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
	The SocialSecurityValidator class validates that a String
	is a valid United States Social Security number.
	It does not check whether it is an existing Social Security number.
**/
class SocialSecurityValidator extends Validator {
	private static final INVALID_FORMAT_CHARS_ERROR = "The allowedFormatChars parameter is invalid. It cannot contain any digits.";
	private static final ZERO_START_ERROR = "Invalid Social Security number";
	private static final WRONG_FORMAT_ERROR = "The Social Security number must be 9 digits or in the form NNN-NN-NNNN.";
	private static final INVALID_CHAR_ERROR = "You entered invalid characters in your Social Security number.";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The SocialSecurityValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies
		value.social, the `baseField` value is `social`.

		@return An Array of ValidationResult objects, with one ValidationResult
		object for each field examined by the validator.

		@see `mx.validators.ValidationResult`
	**/
	public static function validateSocialSecurity(validator:SocialSecurityValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;

		var hyphencount:Int = 0;
		var len:Int = value.toString().length;
		var checkForFormatChars:Bool = false;

		var n:Int;

		if ((len != 9) && (len != 11)) {
			results.push(new ValidationResult(true, baseField, "wrongFormat", validator.wrongFormatError));
			return results;
		}

		n = allowedFormatChars.length;
		for (i in 0...n) {
			if (Validator.DECIMAL_DIGITS.indexOf(allowedFormatChars.charAt(i)) != -1) {
				throw new Error(INVALID_FORMAT_CHARS_ERROR);
			}
		}

		if (len == 11) {
			checkForFormatChars = true;
		}

		for (i in 0...len) {
			var allowedChars:String;
			if (checkForFormatChars && (i == 3 || i == 6)) {
				allowedChars = allowedFormatChars;
			} else {
				allowedChars = Validator.DECIMAL_DIGITS;
			}

			if (allowedChars.indexOf(value.charAt(i)) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
		}

		if (value.substring(0, 3) == "000") {
			results.push(new ValidationResult(true, baseField, "zeroStart", validator.zeroStartError));
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
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  allowedFormatChars
	//----------------------------------
	private var _allowedFormatChars:String = " -";

	private var allowedFormatCharsOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Specifies the set of formatting characters allowed in the input.

		@default " -"
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

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  invalidCharError
	//----------------------------------
	private var _invalidCharError:String = INVALID_CHAR_ERROR;

	private var invalidCharErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value contains characters
		other than digits and formatting characters
		defined by the `allowedFormatChars` property.

		@default "You entered invalid characters in your Social Security number."
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
	//  wrongFormatError
	//----------------------------------
	private var _wrongFormatError:String = WRONG_FORMAT_ERROR;

	private var wrongFormatErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value is incorrectly formatted.

		@default "The Social Security number must be 9 digits or in the form NNN-NN-NNNN."
	**/
	public var wrongFormatError(get, set):String;

	private function get_wrongFormatError():String {
		return _wrongFormatError;
	}

	private function set_wrongFormatError(value:String):String {
		wrongFormatErrorOverride = value;

		_wrongFormatError = value != null ? value : WRONG_FORMAT_ERROR;
		return _wrongFormatError;
	}

	//----------------------------------
	//  zeroStartError
	//----------------------------------
	private var _zeroStartError:String = ZERO_START_ERROR;

	private var zeroStartErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value contains an invalid Social Security number.

		@default "Invalid Social Security number; the number cannot start with 000."
	**/
	public var zeroStartError(get, set):String;

	private function get_zeroStartError():String {
		return _zeroStartError;
	}

	private function set_zeroStartError(value:String):String {
		zeroStartErrorOverride = value;

		_zeroStartError = value != null ? value : ZERO_START_ERROR;
		return _zeroStartError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowedFormatChars = allowedFormatChars;

		invalidCharError = invalidCharErrorOverride;
		wrongFormatError = wrongFormatErrorOverride;
		zeroStartError = zeroStartErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a Social Security number.

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
		// or if the required property is set to `false` and length is 0.
		var val:String = value != null ? Std.string(value) : "";
		if (results.length > 0 || ((val.length == 0) && !required)) {
			return results;
		} else {
			return SocialSecurityValidator.validateSocialSecurity(this, value, null);
		}
	}
}
