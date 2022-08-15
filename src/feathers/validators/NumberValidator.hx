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

/**
	The NumberValidator class ensures that a String represents a valid number.
	It can ensure that the input falls within a given range
	(specified by `minValue` and `maxValue`),
	is an integer (specified by `domain`),
	is non-negative (specified by `allowNegative`),
	and does not exceed the specified `precision`.
	The validator correctly validates formatted numbers (e.g., "12,345.67")
	and you can customize the `thousandsSeparator` and
	`decimalSeparator` properties for internationalization.
**/
class NumberValidator extends Validator {
	private static final DECIMAL_POINT_COUNT_ERROR = "The decimal separator can occur only once.";
	private static final EXCEEDS_MAX_ERROR = "The number entered is too large.";
	private static final INTEGER_ERROR = "The number must be an integer.";
	private static final INVALID_CHAR_ERROR = "The input contains invalid characters.";
	private static final INVALID_FORMAT_CHARS_ERROR = "One of the formatting parameters is invalid.";
	private static final LOWER_THAN_MIN_ERROR = "The amount entered is too small.";
	private static final NEGATIVE_ERROR = "The amount may not be negative.";
	private static final PRECISION_ERROR = "The amount entered has too many digits beyond the decimal point.";
	private static final SEPARATION_ERROR = "The thousands separator must be followed by three digits.";

