import React from 'react/addons';

import FormMixin from '../FormMixin';
import createChainedFunction from '../utils/createChainedFunction';

const {cloneWithProps} = React.addons

export default React.createClass({

  mixins: [FormMixin],

  render() {
    var form = this.getForm();
    var child = this.props.children[0];
    return cloneWithProps(child, {
      onClick: createChainedFunction(child.props.onClick, form.submit)
    });
  }
});
