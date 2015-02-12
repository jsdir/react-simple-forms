var _ = require('lodash');
var React = require('react');

var eachElements = require('./utils/eachElements.js');

var Form = React.createClass({
  propTypes: {
    onSubmit: React.PropTypes.func,
    onSuccess: React.PropTypes.func
  },
  getContext: function() {
    return {
      getField: this.getField,
      changeField: this.changeField,
      submit: this.submit
    };
  },
  submit: function() {
    this.props.onSubmit && this.props.onSubmit();
    var data = _.mapValues(this.fields, 'value');
    this.props.onSuccess && this.props.onSuccess(data);
  },
  getField: function(name) {
    this.fields = this.fields || {};
    var field = this.fields[name] || {value: null};
    this.fields[name] = field;
    return field;
  },
  changeField: function(name, value) {
    this.fields[name].value = value;
    this.forceUpdate();
  },
  render: function() {
    var formContext = this.getContext();
    // Add form data to all field props.
    var fieldNames = [];

    eachElements(this.props.children, function(child) {
      // Only add form context if the child is a field.
      if (child.props) {
        child.props._formContext = formContext;
        // Add field name to an ordered field list used for tabbing and
        // getting the first message.
        fieldNames.push(child.props.name);
      }
    });

    this.fieldNames = fieldNames;
    return <form>{this.props.children}</form>;
  }
});

module.exports = Form;

/*import React from 'react/addons';

import {triggers} from './symbols';
import eachElements from './utils/eachElements';

const {update} = React.addons;

export default React.createClass({

  propTypes: {
    validate: React.PropTypes.func.isRequired,
    onSuccess: React.PropTypes.func.isRequired,
    onError: React.PropTypes.func.isRequired,
    errorClass: React.PropTypes.string,
    tabOnEnter: React.PropTypes.bool
  },

  getInitialState() {
    return {
      fields: {}
    };
  },

  getDefaultProps() {
    return {
      errorClass: 'Form-error',
      tabOnEnter: true
    };
  },

  getFirstMessage(messages) {
    (this.fieldList || []).each(name => {
      if (name in messages) {
        return name;
      }
    });
  },

  addMessages(fields, messages) {
    return fields.map((name, field) => {
      return Object.merge(field, {message: messages[name]});
    });
  },

  validateField(name, value, validationTrigger) {
    this.setField({lastTrigger: validationTrigger, status: status.pending});
    this.props.validate(this.getData(), name, messages => {
      if (messages) {
        // set field.message: messages[name], status: status.invalid
        // set message: messages[name]
      } else {
        // set message: null, status: status.valid
      }
    })
  },

  getData() {
    return this.state.fields.map(field => {
      return field.value || null;
    });
  },

  submit() {
    this.props.validate(this.getData(), null, (messages, data) => {
      if (messages) {
        this.setState({
          messages: messages,
          message: this.getFirstMessage(messages),
          fields: this.addMessages(this.state.fields, messages)
        });
        return this.props.onError(messages);
      }
      this.props.onSuccess(data);
      // TODO: set lastTrigger to triggers.submit
    });
  },

  onChange(name, value, validationTrigger=triggers.blur) {
    // Update field value and validation trigger.
    this.setState(update(this.state, {
      fields: {$merge: {[name]: {value, validationTrigger}}}
    }));

    // TODO: set global.message: null. Message dissappears when any field changes
    // change changed field to status: none, message: none

    // Validate on change if field uses input validation trigger.
    if (validationTrigger === triggers.input) {
      this.validateField(name, value, triggers.input)
    }
  },

  onFocus(name) {

  },

  onBlur(name) {
    var field = this.state.fields.name;
    // TODO: default onBlur
    if (field && field.trigger === triggers.onBlur) {
      this.validateField(name, value, triggers.onBlur);
    }
  },

  getFormContext() {
    return {
      // Form data
      message: this.state.message,
      errorClass: this.props.errorClass,

      // Form callbacks
      submit: this.submit,
      onChange: this.onChange,
      onFocus: this.onFocus,
      onBlur: this.onBlur,

      // Field data
      fields: this.state.fields
    };
  },

  render() {
    var formContext = this.getFormContext();

    // Add form data to all field props.
    this.fieldList = [];
    eachElements(this.props.children, (child) => {
      // Only add form context if the child is a field.
      if (child.props && child.props.name) {
        child.props._formContext = formContext;
        // Add field name to an ordered field list used for tabbing and
        // getting the first message.
        this.fieldList.push(child.props.name);
      }
    });

    return this.props.children;
  }
});
*/
