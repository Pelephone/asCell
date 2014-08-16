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
	import flash.utils.getQualifiedClassName;
	
	import mapper.BaseMapper;
	import mapper.ReflCacheMgr;
	import mapper.event.ObjectEvent;
	import mapper.util.SrcUtils;

	/**
	 * XML对象解析解码器，本工具有Pelephone封闭
	 * @website http://www.cnblogs.com/pelephone
	 * @author Pelephone
	 */
	public class XMLEncoder extends BaseMapper
	{
		/**
		 * 解析对象数据发出消息,因为java,c解析object的方式都不一样,可以的听此消息进行处理
		 */
		public static const PARSE_OBJECT_TO_XML:String = "parse_object_to_xml";
		
		/** 
		 * 此参数是用来防止嵌套引用报错的，如A有个属性B，B个属性A，两个对象相互引用。obj转xml时会出错。
		 * 如果相互引用的bug出现时，生成的代码最多只生成 traversalDepth 次。20次后就设null;
		 * 设为-1则不停循环
		 
		private var traversalDepth:int = 20;*/
		
		public function XMLEncoder()
		{
		}
		
		/**
		 * 把对象转换为xml
		 */
		public function encode( o:* ):XML
		{
			quoteObj = {};
			var xml:XML = convertToXML( o );
			quoteObj = null;
			return xml;
		}
		
		/**
		 * 将对象跟椐各类型转成xml
		 *
		 * @param 转换变量.  能转成object,number,array,等等
		 */
		public function convertToXML( value:*, xmlSrc:String="", objName:String=null):XML
		{
/*			// 如果遍历值不为-1，就判断生成的层级是否超过允许值，不然对象互相引用会进入死循环递归
			if(traversalDepth!=-1 && tranNum>traversalDepth)
				return null;*/
			
			if ( value is String ) {
				
				// 转换字符串里面的特殊符号
				return newXMLByValue("String",encodeURIComponent( value as String ));
			}
			else if ( value is int ) {
				
				return newXMLByValue("int",( value as int ));
			}
			else if ( value is uint ) {
				
				return newXMLByValue("int",( value as uint ));
			}
			else if ( value is Number ) {
				
				return newXMLByValue("Number",( value as Number ));
			}
			else if ( value is Boolean ) {
				
				return newXMLByValue("Boolean",value);
				
			}
			else if ( value is Array ) {
				
				// 调用数组转换方法转换对象
				return arrayToXML( value as Array, xmlSrc, objName);
			}
			else if ( value is Class ) {
				
				return null;
			}
			else if ( value is Object && value != null ) {
				
				// 调用对象转换方法转换对象
				return objectToXML( value ,xmlSrc, objName);
			}
			return null;
		}
		
		/**
		 * 将数组对象转换成XML
		 *
		 * @param 要转换的数组对象
		 * @return XML
		 */
		private function arrayToXML( a:Array, xmlSrc:String=null,objName:String=null):XML {
			var x:XML = new XML("<Array/>");
			
			for ( var i:int = 0; i < a.length; i++ ) {
				if(a[i]==null){
					x.appendChild(<null />);
					continue;
				}
//				var oName:String = xmlSrc +"/" + objName + "[" + i + "]" ;
				var oName:String = objName + "\/" + SrcUtils.XML_CHILDREN_STR + "[" + i + "]" ;
				// 将子数组里的子对象转换成xml并加到xml上
				x.appendChild(convertToXML( a[i], xmlSrc, oName ));
			}
			return x;
		}
		
		/**
		 * 遍历找出引用对象,返回xml
		 * @param obj
		 * @return 
		 */
		private function newQuoteXML(obj:Object,nodeName:String,mySrc:String):XML
		{
			for(var key:Object in quoteObj) 
			{
				if(quoteObj[key]===obj){
					var src:String = SrcUtils.changeRefSrc(mySrc,String(key));
					return new XML("<" + nodeName + " " + REFERENCE_CLASS + "=\"" + src + "\" />");
				}
			}
			return null;
		}
		
		/**
		 * 将对象解析成xml形式
		 * @param obj			要解析的obj
		 * @param xmlSrc	  	obj在xml的路径
		 * @return 
		 */		
		private function objectToXML(obj:Object, xmlSrc:String=null,objName:String=null):XML
		{
			var nodeName:String = getBaseClzStr(obj);
			
			objName = objName || nodeName;
			xmlSrc = xmlSrc + "/" + objName;
			var refStr:* = newQuoteXML(obj,nodeName,xmlSrc);
			if(refStr){
				return refStr;
			}
			quoteObj[xmlSrc]=obj;
			
			// 创建一个xml节点对象
			var objXml:XML = new XML("<" + nodeName + "/>");
			var classInfo:XML = ReflCacheMgr.getDescribeType(obj);
//			var classInfo:XML = describeType( obj );
			
			// 如果对象是"Object"类型
			if ( classInfo.@name.toString() == "Object" )
			{
				// 遍历对象的值暂存
				var value:Object;
				var inum:int = 0;
				
				// 遍历对象所有属性
				for ( var key:String in obj )
				{
					value = obj[key];
					
					// 函数对象就过滤掉，不转换
					if ( value is Function )
					{
						// skip this key and try another
						continue;
					}
					
//					var xmlVal:Object = convertToXML(value,tranNum,xmlSrc);
//					var xmlVal:Object = newObjectXML(key,value,xmlSrc,key);
					
					var parObj:Object = new Object();
					parObj.backXML = null;
					parObj.key = key;
					parObj.value = value;
					parObj.xmlSrc = xmlSrc;
					parObj.inum = inum;
					if(hasEventListener(PARSE_OBJECT_TO_XML)){
						dispatchEvent(new ObjectEvent(PARSE_OBJECT_TO_XML,parObj));
					}else{
						parObj.backXML = convertToXML(value,xmlSrc,key);
						if(key)	parObj.backXML.setLocalName(key);
					}
//					var xmlVal:XML = convertToXML(value,xmlSrc,key);
//					if(key)	parObj.backXML.setLocalName(key);
					inum++;
					objXml.appendChild(parObj.backXML);
				}
				return objXml;
			}
			
			// 设置 obj 的每个属性 prop
			//			for each(var prop:XML in classInfo)
			
			for each ( var v:XML in classInfo..*.( 
				name() == "variable"
				||
				( 
					name() == "accessor"
					// Issue #116 - 保证 accessors 可读
					&& attribute( "access" ).charAt( 0 ) == "r" ) 
			) )
			{
				// Issue #110 - If [Transient] metadata exists, then we should skip
				if ( v.metadata && v.metadata.( @name == "Transient" ).length() > 0 )
				{
					continue;
				}
				if(!obj[ v.@name ]) continue;
				
				// 如果只解析映射表里的对象则进行映射表内判断
				if(isOnlyMapper){
					var clzName:String = getClassByAllSrc(classInfo.@name.toString());
					if(!getClzByName(clzName)) continue;
				}
				
				var xmlSrc2:String =  xmlSrc + "/" + v.@name;
				var x:XML = convertToXML(obj[ v.@name ], xmlSrc, v.@name);
				if(x==null) continue;
				x.setLocalName(v.@name.toString());
				objXml.appendChild(x);
			}
			
			return objXml;
		}
		
		/**
		 * 创建一个新的对象对应的xml数据
		 * @param key		键值
		 * @param value		对象
		 * @param tranNum	层次
		 * @return 
		 
		protected function newObjectXML(key:Object,value:Object,xmlSrc:String="",objName:String=null):XML
		{
			var xmlVal:XML = convertToXML(value,xmlSrc,objName);
			if(objName)	xmlVal.setLocalName(objName);
//			xmlVal = newXMLByValue(String(key),xmlVal);
			return xmlVal;
		}*/
		
		////////////////////////////////////////////
		// 通用工具方法
		////////////////////////////////////////////
		
		/**
		 * 创建新xml元素
		 * @param propType
		 * @param value
		 * @return 
		 */
		protected function newXMLByValue(propType:String,value:Object=null):XML
		{
			if(!value) return null;
			var xml:XML = new XML("<" + propType + ">" + "</" + propType + ">");
			xml.appendChild(value);
			return xml;
		}
		
		/**
		 * 是否是基本类型(如int,String)
		 * @param obj
		 * @return 
		 */
		private function getBaseClzStr(obj:Object):String
		{
			var objClzName:String = getQualifiedClassName(obj);
			switch(objClzName)
			{
				case "int":
				case "uint":
				case "Boolean":
				case "Number":
				case "String":
				case "Array":
					return 	objClzName;				
				default:
					objClzName = getClassByAllSrc(objClzName);
					objClzName = getAliasName(objClzName);
					return objClzName;
			}
		}
		/**
		 * 转换类名
		 * 将flash.display::Sprite这样形式的字符串换成Sprite
		 * @param reObjStr
		 * @return 
		 */
		public static function getClassByAllSrc(reObjStr:String):String
		{
			var lid:int = reObjStr.lastIndexOf("::");
			if(lid<0) return reObjStr;
			return reObjStr.substring(lid+2);
		}
	}
}