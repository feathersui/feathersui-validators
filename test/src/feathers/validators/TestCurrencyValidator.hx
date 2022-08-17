package feathers.validators;

import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestCurrencyValidator extends Test {
	private var _validator:CurrencyValidator;

	public function setup():Void {
		_validator = new CurrencyValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testUnderMinValue():Void {
		_validator.minValue = 29;
		var event = _validator.validate("$28");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("lowerThanMin", result.errorCode);
		Assert.equals("The amount entered is too small.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testEqualsMinValue():Void {
		_validator.minValue = 29;
		var event = _validator.validate("$29");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testOverMinValue():Void {
		_validator.minValue = 29;
		var event = _validator.validate("$30");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testLowerThanMinErrorCustom():Void {
		final expected = "Custom error";
		_validator.minValue = 29;
		_validator.lowerThanMinError = expected;
		var event = _validator.validate("$28");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testOverMaxValue():Void {
		_validator.maxValue = 29;
		var event = _validator.validate("$30");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("exceedsMax", result.errorCode);
		Assert.equals("The amount entered is too large.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testEqualsMaxValue():Void {
		_validator.maxValue = 29;
		var event = _validator.validate("$29");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testUnderMaxValue():Void {
		_validator.maxValue = 29;
		var event = _validator.validate("$28");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testExceedsMaxErrorCustom():Void {
		final expected = "Custom error";
		_validator.maxValue = 29;
		_validator.exceedsMaxError = expected;
		var event = _validator.validate("$30");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testAllowNegativeInvalid1():Void {
		_validator.allowNegative = false;
		var event = _validator.validate("-$1");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("negative", result.errorCode);
		Assert.equals("The amount may not be negative.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testAllowNegativeInvalid2():Void {
		_validator.allowNegative = false;
		var event = _validator.validate("($1)");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("negative", result.errorCode);
		Assert.equals("The amount may not be negative.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testAllowNegativeValid1():Void {
		_validator.allowNegative = true;
		var event = _validator.validate("-$1");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowNegativeValid2():Void {
		_validator.allowNegative = true;
		var event = _validator.validate("($1)");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAllowNegativeErrorCustom():Void {
		final expected = "Custom error";
		_validator.allowNegative = false;
		_validator.negativeError = expected;
		var event = _validator.validate("-$1");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testDefaultCurrencySymbol():Void {
		var event = _validator.validate("$123");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDefaultCurrencySymbolMissing():Void {
		var event = _validator.validate("123");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomCurrencySymbol():Void {
		_validator.currencySymbol = "€";
		var event = _validator.validate("€123");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomCurrencySymbolMissing():Void {
		_validator.currencySymbol = "€";
		var event = _validator.validate("123");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDefaultThousandsSeparator():Void {
		var event = _validator.validate("$1,234");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomThousandsSeparator():Void {
		_validator.thousandsSeparator = "#";
		var event = _validator.validate("$1#234#567");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDecimalSeparatorValid():Void {
		var event = _validator.validate("$1.23");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCustomDecimalSeparator():Void {
		_validator.decimalSeparator = "#";
		var event = _validator.validate("$1#23");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDecimalSeparatorValidNoLeadingDigit():Void {
		var event = _validator.validate("$.23");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testInvalidCharOnlyNegativeSign():Void {
		var event = _validator.validate("-");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharOnlyNegativeSignAndDecimal():Void {
		var event = _validator.validate("-.");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharOnlyNegativeSignAndCurrencySymbol():Void {
		var event = _validator.validate("-$");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharOnlyNegativeSignCurrencySymbolAndDecimal():Void {
		var event = _validator.validate("-$.");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharOnlyCurrencySymbolAndDecimal():Void {
		var event = _validator.validate("$.");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharDecimalOnly():Void {
		var event = _validator.validate(".");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharCurrencySignOnly():Void {
		var event = _validator.validate("$");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharLetter():Void {
		var event = _validator.validate("$z");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharAfterDecimal():Void {
		var event = _validator.validate("$.2,3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testThousandsSeparatorNoLeadingDigit():Void {
		var event = _validator.validate("$,234");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidChar", result.errorCode);
		Assert.equals("The input contains invalid characters.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate("-$");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testDecimalPointCountInvalid():Void {
		var event = _validator.validate("$0.2.0");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("decimalPointCount", result.errorCode);
		Assert.equals("The decimal separator can occur only once.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testDecimalPointCountErrorCustom():Void {
		final expected = "Custom error";
		_validator.decimalPointCountError = expected;
		var event = _validator.validate("$0.2.0");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testSeparationInvalid():Void {
		var event = _validator.validate("$1,23");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("separation", result.errorCode);
		Assert.equals("The thousands separator must be followed by three digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testSeparationErrorCustom():Void {
		final expected = "Custom error";
		_validator.separationError = expected;
		var event = _validator.validate("$1,23");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidFormatCharsThousandsAndDecimalEqual():Void {
		_validator.thousandsSeparator = "#";
		_validator.decimalSeparator = "#";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsThousandsIsNegativeSign():Void {
		_validator.thousandsSeparator = "-";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsDecimalIsNegativeSign():Void {
		_validator.decimalSeparator = "-";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsCurrencySymbolIsNegativeSign():Void {
		_validator.currencySymbol = "-";
		var event = _validator.validate("-123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsThousandsIsDigit():Void {
		_validator.thousandsSeparator = "8";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsDecimalIsDigit():Void {
		_validator.decimalSeparator = "8";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsCurrencySymbolIsDigit():Void {
		_validator.currencySymbol = "8";
		var event = _validator.validate("$123.4");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("invalidFormatChar", result.errorCode);
		Assert.equals("One of the formatting parameters is invalid.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidFormatCharsErrorCustom():Void {
		final expected = "Custom error";
		_validator.thousandsSeparator = "#";
		_validator.decimalSeparator = "#";
		_validator.invalidFormatCharsError = expected;
		var event = _validator.validate("$123.4");
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testDefaultPrecisionValid():Void {
		var event = _validator.validate("$1.23");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDefaultPrecisionInvalid():Void {
		var event = _validator.validate("$1.234");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("precision", result.errorCode);
		Assert.equals("The amount entered has too many digits beyond the decimal point.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testPrecisionValid():Void {
		_validator.precision = 3;
		var event = _validator.validate("$1.234");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testPrecisionValidFewerDigits():Void {
		_validator.precision = 3;
		var event = _validator.validate("$1.2");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testPrecisionInvalid():Void {
		_validator.precision = 3;
		var event = _validator.validate("$1.2345");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("precision", result.errorCode);
		Assert.equals("The amount entered has too many digits beyond the decimal point.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testInvalidPrecisionErrorCustom():Void {
		final expected = "Custom error";
		_validator.precision = 3;
		_validator.precisionError = expected;
		var event = _validator.validate("$1.2345");
		Assert.equals(expected, event.results[0].errorMessage);
	}
}
