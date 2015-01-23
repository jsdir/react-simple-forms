import React from 'react';

import FormMixin from '../FormMixin';

export default React.createClass({

  mixins: [FormMixin],

  render() {
    var form = this.getForm();
    if (form.message) {
      return <div class={form.errorClass}>form.message</div>
    }
  }
});
