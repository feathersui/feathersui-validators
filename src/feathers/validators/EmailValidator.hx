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
	The EmailValidator class validates that a String has a single &#64; sign,
	a period in the domain name and that the top-level domain suffix has
	two, three, four, or six characters.
	IP domain names are valid if they are enclosed in square brackets. 
	The validator does not check whether the domain and user name
	actually exist.

	You can use IP domain names if they are enclosed in square brackets; 
	for example, myname&#64;[206.132.22.1].
	You can use individual IP numbers from 0 to 255.
**/
class EmailValidator extends Validator {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	private static final INVALID_CHAR_ERROR = "Your e-mail address contains invalid characters.";
	private static final INVALID_DOMAIN_ERROR = "The domain in your e-mail address is incorrectly formatted.";
	private static final INVALID_IP_DOMAIN_ERROR = "The IP domain in your e-mail address is incorrectly formatted.";
	private static final INVALID_PERIODS_IN_DOMAIN_ERROR = "The domain in your e-mail address has consecutive periods.";
	private static final MISSING_AT_SIGN_ERROR = "An at sign (@) is missing in your e-mail address.";
	private static final MISSING_PERIOD_IN_DOMAIN_ERROR = "The domain in your e-mail address is missing a period.";
	private static final MISSING_USERNAME_ERROR = "The username in your e-mail address is missing.";
	private static final TOO_MANY_AT_SIGNS_ERROR = "Your e-mail address contains too many @ characters.";

	private static final DISALLOWED_LOCALNAME_CHARS:String = "()<>,;:\\\"[] `~!#$%^&*={}|/?\t\n\r";

	private static final DISALLOWED_DOMAIN_CHARS:String = "()<>,;:\\\"[] `~!#$%^&*+={}|/?'\t\n\r";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Convenience method for calling a validator
		from within a custom validation function.
		Each of the standard Flex validators has a similar convenience method.

		@param validator The EmailValidator instance.

		@param value A field to validate.

		@param baseField Text representation of the subfield
		specified in the value parameter.
		For example, if the `value` parameter specifies value.email,
		the `baseField` value is "email".

		@return An Array of ValidationResult objects, with one
		ValidationResult object for each field examined by the validator. 

		@see `mx.validators.ValidationResult`
	**/
	public static function validateEmail(validator:EmailValidator, value:Dynamic, baseField:String):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		// Validate the domain name
		// If IP domain, then must follow [x.x.x.x] format
		// Can not have continous periods.
		// Must have at least one period.
		// Must end in a top level domain name that has 2, 3, 4, or 6 characters.

		var emailStr:String = Std.string(value);
		var username:String = "";
		var domain:String = "";
		var n:Int;

		// Find the @
		var ampPos:Int = emailStr.indexOf("@");
		if (ampPos == -1) {
			results.push(new ValidationResult(true, baseField, "missingAtSign", validator.missingAtSignError));
			return results;
		}
		// Make sure there are no extra @s.
		else if (emailStr.indexOf("@", ampPos + 1) != -1) {
			results.push(new ValidationResult(true, baseField, "tooManyAtSigns", validator.tooManyAtSignsError));
			return results;
		}

		// Separate the address into username and domain.
		username = emailStr.substring(0, ampPos);
		domain = emailStr.substring(ampPos + 1);

		// Validate username has no illegal characters
		// and has at least one character.
		var usernameLen:Int = username.length;
		if (usernameLen == 0) {
			results.push(new ValidationResult(true, baseField, "missingUsername", validator.missingUsernameError));
			return results;
		}

		for (i in 0...usernameLen) {
			if (DISALLOWED_LOCALNAME_CHARS.indexOf(username.charAt(i)) != -1) {
				results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
				return results;
			}
		}

		// name can't start with a dot
		if (username.charAt(0) == '.') {
			results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
			return results;
		}

		var domainLen:Int = domain.length;

