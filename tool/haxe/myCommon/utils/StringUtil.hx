package utils;

/**
 * 字符串工具
 * @author Pelephone
 */
class StringUtil
{

	/**
	 * 替换字符串中$1,$2,$3...变量
	 */
	public static function format(reStr:String,args:Array<Dynamic>):String
	{
		var s:String = reStr;
		for (i in 0...args.length)
		{
			s = StringTools.replace(s, "$" + (i+1), Std.string(args[i]));
		}
		return s;
	}
	
	
	public static function trim(input:String):String {
		return ltrim(rtrim(input));
	}

	public static function ltrim(input:String):String {
		if (input != null) {
			var size:Int = input.length;
			for(i in 0...size) {
				if(input.charCodeAt(i) > 32) {
					return input.substring(i);
				}
			}
		}
		return "";
	}

	public static function rtrim(input:String):String {
		if (input != null) {
			var size:Int = input.length;
			var i:Int = size;
			while(i > 0) {
				if(input.charCodeAt(i - 1) > 32) {
					return input.substring(0, i);
				}
				i--;
			}
		}
		return "";
	}

	public static function simpleEscape(input:String):String {
		input = input.split("\n").join("\\n");
		input = input.split("\r").join("\\r");
		input = input.split("\t").join("\\t");
		//input = input.split("\f").join("\\f");
		//input = input.split("\b").join("\\b");
		return input;
	}
	
	public static function strictEscape(input:String, isTrim:Bool = true):String {
		if (input != null && input.length > 0) {
			if (isTrim) {
				input = trim(input);
			}
			input = StringTools.urlEncode(input);
			var a = input.split("");
			for (i in 0...a.length) {
				switch(a[i]) {
					case "!": a[i] = "%21";
					case "'": a[i] = "%27";
					case "(": a[i] = "%28";
					case ")": a[i] = "%29";
					case "*": a[i] = "%2A";
					case "-": a[i] = "%2D";
					case ".": a[i] = "%2E";
					case "_": a[i] = "%5F";
					case "~": a[i] = "%7E";
				}
			}
			return a.join("");
		}
		return "";
	}
	
	/**
	 *  判断字符串是否为空
	 */
	public static function isEmpty(str:String):Bool
	{
		if (!Std.is(str, String))
		return true;
		else if (str == null || str == "" || str == "0")
		return true;
		else
		return false;
	}
}