	/**
		Convenience method for calling a validator
		from within a custom validation function.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The NumberValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies value.number,
		the `baseField` value is "number".

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateNumber(validator:NumberValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowNegative:Bool = validator.allowNegative;
		var decimalSeparator:String = validator.decimalSeparator;
		var domain:String = validator.domain;
		var maxValue:Float = validator.maxValue;
		var minValue:Float = validator.minValue;
		var precision:Int = validator.precision;
		var thousandsSeparator:String = validator.thousandsSeparator;
		var input:String = Std.string(value);
		var len:Int = input.length;
		var isNegative:Bool = false;
		var c:String;
		var isNumber:Bool = (value is Float);

		// Make sure the formatting character parameters are unique,
		// are not digits or the negative sign,
		// and that the separators are one character.
		var invalidFormChars:String = Validator.DECIMAL_DIGITS + "-";

		if (decimalSeparator == thousandsSeparator
			|| invalidFormChars.indexOf(decimalSeparator) != -1
			|| invalidFormChars.indexOf(thousandsSeparator) != -1
			|| decimalSeparator.length != 1
			|| thousandsSeparator.length != 1) {
			results.push(new ValidationResult(true, baseField, "invalidFormatChar", validator.invalidFormatCharsError));
			return results;
		}

		// Check for invalid characters in input.
		var validChars:String = Validator.DECIMAL_DIGITS + "-" + decimalSeparator + thousandsSeparator;
		var i = 0;
		while (i < len) {
			c = input.charAt(i);
			if (validChars.indexOf(c) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
			i++;
		}

		// Check if the input is negative.
		if (input.charAt(0) == "-") {
			if (len == 1) // we have only '-' char
			{
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			} else if (len == 2 && input.charAt(1) == '.') // handle "-."
			{
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}

			// Check if negative input is allowed.
			if (!allowNegative) {
				results.push(new ValidationResult(true, baseField, "negative", validator.negativeError));
				return results;
			}

			// Strip off the minus sign, update some variables.
			input = input.substring(1);
			len--;
			isNegative = true;
		}

		// Make sure there's only one decimal point.
		if (input.indexOf(decimalSeparator) != input.lastIndexOf(decimalSeparator)) {
			results.push(new ValidationResult(true, baseField, "decimalPointCount", validator.decimalPointCountError));
			return results;
		}

		// Make sure every character after the decimal is a digit,
		// and that there aren't too many digits after the decimal point:
		// if domain is int there should be none,
		// otherwise there should be no more than specified by precision.
		var decimalSeparatorIndex:Int = input.indexOf(decimalSeparator);
		if (decimalSeparatorIndex != -1) {
			var numDigitsAfterDecimal:Float = 0;

			if (i == 1 && i == len) // we only have a '.'
			{
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}

			for (i in (decimalSeparatorIndex + 1)...len) {
				// This character must be a digit.
				if (Validator.DECIMAL_DIGITS.indexOf(input.charAt(i)) == -1) {
					results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
					return results;
				}

				++numDigitsAfterDecimal;

				// There may not be any non-zero digits after the decimal
				// if domain is int.
				if (domain == NumberValidatorDomainType.INT && input.charAt(i) != "0") {
					results.push(new ValidationResult(true, baseField, "integer", validator.integerError));
					return results;
				}

				// Make sure precision is not exceeded.
				if (precision != -1 && numDigitsAfterDecimal > precision) {
					results.push(new ValidationResult(true, baseField, "precision", validator.precisionError));
					return results;
				}
			}
		}

		// Make sure the input begins with a digit or a decimal point.
		if (Validator.DECIMAL_DIGITS.indexOf(input.charAt(0)) == -1 && input.charAt(0) != decimalSeparator) {
			results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
			return results;
		}

		// Make sure that every character before the decimal point
		// is a digit or is a thousands separator.
		// If it's a thousands separator,
		// make sure it's followed by three consecutive digits.
		var end:Int = decimalSeparatorIndex == -1 ? len : decimalSeparatorIndex;
		if (!isNumber) {
			for (i in 1...end) {
				c = input.charAt(i);
				if (c == thousandsSeparator) {
					if (c == thousandsSeparator) {
						if ((end - i != 4 && input.charAt(i + 4) != thousandsSeparator)
							|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 1)) == -1
							|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 2)) == -1
							|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 3)) == -1) {
							results.push(new ValidationResult(true, baseField, "separation", validator.separationError));
							return results;
						}
					}
				} else if (Validator.DECIMAL_DIGITS.indexOf(c) == -1) {
					results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
					return results;
				}
			}
		}

		// Make sure the input is within the specified range.
		if (!Math.isNaN(minValue) || !Math.isNaN(maxValue)) {
			// First strip off the thousands separators.
			for (i in 0...end) {
				if (input.charAt(i) == thousandsSeparator) {
					var left:String = input.substring(0, i);
					var right:String = input.substring(i + 1);
					input = left + right;
				}
			}

			// Translate the value back into standard english
			// If the decimalSeperator is not '.' we need to change it to '.'
			// so that the number casting will work properly
			if (validator.decimalSeparator != '.') {
				var dIndex:Int = input.indexOf(validator.decimalSeparator);
				if (dIndex != -1) {
					var dLeft:String = input.substring(0, dIndex);
					var dRight:String = input.substring(dIndex + 1);
					input = dLeft + '.' + dRight;
				}
			}

			// Check bounds

			var x:Float = Std.parseFloat(input);

			if (isNegative)
				x = -x;

			if (!Math.isNaN(minValue) && x < minValue) {
				results.push(new ValidationResult(true, baseField, "lowerThanMin", validator.lowerThanMinError));
				return results;
			}

			if (!Math.isNaN(maxValue) && x > maxValue) {
				results.push(new ValidationResult(true, baseField, "exceedsMax", validator.exceedsMaxError));
				return results;
			}
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
	//  allowNegative
	//----------------------------------
	private var _allowNegative:Dynamic;

	private var allowNegativeOverride:Bool = true;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Specifies whether negative numbers are permitted.
		Valid values are `true` or `false`.

		@default true
	**/
	public var allowNegative(get, set):Bool;

	private function get_allowNegative():Bool {
		return _allowNegative;
	}

	private function set_allowNegative(value:Bool):Bool {
		allowNegativeOverride = value;

		_allowNegative = value;
		return _allowNegative;
	}

	//----------------------------------
	//  decimalSeparator
	//----------------------------------
	private var _decimalSeparator:String;

	private var decimalSeparatorOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The character used to separate the whole
		from the fractional part of the number.
		Cannot be a digit and must be distinct from the
		`thousandsSeparator`.

		@default "."
	**/
	public var decimalSeparator(get, set):String;

	private function get_decimalSeparator():String {
		return _decimalSeparator;
	}

	private function set_decimalSeparator(value:String):String {
		decimalSeparatorOverride = value;

		_decimalSeparator = value != null ? value : ".";
		return _decimalSeparator;
	}

	//----------------------------------
	//  domain
	//----------------------------------
	private var _domain:String = NumberValidatorDomainType.REAL;

	private var domainOverride:String = NumberValidatorDomainType.REAL;

