import React from 'react/addons';

import createChainedFunction from './utils/createChainedFunction';

const {cloneWithProps} = React.addons;

export default {

  getForm() {
    return this.props._form;
  },

  getCursor(name) {
    return this._formCursor.concat(name);
  },

  onChange(value) {
    this._form.onChange(this.getCursor(), value);
  },

  /**
   * Wraps a field.
   */
  wrapField(fieldName, element) {
    // TODO: ensure that element is only one valid Element, otherwise throw
    // invariant
    return cloneWithProps(element, {
      onChange: createChainedFunction(element.props.onClick, this.onChange),
      value: this._form.getValue(this.getCursor(fieldName))
    })
  }
};
