import React from 'react';

import FormMixin from '../FormMixin';

export default React.createClass({

  mixins: [FormMixin],

  render() {
    var formData = this.getFormData();
    if (formData.message) {
      return <div class={formData.errorClass}>formData.message</div>
    }
  }
});
