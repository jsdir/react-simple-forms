React = require "react"

mixins = require "./mixins"

{validateField, validateAll} = require "./validate"

Form = React.createClass
  displayName: "Form"

  mixins: [mixins.FormContextMixin]

  getInitialState: -> data: {}

  onFieldChange: (field, value) ->
    # First, set the field's state value.
    state = data: {}
    state.data[field] = value

    schema = @props.schema[field]
    if schema.continuousValidation

      # Second, set the field state as pending.
      state = {}
      state[field].pending = true
      @setState state

      # Third, perform validation. The validation methods may be either
      # synchronous or asynchronous.
      state = {}
      validateField field, schema, value, (err, message) =>
        state[field].pending = false
        errorMessage = err or message
        if errorMessage
          # Internal error or validation error happened.
          state[field].valid = false
          state.error = errorMessage
        else
          # No error happened.
          state[field].valid = true

    @setState state

  onFieldFocus: (field) ->
    # Focusing on a field removes all associated error indicators.
    state = {}
    state[field]

  onFieldBlur: (field) ->

  submit: ->
    # Validate the entire form before running the success callback.
    validateAll @props.schema, @state.data, (messages, data, firstMessage) ->
      if firstMessage
        # Internal error or validation error happened.
        @setState error: firstMessage
      else
        # No error happened.
        @props.onSubmit data

  render: -> @props.children
    # React.Children.map @props.children (child) ->
    # pass @props.showChecks

module.exports = Form
