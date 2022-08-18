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
	The DateValidator class validates that a String, Date, or Object contains a 
	proper date and matches a specified format. Users can enter a single 
	digit or two digits for month, day, and year. 
	By default, the validator ensures the following formats:

	- The month is between 1 and 12 (or 0-11 for `Date` objects)
	- The day is between 1 and 31
	- The year is a number

	You can specify the date in the DateValidator class in two ways:

	- A single `String` containing the date - Use the `source`
		and `property` properties to specify the String.
		The String can contain digits and the formatting characters
		specified by the `allowedFormatChars` property,
		which include the "/\-. " characters. 
		By default, the input format of the date in a String field
		is "MM/DD/YYYY" where "MM" is the month, "DD" is the day,
		and "YYYY" is the year. 
		You can use the `inputFormat` property
		to specify a different format.
	- A `Date` object.
	- An anonymous structure or multiple fields containing the day, month, and
		year.  Use all of the following properties to specify the day, month,
		and year inputs: `daySource`, `dayProperty`, `monthSource`,
		`monthProperty`, `yearSource`, and `yearProperty`.
**/
class DateValidator extends Validator {
	private static final INVALID_FORMAT_CHARS_ERROR = "The allowedFormatChars parameter is invalid. It cannot contain any digits.";
	private static final DS_ATTRIBUTE_ERROR = "The daySource attribute, '{0}', can not be of type String.";
	private static final MS_ATTRIBUTE_ERROR = "The monthSource attribute, '{0}', can not be of type String.";
	private static final YS_ATTRIBUTE_ERROR = "The yearSource attribute, '{0}', can not be of type String.";
	private static final FORMAT_ERROR = "Configuration error: Incorrect formatting string.";
	private static final INVALID_CHAR_ERROR = "The date contains invalid characters.";
	private static final WRONG_DAY_ERROR = "Enter a valid day for the month.";
	private static final WRONG_MONTH_ERROR = "Enter a month between 1 and 12.";
	private static final WRONG_YEAR_ERROR = "Enter a year between 0 and 9999.";
	private static final WRONG_LENGTH_ERROR = "Type the date in the format.";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator
		from within a custom validation function.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The DateValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the value parameter. 
		For example, if the `value` parameter
		specifies value.date, the `baseField` value is "date".

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateDate(validator:DateValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;
		var inputFormat:String = validator.inputFormat;
		var validateAsString:Bool = validator.validateAsString;
		var includeFormatInError:Bool = validator.includeFormatInError;

		var validInput:String = Validator.DECIMAL_DIGITS + allowedFormatChars;

		var dateObj:Dynamic = {day: "", month: "", year: ""};

		var dayProp:String = baseField;
		var monthProp:String = baseField;
		var yearProp:String = baseField;

		var dateParts:Array<String> = [];
		var formatParts:Array<String> = [];

		var dayPart:String = "";
		var monthPart:String = "";
		var yearPart:String = "";

		var monthRequired:Bool = false;
		var dayRequired:Bool = false;
		var yearRequired:Bool = false;
		var valueIsString:Bool = false;

		var objValue:Dynamic = null;
		var stringValue:Dynamic = null;

		var n:Int;
		var temp:String;
		var formatChar:String;

		var part:Int = -1;
		var lastFormatChar:String = "";
		var noSeperators:Bool = true;

		n = inputFormat.length;
		for (i in 0...n) {
			formatChar = inputFormat.charAt(i);

			if (lastFormatChar != formatChar) {
				part++;
				formatParts[part] = "";
			}

			if (formatChar == "D" || formatChar == "d") {
				dayRequired = true;
				formatParts[part] += "D";
			} else if (formatChar == "M" || formatChar == "m") {
				monthRequired = true;
				formatParts[part] += "M";
			} else if (formatChar == "Y" || formatChar == "y") {
				yearRequired = true;
				formatParts[part] += "Y";
			} else if (allowedFormatChars.indexOf(formatChar) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			} else {
				noSeperators = false;
				formatParts[part] += formatChar;
			}

			lastFormatChar = formatChar;
		}

		if ((value is String)) {
			valueIsString = true;
			stringValue = (value : String);
		} else if ((value is Float)) {
			valueIsString = true;
			stringValue = Std.string(value);
		} else if ((value is Date)) {
			var date:Date = (value : Date);
			objValue = {
				year: date.getFullYear(),
				month: date.getMonth() + 1,
				day: date.getDate()
			};
		} else {
			objValue = value;
		}

		// Check if the validator is an object or a string.
		if (!validateAsString || !valueIsString) {
			var baseFieldDot:String = (baseField != null) ? baseField + "." : "";
			dayProp = baseFieldDot + "day";
			yearProp = baseFieldDot + "year";
			monthProp = baseFieldDot + "month";

			if (validator.required && (!objValue.month || objValue.month == "")) {
				results.push(new ValidationResult(true, monthProp, "requiredField", validator.requiredFieldError));
			} else if (Math.isNaN(objValue.month)) {
				results.push(new ValidationResult(true, monthProp, "wrongMonth", validator.wrongMonthError));
			} else {
				monthRequired = true;
			}

			if (validator.required && (!objValue.year || objValue.year == "")) {
				results.push(new ValidationResult(true, yearProp, "requiredField", validator.requiredFieldError));
			} else if (Math.isNaN(objValue.year)) {
				results.push(new ValidationResult(true, yearProp, "wrongYear", validator.wrongYearError));
			} else {
				yearRequired = true;
			}

			var dayMissing:Bool = (!objValue.day || objValue.day == "");
			var dayInvalid:Bool = dayMissing || Math.isNaN(objValue.day);
			var dayWrong:Bool = !dayMissing && Math.isNaN(objValue.day);
			var dayOptional:Bool = yearRequired && monthRequired;

			// If the validator is required and there is no day specified
			if (validator.required && dayMissing) {
				results.push(new ValidationResult(true, dayProp, "requiredField", validator.requiredFieldError));
			} else if (!dayInvalid) // The day is valid (a number).
			{
				dayRequired = true;
			} else if (!dayOptional || dayWrong) // Day is not optional and is NaN.
			{
				results.push(new ValidationResult(true, dayProp, "wrongDay", validator.wrongDayError));
			}

			dateObj.month = objValue.month != null ? Std.string(objValue.month) : "";
			dateObj.day = objValue.day != null ? Std.string(objValue.day) : "";
			dateObj.year = objValue.year != null ? Std.string(objValue.year) : "";
		} else {
			var result:ValidationResult = DateValidator.validateFormatString(validator, inputFormat, baseField);
			if (result != null) {
				results.push(result);
				return results;
			} else {
				var lastStringChar:String = "";
				lastFormatChar = "";
				n = stringValue.length;
				part = -1;
				for (i in 0...n) {
					var stringChar:String = stringValue.charAt(i);
					var lastIsDigit:Bool = (Validator.DECIMAL_DIGITS.indexOf(lastStringChar) >= 0) && (lastStringChar != "");
					var curentIsDigit:Bool = (Validator.DECIMAL_DIGITS.indexOf(stringChar) >= 0);

					formatChar = inputFormat.charAt(i);
					if (validInput.indexOf(stringChar) == -1) {
						results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
						return results;
					} else if (lastIsDigit != curentIsDigit) {
						part++;
						dateParts[part] = stringChar;
					}
					//  TODO will only work if month and day are not specified as single digits
					else if (lastFormatChar != formatChar && noSeperators) {
						part++;
						dateParts[part] = stringChar;
					} else {
						dateParts[part] += stringChar;
					}

					lastStringChar = stringChar;
					lastFormatChar = formatChar;
				}

				if (formatParts.length != dateParts.length) {
					results.push(new ValidationResult(true, baseField, "wrongLength",
						validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
					return results;
				}

				n = formatParts.length;
				for (j in 0...n) {
					var mask:String = formatParts[j].charAt(0);

					if (mask == "D") {
						dateObj.day = dateParts[j];
						dayPart = formatParts[j];
					} else if (mask == "M") {
						dateObj.month = dateParts[j];
						monthPart = formatParts[j];
					} else if (mask == "Y") {
						dateObj.year = dateParts[j];
						yearPart = formatParts[j];
					} else if (!noSeperators) {
						// separator part, we have valid separator characters just validate against
						// repeating separator values, validate now as we could have multiple separators
						if (dateParts[j].length != formatParts[j].length) {
							results.push(new ValidationResult(true, baseField, "wrongLength",
								validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
							return results;
						}
					}
				}

				// DD or D format
				if ((dayRequired && dayPart.length == 2 && dateObj.day.length != 2)
					|| (dayRequired && dayPart.length == 1 && dateObj.day.length > 2)) {
					results.push(new ValidationResult(true, baseField, "wrongLength",
						validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
					return results;
				}
				// MM or M format
				if ((monthRequired && monthPart.length == 2 && dateObj.month.length != 2)
					|| (monthRequired && monthPart.length == 1 && dateObj.month.length > 2)) {
					results.push(new ValidationResult(true, baseField, "wrongLength",
						validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
					return results;
				}
				// YY or YYYY format
				if ((yearRequired && yearPart.length == 2 && dateObj.year.length != 2)
					|| (yearRequired && yearPart.length == 4 && dateObj.year.length != 4)) {
					results.push(new ValidationResult(true, baseField, "wrongLength",
						validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
					return results;
				}

				if ((monthRequired && dateObj.month == "") || (dayRequired && dateObj.day == "") || (yearRequired && dateObj.year == "")) {
					results.push(new ValidationResult(true, baseField, "wrongLength",
						validator.wrongLengthError + (includeFormatInError ? " " + inputFormat : "")));
					return results;
				}
			}
		}

		if (results.length > 0) {
			return results;
		}

		var monthNum:Float = Std.parseFloat(Std.string(dateObj.month));
		var dayNum:Float = Std.parseFloat(Std.string(dateObj.day));
		var yearNum:Float = Std.parseFloat(Std.string(dateObj.year));

		if (monthNum > 12 || monthNum < 1) {
			results.push(new ValidationResult(true, monthProp, "wrongMonth", validator.wrongMonthError));
			return results;
		}

		var maxDay:Float = 31;

		if (monthNum == 4 || monthNum == 6 || monthNum == 9 || monthNum == 11) {
			maxDay = 30;
		} else if (monthNum == 2) {
			if (yearNum % 4 > 0) {
				maxDay = 28;
			} else if (yearNum % 100 == 0 && yearNum % 400 > 0) {
				maxDay = 28;
			} else {
				maxDay = 29;
			}
		}

		if (dayRequired && (dayNum > maxDay || dayNum < 1)) {
			results.push(new ValidationResult(true, dayProp, "wrongDay", validator.wrongDayError));
			return results;
		}

		if (yearRequired && (yearNum > 9999 || yearNum < 0)) {
			results.push(new ValidationResult(true, yearProp, "wrongYear", validator.wrongYearError));
			return results;
		}

		return results;
	}

	private static function validateFormatString(validator:DateValidator, format:String, baseField:String):ValidationResult {
		var monthCounter:Float = 0;
		var dayCounter:Float = 0;
		var yearCounter:Float = 0;

		var n:Int = format.length;
		for (i in 0...n) {
			var mask:String = "" + format.substring(i, i + 1);

			// Check for upper and lower case to maintain backwards compatibility.
			if (mask == "m" || mask == "M") {
				monthCounter++;
			} else if (mask == "d" || mask == "D") {
				dayCounter++;
			} else if (mask == "y" || mask == "Y") {
				yearCounter++;
			}
		}

		if ((monthCounter >= 1 && monthCounter <= 2 && (yearCounter == 2 || yearCounter == 4) && dayCounter == 0)
			|| (monthCounter >= 1
				&& monthCounter <= 2
				&& dayCounter >= 1
				&& dayCounter <= 2
				&& (yearCounter == 0 || yearCounter == 2 || yearCounter == 4))) {
			return null; // Passes format validation
		} else {
			return new ValidationResult(true, baseField, "format", validator.formatError);
		}
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

		subFields = ["day", "month", "year"];
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
		for the day, month and year subfields.
	**/
	override private function get_actualListeners():Array<Dynamic> {
		var results:Array<Dynamic> = [];

		var dayResult:Dynamic = null;
		if (_dayListener != null) {
			dayResult = _dayListener;
		} else if (_daySource != null) {
			dayResult = _daySource;
		}

		if (dayResult != null) {
			results.push(dayResult);
			if ((dayResult is IValidatorListener)) {
				cast(dayResult, IValidatorListener).validationSubField = "day";
			}
		}

		var monthResult:Dynamic = null;
		if (_monthListener != null) {
			monthResult = _monthListener;
		} else if (_monthSource != null) {
			monthResult = _monthSource;
		}

		if (monthResult != null) {
			results.push(monthResult);
			if ((monthResult is IValidatorListener)) {
				cast(monthResult, IValidatorListener).validationSubField = "month";
			}
		}

		var yearResult:Dynamic = null;
		if (_yearListener != null) {
			yearResult = _yearListener;
		} else if (_yearSource != null) {
			yearResult = _yearSource;
		}

		if (yearResult != null) {
			results.push(yearResult);
			if ((yearResult is IValidatorListener)) {
				cast(yearResult, IValidatorListener).validationSubField = "year";
			}
		}

		if (results.length > 0 && listener != null) {
			results.push(listener);
		} else {
			results = results.concat(super.get_actualListeners());
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
		The set of formatting characters allowed for separating
		the month, day, and year values.

		@default "/\-. "
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

		_allowedFormatChars = value != null ? value : "/- \\.";
		return _allowedFormatChars;
	}

	//----------------------------------
	//  dayListener
	//----------------------------------
	private var _dayListener:IValidatorListener;

	// [Inspectable(category="General")]

	/** 
		The component that listens for the validation result
		for the day subfield.
		If none is specified, use the value specified
		for the `daySource` property.
	**/
	public var dayListener(get, set):IValidatorListener;

	private function get_dayListener():IValidatorListener {
		return _dayListener;
	}

	private function set_dayListener(value:IValidatorListener):IValidatorListener {
		if (_dayListener == value)
			return _dayListener;

		removeListenerHandler();

		_dayListener = value;

		addListenerHandler();
		return _dayListener;
	}

	//----------------------------------
	//  dayProperty
	//----------------------------------
	// [Inspectable(category="General")]

	/**
		Name of the day property to validate. This property is optional, but
		if you specify the `daySource` property, you should specify either
		`dayProperty` or `dayValueFunction` as well.

		@see `dayValueFunction`
	 */
	public var dayProperty:String;

	/**
		A function that returns the day value to validate. It's recommended to
		use `dayValueFunction` instead of `dayProperty` because reflection is
		used with `dayProperty`, which could result in issues if Dead Code
		Elimination (DCE) is enabled.
	**/
	public var dayValueFunction:() -> Dynamic;

	//----------------------------------
	//  daySource
	//----------------------------------
	private var _daySource:Dynamic;

	// [Inspectable(category="General")]

	/** 
		Object that contains the value of the day field.
		If you specify a value for this property, you must also
		specify a value for either the `dayProperty` property or the
		`dayValueFunction` property. 
		Do not use this property if you set the `source` 
		and `property` (or `valueFunction`) properties.

		@see `dayProperty`
		@see `dayValueFunction`
	**/
	public var daySource(get, set):Dynamic;

	private function get_daySource():Dynamic {
		return _daySource;
	}

	private function set_daySource(value:Dynamic):Dynamic {
		if (_daySource == value)
			return _daySource;

		if ((value is String)) {
			var message:String = ValidatorStringUtil.substitute(DS_ATTRIBUTE_ERROR, value);
			throw new Error(message);
		}

		removeListenerHandler();

		_daySource = value;

		addListenerHandler();
		return _daySource;
	}

	//----------------------------------
	//  includeFormatInError
	//----------------------------------
	private var _includeFormatInError:Bool = false;

	// [Inspectable(category="General", defaultValue="true")]

	/** 
		If `true` the date format is shown in some
		validation error messages. Setting to `false`
		changes all DateValidators.

		@default true
	**/
	public var includeFormatInError(get, set):Bool;

	private function get_includeFormatInError():Bool {
		return _includeFormatInError;
	}

	private function set_includeFormatInError(value:Bool):Bool {
		_includeFormatInError = value;
		return _includeFormatInError;
	}

	//----------------------------------
	//  inputFormat
	//----------------------------------
	private var _inputFormat:String;

	private var inputFormatOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		The date format to validate the value against.
		"MM" is the month, "DD" is the day, and "YYYY" is the year.
		This String is case-sensitive.

		@default "MM/DD/YYYY"
	**/
	public var inputFormat(get, set):String;

	private function get_inputFormat():String {
		return _inputFormat;
	}

	private function set_inputFormat(value:String):String {
		inputFormatOverride = value;

		_inputFormat = value != null ? value : "MM/DD/YYYY";
		return _inputFormat;
	}

	//----------------------------------
	//  monthListener
	//----------------------------------
	private var _monthListener:IValidatorListener;

	// [Inspectable(category="General")]

	/** 
		The component that listens for the validation result
		for the month subfield. 
		If none is specified, use the value specified
		for the `monthSource` property.
	**/
	public var monthListener(get, set):IValidatorListener;

	private function get_monthListener():IValidatorListener {
		return _monthListener;
	}

	private function set_monthListener(value:IValidatorListener):IValidatorListener {
		if (_monthListener == value)
			return _monthListener;

		removeListenerHandler();

		_monthListener = value;

		addListenerHandler();
		return _monthListener;
	}

	//----------------------------------
	//  monthProperty
	//----------------------------------
	// [Inspectable(category="General")]

	/**
		Name of the month property to validate. This property is optional, but
		if you specify the `monthSource` property, you should specify either
		`monthProperty` or `monthValueFunction` as well.

		@see `monthValueFunction`
	**/
	public var monthProperty:String;

	/**
		A function that returns the day value to validate. It's recommended to
		use `monthValueFunction` instead of `monthProperty` because reflection
		is used with `monthProperty`, which could result in issues if Dead Code
		Elimination (DCE) is enabled.
	**/
	public var monthValueFunction:() -> Dynamic;

	//----------------------------------
	//  monthSource
	//----------------------------------
	private var _monthSource:Dynamic;

	// [Inspectable(category="General")]

	/** 
		Object that contains the value of the month field.
		If you specify a value for this property, you must also specify
		a value for either the `monthProperty` property or the
		`monthValueFunction` property.
		Do not use this property if you set the `source` 
		and `property` (or `valueFunction`) properties. 

		@see `monthProperty`
		@see `monthValueFunction`
	**/
	public var monthSource(get, set):Dynamic;

	private function get_monthSource():Dynamic {
		return _monthSource;
	}

	private function set_monthSource(value:Dynamic):Dynamic {
		if (_monthSource == value)
			return _monthSource;

		if ((value is String)) {
			var message:String = ValidatorStringUtil.substitute(MS_ATTRIBUTE_ERROR, value);
			throw new Error(message);
		}

		removeListenerHandler();

		_monthSource = value;

		addListenerHandler();
		return _monthSource;
	}

	//----------------------------------
	//  validateAsString
	//----------------------------------
	private var _validateAsString:Bool = true;

	private var validateAsStringOverride:Bool = true;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		Determines how to validate the value.
		If set to `true`, the validator evaluates the value
		as a String, unless the value has a `month`,
		`day`, or `year` property.
		If `false`, the validator evaluates the value
		as a Date object. 

		@default true
	**/
	public var validateAsString(get, set):Bool;

	private function get_validateAsString():Bool {
		return _validateAsString;
	}

	private function set_validateAsString(value:Bool):Bool {
		validateAsStringOverride = value;

		_validateAsString = value;
		return _validateAsString;
	}

	//----------------------------------
	//  yearListener
	//----------------------------------
	private var _yearListener:IValidatorListener;

	// [Inspectable(category="General")]

	/** 
		The component that listens for the validation result
		for the year subfield. 
		If none is specified, use the value specified
		for the `yearSource` property.
	**/
	public var yearListener(get, set):IValidatorListener;

	private function get_yearListener():IValidatorListener {
		return _yearListener;
	}

	private function set_yearListener(value:IValidatorListener):IValidatorListener {
		if (_yearListener == value)
			return _yearListener;

		removeListenerHandler();

		_yearListener = value;

		addListenerHandler();
		return _yearListener;
	}

	//----------------------------------
	//  yearProperty
	//----------------------------------
	// [Inspectable(category="General")]

	/**
		Name of the year property to validate. This property is optional, but if
		you specify the `yearSource` property, you should specify either
		`yearProperty` or `yearValueFunction` as well.

		@see `yearValueFunction`
	**/
	public var yearProperty:String;

	/**
		A function that returns the day value to validate. It's recommended to
		use `yearValueFunction` instead of `yearProperty` because reflection
		is used with `yearProperty`, which could result in issues if Dead Code
		Elimination (DCE) is enabled.
	**/
	public var yearValueFunction:() -> Dynamic;

	//----------------------------------
	//  yearSource
	//----------------------------------
	private var _yearSource:Dynamic;

	// [Inspectable(category="General")]

	/** 
		Object that contains the value of the year field.
		If you specify a value for this property, you must also specify
		a value for either the `yearProperty` property or the
		`yearValueFunction` property. 
		Do not use this property if you set the `source` 
		and `property` (or `valueFunction`) properties. 

		@see `yearProperty`
		@see `yearValueFunction`
	**/
	public var yearSource(get, set):Dynamic;

	private function get_yearSource():Dynamic {
		return _yearSource;
	}

	private function set_yearSource(value:Dynamic):Dynamic {
		if (_yearSource == value)
			return _yearSource;

		if (value is String) {
			var message:String = ValidatorStringUtil.substitute(YS_ATTRIBUTE_ERROR, value);
			throw new Error(message);
		}

		removeListenerHandler();

		_yearSource = value;

		addListenerHandler();
		return _yearSource;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  formatError
	//----------------------------------
	private var _formatError:String;

	private var formatErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the `inputFormat` property
		is not in the correct format.

		@default "Configuration error: Incorrect formatting string." 
	**/
	public var formatError(get, set):String;

	private function get_formatError():String {
		return _formatError;
	}

	private function set_formatError(value:String):String {
		formatErrorOverride = value;

		_formatError = value != null ? value : FORMAT_ERROR;
		return _formatError;
	}

	//----------------------------------
	//  invalidCharError
	//----------------------------------
	private var _invalidCharError:String;

	private var invalidCharErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when there are invalid characters in the date.

		@default "Invalid characters in your date."
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
	//  wrongDayError
	//----------------------------------
	private var _wrongDayError:String;

	private var wrongDayErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the day is invalid.

		@default "Enter a valid day for the month." 
	**/
	public var wrongDayError(get, set):String;

	private function get_wrongDayError():String {
		return _wrongDayError;
	}

	private function set_wrongDayError(value:String):String {
		wrongDayErrorOverride = value;

		_wrongDayError = value != null ? value : WRONG_DAY_ERROR;
		return _wrongDayError;
	}

	//----------------------------------
	//  wrongLengthError
	//----------------------------------
	private var _wrongLengthError:String;

	private var wrongLengthErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the length of the date
		doesn't match that of the `inputFormat` property.

		@default "Type the date in the format." 
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
	//  wrongMonthError
	//----------------------------------
	private var _wrongMonthError:String;

	private var wrongMonthErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the month is invalid.

		@default "Enter a month between 1 and 12."
	**/
	public var wrongMonthError(get, set):String;

	private function get_wrongMonthError():String {
		return _wrongMonthError;
	}

	private function set_wrongMonthError(value:String):String {
		wrongMonthErrorOverride = value;

		_wrongMonthError = value != null ? value : WRONG_MONTH_ERROR;
		return _wrongMonthError;
	}

	//----------------------------------
	//  wrongYearError
	//----------------------------------
	private var _wrongYearError:String;

	private var wrongYearErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the year is invalid.

		@default "Enter a year between 0 and 9999."
	**/
	public var wrongYearError(get, set):String;

	private function get_wrongYearError():String {
		return _wrongYearError;
	}

	private function set_wrongYearError(value:String):String {
		wrongYearErrorOverride = value;

		_wrongYearError = value != null ? value : WRONG_YEAR_ERROR;
		return _wrongYearError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowedFormatChars = allowedFormatCharsOverride;
		inputFormat = inputFormatOverride;
		validateAsString = validateAsStringOverride;

		invalidCharError = invalidCharErrorOverride;
		wrongLengthError = wrongLengthErrorOverride;
		wrongMonthError = wrongMonthErrorOverride;
		wrongDayError = wrongDayErrorOverride;
		wrongYearError = wrongYearErrorOverride;
		formatError = formatErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a date.

		You do not call this method directly;
		Flex calls it as part of performing a validation.
		If you create a custom validator class, you must implement this method.

		@param value Either a String or an Object to validate.

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
			return DateValidator.validateDate(this, value, null);
		}
	}

	/**
		Grabs the data for the validator from three different sources.
	**/
	override private function getValueFromSource():Dynamic {
		var useValue:Bool = false;

		var value:Dynamic = {};

		if (dayValueFunction != null) {
			value.day = dayValueFunction();
			useValue = true;
		} else if (daySource != null && dayProperty != null) {
			value.day = Reflect.getProperty(daySource, dayProperty);
			useValue = true;
		}

		if (monthValueFunction != null) {
			value.month = monthValueFunction();
			useValue = true;
		} else if (monthSource != null && monthProperty != null) {
			value.month = Reflect.getProperty(monthSource, monthProperty);
			useValue = true;
		}

		if (yearValueFunction != null) {
			value.year = yearValueFunction();
			useValue = true;
		} else if (yearSource != null && yearProperty != null) {
			value.year = Reflect.getProperty(yearSource, yearProperty);
			useValue = true;
		}

		return useValue ? value : super.getValueFromSource();
	}
}
