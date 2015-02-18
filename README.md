react-simple-forms
==================

Simple form-building for React.

[![Build Status](https://img.shields.io/travis/jsdir/react-simple-forms.svg?style=flat)](https://travis-ci.org/jsdir/react-simple-forms)
[![Dependency Status](https://img.shields.io/david/jsdir/react-simple-forms.svg?style=flat)](https://david-dm.org/jsdir/react-simple-forms)
[![NPM version](https://img.shields.io/npm/v/react-simple-forms.svg?style=flat)](https://www.npmjs.org/package/react-simple-forms)

## Installation

```bash
$ npm install --save react-simple-forms
```

## Usage

More detailed examples can be found in `./examples`.

```js
var React = require('react');
var forms = require('react-simple-forms');

var schema = {
  first_name: {
    rules: {
      required: true,
      min: 4
    }
  },
  last_name: {
    rules: {
      required: true,
      min: 4
    }
  },
  username: {
    rules: {
      required: true,
      alphanumeric: true,
      min: 3
    }
  },
  password: {
    input: forms.inputs.PasswordInput,
    rules: {
      required: true,
      min: 8
    }
  }
};

var form = forms.Form({
  schema: schema,
  onSubmit: function(data) {
    console.log('Form submitted with data: ', data);
  },
  onResult: function(messages, data) {
    if (messages) {
      console.log('Validation failed with messages: ', messages);
    } else {
      console.log('Validation succeeded with data: ', data);
    }
  }
},
  React.DOM.div({id: 'message-section'},
    forms.Message()
  ),
  React.DOM.div({id: 'left-section'},
    forms.Field({name: 'first_name'}),
    forms.Field({name: 'last_name'})
  ),
  React.DOM.div({id: 'right-section'},
    forms.Field({name: 'username'}),
    forms.Field({name: 'password'})
  ),
  React.DOM.div({id: 'submit-section'},
    forms.Submit(null,
      React.DOM.button(null, 'Submit')
    )
  )
);

React.renderComponent(form, document.body);
```

## API Documentation

### `Form`

`Form` is the main component used to construct a form. It is required to contain and provide context for inputs and elements.

Props:

- `validate` (function, required)

  `Form` decouples validation from the form library. `validate` is a function that is called with a data object containing input values. It should call back with the input values if no validation errors occurred and it should call back with a message object if the validation failed. Values can be transformed before they are validated.

  Since most developers would expect a library called `react-simple-forms` to provide some means of automatic validation without having to write a handler, a validation constraint generator is included in the library.

  ```js
  var forms = require('react-simple-forms');

  userSchema.constraints
  userSchema.inputProps

  forms.Form({
    validate: forms.createValidator({
      foo: {}
    }),
    onError: function(messages) {
      console.log(messages);
    },
    onSuccess: function(data) {
      console.log(data);
    }
  })
  forms.createValidator({
    foo: {}
  });
  ```

  TODO: scope option for single value validation
  TODO: figure out when to enable validation for different form inputs.

  `input`

  ```json
  {
    "field": "invalidValue",
    "subset": {
      "field": "invalidValue"
    },
    "list": [
      {
        "field": "invalidValue"
      },
      {
        "field": "validValue"
      },
      {
        "field": "invalidValue"
      }
    ]
  }
  ```

  ```json
  {
    "field": "message",
    "subset": {
      "field": "message"
    },
    "list": {
      0: { // "0" is the index of the subset with the error
        "field": "message"
      },
      2: {
        "field": "message"
      }
    ]
  }
  ```

  detailed output is important to finding what inputs caused error to mark with the error class for example.

- `onError` (function, required)

  Called with an error message object if validation fails.

- `onSuccess` (function, required)

  Called with the returned value from `validate` if validation was successful.

- `defaults` (object, optional) ... Default values for the form
- `inputProps` (object, optional)
- `errorClass` = "Form-error" (string, optional)

  A `className` to apply to inputs then they are invalid.

- tabOnEnter = true (boolean, optional)

  If set to `false`, pressing the enter key will submit the form. If set to `true`, pressing the enter key will focus on the next input until the end, when it will submit.

### `FormMixin`

`FormMixin` is implemented by elements and inputs to gather data about and interact with the parent form. It is possible to create custom inputs by implementing `FormMixin`.

Methods:

- `submit` (function) ... Submits the parent form
- `message` (string | `null`) ... A single message if the form is marked as invalid

Attributes:

- `valid` (boolean)

  Value that is updated with the input's validity in realtime. The can be used to create dynamic validation indicators.

- `fieldMessage` (string | `null`)

  A validation message specific to the field. This can be used to show a Tooltip containing the input error. This solution is implemented in `examples/tooltip.jsx`.

## Inputs

Form data is always changed through form inputs. In order for a component to be recognized as a form input, it must either be wrapped with an `Input` component or it must implement `FormMixin`. They must also be defined with the `name` prop in order for validation to work. If any validation errors occur, `form.errorClass` will be appended to the input's current `className`.

```js
Form
  Input name: "firstName",
    input
  Input name: "lastName",
    input
  CustomInput name: "customValue"
```

### `Input`

`Input` wraps any component that handles data flow with `value` and `onChange`. This can wrap many existing input components created for React as well as most of the builtin DOM elements such as `input` and `textarea`.

```js
var forms = require('react-simple-forms');
<forms.Form>
  <forms.Input><input name="name"/></forms.Input>
  <forms.Input><textarea name="description"/></forms.Input>
</forms.Form>
```

## Form Elements

Form elements are non-input components that use information about the parent form.

### `Message`

  - form.Message (inherit classes)

### `Submit`

`Submit` wraps any element with an `onClick` handler to submit the parent form when clicked.

```js
forms.Submit null,
  button null, "Submit"
```

## Form Structures

Form structures are virtual components that change the structure of the form data.

### `FormSubset`

`FormSubset` can be used to produce nested data.

Props:

- `name`: (string, required) ... The subset name.

```js
Form
  FormSubset name: "term1",
    TextInput name: "start"
    TextInput name: "end"
  FormSubset name: "term2",
    TextInput name: "start"
    TextInput name: "end"
```

On successful validation, `form.onSuccess` will be called with:

```json
{
  "basic": "foo",
  "term1": {
    "start": "12/12/12",
    "end": "12/12/12"
  },
  "term2": {
    "start": "12/12/12",
    "end": "12/12/12"
  }
}
```

`FormSubset` components can be nested to unlimited levels.

### `FormList`

`FormList` can be used to produce nested lists of identical objects.

Props:

- `name` (string, required) ... The list name
- `add` (`Element`, required) ... An element to append to the end of the list that will add another set when clicked
- `remove` (`Element`, required) ... An element to append to the end of a fieldset that will remove that fieldset

Like `FormSubset`, `FormList` can also be nested to unlimited levels.
