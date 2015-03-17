var _ = require('lodash');
var React = require('react/addons');
var invariant = require('react/lib/invariant');
var cloneWithProps = require('react/lib/cloneWithProps');
var update = require('react/lib/update');
var RSVP = require('rsvp');

var applyContext = require('./utils/applyContext');

function isPromise(value) {
  return value && value.then;
}

var Form = React.createClass({
  displayName: 'Form',
  mixins: [React.addons.PureRenderMixin],
  propTypes: {
    validators: React.PropTypes.object,
    onSubmit: React.PropTypes.func,
    onSuccess: React.PropTypes.func,
    onErrors: React.PropTypes.func
  },

  componentWillMount: function() {
    this._debouncedFuncs = {};
    this._loadingValidators = {};
    this._fieldCount = 0;
    this._formState = {
      submitting: false,
      submitted: false,
      submitError: null
    };

    this._formElements = [];
    this._formFieldElements = {};
    this._fieldStates = {};

    this.setAvailableValidators(this.props);
  },

  componentWillReceiveProps: function(nextProps) {
    this.setAvailableValidators(nextProps);
  },

  getDefaultProps: function() {
    return {
      defaultValues: {}
    };
  },

  getContext: function() {
    return {
      // Element methods
      registerElement: this.registerElement,
      unregisterElement: this.unregisterElement,

      // Field methods
      registerField: this.registerField,
      unregisterField: this.unregisterField,
      changeFieldValue: this.changeFieldValue,

      // Form methods
      submit: this.submit,

      // getState methods
      getFormState: this.getFormState,
      getFieldState: this.getFieldState
    };
  },

  getFormState: function() {
    return {
      submitting: this._formState.submitting,
      submitted: this._formState.submitted,
      submitError: this._formState.submitError,
      validatorNames: this.validatorNames
    };
  },

  setAvailableValidators: function(props) {
    this.validatorNames = _.keys(props.validators);
  },

  // Element methods

  registerElement: function(element) {
    this._formElements.push(element);
  },

  unregisterElement: function(element) {
    this._formElements = _.without(this._formElements, element);
  },

  // Field methods

  registerField: function(element, fieldName, validators) {
    this._formFieldElements[fieldName] = element;
    var value = this.props.defaultValues[fieldName] || null;
    var initialFieldState = {
      value: value,
      error: null,
      state: 'loading', // Set to loading for initial validation.
      isPristine: true,
      isFirst: this._fieldCount++ === 0
    };

    this._fieldStates[fieldName] = initialFieldState;

    // Initially validate the newly-registered field.
    this._updateFieldValidationState(fieldName, value, validators);
  },

  unregisterField: function(fieldName) {
    delete this._formFieldElements[fieldName];
    delete this._fieldStates[fieldName];
  },

  changeFieldValue: function(fieldName, value, params) {
    var _this = this;
    params = params || {};

    // Set field loading state.
    _this._updateFieldState(fieldName, {
      value: value,
      state: 'loading',
      error: null,
      isPristine: false
    });

    function change() {
      // TODO: Add a promise to this._loadingValidators to prevent a race
      // condition.
      _this._updateFieldValidationState(fieldName, value, params.validators);
    }

    if (params.debounce) {
      if (!this._debouncedFuncs[fieldName]) {
        this._debouncedFuncs[fieldName] = _.debounce(function(func) {
          func();
        }, params.debounce);
      }
      this._debouncedFuncs[fieldName](change);
    } else {
      change();
    }
  },

  _updateFieldValidationState: function(fieldName, value, validators) {
    var self = this;

    // Keep track of loading validators.
    var promise = this.validateField(fieldName, value, validators)
      .then(function(message) {
        var state;
        if (message) {
          state = {state: 'invalid', error: message};
        } else {
          state = {state: 'valid', error: null};
        }

        self._updateFieldState(fieldName, state);
      })
      .catch(function(err) {
        self._updateFieldState({state: 'invalid', error: err});
      })
      .finally(function() {
        delete self._loadingValidators[fieldName];
      });

    this._loadingValidators[fieldName] = promise;
  },

  _updateFieldState: function(fieldName, state) {
    _.extend(this._fieldStates[fieldName], state);
    // Re-render the changed element.
    this._formFieldElements[fieldName].forceUpdate();
  },

  _updateFormState: function(state) {
    _.extend(this._formState, state);
    _.each(this._formElements, function(element) {
      element.forceUpdate();
    });
  },

  getFieldState: function(fieldName) {
    return this._fieldStates[fieldName];
  },

  setFieldValue: function(fieldName, value) {
    this._updateFieldState(fieldName, {
      value: value,
      state: 'valid',
      error: null
    });
  },

  // Form methods

  submit: function() {
    var self = this;

    if (this.props.onSubmit) {
      this.props.onSubmit();
    }

    // Change form state for all form elements.
    this._updateFormState({
      submitting: true,
      submitted: true,
      submitError: null
    });

    // Asynchronously wait for all loading validations before using errors.
    RSVP.hash(this._loadingValidators || {})
      .then(function() {
        var errors = _.mapValues(self._fieldStates, 'error');
        var filteredErrors = _.pick(errors, _.identity);
        if (!_.isEmpty(filteredErrors)) {
          return self.handleErrors(filteredErrors);
        }

        return self.handleSuccess(_.mapValues(self._fieldStates, 'value'));
      })
      .catch(function(err) {
        console.error((err && err.stack) || err);
      });
  },

  validateField: function(name, value, validators) {
    var self = this;

    // Only check for errors if validators are defined for the field.
    if (!validators) {
      return RSVP.resolve(null);
    }

    // Combine into one resolved error string or null.
    var result = RSVP.resolve(null);

    // TODO: Even though it is supported my most major browsers, make the
    // validator order explicit instead of depending on the object's key order.
    _.each(validators, function(options, validatorName) {
      result = result.then(function() {
        // Validator will return a validation result value (error or null) or
        // a promise that will be fulfilled with a validation result value.
        var result = self.props.validators[validatorName](value, options);
        if (isPromise(result)) {
          // Reject on error
          result.then(function(value) {
            if (value) {
              return RSVP.reject(value);
            }
            return null;
          });
        } else if (result) {
          // Handle static value
          result = RSVP.reject(result);
        } else {
          // Handle static value
          result = RSVP.resolve(null);
        }

        return result;
      });
    });

    return result.catch(function(err) {
      return err;
    });
  },

  handleErrors: function(errors) {
    if (this.props.onErrors) {
      this.props.onErrors(errors);
    }
    this._updateFormState({submitting: false});
  },

  handleSuccess: function(data) {
    var self = this;
    if (this.props.onSuccess) {
      var promise = this.props.onSuccess(data);

      if (isPromise(promise)) {
        return promise.then(function() {
          self._updateFormState({submitting: false});
        }).catch(function(err) {
          self._updateFormState({submitError: err, submitting: false});
        });
      }
    }

    self._updateFormState({submitting: false});
  },

  handleKeyDown: function(e) {
    if (e.key === 'Enter') {
      this.submit();
    }
  },

  render: function() {
    // Add form data to all field props.
    applyContext(this.props.children, {
      _formContext: this.getContext()
    }, []);

    return React.DOM.div({
      className: 'Form',
      onKeyDown: this.handleKeyDown
    }, this.props.children);
  }
});

module.exports = Form;
