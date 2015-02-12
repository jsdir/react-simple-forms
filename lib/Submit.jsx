var React = require('react');

var createChainedFunc = require('./utils/createChainedFunc');
var Mixin = require('./Mixin');

var cloneWithProps = React.addons.cloneWithProps;

var Submit = React.createClass({
  mixins: [Mixin],

  render: function() {
    var formContext = this.getFormContext();
    var child = React.Children.only(this.props.children);

    return cloneWithProps(child, {onClick: createChainedFunc(
      formContext.submit, child.props.onClick
    )});
  }
});

module.exports = Submit;
