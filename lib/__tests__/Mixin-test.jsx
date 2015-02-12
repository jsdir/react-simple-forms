jest.dontMock('..');

var React = require('react/addons');
var RSVP = require('rsvp');
var forms = require('..');

var TestUtils = React.addons.TestUtils;

describe('Mixin', function(){

  pit('should be able to register a field', function() {
    var deferred = RSVP.defer();

    function onSuccess(data) {
      expect(data).toEqual({field: "text"});
      deferred.resolve();
    }

    var MixinInput = React.createClass({
      mixins: [forms.Mixin],
      render: function() {
        return this.makeField(<input></input>, {handleEvents: true});
      }
    });

    var form = TestUtils.renderIntoDocument(
      <forms.Form onSuccess={onSuccess}>
        <MixinInput name="field"></MixinInput>
        <forms.Submit>
          <button/>
        </forms.Submit>
      </forms.Form>
    );

    var inputEl = TestUtils.findRenderedDOMComponentWithTag(form, 'input');
    var buttonEl = TestUtils.findRenderedDOMComponentWithTag(form, 'button');

    TestUtils.Simulate.change(inputEl, {target: {value: "text"}});
    TestUtils.Simulate.click(buttonEl);
    return deferred.promise;
  });
});
