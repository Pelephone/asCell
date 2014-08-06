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
	import asSkinStyle.data.StyleComposite;
	
	import flash.utils.describeType;

	/**
	 * UI工具类
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	internal class StyleUtils
	{
		/**
		 * 通过空格语法获取项
		 * @param spName
		 * @return 
		 */
		internal static function getCssBySplitName(spName:String,cpe:StyleComposite):StyleComposite
		{
			if(spName.indexOf(ArrayToStyleParser.SEPARATOR_CHILD)<0)
			{
				return cpe.getChildByName(spName);
			}
			var arr:Array = spName.split(ArrayToStyleParser.SEPARATOR_CHILD);
			var cps:StyleComposite = cpe;
			for each (var str:String in arr) 
			{
				cps = cps.getChildByName(str);
				if(!cps) return null;
			}
			return cps;
		}
		
		/**
		 * 通过对象复制属性数据给resObj
		 * @param resObj
		 * @param newObj
		 * @param isStrict	是否严格，true时resObj有属性才赋值，false则会给resObj动态添属性
		 * @param ignoreProps	忽略的属性名列表
		 * @return 			返回改变属性后的原对象
		 */
		internal static function setObjByVars(resObj:Object,newObj:Object
											  ,isStrict:Boolean=true, ignoreProps:Array=null):Object
		{
			if(!newObj) return null;
			// 遍历样式对象属性改变dc的属性值
			for (var attName:String in newObj) 
			{
				var voVars:Object = newObj[attName] as Object;
				if(ignoreProps && ignoreProps.indexOf(attName)>=0) continue;
				if(isStrict && !resObj.hasOwnProperty(attName)) continue;
				resObj[attName] = voVars;
			}
			return resObj;
		}
		
		
		////////////////////////////////////////////////
		// xml解析部分
		///////////////////////////////////////////////
		
		/**
		 * 通过xml或xmlList节点对象生成动态对象
		 * @param xml
		 * @param filterAttrs
		 * @return 不生成的属性名
		 */
		internal static function xmlCreateObject(xml:Object,toVars:Object=null,filterAttrs:Array=null):Object
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return null;
			toVars = toVars || {};
			for each (var child:Object in xml.attributes()) 
			{
				if(filterAttrs && filterAttrs.indexOf(String(child))>=0)
					continue;
				if(isNumber(child.toString()))
					toVars[child.localName()] = Number(child);
				else
					toVars[child.localName()] = child.toString();
			}
			return toVars;
		}
		
		/** 
		 * 是否是数值字符串;
		 */
		internal static function isNumber(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			return !isNaN(Number(char))
		}
		
		/**
		 * 将xml上的属性信息解析到单个对象
		 * @param xml			要解析的xml
		 * @param obj	  		要将xml解析到对象类
		 * @param ignoreProps	忽略的属性名列表
		 * @return 
		 */		
		static public function parseXMLItem(xml:Object, obj:Object, ignoreProps:Array=null):*
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return;
			
			var desc:XMLList = describeType( obj )["variable"];
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				
				var list:XMLList = xml.attribute(propName);
				// 先判断是否有此属性,没有再判断是否有些节点
				if(!list.length()) list = xml.child(propName);
				// 如果无节点或者节点是数组则不解析
				if(!list.length() || list.length()>1) continue;
				
				switch(propType)
				{
					// 基本类型
					case "Boolean":
						obj[propName] = Boolean(int(list))
						break;
					case "int":
					case "uint":
					case "String":
					case "Number":
					{
						obj[propName] = list;		// 变量名 和 xml节点名 必须相同 
					}
						break;
				}
			}
			return obj;
		}
		
		/**
		 * 解析xml并生成新的对象返回
		 * @param xml		  要解析的xml
		 * @param tClass	  要将xml解析生成的类
		 * @param ignoreProps 忽略的属性名列表
		 * @return 
		 */		
		static public function parseXMLByClass(xml:Object, tClass:Class, ignoreProps:Array=null):*
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return;
			var obj:Object = new (tClass)();
			parseXMLItem(xml,obj,ignoreProps);
			return obj;
		}
		
		/**
		 * 将xml解析到数组对象里面,不包括子节点
		 * @param xmlList
		 * @param defaultClass
		 * @param ignoreProps
		 * @return 
		 */		
		static public function parseXMLList(xmlList:XMLList, defaultClass:Class, ignoreProps:Array=null):Array
		{
			if(xmlList==null || defaultClass==null) return null;
			var arr:Array = new Array;
			for each(var xml:XML in xmlList)
			{
				var obj:Object = parseXMLByClass(xml, defaultClass, ignoreProps);
				arr.push( obj ); 
			}
			return arr;
		}
	}
}