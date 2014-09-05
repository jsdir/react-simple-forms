React = require "react"
ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require "../index"

{div} = React.DOM
###
createForm = () ->
  forms.Form
    schema:
      text:
        input: forms.inputs.TextInput
    onSubmit: ->
###

describe "Form", ->

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
          expect(messages).to.be.null
          data.should.deep.eq {text: "abcd"}
          done()
      , ->
        forms.Field name: "text"

      c = ReactTestUtils.renderIntoDocument form
      c.submit()

  it "should use the enter key as tab if not focused on the last input", ->
    onSubmit = sinon.spy()

    form = forms.Form
      schema:
        text_1: {}
        text_2: {}
      onSubmit: ->
    , -> div null,
      div ref: "text_1", forms.Field name: "text_1"
      div ref: "text_2", forms.Field name: "text_2"

    c = ReactTestUtils.renderIntoDocument form

    div1 = c.refs.text_1
    div2 = c.refs.text_2

    input1 = ReactTestUtils.findRenderedDOMComponentWithTag div1, "input"
    input2 = ReactTestUtils.findRenderedDOMComponentWithTag div2, "input"

    ReactTestUtils.Simulate.keyDown input1.getDOMNode(), key: "Enter", keyCode: 13

    input1.props.focus.should.be.false
    input2.props.focus.should.be.true
    onSubmit.should.not.have.been.called

  it "should use the enter key to submit if focused on the last input", ->
    onSubmit = sinon.spy()

    form = forms.Form
      schema:
        text_1: {}
        text_2: {}
      onSubmit: onSubmit
    , -> div null,
      div ref: "text_1", forms.Field name: "text_1"
      div ref: "text_2", forms.Field name: "text_2"

    c = ReactTestUtils.renderIntoDocument form

    div1 = c.refs.text_1
    div2 = c.refs.text_2

    input1 = ReactTestUtils.findRenderedDOMComponentWithTag div1, "input"
    input2 = ReactTestUtils.findRenderedDOMComponentWithTag div2, "input"

    ReactTestUtils.Simulate.keyDown input1.getDOMNode(), key: "Enter", keyCode: 13
    ReactTestUtils.Simulate.keyDown input2.getDOMNode(), key: "Enter", keyCode: 13

    input1.props.focus.should.be.false
    input2.props.focus.should.be.true
    onSubmit.should.have.been.called

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

  xit "should fill fields with default values if specified", (done) ->
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
