import React from 'react/addons';

import FormMixin from './FormMixin';

const {cloneWithProps} = React.addons;

export default React.createClass({

  mixins: [FormMixin],

  propTypes: {
    name: React.PropTypes.string.isRequired
  },

  render() {
    var fieldData = this.getFieldData();
    var props = this.getWrapperProps(fieldData);
    return cloneWithProps(React.Children.only(this.props.children), props);
  }
});
