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
package mapper.xml
{
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mapper.event.ObjectEvent;
	import mapper.xml.XMLEncoder;
	
	/**
	 * 专用入解析java,xscream的编码器
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class JavaXMLMapper extends XmlMapper
	{
		/**
		 * java的哈希表眼as的Object存储有些区别,遇到这个节点需要特殊处理
		 */
		private static var OBJECT_ENTRY_ATTR:String = "entry";
		private static var OBJECT_MAP_ATTR:String = "map";
		
		public function JavaXMLMapper()
		{
			super();
			
			xmlEncoder.addEventListener(XMLEncoder.PARSE_OBJECT_TO_XML,encodeObjAttrXML);
			xmlDecoder.addEventListener("",decodeObjAttrXML);
		}
		
		/**
		 * 解析object属性编码为java对应hashmap形式的xml
		 * @param e
		 */
		private function encodeObjAttrXML(e:ObjectEvent):void
		{
			var xx:XML = new XML("<" + OBJECT_ENTRY_ATTR + ">" +
				"<String>" + e.data.key + "</String>" +
				"</" + OBJECT_ENTRY_ATTR + ">");
			
			if(e.data.value==null){
				xx.appendChild(<null />);
				e.data.backXML = xx;
				return;
			}
			var keyType:String = getQualifiedClassName(e.data.value);
			keyType = getClassByAllSrc(keyType);
			var alType:String = xmlEncoder.getAliasByClzName(keyType);
			keyType = alType || keyType;
			var oName:String =  OBJECT_ENTRY_ATTR + "[" + e.data.inum + "]/" + keyType;
			e.data.backXML = xmlEncoder.convertToXML(e.data.value,e.data.xmlSrc,oName);
			xx.appendChild(e.data.backXML);
			e.data.backXML = xx;
		}
		
		/**
		 * 解码java的hashmap字符,解码为as的Object属性
		 * @param e
		 */
		private function decodeObjAttrXML(e:ObjectEvent):void
		{
			if(e.data.tarNode.localName()==OBJECT_ENTRY_ATTR)
			{
				e.data.tarObj[e.data.tarNode.children()[0].toString()] = 
					xmlDecoder.parseValue(e.data.tarNode.children()[1]);
			}
		}
		
		/**
		 * 获取类型
		 * @param value
		 * @return 
		 */
		private function getType(value:Object):String
		{
			var str:String = describeType( value ).@name.toString();
			return getClassByAllSrc(str);
		}
	}
}