		// check for IP address
		if ((domain.charAt(0) == "[") && (domain.charAt(domainLen - 1) == "]")) {
			// Validate IP address
			if (!isValidIPAddress(domain.substring(1, domainLen - 1))) {
				results.push(new ValidationResult(true, baseField, "invalidIPDomain", validator.invalidIPDomainError));
				return results;
			}
		} else {
			// Must have at least one period
			var periodPos:Int = domain.indexOf(".");
			var nextPeriodPos:Int = 0;
			var lastDomain:String = "";

			if (periodPos == -1) {
				results.push(new ValidationResult(true, baseField, "missingPeriodInDomain", validator.missingPeriodInDomainError));
				return results;
			}

			while (true) {
				nextPeriodPos = domain.indexOf(".", periodPos + 1);
				if (nextPeriodPos == -1) {
					lastDomain = domain.substring(periodPos + 1);
					break;
				} else if (nextPeriodPos == periodPos + 1) {
					results.push(new ValidationResult(true, baseField, "invalidPeriodsInDomain", validator.invalidPeriodsInDomainError));
					return results;
				}
				periodPos = nextPeriodPos;
			}

			// Check that there are no illegal characters in the domain.
			for (i in 0...domainLen) {
				if (DISALLOWED_DOMAIN_CHARS.indexOf(domain.charAt(i)) != -1) {
					results.push(new ValidationResult(true, baseField, "invalidChar", validator.invalidCharError));
					return results;
				}
			}

			// Check that the character immediately after the @ is not a period or an hyphen.
			// And check that the character before the period is not an hyphen.
			if (domain.charAt(0) == "." || domain.charAt(0) == "-" || domain.charAt(periodPos - 1) == "-") {
				results.push(new ValidationResult(true, baseField, "invalidDomain", validator.invalidDomainError));
				return results;
			}
		}

