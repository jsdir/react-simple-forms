react-simple-forms
==================

Simple forms for react. Loosely based on react-forms.

[![Build Status](https://travis-ci.org/jsdir/react-simple-forms.png)](https://travis-ci.org/jsdir/react-simple-forms) [![NPM version](https://badge.fury.io/js/react-simple-forms.png)](http://badge.fury.io/js/react-simple-forms)

**This is still under active development.**

Installation
------------

```sh
$ npm install react-simple-forms
```

Usage
-----

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

### Options

#### schema

The `schema` option is passed directly to [valids](https://github.com/jsdir/valids).

```js
var schema = {
  password: {
    input: forms.inputs.PasswordInput
  }
};
```

##### Additional field options:

###### input

The `input` option determines what input component to use for the field when rendering the form. If no input is specified, `forms.inputs.TextInput` is used by default.

- `forms.inputs.TextInput`
- `forms.inputs.PasswordInput`
- `forms.inputs.DateInput`
- `forms.inputs.ChoiceInput`

###### interactive

The `interactive` option determines if the field should be validated immediately once the value changes.

#### messages

The `messages` option is passed directly to [valids](https://github.com/jsdir/valids).

#### onSubmit

The `onSubmit` callback is called with data before validation when the form is initially submitted.

#### onResult

The `onResult` callback is called with validation error messages and form data respectively.

#### showIndicators

The `showIndicators` option determines if indicator icons should be shown on fields.
