/**
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
package utils.tools;

import flash.display.DisplayObject;
import flash.events.Event;


/**
 * 显示对象事件管理工具
 * Pelephone
 */
class StageTool
{
	/**
	 * 使显示对象加入舞台后执行一次toStageFun方法<br/>
	 * 此方法可减轻显示对象初始的压力<br/>
	 * 如果显示对象有很多对象要创建时，new出的时候并不创建，而在显示对象放入舞台时才创建
	 * @param disp 显示对象
	 * @param toStageFun 加入舞台方法
	 */
	public static function addSkinInit(dsp:DisplayObject,toStageFun:Void->Void):Void
	{
		if(dsp.stage != null)
		{
			toStageFun();
			return;
		}
		dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinToStage);
		// 监听舞台加入舞台时的事件，用监听函数存可以不用管回收
		function onSkinToStage(e:Event):Void
		{
			dsp.removeEventListener(Event.ADDED_TO_STAGE,onSkinToStage);
			toStageFun();
		}
	}
}