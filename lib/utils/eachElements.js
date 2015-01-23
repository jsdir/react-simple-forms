import React from 'react';

const eachElements = (children, func) => {
  React.Children.forEach(children, (child) => {
    func(child);
    if (child.props && child.props.children) {
      eachElements(child.props.children, func);
    }
  });
};

export default eachElements;