		return results;
	}

	/**
		Validate a given IP address

		If IP domain, then must follow [x.x.x.x] format
		or for IPv6, then follow [x:x:x:x:x:x:x:x] or [x::x:x:x] or some
		IPv4 hybrid, like [::x.x.x.x] or [0:00::192.168.0.1]
	**/
	private static function isValidIPAddress(ipAddr:String):Bool {
		var ipArray:Array<String> = [];
		var pos:Int = 0;
		var newpos:Int = 0;
		var item:Float;
		var n:Int;

		// if you have :, you're in IPv6 mode
		// if you have ., you're in IPv4 mode

		if (ipAddr.indexOf(":") != -1) {
			// IPv6

			// validate by splitting on the colons
			// to make it easier, since :: means zeros,
			// lets rid ourselves of these wildcards in the beginning
			// and then validate normally

			// get rid of unlimited zeros notation so we can parse better
			var hasUnlimitedZeros:Bool = ipAddr.indexOf("::") != -1;
			if (hasUnlimitedZeros) {
				ipAddr = ~/^::/.replace(ipAddr, "");
				ipAddr = ~/::/g.replace(ipAddr, ":");
			}

			while (true) {
				newpos = ipAddr.indexOf(":", pos);
				if (newpos != -1) {
					ipArray.push(ipAddr.substring(pos, newpos));
				} else {
					ipArray.push(ipAddr.substring(pos));
					break;
				}
				pos = newpos + 1;
			}

			n = ipArray.length;

			final lastIsV4:Bool = ipArray[n - 1].indexOf(".") != -1;

			if (lastIsV4) {
				// if no wildcards, length must be 7
				// always, never more than 7
				if ((ipArray.length != 7 && !hasUnlimitedZeros) || (ipArray.length > 7)) {
					return false;
				}

				for (i in 0...n) {
					if (i == n - 1) {
						// IPv4 part...
						return isValidIPAddress(ipArray[i]);
					}

					item = Std.parseInt("0x" + ipArray[i]);

					if (item != 0) {
						return false;
					}
				}
			} else {
				// if no wildcards, length must be 8
				// always, never more than 8
				if ((ipArray.length != 8 && !hasUnlimitedZeros) || (ipArray.length > 8)) {
					return false;
				}

				for (i in 0...n) {
					item = Std.parseInt("0x" + ipArray[i]);

					if (Math.isNaN(item) || item < 0 || item > 0xFFFF || ipArray[i] == "")
						return false;
				}
			}

			return true;
		}

		if (ipAddr.indexOf(".") != -1) {
			// IPv4

			// validate by splling on the periods
			while (true) {
				newpos = ipAddr.indexOf(".", pos);
				if (newpos != -1) {
					ipArray.push(ipAddr.substring(pos, newpos));
				} else {
					ipArray.push(ipAddr.substring(pos));
					break;
				}
				pos = newpos + 1;
			}

			if (ipArray.length != 4) {
				return false;
			}

			n = ipArray.length;
			for (i in 0...n) {
				item = Std.parseFloat(ipArray[i]);
				if (Math.isNaN(item) || item < 0 || item > 255 || ipArray[i] == "") {
					return false;
				}
			}

			return true;
		}

		return false;
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
		Error message when there are invalid characters in the e-mail address.

		@default "Your e-mail address contains invalid characters."
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
	//  invalidDomainError
	//----------------------------------
	private var _invalidDomainError:String;

	private var invalidDomainErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the suffix (the top level domain)
		is not 2, 3, 4 or 6 characters long.

		@default "The domain in your e-mail address is incorrectly formatted."
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
	//  invalidIPDomainError
	//----------------------------------
	private var _invalidIPDomainError:String;

	private var invalidIPDomainErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when the IP domain is invalid. The IP domain must be enclosed by square brackets.

		@default "The IP domain in your e-mail address is incorrectly formatted."
	**/
	public var invalidIPDomainError(get, set):String;

	private function get_invalidIPDomainError():String {
		return _invalidIPDomainError;
	}

	private function set_invalidIPDomainError(value:String):String {
		invalidIPDomainErrorOverride = value;

		_invalidIPDomainError = value != null ? value : INVALID_IP_DOMAIN_ERROR;
		return _invalidIPDomainError;
	}

	//----------------------------------
	//  invalidPeriodsInDomainError
	//----------------------------------
	private var _invalidPeriodsInDomainError:String;

	private var invalidPeriodsInDomainErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when there are continuous periods in the domain.

		@default "The domain in your e-mail address has continous periods."
	**/
	public var invalidPeriodsInDomainError(get, set):String;

	private function get_invalidPeriodsInDomainError():String {
		return _invalidPeriodsInDomainError;
	}

	private function set_invalidPeriodsInDomainError(value:String):String {
		invalidPeriodsInDomainErrorOverride = value;

		_invalidPeriodsInDomainError = value != null ? value : INVALID_PERIODS_IN_DOMAIN_ERROR;
		return _invalidPeriodsInDomainError;
	}

	//----------------------------------
	//  missingAtSignError
	//----------------------------------
	private var _missingAtSignError:String;

	private var missingAtSignErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when there is no at sign in the email address.

		@default "An at sign (&64;) is missing in your e-mail address."
	**/
	public var missingAtSignError(get, set):String;

	private function get_missingAtSignError():String {
		return _missingAtSignError;
	}

	private function set_missingAtSignError(value:String):String {
		missingAtSignErrorOverride = value;

		_missingAtSignError = value != null ? value : MISSING_AT_SIGN_ERROR;
		return _missingAtSignError;
	}

	//----------------------------------
	//  missingPeriodInDomainError
	//----------------------------------
	private var _missingPeriodInDomainError:String;

	private var missingPeriodInDomainErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when there is no period in the domain.

		@default "The domain in your e-mail address is missing a period."
	**/
	public var missingPeriodInDomainError(get, set):String;

	private function get_missingPeriodInDomainError():String {
		return _missingPeriodInDomainError;
	}

	private function set_missingPeriodInDomainError(value:String):String {
		missingPeriodInDomainErrorOverride = value;

		_missingPeriodInDomainError = value != null ? value : MISSING_PERIOD_IN_DOMAIN_ERROR;
		return _missingPeriodInDomainError;
	}

	//----------------------------------
	//  missingUsernameError
	//----------------------------------
	private var _missingUsernameError:String;

	private var missingUsernameErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when there is no username.

		@default "The username in your e-mail address is missing."
	**/
	public var missingUsernameError(get, set):String;

	private function get_missingUsernameError():String {
		return _missingUsernameError;
	}

	private function set_missingUsernameError(value:String):String {
		missingUsernameErrorOverride = value;

		_missingUsernameError = value != null ? value : MISSING_USERNAME_ERROR;
		return _missingUsernameError;
	}

	//----------------------------------
	//  tooManyAtSignsError
	//----------------------------------
	private var _tooManyAtSignsError:String;

	private var tooManyAtSignsErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when there is more than one at sign in the e-mail address.
		This property is optional. 

		@default "Your e-mail address contains too many &64; characters."
	**/
	public var tooManyAtSignsError(get, set):String;

	private function get_tooManyAtSignsError():String {
		return _tooManyAtSignsError;
	}

	private function set_tooManyAtSignsError(value:String):String {
		tooManyAtSignsErrorOverride = value;

		_tooManyAtSignsError = value != null ? value : TOO_MANY_AT_SIGNS_ERROR;
		return _tooManyAtSignsError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		invalidCharError = invalidCharErrorOverride;
		invalidDomainError = invalidDomainErrorOverride;
		invalidIPDomainError = invalidIPDomainErrorOverride;
		invalidPeriodsInDomainError = invalidPeriodsInDomainErrorOverride;
		missingAtSignError = missingAtSignErrorOverride;
		missingPeriodInDomainError = missingPeriodInDomainErrorOverride;
		missingUsernameError = missingUsernameErrorOverride;
		tooManyAtSignsError = tooManyAtSignsErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate an e-mail address.

		You do not call this method directly;
		Flex calls it as part of performing a validation.
		If you create a custom Validator class, you must implement this method.

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
			return EmailValidator.validateEmail(this, value, null);
		}
	}
}
