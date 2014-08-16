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
	import mapper.ReflCacheMgr;
	import mapper.event.ObjectEvent;
	import mapper.util.SrcUtils;

	/**
	 * XML对象解码器，可以把xml转换成对象，实现po,pojo,vo相互的转换
	 * @author Pelephone
	 */
	public class XMLObjectDecoder extends BaseMapper
	{
		public static const PARSE_OBJ_ATTR:String = "";	//解码对象属性
		
		// 是否强制给动态类加上属性
		private var isDynamicAttr:Boolean;
		
		/**
		 * 是否解析get/set属性
		 */
		public var isGetSet:Boolean = true;
		
		/**
		 * 是否解析xml节点到对象
		 */
		public var isNode:Boolean = true;
		
		/**
		 * 是否解析xml属性到对象
		 */
		public var isAttr:Boolean = true;
		
		public function XMLObjectDecoder()
		{
			clzMapper = new Object();
			isDynamicAttr = false;
		}
		
		/**
		 * 将xml解码转成vo
		 * @param xml
		 * @return 
		 */
		public function decode(xml:Object):*
		{
			quoteObj = {};
			var res:* = parseValue(xml);
			quoteObj = null;
			return res;
		}
		
		/**
		 * 通过类型和xml节点返回节点里生成的对象
		 * @param propType
		 * @param nodeXml
		 * @return 
		 */
		public function parseValue(nodeXml:Object,clzType:String=null):*
		{
			if(clzType==null)
				clzType = nodeXml.localName();
			
			var referenceObj:Object = nodeXml.@[REFERENCE_CLASS];
			if(referenceObj && referenceObj.toString()!=""){
				var refObj:Object = SrcUtils.getSrcByXML(referenceObj.toString(),nodeXml);
//				var str:String = getXMLParentSrc(refObj);
				refObj = quoteObj[refObj.toString()];
				// 暂时没写这步
				return refObj;
			}
			switch(clzType)
			{
				// 基本类型 如果是基本类型就直接在节点斌值
				case "int":
					return int(nodeXml);
				case "uint":
					return uint(nodeXml);
				case "Boolean":
					return Boolean(nodeXml);
				case "Number":
					return Number(nodeXml);
				case "String":
					return decodeURIComponent(String(nodeXml));
				case "Object":
					return parseObject(nodeXml);
				// 数组类型
				case "Array":
					return parseArray(nodeXml);
				default:
					var clz:Class = getClzByName(clzType);
					if(clz==null)
						return null;
					
					var o:Object = new clz();
//					var src:String = getXMLParentSrc(nodeXml);
					var qbName:String = String(nodeXml.toXMLString());
					if(!qbName || !qbName.length)
						return null;
					quoteObj[qbName] = o;
					return parseMappObject(nodeXml,o);
			}
		}
		
		/**
		 * 遍历找出引用对象,返回xml
		 * @param obj
		 * @return 
		 
		private function newQuoteObj(xml:Object,nodeName:String):XML
		{
			for(var key:Object in quoteObj) 
			{
				if(quoteObj[key]===xml)
					return new XML("<" + nodeName + " reference=\"" + key + "\" />");;
			}
			return null;
		}*/
		
		/**
		 * 将xml解析成数组
		 * @param xml
		 */
		private function parseArray(xml:Object):Array
		{
			var arr:Array = [];
//			var src:String = getXMLParentSrc(xml);
			quoteObj[xml.toXMLString()] = arr;
			for each (var node:Object in xml.children()) 
			{
				var clzName:String = node.localName();
				var valObj:* = parseValue(node);
				arr.push(valObj);
			}
			return arr;
		}
		
		/**
		 * 将xml解析成对象
		 * @param xml
		 * @return 
		 */
		private function parseObject(xml:Object):Object
		{
			var o:Object = new Object();
//			var src:String = getXMLParentSrc(xml);
			quoteObj[xml.toXMLString()] = o;
			for each (var node:Object in xml.children())
			{
				if(hasEventListener(PARSE_OBJ_ATTR)){
					var evtObj:Object = {tarObj:o,tarNode:node};
					dispatchEvent(new ObjectEvent(PARSE_OBJ_ATTR,evtObj));
					continue;
				}
				if(node.children().length() && node.children()[0].localName()){
					for each (var nodeChild:Object in node.children())
					{
						o[node.localName()] = parseValue(nodeChild);
					}
					continue;
				}
//				var valObj:* = parseValue(node);
//				if(!valObj) continue;
				o[node.localName()] = decodeURIComponent(String(node));
			}
			return o;
		}
		
		/**
		 * 将xml解析成mapper映射的对象
		 * @param xml
		 */
		private function parseMappObject(xml:Object,o:Object):*
		{
			if(o is Array)
				return parseArray(xml);
			var dest:Object = ReflCacheMgr.getDescribeType(o);
			//var classInfo:Object = describeType(o)["variable"];
			if(isNode)
				dealNodesToObj(xml.children(),o,dest);
			
			if(isAttr)
				dealNodesToObj(xml.attributes(),o,dest);
			
			return o;
		}
		
		/**
		 * 节点信息解析到对象
		 * @param nodes
		 * @param obj
		 * @param dest
		 */
		private function dealNodesToObj(nodes:Object,obj:Object,dest:Object):void
		{
			var classInfo:Object = dest["variable"];
			var desc2:XMLList = dest["accessor"];
			var cInf:Object;
			
			for each (var node:Object in nodes) 
			{
				var lName:String = node.localName();
				var xAttr:Object = desc2.(@name==lName);
				if(isGetSet && xAttr!=null && xAttr.length()>0)
				{
					var propAccess:String = xAttr.@access;
					if(propAccess.indexOf("write")<0) continue;
					cInf = desc2;
				}
				else
					cInf = classInfo;
				
				if(!obj.hasOwnProperty(lName) && !isDynamicAttr)
					continue;
				
				var clzName:String = getClassByAllSrc(cInf.(@name==lName).@type.toString());
				var valObj:* = parseValue(node,clzName);
				if(valObj==null) continue;
				obj[lName] = valObj;
			}
		}
		/////////////////////////////////////////
		// 工具方法
		////////////////////////////////////////
		
		
		/**
		 * xml某节点生成../../aa[2]/bb格式的路径
		 * @param xmlNode
		 
		private function getXMLParentSrc(xmlNode:Object,str:String=null):String
		{
			if(!str){
				str = xmlNode.localName().toString();
			}
			else
			{
				// 数组对象特殊处理
				if(xmlNode.parent())
				{
					var str:String = getXMLParentSrc(xmlNode.parent());
					if(quoteObj[str] is Array){
						var idNum:int = -1;
						for each (var node:Object in xmlNode.children()) 
						{
							if(node===xmlNode){
								idNum++;
								break;
							}
						}
						
//						str = xmlNode.localName().toString() + "[" + idNum + "]" + "/" + str;
						str = "children[" + idNum + "]\/" + str;
					}
				}
				else
					str = xmlNode.localName().toString() + "/" + str;
			}
			if(xmlNode.parent())
				return getXMLParentSrc(xmlNode.parent(),str);
			else
				return str;
		}*/
	}
}