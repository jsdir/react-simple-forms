Form = require "./lib/Form"
elements = require "./lib/elements"
inputs = require "./lib/inputs"
mixins = require "./lib/mixins"

module.exports = {
  Form
  inputs
  Field: elements.Field
  Submit: elements.Submit
  Message: elements.Message
  FormElementMixin: mixins.FormElementMixin
}
