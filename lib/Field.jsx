var React = require('react');

var Mixin = require('./Mixin');

var Field = React.createClass({
  mixins: [Mixin],
  render: function() {
    var element = React.Children.only(this.props.children);
    return this.makeField(element, {handleEvents: this.props.handleEvents});
  }
});

module.exports = Field;
