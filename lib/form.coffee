_ = require "lodash"
React = require "react"
update = require "react/lib/update"
cx = require "react/lib/cx"
valids = require "valids"

inputs = require "./inputs"

{div} = React.DOM

Form = React.createClass
  displayName: "Form"

  propTypes:
    defaults: React.PropTypes.object
    messages: React.PropTypes.object
    onSubmit: React.PropTypes.func
    onResult: React.PropTypes.func
    schema: React.PropTypes.object.isRequired

  childContextTypes:
    defaults: React.PropTypes.object
    onChange: React.PropTypes.func
    statuses: React.PropTypes.object
    message: React.PropTypes.string

  getDefaultProps: ->
    defaults: {}

  getInitialState: ->
    data: @props.defaults or {}
    statuses: {}
    message: null
    # messages: {}

  getChildContext: ->
    console.log @props
    defaults: @props.defaults
    onChange: @onFieldChange
    statuses: @state.statuses
    message: @state.message

  onFieldChange: (field, value) ->
    # Change the value in data.
    data = {}
    data[field] = value
    @setState message: null, data: update @state.data, {$set: data}

  submit: ->
    # Call `onSubmit` callback.
    @props.onSubmit? @state.data

    # Validate data.
    valids.validate @state.data, (messages) =>
      @onResult? messages, @state.data

  render: -> div null, @props.children()

Field = React.createClass
  displayName: "Field"

  propTypes:
    name: React.PropTypes.string.isRequired

  contextTypes:
    defaults: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired
    statuses: React.PropTypes.object.isRequired

  getInitialState: ->
    options = @context.schema[@props.name]
    unless _.isObject options
      throw new Error "A field with name \"#{@props.name}\" does not exist " +
        "in the schema."

    return {
      initialValue: @context.defaults[@props.name]
      input: options.input or inputs.TextInput
      options
    }

  onChange: (value) ->
    @context.onChange @props.name, value

  render: -> @state.input
    options: @state.options
    initialValue: @state.value
    onChange: @onChange
    status: @context.statuses[@props.name] or "default"

Message = React.createClass
  displayName: "Message"

  contextTypes:
    message: React.PropTypes.string

  render: ->
    className = cx "error-message": @context.message?
    React.DOM.div {className}, @context.message

Submit = React.createClass
  displayName: "Submit"

  propTypes:
    children: React.PropTypes.renderable.isRequired

  contextTypes:
    submit: React.PropTypes.func.isRequired

  render: ->
    cloneWithProps @props.children, onClick: => @context.submit()

module.exports = {Form, Field, Message, Submit}
