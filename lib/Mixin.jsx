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
      this.setValue(null);
    }
  },

  setValue: function(value) {
    var formContext = this.getFormContext();
    formContext.changeField(this.props.name, value, this.props.validators);
  },

  getFormContext: function() {
    return this.props._formContext;
  },

  makeField: function(element, options) {
    var setValue = this.setValue;
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var handleEvents = options && options.handleEvents;
    var formContext = this.getFormContext();
    var field = formContext.getField(this.props.name);

    return cloneWithProps(element, {
      className: field.state === 'invalid' && formContext.errorClass,
      name: this.props.name,
      value: field.value,
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
