# Validators for Feathers UI

A port of the form validation classes from [Apache Flex](https://flex.apache.org/) (formerly Adobe Flex) to [Feathers UI](https://feathersui.com/) for [Haxe](https://haxe.org/) and [OpenFL](https://openfl.org/).

Includes the following validators:

- [`CreditCardValidator`](https://api.feathersui.com/validators/current/feathers/validators/CreditCardValidator.html)
- [`CurrencyValidator`](https://api.feathersui.com/validators/current/feathers/validators/CurrencyValidator.html)
- [`DateValidator`](https://api.feathersui.com/validators/current/feathers/validators/DateValidator.html)
- [`EmailValidator`](https://api.feathersui.com/validators/current/feathers/validators/EmailValidator.html)
- [`NumberValidator`](https://api.feathersui.com/validators/current/feathers/validators/NumberValidator.html)
- [`PhoneNumberValidator`](https://api.feathersui.com/validators/current/feathers/validators/PhoneNumberValidator.html)
- [`RegExpValidator`](https://api.feathersui.com/validators/current/feathers/validators/RegExpValidator.html)
- [`SocialSecurityValidator`](https://api.feathersui.com/validators/current/feathers/validators/SocialSecurityValidator.html)
- [`StringValidator`](https://api.feathersui.com/validators/current/feathers/validators/StringValidator.html)
- [`ZipCodeValidator`](https://api.feathersui.com/validators/current/feathers/validators/ZipCodeValidator.html)

## Minimum Requirements

- Haxe 4.2
- OpenFL 9.2
- Feathers UI 1.0

## Installation

This library is not yet available on Haxelib, so you'll need to install it from Github.

```sh
haxelib git feathersui-validators https://github.com/feathersui/feathersui-validators.git
```

## Project Configuration

After installing the library above, add it to your OpenFL _project.xml_ file:

```xml
<haxelib name="feathersui-validators" />
```

## Usage

The following example validates a text input when it loses focus:

```haxe
var textInput = new TextInput();
addChild(textInput);

var validator = new NumberValidator();
validator.source = textInput;
validator.valueFunction = () -> textInput.text;
validator.triggerEvent = FocusEvent.FOCUS_OUT;
validator.addEventListener(ValidationResultEvent.VALID, event -> {
	textInput.errorString = null;
});
validator.addEventListener(ValidationResultEvent.INVALID, event -> {
	var errorString = "";
	for (validationResult in event.results) {
		if (!validationResult.isError) {
			continue;
		}
		if (errorString.length > 0) {
			errorString += "\n";
		}
		errorString += validationResult.errorMessage;
	}
	textInput.errorString = errorString;
});
```

The following example validates a form when it is submitted:

```haxe
var form = new Form();
addChild(form);

var textInput = new TextInput();
var formItem = new FormItem("My Field", textInput);
form.addChild(formItem);

var submitButton = new Button("Submit");
form.addChild(submitButton);
form.submitButton = submitButton;

var validator = new NumberValidator();
validator.source = null;
validator.valueFunction = () -> textInput.text;
// don't trigger automatically
// we'll do it manually when the form is submitted
validator.triggerEvent = null;
validator.addEventListener(ValidationResultEvent.VALID, event -> {
	textInput.errorString = null;
});
validator.addEventListener(ValidationResultEvent.INVALID, event -> {
	var errorString = "";
	for (validationResult in event.results) {
		if (!validationResult.isError) {
			continue;
		}
		if (errorString.length > 0) {
			errorString += "\n";
		}
		errorString += validationResult.errorMessage;
	}
	textInput.errorString = errorString;
});

form.addEventListener(FormEvent.SUBMIT, event -> {
	var hasErrors = false;
	var validators:Array<IValidator> = [validator];
	var events = Validator.validateAll(validators);
	for (event in events) {
		for (validationResult in event.results) {
			if (validationResult.isError) {
				hasErrors = true;
				break;
			}
		}
		if (hasErrors) {
			break;
		}
	}
	if (hasErrors) {
		// some checks were invalid, so don't submit
		return;
	}

	// everything is valid, so now it can be sent to the server
	// using URLLoader or something
});
```

## Documentation

- [feathersui-validators API Reference](https://api.feathersui.com/validators/)
