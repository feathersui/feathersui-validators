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
	This interface specifies the methods and properties that a Validator 
	object must implement. 

	This interface allows to validate multiple data
	types like numbers, currency, phone numbers, zip codes etc that
	are defined in both mx and spark namespaces. The classes 
	mx:Validator and spark:GlobaliationValidatorBase  
	implement this interface. The validateAll() method in these classes use
	this interface type to call the validate() method on 
	multiple validator objects.

	@see `feathers.validators.Validator`
**/
interface IValidator {
	//----------------------------------------------------------------------
	//
	//  Properties
	//
	//----------------------------------------------------------------------
	//----------------------------------
	//  enabled
	//----------------------------------

	/**
		Property to enable/disable validation process.

		Setting this value to `false` will stop the validator
		from performing validation. 
		When a validator is disabled, it dispatches no events, 
		and the `validate()` method returns null.

		@default true
	**/
	var enabled(get, set):Bool;

	//----------------------------------------------------------------------
	//
	//  Methods
	//
	//----------------------------------------------------------------------
	//----------------------------------
	//  validate
	//----------------------------------

	/**
		Performs validation and optionally notifies
		the listeners of the result. 

		@param value Optional value to validate.
		If null, then the validator uses the `source` and
		`property` properties to determine the value.
		If you specify this argument, you should also set the
		`listener` property to specify the target component
		for any validation error messages.

		@param suppressEvents If `false`, then after validation,
		the validator will notify the listener of the result.

		@return A ValidationResultEvent object
		containing the results of the validation. 
		For a successful validation, the
		`ValidationResultEvent.results` Array property is empty. 
		For a validation failure, the
		`ValidationResultEvent.results` Array property contains
		one ValidationResult object for each field checked by the validator, 
		both for fields that failed the validation and for fields that passed. 
		Examine the `ValidationResult.isError`
		property to determine if the field passed or failed the validation. 

		@see `feathers.events.ValidationResultEvent`
		@see `feathers.validators.ValidationResult`
	**/
	function validate(value:Dynamic = null, suppressEvents:Bool = false):ValidationResultEvent;
}
