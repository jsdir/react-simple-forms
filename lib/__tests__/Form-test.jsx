jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');
var forms = require('..');

var TestUtils = React.addons.TestUtils;

describe('Form', function() {

  describe('validation', function() {

    it('should work', function() {

    });

    iit('should fail when trying to use an undefined validator', function() {
      expect(function() {
        var form = TestUtils.renderIntoDocument(
          <forms.Form>
            <forms.Field name="field" handleEvents={true} validators={{foo: true}}>
              <input className="field"/>
            </forms.Field>
          </forms.Form>
        );

        var inputEl = TestUtils.findRenderedDOMComponentWithClass(form, 'field');
        TestUtils.Simulate.change(inputEl, {target: {value: 'text'}})
      }).toThrow('Invariant Violation: Validator(s) `foo` were not defined ' +
        'in the form');
    });
  })
});
