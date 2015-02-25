exports.createForm = function(options) {
  var field1 = <Field></Field>;
  var field2 = <Field></Field>;

  var mixin = {
    submitting: false,
    submitError: null
  };

  options.onSubmit = function() {
    mixin.submitting = true;
  };

  var form = TestUtils.renderIntoDocument(
    <Form options={options}>
      <forms.Submit><button/></forms.Submit>
    </Form>
  );

  var buttonEl = TestUtils.findRenderedDOMComponentWithTag(form, 'button');

  return {
    node: form,
    submit: function() {
      TestUtils.Simulate.click(buttonEl);
    },
    mixin: mixin
  };
};

exports.changeValue = function(node, value) {
  TestUtils.Simulate.change(node, {target: {value: value}});
};
