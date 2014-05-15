_ = require "underscore"

validateRuleGroup = (group, display, value, cb) ->
  # Validate rules within a rule group asynchronously.
  # Stop on first validation failure or error.
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

Form = React.createClass
  displayName: "Form"

  getInitialState: -> data: {}

  onFieldInput: (field, value) ->
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
    state[field].

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

FormMessage = React.createClass
  displayName: "FormMessage"
  render: ->
    div className: "error-message", @props.message

FormField = React.createClass
  displayName: "FormField"
  render: ->
