ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require ".."

assertTextInputChangesValue = (input, done) ->
  form = ReactTestUtils.renderIntoDocument forms.Form
    schema: text: input: input
    onSubmit: (data) ->
      data.text.should.eq "value"
      done()
  , -> forms.Field name: "text"

  input = ReactTestUtils.findRenderedDOMComponentWithTag form, "input"
  ReactTestUtils.Simulate.change input.getDOMNode(), target: value: "value"
  form.submit()

assertTextInputDefaults = (input) ->
  form = ReactTestUtils.renderIntoDocument forms.Form
    schema: text: input: input
    defaults: text: "default"
  , -> forms.Field name: "text"

  input = ReactTestUtils.findRenderedDOMComponentWithTag form, "input"
  input.getDOMNode().value.should.eq "default"

describe "TextInput", ->

  it "should change value correctly", (done) ->
    assertTextInputChangesValue forms.inputs.TextInput, done

  it "should be set to a default value", ->
    assertTextInputDefaults forms.inputs.TextInput

describe "PasswordInput", ->

  it "should change value correctly", (done) ->
    assertTextInputChangesValue forms.inputs.PasswordInput, done

  it "should be set to a default value", ->
    assertTextInputDefaults forms.inputs.PasswordInput

###
describe "DateInput", ->

  it "should change value correctly", ->
    forms.inputs.DateInput

  it "should be set to a default value", ->
    forms.inputs.DateInput

describe "ChoiceInput", ->

  it "should change value correctly", ->
    forms.inputs.ChoiceInput

  it "should be set to a default value", ->
    forms.inputs.ChoiceInput
###
