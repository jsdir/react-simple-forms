var React = require('react/addons');
var invariant = require('react/lib/invariant');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    name: React.PropTypes.string,
    validators: React.PropTypes.object,
    _formContext: React.PropTypes.object.isRequired
  },

  componentDidMount: function() {
    if (this.props.name) {
      this.setValue(null, true);
    }

    var element = this.refs.element;
    var fieldData = this.getFieldData();
    if (element && fieldData.first) {
      setTimeout(function() {
        element.getDOMNode().focus();
      }, 0);
    }
  },

  setValue: function(value, pristine) {
    var formContext = this.getFormContext();
    formContext.changeField(this.props.name, value,
      this.props.validators, pristine);
  },

  getFormContext: function() {
    return this.props._formContext;
  },

  getFieldData: function() {
    return this.getFormContext().getField(this.props.name);
  },

  makeField: function(element, options) {
    var self = this;
    var setValue = this.setValue;
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var handleEvents = options && options.handleEvents;
    var formContext = this.getFormContext();
    var fieldData = this.getFieldData();

    return cloneWithProps(element, {
      className: fieldData.state === 'invalid' && formContext.errorClass,
      name: this.props.name,
      value: fieldData.value,
      ref: 'element',
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
