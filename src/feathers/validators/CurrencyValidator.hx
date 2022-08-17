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
	The CurrencyValidator class ensures that a String
	represents a valid currency expression.
	It can make sure the input falls within a given range
	(specified by `minValue` and `maxValue`),
	is non-negative (specified by `allowNegative`),
	and does not exceed the specified `precision`. The 
	CurrencyValidator class correctly validates formatted and unformatted
	currency expressions, e.g., "$12,345.00" and "12345".
	You can customize the `currencySymbol`, `alignSymbol`,
	`thousandsSeparator`, and `decimalSeparator`
	properties for internationalization.

	@see `mx.validators.CurrencyValidatorAlignSymbol`
**/
class CurrencyValidator extends Validator {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	private static final CURRENCY_SYMBOL_ERROR = "The currency symbol occurs in an invalid location.";
	private static final DECIMAL_POINT_COUNT_ERROR = "The decimal separator can occur only once.";
	private static final EXCEEDS_MAX_ERROR = "The amount entered is too large.";
	private static final LOWER_THAN_MIN_ERROR = "The amount entered is too small.";
	private static final NEGATIVE_ERROR = "The amount may not be negative.";
	private static final PRECISION_ERROR = "The amount entered has too many digits beyond the decimal point.";
	private static final INVALID_CHAR_ERROR = "The input contains invalid characters.";
	private static final INVALID_FORMAT_CHARS_ERROR = "One of the formatting parameters is invalid.";
	private static final SEPARATION_ERROR = "The thousands separator must be followed by three digits.";

	/**
		Formatting characters for negative values.
	**/
	private static final NEGATIVE_FORMATTING_CHARS:String = "-()";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The CurrencyValidator instance.

