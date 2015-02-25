jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');

var forms = require('..');
var testUtils = require('./testUtils');

var TestUtils = React.addons.TestUtils;

describe('Mixin', function(){

  var MixinInput = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      return this.makeField(<input className="input"/>, {handleEvents: true});
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
      onSuccess: function(data, cb) {
        cb(deferred.promise);
      }
    });

    form.submit();
    expect(form.submitting).toBe(true);
    deferred.resolve();
    expect(form.submitting).toBe(false);
  });

  it('should recieve submit errors', function() {
    var deferred = RSVP.defer();
    var state = {};
    state.promise = deferred.promise;
    var form = testUtils.createForm({
      onSuccess: function(data, cb) {
        cb(state.promise);
      }
    });

    form.submit();
    expect(form.submitting).toBe(true);
    deferred.reject('failure');
    expect(form.submitting).toBe(false);
    expect(form.mixin.submitError).toBe('failure');

    // Test that `submitError` is cleared.
    state.promise = RSVP.resolve();
    form.submit();
    expect(form.mixin.submitError).toBe(null);
  });

  it('should recieve validation state', function() {
    var form = testUtils.createForm();
    var input1 = form.inputs.input1;
    expect(input1.state).toBe('pristine');
    testUtils.changeValue(input1.node, 'abc');
    expect(input1.state).toBe('valid');
    testUtils.changeValue(input1.node, 'wait');
    expect(input1.state).toBe('loading');
    form.validateLoad();
    expect(input1.state).toBe('error');
  });

  describe('on submit', function() {

    it('should set `firstInvalid`', function() {
      var form = createform();
      testUtils.changeValue(form.inputs.input1, 'invalid');
      testUtils.changeValue(form.inputs.input2, 'invalid');

      form.submit();

      expect(form.inputs.input1.firstInvalid).toBe(true);
      expect(form.inputs.input2.firstInvalid).toBe(false);

      // Test that `firstInvalid` is `false` once the feield becomes valid.
      testUtils.changeValue(form.inputs.input1, 'valid');

      expect(form.inputs.input1.firstInvalid).toBe(false);
      expect(form.inputs.input2.firstInvalid).toBe(false);
    });

    it('should set `indicateValidity` to `true`', function() {
      var form = createform();
      expect(form.inputs.input1.indicateValidity).toBe(false);
      expect(form.inputs.input2.indicateValidity).toBe(false);

      form.submit();

      expect(form.inputs.input1.indicateValidity).toBe(true);
      expect(form.inputs.input2.indicateValidity).toBe(true);
    });
  });

  describe('on blur', function() {

    it('should have indicateValidity set unless pristine', function() {
      var form = testUtils.createForm();
      TestUtils.Simulate.focus(form.inputs.input2.node);
      expect(form.inputs.input1.indicateValidity).toBe(false);

      TestUtils.Simulate.focus(form.inputs.input1.node);
      testUtils.changeValue(form.inputs.input1.node, 'foo');

      TestUtils.Simulate.focus(form.inputs.input2.node);
      expect(form.inputs.input1.indicateValidity).toBe(true);
    });
  });
});
