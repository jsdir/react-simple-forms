import React from 'react';

import FormMixin from './FormMixin';

export default React.createClass({

  mixins: [FormMixin],

  propTypes: {
    name: React.PropTypes.string.isRequired
  },

  render() {
    return this.wrapField(this.props.name, this.props.children);
  }
});
