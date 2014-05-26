React = require "react"

elements = require "./elements"
validate = require "./validate"

update = require "react/lib/update"

Form = React.createClass
  displayName: "Form"

  propTypes:
    children: React.PropTypes.func.isRequired
    # or components
    defaults: React.PropTypes.object
    messages: React.PropTypes.object
    onSubmit: React.PropTypes.func
    schema: React.PropTypes.object.isRequired

  childContextTypes:
    defaults: React.PropTypes.object
    messages: React.PropTypes.object
    message: React.PropTypes.string
    onChange: React.PropTypes.func
    schema: React.PropTypes.object
    setValidationResult: React.PropTypes.func
    submit: React.PropTypes.func

  getChildContext: ->
    defaults: @props.defaults
    messages: @props.messages
    message: @state.message
    onChange: @onFieldChange
    schema: @props.schema
    setValidationResult: @setValidationResult
    submit: @submit

  getInitialState: ->
    data: {} # Representation of all values of all fields in the form.
    invalidFields: {}
    message: null

  onFieldChange: (field, value) ->
    pair = {}
    pair[field] = value
    data = update @state.data, "$set": pair
    @setState {message: null, data}

  setValidationResult: (field, message) ->
    if message
      # The validation failed.
      @setState {message}
    else
      pair = {}
      pair[field] = message?
      data = update @state.invalidFields, "$set": pair
      @setState {message: null, data}

  submit: ->
    # Interactive fields have shown validity through the cumulative results
    # from setFieldMessage.
    fieldsData =
      schema: @props.schema
      messages: @props.messages

    # validateAll should exclude setFieldMessage aggregates.
    validate.validateAll fieldsData, @state.data, (message) =>
      # dupe
      if message
        @setState {showMessage: true, message}
        @setState field valid colors
      else
        @setState showMessage: false

  render: -> @transferPropsTo @props.components()

module.exports = Form
