React = require "react"

elements = require "./elements"
validate = require "./validate"

Form = React.createClass
  displayName: "Form"

  propTypes:
    schema: React.PropTypes.object.isRequired
    messages: React.PropTypes.object
    components: React.PropTypes.func.isRequired
    onSubmit: React.PropTypes.func

  childContextTypes: ->
    submit: React.PropTypes.func
    schema: React.PropTypes.object
    onChange: React.PropTypes.func
    setMessage: React.PropTypes.func

  getChildContext: ->
    submit: @submit
    schema: @props.schema
    onChange: @onFieldChange
    setMessage: @setFieldMessage

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

    # validateAll should exclude setFieldMessage aggregates.
    validate.validateAll fieldsData, @state.data, (message) ->
      # dupe
      if message
        @setState {showMessage: true, message}
        @setState field valid colors
      else
        @setState showMessage: false

  ###
  context:
    message: -> elements.Message message: @state.message
    field: (name) ->
      elements.FieldWrapper
        setMessage: @contextSetMessage
        onChange: (value) => @contextOnChange name, value
        fieldData:
          name: name
          schema: @props.schema[name]
          messages: @props.messages

    submit: 1

  contextSetMessage: (message) -> @setState {message}

  contextOnChange: (fieldName, value) ->
    @state.data[fieldName] = value
    @setState data: @state.data
  ###

  render: -> @props.components()
    ###
    @props.components @context
    # Helper method will wrap this.
    React.DOM.div null,
      if @state.showMessage then Forms.Message message: @state.message
      FieldWrapper
        field: inputs.IntegerField()
        setMessage: (message) => @setFieldMessage "field", message
        onChange: (value) => @onFieldChange "field", value
      button onClick: @submit, "Submit"
    ###

###
formComponents = (ctx) ->
  div className: "form",
    ctx.message()
    ctx.field "login"
    ctx.field "password"
    div className: "special-field",
      ctx.field "special-field"
    ctx.submit
      LaddaButton null,
        button null, "Submit"

Forms.Form
  schema: userSchema
  messages: {}
  onSubmit: @submit
  children: ->
    Forms.Message()
    Forms.Field name: "login"
    div className: "special-field",
      Forms.Field name: "password"
    LaddaButton null,
      Forms.Submit null,
        button null, "Submit"
###

module.exports = {Form, makeForm}
