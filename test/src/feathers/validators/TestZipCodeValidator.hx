package feathers.validators;

import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

class TestZipCodeValidator extends Test {
	private var _validator:ZipCodeValidator;

	public function setup():Void {
		_validator = new ZipCodeValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testUSZipCodeFiveDigitsInvalidTooShort():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("1234");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("The ZIP code must be 5 digits or 5+4 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeFiveDigitsInvalidTooLong():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("123456");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("The ZIP code must be 5 digits or 5+4 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeValidFiveDigits():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("12345");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testUSZipCodeFiveDigitsPlusFourInvalidTooShort1():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("1234-6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongUSFormat", result.errorCode);
		Assert.equals("The ZIP+4 code must be formatted '12345-6789'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeFiveDigitsPlusFourInvalidTooShort2():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("12345-678");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongUSFormat", result.errorCode);
		Assert.equals("The ZIP+4 code must be formatted '12345-6789'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeFiveDigitsPlusFourInvalidTooLong1():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("123456-7890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("The ZIP code must be 5 digits or 5+4 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeFiveDigitsPlusFourInvalidTooLong2():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("12345-67890");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongLength", result.errorCode);
		Assert.equals("The ZIP code must be 5 digits or 5+4 digits.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeFiveDigitsPlusFourWrongFormattingPosition():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("1234-56789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongUSFormat", result.errorCode);
		Assert.equals("The ZIP+4 code must be formatted '12345-6789'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testUSZipCodeValidFiveDigitsPlusFour():Void {
		_validator.domain = ZipCodeValidatorDomainType.US_ONLY;
		var event = _validator.validate("12345-6789");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testCAZipCodeInvalidTooShort1():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1 2C3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidTooShort2():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1B 2C");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidTooLong1():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1B4 2C3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidTooLong2():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1B 2C34");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidWrongFormattingPosition1():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1B2 C3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidWrongFormattingPosition2():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1 B2C3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeInvalidWrongLetterAndNumberOrder():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("1A2 B3C");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(1, event.results.length);
		var result = event.results[0];
		Assert.isTrue(result.isError);
		Assert.equals("wrongCAFormat", result.errorCode);
		Assert.equals("The Canadian postal code must be formatted 'A1B 2C3'.", result.errorMessage);
		Assert.equals("", result.subField);
	}

	public function testCAZipCodeValid():Void {
		_validator.domain = ZipCodeValidatorDomainType.CANADA_ONLY;
		var event = _validator.validate("A1B 2C3");
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}
}
