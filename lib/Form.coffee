_ = require "underscore"
React = require "react"
update = require "react/lib/update"
valids = require "valids"

elements = require "./elements"

Form = React.createClass
  displayName: "Form"

  # TODO: Only validate initially when a default value is present.
  propTypes:
    children: React.PropTypes.func.isRequired
    defaults: React.PropTypes.object
    messages: React.PropTypes.object
    onSubmit: React.PropTypes.func
    schema: React.PropTypes.object.isRequired
    showIndicators: React.PropTypes.bool

  childContextTypes:
    defaults: React.PropTypes.object
    onFocus: React.PropTypes.func
    fieldStates: React.PropTypes.object
    onChange: React.PropTypes.func
    schema: React.PropTypes.object
    blurValidate: React.PropTypes.func
    submit: React.PropTypes.func
    message: React.PropTypes.string
    enterDown: React.PropTypes.func
    focused: React.PropTypes.string

  getChildContext: ->
    defaults: @props.defaults
    onFocus: @onFocus
    fieldStates: @state.fieldStates
    onChange: @onFieldChange
    schema: @props.schema
    blurValidate: @blurValidate
    submit: @submit
    message: @state.message
    enterDown: @enterDown
    focused: @state.focused

  getInitialState: ->
    data: @props.defaults or {}
    cachedFields: {}
    fieldStates: {}
    message: null
    focused: _.first _.keys @props.schema

  enterDown: (field) ->
    fields = _.keys @props.schema
    index = _.indexOf fields, field
    if index + 1 < fields.length
      @setState focused: fields[index + 1]
    else
      @submit()

  onFocus: (field) ->
    hash = {}
    hash[field] = "$set": "default"
    fieldStates = update @state.fieldStates, hash
    @setState {message: null, focused: field, fieldStates}

  onFieldChange: (field, value) ->
    # Change the value in data.
    @state.data[field] = value
    @setState {message: null, data: @state.data}

    # Only validate on change if interactive.
    if @props.schema[field].interactive
      @validateField field, value, true

  blurValidate: (field) ->
    # Only validate on blur if the field has a value.
    unless @props.schema[field].interactive
      @validateField field, @state.data[field], false

  validateField: (field, value, interactive) ->
    @setState cachedFields: _.omit @state.cachedFields, field

    if value
      data = {}
      data[field] = value
      @validate data, interactive

  validate: (data, interactive, cb) ->
    formData = schema: @props.schema, messages: @props.messages
    valids.validate data, formData, (messages) =>
      firstMessage = true
      state =
        cachedFields: {}
        fieldStates: {}

      messageFields = _.keys messages
      for field, value of data
        if field in messageFields
          message = messages[field]
          # Field is invalid.
          state.cachedFields[field] = "$set": message
          if not interactive and firstMessage
            state.message = "$set": message
            firstMessage = false
          fieldState = if interactive then "invalidInteractive" else "invalid"
          state.fieldStates[field] = "$set": fieldState
        else
          # Field is valid.
          state.cachedFields[field] = "$set": null
          if @props.schema[field].interactive or @props.showIndicators
            state.fieldStates[field] = "$set": "valid"
          else
            state.fieldStates[field] = "$set": "default"

      @setState update @state, state
      cb? messages

  #   fieldStates: {name: [values]}
  #   values:
  #     "default" - plain
  #     "valid" - shows check
  #     "invalidInteractive" - shows x always
  #     "invalid" - shows highlight

  submit: ->
    schemaKeys = _.keys @props.schema
    cachedKeys = _.keys @state.cachedFields
    args = [schemaKeys].concat cachedKeys
    unvalidatedFields = _.without.apply null, args

    # Only validate if there are fields to validate.
    if unvalidatedFields.length
      # Have values default to null.
      defaults = _.object _.map unvalidatedFields, (field) -> [field, null]
      data = _.extend defaults, _.pick @state.data, unvalidatedFields

      @validate data, false, (messages) =>
        unless messages
          @props.onSubmit @state.data
    else
      # Fields have already been checked.
      firstMessage = true
      state =
        fieldStates: {}

      for field, value of @state.cachedFields
        if value
          if firstMessage
            state.message = "$set": value
            firstMessage = false
          fieldState = "invalid"
          state.fieldStates[field] = "$set": fieldState
        else
          if @props.showIndicators
            state.fieldStates[field] = "$set": "valid"
          else
            state.fieldStates[field] = "$set": "default"

      if firstMessage
        @props.onSubmit @state.data
      @setState update @state, state
      cb? messages

  render: ->
    console.log "FORMRENDER"
    @transferPropsTo @props.children()

module.exports = Form
