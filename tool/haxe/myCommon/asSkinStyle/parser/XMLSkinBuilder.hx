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
package asSkinStyle.parser;

import asSkinStyle.data.SkinStyle;
import asSkinStyle.i.ISkinBuilder;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;


/**
 * xml语法的皮肤标签解析生成器
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class XMLSkinBuilder implements ISkinBuilder
{
	/**
	 * 根组合的名称
	 */
	public static var XML_ROOT:String = "root";
	/**
	 * class属性名
	 */
	public static var XML_CLASS:String = "class";
	/**
	 * id属性名
	 */
	public static var XML_ID:String = "name";
	/**
	 * 获取子项的标签
	 */
	public static var XML_GET_CHILD:String = "xChild";
	/**
	 * 引用节点
	 */
	public static var XML_REFERENCE:String = "reference";
	
	/**
	 * 注册在里面的皮肤类,与名称绑定
	 */
	public var tagClzMap:Map<String,Class<DisplayObject>>;
	/**
	 * 皮肤组合,通过xml生成
	 */
	public var skinData:SkinStyle;
	
	public function new()
	{
		tagClzMap = new Map < String, Class<DisplayObject> > ();
	}
	
	public function initSkinComposite(xmlTagObj:Xml):Void
	{
		xmlTagObj.set(XML_ID, XML_ROOT);
		//xmlTagObj.@[XML_ID] = XML_ROOT;
		skinData = makeSkinCom(xmlTagObj,xmlTagObj);
	}
	
	public function createSkinUI(tagIdName:String):DisplayObject
	{
		var sCom:SkinStyle = getSkinDataByName(tagIdName);
		return createSkinAndChild(sCom);
	}
	
	/**
	 * 返回输入样式子项
	 * @param skin
	 * @param childName
	 * @return 
	 */
	public function getSkinChild(skin:DisplayObjectContainer,childName:String):DisplayObject
	{
		return skin.getChildByName(childName);
	}
	
	/**
	 * 设置对象样式和子项样式
	 * @param sCom
	 * @return 
	 */
	private function createSkinAndChild(sCom:SkinStyle):Object
	{
		if(!sCom) return null;
		var clz:Class = getTagClass(sCom.classTag);
		if(!clz){
			trace("标签类",sCom.classTag,"未注册,不能生成!");
			return null;
		}
		//var resSkin:Object = new clz();
		var resSkin:DisplayObject = Type.createEmptyInstance(clz);
		
		StyleUtils.setObjByVars(resSkin,sCom.getStyleVars(),true,[XML_REFERENCE]);
		createStyleChild(sCom,resSkin);
		
		return resSkin;
	}
	
	/**
	 * 通过样式生成子项皮肤
	 * @param sCom
	 */
	private function createStyleChild(sCom:SkinStyle,resSkin:DisplayObject):Object
	{
		var dc:DisplayObjectContainer = cast resSkin;
		if(!dc || !sCom.numChildren()) return resSkin;
		for (i in i...sCom.numChildren()) 
		{
			var ccmp:SkinStyle = sCom.getChildByIndex(i) as SkinStyle;
			
			var skinChild:Object = getSkinChild(dc,ccmp.getName());
			// 如果子项标签是特殊标签则不生成新对象，进行查找子项后斌值
			if((ccmp && ccmp.classTag==XML_GET_CHILD) || skinChild )
			{
				StyleUtils.setObjByVars(skinChild,ccmp.getStyleVars(),true,[XML_REFERENCE]);
			}
			else
			{
				var cdp:DisplayObject = createSkinAndChild(ccmp) as DisplayObject;
				if(!cdp) continue;
				dc.addChild(cdp);
			}
		}
		return resSkin;
	}
	
	/**
	 * 跟椐组合标签设置对象样式
	 * @param skin
	 * @param skinId
	 */
	public function setSkinChildStyle(skinObject:Object,skinId:String):Void
	{
		var skinCom:SkinStyle = skinData.getChildByName(skinId) as SkinStyle;
		setSkinStyleCom(skinObject,skinCom);
	}
	
	/**
	 * 通过组件样式设置皮肤及子项属性
	 * @param skinObject
	 * @param skinCom
	 * @return 
	 */
	private function setSkinStyleCom(skinObject:Object,skinCom:SkinStyle):Object
	{
		var dc:DisplayObjectContainer = skinObject as DisplayObjectContainer;
		if(!dc || !skinCom ||!skinCom.numChildren()) return skinObject;
		for (var i:int = 0; i < skinCom.numChildren(); i++) 
		{
			var ccmp:SkinStyle = skinCom.getChildByIndex(i) as SkinStyle;
			
			// 如果子项标签是特殊标签则不生成新对象，进行查找子项后斌值
			if(ccmp && ccmp.classTag==XML_GET_CHILD )
			{
				var skinChild:Object = getSkinChild(dc,ccmp.getName());
				if(skinChild)
					StyleUtils.setObjByVars(skinChild,ccmp.getStyleVars());
			}
		}
		return skinObject;
	}
	
	/**
	 * 通过xml递归子项生成皮肤
	 * @param skinXML
	 * @param rootXml
	 * @param idName
	 * @return 
	 */
	private function makeSkinCom(skinXML:Xml,rootXml:Map<String,Dynamic>):SkinStyle
	{
		if (skinXML == null)
		return null;
		
		var id:String = skinXML.get(XML_ID);
		skinXML = getReferenceXml(skinXML,rootXml);
		
		var tagName:String = skinXML.localName();
		var styleVars:Object = StyleUtils.xmlCreateObject(skinXML);
		styleVars[XML_ID] = id;
		var scom:SkinStyle = newSkinComp(id,tagName,styleVars);
		
		for each (var childXML:Object in skinXML.children()) 
		{
			var childCom:SkinStyle = makeSkinCom(childXML,rootXml);
			scom.add(childCom);
		}
		
		return scom;
	}
	
	/**
	 * 归递生成xml对象
	 */
	private function getReferenceXml(refXml:Object,rootXml:Object):Object
	{
		refXml = refXml[0];
		if(!refXml || !refXml.length()) return null;
		var refId:String = refXml.attribute(XML_REFERENCE);
		if(refId && refId.length)
		{
			var scXml:Object = rootXml.children().(attribute(XML_ID)==refId);
			var resXml:Object = getReferenceXml(scXml.copy(),rootXml);
			resXml.appendChild(refXml.children());
			return resXml;
		}
		else
			return refXml;
	}
	
	public function newSkinComp(idName:String,tagName:String,styleVars:Object):SkinStyle
	{
		return new SkinStyle(idName,tagName,styleVars);
	}
	
	public function getSkinDataByName(tagIdName:String):SkinStyle
	{
		return cast StyleUtils.getCssBySplitName(tagIdName,skinData);
	}
	
	public function hasSkinComposite(tagIdName:String):Bool
	{
		var skinCom:SkinStyle = cast StyleUtils.getCssBySplitName(tagIdName,skinData);
		return skinCom!=null;
	}
	
	public function registerTag(tagName:String, dispClz:Class<DisplayObject>):Void
	{
		tagClzMap.set(tagName, dispClz);
	}
	
	public function getTagClass(clzName:String):Class<DisplayObject>
	{
		return tagClzMap.get(clzName);
	}
	
	public function hasTagClass(clzName:String):Bool
	{
		return tagClzMap.exists(clzName);
	}
	
	public function dispose():Void
	{
		tagClzMap = {};
		skinData.safeRemove(skinData);
		skinData = null;
	}
}