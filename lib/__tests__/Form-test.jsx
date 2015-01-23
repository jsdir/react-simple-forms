jest.dontMock('../elements/Message');
jest.dontMock('../elements/Submit');
jest.dontMock('../Form');

import React from 'react/addons';
import {Promise} from 'es6-promise';

import Form from '../Form';
import Submit from '../elements/Submit';

const {TestUtils} = React.addons;

describe('Form', () => {

  // should call onError when validation fails
  //
  // should call onSuccess when validation succeeds
  //  - assert correct data recieved

  pit('should interact with form elements', () => {
    return new Promise((resolve) => {
      const instance = TestUtils.renderIntoDocument(
        <Form validate={resolve}>
          <Submit>
            <button onClick={() => {console.log("HEELELE");}}>Testing</button>
            <Submit>
              <button onClick={() => {console.log("HEELELE");}}>Testing</button>
            </Submit>
          </Submit>
        </Form>
      );
      let b = TestUtils.findRenderedDOMComponentWithTag(instance, 'button');
      TestUtils.Simulate.click(b.getDOMNode())
    });
    // check message and submit
  });
});

/*
Message
  should show first message (check className)

FormMixin
  test wrapField
  test correct form details recieved(messages, message, submit)?
  test inpementing and synamic validation
    mixin should provide:
      this.isValid()
      this.getMessage()

FormList

FormFieldset
  fill out data and submit, data should have structure
  fill out invalid data and submit, messages should have structure.
    fields should get isValid and message correct.

test createValidator
 */