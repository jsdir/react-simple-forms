import React from 'react';

import cloneWithProps from 'react/lib/cloneWithProps'

import eachElements from './utils/eachElements';

export default React.createClass({

  propTypes: {
    validate: React.PropTypes.func.isRequired,
    onSuccess: React.PropTypes.func.isRequired,
    onFail: React.PropTypes.func.isRequired
  },

  getInitialState() {
    return {
      messages: null
    };
  },

  submit() {
    this.props.validate({}, (messages, data) => {
      if (messages) {
        this.setState({messages: messages});
        return this.props.onFail(messages);
      }
      this.props.onSuccess(data);
    }.bind(this));
  },

  getFormData() {
    return {
      submit: this.submit,
      messages: this.state.messages
      // error: this.state.error
    };
  },

  render() {
    var formData = this.getFormData();

    // Apply form data to all descendants.
    eachElements(this.props.children, (child) => {
      if (child.props) {
        child.props._form = formData;
      }
    });

    return this.props.children;
  }
});
