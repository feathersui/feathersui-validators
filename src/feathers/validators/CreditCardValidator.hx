/*
	Licensed to the Apache Software Foundation (ASF) under one or more
	contributor license agreements.  See the NOTICE file distributed with
	this work for additional information regarding copyright ownership.
	The ASF licenses this file to You under the Apache License, Version 2.0
	(the "License"); you may not use this file except in compliance with
	the License.  You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 */

package feathers.validators;

import feathers.validators.utils.ValidatorStringUtil;
import openfl.errors.Error;

/**
	The CreditCardValidator class validates that a credit card number
	is the correct length, has the correct prefix, and passes
	the Luhn mod10 algorithm for the specified card type. 
	This validator does not check whether the credit card
	is an actual active credit card account.

	You can specify the input to the CreditCardValidator in two ways:

	- Use the `cardNumberSource` and `cardNumberProperty` properties to specify
	  the location of the credit card number, and the `cardTypeSource` and
	  `cardTypeProperty` properties to specify the location of the credit card
	  type to validate.
	- Use the `source` and `property` properties to specify a single Object.

		The Object should contain the following fields:

		- `cardType` - Specifies the type of credit card being validated. 

			- In Haxe, use the static constants:

				- `CreditCardValidatorCardType.MASTER_CARD`
				- `CreditCardValidatorCardType.VISA`
				- `CreditCardValidatorCardType.AMERICAN_EXPRESS`
				- `CreditCardValidatorCardType.DISCOVER`
				- `CreditCardValidatorCardType.DINERS_CLUB`

		- `cardNumber` - Specifies the number of the card being validated.

	To perform the validation, it uses the following guidelines:

	Length:

	- Visa: 13 or 16 digits
	- MasterCard: 16 digits
	- Discover: 16 digits
	- American Express: 15 digits
	- Diners Club: 14 digits or 16 digits if it also functions as MasterCard

	Prefix:

	- Visa: 4
	- MasterCard: 51 to 55
	- Discover: 6011
	- American Express: 34 or 37
	- Diners Club: 300 to 305, 36 or 38, 51 to 55

	@see `feathers.validators.CreditCardValidatorCardType`
**/
class CreditCardValidator extends Validator {
	private static final MISSING_CARD_TYPE_ERROR = "The value being validated doesn't contain a cardType property.";
	private static final MISSING_CARD_NUMBER_ERROR = "The value being validated doesn't contain a cardNumber property.";
	private static final INVALID_FORMAT_CHARS_ERROR = "The allowedFormatChars parameter is invalid. It cannot contain any digits.";
	private static final CSN_ATTRIBUTE_ERROR = "The cardNumberSource attribute, '{0}', can not be of type String.";
	private static final CTS_ATTRIBUTE_ERROR = "The cardTypeSource attribute, '{0}', can not be of type String.";
	private static final INVALID_CHAR_ERROR = "Invalid characters in your credit card number. (Enter numbers only.)";
	private static final INVALID_NUMBER_ERROR = "The credit card number is invalid.";
	private static final NO_NUMBER_ERROR = "No credit card number is specified.";
	private static final NO_TYPE_ERROR = "No credit card type is specified or the type is not valid.";
	private static final WRONG_LENGTH_ERROR = "Your credit card number contains the wrong number of digits.";
	private static final WRONG_TYPE_ERROR = "Incorrect card type is specified.";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The CreditCardValidator instance.

		@param value A field to validate, which must contain
		the `cardType` and `cardNumber` fields.

