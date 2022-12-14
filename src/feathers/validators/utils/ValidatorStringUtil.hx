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

package feathers.validators.utils;

/**
	The StringUtil utility class is an all-static class with methods for
	working with String objects within Flex.
	You do not create instances of StringUtil;
	instead you call methods such as 
	the `StringUtil.substitute()` method.  
**/
class ValidatorStringUtil {
	/**
		Substitutes "{n}" tokens within the specified string
		with the respective arguments passed in.

		```haxe
		var str:String = "here is some info '{0}' and {1}";
		trace(StringUtil.substitute(str, 15.4, true));
		// this will output the following string:
		// "here is some info '15.4' and true"
		```

		Note that this uses String.replace and "$" can have special
		meaning in the argument strings escape by using "$$".

		@param str The string to make substitutions in.
		This string can contain special tokens of the form
		`{n}`, where `n` is a zero based index,
		that will be replaced with the additional parameters
		found at that index if specified.

		@param rest Additional parameters that can be substituted
		in the `str` parameter at each `{n}`
		location, where `n` is an integer (zero based)
		index value into the array of values specified.
		If the first parameter is an array this array will be used as
		a parameter list.
		This allows reuse of this routine in other methods that want to
		use the ... rest signature.
		For example

		```haxe
		public function myTracer(str:String, ...rest):Void
		{ 
			label.text += ValidationStringUtil.substitute(str, rest) + "\n";
		}
		```

		@return New string with all of the `{n}` tokens
		replaced with the respective arguments specified.
	**/
	public static function substitute(str:String, #if (haxe_ver >= 4.2)...rest:Dynamic #else ?value1:String, ?value2:String, ?value3:String #end):String {
		if (str == null) {
			return '';
		}
		#if (haxe_ver < 4.2)
		var args:Array<String> = [];
		if (value1 != null) {
			args.push(value1);
			if (value2 != null) {
				args.push(value2);
				if (value3 != null) {
					args.push(value3);
				}
			}
		}
		#else
		// Replace all of the parameters in the msg string.
		var args:Array<String> = null;
		var restAsArray = rest.toArray();
		if (restAsArray.length == 1 && (restAsArray[0] is Array)) {
			var rest0:Array<Dynamic> = cast restAsArray[0];
			args = rest0.map(current -> Std.string(current));
		} else {
			args = restAsArray.map(current -> Std.string(current));
		}
		#end
		for (i in 0...args.length) {
			str = new EReg("\\{" + i + "\\}", "g").replace(str, args[i]);
		}
		return str;
	}
}
