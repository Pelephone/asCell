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
package asSkinStyle.parser;

import asSkinStyle.data.StyleModel;
import asSkinStyle.data.StyleTag;
import asSkinStyle.data.StyleVars;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.errors.Error;


/**
 * 把样式数据解析到显示对象
 * @author Pelephone
 */
class DecodeXmlStyle
{
	public function new(styleModel:StyleModel = null)
	{
		model = styleModel;
		if (model == null)
		model = new StyleModel();
	}
	
	/**
	 * 样式数据
	 */
	var model:StyleModel;
	
	/**
	 * 通过id创建皮肤
	 * @param idPath
	 * @param toSkin
	 */
	public function decodeBuildStyle(idPath:String,toSkin:DisplayObject=null):DisplayObject
	{
		var sVars:StyleVars = getStyleVar(idPath,1);
		if (sVars == null || sVars.tag != StyleTag.TAG_NEW)
		return toSkin;
		if(toSkin == null)
		toSkin = getCreateSkin(sVars.clzTag,sVars.id,sVars.constructLs);
		
		setObjByVars(toSkin,sVars);
		
		for (itm in sVars.childs) 
		{
			createStyleSkin(itm,cast toSkin);
		}
		return toSkin;
	}
	
	/**
	 * 通过id路径获取对象的样式数据
	 * @param idPath
	 * @return 
	 */
	private function getStyleVar(idPath:String,mapType:Int=0):StyleVars
	{
		if(mapType == 0)
			return model.getStyleVars(idPath);
		else
			return model.getBuildVars(idPath);
	}
	
	/**
	 * 递归样式生成皮肤
	 * @param sVars
	 */
	private function createStyleSkin(sVars:StyleVars,parentSkin:DisplayObjectContainer=null):DisplayObject
	{
		var childSkin:DisplayObject = getCreateSkin(sVars.clzTag,sVars.id,sVars.constructLs);
		if(childSkin == null)
		return parentSkin;
		
		setObjByVars(childSkin,sVars);
		
		parentSkin.addChild(childSkin);
		
		if(!Std.is(childSkin , DisplayObjectContainer))
			return parentSkin;
		
		for (itm in sVars.childs) 
		{
			createStyleSkin(itm,cast childSkin);
		}
		return null;
	}
	
	/**
	 * 通过类标签名获取生成显示对象,找不到标签，默认会创建Sprite对象
	 * @param clzTag
	 * @return 
	 */
	private function getCreateSkin(clzTag:String,name:String,params:Array<Dynamic>=null):DisplayObject
	{
		var res:DisplayObject = null;
		if(clzTag==null || clzTag.length==0)
			res = new Sprite();
		
		if(res == null)
		{
			var clz:Class<DisplayObject> = model.getClass(clzTag);
			try
			{
				if(params == null || params.length == 0)
				return Type.createEmptyInstance(clz);
				else
				return Type.createInstance(clz, params);
				
				/*if(clz == null)
					clz = ApplicationDomain.currentDomain.getDefinition(clzTag) as Class;
			
				if(clz != null)
				{
					if(!params)
						res = new clz() as DisplayObject;
					else if(params.length == 1)
						res = new clz( params[0] ) as DisplayObject;
					else if(params.length == 2)
						res = new clz( params[0], params[1] ) as DisplayObject;
					else if(params.length == 3)
						res = new clz( params[0], params[1], params[2] ) as DisplayObject;
					else
						res = new clz() as DisplayObject;
				}*/
			}
			catch (e:Error)
			{
			}

		}
		if(res == null)
		res = new Sprite();
		
		res.name = name;
		return res;
	}
	
	/**
	 * 通过样式id路径，设置皮肤
	 * @param idPath
	 * @param skin
	 */
	public function decodeSetStyle(idPath:String,skin:DisplayObject):DisplayObject
	{
		var sVars:StyleVars = getStyleVar(idPath,0);
		if(sVars == null)
		return skin;
		
		return setStyleSkin(sVars,skin);
	}
	
	/**
	 * 设置显示对象
	 * @param sVar
	 * @param skin
	 */
	private function setStyleSkin(sVar:StyleVars,skin:DisplayObject):DisplayObject
	{
		setObjByVars(skin,sVar);
		
		var dc:DisplayObjectContainer = cast skin;
		if (dc != null && dc.numChildren > 0 && sVar.childs.length > 0)
		{
			for (itm in sVar.childs) 
			{
				var childDP:DisplayObject = dc.getChildByName(itm.id);
				if(childDP == null)
				continue;
				
				setStyleSkin(itm,childDP);
			}
		}
		return skin;
	}
	
	/**
	 * 通过对象复制属性数据给resObj
	 * @param resObj
	 * @param newObj
	 * @param isStrict	是否严格，true时resObj有属性才赋值，false则会给resObj动态添属性
	 * @param ignoreProps	忽略的属性名列表
	 * @return 			返回改变属性后的原对象
	 */
	private function setObjByVars(resObj:Dynamic,newObj:StyleVars
									,isStrict:Bool=true):Dynamic
	{
		if (newObj == null)
		return null;
		
		// 遍历样式对象属性改变dc的属性值
		for (attName in newObj.attrLs) 
		{
			var voVars:Dynamic = newObj.getValue(attName);
			if(isStrict && !Reflect.hasField(resObj,attName))
			continue;
			var varStr:String = cast voVars;
			if (varStr != null && varStr.length > 1 )
			{
				var tag:String;
				if(varStr.indexOf(StyleTag.REFL_REG_VALUE)==0)
				{
					tag = varStr.substring(1);
					voVars = model.getTagObject(tag);
				}
				else if(varStr.indexOf(StyleTag.REFL_TAG_VALUE)==0)
				{
					tag = varStr.substring(1);
					voVars = createByTag(tag);
				}
			}
			//resObj.set(attName, voVars);
			Reflect.setField(resObj, attName, voVars);
		}
		return resObj;
	}
	
	/**
	 * 通过标签创建对象
	 * @param tag
	 */
	function createByTag(idPath:String):DisplayObject
	{
		var vars:StyleVars = model.getStyleVars(idPath);
		if(vars == null)
			return null;
		
		var clz:Class<DisplayObject> = model.getClass(vars.clzTag);
		try
		{
			//if(clz == null)
				//clz = ApplicationDomain.currentDomain.getDefinition(vars.clzTag) as Class;
			//var resObj:Object = new clz();
			var resObj:DisplayObject = Type.createEmptyInstance(clz);
			setObjByVars(resObj, vars);
			return resObj;
		}
		catch (e:Error)
		{
		}
		return null;
	}
}