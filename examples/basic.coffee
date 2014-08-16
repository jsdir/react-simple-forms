form.AsyncForm
  onSubmit: (data, cb) ->
    request.post data, (err) ->
      if err
        cb "Failed to save the item."
      else
        cb()
  schema: itemSchema
  messages: config.messages
  defaults:
    first_name: "Placeholder"
    last_name: "Placeholder"
  children: -> div null,
    form.Message className: "error-message"
    fieldset null,
      form.Field name: "first_name"
      form.Field name: "last_name"
    fieldset null,
      form.Field name: "birthday"
    form.Submit null,
      button null, "Create"

# Elements add themselves to the context when mounted.

FormMixin =
  createSubmitButton: (args...) ->
    form.Submit null, button args...

AsyncForm = React.createClass
  displayName: "AsyncForm"

  propTypes:
    children: React.PropTypes.func.isRequired

  setButtonActivity: (active) ->
    @setState
    _.each @buttons, (cb) ->
      cb active

  setMessage: (message) ->
    _.each @messages, (cb) ->
      cb message

  onSubmit: ->
    @setButtonActivity true
    @props.onSubmit @state.data, (err) =>
      if err
        # setMessage err
      else
        @setButtonActivity false

  render: ->
    @transferPropsTo @props.children()
