var _ = require('lodash');
var React = require('react/addons');
var invariant = require('react/lib/invariant');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    name: React.PropTypes.string,
    validators: React.PropTypes.object
  },

  contextTypes: {
    _formContext: React.PropTypes.object.isRequired
  },

  componentWillMount: function() {
    var ctx = this.getFormContext();
    ctx.registerElement(this);

    if (this.isField()) {
      var value = ctx.registerField(this, this.props.name);
      this.setState({value: value});
    }

    /*
    var element = this.refs.element;
    var fieldData = this.getFieldData();
    if (element && fieldData.first) {
      setTimeout(function() {
        element.getDOMNode().focus();
      }, 0);
    }
    */
  },

  componentWillUnmount: function() {
    var ctx = this.getFormContext();
    ctx.unregisterElement(this);

    if (this.isField()) {
      ctx.unregisterField(this.props.name);
    }
  },

  // Utilities

  getFormContext: function() {
    return this.context._formContext;
  },

  getFieldData: function() {
    return this.getFormContext().getFieldData(this.props.name);
  },

  isField: function() {
    return !!this.props.name;
  },

  // Methods

  setValue: function(value) {
    this.getFormContext()
      .changeFieldValue(this.props.name, value, this.props.validators);
  },

  renderField: function(element, options) {
    var setValue = this.setValue;
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var errorClass = this.getFormContext().errorClass;
    var handleEvents = options && options.handleEvents;
    var fieldData = this.getFieldData();

    // TODO: Use `React.cloneElement` when react v0.13 is released.
    // `cloneElement` will apply refs

    return cloneWithProps(element, {
      className: fieldData.state === 'invalid' && errorClass,
      name: this.props.name,
      value: fieldData.value,
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
