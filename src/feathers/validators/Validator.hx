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

import openfl.errors.Error;
import feathers.events.ValidationResultEvent;
import openfl.events.IEventDispatcher;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	The Validator class is the base class for all Flex validators. 
	This class implements the ability for a validator to make a field
	required, which means that the user must enter a value in the field
	or the validation fails.
	*
	@see `mx.events.ValidationResultEvent`
	@see `mx.validators.ValidationResult`
	@see `mx.validators.RegExpValidationResult`
 */
class Validator extends EventDispatcher implements IValidator {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	private static final REQUIRED_ERROR = "This field is required.";

	/**
		A string containing the upper- and lower-case letters
		of the Roman alphabet  ("A" through "Z" and "a" through "z").
	 */
	private static final ROMAN_LETTERS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	/**
		A String containing the decimal digits 0 through 9.
	 */
	private static final DECIMAL_DIGITS:String = "0123456789";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
		Invokes all the validators in the `validators` Array.
		Returns an Array containing one ValidationResultEvent object 
		for each validator that failed.
		Returns an empty Array if all validators succeed. 
		*
		@param validators An Array containing the Validator objects to execute. 
		*
		@return Array of ValidationResultEvent objects, where the Array
		contains one ValidationResultEvent object for each validator
		that failed. 
		The Array is empty if all validators succeed.
	 */
	public static function validateAll(validators:Array<IValidator>):Array<ValidationResultEvent> {
		var result:Array<ValidationResultEvent> = [];

		var n:Int = validators.length;
		for (i in 0...n) {
			var v:IValidator = cast(validators[i], IValidator);
			if (v != null && v.enabled) {
				var resultEvent:ValidationResultEvent = v.validate();
				if (resultEvent.type != ValidationResultEvent.VALID) {
					result.push(resultEvent);
				}
			}
		}

		return result;
	}

	private static function trimString(str:String):String {
		var startIndex:Int = 0;
		while (str.indexOf(' ', startIndex) == startIndex) {
			++startIndex;
		}

		var endIndex:Int = str.length - 1;
		while (str.lastIndexOf(' ', endIndex) == endIndex) {
			--endIndex;
		}

		return endIndex >= startIndex ? str.substring(startIndex, endIndex + 1) : "";
	}

	private static function getValue(obj:Dynamic, path:Array<String>):Dynamic {
		if (obj == null) {
			return null;
		}

		if (path == null || path.length == 0) {
			return obj;
		}

		var result:Dynamic = obj;
		var i:Int = -1;
		while (++i < path.length && result != null) {
			result = Reflect.getProperty(result, path[i]);
			if (result == null) {
				return null;
			}
		}

		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
		Constructor.
	 */
	public function new() {
		super();
		resourcesChanged();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	// private var document:Dynamic;
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  actualTrigger
	//----------------------------------

	/**
		Contains the trigger object, if any,
		or the source object. Used to determine the listener object
		for the `triggerEvent`.
	 */
	private var actualTrigger(get, never):IEventDispatcher;

	private function get_actualTrigger():IEventDispatcher {
		if (_trigger != null)
			return _trigger;
		else if (_source != null)
			return cast(_source, IEventDispatcher);

		return null;
	}

	//----------------------------------
	//  actualListeners
	//----------------------------------

	/**
		Contains an Array of listener objects, if any,  
		or the source object. Used to determine which object
		to notify about the validation result.
	 */
	private var actualListeners(get, never):Array<Dynamic>;

	private function get_actualListeners():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		if (_listener != null) {
			result.push(_listener);
		} else if (_source != null) {
			result.push(_source);
		}

		return result;
	}

	//----------------------------------
	//  enabled
	//----------------------------------
	private var _enabled:Bool = true;

	// [Inspectable(category="General", defaultValue="true")]

	/** 
		Setting this value to `false` will stop the validator
		from performing validation. 
		When a validator is disabled, it dispatch no events, 
		and the `validate()` method returns null.
		*
		@default true
	 */
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return _enabled;
	}

	private function set_enabled(value:Bool):Bool {
		_enabled = value;
		return _enabled;
	}

	//----------------------------------
	//  listener
	//----------------------------------
	private var _listener:Dynamic;

	// [Inspectable(category="General")]
	/**
		Specifies the validation listener.

		If you do not specify a listener,
		Flex uses the value of the `source` property. 
		After Flex determines the source component,
		it changes the border color of the component,
		displays an error message for a failure,
		or hides any existing error message for a successful validation.
	**/
	/* This behavior has been removed.

		If Flex does not find an appropriate listener, 
		validation errors propagate to the Application object, causing Flex 
		to display an Alert box containing the validation error message.

		Specifying `this` causes the validation error
		to propagate to the Application object, 
		and displays an Alert box containing the validation error message.
	**/
	public var listener(get, set):Dynamic;

