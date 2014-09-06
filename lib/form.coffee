_ = require "lodash"
React = require "react"
update = require "react/lib/update"
cloneWithProps = require "react/lib/cloneWithProps"
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
    showIndicators: React.PropTypes.bool

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
    showIndicators: React.PropTypes.bool

  getDefaultProps: ->
    defaults: {}

  getInitialState: ->
    data: @props.defaults or {}
    statuses: {}
    message: null
    focused: null
    fieldOrder: []
    submitting: false

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
    showIndicators: @props.showIndicators

  componentDidMount: ->
    @setState focused: _.first @state.fieldOrder

  onFieldChange: (field, value) ->
    # Change the value in data.
    data = {}
    data[field] = {$set: value}

    # Hide error formatting and indicators.
    @setValid field, valid: null

    # Validate if field is interactive
    if @isInteractive field
      @validateField field, value, true

    @setState
      message: null
      data: update @state.data, data

    @props.onInput?()

  validate: (data, schema, onResult) ->
    valids.validate data,
      schema: schema
      messages: @props.messages
    , onResult

  showMessages: (messages) ->
    @setState message: _.values(messages)[0]

  validateField: (field, value, interactive) ->
    data = {}
    data[field] = value

    # Only validate the single field.
    schema = _.pick @props.schema, [field]

    @validate data, schema, (messages) =>
      if messages
        @setValid field, {valid: false, interactive}
        unless interactive
          # Show the validation message.
          @showMessages messages
      else
        @setValid field, valid: true

  isInteractive: (field) ->
    @props.schema[field].interactive

  setValid: (field, valid) ->
    statuses = {}
    statuses[field] = {$set: valid}
    @setState statuses: update @state.statuses, statuses

  onFieldFocus: (field) ->
    if @state.focused
      # Handle the field that is being blurred.
      # Validate if not interactive and not empty.
      value = @state.data[@state.focused]
      if value?
        @validateField @state.focused, value, false

    @setState focused: field

  onEnterDown: ->
    index = _.indexOf @state.fieldOrder, @state.focused
    if index + 1 < @state.fieldOrder.length
      field = @state.fieldOrder[index + 1]
      @onFieldFocus field
      @setState focused: field
    else
      @submit()

  submit: ->
    unless @state.submitting
      @setState submitting: true

      # Call `onSubmit` callback.
      @props.onSubmit? @state.data

      # Validate data.
      @validate @state.data, @props.schema, (messages) =>
        @setState submitting: false
        if messages
          @showMessages messages
          @setState
            statuses: _.object _.map messages, (message, field) ->
              [field, valid: false]
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
    showIndicators: React.PropTypes.bool

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

  render: -> @transferPropsTo @state.input
    options: @state.options
    value: @state.value
    onChange: @onChange
    onKeyDown: @onKeyDown
    onFocus: @onFocus
    valid: @context.statuses[@props.name]
    focus: @props.name is @context.focused
    showIndicators: @context.showIndicators

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
    cloneWithProps @props.children, onClick: =>
      @props.children.props.onClick?()
      @context.submit()

module.exports = {Form, Field, Message, Submit}
