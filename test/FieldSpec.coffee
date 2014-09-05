ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require ".."

describe "Field", ->

  # Options

  xit "should require its name to be registered in the schema", (done) ->
    expect(->
      field = forms.Field value: "default", name: "field"
      instance = ReactTestUtils.renderIntoDocument field
    ).to.throw "A field with name \"field\" does not exist in the schema."
    done()

  # Validation

  xit "should validate on input if the field is interactive", (done) ->
    # initial should be blank
    # Test with presence success or fail indicators, both should not show error decorator

    # if no indicators only show error decoration or not

    # test async validators

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

  xit "should hide error formatting and indicators on input", (done) ->
    # for all fields interactive/noninteractive

  xit "should show error formatting and message on any field blur", ->

