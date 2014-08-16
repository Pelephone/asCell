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

import asSkinStyle.i.IStyleParser;


/**
 * 样式解析
 * @author Pelephone
 */
public class XMLStypeParser implements IStyleParser
{
	public function new()
	{
	}
	
	public function initStyle(cssObject:Object):void
	{
	}
	
	public function addCssToComposite(newCssObject:Object, cssName:String="root"):void
	{
	}
	
	public function setSkinUI(skinObject:Object, cssName:String):Object
	{
		return null;
	}
	
	public function hasStyleComposite(tagIdName:String):Boolean
	{
		return false;
	}
}