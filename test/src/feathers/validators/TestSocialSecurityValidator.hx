package feathers.validators;

import feathers.events.ValidationResultEvent;
import openfl.errors.Error;
import utest.Assert;
import utest.Test;

class TestSocialSecurityValidator extends Test {
	private var _validator:SocialSecurityValidator;

	public function setup():Void {
		_validator = new SocialSecurityValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testValid1():Void {
		var event = _validator.validate("123-45-6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testValid2():Void {
		var event = _validator.validate("123 45 6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testValid3():Void {
		var event = _validator.validate("123456789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowedFormatCharsValid():Void {
		_validator.allowedFormatChars = "#";
		var event = _validator.validate("123#45#6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowedFormatCharsInvalid():Void {
		_validator.allowedFormatChars = "-";
		var event = _validator.validate("123#45#6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("You entered invalid characters in your Social Security number.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharWrongAllowedFormatCharsPosition():Void {
		var event = _validator.validate("12-345-6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("You entered invalid characters in your Social Security number.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testWrongFormat():Void {
		var event = _validator.validate("123-45-67890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongFormat", result.errorCode);
		Assert.equals("The Social Security number must be 9 digits or in the form NNN-NN-NNNN.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testWrongFormatErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongFormatError = expected;
		var event = _validator.validate("123-45-67890");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testZeroStart():Void {
		var event = _validator.validate("000-45-6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("zeroStart", result.errorCode);
		Assert.equals("Invalid Social Security number", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testZeroStartErrorCustom():Void {
		final expected = "Custom error";
		_validator.zeroStartError = expected;
		var event = _validator.validate("000-45-6789");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidChar():Void {
		var event = _validator.validate("123-45-67Z9");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("You entered invalid characters in your Social Security number.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate("123-45-67Z9");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testAllowFormatCharsInvalidThrows():Void {
		Assert.raises(() -> {
			_validator.allowedFormatChars = "2";
		}, Error);
	}
}