	private function get_listener():Dynamic {
		return _listener;
	}

	private function set_listener(value:Dynamic):Dynamic {
		removeListenerHandler();
		_listener = value;
		addListenerHandler();
		return _listener;
	}

	//----------------------------------
	//  property
	//----------------------------------
	private var _property:String;

	// [Inspectable(category="General")]

	/**
		A String specifying the name of the property of the `source` object that
		contains the value to validate. Setting `property` is optional, but if
		you specify `source`, you should set a value for either `property` or
		`valueFunction` as well.

		Reading the `property` uses reflection, which may not work if Dead Code
		Elimination (DCE) is enabled. The `property` property is included for
		backwards compatibility with the Flex API, but the new `valueFunction`
		is now recommended instead.

		@default null

		@see `valueFunction`
	**/
	public var property(get, set):String;

	private function get_property():String {
		return _property;
	}

	private function set_property(value:String):String {
		_property = value;
		return _property;
	}

	private var _valueFunction:() -> Dynamic;

	/**
		A function that returns the value to validate. It's recommended to use
		`valueFunction` instead of `property` because reflection is used with
		`property`, which could result in issues if Dead Code Elimination (DCE)
		is enabled.

		@default null
	**/
	public var valueFunction(get, set):() -> Dynamic;

	private function get_valueFunction():() -> Dynamic {
		return _valueFunction;
	}

	private function set_valueFunction(value:() -> Dynamic):() -> Dynamic {
		_valueFunction = value;
		return _valueFunction;
	}

	//----------------------------------
	//  required
	//----------------------------------
	private var _required:Bool = true;

	// [Inspectable(category="General", defaultValue="true")]

	/**
		If `true`, specifies that a missing or empty
		value causes a validation error.

		@default true
	**/
	public var required(get, set):Bool;

	private function get_required():Bool {
		return _required;
	}

	private function set_required(value:Bool):Bool {
		_required = value;
		return _required;
	}

	//----------------------------------
	//  source
	//----------------------------------
	private var _source:Dynamic;

	// [Inspectable(category="General")]
	// [Bindable("sourceChanged")]

	/**
		Specifies the object containing the property to validate. 
		Set this to an instance of a component or a data model. 
		You use data binding syntax in MXML to specify the value.
		This property supports dot-delimited Strings
		for specifying nested properties. 

		If you specify a value to the `source` property,
		then you should specify a value to the `property`
		property as well. 
		The `source` property is optional.

		@default null

		@see `valueFunction`
	**/
	public var source(get, set):Dynamic;

	private function get_source():Dynamic {
		return _source;
	}

	private function set_source(value:Dynamic):Dynamic {
		if (_source == value) {
			return _source;
		}

		if ((value is String)) {
			var message:String = 'The source attribute, \'${Std.string(value)}\', can not be of type String.';
			throw new Error(message);
		}

		// Remove the listener from the old source.
		removeTriggerHandler();
		removeListenerHandler();

		_source = value;

		// Listen for the trigger event on the new source.
		addTriggerHandler();
		addListenerHandler();
		dispatchEvent(new Event("sourceChanged"));
		return _source;
	}

	//----------------------------------
	//  subFields
	//----------------------------------

	/**
		An Array of Strings containing the names for the properties contained 
		in the `value` Object passed to the `validate()` method. 
		For example, CreditCardValidator sets this property to 
		`[ "cardNumber", "cardType" ]`. 
		This value means that the `value` Object 
		passed to the `validate()` method 
		should contain a `cardNumber` and a `cardType` property. 

		Subclasses of the Validator class that 
		validate multiple data fields (like CreditCardValidator and DateValidator)
		should assign this property in their constructor.
	**/
	private var subFields:Array<String> = [];

	//----------------------------------
	//  trigger
	//----------------------------------
	private var _trigger:IEventDispatcher;

	// [Inspectable(category="General")]

	/**
		Specifies the component generating the event that triggers the validator. 
		If omitted, by default Flex uses the value of the `source` property.
		When the `trigger` dispatches a `triggerEvent`,
		validation executes. 
	**/
	public var trigger(get, set):IEventDispatcher;

	private function get_trigger():IEventDispatcher {
		return _trigger;
	}

	private function set_trigger(value:IEventDispatcher):IEventDispatcher {
		removeTriggerHandler();
		_trigger = value;
		addTriggerHandler();
		return _trigger;
	}

