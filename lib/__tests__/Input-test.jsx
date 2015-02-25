jest.autoMockOff();
jest.dontMock('..');
jest.dontMock('rsvp');

var React = require('react');

var RSVP = require('rsvp');
var forms = require('..');
var testUtils = require('./testUtils');

var TestUtils = React.addons.TestUtils;

describe('Input', function() {

  it('should apply form errorClass', function() {
    var form = TestUtils.renderIntoDocument(
      <forms.Form
        errorClass="customErrorClass"
        validators={{validator: testUtils.validator}}>
        <forms.Field name="field" handleEvents={true} validators={{validator: true}}>
          <input className="field"/>
        </forms.Field>
      </forms.Form>
    );

    var inputEl = TestUtils.findRenderedDOMComponentWithClass(form, 'field');

    expect(inputEl.getDOMNode().className).not.toContain('customErrorClass');

    testUtils.changeValue(inputEl, 'invalid');
    jest.runAllTimers();
    expect(inputEl.getDOMNode().className).toContain('customErrorClass');
  });
});
