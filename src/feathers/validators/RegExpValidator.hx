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

import feathers.events.ValidationResultEvent;

/** 
	The RegExpValidator class lets you use a regular expression
	to validate a field. 
	You pass a regular expression to the validator using the
	`expression` property, and additional flags
	to control the regular expression pattern matching 
	using the `flags` property. 

	The validation is successful if the validator can find a match
	of the regular expression in the field to validate.
	A validation error occurs when the validator finds no match.

	The RegExpValidator class dispatches the `valid`
	and `invalid` events.
	For an `invalid` event, the event object is an instance
	of the ValidationResultEvent class, and it contains an Array
	of ValidationResult objects.

	However, for a `valid` event, the ValidationResultEvent
	object contains an Array of RegExpValidationResult objects.
	The RegExpValidationResult class is a child class of the
	ValidationResult class, and contains additional properties 
	used with regular expressions, including the following:

	- `matchedIndex` An integer that contains the starting index in the input
	   String of the match.
	- `matchedString` A String that contains the substring of the input String
	   that matches the regular expression.
	- `matchedSubStrings` An Array of Strings that contains 
	   parenthesized substring matches, if any. If no substring matches are found, 
	   this Array is of length 0.  Use matchedSubStrings[0] to access the 
	   first substring match.

	@see `feathers.validators.RegExpValidationResult`
	@see `feathers.validators.ValidationResult`
	@see `EReg`
**/
class RegExpValidator extends Validator {
	private static final NO_EXPRESSION_ERROR = "The expression is missing.";
	private static final NO_MATCH_ERROR = "The field is invalid.";

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
	//  Variables
	//
	//--------------------------------------------------------------------------
	private var regExp:EReg;

	private var foundMatch:Bool = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  expression
	//----------------------------------
	private var _expression:String;

	// [Inspectable(category="General")]

	/**
		The regular expression to use for validation. 
	**/
	public var expression(get, set):String;

	private function get_expression():String {
		return _expression;
	}

	private function set_expression(value:String):String {
		if (_expression != value) {
			_expression = value;

			createRegExp();
		}
		return _expression;
	}

	//----------------------------------
	//  flags
	//----------------------------------
	private var _flags:String;

	// [Inspectable(category="General", defaultValue="null")]

	/**
		The regular expression flags to use when matching.
	**/
	public var flags(get, set):String;

	private function get_flags():String {
		return _flags;
	}

	private function set_flags(value:String):String {
		if (_flags != value) {
			_flags = value;

			createRegExp();
		}
		return _flags;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  noExpressionError
	//----------------------------------
	private var _noExpressionError:String;

	private var noExpressionErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when there is no regular expression specifed. 
		The default value is "The expression is missing."
	**/
	public var noExpressionError(get, set):String;

	private function get_noExpressionError():String {
		return _noExpressionError;
	}

	private function set_noExpressionError(value:String):String {
		noExpressionErrorOverride = value;

		_noExpressionError = value != null ? value : NO_EXPRESSION_ERROR;
		return _noExpressionError;
	}

	//----------------------------------
	//  noMatchError
	//----------------------------------
	private var _noMatchError:String;

	private var noMatchErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/** 
		Error message when there are no matches to the regular expression. 
		The default value is "The field is invalid."
	**/
	public var noMatchError(get, set):String;

	private function get_noMatchError():String {
		return _noMatchError;
	}

	private function set_noMatchError(value:String):String {
		noMatchErrorOverride = value;

		_noMatchError = value != null ? value : NO_MATCH_ERROR;
		return _noMatchError;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override private function resourcesChanged():Void {
		super.resourcesChanged();

		noExpressionError = noExpressionErrorOverride;
		noMatchError = noMatchErrorOverride;
	}

	/**
		Override of the base class `doValidation()` method
		to validate a regular expression.

		You do not call this method directly;
		Flex calls it as part of performing a validation.
		If you create a custom Validator class, you must implement this method.

		@param value Object to validate.

		@return For an invalid result, an Array of ValidationResult objects,
		with one ValidationResult object for each field examined by the validator.
	**/
	override private function doValidation(value:Dynamic):Array<ValidationResult> {
		var results = super.doValidation(value);

		// Return if there are errors
		// or if the required property is set to `false` and length is 0.
		var val:String = value != null ? Std.string(value) : "";
		if (results.length > 0 || ((val.length == 0) && !required)) {
			return results;
		}

		return validateRegExpression(value);
	}

	override private function handleResults(errorResults:Array<ValidationResult>):ValidationResultEvent {
		var result:ValidationResultEvent;

		if (foundMatch) {
			result = new ValidationResultEvent(ValidationResultEvent.VALID);
			result.results = errorResults;
		} else {
			result = super.handleResults(errorResults);
		}

		foundMatch = false;

		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	private function createRegExp():Void {
		if (_expression == null) {
			_expression = "";
		}
		if (_flags == null) {
			_flags = "";
		}
		regExp = new EReg(_expression, _flags);
	}

	/**
		Performs validation on the validator
	**/
	private function validateRegExpression(value:Dynamic):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];
		foundMatch = false;

		if (regExp != null && _expression != "") {
			if (regExp.match(Std.string(value))) {
				var substrs = getMatchedSubstrings();
				results.push(new RegExpValidationResult(false, null, "", "", regExp.matched(0), regExp.matchedPos().pos, substrs));
				foundMatch = true;
				if (_flags.indexOf("g") != -1) {
					while (regExp.match(Std.string(value))) {
						var substrs = getMatchedSubstrings();
						results.push(new RegExpValidationResult(false, null, "", "", regExp.matched(0), regExp.matchedPos().pos, substrs));
					}
				}
			}

			if (results.length == 0) {
				results.push(new ValidationResult(true, null, "noMatch", noMatchError));
			}
		} else {
			results.push(new ValidationResult(true, null, "noExpression", noExpressionError));
		}

		return results;
	}

	private function getMatchedSubstrings():Array<String> {
		var substrs:Array<String> = [];
		var index = 1;
		while (true) {
			var substr:String = null;
			try {
				substr = regExp.matched(index);
			} catch (e:Dynamic) {}
			if (substr == null) {
				break;
			}
			substrs.push(substr);
			index++;
		}
		return substrs;
	}
}
