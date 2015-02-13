jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');
var forms = require('..');

var TestUtils = React.addons.TestUtils;

describe('Form', function() {

  describe('validation', function() {

    pit('should work', function() {
      var deferred = RSVP.defer();

      function onErrors(errors) {
        expect(errors).toEqual({
          required_field: 'Value is required',
          three_field: 'Should be three',
          two_field: 'Should be two'
        });
        deferred.resolve();
      }

      var validators = {
        required: function(value) {
          if (!value) {
            return 'Value is required';
          }
        },
        two: function(value) {
          if (parseInt(value) !== 2) {
            return 'Should be two';
          }
        },
        three: function(value) {
          return new RSVP.Promise(function(resolve, reject) {
            if (parseInt(value) !== 3) {
              return resolve('Should be three');
            }
            resolve();
          });
        }
      }

      var form = TestUtils.renderIntoDocument(
        <forms.Form validators={validators} onErrors={onErrors}>
          <forms.Field
            name="required_field"
            handleEvents={true}
            validators={{required: true}}>
            <input className="required_field"/>
          </forms.Field>
          <forms.Field
            name="two_field"
            handleEvents={true}
            validators={{two: true}}>
            <input className="two_field"/>
          </forms.Field>
          <forms.Field
            name="three_field"
            handleEvents={true}
            validators={{three: true}}>
            <input className="three_field"/>
          </forms.Field>
          <forms.Submit><button/></forms.Submit>
        </forms.Form>
      );

      var twoEl = TestUtils.findRenderedDOMComponentWithClass(form, 'two_field');
      var threeEl = TestUtils.findRenderedDOMComponentWithClass(form, 'three_field');
      var buttonEl = TestUtils.findRenderedDOMComponentWithTag(form, 'button');

      TestUtils.Simulate.change(twoEl, {target: {value: '3'}});
      TestUtils.Simulate.change(threeEl, {target: {value: '4'}});
      TestUtils.Simulate.click(buttonEl);

      return deferred.promise;
    });

    it('should fail when trying to use an undefined validator', function() {
      expect(function() {
        var form = TestUtils.renderIntoDocument(
          <forms.Form>
            <forms.Field
              name="field"
              handleEvents={true}
              validators={{foo: true}}>
              <input className="field"/>
            </forms.Field>
          </forms.Form>
        );

        var inputEl = TestUtils.findRenderedDOMComponentWithClass(form, 'field');
        TestUtils.Simulate.change(inputEl, {target: {value: 'text'}});
      }).toThrow('Invariant Violation: Validator(s) `foo` were not defined ' +
        'in the form');
    });
  })
});
