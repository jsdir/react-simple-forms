React = require "react"
cx = require "react/lib/cx"

inputs = require "./inputs"
validate = require "./validate"

###*
 * A component for a form field.
###
Field = React.createClass
  displayName: "Field"

  propTypes:
    name: React.PropTypes.string.isRequired

  contextTypes:
    defaults: React.PropTypes.object
    onChange: React.PropTypes.func
    messages: React.PropTypes.object
    schema: React.PropTypes.object
    setValidationResult: React.PropTypes.func

  getInitialState: ->
    invalid: false
    showIndicator: false
    value: @context.defaults?[@props.name]

  componentDidMount: ->
    # Only validate initially when a default value is present.
    @validate @state.value if @state.value

  getFieldSchema: ->
    if @props.name of @context.schema
      return @context.schema[@props.name]
    else
      throw new Error "A field with name \"#{@props.name}\" does not exist " +
        "in the schema."

  onChange: (value) ->
    @hideError()
    @setState {value}
    @validate value if @getFieldSchema().interactive
    @context.onChange @props.name, value

  onFocus: ->
    @hideError()

  hideError: ->
    @setState showIndicator: false, invalid: false

  onBlur: ->
    # Validate non-empty, non-interactive fields on blur.
    if @state.value and not @getFieldSchema().interactive
      @validate @state.value

  validate: (value) ->
    validate.validateField
      name: @props.name
      schema: @getFieldSchema()
      messages: @context.messages
    , value, (message) =>
      # All interactive fields will show an indicator on input.
      @setState showIndicator: true, invalid: message?
      @context.setValidationResult @props.name, message

  render: ->
    # Default to StringInput if no Input was given in the schema.
    fieldSchema = @getFieldSchema()
    input = fieldSchema.input or inputs.TextInput
    return input
      placeholder: fieldSchema.placeholder
      value: @state.value
      onChange: @onChange
      onFocus: @onFocus
      onBlur: @onBlur
      invalid: @state.invalid
      showIndicator: @state.showIndicator

###*
 * Shows an error message on validation error or failure.
###
Message = React.createClass
  displayName: "FormMessage"

  contextTypes:
    message: React.PropTypes.string

  render: ->
    className = cx "error-message": @context.message?
    React.DOM.div {className}, @context.message

###*
 * Wraps a submit button or anything with an onClick callback.
###
Submit = React.createClass
  displayName: "FormSubmit"

  propTypes:
    children: React.PropTypes.component.isRequired

  contextTypes:
    submit: React.PropTypes.func.isRequired

  render: ->
    childProps = @props.children.props

    if childProps.onClick
      # Run any existing onClick handler even through we are overriding the
      # handler.
      existingHandler = childProps.onClick
      childProps.onClick = =>
        console.log "wo"
        existingHandler()
        @context.submit()
    else
      childProps.onClick = =>
        console.log "asdasd"
        @context.submit()

    return @props.children

module.exports = {Field, Message, Submit}
