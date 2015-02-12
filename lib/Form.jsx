var _ = require('lodash');
var React = require('react');
var RSVP = require('rsvp');

var eachElements = require('./utils/eachElements.js');

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
    setAvailableValidators(this.props);
  },

  componentWillReceiveProps: function(nextProps) {
    setAvailableValidators(nextProps);
  },

  getInitialState: function() {
    return {
      submitting: false
    };
  },

  getDefaultProps: function() {
    errorClass: 'Form-error',
    tabOnEnter: true
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
    this.props.onSubmit && this.props.onSubmit();
    var data = _.mapValues(this.fields, 'value');
    this.setState({submitting: true});

    // Asynchronously validate all of the field data.
    this.validate(data)
      .then(function(errors) {
        self.setState({submitting: false});
        if (errors) {
          return self.handleErrors(errors);
        }
        return self.handleSuccess(data);
      });
  },

  setAvailableValidators: function(props) {
    this.validatorNames = _.keys(props.validators);
  },

  validate: function(data) {
    var validators = this.props.validators;
    return RSVP.hash(_.mapValues(this.fields, function(field, name) {
      // Only check for errors if validators are defined for the field.
      if (!field.validators) {
        return RSVP.resolve(null);
      }

      // Consolidate to one error or null
      return RSVP.all(_.map(field.validators, function(options, validatorName) {
        // Validator will return a validation result value (error or null) or a
        // promise that will be fulfilled with a validation result value.
        var result = validators[name](field.value, options);
        if (RSVP.isPromise(result)) {
          return result;
        }
        // Convert static values to fulfilled promises.
        return RSVP.resolve(result);
      })).then(function() {
        // No errors were thrown.
        return null;
      }).catch(function(err) {
        // Resolve with the error.
        return err;
      });
    }))
      .then(_.compact); // Remove null error messages.
      .then(function(errors) {
        // Return null if there are no errors.
        if (_.size(errors) === 0) {
          return null;
        }
        return errors;
      });
  },

  handleErrors: function(errors) {
    this.props.onErrors && this.props.onErrors(errors);
  },

  handleSuccess: function(data)
    this.props.onSuccess && this.props.onSuccess(data);
  },

  getField: function(name) {
    this.fields = this.fields || {};
    var field = this.fields[name] || {value: null};
    this.fields[name] = field;
    return field;
  },

  changeField: function(name, value, validators) {
    // Check for undefined validators.
    var diff = _.difference(_.keys(validators), this.validatorNames);
    if (diff.length > 0) {
      invariant(false, 'Validator(s) %s were not defined in the form', diff);
    }
    this.fields[name] = {value: value, validators: validators);
    this.forceUpdate();
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
