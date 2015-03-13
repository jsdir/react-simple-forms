var _ = require('lodash');
var React = require('react/addons');
var invariant = require('react/lib/invariant');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    name: React.PropTypes.string,
    validators: React.PropTypes.object,
    debounce: React.PropTypes.number
  },

  contextTypes: {
    _formContext: React.PropTypes.object.isRequired
  },

  componentWillMount: function() {
    var formContext = this.getFormContext();
    var formState = formContext.getFormState();

    // Throw an error if the field uses undefined validators.
    var validatorNames = _.keys(this.props.validators);
    var diff = _.difference(validatorNames, formState.validatorNames);
    if (diff.length > 0) {
      invariant(false, 'Validator(s) `%s` not defined in the form', diff);
    }

    formContext.registerElement(this);
    if (this.isField()) {
      formContext
        .registerField(this, this.props.name, this.props.validators);
    }
  },

  componentDidMount: function() {
    // Focus on the first field.
    var element = this.refs.element;
    var fieldState = this.getFieldState();
    if (element && fieldState.isFirst) {
      setTimeout(function() {
        element.getDOMNode().focus();
      }, 0);
    }
  },

  componentWillUnmount: function() {
    var formContext = this.getFormContext();
    formContext.unregisterElement(this);

    if (this.isField()) {
      formContext.unregisterField(this.props.name);
    }
  },

  // Utilities

  getFormContext: function() {
    return this.context._formContext;
  },

  getFormState: function() {
    return this.getFormContext().getFormState();
  },

  getFieldState: function() {
    return this.getFormContext().getFieldState(this.props.name);
  },

  isField: function() {
    return !!this.props.name;
  },

  // Methods

  setValue: function(value) {
    this.getFormContext().changeFieldValue(this.props.name, value, {
      validators: this.props.validators,
      debounce: this.props.debounce
    });
  },

  renderField: function(element, options) {
    var setValue = this.setValue;
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var errorClass = this.getFormState().errorClass;
    var handleEvents = options && options.handleEvents;
    var fieldState = this.getFieldState();

    // TODO: Use `React.cloneElement` from react v0.13.
    // `cloneElement` will apply refs

    return cloneWithProps(element, {
      className: fieldState.state === 'invalid' && errorClass,
      name: this.props.name,
      value: fieldState.value,
      // ref: 'element',
      onChange: function(value) {
        if (handleEvents) {
          value = value.target.value;
        }
        setValue(value);
      }
    });
  }
};

module.exports = Mixin;
