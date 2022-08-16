package feathers.validators;

import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestRegExpValidator extends Test {
	private var _validator:RegExpValidator;

	public function setup():Void {
		_validator = new RegExpValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testValid():Void {
		_validator.expression = "^[a-z]+[0-9]+$";
		var event = _validator.validate("abc123");
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = cast(event.results[0], RegExpValidationResult);
		Assert.equals("abc123", result.matchedString);
		Assert.equals(0, result.matchedIndex);
		Assert.notNull(result.matchedSubstrings);
		Assert.equals(0, result.matchedSubstrings.length);
	}

	public function testValidWithSubstrings():Void {
		_validator.expression = "^([a-z]+)([0-9]+)$";
		var event = _validator.validate("abc123");
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = cast(event.results[0], RegExpValidationResult);
		Assert.equals("abc123", result.matchedString);
		Assert.equals(0, result.matchedIndex);
		Assert.equals(2, result.matchedSubstrings.length);
		var substrs = result.matchedSubstrings;
		Assert.equals("abc", substrs[0]);
		Assert.equals("123", substrs[1]);
	}

	public function testNoExpression():Void {
		var event = _validator.validate("abc123");
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("noExpression", result.errorCode);
		Assert.equals("The expression is missing.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testNoExpressionErrorCustom():Void {
		final expected = "Custom error";
		_validator.noExpressionError = expected;
		var event = _validator.validate("abc123");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testNoMatch():Void {
		_validator.expression = "123abc";
		var event = _validator.validate("abc123");
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("noMatch", result.errorCode);
		Assert.equals("The field is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testNoMatchErrorCustom():Void {
		final expected = "Custom error";
		_validator.expression = "123abc";
		_validator.noMatchError = expected;
		var event = _validator.validate("abc123");
		Assert.equals(expected, event.results[0].errorMessage);
	}
}
