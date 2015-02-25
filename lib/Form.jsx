var _ = require('lodash');
var React = require('react');
var invariant = require('react/lib/invariant');
var update = require('react/lib/update');
var RSVP = require('rsvp');

var eachElements = require('./utils/eachElements.js');

function isPromise(value) {
  return value && value.then;
}

var Form = React.createClass({
  propTypes: {
    validators: React.PropTypes.object,
    onSubmit: React.PropTypes.func,
    onSuccess: React.PropTypes.func,
    onErrors: React.PropTypes.func,
    errorClass: React.PropTypes.string,
    tabOnEnter: React.PropTypes.bool
  },

  componentWillMount: function() {
    this.setAvailableValidators(this.props);
  },

  componentWillReceiveProps: function(nextProps) {
    this.setAvailableValidators(nextProps);
  },

  getInitialState: function() {
    return {
      submitting: false,
      fields: {}
    };
  },

  getDefaultProps: function() {
    return {
      errorClass: 'Form-error',
      tabOnEnter: true
    };
  },

  getContext: function() {
    return {
      getField: this.getField,
      changeField: this.changeField,
      submit: this.submit,
      submitting: this.state.submitting,
      errorClass: this.props.errorClass
    };
  },

  submit: function() {
    var self = this;

    if (this.props.onSubmit) {
      this.props.onSubmit();
    }

    this.setState({submitting: true});

    // Asynchronously validate all of the field data.
    RSVP.hash(_.mapValues(this.state.fields, 'error'))
      .then(function(errors) {
        self.setState({submitting: false});
        if (!_.isEmpty(_.filter(errors, _.identity))) {
          return self.handleErrors(errors);
        }
        return self.handleSuccess(_.mapValues(this.state.fields, 'value'));
      });
  },

  setAvailableValidators: function(props) {
    this.validatorNames = _.keys(props.validators);
  },

  validateField: function(name, value, validators) {
    var self = this;

    // Only check for errors if validators are defined for the field.
    if (!validators) {
      return RSVP.resolve(null);
    }

    // Combine into one resolved error string or null.
    return RSVP.all(_.map(validators, function(options, validatorName) {
      // Validator will return a validation result value (error or null) or
      // a promise that will be fulfilled with a validation result value.
      var result = self.props.validators[validatorName](value, options);
      if (!isPromise(result)) {
        // Convert static values to a resolved promise.
        if (result) {
          return RSVP.reject(result);
        }
        return RSVP.resolve();
      }
      return result.then(function(value) {
        if (value) {
          return RSVP.reject(value);
        }
        return null;
      });
    })).then(function(results) {
      return null;
    }).catch(function(err) {
      return err;
    });
  },

  handleErrors: function(errors) {
    if (this.props.onErrors) {
      this.props.onErrors(errors);
    }
  },

  handleSuccess: function(data) {
    if (this.props.onSuccess) {
      this.props.onSuccess(data);
    }
  },

  getField: function(name) {
    return this.state.fields[name] || {
      value: null, state: 'pristine', error: null
    };
  },

  changeField: function(name, value, validators) {
    var self = this;
    // Check for undefined validators.
    var diff = _.difference(_.keys(validators), this.validatorNames);
    if (diff.length > 0) {
      invariant(false, 'Validator(s) `%s` were not defined in the form', diff);
    }

    var data = {};
    data[name] = {$set: {value: value, state: 'loading', error: null}};
    this.setState({fields: update(this.state.fields, data)});

    this.validateField(name, value, validators)
      .then(function(message) {
        data = {};
        if (message) {
          data[name] = {$set: {state: 'invalid', error: message}};
        } else {
          data[name] = {$set: {state: 'valid'}};
        }
        self.setState({fields: update(self.state.fields, data)});
      });
  },

  render: function() {
    var formContext = this.getContext();
    // Add form data to all field props.
    var fieldNames = [];

    eachElements(this.props.children, function(child) {
      // Only add form context if the child is a field.
      if (child.props) {
        child.props._formContext = formContext;
        // Add field name to an ordered field list used for tabbing and
        // getting the first message.
        fieldNames.push(child.props.name);
      }
    });

    this.fieldNames = fieldNames;
    return <form>{this.props.children}</form>;
  }
});

module.exports = Form;
