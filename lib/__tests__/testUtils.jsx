var React = require('react');
var RSVP = require('rsvp');

var forms = require('..');

var TestUtils = React.addons.TestUtils;

exports.createForm = function(props) {

  // States
  var mixin = {
    submitting: false,
    submitError: null
  };

  var field1 = {};
  var field2 = {};

  // Components
  var FormInput = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      var fieldState = this.getFieldState();
      this.props.state.state = fieldState.state;
      this.props.state.value = fieldState.value;
      this.props.state.isFirst = fieldState.isFirst;
      this.props.state.isPristine = fieldState.isPristine;

      return this.renderField(
        <input className={this.props.className}/>
      , {handleEvents: true});
    }
  });

  var MixinListener = React.createClass({
    mixins: [forms.Mixin],
    render: function() {
      var formState = this.getFormState();
      mixin.submitting = formState.submitting;
      mixin.submitError = formState.submitError;

      return null;
    }
  });

  props = props || {};
  if (!props.validators) {
    props.validators = {validator: exports.validator};
  }

  var form = TestUtils.renderIntoDocument(
    <forms.Form {...props}>
      <FormInput name="field1" className="field1" state={field1} validators={{validator: true}}/>
      <FormInput name="field2" className="field2" state={field2} validators={{validator: true}}/>
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
