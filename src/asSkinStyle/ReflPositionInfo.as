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
* WITHOUT WARRANTIES 
*/
package asSkinStyle
{
	import asSkinStyle.i.IDrawBase;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	
	/**
	 * 位置坐标信息信息
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class ReflPositionInfo
	{
		/**
		 * 注册引用对象，解析的时候用于赋值引用对象
		 */
		public static var refValue:Object = {};
		
		/**
		 * 是否严格json,(属性名是否加双引号)
		 */
		public static var STRICT_JSON:Boolean = false;
		
		/**
		 * 是否生成默认值为0的属性
		 */
		public static var IS_DO_DEFAULT:Boolean = false;
		/**
		 * 待生成的属性名
		 */
		public static var REF_ATTR_LS:Vector.<String> = new <String>["x","y","width","height"];
		/**
		 * 需四舍五入的属性名
		 */
		public static var INIT_ATTR_LS:Vector.<String> = new <String>["x","y","width","height"];
		
		public static var UI_TYPE_ATTR:String = "uiType";
		/**
		 * 是否创建对象
		 */
		public static var isCreateType:Boolean = true;
		
		/**
		 * 是否生成子项代码
		 */
		public static var isCreateChild:Boolean = true;
		
		/**
		 * 注册引用对象
		 * @param name
		 * @param value
		 */
		public static function regRefValue(name:String,value:Object):void
		{
			refValue[name] = value;
		}
		
		/**
		 * 移除引用对象
		 * @param name
		 */
		public static function removeRefValue(name:String):void
		{
			refValue[name] = null;
			delete refValue[name];
		}
		
		/**
		 * 是否创建属性对象代码
		 */
		public static var isAttrCode:Boolean = false;
		
		/**
		 * 判断对象是否需要生成代码
		 * @param dsp
		 * @return 
		 */
		private static function isNeedCode(dsp:DisplayObject):Boolean
		{
			if(dsp == null)
				return false;
			if(dsp.hasOwnProperty("noCode") && dsp["noCode"] == true)
				return false;
			
			var dspc:DisplayObjectContainer = dsp.parent;
			if(dspc == null)
				return false;
			
			if(dspc.hasOwnProperty("noCodeChild") && dspc["noCodeChild"] == true)
				return false;
			
			if(!isAttrCode && dspc.hasOwnProperty(dsp.name))
				return false;
			
			return true;
		}
		
		/**
		 * 将对象的所有子项解析成xml
		 * @param dspc 要解析的显示对象
		 * @param isDoDef 是否默认值也生成,0是默认值
		 * @param ignoreNameLs 忽略名
		 * @return 
		 */
		public static function encodeChildToXml(dspc:DisplayObjectContainer,xml:XML=null):XML
		{
			if(xml == null)
				xml = new XML(<deCode />);
			// 要反射的属性
			var refAttrLs:Vector.<String> = REF_ATTR_LS;
			for (var i:int = 0; i < dspc.numChildren; i++) 
			{
				var dsp:DisplayObject = dspc.getChildAt(i);
				if(!isNeedCode(dsp))
					continue;
				
				var itmX:XML = new XML(<item />);
				var attrNum:int = 0;
				for each (var itmStr:String in refAttrLs) 
				{
					if(!isCanCode(dsp,itmStr,INIT_ATTR_LS))
						continue;
					
					itmX.@[itmStr] = dsp[itmStr];
					attrNum = attrNum + 1;
				}
				if(attrNum>0)
				{
					itmX.@["name"] = dsp.name;
					xml.appendChild(itmX);
				}
				
				if(!isCreateChild || !dsp.hasOwnProperty(UI_TYPE_ATTR))
					continue;
				
				var cdsp:DisplayObjectContainer = dsp as DisplayObjectContainer;
				if(!cdsp || cdsp.numChildren == 0)
					continue;
				
				encodeChildToXml(cdsp,itmX);
			}
			return xml;
		}
		
		/**
		 * 判断对象属性是否可生成
		 * @return 
		 */
		private static function isCanCode(dsp:DisplayObject,attrName:String,intAttrLs:Vector.<String>=null):Boolean
		{
			if(!dsp.hasOwnProperty(attrName))
				return false;
			if(!IS_DO_DEFAULT)
			{
				if(intAttrLs == null)
					intAttrLs = INIT_ATTR_LS;
				var isWH:Boolean = ((dsp is TextField) || (dsp is IDrawBase));
				if(!isWH && attrName == "width" && dsp.scaleX == 1)
					return false;
				else if(!isWH && attrName == "height" && dsp.scaleY == 1)
					return false;
				else if(intAttrLs.indexOf(attrName)>=0 && int(dsp[attrName])==0)
					return false;
			}
			return true;
		}
		
		/**
		 * 将xml上的位置信息解析到子项
		 * @param xml
		 */
		public static function decodeXmlToChild(dspc:DisplayObjectContainer,xml:Object):void
		{
			for each (var itmX:Object in xml.children()) 
			{
				var vName:String = itmX.@name;
				var dsp:DisplayObject = dspc.getChildByName(vName);
				var uiType:String = itmX.attribute(UI_TYPE_ATTR);
				if(!dsp)
				{
					if(!isCreateType)
						continue;
					
					dsp = typeToDsp(uiType);
					if(dsp == null)
						continue;
					dspc.addChild(dsp);
				}
				for each (var itm2:Object in itmX.attributes()) 
				{
					var val:Object = itm2;
					var n:String = itm2.name();
					if(n == "name")
						continue;
					if(String(val).indexOf("$")==0)
					{
						var s2:String = String(val).substr(1);
						if(refValue.hasOwnProperty(s2))
							val = refValue[s2];
					}
					dsp[n] = val;
				}
				
				
				if(!isCreateChild || !uiType || !uiType.length || !dsp.hasOwnProperty(UI_TYPE_ATTR))
					continue;
				
				var cdsp:DisplayObjectContainer = dsp as DisplayObjectContainer;
				if(!cdsp || cdsp.numChildren == 0)
					continue;
				
				decodeXmlToChild(cdsp,itmX);
			}
		}
		
		// 通过ui类型生成显示对象
		private static function typeToDsp(uiType:String):DisplayObject
		{
			if(!isCreateType || !uiType || !uiType.length)
				return null;
			
			var cls:Class = refValue[uiType];
			if(cls == null)
				return null;
			
			var dsp:DisplayObject = new cls();
			if(!dsp)
				return null;
			
			if(dsp.hasOwnProperty(UI_TYPE_ATTR))
				dsp[UI_TYPE_ATTR] = uiType;
			
			return dsp;
		}
		
		//---------------------------------------------------
		// 解析对象
		//---------------------------------------------------
		
		/**
		 * 是否紧凑显示
		 */
		public static var IS_NEAR:Boolean = true;
		
		/**
		 * 将对象的所有子项解析成Object
		 * @param dspc 要解析的显示对象
		 * @param isDoDef 是否默认值也生成,0是默认值
		 * @return 
		 */
		public static function encodeChildToJson(dspc:DisplayObjectContainer):String
		{
			var resStr:String = STRICT_JSON?"{\n":"[\n";
			// 要反射的属性
			
			var refAttrLs:Vector.<String> = REF_ATTR_LS;
			
			for (var i:int = 0; i < dspc.numChildren; i++) 
			{
				var dsp:DisplayObject = dspc.getChildAt(i);
				
				var itmObj:Object = {};
				if(!IS_NEAR)
				var itmS:String = "{\n";
				else
					itmS = "{";
				
				var attrNum:int = 0;
				for (var j:int = 0; j < refAttrLs.length; j++) 
				{
					var itmStr:String = refAttrLs[j] as String;
					
					if(!isCanCode(dsp,itmStr,INIT_ATTR_LS))
						continue;
					
					if(attrNum>0)
						itmS = itmS + ",";
						
					if(STRICT_JSON)
						itmS = itmS + "\"" + itmStr + "\"";
					else
						itmS = itmS + itmStr;
					
					
					if(dsp[itmStr] is String)
						itmS = itmS + ":\"" + dsp[itmStr] + "\"";
					else if(INIT_ATTR_LS.indexOf(itmStr)>=0)
						itmS = itmS + ":" + Math.round(dsp[itmStr]);
					else
						itmS = itmS + ":" + dsp[itmStr];
					
					if(!IS_NEAR)
					itmS = itmS + "\n";
					
					attrNum = attrNum + 1;
				}
				
				if(attrNum>0)
				{
					if(STRICT_JSON)
						itmS = itmS + ",\"name\":\"";
					else
						itmS = itmS + ",name:\"";
					
					if(!IS_NEAR)
					itmS = itmS + dsp.name + "\"\n}";
					else
					itmS = itmS + dsp.name + "\"}";
					
					resStr = resStr + itmS;
					if(i<(dspc.numChildren - 1))
						resStr = resStr + "\n,";
				}
			}
			resStr = resStr + (STRICT_JSON?"\n}":"\n]");
			return resStr;
		}
		
		/**
		 * 将对象的所有子项解析成Object
		 * @param dspc 要解析的显示对象
		 * @param isDoDef 是否默认值也生成,0是默认值
		 * @return 
		 */
		public static function encodeChildToObj(dspc:DisplayObjectContainer):Object
		{
			var res:Array = [];
			// 要反射的属性
			var refAttrLs:Vector.<String> = REF_ATTR_LS;
			for (var i:int = 0; i < dspc.numChildren; i++) 
			{
				var dsp:DisplayObject = dspc.getChildAt(i);
				if(!dsp)
					continue;
				
				var itmObj:Object = {};
				var attrNum:int = 0;
				for (var j:int = 0; j < refAttrLs.length; j++) 
				{
					var itmStr:String = refAttrLs[j] as String;
					if(!isCanCode(dsp,itmStr,INIT_ATTR_LS))
						continue;
					if(INIT_ATTR_LS.indexOf(itmStr)>=0)
						itmObj[itmStr] = Math.round(dsp[itmStr]);
					else
						itmObj[itmStr] = dsp[itmStr];
					attrNum = attrNum + 1;
				}
				
				if(attrNum>0)
				{
					itmObj["name"] = dsp.name;
					res.push(itmObj);
				}
			}
			return res;
		}
		
		/**
		 * 将对象上的位置信息解析到子项
		 * @param xml
		 */
		public static function decodeObjToChild(dspc:DisplayObjectContainer,obj:Object):void
		{
			for each (var itmX:Object in obj) 
			{
				var vName:String = itmX.name;
				var dsp:DisplayObject = dspc.getChildByName(vName);
				var uiType:String = null;
				if(itmX.hasOwnProperty(UI_TYPE_ATTR))
					uiType = itmX[UI_TYPE_ATTR];
				if(!dsp)
				{
					if(!isCreateType)
						continue;
					
					dsp = typeToDsp(uiType);
					if(dsp == null)
						continue;
					dspc.addChild(dsp);
				}
				for (var itm2:Object in itmX) 
				{
					var val:Object = itmX[itm2];
					if(val == "name" || !dsp.hasOwnProperty(itm2))
						continue;
					dsp[itm2] = val;
				}
			}
		}
		
		/**
		 * 将Json上的位置信息解析到子项
		 */
		public static function decodeJsonToChild(dspc:DisplayObjectContainer,json:String):void
		{
			var reg:RegExp = /[\r\n\s\t\r\"\']/g;
			json = json.replace(reg,"");
			var jObj:Object = parseJson(json);
			decodeObjToChild(dspc,jObj);
		}
		
		/**
		 * 把解析json转为Object对象
		 * @param json
		 * @return 
		 */
		private static function parseJson(json:String):Object
		{
			var mark:String = json.substr(0,1) + json.substr(json.length - 1);
			var contStr:String = json.substr(1,(json.length - 2));
			var ary:Array;
			var valObj:Object;
			switch(mark)
			{
				case "[]":
				{
					valObj = [];
					ary = contStr.split("},");
					for each (var itm:String in ary) 
					{
						var str:String = itm;
						if(itm.lastIndexOf("}")<0)
							str = str + "}";
						valObj.push(parseJson(str));
					}
					break;
				}
				case "{}":
				{
					valObj = {};
					ary = contStr.split(",");
					for each (itm in ary) 
					{
						var iAry:Array = itm.split(":");
						
						var val:Object = iAry[1];
						if(String(val).indexOf("$")==0)
						{
							var s2:String = String(val).substr(1);
							if(refValue.hasOwnProperty(s2))
								val = refValue[s2];
						}
						valObj[iAry[0]] = val;
					}
					break;
				}
			}
			return valObj;
		}
	}
}