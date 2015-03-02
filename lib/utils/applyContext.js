var _ = require('lodash');
var React = require('react');

function applyContext(children, context, fieldNames) {
  React.Children.forEach(children, function(child) {
    if (child.props) {
      if (child.props.name) {
        // Add fields to a list.
        fieldNames.push(child.props.name);

        if (child._context) {
          _.extend(child._context, context);
        }
      }

      if (child.props.children) {
        // Recursively apply context.
        applyContext(child.props.children, context, fieldNames);
      }
    }
  });
}

module.exports = applyContext;
