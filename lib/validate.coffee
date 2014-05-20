_ = require "lodash"

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

module.exports = {
  validateField
  validateAll
}
