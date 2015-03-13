jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');

var forms = require('..');
var testUtils = require('./testUtils');

var TestUtils = React.addons.TestUtils;

describe('Mixin', function() {

  var MixinInput = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      return this.renderField(<input className="input"/>, {handleEvents: true});
    }
  });

  pit('should be able to register fields', function() {
    var deferred = RSVP.defer();

    function onSuccess(data) {
      expect(data).toEqual({input: 'inputText', field: 'fieldText'});
      deferred.resolve();
    }

    var form = TestUtils.renderIntoDocument(
      <forms.Form onSuccess={onSuccess}>
        <MixinInput name="input"/>
        <forms.Field name="field" handleEvents={true}>
          <input className="field"/>
        </forms.Field>
        <forms.Submit><button/></forms.Submit>
      </forms.Form>
    );

    var inputEl = TestUtils.findRenderedDOMComponentWithClass(form, 'input');
    var fieldEl = TestUtils.findRenderedDOMComponentWithClass(form, 'field');
    var buttonEl = TestUtils.findRenderedDOMComponentWithTag(form, 'button');

    TestUtils.Simulate.change(inputEl, {target: {value: 'inputText'}});
    TestUtils.Simulate.change(fieldEl, {target: {value: 'fieldText'}});
    TestUtils.Simulate.click(buttonEl);

    return deferred.promise;
  });

  it('should require a name prop', function() {
    expect(function() {
      TestUtils.renderIntoDocument(
        <forms.Form>
          <MixinInput/>
        </forms.Form>
      );
    }).toThrow('Invariant Violation: All fields must have a unique `name` ' +
      'prop');
  });

  it('should recieve submit progress', function() {
    var deferred = RSVP.defer();
    var form = testUtils.createForm({
      onSuccess: function(data) {
        expect(data).toEqual({field1: null, field2: null});
        return deferred.promise;
      }
    });

    form.submit();
    expect(form.mixin.submitting).toBe(true);
    deferred.resolve();
    jest.runAllTimers();
    expect(form.mixin.submitting).toBe(false);
  });

  it('should recieve submit errors', function() {
    var deferred = RSVP.defer();
    var state = {};
    state.promise = deferred.promise;
    var form = testUtils.createForm({
      onSuccess: function(data) {
        return state.promise;
      }
    });

    form.submit();
    expect(form.mixin.submitting).toBe(true);
    deferred.reject('failure');
    jest.runAllTimers();
    expect(form.mixin.submitting).toBe(false);
    expect(form.mixin.submitError).toBe('failure');

    // Test that `submitError` is cleared.
    state.promise = RSVP.resolve();
    form.submit();
    jest.runAllTimers();
    expect(form.mixin.submitError).toBe(null);
  });

  it('should recieve validation state', function() {
    var deferred = RSVP.defer();

    function validator(value) {
      if (value === 'invalid') {
        return RSVP.reject('message');
      }
      if (value === 'load') {
        return deferred.promise;
      }
      return RSVP.resolve();
    }

    var form = testUtils.createForm({
      validators: {validator: validator}
    });

    var field1 = form.fields.field1;
    jest.runAllTimers();
    expect(field1.state).toBe('valid');
    expect(field1.isPristine).toBe(true);

    testUtils.changeValue(field1.node, 'valid');
    jest.runAllTimers();
    expect(field1.state).toBe('valid');
    expect(field1.isPristine).toBe(false);

    testUtils.changeValue(field1.node, 'invalid');
    jest.runAllTimers();
    expect(field1.state).toBe('invalid');

    testUtils.changeValue(field1.node, 'load');
    jest.runAllTimers();
    expect(field1.state).toBe('loading');

    deferred.resolve();
    jest.runAllTimers();
    expect(field1.state).toBe('valid');
  });
});
