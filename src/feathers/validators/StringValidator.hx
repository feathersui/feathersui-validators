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

/**
	The `StringValidator` class validates that the length of a String is within a
	specified range. 
 */
class StringValidator extends Validator {
	private static final TOO_LONG_ERROR = "This string is longer than the maximum allowed length. This must be less than {0} characters long.";
	private static final TOO_SHORT_ERROR = "This string is shorter than the minimum allowed length. This must be at least {0} characters long.";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator. Each of the standard Flex
		validators has a similar convenience method.

		@param validator The StringValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies
		value.mystring, the `baseField` value
		is `"mystring"`.

		@return An Array of ValidationResult objects, with one
		ValidationResult  object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateString(validator:StringValidator, value:Dynamic, baseField:String = null):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var maxLength = validator.maxLength;
		var minLength = validator.minLength;

		var val:String = value != null ? Std.string(value) : "";

		if (!Math.isNaN(maxLength) && val.length > maxLength) {
			results.push(new ValidationResult(true, baseField, "tooLong", ValidatorStringUtil.substitute(validator.tooLongError, Std.string(maxLength))));
			return results;
		}

		if (!Math.isNaN(minLength) && val.length < minLength) {
			results.push(new ValidationResult(true, baseField, "tooShort", ValidatorStringUtil.substitute(validator.tooShortError, Std.string(minLength))));
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
	//  maxLength
	//----------------------------------
	private var _maxLength:Float = Math.NaN;

	private var maxLengthOverride:Float = Math.NaN;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		Maximum length for a valid String. A value of `Math.NaN` means this property is
		ignored.

		@default Math.NaN
	**/
	public var maxLength(get, set):Float;

	private function get_maxLength():Float {
		return _maxLength;
	}

	private function set_maxLength(value:Float):Float {
		maxLengthOverride = value;

		_maxLength = value;
		return _maxLength;
	}

	//----------------------------------
	//  minLength
	//----------------------------------
	private var _minLength:Float = Math.NaN;

	private var minLengthOverride:Float = Math.NaN;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		Minimum length for a valid String. A value of `Math.NaN` means this property is
		ignored.

		@default Math.NaN
	**/
	public var minLength(get, set):Float;

	private function get_minLength():Float {
		return _minLength;
	}

	private function set_minLength(value:Float):Float {
		minLengthOverride = value;

		_minLength = value;
		return _minLength;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  tooLongError
	//----------------------------------
	private var _tooLongError:String = TOO_LONG_ERROR;

	private var tooLongErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the String is longer than the `maxLength` property.

		@default "This string is longer than the maximum allowed length. This must be less than {0} characters long."
	**/
	public var tooLongError(get, set):String;

	private function get_tooLongError():String {
		return _tooLongError;
	}

	private function set_tooLongError(value:String):String {
		tooLongErrorOverride = value;

		_tooLongError = (value != null && value.length > 0) ? value : TOO_LONG_ERROR;
		return _tooLongError;
	}

	//----------------------------------
	//  tooShortError
	//----------------------------------
	private var _tooShortError:String;

	private var tooShortErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the string is shorter than the `minLength` property.

		@default "This string is shorter than the minimum allowed length. This must be at least {0} characters long."
	**/
	public var tooShortError(get, set):String;

	private function get_tooShortError():String {
		return _tooShortError;
	}

	private function set_tooShortError(value:String):String {
		tooShortErrorOverride = value;

		_tooShortError = (value != null && value.length > 0) ? value : TOO_SHORT_ERROR;
		return _tooShortError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		maxLength = maxLengthOverride;
		minLength = minLengthOverride;

		tooLongError = tooLongErrorOverride;
		tooShortError = tooShortErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method to validate a String.

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
			return StringValidator.validateString(this, value, null);
		}
	}
}
