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

  componentWillUpdate: function() {
    var fieldData = this.getFieldData();
    if (fieldData.focused && this.refs.element) {
      var node = this.refs.element.getDOMNode();
      if (node.focus) {
        node.focus();
      }
    }
  },

  makeField: function(element, options) {
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
      // TODO: merge handlers with existing props
      onFocus: function() {
        fieldData.focus(this.props.name);
      },
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
