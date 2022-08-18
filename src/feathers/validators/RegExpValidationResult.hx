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
	The RegExpValidator class dispatches the `valid`
	and `invalid` events. 
	For an `invalid` event, the event object
	is an instance of the ValidationResultEvent class, 
	and the `ValidationResultEvent.results` property
	contains an Array of ValidationResult objects.

	However, for a `valid` event, the 
	`ValidationResultEvent.results` property contains 
	an Array of RegExpValidationResult objects.
	The RegExpValidationResult class is a child class
	of the ValidationResult class, and contains additional properties 
	used with regular expressions.

	@see `feathers.events.ValidationResultEvent`
**/
class RegExpValidationResult extends ValidationResult {
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/** 
		Constructor.

		@param isError Pass `true` if there was a validation error.

		@param subField Name of the subfield of the validated Object.

		@param errorCode  Validation error code.

		@param errorMessage Validation error message.

		@param matchedString Matching substring.

		@param matchedIndex Index of the matching String.

		@param matchedSubstrings Array of substring matches.
	**/
	public function new(isError:Bool, subField:String = "", errorCode:String = "", errorMessage:String = "", matchedString:String = "", matchedIndex:Int = 0,
			matchedSubstrings:Array<String> = null) {
		super(isError, subField, errorCode, errorMessage);

		this.matchedString = matchedString;
		this.matchedIndex = matchedIndex;
		this.matchedSubstrings = matchedSubstrings != null ? matchedSubstrings : [];
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	//  matchedIndex
	//--------------------------------------------------------------------------

	/** 
		An integer that contains the starting index
		in the input String of the match.
	**/
	public var matchedIndex:Int;

	//--------------------------------------------------------------------------
	//  matchedString
	//--------------------------------------------------------------------------

	/**
		A String that contains the substring of the input String
		that matches the regular expression.
	**/
	public var matchedString:String;

	//--------------------------------------------------------------------------
	//  matchedSubstrings
	//--------------------------------------------------------------------------

	/**
		An Array of Strings that contains parenthesized
		substring matches, if any. 
		If no substring matches are found, this Array is of length 0.
		Use `matchedSubStrings[0]` to access
		the first substring match.
	**/
	public var matchedSubstrings:Array<String>;
}
