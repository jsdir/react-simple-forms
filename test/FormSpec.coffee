React = require "react"
ReactTestUtils = require "react/lib/ReactTestUtils"

Forms = require ".."

describe "Forms", ->
  it "should work", ->

    schema =
      "email":
        input: Forms.inputs.MultilineInput
      "password": {}

    form = Forms.Form
      schema: schema
      messages: {}
      onSubmit: @submit
      components: -> React.DOM.div null,
        Forms.Message message: "hello world"
        Forms.Field name: "email"
        React.DOM.div className: "special-field",
          Forms.Field name: "password"
          Forms.Submit null,
            React.DOM.button null, "Submit"

    instance = ReactTestUtils.renderIntoDocument form
    console.log instance.getDOMNode()
