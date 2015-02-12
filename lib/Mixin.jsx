var React = require('react/addons');
var invariant = require('react/lib/invariant');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    _formContext: React.PropTypes.object.isRequired
  },

  getFormContext: function() {
    return this.props._formContext;
  },

  makeField: function(element, options) {
    if (!this.props.name) {
      invariant(false, 'All fields must have a unique `name` prop');
    }

    var formContext = this.getFormContext();
    var handleEvents = options && options.handleEvents;

    return cloneWithProps(element, {
      name: this.props.name,
      value: formContext.getField(this.props.name).value,
      onChange: function(value) {
        if (handleEvents) {
          value = value.target.value;
        }
        formContext.changeField(this.props.name, value);
      }
    });
  }
};

module.exports = Mixin;
