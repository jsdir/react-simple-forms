React = require "react"

FormContextMixin =
  childContextTypes:
    schema: React.PropTypes.string
    message: React.PropTypes.string

  getChildContext: ->
    schema: "hai" # @props.schema
    message: "hello" # @state.message

FormElementMixin =
  contextTypes:
    schema: React.PropTypes.string
    message: React.PropTypes.string
    #onSubmit: React.PropTypes.func

module.exports = {
  FormContextMixin
  FormElementMixin
}
