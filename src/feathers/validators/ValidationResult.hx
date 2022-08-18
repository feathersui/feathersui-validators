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
	The ValidationResult class contains the results of a validation. 

	The ValidationResultEvent class defines the event object
	that is passed to event listeners for the `valid`
	and `invalid` validator events. 
	The class also defines the `results` property,
	which contains an Array of ValidationResult objects,
	one for each field examined by the validator.
	This lets you access the ValidationResult objects
	from within an event listener.

	@see `feathers.events.ValidationResultEvent`
**/
class ValidationResult {
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
		Constructor

		@param isError Pass `true` if there was a validation error.

		@param subField Name of the subfield of the validated Object.

		@param errorCode  Validation error code.

		@param errorMessage Validation error message.
	**/
	public function new(isError:Bool, subField:String = "", errorCode:String = "", errorMessage:String = "") {
		this.isError = isError;
		this.subField = subField;
		this.errorMessage = errorMessage;
		this.errorCode = errorCode;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  errorCode
	//----------------------------------

	/**
		The validation error code if the value of the `isError` property is `true`.
	**/
	public var errorCode:String;

	//----------------------------------
	//  errorMessage
	//----------------------------------

	/**
		The validation error message if the value of the `isError` property is `true`.
	**/
	public var errorMessage:String;

	//----------------------------------
	//  isError
	//----------------------------------

	/**
		Contains `true` if the field generated a validation failure.
	**/
	public var isError:Bool;

	//----------------------------------
	//  subField
	//----------------------------------

	/**
		The name of the subfield that the result is associated with.
		Some validators, such as CreditCardValidator and DateValidator,
		validate multiple subfields at the same time.
	**/
	public var subField:String;
}
