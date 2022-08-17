package feathers.validators;

import openfl.errors.Error;
import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestDateValidator extends Test {
	private var _validator:DateValidator;

	public function setup():Void {
		_validator = new DateValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testDefaultFormatValid():Void {
		var event = _validator.validate("07/31/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomFormatDayBeforeMonthValid():Void {
		_validator.inputFormat = "DD/MM/YYYY";
		var event = _validator.validate("31/07/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomFormatYearMonthDayValid():Void {
		_validator.inputFormat = "YYYY/MM/DD";
		var event = _validator.validate("1989/07/31");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomFormatValidShortValues1():Void {
		_validator.inputFormat = "M/D/YY";
		var event = _validator.validate("2/4/89");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomFormatValidShortValues2():Void {
		_validator.inputFormat = "M/D/YY";
		var event = _validator.validate("12/31/89");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomFormatValidShortValues3():Void {
		_validator.inputFormat = "M/D/YY";
		var event = _validator.validate("02/04/89");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDefaultAllowedFormatCharsValid():Void {
		var event = _validator.validate("12-31-1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowedFormatCharsValid():Void {
		_validator.allowedFormatChars = "#";
		_validator.inputFormat = "MM#DD#YYYY";
		var event = _validator.validate("12#31#1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowedFormatCharsInvalid():Void {
		_validator.allowedFormatChars = "#";
		_validator.inputFormat = "MM#DD#YYYY";
		var event = _validator.validate("12/31/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("invalidChar", result1.errorCode);
		Assert.equals("The date contains invalid characters.", result1.errorMessage);
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testFormatError():Void {
		_validator.inputFormat = "MM/DDD/YYYY";
		var event = _validator.validate("12/31/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("format", result1.errorCode);
		Assert.equals("Configuration error: Incorrect formatting string.", result1.errorMessage);
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testFormatErrorCustom():Void {
		final expected = "Custom error";
		_validator.formatError = expected;
		_validator.inputFormat = "MM/DDD/YYYY";
		var event = _validator.validate("12/31/1989");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongDayError1():Void {
		var event = _validator.validate({month: 12, day: 32, year: 1989});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(3, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongDay", result1.errorCode);
		Assert.equals("Enter a valid day for the month.", result1.errorMessage);
		Assert.equals("day", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("month", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("year", result3.subField);
	}

	public function testWrongDayError2():Void {
		var event = _validator.validate("12/32/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongDay", result1.errorCode);
		Assert.equals("Enter a valid day for the month.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongDayErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongDayError = expected;
		var event = _validator.validate({month: 12, day: 32, year: 1989});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongMonthError1():Void {
		var event = _validator.validate({month: 13, day: 31, year: 1989});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(3, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongMonth", result1.errorCode);
		Assert.equals("Enter a month between 1 and 12.", result1.errorMessage);
		Assert.equals("month", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("year", result3.subField);
	}

	public function testWrongMonthError2():Void {
		var event = _validator.validate("13/31/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongMonth", result1.errorCode);
		Assert.equals("Enter a month between 1 and 12.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongMonthErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongMonthError = expected;
		var event = _validator.validate({month: 13, day: 31, year: 1989});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongYearError():Void {
		var event = _validator.validate({month: 12, day: 31, year: 10000});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(3, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongYear", result1.errorCode);
		Assert.equals("Enter a year between 0 and 9999.", result1.errorMessage);
		Assert.equals("year", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
	}

	public function testWrongYearErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongYearError = expected;
		var event = _validator.validate({month: 12, day: 31, year: 10000});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidCharError():Void {
		var event = _validator.validate("12/1Z/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("invalidChar", result1.errorCode);
		Assert.equals("The date contains invalid characters.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate("12/1Z/1989");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongLengthError1():Void {
		var event = _validator.validate("12/31//1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Type the date in the format.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongLengthError2():Void {
		var event = _validator.validate("12/100/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Type the date in the format.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongLengthError3():Void {
		var event = _validator.validate("100/31/1989");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Type the date in the format.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongLengthError4():Void {
		var event = _validator.validate("12/31/198");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Type the date in the format.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongLengthError5():Void {
		var event = _validator.validate("12/31/10000");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(4, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Type the date in the format.", result1.errorMessage);
		// when a string is passed in, there is no subfield
		Assert.equals("", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("day", result2.subField);
		var result3 = event.results[2];
		Assert.isFalse(result3.isError);
		Assert.equals("", result3.errorCode);
		Assert.equals("", result3.errorMessage);
		Assert.equals("month", result3.subField);
		var result4 = event.results[3];
		Assert.isFalse(result4.isError);
		Assert.equals("", result4.errorCode);
		Assert.equals("", result4.errorMessage);
		Assert.equals("year", result4.subField);
	}

	public function testWrongLengthErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongLengthError = expected;
		var event = _validator.validate("12/31//1989");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testAllowFormatCharsInvalidThrows():Void {
		Assert.raises(() -> {
			_validator.allowedFormatChars = "2";
		}, Error);
	}

	public function testDaySourceThrows():Void {
		Assert.raises(() -> {
			_validator.daySource = "2";
		}, Error);
	}

	public function testMonthSourceThrows():Void {
		Assert.raises(() -> {
			_validator.monthSource = "2";
		}, Error);
	}

	public function testYearSourceThrows():Void {
		Assert.raises(() -> {
			_validator.yearSource = "2";
		}, Error);
	}
}
