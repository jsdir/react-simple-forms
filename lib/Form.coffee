React = require "react"

elements = require "./elements"
validate = require "./validate"

Form = React.createClass
  displayName: "Form"

  propTypes:
    components: React.PropTypes.func.isRequired
    messages: React.PropTypes.object
    onSubmit: React.PropTypes.func
    schema: React.PropTypes.object.isRequired

  childContextTypes:
    messages: React.PropTypes.object
    onChange: React.PropTypes.func
    schema: React.PropTypes.object
    setMessage: React.PropTypes.func
    submit: React.PropTypes.func

  getChildContext: ->
    messages: @props.messages
    onChange: @onFieldChange
    schema: @props.schema
    setMessage: @setFieldMessage
    submit: @submit

  getInitialState: ->
    showMessage: false
    message: ""

  onFieldChange: (field, value) ->
    @setState showMessage: false
    #@setState data.field: value

  setFieldMessage: (field, message) ->
    @setState {showMessage: true, message}

  submit: ->
    # Interactive fields have shown validity through the cumulative results
    # from setFieldMessage.
    fieldsData =
      schema: @props.schema
      messages: @props.messages

    # validateAll should exclude setFieldMessage aggregates.
    validate.validateAll fieldsData, @state.data, (message) ->
      # dupe
      if message
        @setState {showMessage: true, message}
        @setState field valid colors
      else
        @setState showMessage: false

  render: -> @props.components()

module.exports = Form
