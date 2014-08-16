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
    onInput: React.PropTypes.func
    schema: React.PropTypes.object.isRequired

  childContextTypes:
    defaults: React.PropTypes.object
    schema: React.PropTypes.object
    onChange: React.PropTypes.func
    onFocus: React.PropTypes.func
    statuses: React.PropTypes.object
    message: React.PropTypes.string
    onEnterDown: React.PropTypes.func
    submit: React.PropTypes.func
    fieldOrder: React.PropTypes.array
    focused: React.PropTypes.string

  getDefaultProps: ->
    defaults: {}

  getInitialState: ->
    data: @props.defaults or {}
    statuses: {}
    message: null
    focused: null
    fieldOrder: []

  getChildContext: ->
    defaults: @props.defaults
    schema: @props.schema
    onChange: @onFieldChange
    onFocus: @onFieldFocus
    statuses: @state.statuses
    message: @state.message
    onEnterDown: @onEnterDown
    submit: @submit
    fieldOrder: @state.fieldOrder
    focused: @state.focused

  componentDidMount: ->
    @setState focused: _.first @state.fieldOrder

  onFieldChange: (field, value) ->
    # Change the value in data.
    data = {}
    data[field] = {$set: value}
    @setState message: null, data: update @state.data, data
    @props.onInput?()

  onFieldFocus: (field) ->
    @setState focused: field

  onEnterDown: () ->
    index = _.indexOf @state.fieldOrder, @state.focused
    if index + 1 < @state.fieldOrder.length
      @setState focused: @state.fieldOrder[index + 1]
    else
      @submit()

  submit: ->
    # Call `onSubmit` callback.
    @props.onSubmit? @state.data

    # Validate data.
    valids.validate @state.data,
      schema: @props.schema
      messages: @props.messages
    , (messages) =>
      if messages then @setState message: _.values(messages)[0]
      @props.onResult? messages, @state.data

  render: -> div null, @props.children()

Field = React.createClass
  displayName: "Field"

  propTypes:
    name: React.PropTypes.string.isRequired

  contextTypes:
    defaults: React.PropTypes.object.isRequired
    schema: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired
    onFocus: React.PropTypes.func.isRequired
    statuses: React.PropTypes.object.isRequired
    onEnterDown: React.PropTypes.func.isRequired
    fieldOrder: React.PropTypes.array.isRequired
    focused: React.PropTypes.string

  componentDidMount: ->
    @context.fieldOrder.push @props.name

  getInitialState: ->
    options = @context.schema[@props.name]
    unless _.isObject options
      throw new Error "A field with name \"#{@props.name}\" does not exist " +
        "in the schema."

    return {
      value: @context.defaults[@props.name]
      input: options.input or inputs.TextInput
      options
    }

  onChange: (value) ->
    @setState value: value
    @context.onChange @props.name, value

  onFocus: ->
    @context.onFocus @props.name

  onKeyDown: (e) ->
    @context.onEnterDown @props.name if e.keyCode is 13

  render: -> @state.input
    options: @state.options
    value: @state.value
    onChange: @onChange
    onKeyDown: @onKeyDown
    onFocus: @onFocus
    status: @context.statuses[@props.name] or "default"
    focus: @props.name is @context.focused

Message = React.createClass
  displayName: "Message"

  contextTypes:
    message: React.PropTypes.string

  render: ->
    className = cx "error-message": @context.message?
    @transferPropsTo div {className}, @context.message

Submit = React.createClass
  displayName: "Submit"

  propTypes:
    children: React.PropTypes.renderable.isRequired

  contextTypes:
    submit: React.PropTypes.func.isRequired

  render: ->
    cloneWithProps @props.children, onClick: => @context.submit()

module.exports = {Form, Field, Message, Submit}
