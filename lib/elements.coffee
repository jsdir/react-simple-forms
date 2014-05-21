React = require "react"

mixins = require "./mixins"
inputs = require "./inputs"

###*
 * Wraps any element with an onClick callback to submit the enclosing form.
###
Submit = React.createClass
  displayName: "ReactFormSubmit"

  mixins: [mixins.FormElementMixin]

  render: -> @props.children onClick: @context.submit

###*
 * A proxy element for a form field.
###
Field = React.createClass
  displayName: "ReactFormField"

  mixins: [mixins.FormElementMixin]

  render: ->
    fieldSchema = @context.schema[@props.name]
    component = fieldSchema.component or "string"
    if _.isString component then component = inputs.getInputForType component

    return @transferPropsTo component
      onChange: (value) -> @context.schema.onFieldChange @props.name, value
      valid: @context.validFields[@props.name]
      pending: @context.pendingFields[@props.name]
      showTicks: @context.ticks

###*
 * Shows an error message on validation error or failure.
###
Message = React.createClass
  displayName: "ReactFormMessage"

  mixins: [mixins.FormElementMixin]

  render: ->
    if @context.message
      return div className: "error-message", @context.message

module.exports = {
  Submit
  Field
  Message
}
