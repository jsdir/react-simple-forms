jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');
var forms = require('..');

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
});
