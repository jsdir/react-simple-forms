React = require "react"
ReactTestUtils = require "react/lib/ReactTestUtils"

forms = require ".."

submitForm = (form) ->
  formComponent = ReactTestUtils.renderIntoDocument form
  formComponent.submit()

createMultiInputForm = ->
  onSubmit = sinon.spy()

  form = forms.Form
    schema:
      text_1: {}
      text_2: {}
    onSubmit: onSubmit
  , -> React.DOM.div null,
    React.DOM.div ref: "text_1", forms.Field name: "text_1"
    React.DOM.div ref: "text_2", forms.Field name: "text_2"

  formComponent = ReactTestUtils.renderIntoDocument form

  div1 = formComponent.refs.text_1
  div2 = formComponent.refs.text_2

  input1 = ReactTestUtils.findRenderedDOMComponentWithTag div1, "input"
  input2 = ReactTestUtils.findRenderedDOMComponentWithTag div2, "input"

  return {onSubmit, formComponent, input1, input2}

describe "Form", ->

  describe "`onSubmit` callback", ->

    it "should be called when the form is submitted", (done) ->
      form = forms.Form
        defaults:
          text: "abc"
        schema:
          text: input: forms.inputs.TextInput
        onSubmit: (data) ->
          data.should.deep.eq {text: "abc"}
          done()
      , ->
        forms.Field name: "text"

      submitForm form

  describe "`onResult` callback", ->

    it "should be called with messages on validation failure", (done) ->
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

      submitForm form

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

      submitForm form

  it "should use the enter key as tab if not focused on the last input", ->
    form = createMultiInputForm()

    ReactTestUtils.Simulate.keyDown form.input1.getDOMNode(),
      key: "Enter", keyCode: 13

    form.input1.props.focus.should.be.false
    form.input2.props.focus.should.be.true
    form.onSubmit.should.not.have.been.called

  it "should use the enter key to submit if focused on the last input", ->
    form = createMultiInputForm()

    ReactTestUtils.Simulate.keyDown form.input1.getDOMNode(),
      key: "Enter", keyCode: 13
    ReactTestUtils.Simulate.keyDown form.input2.getDOMNode(),
      key: "Enter", keyCode: 13

    form.input1.props.focus.should.be.false
    form.input2.props.focus.should.be.true
    form.onSubmit.should.have.been.called

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

  it "should have descendant Submit components submit the form on click", ->
    onSubmit = sinon.spy()

    form = forms.Form
      schema: {}
      onSubmit: onSubmit
    , ->
      forms.Submit null, React.DOM.button()

    c = ReactTestUtils.renderIntoDocument form
    button = ReactTestUtils.findRenderedDOMComponentWithTag c, "button"
    ReactTestUtils.Simulate.click button
    onSubmit.should.have.been.called

  xit "should not allow multiple submits at once", (done) ->
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
    # Fill with invalid data then fill with valid data.
    # Check message content

  ###
  xit "should show indicators if requested", ->
    # Show indicators after blur

  xit "should update indicators if the field is interactive", ->
  ###
