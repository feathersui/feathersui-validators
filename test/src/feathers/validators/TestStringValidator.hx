package feathers.validators;

import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestStringValidator extends Test {
	private var _validator:StringValidator;

	public function setup():Void {
		_validator = new StringValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testRequiredWithEmptyString():Void {
		_validator.required = true;
		var event = _validator.validate("");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("requiredField", result.errorCode);
		Assert.equals("This field is required.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testRequiredWithNull():Void {
		_validator.required = true;
		var event = _validator.validate(null);
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("requiredField", result.errorCode);
		Assert.equals("This field is required.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testNotRequiredWithEmptyString():Void {
		_validator.required = false;
		var event = _validator.validate("");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testNotRequiredWithNull():Void {
		_validator.required = false;
		var event = _validator.validate(null);
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testRequiredFieldError():Void {
		final expected = "Custom error";
		_validator.required = true;
		_validator.requiredFieldError = expected;
		var event = _validator.validate(null);
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testUnderMinLength():Void {
		_validator.minLength = 2;
		var event = _validator.validate("a");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("tooShort", result.errorCode);
		Assert.equals("This string is shorter than the minimum allowed length. This must be at least 2 characters long.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testEqualsMinLength():Void {
		_validator.minLength = 2;
		var event = _validator.validate("ab");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testOverMinLength():Void {
		_validator.minLength = 2;
		var event = _validator.validate("abc");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testTooShortError():Void {
		final expected = "Custom error";
		_validator.minLength = 2;
		_validator.tooShortError = expected;
		var event = _validator.validate("a");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testOverMaxLength():Void {
		_validator.maxLength = 2;
		var event = _validator.validate("abc");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("tooLong", result.errorCode);
		Assert.equals("This string is longer than the maximum allowed length. This must be less than 2 characters long.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testEqualsMaxLength():Void {
		_validator.maxLength = 2;
		var event = _validator.validate("ab");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testUnderMaxLength():Void {
		_validator.maxLength = 2;
		var event = _validator.validate("a");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testTooLongError():Void {
		final expected = "Custom error";
		_validator.maxLength = 2;
		_validator.tooLongError = expected;
		var event = _validator.validate("abc");
		Assert.equals(expected, event.results[0].errorMessage);
	}
}