	// [Inspectable(category="General", enumeration="int,real", defaultValue="null")]

	/**
		Type of number to be validated.
		Permitted values are `"real"` and `"int"`.

		In ActionScript, you can use the following constants to set this property: 
		`NumberValidatorDomainType.REAL` or
		`NumberValidatorDomainType.INT`.

		@default "real"
	**/
	public var domain(get, set):String;

	private function get_domain():String {
		return _domain;
	}

	private function set_domain(value:String):String {
		domainOverride = value;

		_domain = value != null ? value : NumberValidatorDomainType.REAL;
		return _domain;
	}

	//----------------------------------
	//  maxValue
	//----------------------------------
	private var _maxValue:Float = Math.NaN;

	private var maxValueOverride:Float = Math.NaN;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Maximum value for a valid number. A value of NaN means there is no maximum.

		@default NaN
	**/
	public var maxValue(get, set):Float;

	private function get_maxValue():Float {
		return _maxValue;
	}

	private function set_maxValue(value:Float):Float {
		maxValueOverride = value;

		_maxValue = value;
		return _maxValue;
	}

	//----------------------------------
	//  minValue
	//----------------------------------
	private var _minValue:Float = Math.NaN;

	private var minValueOverride:Float = Math.NaN;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Minimum value for a valid number. A value of NaN means there is no minimum.

		@default NaN
	**/
	public var minValue(get, set):Float;

	private function get_minValue():Float {
		return _minValue;
	}

	private function set_minValue(value:Float):Float {
		minValueOverride = value;

		_minValue = value;
		return _minValue;
	}

	//----------------------------------
	//  precision
	//----------------------------------
	private var _precision:Int = -1;

	private var precisionOverride:Int = -1;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The maximum number of digits allowed to follow the decimal point.
		Can be any nonnegative integer. 
		Note: Setting to `0` has the same effect
		as setting `domain` to `"int"`.
		A value of -1 means it is ignored.

		@default -1
	**/
	public var precision(get, set):Int;

	private function get_precision():Int {
		return _precision;
	}

	private function set_precision(value:Int):Int {
		precisionOverride = value;

		_precision = value;
		return _precision;
	}

	//----------------------------------
	//  thousandsSeparator
	//----------------------------------
	private var _thousandsSeparator:String = ",";

	private var thousandsSeparatorOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The character used to separate thousands
		in the whole part of the number.
		Cannot be a digit and must be distinct from the
		`decimalSeparator`.

		@default ","
	**/
	public var thousandsSeparator(get, set):String;

	private function get_thousandsSeparator():String {
		return _thousandsSeparator;
	}

