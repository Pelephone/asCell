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
package mapper.util
{
	public class SrcUtils
	{
		public static const XML_CHILDREN_STR:String = "children";	//子节点属性 (遍历出这个字符就特殊处理数组)
		
		/**
		 * 通过目标路径和自己的路径径转成相对路径(例如aa/bb.另一个是aa/cc)最后得出的结果是../cc
		 * @param keySrc	aa/bb/cc的形式
		 * @param mySrc		同keySrc
		 * @return 
		 */
		public static function changeRefSrc(mySrc:String,tarSrc:String):String
		{
			// 先把相同的部份给去掉
			var strx:String = tarSrc.length>mySrc.length?tarSrc:mySrc;
			
			var tarArr:Array = tarSrc.split("\/");
			var myArr:Array = mySrc.split("\/");
			var strArr:Array = tarArr.length>myArr.length?tarArr:myArr;
			
			while(strArr.length){
				if(tarArr[0]==myArr[0])
				{
					tarArr.shift();
					myArr.shift();
				}
				else break;
			}
			
			var str:String = "";
			for (var i:int = 0; i < myArr.length; i++) 
			{
				str += "../";
			}
			str += tarArr.join("\/");
			
			return str;
		}
		
		
		
		/**
		 * 通过路径和xml节点
		 * @param src
		 * @param xml
		 */
		public static function getSrcByXML(src:String,xml:Object):*
		{
			var paths:Array = src.split("\/");
			for each (var tarStr:String in paths) 
			{
				if(!tarStr || !tarStr.length)
					continue;
				
				if(tarStr==".."){
					xml = xml.parent();
					continue;
				}
				var tid:int = tarStr.indexOf("[");
				if(tid>0)
				{
					var xmlname:String= tarStr.substr(0,tid);
					var arrId:int = int(tarStr.substring(tid+1,(tarStr.length-1)));
					if(xmlname==XML_CHILDREN_STR)
						xml = xml.children()[arrId];
					else
						xml = xml.elements(xmlname)[arrId];
					continue;
				}
				xml = xml.elements(tarStr);
			}
			return xml;
		}
	}
}