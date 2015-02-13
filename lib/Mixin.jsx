var React = require('react/addons');
var invariant = require('react/lib/invariant');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    name: React.PropTypes.string,
    validators: React.PropTypes.object,
    _formContext: React.PropTypes.object.isRequired
  },

  getFormContext: function() {
    return this.props._formContext;
  },

  makeField: function(element, options) {
    var self = this;
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var formContext = this.getFormContext();
    var handleEvents = options && options.handleEvents;

    return cloneWithProps(element, {
      name: self.props.name,
      value: formContext.getField(self.props.name).value,
      onChange: function(value) {
        if (handleEvents) {
          value = value.target.value;
        }
        formContext.changeField(self.props.name, value, self.props.validators);
      }
    });
  }
};

module.exports = Mixin;
