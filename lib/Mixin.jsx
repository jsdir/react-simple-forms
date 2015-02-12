var React = require('react/addons');

var cloneWithProps = React.addons.cloneWithProps;

var Mixin = {
  propTypes: {
    _formContext: React.PropTypes.object.isRequired
  },

  getFormContext: function() {
    return this.props._formContext;
  },

  makeField: function(element, options) {
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
