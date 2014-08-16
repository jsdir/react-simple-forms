React = require "react"
ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require "../index"

###
createForm = () ->
  forms.Form
    schema:
      text:
        input: forms.inputs.TextInput
    onSubmit: ->
###

describe "Forms", ->

  describe "`onSubmit` callback", ->

    it "should be called when the form is submitted", (done) ->
      form = forms.Form
        schema:
          text: input: forms.inputs.TextInput
        onSubmit: (data) ->
          data.should.deep.eq {}
          done()
      , ->
        forms.Field name: "text"

      c = ReactTestUtils.renderIntoDocument form
      c.submit()

  describe "`onResult` callback", ->

    it "should be called with messages when the form fails to validate", (done) ->
      form = forms.Form
        defaults:
          text: "abc"
        schema:
          text:
            input: forms.inputs.TextInput
            rules: min: 4
        onResult: (messages, data) ->
          message = 'attribute "text" must have a minimum of 4 characters'
          messages.should.deep.eq {text: message}
          data.should.deep.eq {text: "abc"}
          done()
      , ->
        forms.Field name: "text"

      c = ReactTestUtils.renderIntoDocument form
      c.submit()

    it "should be called with data when the form validates", (done) ->
      form = forms.Form
        defaults:
          text: "abcd"
        schema:
          text:
            input: forms.inputs.TextInput
            rules: min: 4
        onResult: (messages, data) ->
          message = 'attribute "text" must have a minimum of 4 characters'
          expect(messages).to.be.null
          data.should.deep.eq {text: "abcd"}
          done()
      , ->
        forms.Field name: "text"

      c = ReactTestUtils.renderIntoDocument form
      c.submit()

  xit "should use the enter key as tab if not focused on the last input", ->

  xit "should use the enter key to submit if focused on the last input", ->

  it "should display messages in descendant Message components", (done) ->
    form = forms.Form
      defaults:
        text: "abc"
      schema:
        text:
          input: forms.inputs.TextInput
          rules: min: 4
      onResult: (messages, data) ->
        message = ReactTestUtils.findRenderedComponentWithType c, forms.Message
        message.getDOMNode().textContent.should.eq 'attribute "text" must have a minimum of 4 characters'
        done()
    , -> React.DOM.div null,
      forms.Message()
      forms.Field name: "text"

    c = ReactTestUtils.renderIntoDocument form
    c.submit()

  xit "should have descendant Submit components submit the form on click", ->
    form = forms.Form
      schema: schema
      onResult: done
    , ->
      forms.Submit ref: "submit", React.DOM.button

    TestUtils.renderIntoDocument form
    button = form.refs.submit.getDOMNode()
    TestUtils.Simulate.click button

  xit "should not allow multiple submits times at once", (done) ->
    form.submit()
    form.submit()

  xit "should use custom messages", (done) ->
    form = forms.Form
      schema: 1
      messages: 1
      onResult: (messages) ->
        messages.should.deep.eq field: "message"
        done()

  xit "should hide messages when submitted", ->

  it "should fill fields with default values if specified", (done) ->
    form = forms.Form
      defaults:
        text: "abc"
      schema:
        text: input: forms.inputs.TextInput
      onResult: (messages, data) ->
        field = ReactTestUtils.findRenderedComponentWithType c, forms.Field
        field.getDOMNode().textContent.should.eq "abc"
        done()
    , -> forms.Field name: "text"

    c = ReactTestUtils.renderIntoDocument form
    c.submit()
    # show indicators

  xit "should show indicators if requested", ->
    # Show indicators after blur

  xit "should update indicators if the field is interactive", ->
