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

import openfl.errors.Error;

/**
	The ZipCodeValidator class validates that a String
	has the correct length and format for a five-digit ZIP code,
	a five-digit+four-digit United States ZIP code, or Canadian postal code.
**/
class ZipCodeValidator extends Validator {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	private static final INVALID_CHARS_ERROR:String = "The ZIP code contains invalid characters.";
	private static final INVALID_DOMAIN_ERROR:String = "The domain parameter is invalid. It must be either 'US Only', 'Canada Only', or 'US or Canada'.";
	private static final INVALID_FORMAT_CHARS_ERROR:String = "The allowedFormatChars parameter is invalid. Alphanumeric characters are not allowed (a-z A-Z 0-9).";
	private static final WRONG_CA_FORMAT_ERROR:String = "The Canadian postal code must be formatted 'A1B 2C3'.";
	private static final WRONG_US_FORMAT_ERROR:String = "The ZIP+4 code must be formatted '12345-6789'.";
	private static final WRONG_LENGTH_ERROR:String = "The ZIP code must be 5 digits or 5+4 digits.";

	private static final DOMAIN_US:UInt = 1;

	private static final DOMAIN_US_OR_CANADA:UInt = 2;

	private static final DOMAIN_CANADA:UInt = 3;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The ZipCodeValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies value.zipCode,
		the `baseField` value is `"zipCode"`.

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateZipCode(validator:ZipCodeValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;
		var domain:String = validator.domain;

		var zip:String = Std.string(value);
		var len:Int = zip.length;

		var domainType:UInt = DOMAIN_US;
		switch (domain) {
			case ZipCodeValidatorDomainType.US_OR_CANADA:
				domainType = DOMAIN_US_OR_CANADA;
			case ZipCodeValidatorDomainType.US_ONLY:
				domainType = DOMAIN_US;
			case ZipCodeValidatorDomainType.CANADA_ONLY:
				domainType = DOMAIN_CANADA;
			default:
				results.push(new ValidationResult(true, baseField, "invalidDomain", validator.invalidDomainError));
				return results;
		}

		var n:Int;
		var c:String;

		// Make sure localAllowedFormatChars contains no numbers or letters.
		n = allowedFormatChars.length;
		for (i in 0...n) {
			c = allowedFormatChars.charAt(i);
			if (Validator.DECIMAL_DIGITS.indexOf(c) != -1 || Validator.ROMAN_LETTERS.indexOf(c) != -1) {
				throw new Error(INVALID_FORMAT_CHARS_ERROR);
			}
		}

		// Now start checking the ZIP code.
		// At present, only US and Canadian ZIP codes are supported.
		// As a result, the easiest thing to check first
		// to determine the domain is the length.
		// A length of 5 or 10 means a US ZIP code
		// and a length of 6 or 7 means a Canadian ZIP.
		// If more countries are supported in the future, it may make sense
		// to check other conditions first depending on the domain specified
		// and all the possible ZIP code formats for that domain.
		// For now, this approach makes the most sense.

		// Make sure there are no invalid characters in the ZIP.
		for (i in 0...len) {
			c = zip.charAt(i);

			if (Validator.ROMAN_LETTERS.indexOf(c) == -1
				&& Validator.DECIMAL_DIGITS.indexOf(c) == -1
				&& allowedFormatChars.indexOf(c) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
		}

		// Find out if the ZIP code contains any letters.
		var containsLetters:Bool = false;
		for (i in 0...len) {
			if (Validator.ROMAN_LETTERS.indexOf(zip.charAt(i)) != -1) {
				containsLetters = true;
				break;
			}
		}

		// do an initial check on the length
		if ((len < 5 || len > 10) || (len == 8) || (!containsLetters && (len == 6 || len == 7))) {
			// it's the wrong length for either a US or Canadian zip
			if (domainType == DOMAIN_CANADA) {
				// this is different from Flex. Flex would return an error
				// message for US, even if the domain was strictly Canada
				results.push(new ValidationResult(true, baseField, "wrongCAFormat", validator.wrongCAFormatError));
			} else {
				results.push(new ValidationResult(true, baseField, "wrongLength", validator.wrongLengthError));
			}
			return results;
		}

		// if we got this far, we're doing good so far
		switch (domainType) {
			case DOMAIN_US:
				if (validator.validateUSCode(zip, containsLetters) == false) {
					results.push(new ValidationResult(true, baseField, "wrongUSFormat", validator.wrongUSFormatError));
					return results;
				}

			case DOMAIN_CANADA:
				if (validator.validateCACode(zip, containsLetters) == false) {
					results.push(new ValidationResult(true, baseField, "wrongCAFormat", validator.wrongCAFormatError));
					return results;
				}

			case DOMAIN_US_OR_CANADA:
				var valid:Bool = true;
				var validationResult:ValidationResult = null;

				if (len == 5 || len == 9 || len == 10) // US
				{
					if (validator.validateUSCode(zip, containsLetters) == false) {
						validationResult = new ValidationResult(true, baseField, "wrongUSFormat", validator.wrongUSFormatError);

						valid = false;
					}
				} else // CA
				{
					if (validator.validateCACode(zip, containsLetters) == false) {
						validationResult = new ValidationResult(true, baseField, "wrongCAFormat", validator.wrongCAFormatError);

						valid = false;
					}
				}

				if (!valid) {
					results.push(validationResult);
					return results;
				}
		}

		return results;
	}

	private function validateUSCode(zip:String, containsLetters:Bool):Bool {
		var len:Int = zip.length;

		if (containsLetters) {
			return false;
		}

		// Make sure the first 5 characters are all digits.
		var i:Int = 0;
		while (i < 5) {
			if (Validator.DECIMAL_DIGITS.indexOf(zip.charAt(i)) == -1) {
				return false;
			}
			i++;
		}

		if (len == 9 || len == 10) {
			if (len == 10) {
				// Make sure the 6th character
				// is an allowed formatting character.
				if (allowedFormatChars.indexOf(zip.charAt(5)) == -1) {
					return false;
				}
				i++;
			}

			// Make sure the remaining 4 characters are digits.
			while (i < len) {
				if (Validator.DECIMAL_DIGITS.indexOf(zip.charAt(i)) == -1) {
					return false;
				}
				i++;
			}
		}

		return true;
	}

	private function validateCACode(zip:String, containsLetters:Bool):Bool {
		var len:Int = zip.length;

		// check the basics
		if (!containsLetters) {
			return false;
		}

		var i:UInt = 0;

		// Make sure the zip is in the form 'ldlfdld'
		// where l is a letter, d is a digit,
		// and f is an allowed formatting character.
		if (Validator.ROMAN_LETTERS.indexOf(zip.charAt(i++)) == -1
			|| Validator.DECIMAL_DIGITS.indexOf(zip.charAt(i++)) == -1
			|| Validator.ROMAN_LETTERS.indexOf(zip.charAt(i++)) == -1) {
			return false;
		}

		if (len == 7 && allowedFormatChars.indexOf(zip.charAt(i++)) == -1) {
			return false;
		}

		if (Validator.DECIMAL_DIGITS.indexOf(zip.charAt(i++)) == -1
			|| Validator.ROMAN_LETTERS.indexOf(zip.charAt(i++)) == -1
			|| Validator.DECIMAL_DIGITS.indexOf(zip.charAt(i++)) == -1) {
			return false;
		}

		return true;
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
		The set of formatting characters allowed in the ZIP code.
		This can not have digits or alphabets [a-z A-Z].

		@default " -".
	**/
	public var allowedFormatChars(get, set):String;

	private function get_allowedFormatChars():String {
		return _allowedFormatChars;
	}

	private function set_allowedFormatChars(value:String):String {
		if (value != null) {
			for (i in 0...value.length) {
				var c:String = value.charAt(i);
				if (Validator.DECIMAL_DIGITS.indexOf(c) != -1 || Validator.ROMAN_LETTERS.indexOf(c) != -1) {
					throw new Error(INVALID_FORMAT_CHARS_ERROR);
				}
			}
		}

		allowedFormatCharsOverride = value;

		_allowedFormatChars = value != null ? value : " -";
		return _allowedFormatChars;
	}

	//----------------------------------
	//  domain
	//----------------------------------
	private var _domain:String = ZipCodeValidatorDomainType.US_ONLY;

	private var domainOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		Type of ZIP code to check.

		In Haxe, you can use the following constants to set this property: 
		`ZipCodeValidatorDomainType.US_ONLY`, 
		`ZipCodeValidatorDomainType.US_OR_CANADA`, or
		`ZipCodeValidatorDomainType.CANADA_ONLY`.

		@default ZipCodeValidatorDomainType.US_ONLY
	**/
	public var domain(get, set):String;

	private function get_domain():String {
		return _domain;
	}

	private function set_domain(value:String):String {
		domainOverride = value;

		_domain = value != null ? value : ZipCodeValidatorDomainType.US_ONLY;
		return _domain;
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
		Error message when the ZIP code contains invalid characters.

		@default "The ZIP code contains invalid characters."
	**/
	public var invalidCharError(get, set):String;

	private function get_invalidCharError():String {
		return _invalidCharError;
	}

	private function set_invalidCharError(value:String):String {
		invalidCharErrorOverride = value;

		_invalidCharError = value != null ? value : INVALID_CHARS_ERROR;
		return _invalidCharError;
	}

	//----------------------------------
	//  invalidDomainError
	//----------------------------------
	private var _invalidDomainError:String;

	private var invalidDomainErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the `domain` property contains an invalid value.

		@default "The domain parameter is invalid. It must be either 'US Only' or 'US or Canada'."
	**/
	public var invalidDomainError(get, set):String;

	private function get_invalidDomainError():String {
		return _invalidDomainError;
	}

	private function set_invalidDomainError(value:String):String {
		invalidDomainErrorOverride = value;

		_invalidDomainError = value != null ? value : INVALID_DOMAIN_ERROR;
		return _invalidDomainError;
	}

	//----------------------------------
	//  wrongCAFormatError
	//----------------------------------
	private var _wrongCAFormatError:String;

	private var wrongCAFormatErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message for an invalid Canadian postal code.

		@default "The Canadian postal code must be formatted 'A1B 2C3'."
	**/
	public var wrongCAFormatError(get, set):String;

	private function get_wrongCAFormatError():String {
		return _wrongCAFormatError;
	}

	private function set_wrongCAFormatError(value:String):String {
		wrongCAFormatErrorOverride = value;

		_wrongCAFormatError = value != null ? value : WRONG_CA_FORMAT_ERROR;
		return _wrongCAFormatError;
	}

	//----------------------------------
	//  wrongLengthError
	//----------------------------------
	private var _wrongLengthError:String;

	private var wrongLengthErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message for an invalid US ZIP code.

		@default "The ZIP code must be 5 digits or 5+4 digits."
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
	//  wrongUSFormatError
	//----------------------------------
	private var _wrongUSFormatError:String;

	private var wrongUSFormatErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message for an incorrectly formatted ZIP code.

		@default "The ZIP+4 code must be formatted '12345-6789'."
	**/
	public var wrongUSFormatError(get, set):String;

	private function get_wrongUSFormatError():String {
		return _wrongUSFormatError;
	}

	private function set_wrongUSFormatError(value:String):String {
		wrongUSFormatErrorOverride = value;

		_wrongUSFormatError = value != null ? value : WRONG_US_FORMAT_ERROR;
		return _wrongUSFormatError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowedFormatChars = allowedFormatCharsOverride;
		domain = domainOverride;

		invalidDomainError = invalidDomainErrorOverride;
		invalidCharError = invalidCharErrorOverride;
		wrongCAFormatError = wrongCAFormatErrorOverride;
		wrongLengthError = wrongLengthErrorOverride;
		wrongUSFormatError = wrongUSFormatErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a ZIP code.

		You do not call this method directly;
		Flex calls it as part of performing a validation.
		If you create a custom Validator class, you must implement this method.

		@param value Object to validate.

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
			return ZipCodeValidator.validateZipCode(this, value, null);
		}
	}
}
