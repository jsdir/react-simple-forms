React = require "react"

FormContextMixin =
  childContextTypes:
    schema: React.PropTypes.object
    message: React.PropTypes.string

  getChildContext: ->
    schema: @props.schema
    message: @state.message

FormElementMixin =
  contextTypes:
    schema: React.PropTypes.object
    message: React.PropTypes.string
    onSubmit: React.PropTypes.func

module.exports = {
  FormContextMixin
  FormElementMixin
}
