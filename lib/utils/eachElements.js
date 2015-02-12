var React = require('react');

function eachElements(children, func) {
  React.Children.forEach(children, function(child) {
    func(child);
    if (child.props && child.props.children) {
      eachElements(child.props.children, func);
    }
  });
};

module.exports = eachElements;
