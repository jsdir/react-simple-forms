import React from 'react/addons';

import FormMixin from '../FormMixin';
import createChainedFunction from '../utils/createChainedFunction';

const {cloneWithProps} = React.addons

export default React.createClass({

  mixins: [FormMixin],

  render() {
    return cloneWithProps(React.Children.only(child), {
      onClick: createChainedFunction(child.props.onClick, this.submitForm)
    });
  }
});