	//----------------------------------
	//  triggerEvent
	//----------------------------------
	private var _triggerEvent:String = Event.CHANGE;

	// [Inspectable(category="General")]

	/**
		Specifies the event that triggers the validation. 
		If omitted, Flex uses the `valueCommit` event. 
		Flex dispatches the `valueCommit` event
		when a user completes data entry into a control.
		Usually this is when the user removes focus from the component, 
		or when a property value is changed programmatically.
		If you want a validator to ignore all events,
		set `triggerEvent` to the empty string ("").
	**/
	public var triggerEvent(get, set):String;

	private function get_triggerEvent():String {
		return _triggerEvent;
	}

	private function set_triggerEvent(value:String):String {
		if (_triggerEvent == value)
			return _triggerEvent;

		removeTriggerHandler();
		_triggerEvent = value;
		addTriggerHandler();
		return _triggerEvent;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------
	//----------------------------------
	//  requiredFieldError
	//----------------------------------
	private var _requiredFieldError:String;

	private var requiredFieldErrorOverride:String;

	// [Inspectable(category="Errors", defaultValue="null")]

	/**
		Error message when a value is missing and the 
		`required` property is `true`. 

		@default "This field is required."
	**/
	public var requiredFieldError(get, set):String;

	private function get_requiredFieldError():String {
		return _requiredFieldError;
	}

	private function set_requiredFieldError(value:String):String {
		requiredFieldErrorOverride = value;

		_requiredFieldError = (value != null && value.length > 0) ? value : REQUIRED_ERROR;
		return _requiredFieldError;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
		This method is called when a Validator is constructed,
		and again whenever the ResourceManager dispatches
		a `"change"` Event to indicate
		that the localized resources have changed in some way.

		This event will be dispatched when you set the ResourceManager's
		`localeChain` property, when a resource module
		has finished loading, and when you call the ResourceManager's
		`update()` method.

		Subclasses should override this method and, after calling
		`super.resourcesChanged()`, do whatever is appropriate
		in response to having new resource values.
	**/
	private function resourcesChanged():Void {
		requiredFieldError = requiredFieldErrorOverride;
	}

	private function addTriggerHandler():Void {
		if (actualTrigger != null && _triggerEvent != null) {
			actualTrigger.addEventListener(_triggerEvent, triggerHandler);
		}
	}

	private function removeTriggerHandler():Void {
		if (actualTrigger != null && _triggerEvent != null) {
			actualTrigger.removeEventListener(_triggerEvent, triggerHandler);
		}
	}

	/**
		Sets up all of the listeners for the 
		`valid` and `invalid`
		events dispatched from the validator. Subclasses of the Validator class 
		should first call the `removeListenerHandler()` method, 
		and then the `addListenerHandler()` method if 
		the value of one of their listeners or sources changes. 
		The CreditCardValidator and DateValidator classes use this function internally. 
	**/
	private function addListenerHandler():Void {
		var actualListener:Dynamic;
		var listeners = actualListeners;

		var n:Int = listeners.length;
		for (i in 0...n) {
			actualListener = listeners[i];
			if ((actualListener is IValidatorListener)) {
				addEventListener(ValidationResultEvent.VALID, cast(actualListener, IValidatorListener).validationResultHandler);
				addEventListener(ValidationResultEvent.INVALID, cast(actualListener, IValidatorListener).validationResultHandler);
			}
		}
	}

	/**
		Disconnects all of the listeners for the 
		`valid` and `invalid`
		events dispatched from the validator. Subclasses should first call the
		`removeListenerHandler()` method and then the 
		`addListenerHandler` method if 
		the value of one of their listeners or sources changes. 
		The CreditCardValidator and DateValidator classes use this function internally. 
	**/
	private function removeListenerHandler():Void {
		var actualListener:Dynamic;
		var listeners = actualListeners;

		var n:Int = listeners.length;
		for (i in 0...n) {
			actualListener = listeners[i];
			if ((actualListener is IValidatorListener)) {
				removeEventListener(ValidationResultEvent.VALID, cast(actualListener, IValidatorListener).validationResultHandler);
				removeEventListener(ValidationResultEvent.INVALID, cast(actualListener, IValidatorListener).validationResultHandler);
			}
		}
	}

	/**
		Returns `true` if `value` is not null. 

		@param value The value to test.

		@return `true` if `value` is not null.
	**/
	private function isRealValue(value:Dynamic):Bool {
		return (value != null);
	}

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

		@see `mx.events.ValidationResultEvent`
		@see `mx.validators.ValidationResult`
	**/
	public function validate(value:Dynamic = null, suppressEvents:Bool = false):ValidationResultEvent {
		if (value == null) {
			value = getValueFromSource();
		}

		if (isRealValue(value) || required) {
			// Validate if the target is required or our value is non-null.
			return processValidation(value, suppressEvents);
		} else {
			// We assume if value is null and required is false that
			// validation was successful.
			var resultEvent:ValidationResultEvent = handleResults(null);
			if (!suppressEvents && _enabled) {
				dispatchEvent(resultEvent);
			}
			return resultEvent;
		}
	}

	/**
		Returns the Object to validate. Subclasses, such as the 
		CreditCardValidator and DateValidator classes, 
		override this method because they need
		to access the values from multiple subfields. 

		@return The Object to validate.
	**/
	private function getValueFromSource():Dynamic {
		if (_valueFunction != null) {
			return _valueFunction();
		} else if (_source != null && (_property != null && _property.length > 0)) {
			return _property.indexOf(".") == -1 ? Reflect.getProperty(_source, _property) : getValue(_source, _property.split("."));
		} else if (_source == null && (_property != null && _property.length > 0)) {
			var message = "The source attribute must be specified when the property attribute is specified.";
			throw new Error(message);
		} else if (_source != null && (_property == null || _property.length == 0)) {
			var message = "The property or propertyFunction attribute must be specified when the source attribute is specified.";
			throw new Error(message);
		}

		return null;
	}

	/**
		Main internally used function to handle validation process.
	**/
	private function processValidation(value:Dynamic, suppressEvents:Bool):ValidationResultEvent {
		var resultEvent:ValidationResultEvent = null;

		if (_enabled) {
			var errorResults = doValidation(value);
			resultEvent = handleResults(errorResults);
		} else {
			suppressEvents = true; // Don't send any events
		}

		if (!suppressEvents) {
			dispatchEvent(resultEvent);
		}

		return resultEvent;
	}

	/**
		Executes the validation logic of this validator, 
		including validating that a missing or empty value
		causes a validation error as defined by
		the value of the `required` property.

		If you create a subclass of a validator class,
		you must override this method.

		@param value Value to validate.

		@return For an invalid result, an Array of ValidationResult objects,
		with one ValidationResult object for each field examined
		by the validator that failed validation.

		@see `mx.validators.ValidationResult`
	**/
	private function doValidation(value:Dynamic):Array<ValidationResult> {
		var results:Array<ValidationResult> = [];

		var result:ValidationResult = validateRequired(value);
		if (result != null) {
			results.push(result);
		}

		return results;
	}

	/**
		Determines if an object is valid based on its `required` property.
		This is a convenience method for calling a validator from within a 
		custom validation function. 
	**/
	private function validateRequired(value:Dynamic):ValidationResult {
		if (required) {
			var val:String = (value != null) ? Std.string(value) : "";

			val = trimString(val);

			// If the string is empty and required is set to true
			// then throw a requiredFieldError.
			if (val.length == 0) {
				return new ValidationResult(true, "", "requiredField", requiredFieldError);
			}
		}

		return null;
	}

	/**
		Returns a ValidationResultEvent from the Array of error results. 
		Internally, this function takes the results from the 
		`doValidation()` method and puts it into a ValidationResultEvent object. 
		Subclasses, such as the RegExpValidator class, 
		should override this function if they output a subclass
		of ValidationResultEvent objects, such as the RegExpValidationResult objects, and 
		needs to populate the object with additional information. You never
		call this function directly, and you should rarely override it. 

		@param errorResults Array of ValidationResult objects.

		@return The ValidationResultEvent returned by the `validate()` method. 
	**/
	private function handleResults(errorResults:Array<ValidationResult>):ValidationResultEvent {
		var resultEvent:ValidationResultEvent;

		if (errorResults != null && errorResults.length > 0) {
			resultEvent = new ValidationResultEvent(ValidationResultEvent.INVALID);
			resultEvent.results = errorResults;

			if (subFields.length > 0) {
				var errorFields:Dynamic = {};
				var subField:String;

				// Now we need to send valid results
				// for every subfield that didn't fail.
				var n:Int;

				n = errorResults.length;
				for (i in 0...n) {
					subField = errorResults[i].subField;
					if (subField != null && subField.length > 0) {
						Reflect.setField(errorFields, subField, true);
					}
				}

				n = subFields.length;
				for (i in 0...n) {
					if (Reflect.field(errorFields, subFields[i]) != true) {
						errorResults.push(new ValidationResult(false, subFields[i]));
					}
				}
			}
		} else {
			resultEvent = new ValidationResultEvent(ValidationResultEvent.VALID);
		}

		return resultEvent;
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function triggerHandler(event:Event):Void {
		validate();
	}
}