	private function set_thousandsSeparator(value:String):String {
		thousandsSeparatorOverride = value;

		_thousandsSeparator = value != null ? value : ",";
		return _thousandsSeparator;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  decimalPointCountError
	//----------------------------------
	private var _decimalPointCountError:String = DECIMAL_POINT_COUNT_ERROR;

	private var decimalPointCountErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the decimal separator character occurs more than once.

		@default "The decimal separator can occur only once."
	**/
	public var decimalPointCountError(get, set):String;

	private function get_decimalPointCountError():String {
		return _decimalPointCountError;
	}

	private function set_decimalPointCountError(value:String):String {
		decimalPointCountErrorOverride = value;

		_decimalPointCountError = value != null ? value : DECIMAL_POINT_COUNT_ERROR;
		return _decimalPointCountError;
	}

	//----------------------------------
	//  exceedsMaxError
	//----------------------------------
	private var _exceedsMaxError:String = EXCEEDS_MAX_ERROR;

	private var exceedsMaxErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value exceeds the `maxValue` property.

		@default "The number entered is too large."
	**/
	public var exceedsMaxError(get, set):String;

	private function get_exceedsMaxError():String {
		return _exceedsMaxError;
	}

	private function set_exceedsMaxError(value:String):String {
		exceedsMaxErrorOverride = value;

		_exceedsMaxError = value != null ? value : EXCEEDS_MAX_ERROR;
		return _exceedsMaxError;
	}

	//----------------------------------
	//  integerError
	//----------------------------------
	private var _integerError:String = INTEGER_ERROR;

	private var integerErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the number must be an integer, as defined 
		by the `domain` property.

		@default "The number must be an integer."
	**/
	public var integerError(get, set):String;

	private function get_integerError():String {
		return _integerError;
	}

	private function set_integerError(value:String):String {
		integerErrorOverride = value;

		_integerError = value != null ? value : INTEGER_ERROR;
		return _integerError;
	}

	//----------------------------------
	//  invalidCharError
	//----------------------------------
	private var _invalidCharError:String = INVALID_CHAR_ERROR;

	private var invalidCharErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value contains invalid characters.

		@default The input contains invalid characters."
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
	//  invalidFormatCharsError
	//----------------------------------
	private var _invalidFormatCharsError:String = INVALID_FORMAT_CHARS_ERROR;

	private var invalidFormatCharsErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value contains invalid format characters, which means that 
		it contains a digit or minus sign (-) as a separator character, 
		or it contains two or more consecutive separator characters.

		@default "One of the formatting parameters is invalid."
	**/
	public var invalidFormatCharsError(get, set):String;

	private function get_invalidFormatCharsError():String {
		return _invalidFormatCharsError;
	}

	private function set_invalidFormatCharsError(value:String):String {
		invalidFormatCharsErrorOverride = value;

		_invalidFormatCharsError = value != null ? value : INVALID_FORMAT_CHARS_ERROR;
		return _invalidFormatCharsError;
	}

	//----------------------------------
	//  lowerThanMinError
	//----------------------------------
	private var _lowerThanMinError:String = LOWER_THAN_MIN_ERROR;

	private var lowerThanMinErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value is less than `minValue`.

		@default "The amount entered is too small."
	**/
	public var lowerThanMinError(get, set):String;

	private function get_lowerThanMinError():String {
		return _lowerThanMinError;
	}

	private function set_lowerThanMinError(value:String):String {
		lowerThanMinErrorOverride = value;

		_lowerThanMinError = value != null ? value : LOWER_THAN_MIN_ERROR;
		return _lowerThanMinError;
	}

	//----------------------------------
	//  negativeError
	//----------------------------------
	private var _negativeError:String = NEGATIVE_ERROR;

	private var negativeErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value is negative and the 
		`allowNegative` property is `false`.

		@default "The amount may not be negative."
	**/
	public var negativeError(get, set):String;

	private function get_negativeError():String {
		return _negativeError;
	}

	private function set_negativeError(value:String):String {
		negativeErrorOverride = value;

		_negativeError = value != null ? value : NEGATIVE_ERROR;
		return _negativeError;
	}

	//----------------------------------
	//  precisionError
	//----------------------------------
	private var _precisionError:String = PRECISION_ERROR;

	private var precisionErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value has a precision that exceeds the value defined 
		by the precision property.

		@default "The amount entered has too many digits beyond the decimal point."
	**/
	public var precisionError(get, set):String;

	private function get_precisionError():String {
		return _precisionError;
	}

	private function set_precisionError(value:String):String {
		precisionErrorOverride = value;

		_precisionError = value != null ? value : PRECISION_ERROR;
		return _precisionError;
	}

	//----------------------------------
	//  separationError
	//----------------------------------
	private var _separationError:String = SEPARATION_ERROR;

	private var separationErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the thousands separator is in the wrong location.

		@default "The thousands separator must be followed by three digits."
	**/
	public var separationError(get, set):String;

	private function get_separationError():String {
		return _separationError;
	}

	private function set_separationError(value:String):String {
		separationErrorOverride = value;

		_separationError = value != null ? value : SEPARATION_ERROR;
		return _separationError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowNegative = allowNegativeOverride;
		decimalSeparator = decimalSeparatorOverride;
		domain = domainOverride;
		maxValue = maxValueOverride;
		minValue = minValueOverride;
		precision = precisionOverride;
		thousandsSeparator = thousandsSeparatorOverride;

		decimalPointCountError = decimalPointCountErrorOverride;
		exceedsMaxError = exceedsMaxErrorOverride;
		integerError = integerErrorOverride;
		invalidCharError = invalidCharErrorOverride;
		invalidFormatCharsError = invalidFormatCharsErrorOverride;
		lowerThanMinError = lowerThanMinErrorOverride;
		negativeError = negativeErrorOverride;
		precisionError = precisionErrorOverride;
		separationError = separationErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method 
		to validate a number.

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
			return NumberValidator.validateNumber(this, value, null);
		}
	}
}