		@param value The object to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies value.currency,
		the baseField value is "currency".

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateCurrency(validator:CurrencyValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var alignSymbol:String = validator.alignSymbol;
		var allowNegative:Bool = validator.allowNegative;
		var currencySymbol:String = validator.currencySymbol;
		var decimalSeparator:String = validator.decimalSeparator;
		var maxValue:Float = validator.maxValue;
		var minValue:Float = validator.minValue;
		var precision:Int = validator.precision;
		var thousandsSeparator:String = validator.thousandsSeparator;

		var input:String = Std.string(value);
		var len:Int = input.length;

		var isNegative:Bool = false;
		var hasCurrencySymbol:Bool = false;

		var c:String;

		// Make sure the formatting character parameters are unique,
		// are not digits or negative formatting characters,
		// and that the separators are one character.
		var invalidFormChars:String = Validator.DECIMAL_DIGITS + NEGATIVE_FORMATTING_CHARS;

		if (currencySymbol == thousandsSeparator
			|| currencySymbol == decimalSeparator
			|| decimalSeparator == thousandsSeparator
			|| invalidFormChars.indexOf(currencySymbol) != -1
			|| invalidFormChars.indexOf(decimalSeparator) != -1
			|| invalidFormChars.indexOf(thousandsSeparator) != -1
			|| decimalSeparator.length != 1
			|| thousandsSeparator.length != 1) {
			results.push(new ValidationResult(true, baseField, "invalidFormatChar", validator.invalidFormatCharsError));
			return results;
		}

		// Check for invalid characters in input.
		var validChars:String = Validator.DECIMAL_DIGITS + NEGATIVE_FORMATTING_CHARS + currencySymbol + decimalSeparator + thousandsSeparator;
		for (i in 0...len) {
			c = input.charAt(i);

			if (validChars.indexOf(c) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
		}

		// Check if the input is negative.
		if (input.charAt(0) == "-") {
			if (len == 1) // we have only '-' char
			{
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}

			// Check if negative input is allowed.
			if (!allowNegative) {
				results.push(new ValidationResult(true, baseField, "negative", validator.negativeError));
				return results;
			}

			// Strip off the negative formatting and update some variables.
			input = input.substring(1);
			len--;
			isNegative = true;
		} else if (input.charAt(0) == "(") {
			// Make sure the last character is a closed parenthesis.
			if (input.charAt(len - 1) != ")") {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}

			// Check if negative input is allowed.
			if (!allowNegative) {
				results.push(new ValidationResult(true, baseField, "negative", validator.negativeError));
				return results;
			}

			// Strip off the negative formatting and update some variables.
			input = input.substring(1, len - 2);
			len -= 2;
			isNegative = true;
		}

		// Find the currency symbol if it exists,
		// then make sure that it's in the right place
		// and that there is only one.
		var currencySymbolLength = currencySymbol.length; // allows for symbols that use multiple chars, like the Brazilian "R$"
		hasCurrencySymbol = input.indexOf(currencySymbol) != -1;
		if (hasCurrencySymbol) {
			if (len == currencySymbolLength) { // we have only currency symbol
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
			if ((input.substr(0, currencySymbolLength) == currencySymbol && alignSymbol == CurrencyValidatorAlignSymbol.RIGHT)
				|| (input.substr(len - currencySymbolLength, currencySymbolLength) == currencySymbol
					&& alignSymbol == CurrencyValidatorAlignSymbol.LEFT)
				|| (len > (2 * currencySymbolLength)
					&& input.substring(currencySymbolLength, len - currencySymbolLength).indexOf(currencySymbol) != -1)
				|| (input.indexOf(currencySymbol) != input.lastIndexOf(currencySymbol))) {
				results.push(new ValidationResult(true, baseField, "currencySymbol", validator.currencySymbolError));
				return results;
			}
		}

		// Now that we know it's in the right place,
		// strip off the currency symbol if it exists.
		var currencySymbolIndex:Int = input.indexOf(currencySymbol);
		if (currencySymbolIndex != -1) {
			if (currencySymbolIndex > 0) // if it's at the end
			{
				input = input.substring(0, len - currencySymbolLength);
			} else // it's at the beginning
			{
				input = input.substring(currencySymbolLength);
			}
			len -= currencySymbolLength;
		}

		if (len == 1 && input.charAt(0) == decimalSeparator) // we have only decimal separator
		{
			results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
			return results;
		}

		// Make sure there is only one decimal point.
		if (input.indexOf(decimalSeparator) != input.lastIndexOf(decimalSeparator)) {
			results.push(new ValidationResult(true, baseField, "decimalPointCount", validator.decimalPointCountError));
			return results;
		}

		// Make sure that every character after the decimal point
		// is a digit and that the precision is not exceeded.
		var decimalSeparatorIndex:Int = input.indexOf(decimalSeparator);
		var numDigitsAfterDecimal:Int = 0;

		// If there is no decimal separator, act like there is one at the end.
		if (decimalSeparatorIndex == -1) {
			decimalSeparatorIndex = len;
		}

		for (i in (decimalSeparatorIndex + 1)...len) {
			if (Validator.DECIMAL_DIGITS.indexOf(input.charAt(i)) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}

			++numDigitsAfterDecimal;

			// Make sure precision is not exceeded.
			if (precision != -1 && numDigitsAfterDecimal > precision) {
				results.push(new ValidationResult(true, baseField, "precision", validator.precisionError));
				return results;
			}
		}

		// Make sure the input begins with a digit or a decimal point.
		if (Validator.DECIMAL_DIGITS.indexOf(input.charAt(0)) == -1 && input.charAt(0) != decimalSeparator) {
			results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
			return results;
		}

		// Make sure that every character before the decimal point
		// is a digit or is a thousands separator.
		// If it's a thousands separator, make sure it's followed
		// by three consecutive digits, and then make sure the next character
		// is valid (i.e., either thousands separator, decimal separator,
		// or nothing).
		var validGroupEnder:String = thousandsSeparator + decimalSeparator;
		for (i in 1...decimalSeparatorIndex) {
			c = input.charAt(i);

			if (c == thousandsSeparator) {
				if (input.substring(i + 1, i + 4).length < 3
					|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 1)) == -1
					|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 2)) == -1
					|| Validator.DECIMAL_DIGITS.indexOf(input.charAt(i + 3)) == -1
					|| validGroupEnder.indexOf(input.charAt(i + 4)) == -1) {
					results.push(new ValidationResult(true, baseField, "separation", validator.separationError));
					return results;
				}
			} else if (Validator.DECIMAL_DIGITS.indexOf(c) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
		}

