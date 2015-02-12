var React = require('react');

var Mixin = require('./Mixin');

var Input = React.createClass({
  mixins: [Mixin],
  render: function() {
    var element = React.Children.only(props.children);
    return this.makeField(element);
  }
});

module.exports = Input;
