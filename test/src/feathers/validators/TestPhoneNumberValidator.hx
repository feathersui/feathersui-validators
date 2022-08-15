package feathers.validators;

import openfl.errors.Error;
import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestPhoneNumberValidator extends Test {
	private var _validator:PhoneNumberValidator;

	public function setup():Void {
		_validator = new PhoneNumberValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testLengthInvalidTooShort1():Void {
		var event = _validator.validate("12-456-7890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("Your telephone number must contain at least 10 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testLengthInvalidTooShort2():Void {
		var event = _validator.validate("123-45-7890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("Your telephone number must contain at least 10 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testLengthInvalidTooShort3():Void {
		var event = _validator.validate("123-456-789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("Your telephone number must contain at least 10 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testWrongLengthErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongLengthError = expected;
		var event = _validator.validate("123-456-789");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testLengthValid1():Void {
		var event = _validator.validate("123-456-7890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testLengthValid2():Void {
		// yes, this is valid. this validator is not strict about separators!
		var event = _validator.validate("1234-56-7890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testInvalidChar():Void {
		var event = _validator.validate("123-456-7Z90");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("Your telephone number contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate("123-456-7Z90");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testAllowFormatCharsInvalidThrows():Void {
		Assert.raises(() -> {
			_validator.allowedFormatChars = "2";
		}, Error);
	}
}
