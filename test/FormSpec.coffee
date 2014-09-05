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

  # Callbacks

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

    it "should be called with data on validation success", (done) ->
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

  describe "enter key", ->

    it "should function as tab if not focused on the last input", ->
      form = createMultiInputForm()

      ReactTestUtils.Simulate.keyDown form.input1.getDOMNode(),
        key: "Enter", keyCode: 13

      form.input1.props.focus.should.be.false
      form.input2.props.focus.should.be.true
      form.onSubmit.should.not.have.been.called

    it "should function as submit if focused on the last input", ->
      form = createMultiInputForm()

      ReactTestUtils.Simulate.keyDown form.input1.getDOMNode(),
        key: "Enter", keyCode: 13
      ReactTestUtils.Simulate.keyDown form.input2.getDOMNode(),
        key: "Enter", keyCode: 13

      form.input1.props.focus.should.be.false
      form.input2.props.focus.should.be.true
      form.onSubmit.should.have.been.called

  # Submit

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

  it "should not allow multiple submits at once", ->
    onSubmit = sinon.spy()

    form = ReactTestUtils.renderIntoDocument forms.Form
      schema: text: rules: customValidator: (value, cb) ->
        setTimeout ->
          cb null, "result"
        , 0
      onSubmit: onSubmit
    , -> null

    form.submit()
    form.submit()

    onSubmit.should.have.been.calledOnce

  # Validation Messages

  it "should display default messages", (done) ->
    form = ReactTestUtils.renderIntoDocument forms.Form
      defaults:
        text: "abc"
      schema:
        text:
          input: forms.inputs.TextInput
          rules: min: 4
      onResult: (messages, data) ->
        messageComponent = ReactTestUtils.findRenderedComponentWithType(
          form, forms.Message
        )
        message = 'attribute "text" must have a minimum of 4 characters'
        messages.should.deep.eq text: message
        messageComponent.getDOMNode().textContent.should.eq message
        done()
    , -> React.DOM.div null,
      forms.Message()
      forms.Field name: "text"

    form.submit()

  it "should display custom messages", (done) ->
    form = ReactTestUtils.renderIntoDocument forms.Form
      defaults:
        text: "abc"
      schema:
        text:
          input: forms.inputs.TextInput
          rules: min: 4
      messages:
        min: -> "custom message"
      onResult: (messages, data) ->
        messageComponent = ReactTestUtils.findRenderedComponentWithType(
          form, forms.Message
        )
        message = "custom message"
        messages.should.deep.eq text: message
        messageComponent.getDOMNode().textContent.should.eq message
        done()
    , -> React.DOM.div null,
      forms.Message()
      forms.Field name: "text"

    form.submit()

  xit "should hide messages on submit", ->
    # Fill with invalid data then fill with valid data.
    # Check message content

  xit "should hide messages on field input", ->
