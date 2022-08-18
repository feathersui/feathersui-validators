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
	The interface that components implement to support
	the Flex data validation mechanism. 
	The UIComponent class implements this interface.
	Therefore, any subclass of UIComponent also implements it.
**/
interface IValidatorListener {
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  errorString
	//----------------------------------

	/**
		The text that will be displayed by a component's error tip when a
		component is monitored by a Validator and validation fails.

		You can use the `errorString` property to show a 
		validation error for a component, without actually using
		a validator class. 
		When you write a String value to the `errorString` property, 
		Flex draws a red border around the component to indicate
		the validation error, and the String appears in a tooltip
		as the validation error message when you move  the mouse over
		the component, just as if a validator detected a validation error.

		To clear the validation error, write an empty String, "", 
		to the `errorString` property.

		Note that writing a value to the `errorString` property 
		does not trigger the valid or invalid events; it only changes the 
		border color and displays the validation error message.
	**/
	var errorString(get, set):String;

	//----------------------------------
	//  validationSubField
	//----------------------------------

	/**
		Used by a validator to assign a subfield.
	**/
	var validationSubField(get, set):String;

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
		Handles both the `valid` and `invalid` events
		from a  validator assigned to this component.  

		You typically handle the `valid` and `invalid`
		events dispatched by a validator by assigning event listeners
		to the validators. 
		If you want to handle validation events directly in the component
		that is being validated, you can override this method
		to handle the `valid` and `invalid` events.
		From within your implementation, you can use the
		`dispatchEvent()` method to dispatch the 
		`valid` and `invalid` events
		in the case where a validator is also listening for them.

		@param event The event object for the validation.

		@see `feathers.events.ValidationResultEvent`
	**/
	function validationResultHandler(event:ValidationResultEvent):Void;
}
