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
	import mapper.BaseMapper;

	/**
	 * xml映射工具,可以将vo/po与xml互相转换
	 * @website http://www.cnblogs.com/pelephone
	 * @author Pelephone
	 */
	public class XmlMapper extends BaseMapper
	{
		private var _xmlEncoder:XMLEncoder;			//xml编码器
		private var _xmlDecoder:XMLObjectDecoder;	//xml对象解码器
		
		/** 
		 * 此参数是用来防止嵌套引用报错的，如A有个属性B，B个属性A，两个对象相互引用。obj转xml时会出错。
		 * 如果相互引用的bug出现时，生成的代码最多只生成 traversalDepth 次。9次后就设null;
		 
		private var traversalDepth:int = 9;*/
		
		public function XmlMapper()
		{
			_xmlEncoder = new XMLEncoder();
			_xmlDecoder = new XMLObjectDecoder();
			
			clzMapper = {};
			xmlEncoder.clzMapper = clzMapper;
			xmlDecoder.clzMapper = clzMapper;
			
			aliasMapper = {};
			xmlEncoder.aliasMapper = aliasMapper;
			xmlDecoder.aliasMapper = aliasMapper;
		}
		
		/**
		 * 把对象转换成xml格式的字符串
		 * @param obj
		 * @return 
		 */
		public function toXML(obj:Object):XML
		{
			return xmlEncoder.encode(obj);
		}
		
		/**
		 * 把xml字符串转换成obj对象
		 * @param xml
		 */		
		public function fromXMLStr(xmlStr:String):*
		{
			var xml:XML = new XML(xmlStr);
			return xmlDecoder.decode(xml);
		}
		
		/**
		 * 把xml转换成obj对象
		 * 因为有可能是XML,XMLList其中一个,所以这里用参数Object
		 * @param xml
		 */		
		public function fromXML(xml:Object):*
		{
			return xmlDecoder.decode(xml);
		}
		
		override public function set isOnlyMapper(value:Boolean):void
		{
			super.isOnlyMapper = value;
			xmlEncoder.isOnlyMapper = xmlDecoder.isOnlyMapper = value;
		}

		public function get xmlEncoder():XMLEncoder
		{
			return _xmlEncoder;
		}

		public function get xmlDecoder():XMLObjectDecoder
		{
			return _xmlDecoder;
		}


	}
}