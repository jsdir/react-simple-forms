ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require ".."

assertTextInputChangesValue = (input, tag, done) ->
  form = ReactTestUtils.renderIntoDocument forms.Form
    schema: text: input: input
    onSubmit: (data) ->
      data.text.should.eq "value"
      done()
  , -> forms.Field name: "text"

  input = ReactTestUtils.findRenderedDOMComponentWithTag form, tag
  ReactTestUtils.Simulate.change input.getDOMNode(), target: value: "value"
  form.submit()

assertTextInputDefaults = (input, tag) ->
  form = ReactTestUtils.renderIntoDocument forms.Form
    schema: text: input: input
    defaults: text: "default"
  , -> forms.Field name: "text"

  input = ReactTestUtils.findRenderedDOMComponentWithTag form, tag
  input.getDOMNode().value.should.eq "default"

describe "TextInput", ->

  it "should change value correctly", (done) ->
    assertTextInputChangesValue forms.inputs.TextInput, "input", done

  it "should be set to a default value", ->
    assertTextInputDefaults forms.inputs.TextInput, "input"

describe "PasswordInput", ->

  it "should change value correctly", (done) ->
    assertTextInputChangesValue forms.inputs.PasswordInput, "input", done

  it "should be set to a default value", ->
    assertTextInputDefaults forms.inputs.PasswordInput, "input"

describe "TextareaInput", ->

  it "should change value correctly", (done) ->
    assertTextInputChangesValue forms.inputs.TextareaInput, "textarea", done

  it "should be set to a default value", ->
    assertTextInputDefaults forms.inputs.TextareaInput, "textarea"

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
