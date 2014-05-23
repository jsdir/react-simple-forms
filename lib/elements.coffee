React = require "react"

###*
 * An internal wrapper component for a form field.
###
FieldWrapper = React.createClass
  displayName: "FieldWrapper"

  getInitialState: ->
    invalid: false
    showIndicator: false

  onChange: (value) ->
    @hideError()
    @setState {value}
    @validate value if schema.interactive
    @props.onChange value

  onFocus: -> @hideError()

  hideError: -> @setState showIndicator: false, invalid: false

  onBlur: ->
    if @state.value and not @props.fieldData.interactive
      @validate @state.value

  validate: (value) ->
    validate.validateField @props.fieldData, value, (message) =>
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

###*
 * Shows an error message on validation error or failure.
###
Message = React.createClass
  displayName: "FormMessage"

  propTypes:
    message: React.PropTypes.string,

  render: ->
    React.DOM.div className: "error-message", @props.message

module.exports = {
  FieldWrapper
  Message
}
