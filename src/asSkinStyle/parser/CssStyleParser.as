/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package asSkinStyle.parser
{
	import asSkinStyle.i.IStyleParser;
	
	/**
	 * 解析css语法的解析器
	 * (本人用正规表达式写的css解析，相比词法分析器效率低些，一般情况本人会用ArrayToStyleParser的多
	 * 有能力的可以自己重构一个此解析器，本人时间有限，不知什么时候才能有时间改进此功能）
	 * 
	 * var cssStr:String = "" +
				"aa{x:100;width:50;height:50;bgColor:0xFF0000};" +
				"aa bb{width:30;height:30;bgColor:0x00FF00;y:10};";
			
		// 生成管理器
		var mgr:AsSkinStyle = new AsSkinStyle(xxx,cssStr,(new XMLSkinParser()),(new CssStyleParser()));
	 * 
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class CssStyleParser extends ArrayToStyleParser implements IStyleParser
	{
		/**
		 * 单条css对象正规表达式匹配
		 */
		private static const CSS_OBJECT_SPLIT:RegExp =  /\}[;|\s]*/g;
		/**
		 * 用来删除空白字符
		 */
		private static const STR_SPACE_REG:RegExp =  /\n\s*\r/g;
		
		/**
		 * 解析css语法的解析器
		 */
		public function CssStyleParser()
		{
			super();
		}
		
		/**
		 * 初始解析css字符串创建样式
		 * @param cssObject
		 */
		override public function initStyle(cssObject:Object):void
		{
			var str:String = cssObject.toString();
			str = str.replace(STR_SPACE_REG);
			
			var cssArr:Array = str.split(CSS_OBJECT_SPLIT);
			var resArr:Array = [];
			for each (var s:String in cssArr) 
			{
				if(!s || !s.length) continue;
				var tid:int = s.indexOf("{");
				var sName:String = s.substring(0,tid);
				var attrStr:String = s.substring(tid+1);
				
				var aCssObj:Object = createObj(attrStr);
				
				resArr.push(sName);
				resArr.push(aCssObj);
			}
			super.initStyle(resArr);
		}
		
		/**
		 * 通过冒号分号分隔符生成对象
		 */
		private function createObj(attrStr:String):Object
		{
			var cssObj:Object = {};
			var attrArr:Array = attrStr.split(";");
			for each (var s:String in attrArr) 
			{
				var tid:int = s.indexOf(":");
				var sName:String = s.substring(0,tid);
				var valStr:String = s.substring(tid+1);
				if(StyleUtils.isNumber(valStr))
					cssObj[sName] = Number(valStr);
				else
					cssObj[sName] = valStr;
			}
			return cssObj;
		}
	}
}