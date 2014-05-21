Form = require "./lib/Form"
elements = require "./lib/elements"
mixins = require "./lib/mixins"
inputs = require "./lib/inputs"

module.exports = {
  Form
  inputs
  Field: elements.Field
  Submit: elements.Submit
  Message: elements.Message
  FormElementMixin: mixins.FormElementMixin
}
