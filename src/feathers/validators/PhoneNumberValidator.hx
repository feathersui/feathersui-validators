package feathers.validators;

import feathers.validators.utils.ValidatorStringUtil;
import openfl.errors.Error;

/**
	The PhoneNumberValidator class validates that a string
	is a valid phone number.
	A valid phone number contains at least 10 digits,
	plus additional formatting characters.
	The validator does not check if the phone number
	is an actual active phone number.
**/
class PhoneNumberValidator extends Validator {
	private static final INVALID_FORMAT_CHARS_ERROR = "The allowedFormatChars parameter is invalid. It cannot contain any digits.";
	private static final INVALID_CHAR_ERROR = "Your telephone number contains invalid characters.";
	private static final WRONG_LENGTH_ERROR = "Your telephone number must contain at least {0} digits.";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator
		from within a custom validation function.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The PhoneNumberValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the `value` parameter.
		For example, if the `value` parameter specifies value.phone,
		the `baseField` value is "phone".

		@return An Array of ValidationResult objects, with one ValidationResult 
		object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validatePhoneNumber(validator:PhoneNumberValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;

		var valid:String = Validator.DECIMAL_DIGITS + allowedFormatChars;
		var len:Int = value.toString().length;
		var digitLen:Int = 0;
		var n:Int;
		var minDigits = validator.minDigits;

		n = allowedFormatChars.length;
		for (i in 0...n) {
			if (Validator.DECIMAL_DIGITS.indexOf(allowedFormatChars.charAt(i)) != -1) {
				throw new Error(INVALID_FORMAT_CHARS_ERROR);
			}
		}

		for (i in 0...len) {
			var temp:String = "" + value.toString().substring(i, i + 1);
			if (valid.indexOf(temp) == -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
			if (valid.indexOf(temp) <= 9)
				digitLen++;
		}

		if (!Math.isNaN(minDigits) && digitLen < minDigits) {
			results.push(new ValidationResult(true, baseField, "wrongLength",
				ValidatorStringUtil.substitute(validator.wrongLengthError, Std.string(minDigits))));
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
	private var _allowedFormatChars:String;

	private var allowedFormatCharsOverride:String;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		The set of allowable formatting characters.

		@default "()- .+"
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

		_allowedFormatChars = value != null ? value : "-()+ .";
		return _allowedFormatChars;
	}

	//----------------------------------
	//  minDigits
	//----------------------------------
	private var _minDigits:Float;

	private var minDigitsOverride:Float = 10;

	// [Inspectable(category="General", defaultValue="null")]

	/** 
		Minimum number of digits for a valid phone number.
		A value of `Math.NaN` means this property is ignored.

		@default 10
	**/
	public var minDigits(get, set):Float;

	private function get_minDigits():Float {
		return _minDigits;
	}

	private function set_minDigits(value:Float):Float {
		minDigitsOverride = value;

		_minDigits = value;
		return _minDigits;
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
		Error message when the value contains invalid characters.

		@default "Your telephone number contains invalid characters."
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
	//  wrongLengthError
	//----------------------------------
	private var _wrongLengthError:String;

	private var wrongLengthErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when the value has fewer than 10 digits.

		@default "Your telephone number must contain at least 10 digits."
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

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		allowedFormatChars = allowedFormatCharsOverride;
		minDigits = minDigitsOverride;
		invalidCharError = invalidCharErrorOverride;
		wrongLengthError = wrongLengthErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a phone number.

		You do not typically call this method directly;
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
			return PhoneNumberValidator.validatePhoneNumber(this, value, null);
		}
	}
}
