React = require "react"

inputs = require "./inputs"

###*
 * A component for a form field.
###
Field = React.createClass
  displayName: "FieldWrapper"

  propTypes:
    name: React.PropTypes.string.isRequired
    value: React.PropTypes.any

  contextTypes:
    onChange: React.PropTypes.func
    setMessage: React.PropTypes.func
    schema: React.PropTypes.shape
      interactive: React.PropTypes.bool
      input: React.PropTypes.component

  getInitialState: ->
    value: @props.value
    invalid: false
    showIndicator: false

  onChange: (value) ->
    @hideError()
    @setState {value}
    @validate value if @context.schema.interactive
    @context.onChange @props.name, value

  onFocus: -> @hideError()

  hideError: -> @setState showIndicator: false, invalid: false

  onBlur: ->
    if @state.value and not @context.schema.interactive
      @validate @state.value

  validate: (value) ->
    validate.validateField @props.fieldData, value, (message) =>
      # All interactive fields will show an indicator on input.
      @setState showIndicator: true, invalid: message?
      @context.setMessage @props.name, message

  render: ->
    # Default to StringInput if no Input was given in the schema.
    input = @context.schema.input or inputs.StringInput

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
    message: React.PropTypes.string.isRequired

  render: ->
    React.DOM.div className: "error-message", @props.message

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
      childProps.onClick = ->
        existingHandler()
        @context.submit()
    else
      childProps.onClick = ->
        @context.submit()

module.exports = {Field, Message, Submit}
