import React from 'react/addons';

import FormMixin from '../FormMixin';
import updateCursors from '../utils/updateCursors';

const {cloneWithProps} = React;

var addClickHandler = (element, handler) => {
  return cloneWithProps(element, {onClick: handler});
};

export default React.createClass({

  mixins: [FormMixin],

  propTypes: {
    name: React.PropTypes.string.isRequired,
    addFieldsetElement: React.PropTypes.element.isRequired,
    removeFieldsetElement: React.PropTypes.element.isRequired
  },

  addFieldset() {
    this.form.addFieldset(this);
  },

  removeFieldset(index) {
    this.form.removeFieldset(this, index);
  },

  renderFieldSets() {
    var self = this;
    return list.map((item, index) => {
      return <div>
        updateCursors(item, [self.props.name, index]),
        addClickHandler(self.props.removeFieldsetElement, () => {
          self.removeFieldset(index);
        })
      </div>;
    });
  },

  render() {
    return <div>
      this.renderFieldSets(),
      addClickHandler(this.props.addFieldsetElement, this.addFieldset);
    </div>;
  }
});
