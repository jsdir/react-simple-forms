React = require "react"
ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require "../index"

describe "Forms", ->
  it "should work", ->
    schema =
      email:
        input: forms.inputs.MultilineInput
      password: {}

    form = forms.Form
      schema: schema
      messages: {}
      onSubmit: @submit
      components: -> React.DOM.div null,
        forms.Message message: "hello world"
        forms.Field name: "email"
        React.DOM.div className: "special-field",
          forms.Field name: "password"
          forms.Submit null,
            React.DOM.button null, "Submit"

    instance = ReactTestUtils.renderIntoDocument form

  it "should use the enter key as tab if not focused on the last input"

  it "should use the enter key to submit if focused on the last input"