var React = require('react/addons');

var Mixin = require('./Mixin');

var Field = React.createClass({
  displayName: 'Field',
  mixins: [
    React.addons.PureRenderMixin,
    Mixin
  ],
  render: function() {
    var element = React.Children.only(this.props.children);
    return this.renderField(element, {handleEvents: this.props.handleEvents});
  }
});

module.exports = Field;