		@param baseField Text representation of the subfield
		specified in the value parameter. 
		For example, if the `value` parameter
		specifies value.date, the `baseField` value is "date".

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `feathers.validators.ValidationResult`
	**/
	public static function validateCreditCard(validator:CreditCardValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;

		var baseFieldDot:String = (baseField != null && baseField.length > 0) ? baseField + "." : "";

		var valid:String = Validator.DECIMAL_DIGITS + allowedFormatChars;
		var cardType:String = null;
		var cardNum:String = null;
		var digitsOnlyCardNum:String = "";
		var message:String;

		var n:Int;

		try {
			var tempCardType:Dynamic = Reflect.getProperty(value, "cardType");
			if (tempCardType != null) {
				cardType = Std.string(tempCardType);
			}
		} catch (e:Dynamic) {
			throw new Error(MISSING_CARD_TYPE_ERROR);
		}

		try {
			var tempCardNum:Dynamic = Reflect.getProperty(value, "cardNumber");
			if (tempCardNum != null) {
				cardNum = Std.string(tempCardNum);
			}
		} catch (f:Dynamic) {
			throw new Error(MISSING_CARD_NUMBER_ERROR);
		}

		// in the Flex version, there was a check if cardType or cardNum were
		// null or length == 0, and it mentioned that the field was required
		// however, the later checks for those same invalid values provide
		// better error messages, so the duplicated validation was removed

		n = allowedFormatChars.length;
		for (i in 0...n) {
			if (Validator.DECIMAL_DIGITS.indexOf(allowedFormatChars.charAt(i)) != -1) {
				throw new Error(INVALID_FORMAT_CHARS_ERROR);
			}
		}

		if (cardType == null || cardType.length == 0) {
			results.push(new ValidationResult(true, baseFieldDot + "cardType", "noType", validator.noTypeError));
		} else if (cardType != CreditCardValidatorCardType.MASTER_CARD
			&& cardType != CreditCardValidatorCardType.VISA
			&& cardType != CreditCardValidatorCardType.AMERICAN_EXPRESS
			&& cardType != CreditCardValidatorCardType.DISCOVER
			&& cardType != CreditCardValidatorCardType.DINERS_CLUB) {
			results.push(new ValidationResult(true, baseFieldDot + "cardType", "wrongType", validator.wrongTypeError));
		}

		if (cardNum == null || cardNum.length == 0) {
			results.push(new ValidationResult(true, baseFieldDot + "cardNumber", "noNum", validator.noNumError));
		}

		if (cardNum != null) {
			n = cardNum.length;
			for (i in 0...n) {
				var temp:String = "" + cardNum.substring(i, i + 1);
				if (valid.indexOf(temp) == -1) {
					results.push(new ValidationResult(true, baseFieldDot + "cardNumber", "invalidChar", validator.invalidCharError));
				}
				if (Validator.DECIMAL_DIGITS.indexOf(temp) != -1)
					digitsOnlyCardNum += temp;
			}
		}

		if (results.length > 0)
			return results;

		var cardNumLen:Int = digitsOnlyCardNum.length;
		var correctLen:Int = -1;
		var correctLen2:Int = -1;
		var correctPrefixArray:Array<String> = [];

		// diner club cards with a beginning digit of 5 need to be treated as
		// master cards. Go to the following link for more info.
		// http://www.globalpaymentsinc.com/myglobal/industry_initiatives/mc-dc-canada.html
		if (cardType == CreditCardValidatorCardType.DINERS_CLUB && digitsOnlyCardNum.charAt(0) == "5") {
			cardType = CreditCardValidatorCardType.MASTER_CARD;
		}

		switch (cardType) {
			case CreditCardValidatorCardType.MASTER_CARD:
				correctLen = 16;
				correctPrefixArray.push("51");
				correctPrefixArray.push("52");
				correctPrefixArray.push("53");
				correctPrefixArray.push("54");
				correctPrefixArray.push("55");

			case CreditCardValidatorCardType.VISA:
				correctLen = 13;
				correctLen2 = 16;
				correctPrefixArray.push("4");

			case CreditCardValidatorCardType.AMERICAN_EXPRESS:
				correctLen = 15;
				correctPrefixArray.push("34");
				correctPrefixArray.push("37");

			case CreditCardValidatorCardType.DISCOVER:
				correctLen = 16;
				correctPrefixArray.push("6011");

			case CreditCardValidatorCardType.DINERS_CLUB:
				correctLen = 14;
				correctPrefixArray.push("300");
				correctPrefixArray.push("301");
				correctPrefixArray.push("302");
				correctPrefixArray.push("303");
				correctPrefixArray.push("304");
				correctPrefixArray.push("305");
				correctPrefixArray.push("36");
				correctPrefixArray.push("38");

			default:
				results.push(new ValidationResult(true, baseFieldDot + "cardType", "wrongType", validator.wrongTypeError));
				return results;
		}

		if ((cardNumLen != correctLen) && (cardNumLen != correctLen2)) {
			results.push(new ValidationResult(true, baseFieldDot + "cardNumber", "wrongLength", validator.wrongLengthError));
			return results;
		}

		// Validate the prefix
		var foundPrefix:Bool = false;
		var i = correctPrefixArray.length - 1;
		while (i >= 0) {
			if (digitsOnlyCardNum.indexOf(correctPrefixArray[i]) == 0) {
				foundPrefix = true;
				break;
			}
			i--;
		}

		if (!foundPrefix) {
			results.push(new ValidationResult(true, baseFieldDot + "cardNumber", "invalidNumber", validator.invalidNumberError));
			return results;
		}

		// Implement Luhn formula testing of this.cardNumber
		var doubledigit:Bool = false;
		var checkdigit:Int = 0;
		var tempdigit:Int;
		var i = cardNumLen - 1;
		while (i >= 0) {
			tempdigit = Std.parseInt(digitsOnlyCardNum.charAt(i));
			if (doubledigit) {
				tempdigit *= 2;
				checkdigit += (tempdigit % 10);
				if ((tempdigit / 10) >= 1.0)
					checkdigit++;
				doubledigit = false;
			} else {
				checkdigit = checkdigit + tempdigit;
				doubledigit = true;
			}
			i--;
		}

		if ((checkdigit % 10) != 0) {
			results.push(new ValidationResult(true, baseFieldDot + "cardNumber", "invalidNumber", validator.invalidNumberError));
			return results;
		}

		return results;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
		Constructor.
	**/
	public function new() {
		super();

		subFields = ["cardNumber", "cardType"];
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  actualListeners
	//----------------------------------

	/** 
		Returns either the listener or the source
		for the cardType and cardNumber subfields.
	**/
	override private function get_actualListeners():Array<Dynamic> {
		var results:Array<Dynamic> = [];

		var typeResult:Dynamic = null;
		if (_cardTypeListener != null) {
			typeResult = _cardTypeListener;
		} else if (_cardTypeSource != null) {
			typeResult = _cardTypeSource;
		}

		results.push(typeResult);
		if ((typeResult is IValidatorListener)) {
			cast(typeResult, IValidatorListener).validationSubField = "cardType";
		}

		var numResult:Dynamic = null;
		if (_cardNumberListener != null) {
			numResult = _cardNumberListener;
		} else if (_cardNumberSource != null) {
			numResult = _cardNumberSource;
		}

		results.push(numResult);
		if ((numResult is IValidatorListener)) {
			cast(numResult, IValidatorListener).validationSubField = "cardNumber";
		}

		if (results.length > 0 && listener) {
			results.push(listener);
		}

		return results;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  allowedFormatChars
	//----------------------------------
	private var _allowedFormatChars:String;

	private var allowedFormatCharsOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		The set of formatting characters allowed in the
		`cardNumber` field.

		@default " -" (space and dash)
	**/
	public var allowedFormatChars(get, set):String;

	private function get_allowedFormatChars():String {
		return _allowedFormatChars;
	}

	private function set_allowedFormatChars(value:String):String {
		if (value != null) {
			var n:Int = value.length;
			for (i in 0...n) {
				if (Validator.DECIMAL_DIGITS.indexOf(value.charAt(i)) != -1) {
					throw new Error(INVALID_FORMAT_CHARS_ERROR);
				}
			}
		}

		allowedFormatCharsOverride = value;

		_allowedFormatChars = value != null ? value : " -";
		return _allowedFormatChars;
	}

	//----------------------------------
	//  cardNumberListener
	//----------------------------------
	private var _cardNumberListener:IValidatorListener;

	// [Inspectable(category="General")]

	/** 
		The component that listens for the validation result
		for the card number subfield. 
		If none is specified, use the value specified
		to the `cardNumberSource` property.
	**/
	public var cardNumberListener(get, set):IValidatorListener;

	private function get_cardNumberListener():IValidatorListener {
		return _cardNumberListener;
	}

	private function set_cardNumberListener(value:IValidatorListener):IValidatorListener {
		if (_cardNumberListener == value)
			return _cardNumberListener;

		removeListenerHandler();

		_cardNumberListener = value;

		addListenerHandler();

		return _cardNumberListener;
	}

	//----------------------------------
	//  cardNumberProperty
	//----------------------------------
	// [Inspectable(category="General")]

	/**
		Name of the card number property to validate. This attribute is
		optional, but if you specify the `cardNumberSource` property, 
		you should also specify either `cardNumberProperty` or
		`cardNumberValueFunction` as well.

		@see `cardNumberValueFunction`
	**/
	public var cardNumberProperty:String;

	/**
		A function that returns the day value to validate. It's recommended to
		use `cardNumberValueFunction` instead of `cardNumberProperty` because
		reflection is used with `cardNumberProperty`, which could result in
		issues if Dead Code Elimination (DCE) is enabled.
	**/
	public var cardNumberValueFunction:() -> Dynamic;

	//----------------------------------
	//  cardNumberSource
	//----------------------------------
	private var _cardNumberSource:Dynamic;

	// [Inspectable(category="General")]

	/** 
		Object that contains the value of the card number field.
		If you specify a value for this property, you must also specify
		a value for either the `cardNumberProperty` property or the
		`cardNumberValueFunction` property. 
		Do not use this property if you set the `source` 
		and `property` (or `valueFunction`) properties.

		@see `cardNumberProperty`
		@see `cardNumberValueFunction`
	**/
	public var cardNumberSource(get, set):Dynamic;

	private function get_cardNumberSource():Dynamic {
		return _cardNumberSource;
	}

	private function set_cardNumberSource(value:Dynamic):Dynamic {
		if (_cardNumberSource == value)
			return _cardNumberSource;

		if ((value is String)) {
			var message:String = ValidatorStringUtil.substitute(CSN_ATTRIBUTE_ERROR, value);
			throw new Error(message);
		}

		removeListenerHandler();

		_cardNumberSource = value;

		addListenerHandler();

		return _cardNumberSource;
	}

	//----------------------------------
	//  cardTypeListener
	//----------------------------------
	private var _cardTypeListener:IValidatorListener;

	// [Inspectable(category="General")]

	/** 
		The component that listens for the validation result
		for the card type subfield. 
		If none is specified, then use the value
		specified to the `cardTypeSource` property.
	**/
	public var cardTypeListener(get, set):IValidatorListener;

	private function get_cardTypeListener():IValidatorListener {
		return _cardTypeListener;
	}

	private function set_cardTypeListener(value:IValidatorListener):IValidatorListener {
		if (_cardTypeListener == value)
			return _cardTypeListener;

		removeListenerHandler();

		_cardTypeListener = value;

		addListenerHandler();

		return _cardTypeListener;
	}

	//----------------------------------
	//  cardTypeProperty
	//----------------------------------
	// [Inspectable(category="General")]

	/**
		Name of the card type property to validate. This property is optional,
		but if you specify the `cardTypeSource` property, you should specify
		either `cardTypeProperty` or `cardTypeValueFunction` as well.

		@see `cardTypeValueFunction`
		@see `feathers.validators.CreditCardValidatorCardType`
	**/
	public var cardTypeProperty:String;

	/**
		A function that returns the day value to validate. It's recommended to
		use `cardTypeValueFunction` instead of `cardTypeProperty` because
		reflection is used with `cardTypeProperty`, which could result in issues
		if Dead Code Elimination (DCE) is enabled.
	**/
	public var cardTypeValueFunction:() -> Dynamic;

	//----------------------------------
	//  cardTypeSource
	//----------------------------------
	private var _cardTypeSource:Dynamic;

	// [Inspectable(category="General")]

	/** 
		Object that contains the value of the card type field.
		If you specify a value for this property, you must also specify
		a value for either the `cardTypeProperty` property or the
		`cardTypeValueFunction` property. 
		Do not use this property if you set the `source` 
		and `property` (or `valueFunction`) properties.

		@see `cardTypeProperty`
		@see `cardTypeValueFunction`
		@see `feathers.validators.CreditCardValidatorCardType`
	**/
	public var cardTypeSource(get, set):Dynamic;

	private function get_cardTypeSource():Dynamic {
		return _cardTypeSource;
	}

	private function set_cardTypeSource(value:Dynamic):Dynamic {
		if (_cardTypeSource == value)
			return _cardTypeSource;

		if ((value is String)) {
			var message:String = ValidatorStringUtil.substitute(CTS_ATTRIBUTE_ERROR, value);
			throw new Error(message);
		}

		removeListenerHandler();

		_cardTypeSource = value;

		addListenerHandler();

		return _cardTypeSource;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  invalidCharError
	//----------------------------------
	private var _invalidCharError:String;

	private var invalidCharErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the `cardNumber` field contains invalid characters.

		@default "Invalid characters in your credit card number. (Enter numbers only.)"
	**/
	public var invalidCharError(get, set):String;

	private function get_invalidCharError():String {
		return _invalidCharError;
	}

	private function set_invalidCharError(value:String):String {
		invalidCharErrorOverride = value;

		_invalidCharError = value != null ? value : INVALID_CHAR_ERROR;
		return _invalidCharError;
	}

	//----------------------------------
	//  invalidNumberError
	//----------------------------------
	private var _invalidNumberError:String;

	private var invalidNumberErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the credit card number is invalid.

		@default "The credit card number is invalid."
	**/
	public var invalidNumberError(get, set):String;

	private function get_invalidNumberError():String {
		return _invalidNumberError;
	}

	private function set_invalidNumberError(value:String):String {
		invalidNumberErrorOverride = value;

		_invalidNumberError = value != null ? value : INVALID_NUMBER_ERROR;
		return _invalidNumberError;
	}

	//----------------------------------
	//  noNumError
	//----------------------------------
	private var _noNumError:String;

	private var noNumErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the `cardNumber` field is empty.

		@default "No credit card number is specified."
	**/
	public var noNumError(get, set):String;

	private function get_noNumError():String {
		return _noNumError;
	}

	private function set_noNumError(value:String):String {
		noNumErrorOverride = value;

		_noNumError = value != null ? value : NO_NUMBER_ERROR;
		return _noNumError;
	}

	//----------------------------------
	//  noTypeError
	//----------------------------------
	private var _noTypeError:String;

	private var noTypeErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the `cardType` field is blank.

		@default "No credit card type is specified or the type is not valid."
	**/
	public var noTypeError(get, set):String;

	private function get_noTypeError():String {
		return _noTypeError;
	}

	private function set_noTypeError(value:String):String {
		noTypeErrorOverride = value;

		_noTypeError = value != null ? value : NO_TYPE_ERROR;
		return _noTypeError;
	}

	//----------------------------------
	//  wrongLengthError
	//----------------------------------
	private var _wrongLengthError:String;

	private var wrongLengthErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the `cardNumber` field contains the wrong
		number of digits for the specified credit card type.

		@default "Your credit card number contains the wrong number of digits." 
	**/
	public var wrongLengthError(get, set):String;

	private function get_wrongLengthError():String {
		return _wrongLengthError;
	}

	private function set_wrongLengthError(value:String):String {
		wrongLengthErrorOverride = value;

		_wrongLengthError = value != null ? value : WRONG_LENGTH_ERROR;
		return _wrongLengthError;
	}

	//----------------------------------
	//  wrongTypeError
	//----------------------------------
	private var _wrongTypeError:String;

	private var wrongTypeErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message the `cardType` field contains an invalid credit card type. 
		You should use the predefined constants for the `cardType` field:

		- `CreditCardValidatorCardType.MASTER_CARD`
		- `CreditCardValidatorCardType.VISA`
		- `CreditCardValidatorCardType.AMERICAN_EXPRESS`
		- `CreditCardValidatorCardType.DISCOVER`
		- `CreditCardValidatorCardType.DINERS_CLUB`

		@default "Incorrect card type is specified."
	**/
	public var wrongTypeError(get, set):String;

	private function get_wrongTypeError():String {
		return _wrongTypeError;
	}

	private function set_wrongTypeError(value:String):String {
		wrongTypeErrorOverride = value;

		_wrongTypeError = value != null ? value : WRONG_TYPE_ERROR;
		return _wrongTypeError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowedFormatChars = allowedFormatCharsOverride;

		invalidCharError = invalidCharErrorOverride;
		invalidNumberError = invalidNumberErrorOverride;
		noNumError = noNumErrorOverride;
		noTypeError = noTypeErrorOverride;
		wrongLengthError = wrongLengthErrorOverride;
		wrongTypeError = wrongTypeErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a credit card number.

		You do not call this method directly;
		Flex calls it as part of performing a validation.
		If you create a custom Validator class, you must implement this method.

		@param value an Object to validate.

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 
	**/
	override private function doValidation(value:Dynamic):Array<ValidationResult> {
		var results = super.doValidation(value);

		// Return if there are errors
		// or if the required property is set to false and length is 0.
		var val:String = value != null ? Std.string(value) : "";
		if (results.length > 0 || ((val.length == 0) && !required)) {
			return results;
		} else {
			return CreditCardValidator.validateCreditCard(this, value, null);
		}
	}

	/**
		Grabs the data for the validator from two different sources
	**/
	override private function getValueFromSource():Dynamic {
		var useValue:Bool = false;

		var value:Dynamic = {};

		if (cardTypeValueFunction != null) {
			value.cardType = cardTypeValueFunction();
			useValue = true;
		} else if (cardTypeSource != null && cardTypeProperty != null) {
			value.cardType = Reflect.getProperty(cardTypeSource, cardTypeProperty);
			useValue = true;
		}

		if (cardNumberValueFunction != null) {
			value.cardNumber = cardNumberValueFunction();
			useValue = true;
		} else if (cardNumberSource != null && cardNumberProperty != null) {
			value.cardNumber = Reflect.getProperty(cardNumberSource, cardNumberProperty);
			useValue = true;
		}

		if (useValue) {
			return value;
		} else {
			return super.getValueFromSource();
		}
	}
}
