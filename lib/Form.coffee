React = require "react"

mixins = require "./mixins"

{validateField, validateAll} = require "./validate"
{div} = React.DOM

Form = React.createClass
  displayName: "Form"

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

  render: -> div null, @props.children
    React.Children.map @props.children (child) ->
      if child.
    # pass @props.showChecks

###
schema.interactive always shows indicators
###

Form = React.createClass
  displayName: "Form"

  getInitialState: ->
    showMessage: false
    message: ""

  onFieldChange: (field, value) ->
    @setState showMessage: false
    @setState data.field: value

  setFieldMessage: (field, message) ->
    @setState {showMessage: true, message}

  submit: ->
    # Interactive fields have shown validity through the cumulative results
    # from setFieldMessage.
    fieldsData =
      schema: @props.schema
      messages: @props.messages

    validate.validateAll fieldsData, @state.data, (message) ->
      # dupe
      if message
        @setState {showMessage: true, message}
      else
        @setState showMessage: false

  render: ->
    # Helper method will wrap this.
    div null,
      if @state.showMessage then Forms.Message message: @state.message
      FieldWrapper
        field: inputs.IntegerField()
        setMessage: (message) => @setFieldMessage "field", message
        onChange: (value) => @onFieldChange "field", value
      button onClick: @submit, "Submit"

FieldWrapper = React.createClass
  displayName: "FieldWrapper"

  getInitialState: ->
    invalid: false
    showIndicator: false

  onChange: (value) ->
    ###
    @props.fieldData =
      name: "fieldName"
      schema: schema
      messages: errorMessages
    ###

    @setState {value}


    @validate() if schema.interactive
    if schema.interactive
      validate.validateField @props.fieldData, value, (message) =>
        # All interactive fields will show an indicator on input.
        @setState showIndicator: true, invalid: message?
        @props.setMessage message

    @hideError()
    @props.onChange value

  onFocus: -> @hideError()

  hideError: -> @setState showIndicator: false, invalid: false

  onBlur: ->
    if @state.value and not @props.fieldData.interactive
      @validate @state.value

  validate: ->
    validate.validateField @props.fieldData, @state.value, (message) =>
      # All interactive fields will show an indicator on input.
      @setState showIndicator: true, invalid: message?
      @props.setMessage message

  render: ->
    @props.field
      value: @state.value
      onChange: @onChange
      onFocus: @onFocus
      onBlur: @onBlur
      invalid: @state.invalid
      showIndicator: @state.showIndicator

module.exports = Form
