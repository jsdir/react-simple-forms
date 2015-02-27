var React = require('react');
var cloneWithProps = require('react/lib/cloneWithProps');

function cloneAllWithProps(children, props, fieldNames) {
  return React.Children.map(children, function(originalChild) {
    // Skip non-elements.
    if (!React.isValidElement(originalChild)) {
      return originalChild;
    }

    // Skip children that have refs.
    if (originalChild.ref) {
      return originalChild;
    }

    var child = cloneWithProps(originalChild, props);

    if (child.props) {
      // Recursively apply the props.
      if (child.props.children) {
        child.props.children = cloneAllWithProps(child.props.children,
          props, fieldNames);
      }

      // If field, add field name to an ordered field list used for
      // tabbing and getting the first error.
      if (child.props.name) {
        fieldNames.push(child.props.name);
      }
    }

    return child;
  });
}

module.exports = cloneAllWithProps;
