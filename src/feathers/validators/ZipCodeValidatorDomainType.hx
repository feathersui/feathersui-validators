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
	The ZipCodeValidatorDomainType class defines the values 
	for the `domain` property of the ZipCodeValidator class,
	which you use to specify the type of ZIP code to validate.

	@see `feathers.validators.ZipCodeValidator`
**/
#if haxe4 enum #else @:enum #end abstract ZipCodeValidatorDomainType(String) from String to String {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
		Specifies to validate a United States or Canadian ZIP code.
	**/
	public var US_OR_CANADA = "US or Canada";

	/**
		Specifies to validate a United States ZIP code.
	**/
	public var US_ONLY = "US Only";

	/**
		Specifies to validate a Canadian ZIP code.
	**/
	public var CANADA_ONLY = "Canada Only";
}
