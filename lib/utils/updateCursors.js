import React from 'react/addons';

const {cloneWithProps} = React;

const updateCursors = (children, cursor) => {
  return React.Children.map(children, (child) => {
    return updateCursors(cloneWithProps(child, {
      _formCursor: (child.props._formCursor || []).concat(cursor);
    }), cursor);
  });
};

export default updateCursors;
