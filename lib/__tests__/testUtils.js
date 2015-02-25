var React = require('react');
var RSVP = require('rsvp');

var forms = require('..');

var TestUtils = React.addons.TestUtils;

exports.createForm = function(options) {

  // States
  var mixin = {
    submitting: false,
    submitError: null,
    submitted: false
  };

  var field1 = {};
  var field2 = {};

  // Components
  var FormInput = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      return this.makeField(<input className={this.props.className}/>, {handleEvents: true});
    }
  });

  var MixinListener = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      var formContext = this.getFormContext();
      mixin.submitting = formContext.submitting;
      mixin.submitError = formContext.submitError;
      return <noscript/>
    }
  });

  var props = {
    onSubmit: function() {
      mixin.submitted = true;
    }
  };

  var form = TestUtils.renderIntoDocument(
    <forms.Form {...props}>
      <FormInput name="field1" className="field1" state={field1}/>
      <FormInput name="field2" className="field2" state={field2}/>
      <MixinListener/>
      <forms.Submit><button/></forms.Submit>
    </forms.Form>
  );

  var buttonEl = TestUtils.findRenderedDOMComponentWithTag(form, 'button');
  field1.node = TestUtils.findRenderedDOMComponentWithClass(form, 'field1');
  field2.node = TestUtils.findRenderedDOMComponentWithClass(form, 'field2');

  return {
    node: form,
    submit: function() {
      TestUtils.Simulate.click(buttonEl);
    },
    mixin: mixin,
    fields: {
      field1: field1,
      field2: field2
    }
  };
};

exports.changeValue = function(node, value) {
  TestUtils.Simulate.change(node, {target: {value: value}});
};

exports.validator = function(value) {
  if (value === 'invalid') {
    return RSVP.resolve('message');
  }
  return RSVP.resolve(null);
};
