React = require "react"
TestUtils = require "react/lib/ReactTestUtils"

forms = require ".."

describe "Forms", ->

  describe "`onSubmit` callback", ->

    it "should be called when the form is submitted", ->
      @

  xdescribe "`onResult` callback", ->

    it "should be called with messages when the form fails to validate", (done) ->

    it "should be called with data when the form validates", (done) ->
      describe ""
      it "", (done) ->
        form = forms.Form
          schema: 1
          onSubmit: ->
            @
          onResult: (messages, data) ->
            @

        instance = ReactTestUtils.renderIntoDocument form
        instance.submit()

  xit "should use the enter key as tab if not focused on the last input", ->

  xit "should use the enter key to submit if focused on the last input", ->

  xit "should display messages in descendant Message components", (done) ->
    form = forms.Form
      schema: name: {}
      onResult: ->
        @refs.message.getDOMNode().text.should.eq "error message"
        done()
    , -> forms.Message ref: "message"

    instance = TestUtils.renderIntoDocument form
    console.log instance.refs.message.getDOMNode()
    instance.submit()

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

  xit "should fill fields with default values if specified", ->
    # show indicators

  xit "should show indicators if requested", ->
    # Show indicators after blur

  xit "should update indicators if the field is interactive", ->
