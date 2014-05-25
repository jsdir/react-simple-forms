React = require "react"

inputs = require "./inputs"

###*
 * A component for a form field.
###
Field = React.createClass
  displayName: "FieldWrapper"

  propTypes:
    name: React.PropTypes.string.isRequired

  contextTypes:
    defaults: React.PropTypes.object.isRequired
    initialValues: React.PropTypes.object
    messages: React.PropTypes.object
    onChange: React.PropTypes.func
    schema: React.PropTypes.object
    setMessage: React.PropTypes.func

  getInitialState: ->
    invalid: false
    showIndicator: false
    value: @context.defaults?[@props.name]

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
      @context.setMessage @props.name, message

  render: ->
    # Default to StringInput if no Input was given in the schema.
    input = @getFieldSchema().input or inputs.StringInput

    return input
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

  propTypes:
    message: React.PropTypes.string

  render: ->
    React.DOM.div className: "error-message", @props.message

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
        existingHandler()
        @context.submit()
    else
      childProps.onClick = =>
        console.log "what"
        @context.submit()

    return @props.children

module.exports = {Field, Message, Submit}
