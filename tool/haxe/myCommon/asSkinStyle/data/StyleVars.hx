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
package asSkinStyle.data;

/**
 * 样式变量数据
 * amf模式下可用此对象注册别名，生成amf数据
 * @author Pelephone
 */
class StyleVars
{
	public function new()
	{
		varsMap = new Map<String,Dynamic>();
		childs = [];
	}
	
	/**
	 * 节点唯一的id名
	 */
	public var id:String;
	/**
	 * 全路径
	 */
	public var path:String;
	/**
	 * 引用字符
	 */
	public var reference:String;
	/**
	 * 类标签，从已注册的类取别名
	 */
	public var clzTag:String;
	/**
	 * 节点标签，new,还是get
	 */
	public var tag:String;
	/**
	 * 属性映射对象值
	 */
	public var varsMap:Map<String,Dynamic>;
	/**
	 * 属性名组(多用一个数组来存映射是用于设置属性的时候有序)
	 
	public var attrLs:Array<String>;*/
	/**
	 * 构造参数组
	 */
	public var constructLs:Array<String>;
	
	/**
	 * 设置属性映射
	 * @param attr
	 * @param value
	 */
	public function setVars(attr:String,value:Dynamic):Void
	{
/*		if(!varsMap.exists(attr))
		{
			attrLs.push(attr);
		}*/
		varsMap.set(attr, value);
	}
	
	/**
	 * 属性名
	 * @return
	 
	public function getAttrLs():Array<String>
	{
		return varsMap.keys();
	}*/
	
	/**
	 * 通过属性名获取对应的值
	 * @param attr
	 * @return 
	 */
	public function getValue(attr:String):Dynamic 
	{
		return varsMap.get(attr);
	}
	
	/**
	 * 子项
	 */
	public var childs:Array<StyleVars>;
	
	/**
	 * 通过id名称获取子项
	 * @param childId
	 * @return 
	 
	public function getVars(childId:String):StyleVars
	{
		for each (var itm:StyleVars in childs) 
		{
			if(itm.id == childId)
				return itm;
		}
		return null;
	}*/
	
	/**
	 * 销毁
	 */
	public function dispose():Void
	{
		for (itm in childs) 
		{
			itm.dispose();
		}
		childs = [];
	}
}