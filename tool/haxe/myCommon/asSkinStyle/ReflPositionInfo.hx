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
package asSkinStyle;

import asSkinStyle.i.IDrawBase;
	
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;

/**
 * 位置坐标信息信息
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class ReflPositionInfo
{
	/**
	 * 注册引用对象，解析的时候用于赋值引用对象
	 */
	public static var refValue:Object = {};
	
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
	 * 将对象的所有子项解析成xml
	 * @param dspc 要解析的显示对象
	 * @param isDoDef 是否默认值也生成,0是默认值
	 * @param ignoreNameLs 忽略名
	 * @return 
	 * 
	 */
	public static function encodeChildToXml(dspc:DisplayObjectContainer,isDoDef:Boolean=false
											,ignoreNameLs:Vector.<String>=null):XML
	{
		var xml:XML = new XML(<root />);
		// 要反射的属性
		var refAttrLs:Vector.<String> = new <String>["x","y","width","height"];
		for (var i:int = 0; i < dspc.numChildren; i++) 
		{
			var dsp:DisplayObject = dspc.getChildAt(i);
			if(ignoreNameLs && ignoreNameLs.indexOf(dsp.name)>=0)
				continue;
			var itmX:XML = new XML(<item />);
			var attrNum:int = 0;
			for each (var itmStr:String in refAttrLs) 
			{
				if(!isCanCode(dsp,itmStr,isDoDef))
					continue;
				
				itmX.@[itmStr] = dsp[itmStr];
				attrNum = attrNum + 1;
			}
			if(attrNum>0)
			{
				itmX.@["name"] = dsp.name;
				xml.appendChild(itmX);
			}
		}
		return xml;
	}
	
	/**
	 * 判断对象属性是否可生成
	 * @return 
	 */
	private static function isCanCode(dsp:DisplayObject,attrName:String
									  ,isDoDef:Boolean=false):Boolean
	{
		
		if(!dsp.hasOwnProperty(attrName))
			return false;
		if(!isDoDef)
		{
			var isWH:Boolean = ((dsp is TextField) || (dsp is IDrawBase));
			if(!isWH && attrName == "width" && dsp.scaleX == 1)
				return false;
			else if(!isWH && attrName == "height" && dsp.scaleY == 1)
				return false;
			else if(int(dsp[attrName])==0)
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
			if(!dsp)
				continue;
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
		}
	}
	
	//---------------------------------------------------
	// 解析对象
	//---------------------------------------------------
	
	/**
	 * 将对象的所有子项解析成Object
	 * @param dspc 要解析的显示对象
	 * @param isDoDef 是否默认值也生成,0是默认值
	 * @return 
	 */
	public static function encodeChildToJson(dspc:DisplayObjectContainer,isDoDef:Boolean=false
											,ignoreNameLs:Vector.<String>=null):String
	{
		var resStr:String = "[";
		// 要反射的属性
		var refAttrLs:Vector.<String> = new <String>["x","y","width","height"];
		var intAttrLs:Vector.<String> = new <String>["x","y","width","height"];
		
		for (var i:int = 0; i < dspc.numChildren; i++) 
		{
			var dsp:DisplayObject = dspc.getChildAt(i);
			
			if(ignoreNameLs && ignoreNameLs.indexOf(dsp.name)>=0)
				continue;
			
			var itmObj:Object = {};
			var itmS:String = "{";
			var attrNum:int = 0;
			for (var j:int = 0; j < refAttrLs.length; j++) 
			{
				var itmStr:String = refAttrLs[j] as String;
				
				if(!isCanCode(dsp,itmStr,isDoDef))
					continue;
				
				if(dsp[itmStr] is String)
					itmS = itmS + itmStr + ":\"" + dsp[itmStr] + "\"";
				else if(intAttrLs.indexOf(itmStr)>=0)
					itmS = itmS + itmStr + ":" + Math.round(dsp[itmStr]);
				else
					itmS = itmS + itmStr + ":" + dsp[itmStr];
				
				itmS = itmS + ",";
				attrNum = attrNum + 1;
			}
			
			if(attrNum>0)
			{
				itmS = itmS + "name:" + dsp.name + "}";
				resStr = resStr + itmS;
				if(i<(dspc.numChildren - 1))
					resStr = resStr + "\n,";
			}
		}
		resStr = resStr + "]";
		return resStr;
	}
	
	
	/**
	 * 将对象的所有子项解析成Object
	 * @param dspc 要解析的显示对象
	 * @param isDoDef 是否默认值也生成,0是默认值
	 * @return 
	 */
	public static function encodeChildToObj(dspc:DisplayObjectContainer,isDoDef:Boolean=false
											,ignoreNameLs:Vector.<String>=null):Object
	{
		var res:Array = [];
		// 要反射的属性
		var refAttrLs:Vector.<String> = new <String>["x","y","width","height"];
		var intAttrLs:Vector.<String> = new <String>["x","y","width","height"];
		for (var i:int = 0; i < dspc.numChildren; i++) 
		{
			var dsp:DisplayObject = dspc.getChildAt(i);
			if(!dsp)
				continue;
			
			if(ignoreNameLs && ignoreNameLs.indexOf(dsp.name)>=0)
				continue;
			
			var itmObj:Object = {};
			var attrNum:int = 0;
			for (var j:int = 0; j < refAttrLs.length; j++) 
			{
				var itmStr:String = refAttrLs[j] as String;
				if(!isCanCode(dsp,itmStr,isDoDef))
					continue;
				if(intAttrLs.indexOf(itmStr)>=0)
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
			if(!dsp)
				continue;
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
					valObj.push(parseJson(itm + "}"));
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