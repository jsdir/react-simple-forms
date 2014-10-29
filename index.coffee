form = require "./lib/form"
inputs = require "./lib/inputs"

module.exports =
  Form: form.Form
  Field: form.Field
  Message: form.Message
  Submit: form.Submit
  inputs: inputs
  InputMixin: inputs.InputMixin
