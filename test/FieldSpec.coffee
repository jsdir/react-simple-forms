React = require "react"
TestUtils = require "react/lib/ReactTestUtils"

validate = require "../lib/validate"
validateField = sinon.stub validate, "validateField"
forms = require "../index"

TestInput = React.createClass
  displayName: "TestInput"
  render: -> React.DOM.div null, @props.value

describe "Field", ->

  createContext = ->
    defaults: {}
    schema:
      field:
        input: TestInput

  afterEach ->
    validateField.reset()

  after ->
    validateField.restore()

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

    context.onChange = (field, value) ->
      field.should.equal "field"
      value.should.equal "changedInput"
      done()

    context.schema.field.input = forms.inputs.TextInput
    React.withContext context, ->
      field = forms.Field name: "field"
      instance = TestUtils.renderIntoDocument field
      e = target: value: "changedInput"
      input = TestUtils.findRenderedDOMComponentWithTag instance, "input"
      TestUtils.Simulate.change input, e

  it "should initially validate defaults inherited from context", (done) ->
    context = createContext()
    context.defaults.field = "contextDefault"
    React.withContext context, =>
      field = forms.Field name: "field"
      TestUtils.renderIntoDocument field
      validateField.should.have.been.calledOnce
      done()

  it "should not initially validate if default is absent", (done) ->
    context = createContext()
    React.withContext context, =>
      field = forms.Field name: "field"
      TestUtils.renderIntoDocument field
      validateField.should.not.have.been.called
      done()

  xit "should validate on input if the field is interactive", (done) ->
    context = createContext()
    context.schema.field.interactive = true
    context.schema.field.input = forms.inputs.TextInput

    context.setValidationResult = (field, message) ->
      field.should.equal "field"
      #done()

    React.withContext context, =>
      field = forms.Field name: "field"
      instance = TestUtils.renderIntoDocument field

      e = target: value: "changedInput"
      TestUtils.Simulate.change instance.getDOMNode(), e
      validateField.should.have.been.calledOnce
      # validateField.reset()
      done()
    # Assert validate is called.
    # check that callbacks are sent, namely through context
    # setValidationResult fieldName, message or null
    # should show indicator. should not show error formatting
    # this is the only instance in which the failing indicator will be shown

  xit "should hide error formatting and indicators on input", (done) ->


  xit "should validate non-interactive fields on blur", (done) ->
    # (if the field was interactive, an indicator would already be showing
    # and the validation would have already taken place)
    # Make the the field is validating no matter what.
    # TODO: if form.showTicks, check that a tick is shown on successful
    # validation and no indicator but error formatting is shown on failed
    # validation

  xit "should not validate empty fields on blur", (done) ->
    # Validation results at the field levels are stored at the form level to
    # make final validation more efficient.

# Is getChildContext called on every render? If so, see if it can pull from
# state. Pull initialValidationState ({...}) into context, and render the
# fields to get their initial state (state.invalid, default:false) from
# context.
