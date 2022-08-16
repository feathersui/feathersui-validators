package feathers.validators;

import openfl.errors.Error;
import feathers.events.ValidationResultEvent;
import utest.Assert;
import utest.Test;

/*
	Some example credit card numbers for testing purposes.

	| Credit Card Type | Credit Card Number |
	| ---------------- | ------------------ |
	| American Express | 371449635398431    |
	| Diners Club      | 30569309025904     |
	| Discover         | 6011111111111117   |
	| JCB              | 3530111333300000   |
	| MasterCard       | 5555555555554444   |
	| Visa             | 4111111111111111   |

	Source: https://www.validcreditcardnumber.com
 */
class TestCreditCardValidator extends Test {
	private var _validator:CreditCardValidator;

	public function setup():Void {
		_validator = new CreditCardValidator();
	}

	public function teardown():Void {
		_validator = null;
	}

	public function testMasterCardValid():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD, cardNumber: "5555555555554444"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testVisaValid():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.VISA, cardNumber: "4111111111111111"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testAmexValid():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.AMERICAN_EXPRESS, cardNumber: "371449635398431"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDiscoverValid():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.DISCOVER, cardNumber: "6011111111111117"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testDinersClubValid():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.DINERS_CLUB, cardNumber: "30569309025904"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.VALID, event.type);
		Assert.isNull(event.results);
	}

	public function testNoNumError():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("noNum", result1.errorCode);
		Assert.equals("No credit card number is specified.", result1.errorMessage);
		Assert.equals("cardNumber", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardType", result2.subField);
	}

	public function testNoNumErrorCustom():Void {
		final expected = "Custom error";
		_validator.noNumError = expected;
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testNoTypeError():Void {
		var event = _validator.validate({cardNumber: "5555555555554444"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("noType", result1.errorCode);
		Assert.equals("No credit card type is specified or the type is not valid.", result1.errorMessage);
		Assert.equals("cardType", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardNumber", result2.subField);
	}

	public function testNoTypeErrorCustom():Void {
		final expected = "Custom error";
		_validator.required = false;
		_validator.noTypeError = expected;
		var event = _validator.validate({cardNumber: "5555555555554444"});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongTypeError():Void {
		var event = _validator.validate({cardType: "Invalid Card Type", cardNumber: "5555555555554444"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongType", result1.errorCode);
		Assert.equals("Incorrect card type is specified.", result1.errorMessage);
		Assert.equals("cardType", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardNumber", result2.subField);
	}

	public function testWrongTypeErrorCustom():Void {
		final expected = "Custom error";
		_validator.required = false;
		_validator.wrongTypeError = expected;
		var event = _validator.validate({cardType: "Invalid Card Type", cardNumber: "5555555555554444"});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidCharError():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD, cardNumber: "555555555555444A"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("invalidChar", result1.errorCode);
		Assert.equals("Invalid characters in your credit card number. (Enter numbers only.)", result1.errorMessage);
		Assert.equals("cardNumber", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardType", result2.subField);
	}

	public function testInvalidCharErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidCharError = expected;
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD, cardNumber: "555555555555444A"});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testWrongLengthError():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD, cardNumber: "55555555555544441"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("wrongLength", result1.errorCode);
		Assert.equals("Your credit card number contains the wrong number of digits.", result1.errorMessage);
		Assert.equals("cardNumber", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardType", result2.subField);
	}

	public function testWrongLengthErrorCustom():Void {
		final expected = "Custom error";
		_validator.wrongLengthError = expected;
		var event = _validator.validate({cardType: CreditCardValidatorCardType.MASTER_CARD, cardNumber: "55555555555544441"});
		Assert.equals(expected, event.results[0].errorMessage);
	}

	public function testInvalidNumberError():Void {
		var event = _validator.validate({cardType: CreditCardValidatorCardType.VISA, cardNumber: "5555555555554444"});
		Assert.notNull(event);
		Assert.equals(ValidationResultEvent.INVALID, event.type);
		Assert.notNull(event.results);
		Assert.equals(2, event.results.length);
		var result1 = event.results[0];
		Assert.isTrue(result1.isError);
		Assert.equals("invalidNumber", result1.errorCode);
		Assert.equals("The credit card number is invalid.", result1.errorMessage);
		Assert.equals("cardNumber", result1.subField);
		var result2 = event.results[1];
		Assert.isFalse(result2.isError);
		Assert.equals("", result2.errorCode);
		Assert.equals("", result2.errorMessage);
		Assert.equals("cardType", result2.subField);
	}

	public function testInvalidNumberErrorCustom():Void {
		final expected = "Custom error";
		_validator.invalidNumberError = expected;
		var event = _validator.validate({cardType: CreditCardValidatorCardType.VISA, cardNumber: "5555555555554444"});
		Assert.equals(expected, event.results[0].errorMessage);
	}
}
