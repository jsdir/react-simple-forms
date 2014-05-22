_ = require "lodash"
valids = require "valids"
React = require "react"

getInput = require "./inputs"

###*
 * Validates rules within a rule group asynchronously. This will stop
 * validating on first validation failure or error.
###
validateRuleGroup = (group, display, value, cb) ->
  async.each _.keys(group), (ruleName, cb) ->
    param = group[ruleName]
    if _.isFunction param
      # cb(err, message)
      param value, (err, message) ->
        # Treat validation errors and normal failures as errors since they
        # need to stop the asynchronous iteration immediately. We use a hash to
        # maintain distinction for other functions.
        cb {err, message}
    else
      # Validators from the valids library don't throw validation errors.
      # Only failures are passed. Since failures also need to stop the
      # asynchronous iteration, the message will be passed as an error.
      message = valids[name] display, value, param, @options.messages[name]
      if message then cb {message} else cb()
  , cb

###*
 * Validates a field and stops validating on first validation failure or error.
###
validateField = (field, schema, value, cb) ->
  # Get a user-friendly display name for the field.
  displayName = schema.displayName or field

  # Get an array of rules grouped by priority with first and last in the
  # array corresponding to first and last in validation order.
  if _.isArray schemaField.rules
    rules = schemaField.rules
  else if schemaField.rules
    rules = [schemaField.rules]
  else
    rules = []

  # Validate individual rule groups synchronously.
  async.eachSeries rules, (group, cb) =>
    validateRuleGroup group, display, value, cb
  , cb

###*
 * Validates all values in data against the fields given in the schema.
###
validateAll = (schema, data, cb) ->
  valid = true
  messages = {}

  # Validate fields asynchronously. Do not stop on any validation failures.
  fieldNames = _.keys schema
  async.each fieldNames, (fieldName, cb) ->
    fieldSchema = schema[fieldName]
    validateField fieldName, fieldSchema, data[fieldName], (err) ->
      errorMessage = err.message or err.err
      if errorMessage
        valid = false
        messages[fieldName] = errorMessage
      cb()
  , ->
    if valid
      cb null, data
    else
      messageField = _.first _.intersection fieldNames, _.keys messages
      cb messages, data, messages[messageField]

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

FormField = React.createClass
  displayName: "FormField"

  mixins: [FormElementMixin]

  render: ->
    fieldSchema = @context.schema[@props.name]
    component = fieldSchema.component or "string"
    if _.isString component then component = getInput component

    return @transferPropsTo component
      onChange: (value) -> @context.schema.onFieldChange @props.name, value
      valid: @context.validFields[@props.name]
      pending: @context.pendingFields[@props.name]
      showTicks: @context.ticks

FormMessage = React.createClass
  displayName: "FormMessage"

  mixins: [FormElementMixin]

  render: ->
    if @context.message
      div className: "error-message", @context.message

Form = React.createClass
  displayName: "Form"

  mixins: [FormContextMixin]

  getInitialState: -> data: {}

  onFieldChange: (field, value) ->
    # First, set the field's state value.
    state = data: {}
    state.data[field] = value

    schema = @props.schema[field]
    if schema.continuousValidation

      # Second, set the field state as pending.
      state = {}
      state[field].pending = true
      @setState state

      # Third, perform validation. The validation methods may be either
      # synchronous or asynchronous.
      state = {}
      validateField field, schema, value, (err, message) =>
        state[field].pending = false
        errorMessage = err or message
        if errorMessage
          # Internal error or validation error happened.
          state[field].valid = false
          state.error = errorMessage
        else
          # No error happened.
          state[field].valid = true

    @setState state

  onFieldFocus: (field) ->
    # Focusing on a field removes all associated error indicators.
    state = {}
    state[field]

  onFieldBlur: (field) ->

  submit: ->
    # Validate the entire form before running the success callback.
    validateAll @props.schema, @state.data, (messages, data, firstMessage) ->
      if firstMessage
        # Internal error or validation error happened.
        @setState error: firstMessage
      else
        # No error happened.
        @props.onSubmit data

  render: -> @props.children
    # React.Children.map @props.children (child) ->
    # pass @props.showChecks

FormSubmit = React.createComponent
  displayName: "FormSubmit"

  mixins: [FormElementMixin]

  render: -> @props.children onClick: @context.submit

models.exports = {
  Form
  FormError
  FormField
  FormSubmit
}