		// Make sure the input is within the specified range.
		if (!Math.isNaN(minValue) || !Math.isNaN(maxValue)) {
			// First strip off the thousands separators.
			for (i in 0...decimalSeparatorIndex) {
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

			if (isNegative) {
				x = -x;
			}

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
	//  alignSymbol
	//----------------------------------
	private var _alignSymbol:String = CurrencyValidatorAlignSymbol.LEFT;

	private var alignSymbolOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Specifies the alignment of the `currencySymbol`
		relative to the rest of the expression.
		Acceptable values in Haxe are `CurrencyValidatorAlignSymbol.LEFT`, 
		`CurrencyValidatorAlignSymbol.RIGHT`, and 
		`CurrencyValidatorAlignSymbol.ANY`.
		 
		@default CurrencyValidatorAlignSymbol.LEFT

		@see `mx.validators.CurrencyValidatorAlignSymbol`
	**/
	public var alignSymbol(get, set):String;

	private function get_alignSymbol():String {
		return _alignSymbol;
	}

	private function set_alignSymbol(value:String):String {
		alignSymbolOverride = value;

		_alignSymbol = value != null ? value : CurrencyValidatorAlignSymbol.LEFT;
		return _alignSymbol;
	}

	//----------------------------------
	//  allowNegative
	//----------------------------------
	private var _allowNegative:Bool;

	private var allowNegativeOverride:Bool = true;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Specifies whether negative numbers are permitted.
		Can be `true` or `false`.

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
	//  currencySymbol
	//----------------------------------
	private var _currencySymbol:String;

	private var currencySymbolOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The character String used to specify the currency symbol, 
		such as "$", "R$", or "&#163;".
		Cannot be a digit and must be distinct from the
		`thousandsSeparator` and the `decimalSeparator`.

		@default "$"
	**/
	public var currencySymbol(get, set):String;

	private function get_currencySymbol():String {
		return _currencySymbol;
	}

	private function set_currencySymbol(value:String):String {
		currencySymbolOverride = value;

		_currencySymbol = value != null ? value : "$";
		return _currencySymbol;
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
		`currencySymbol` and the `thousandsSeparator`.

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
	//  maxValue
	//----------------------------------
	private var _maxValue:Float = Math.NaN;

	private var maxValueOverride:Float = Math.NaN;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		Maximum value for a valid number.
		A value of `Math.NaN` means it is ignored.

		@default Math.NaN
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
		Minimum value for a valid number.
		A value of `Math.NaN` means it is ignored.

		@default Math.NaN
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
	private var _precision:Int;

	private var precisionOverride:Int = 2;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The maximum number of digits allowed to follow the decimal point.
		Can be any non-negative integer.
		Note: Setting to `0`
		has the same effect as setting `NumberValidator.domain`
		to `int`.
		Setting it to -1, means it is ignored.

		@default 2
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
	private var _thousandsSeparator:String;

	private var thousandsSeparatorOverride:String;

	// [Inspectable(category="General", defaultValue=",")]

	/**
		The character used to separate thousands.
		Cannot be a digit and must be distinct from the
		`currencySymbol` and the `decimalSeparator`.

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
	//  currencySymbolError
	//----------------------------------
	private var _currencySymbolError:String;

	private var currencySymbolErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the currency symbol, defined by `currencySymbol`,
		is in the wrong location.

		@default "The currency symbol occurs in an invalid location."
	**/
	public var currencySymbolError(get, set):String;

	private function get_currencySymbolError():String {
		return _currencySymbolError;
	}

	private function set_currencySymbolError(value:String):String {
		currencySymbolErrorOverride = value;

		_currencySymbolError = value != null ? value : CURRENCY_SYMBOL_ERROR;
		return _currencySymbolError;
	}

	//----------------------------------
	//  decimalPointCountError
	//----------------------------------
	private var _decimalPointCountError:String;

	private var decimalPointCountErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the decimal separator character occurs more than once.

		@default "The decimal separator can only occur once."
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
	private var _exceedsMaxError:String;

	private var exceedsMaxErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value is greater than `maxValue`.

		@default "The amount entered is too large."
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
	//  invalidCharError
	//----------------------------------
	private var _invalidCharError:String;

	private var invalidCharErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the currency contains invalid characters.

		@default "The input contains invalid characters."
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
	private var _invalidFormatCharsError:String;

	private var invalidFormatCharsErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value contains an invalid formatting character.

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
	private var _lowerThanMinError:String;

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
	private var _negativeError:String;

	private var negativeErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value is negative and
		the `allowNegative` property is `false`.

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
	private var _precisionError:String;

	private var precisionErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the value has a precision that exceeds the value
		defined by the `precision` property.

		@default "The amount entered has too many digits beyond 
		the decimal point."
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
	private var _separationError:String;

	private var separationErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the thousands separator is incorrectly placed.

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

		alignSymbol = alignSymbolOverride;
		allowNegative = allowNegativeOverride;
		currencySymbol = currencySymbolOverride;
		decimalSeparator = decimalSeparatorOverride;
		maxValue = maxValueOverride;
		minValue = minValueOverride;
		precision = precisionOverride;
		thousandsSeparator = thousandsSeparatorOverride;

		currencySymbolError = currencySymbolErrorOverride;
		decimalPointCountError = decimalPointCountErrorOverride;
		exceedsMaxError = exceedsMaxErrorOverride;
		invalidCharError = invalidCharErrorOverride;
		invalidFormatCharsError = invalidFormatCharsErrorOverride;
		lowerThanMinError = lowerThanMinErrorOverride;
		negativeError = negativeErrorOverride;
		precisionError = precisionErrorOverride;
		separationError = separationErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a currency expression.

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
			return CurrencyValidator.validateCurrency(this, value, null);
		}
	}
}
