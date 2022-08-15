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

package feathers.events;

import feathers.validators.ValidationResult;
import openfl.events.EventType;
import openfl.events.Event;

class ValidationResultEvent extends Event {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
		The `ValidationResultEvent.INVALID` constant defines the value of the 
		`type` property of the event object for an `invalid` event.
		The value of this constant is "invalid".

		The properties of the event object have the following values:
		 
		<table class="innertable">
		   <tr><th>Property</th><th>Value</th></tr>
		   <tr><td>`bubbles`</td><td>false</td></tr>
		   <tr><td>`cancelable`</td><td>false</td></tr>
		   <tr><td>`currentTarget`</td><td>The Object that defines the 
			 event listener that handles the event. For example, if you use 
			 `myButton.addEventListener()` to register an event listener, 
			 myButton is the value of the `currentTarget`. </td></tr>
		   <tr><td>`field`</td><td>The name of the field that failed validation.</td></tr>
		   <tr><td>`message`</td><td>A single string that contains 
			 every error message from all of the ValidationResult objects in the results Array.</td></tr>
		   <tr><td>`results`</td><td>An array of ValidationResult objects, 
			 one per validated field.</td></tr>
		   <tr><td>`target`</td><td>The Object that dispatched the event; 
			 it is not always the Object listening for the event. 
			 Use the `currentTarget` property to always access the 
			 Object listening for the event.</td></tr>
		</table>
	**/
	public static inline var INVALID:EventType<ValidationResultEvent> = "invalid";

	/**
		The `ValidationResultEvent.VALID` constant defines the value of the 
		`type` property of the event object for a `valid`event.
		The value of this constant is "valid".

		The properties of the event object have the following values:

		<table class="innertable">
		   <tr><th>Property</th><th>Value</th></tr>
		   <tr><td>`bubbles`</td><td>false</td></tr>
		   <tr><td>`cancelable`</td><td>false</td></tr>
		   <tr><td>`currentTarget`</td><td>The Object that defines the 
			 event listener that handles the event. For example, if you use 
			 `myButton.addEventListener()` to register an event listener, 
			 myButton is the value of the `currentTarget`. </td></tr>
		   <tr><td>`field`</td><td>An empty String.</td></tr>
		   <tr><td>`message`</td><td>An empty String.</td></tr>
		   <tr><td>`results`</td><td>An empty Array.</td></tr>
		   <tr><td>`target`</td><td>The Object that dispatched the event; 
			 it is not always the Object listening for the event. 
			 Use the `currentTarget` property to always access the 
			 Object listening for the event.</td></tr>
		</table>
	**/
	public static inline var VALID:EventType<ValidationResultEvent> = "valid";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
		Constructor.

		@param type The event type; indicates the action that caused the event.

		@param bubbles Specifies whether the event can bubble up the 
		display list hierarchy.

		@param cancelable Specifies whether the behavior associated with the event can be prevented.

		@param field The name of the field that failed validation and triggered the event.

		@param results An array of ValidationResult objects, one per validated field. 
	**/
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, field:String = null, results:Array<ValidationResult> = null) {
		super(type, bubbles, cancelable);

		this.field = field;
		this.results = results;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  field
	//----------------------------------

	/**
		The name of the field that failed validation and triggered the event.
	**/
	public var field:String;

	//----------------------------------
	//  message
	//----------------------------------

	/**
		A single string that contains every error message from all
		of the ValidationResult objects in the results Array.
	**/
	public var message(get, never):String;

	private function get_message():String {
		var msg:String = "";
		var n:Int = 0;

		if (results != null) {
			n = results.length;
		}

		for (i in 0...n) {
			if (results[i].isError) {
				msg += msg == "" ? "" : "\n";
				msg += results[i].errorMessage;
			}
		}

		return msg;
	}

	//----------------------------------
	//  results
	//----------------------------------

	/**
		An array of ValidationResult objects, one per validated field. 

		@see `mx.validators.ValidationResult`
	**/
	public var results:Array<ValidationResult>;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	override public function clone():ValidationResultEvent {
		return new ValidationResultEvent(type, bubbles, cancelable, field, results);
	}
}
