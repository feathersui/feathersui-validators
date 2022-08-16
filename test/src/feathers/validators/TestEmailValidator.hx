package feathers.validators;

import feathers.events.ValidationResultEvent;
import openfl.errors.Error;
import utest.Assert;
import utest.Test;

class TestEmailValidator extends Test {
	private var _validator:EmailValidator;

	public function setup():Void {
		_validator = new EmailValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testDomainValid():Void {
		var event = _validator.validate("hello@example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testInvalidDomain1():Void {
		var event = _validator.validate("hello@.example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidDomain", result.errorCode);
		Assert.equals("The domain in your e-mail address is incorrectly formatted.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidDomain2():Void {
		var event = _validator.validate("hello@-example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidDomain", result.errorCode);
		Assert.equals("The domain in your e-mail address is incorrectly formatted.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidDomainErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidDomainError = expected;
		var event = _validator.validate("hello@-example.com");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testIPAddressValid():Void {
		var event = _validator.validate("hello@[123.123.123.123]");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testInvalidIPDomain():Void {
		var event = _validator.validate("hello@[256.123.123.123]");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidIPDomain", result.errorCode);
		Assert.equals("The IP domain in your e-mail address is incorrectly formatted.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidIPDomainErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidIPDomainError = expected;
		var event = _validator.validate("hello@[256.123.123.123]");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testTooManyAtSigns():Void {
		var event = _validator.validate("hello@what@example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("tooManyAtSigns", result.errorCode);
		Assert.equals("Your e-mail address contains too many @ characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testTooManyAtSignsErrorCustom():Void {
		final expected = "Custom error";
		_validator.tooManyAtSignsError = expected;
		var event = _validator.validate("hello@what@example.com");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testMissingAtSign():Void {
		var event = _validator.validate("example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("missingAtSign", result.errorCode);
		Assert.equals("An at sign (@) is missing in your e-mail address.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testMissingAtSignErrorCustom():Void {
		final expected = "Custom error";
		_validator.missingAtSignError = expected;
		var event = _validator.validate("example.com");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testMissingUsername():Void {
		var event = _validator.validate("@example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("missingUsername", result.errorCode);
		Assert.equals("The username in your e-mail address is missing.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testMissingUsernameErrorCustom():Void {
		final expected = "Custom error";
		_validator.missingUsernameError = expected;
		var event = _validator.validate("@example.com");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testMissingPeriodInDomain():Void {
		var event = _validator.validate("hello@example");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("missingPeriodInDomain", result.errorCode);
		Assert.equals("The domain in your e-mail address is missing a period.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testMissingPeriodInDomainErrorCustom():Void {
		final expected = "Custom error";
		_validator.missingPeriodInDomainError = expected;
		var event = _validator.validate("hello@example");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidPeriodsInDomain():Void {
		var event = _validator.validate("hello@example..com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidPeriodsInDomain", result.errorCode);
		Assert.equals("The domain in your e-mail address has consecutive periods.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidPeriodsInDomainErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidPeriodsInDomainError = expected;
		var event = _validator.validate("hello@example..com");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidChar1():Void {
		var event = _validator.validate(".hello@example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("Your e-mail address contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidChar2():Void {
		var event = _validator.validate("h(e)llo@example.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("Your e-mail address contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidChar3():Void {
		var event = _validator.validate("hello@ex(a)mple.com");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("Your e-mail address contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate(".hello@example.com");
		Assert.equals(expected, event.results[0].errorMessage);
	}
}
