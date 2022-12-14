package feathers.validators.utils;

import utest.Assert;
import utest.Test;

class TestValidatorStringUtil extends Test {
	public function testSubstitute():Void {
		var str = "here is some info '{0}' and {1}";
		var result = ValidatorStringUtil.substitute(str, Std.string(15.4), Std.string(true));
		Assert.equals("here is some info '15.4' and true", result);
	}

	#if (haxe_ver >= 4.2)
	public function testSubstituteNonStrings():Void {
		var str = "here is some info '{0}' and {1}";
		var result = ValidatorStringUtil.substitute(str, 15.4, true);
		Assert.equals("here is some info '15.4' and true", result);
	}

	public function testSubstituteArray():Void {
		var str = "here is some info '{0}' and {1}";
		var result = ValidatorStringUtil.substitute(str, [15.4, true]);
		Assert.equals("here is some info '15.4' and true", result);
	}
	#end
}
