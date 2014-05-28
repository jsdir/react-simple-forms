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
    hideError: React.PropTypes.func.isRequired
    fieldStates: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired
    schema: React.PropTypes.object.isRequired
    blurValidate: React.PropTypes.func.isRequired

  getInitialState: ->
    value: @context.defaults?[@props.name]

  getFieldState: ->
    @context.fieldStates[@props.name] or "default"

  getFieldSchema: ->
    if @props.name of @context.schema
      return @context.schema[@props.name]
    else
      throw new Error "A field with name \"#{@props.name}\" does not exist " +
        "in the schema."

  onChange: (value) ->
    @context.onChange @props.name, value

  onFocus: ->
    @context.hideError @props.name

  onBlur: ->
    @context.blurValidate @props.name

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
      fieldState: @getFieldState()

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
        existingHandler()
        @context.submit()
    else
      childProps.onClick = =>
        @context.submit()

    return @props.children

module.exports = {Field, Message, Submit}
