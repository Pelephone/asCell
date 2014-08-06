package utils.tools
{
	import flash.utils.describeType;
	
	/**
	 * 语言包工具, 用于导入/导出语言包
	 *		.格式: key=value, key[index]=value
	 * 		.支持空行
	 * 		.支持注释, 非空首列为 #!
	 * 		.支持1维数组
	 */
	public class LangTool
	{
		static public const REG_COMMENT:RegExp = /^\s*[#!]/;
		static public const REG_ARRAY:RegExp = /(.*)\[(\d+)\]$/;
		static public const LINE_ENDING:String = "\r\n";
		static public const LINE_ENDING_REG:RegExp = /[\r\n]+/;
				
		//
		public function LangTool()
		{
		}
		
		/** 解析init格式到新对象
		 * @param data	要转义的字符串
		 */
		static public function parseIni(data:String):Object
		{
			var obj:Object = new Object();
			var code:String = String(data);
			var codes:Array = code.split(LINE_ENDING);
			
			for (var i:int=0; i<codes.length; i++) {
				//检查是不是注释
				var info:String = codes[i];
				if (info.search(";") >= 0 || info.search("#") >= 0)  continue;
				
				var poz:int = info.search("=");
				if (poz > 0) {
					obj[info.substring(0,poz)] = info.substring(poz + 1,info.length);
				}
			}
			return obj;
		}
		
		// 导出对象到 ini 文件
		static public function export_ini(lang:Object, comment:String):String{
			var lines:Array = [];
			var desc:XML = describeType(lang);
			var name:String, type:String, value:Object;
			
			// constant
			var constant_list:XMLList = desc.constant;
			for each(var constant:XML in constant_list){
				name = constant.@name;
				type = constant.@type;
				value = lang[name];
				add_key(name, type, value);
			}
			
			// variable
			var variable_list:XMLList = desc.variable;
			for each(var variable:XML in variable_list){
				name = variable.@name;
				type = variable.@type;
				value = lang[name];
				add_key(name, type, value);
			}
			
			// dynmic
			for(var key:String in lang){
				add_key(key, typeof(lang[key]), lang[key]);
			}
			
			//
			function add_key(name:String, type:String, value:Object):void{
				var line:String;
				type = type.toLowerCase();
				if(type == "string"){
					line = name + "=" + encode( String(value) );
					lines.push( line );
				}
				else if(type == "array"){
					var arr:Array = value as Array;
					for(var i:int=0; i<arr.length; i++){
						line = name + "[" + i + "]=" + encode(arr[i]);
						lines.push( line );
					}
				}
			}
			
			//
			lines.sort();
			if(comment) lines.unshift("# " + comment );
			return lines.join(LINE_ENDING);
		}
		
		// 导入ini到对象
		static public function import_ini(lang:Object, buffer:String):void{
			var lines:Array = buffer.split( LINE_ENDING_REG );
			trace("LangTool.import_ini(), len:", lines.length);
			
			for each(var line:String in lines){
				if(!line) continue;
				if(REG_COMMENT.test(line)) continue;
				var index:int = line.indexOf("="); if(index<=0) continue;
				var key:String = line.substr(0, index);
				var val:String = line.substr(index+1);
				val = decode( val );
				
				// array
				var obj:Object = REG_ARRAY.exec(key);
				if(obj){
					key = obj[1];
					index = int( obj[2] );
					if(!lang[key]) lang[key] = [];
					lang[key][index] = val;
				}
				// string
				else{
					lang[key] = val;
				}
			}
		}
		
		// 编码字符串
		static private const encode_list:Array = [
			["\n", "\\n"],
			["\r", "\\r"],
			["\b", "\\b"],
			["\t", "\\t"],
		];
		static public function encode(str:String):String{
			for each(var arr:Array in encode_list){
				str = str.split(arr[0]).join(arr[1]);
			}
			return str;
		}
		// 解码字符串
		static public function decode(str:String):String{
			for each(var arr:Array in encode_list){
				str = str.split(arr[1]).join(arr[0]);
			}
			return str;
		}
	}
}