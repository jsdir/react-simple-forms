React = require "react"
TestUtils = require "react/lib/ReactTestUtils"
chai = require "chai"

forms = require "../index"

expect = chai.expect

TestInput = React.createClass
  displayName: "TestInput"
  render: -> React.DOM.div null, @props.value

describe.only "Field", ->

  createContext = ->
    defaults: {}
    schema:
      field:
        input: TestInput

  it "should require its name to be registered in the schema", (done) ->
    context = createContext()
    context.schema = {}
    React.withContext context, ->
      expect(->
        field = forms.Field value: "default", name: "field"
        instance = TestUtils.renderIntoDocument field
      ).to.throw "A field with name \"field\" does not exist in the schema."
      done()

  it "should show the default value from inherited context", (done) ->
    context = createContext()
    context.defaults.field = "contextDefault"
    React.withContext context, ->
      field = forms.Field name: "field"
      instance = TestUtils.renderIntoDocument field
      instance.getDOMNode().textContent.should.equal "contextDefault"
      done()

  it "should work if there is no default value in context", (done) ->
    context = createContext()
    React.withContext context, ->
      field = forms.Field name: "field"
      instance = TestUtils.renderIntoDocument field
      instance.getDOMNode().textContent.should.equal ""
      done()

  it "should run #context.onChange() when the input changes", (done) ->
    context = createContext()
    context.onChange = -> done()
    context.schema.field.input = forms.inputs.TextInput
    React.withContext context, ->
      field = forms.Field value: "default", name: "field"
      instance = TestUtils.renderIntoDocument field
      TestUtils.Simulate.change instance.getDOMNode()

  xit "should initially validate defaults inherited from context"
    # Assert validate is called.

  xit "should not initially validate if no default is present"
    # Assert validate is not called.

  xit "should validate on input if the field is interactive"
    # Assert validate is called.
    # check that callbacks are sent, namely through context
    # setValidationResult fieldName, message or null
    # should show indicator. should not show error formatting
    # this is the only instance in which the failing indicator will be shown

  xit "should hide error formatting and indicators on focus or input"

  xit "should validate non-interactive fields on blur"
    # (if the field was interactive, an indicator would already be showing
    # and the validation would have already taken place)
    # Make the the field is validating no matter what.
    # TODO: if form.showTicks, check that a tick is shown on successful
    # validation and no indicator but error formatting is shown on failed
    # validation

  xit "should not validate empty fields on blur"
    # Validation results at the field levels are stored at the form level to
    # make final validation more efficient.

# Is getChildContext called on every render? If so, see if it can pull from
# state. Pull initialValidationState ({...}) into context, and render the
# fields to get their initial state (state.invalid, default:false) from
# context.
