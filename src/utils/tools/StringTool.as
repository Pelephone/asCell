package utils.tools
{
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	 * 字符串工具
	 * @author Pelephone
	 */	
	public class StringTool
	{
		/// 字符串处理 ///////////
		/**
		 * 转语言包对象字符串缓存对象
		 */
		private static var cacheLangObj:Object;
		
		/**
		 * 通过变量字符设置语言包
		 * 例如{aa}对{bb}说asdf,通过obj的aa,bb属性转成 A对B说asdf
		 */
		public static function langByObj(langStr:String,obj:Object):String
		{
			cacheLangObj = obj;
			var exp:RegExp = /{\w+}/g;
			var reStr:String = langStr.replace(exp, langToken);
			cacheLangObj = null;
			return reStr;
		}
		
		/**
		 * 解析字符
		 */
		private static function langToken(...args):String
		{
			var attr:String = args[0];
			attr = attr.substr(1,attr.length-2);
			var valStr:String = cacheLangObj.hasOwnProperty(attr)?String(cacheLangObj[attr]):"";
			return valStr;
		}
		
		// 支持: %d, %D, %u, %f, %s, %?, {0}, {1}, %2d, %3d 
		static private const exp_printf:RegExp = /(%[d|D|u|f|s|e|?])|%(\d+)d|\{(\d+)(:\w+)?\}/g;
		static private var _args:Array;	// 原始数组
		static private var _argi:int;	// 当前索引号
		static private var _argb:int;	// 当前索引基地址
		static private var _argm:int;	// 当前匹配的个数
		
		// fmt =  %d, %D, %u, %f, %s, %?, {0}, {1}, %2d, %3d 
		static public function printf(fmt:String, ...args):String{
//			if(!exp_printf.test(fmt)) return fmt;
			_args = args; _argb = _argi = _argm = 0; 
			return fmt.replace(exp_printf, match_token);
		}
		
		/**
		 * 简单轻量字符拼接，类似php的变量。注.此方法不支持多个匹配
		 * @param str 格式   aaaa$0bb$1  $0表示 args中第一个插入到str的参数
		 * @param args
		 * @return
		 */
		public static function format(str:String, ... args):String
		{
			var result:String;
			result = str;
			for (var i:int = 1; i <= args.length; i++)
			{
				result = result.replace("$" + i, String(args[i - 1]));
			}
			return result;
		}
		
		/**
		 * 过滤文件名,如aa/bb/cc.txt 过滤出cc 即去掉文件夹路径字符和后缀
		 * @param str
		 * @return 
		 */
		public static function filterFileName(str:String):String
		{
			var start:int = str.lastIndexOf("/") + 1;
			var end:int = str.lastIndexOf(".");
			if(end<start) end = str.length;
			return str.substring(start,end);
		}
		
		
		// 过滤 html 代码
		static public function stripHTML(string:String) : String {
			var reg:RegExp = /<.*?>/g;
			string = string.replace(reg, "");
			return string;
		}
		
		//粗体
		static public function bold(fmt:String):String
		{
			return "<b>"+fmt+"</b>";
		}
		
		// 建立html连接  <a href='event:$EVENT'>$TEXT</a>
		//设置文本的htmlText，加上链接标签
		static public function htmlLink(txt:TextField,text:String,...info):String{
			var str:String = "<a href='event:" + info.join(",") + "'>" + text + "</a>";
			if(txt) txt.htmlText = str;
			return str;
		}
		
		// color = "#ff0000"
		static public function htmlFont(txt:TextField,color:String, src:String):String{
			var str:String = "<font color='" + color + "'>" + src + "</font>";
			if(txt) txt.htmlText = str;
			return str;
		}
		
		// 为所有的 <a> 标签, 添加 target='_blank', 防止替换当前窗口
		static public function  changeHtmlTargetA(str:String):String{
			
			// 删除 <a> 中的 target 属性
			var reg2:RegExp = /(<\s?a\b.*?)target\s?=\s?.*?([\s|>])/gi;
			var str2:String = str.replace(reg2, "$1$2");
			
			// 添加 <a> 中新的 target 属性
			var reg3:RegExp = /(<\s?a)(\b)(.*?>)/gi;
			var str3:String = str2.replace(reg3, "$1 target='_blank' $3"); 
			
			return str3;
		}
		
		// 过滤 html 代码, 并保留某些标签, 例如 retain_tag_list=["a", "u"], 则保留 <a> <u> 中的html内容
		static public function stripHTMLEx(string:String, ...retain_tag_list) : String {
			
			// 转换为小写
			var tag_list:Array = retain_tag_list;
			for(var i:int=0; i<tag_list.length; i++)	{
				tag_list[i] = (tag_list[i] as String).toLowerCase();
			}
			
			// 过滤 html 标签
			var reg:RegExp = /<\/?(\w+).*?>/g;
			var onMatch:Function = function(match:String, desc:String, index:int, str:String):String{
				if( tag_list.indexOf( desc.toLowerCase() ) >= 0) return match;	// 保留该标签 
				return ""; // 否则, 过滤该标签							
			};
			string = string.replace(reg, onMatch);
			return string;
		}
		
		//斜体
		static public function italic(fmt:String,txt:TextField=null):String
		{
			var str:String = "<i>"+fmt+"</i>";
			if(txt) txt.htmlText = str;
			return str;
		}
		
		//设置字体，包括颜色和字大小
		static public function font(fmt:String,color:String=null,size:int=0,txt:TextField=null):String
		{
			var argStr:String = " color='"+color+"'";
			if(size>0) argStr += " size='"+size+"'";
			var str:String = "<font"+argStr+">"+fmt+"</font>";
			if(txt) txt.htmlText = str;
			return str;
		}
		
		//给字符添加class
		static public function fontClass(fmt:String,className:String=null,txt:TextField=null):String
		{
			var str:String = "<span class='"+className+"'>"+fmt+"</span>";
			if(txt) txt.htmlText = str;
			return str;
		}
		
		// 删除多余的换行
		static public function stringDelRnInTextfield(str:String, rep:String=null):String{
			if(!str) return str;
			var reg:RegExp = /[\r\n]{1,2}/g;
			if(!rep) rep = "\n";
			return str.replace(reg, rep);
		}
		
		// 字符串半角转全角		// 算法参考: http://wiki.python.cn/moin/MicroProj/2007-08-07
		static public function stringHalfToFull(str:String):String{
			if(!str) return str;
			
			var codes:Array = new Array;
			for(var i:int=0; i<str.length; i++)
			{
				var c:int = str.charCodeAt( i );
				var c2:int;
				
				// 不是半角字符就返回原来的字符
				if(c < 0x0020 || c > 0x007e ){
					c2 = c;
				}
					// 除了空格其他的全角半角的公式为:半角=全角-0xfee0
				else if(c == 0x0020){
					c2 = 0x3000;
				}
				else{
					c2 = c + 0xfee0;
				}
				codes.push( c2 );
			}
			
			var str2:String = (String.fromCharCode as Function).apply(null, codes);
			return str2;
		}
		
		static private function match_token(...args):String{
			
			var token:String = args[0];
			var i:int, s:String, n:Number, value:Object;
			_argm ++;
			
			// %d, %D, %u, %f, %s, %e, %?
			if(args[1])
			{
				value = _args[_argi++];
				switch(token)
				{
					case "%d":	return String( int(value) );
					case "%D":	return int(value)>0 ? "+"+String(int(value)): String(int(value));
					case "%u":	return String(uint(value));
					case "%f":	return String(Number(value));
					case "%s":	return String(value);
					case "%e":	return encodeURIComponent(String(value));
					case "%?":	return "";
					default:	return token;
				}
			}
				// %2d, %3d, 
			else if (args[2])
			{
				value = _args[_argi++];
				i = int( args[2] );
				s = String( int(value) );
				while(s.length < i) s = "0" + s;
				return s; 
			}
				// {0}, {1}
			else if(args[3])
			{
				i = _argb + int(args[3]);
				if(!_args[ i ]) _args[ i ] = '';
				value = _args[ i ].toString() || "";
				return value.toString();
			}
			
			// default
			return token;
		}
		
		// 转换 阿拉伯数字 到 中文数字, 暂不支持小数
		static public function chineseNumber(value:uint):String{
			
			// 常量
			const map_num:Array 	= ["零","一","二","三","四","五","六","七","八","九"];
			const map_a:Array 		= ["千","百","十", ""];			// 单位a
			//const map_b:Array 		= ["兆","亿","万", ""];			// 单位b
			const map_b:Array 		= ["亿","万", ""];			// 单位b
			const LEN:int	 		= map_a.length * map_b.length;	// 字符串最大长度
			
			// 转换 value 为字符串格式, 并前面填充 '0', 得到如 '0001'
			var buf:String =String( value);
			buf = repeat(LEN-buf.length, "0") + buf;
			if(buf.length != LEN) return "超出上限";
			
			// 遍历每个数字
			var prev:int = 100;			// 上一个有效数字的位置
			var b:String = "";			// 单位b的名字, 在变更后才添加
			var str:String = "";		// 结果字符串
			for(var i:int=0; i<LEN; i++)
			{
				// 仅遍历有效数字
				var ch:String = buf.charAt(i);
				if(ch == '0') continue;
				
				// 单位b, 如果变动, 则添加到 str 上
				var b2:String = map_b[ int(i / 4) ];
				if(b2 != b){
					str += b;		// 添加先前的单位
					b = b2;			// 同一个单位b, 只可能添加一次
				}
				
				// 补零, 当有效数字非连续时
				if(prev < i-1){
					if( (i % 4) != 0 )		// 千位不允许
						str += map_num[0];
				} 
				prev = i;
				
				// 数字
				str += map_num[ch.charCodeAt(0) - 0x30];
				
				// 单位a
				str += map_a[ i % 4];
			}
			str += b;	// 补上单位b
			
			// 修饰
			{
				// 空串
				if(str == "") str = "零";
				
				// 以 "一十" 开始变为以 "十" 开始
				str = str.replace(new RegExp("^一十", ""), "十");
			}
			
			//
			return str;
		}
		
		// 返回 rep 的重复 times 次数后的值
		static public function repeat(times:int, rep:String):String{
			var str:String = "";
			while(times-- > 0) str += rep;
			return str;
		}
		//忽略大小字母比较字符是否相等;
		public static function equalsIgnoreCase(char1:String, char2:String):Boolean
		{
			return char1.toLowerCase() == char2.toLowerCase();
		}
		
		//比较字符是否相等;
		public static function equals(char1:String, char2:String):Boolean
		{
			return char1 == char2;
		}
		
		//是否为Email地址;
		public static function isEmail(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//是否是数值字符串;
		public static function isNumber(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			return !isNaN(parseInt(char))
		}
		
		//是否为Double型数据;
		public static function isDouble(char:String):Boolean
		{
			char=trim(char);
			var pattern:RegExp=/^[-\+]?\d+(\.\d+)?$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//Integer;
		public static function isInteger(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/^[-\+]?\d+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//English;
		public static function isEnglish(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/^[A-Za-z]+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//中文;
		public static function isChinese(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/^[\u0391-\uFFE5]+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//双字节
		public static function isDoubleChar(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/^[^\x00-\xff]+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//含有中文字符
		public static function hasChineseChar(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/[^\x00-\xff]/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//注册字符;
		public static function hasAccountChar(char:String, len:uint=15):Boolean
		{
			if (char == null)
			{
				return false;
			}
			if (len < 10)
			{
				len=15;
			}
			char=trim(char);
			var pattern:RegExp=new RegExp("^[a-zA-Z0-9][a-zA-Z0-9_-]{0," + len + "}$", "");
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//URL地址;
		public static function isURL(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char).toLowerCase();
			var pattern:RegExp=/^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		// 是否为空白;        
		public static function isWhitespace(char:String):Boolean
		{
			switch(char)
			{
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
					return true;
				default:
					return false;
			}
		}
		
		//去左右空格;
		public static function trim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			return rtrim(ltrim(char));
		}
		
		//去左空格; 
		public static function ltrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp=/^\s*/;
			return char.replace(pattern, "");
		}
		
		//去右空格;
		public static function rtrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp=/\s*$/;
			return char.replace(pattern, "");
		}
		
		/**
		 * 判断是否为空 
		 * @param target 要判断的字符串
		 * @return 如果为空返回true，如果不空返回false
		 * 
		 */		
		public static function isEmputy(target:String):Boolean
		{
			if( null == target || "" == target){
				return true;
			}
			else{
				if("" != trim(target)){
					return false;
				}else{
					return true;
				}
			}
		}
		
		/**
		 * 是否为前缀字符串;
		 * @param char		要判断的原始字符
		 * @param prefix	前缀字符
		 */		
		public static function isPrefix(char:String, prefix:String):Boolean
		{
			return (prefix == char.substring(0, prefix.length));
		}
		
		/**
		 * 是否为后缀字符串;
		 * @param char		要判断的原始字符
		 * @param suffix	后缀字符
		 */	
		public static function isSuffix(char:String, suffix:String):Boolean
		{
			return (suffix == char.substring(char.length - suffix.length));
		}
		
		/**
		 * 获取链接地址后缀名
		 * @param url 链接地址
		 * @return 返回空表示查找后缀失败
		 */
		public static function getURLSuffix(url:String):String
		{
			var pid:int = url.lastIndexOf(".");
			var wid:int = url.indexOf("?");
			if((wid>=0 && wid>pid) || pid<0 || (wid>=0 && wid<2))
				return null;
			else
			{
				if(wid>0)
					return url.substring(pid,wid);
				else
					return url.substr(pid);
			}
		}
		
		/**
		 * 去除指定字符串;
		 * @param char
		 * @param remove
		 * @return 
		 */
		public static function remove(char:String, remove:String):String
		{
			return replace(char, remove, "");
		}
		
		//字符串替换;
		public static function replace(char:String, replace:String, replaceWith:String):String
		{
			return char.split(replace).join(replaceWith);
		}
		
		//utf16转utf8编码;
		public static function utf16to8(char:String):String
		{
			var out:Array=new Array();
			var len:uint=char.length;
			for(var i:uint=0; i < len; i++)
			{
				var c:int=char.charCodeAt(i);
				if (c >= 0x0001 && c <= 0x007F)
				{
					out[i]=char.charAt(i);
				}
				else if (c > 0x07FF)
				{
					out[i]=String.fromCharCode(0xE0 | ((c >> 12) & 0x0F), 0x80 | ((c >> 6) & 0x3F), 0x80 | ((c >> 0) & 0x3F));
				}
				else
				{
					out[i]=String.fromCharCode(0xC0 | ((c >> 6) & 0x1F), 0x80 | ((c >> 0) & 0x3F));
				}
			}
			return out.join('');
		}
		
		//utf8转utf16编码;
		public static function utf8to16(char:String):String
		{
			var out:Array=new Array();
			var len:uint=char.length;
			var i:uint=0;
			while(i < len)
			{
				var c:int=char.charCodeAt(i++);
				switch(c >> 4)
				{
					case 0:
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
						// 0xxxxxxx
						out[out.length]=char.charAt(i - 1);
						break;
					case 12:
					case 13:
						// 110x xxxx   10xx xxxx
						var char2:int=char.charCodeAt(i++);
						out[out.length]=String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
						break;
					case 14:
						// 1110 xxxx  10xx xxxx  10xx xxxx
						var char3:int=char.charCodeAt(i++);
						var char4:int=char.charCodeAt(i++);
						out[out.length]=String.fromCharCode(((c & 0x0F) << 12) | ((char3 & 0x3F) << 6) | ((char4 & 0x3F) << 0));
						break;
				}
			}
			return out.join('');
		}
		
		// 解码字符串到对象, "x=1&y=2&z=3" => {x:1, y:2, z:3}
		static public function decodeSimpleObject(str:String, join_char:String=null, equip_char:String=null):Object{
			join_char = join_char || "&";
			equip_char = equip_char || "=";
			var arr:Array = str.split(join_char);
			var obj:Object = {};
			for each(str in arr){
				var a:Array = str.split( equip_char );
				obj[ a[0] ] = a[1]; 
			}
			return obj;
		}
		
		/**
		 * 将对象转为url网络发送的字符串
		 * @param obj
		 * @return 
		 */		
		static public function undecodeObject(object:Object):String{
			var str:String = '';
			for(var tname:String in object){
				str += tname + "=" + object[tname] + "&";
			}
			var lastJoin:int = str.lastIndexOf("&")
			if(lastJoin>=0) str = str.substring(0,(lastJoin-1));
			return str;
		}
		
		public static function autoReturn(str:String, c:int):String
		{
			var l:int=str.length;
			if (l < 0)
				return "";
			var i:int=c;
			var r:String=str.substr(0, i);
			while(i <= l)
			{
				r+="\n";
				r+=str.substr(i, c);
				i+=c;
			}
			return r;
		}
		
		public static function limitStringLengthByByteCount(str:String, bc:int, strExt:String="..."):String
		{
			if (str == null || str == "")
			{
				return str;
			}
			else
			{
				var l:int=str.length;
				var c:int=0;
				var r:String="";
				for(var i:int=0; i < l; ++i)
				{
					var code:uint=str.charCodeAt(i);
					if (code > 0xffffff)
					{
						c+=4;
					}
					else if (code > 0xffff)
					{
						c+=3;
					}
					else if (code > 0xff)
					{
						c+=2;
					}
					else
					{
						++c;
					}
					
					if (c < bc)
					{
						r+=str.charAt(i);
					}
					else if (c == bc)
					{
						r+=str.charAt(i);
						r+=strExt;
						break;
					}
					else
					{
						r+=strExt;
						break;
					}
				}
				return r;
			}
		}
		
		public static function getCharsArray(targetString:String, hasBlankSpace:Boolean):Array
		{
			var tempString:String=targetString;
			if (hasBlankSpace == false)
			{
				tempString=trim(targetString);
			}
			return tempString.split("");
		}
		
		private static var CHINESE_MAX:Number = 0x9FFF;
		private static var CHINESE_MIN:Number = 0x4E00;
		
		private static var LOWER_MAX:Number = 0x007A;
		private static var LOWER_MIN:Number = 0x0061;
		
		private static var NUMBER_MAX:Number = 0x0039;
		private static var NUMBER_MIN:Number = 0x0030;
		
		private static var UPPER_MAX:Number = 0x005A;
		private static var UPPER_MIN:Number = 0x0041;
		/**
		 * 返回一段字符串的字节长度（汉字一个字占2，其他占1）
		 */
		public static function getStringBytes(str:String):int
		{
			if (str == "" || str == null)
				return 0;
			var n:int=0;
			var l:int=str.length;
			for(var i:int=0; i < l; ++i)
			{
				var code:Number=str.charCodeAt(i);
				if (code >= CHINESE_MIN && code <= CHINESE_MAX)
				{
					n+=2;
				}
				else
				{
					++n;
				}
			}
			return n;
		}
		
		/**
		 * 按字节长度截取字符串（汉字一个字占2，其他占1）
		 */
		public static function substrByByteLen(str:String, len:int):String
		{
			if (str == "" || str == null)
				return str;
			var n:int=0;
			var l:int=str.length;
			for(var i:int=0; i < l; ++i)
			{
				var code:Number=str.charCodeAt(i);
				if (code >= CHINESE_MIN && code <= CHINESE_MAX)
				{
					n+=2;
				}
				else
				{
					++n;
				}
				if (n > len)
				{
					str=str.substr(0, i - 1);
					break;
				}
			}
			return str;
		}
		
		/**
		 * 返回一段字符串的字节长度
		 */
		public static function getStringByteLength(str:String):int
		{
			if (str == null)
				return 0;
			var t:ByteArray=new ByteArray();
			t.writeUTFBytes(str);
			return t.length;
		}
		
		
		
		public static function isEmptyString(str:String):Boolean
		{
			return str == null || str == "";
		}
		
		private static var NEW_LINE_REPLACER:String=String.fromCharCode(6);
		
		public static function isNewlineOrEnter(code:uint):Boolean
		{
			return code == 13 || code == 10;
		}
		
		public static function removeNewlineOrEnter(str:String):String
		{
			str=replace(str, "\n", "");
			return replace(str, "\r", "");
		}
		
		/**
		 * 替换掉文本中的 '\n' 为 '\7'
		 */
		public static function escapeNewline(txt:String):String
		{
			return replace(txt, "\n", NEW_LINE_REPLACER);
		}
		
		/**
		 * 替换掉文本中的 '\7' 为  '\n'
		 */
		public static function unescapeNewline(txt:String):String
		{
			return replace(txt, NEW_LINE_REPLACER, "\n");
		}
		
		/**
		 * 判断哪些是全角字符,如果不含有返回空
		 */
		public static function judge(s:String):String
		{
			var temps:String="";
			var isContainQj:Boolean=false;
			for(var i:Number=0; i < s.length; i++)
			{
				//半角长度是一，特殊符号长度是三，汉字和全角长度是9
				if (escape(s.substring(i, i + 1)).length > 3)
				{
					temps+="'" + s.substring(i, i + 1) + "' ";
					isContainQj=true;
				}
			}
			if (isContainQj)
			{
				temps;
			}
			return temps;
		}
		
		/**
		 * 汉字、全角数字和全角字母都是双字节码，第一个字节的值减去160表示该字在字库中的区
		 码，第二个字节的值减去160为位码，如‘啊’的16进制编码为B0   A1，换算成十进制数就是
		 176和161，分别减去160后就是16和1，即‘啊’字的区位码是1601，同样数字和字母的区位
		 码也是如此，如‘0’是0316，‘1’是0317等，因此判断汉字及全角字符基本上只要看其连
		 续的两个字节是否大于160，至于半角字符和数字则更简单了，只要到ASCII码表中查一查就
		 知道了。
		 * //删除oldstr空格，把全角转换成半角
		 //根据汉字字符编码规则：连续两个字节都大于160，
		 //全角符号第一字节大部分为163
		 //～，全角空格第一字节都是161，不知道怎么区分？
		 * /
		/**
		 * 把含有的全角字符转成半角
		 */
		public static function changeToBj(s:String):String
		{
			if (s == null)
				return null;
			var temps:String="";
			for(var i:Number=0; i < s.length; i++)
			{
				if (escape(s.substring(i, i + 1)).length > 3)
				{
					var temp:String=s.substring(i, i + 1);
					if (temp.charCodeAt(0) > 60000)
					{
						//区别汉字
						var code:Number=temp.charCodeAt(0) - 65248;
						var newt:String=String.fromCharCode(code);
						temps+=newt;
					}
					else
					{
						if (temp.charCodeAt(0) == 12288)
							temps+=" ";
						else
							temps+=s.substring(i, i + 1);
					}
				}
				else
				{
					temps+=s.substring(i, i + 1);
				}
			}
			return temps;
		}
		
		/**
		 * 把含有的半角字符转成全角
		 */
		public static function changeToQj(s:String):String
		{
			if (s == null)
				return null;
			var temps:String="";
			for(var i:Number=0; i < s.length; i++)
			{
				if (escape(s.substring(i, i + 1)).length > 3)
				{
					var temp:String=s.substring(i, i + 1);
					if (temp.charCodeAt(0) > 60000)
					{
						//区别汉字
						var code:Number=temp.charCodeAt(0) + 65248;
						var newt:String=String.fromCharCode(code);
						temps+=newt;
					}
					else
					{
						temps+=s.substring(i, i + 1);
					}
				}
				else
				{
					temps+=s.substring(i, i + 1);
				}
			}
			return temps;
		}
		
		/**
		 * 在不够指定长度的字符串前补零
		 * @param str
		 * @param len
		 * @return
		 *
		 */
		public static function renewZero(str:String, len:int):String
		{
			var bul:String="";
			var strLen:int=str.length;
			if (strLen < len)
			{
				for(var i:int=0; i < len - strLen; i++)
				{
					bul+="0";
				}
				return bul + str;
			}
			else
			{
				return str;
			}
		}
		
		/**
		 * 检查字符串是否符合正则表达式
		 */
		public static function isUpToRegExp(str:String, reg:RegExp):Boolean
		{
			if (str != null && reg != null)
			{
				return str.match(reg) != null;
			}
			else
				return false;
		}
		
		/**
		 * 是否含有/0结束符的不正常格式的字符串
		 */
		public static function isErrorFormatString(str:String, len:int=0):Boolean
		{
			if (str == null || (len != 0 && str.length > len))
				return true;
			else
				return str.indexOf(String.fromCharCode(0)) != -1;
		}
		
		/**
		 * 返回格式化后的金钱字符串,如1000000 -> 1,000,000
		 */
		public static function getFormatMoney(money:Number):String
		{
			var moneyStr:String=money.toString();
			var formatMoney:Array=new Array();
			for(var index:Number=-1; moneyStr.charAt(moneyStr.length + index) != ""; index-=3)
			{
				if (Math.abs(index - 2) >= moneyStr.length)
					formatMoney.push(moneyStr.substr(0, moneyStr.length + index + 1));
				else
					formatMoney.push(moneyStr.substr(index - 2, 3));
			}
			formatMoney.reverse();
			return formatMoney.join(",");
		}
		
		/**
		 * 正整数转为中文数字
		 * 最大到十位
		 */		
		private static const ChineseNumberTable:Array = [0x96f6 ,0x4e00 ,0x4e8c ,0x4e09 ,0x56db ,0x4e94 ,0x516d ,0x4e03 ,0x516b ,0x4e5d ,0x5341];
		public static function uintToChineseNumber(u:uint):String {
			if (u <= 10) {
				return String.fromCharCode(ChineseNumberTable[u]);
			}
			else
				if (u < 20) {
					return String.fromCharCode(ChineseNumberTable[10], ChineseNumberTable[u - 10]);
				}
				else
					if (u < 100) {
						var t:uint = Math.floor(u / 10);
						var tt:uint = u % 10;
						if (tt > 0) {
							return String.fromCharCode(ChineseNumberTable[t], ChineseNumberTable[10], ChineseNumberTable[tt]);
						}
						else {
							return String.fromCharCode(ChineseNumberTable[t], ChineseNumberTable[10]);
						}
					}
					else {
						return "";
					}
		}
		
		/**
		 * 删除字符串里第一个匹配的字符串refStr
		 * 如str = "123455"; str = delstr(str,"345");
		 * 输出str为 125;
		 * @param srcStr
		 * @param refStr
		 */		
		public static function delStr(srcStr:String,refStr:String):String
		{
			var s1:String = srcStr.substring(0,srcStr.indexOf(refStr));
			var s2:String = srcStr.substring((s1.length+refStr.length),srcStr.length);
			return s1+s2;
		}
		
		/**
		 * 防C的字符处理
		 * @param strFormat   Format-control string
		 * @param args
		 * @return 
		 * 
		 * 只支持
		 * %%	'%'
		 * %s	字符串
		 * %i	整数(dec)
		 * %x	整数(hex)
		 */		
		public static function formatC(strFormat:String, ...additionalArgs):String {
			var args:Array = additionalArgs;
			var i:int = 0;
			var r:String = "";
			var l:int = strFormat.length;
			var k:int = 0;
			var n:int;
			while (true) {
				var j:int = strFormat.indexOf("%", i);
				if (j == -1) {
					r += strFormat.substring(i);
					break;
				}
				else
					if (j + 1 == l) {
						break;
					}
					else {
						var t:String = strFormat.charAt(j + 1);
						switch (t) {
							case "%":
								r += t;
								break;
							
							case "s":
								t = args[k];
								++k;
								if (t != null) {
									r += t;
								}
								break;
							
							case "i":
								t = args[k];
								++k;
								if (t != null) {
									r += t;
								}
								break;
							
							case "x":
								t = args[k];
								++k;
								if (t != null) {
									n = parseInt(t);
									r += n.toString(16);
								}
								break;
						}
						i = j + 2;
					}
			}
			
			return r;
		}
		
		public function StringUtil():void
		{
			throw new Error("StringUtil class is static container only");
		}
		
		
		// 比率参数为假或者不存在则按数组里字符的长度平均分配
		/**
		 * 根据数组数据的字符长度比分配比率
		 * @param datas	数组数据
		 * @return 
		 */
		public static function oddsByDatas(datas:Object):Array
		{
			var sum:int = 0,i:int=0,odds:Array = [];
			// 先算出字符长度
			for each(var s:String in datas){
				sum += (s.length==0)?1:s.length;
			}
			// 再算出数组数据中每个数据长度的比例
			for each(s in datas){
				odds.push(((s.length==0)?1:s.length)/sum);
			}
			return odds;
		}
		
		/**
		 * 破坏 html 标签, 返回新的字符串, 如替换 '<' => '&lt;' 和 '&' => '&amp;' 
		 * @param dangerSource	危险的文本, 其中包含 html 标签
		 * @return 				安全的文本, 其中的 html 标签已经被破坏
		 */
		static public function htmlDestroyTag(dangerSource:String):String{
			if(! dangerSource ) return null;
			
			//
			var onMatch:Function = function (match:String,
											 desc:String,
											 index:int,
											 str:String):String
			{
				switch(match)
				{
					case "<":		return "&lt;";
					case "&":		return "&amp;"
					default:		return match;
				}
			}; 
			return dangerSource.replace(expHtmlTag, onMatch);
		}
		static private const expHtmlTag:RegExp	= /([<|&])/g;
		
		// 清楚 html 标签
		static public function htmlRemoveTag(str:String):String{
			if(!str) return str;
			return str.replace( /<.*?>/g, "");
		}
		
		/**
		 * 将swf文件路径去除?号后面部面,只取文件名
		 * @param src
		 * @return 
		 */
		public static function getSrcFileName(src:String):String
		{
			var tid:int = src.indexOf("?");
			if (tid != -1)
				return src.substring(0, tid);
			return src;
		}
		
		// 去除域名
		private static const _REG_HTTP:RegExp = /http:\/\/[\w|.|:]+\//i;
		// 去除:,.,/,",'这些特殊字符
		private static const _REG_POT:RegExp = /[:|.|\/|"|']/g;
//		private static const _REG_HTTP:RegExp = /http:\/\/[\w|.|:]+\/""http:\/\/[\w|.|:]+\//i;
//		private static const _REG_POT:RegExp = /[:|.|\/]""[:|.|\/]/g;
		/**
		 * 将文件路径中的"."转换成"-"
		 * @param src
		 * @return 
		 */
		public static function changeSrcPot(src:String):String
		{
			var str:String = getSrcFileName(src);
			str = str.replace(_REG_HTTP, "");
			return str.replace(_REG_POT, "-");
		}
		
		
		/**
		 * 获取特殊命名字符串中的第N个参数<br/>
		 * 例如:"carrer$sex_4$2"字符串4是valId=0对应的返回值，2是valId=1对应的返回值
		 */
		public static function getVal(str:String,valId:int=0):Object
		{
			var arr:Array = str.split("_");
			if(!arr || !arr.length) return null;
			arr = arr[1].split("$");
			if(!arr || !arr.length) return null;
			return arr[valId];
		}
		
		
		/**
		 * 简单格式化 abc{0}asdf{1}
		 * @param message
		 * @param args
		 * @return 
		 */
		public static function formatS(message:String, ...args) : String
		{
			var tmpStr:String;
			if (args == null)
			{
				return message;
			}
			var i:int = 0;
			while (i < args.length)
			{
				tmpStr = args[i];
				var re:RegExp = new RegExp("\\{" + i + "\\}","g");
				message = message.replace(re, tmpStr);
				i = i + 1;
			}
			return message;
		}
	}
}