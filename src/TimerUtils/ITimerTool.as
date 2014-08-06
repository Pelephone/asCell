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
package TimerUtils
{
	
	/**
	 * 时间管理器,将要渲染对象加入可对其进行统一的时间帧管理
	 * Pelephone
	 */
	public interface ITimerTool
	{
		/**
		 * 场景全局帧率
		 * @param value
		 */
		function set stageFrameRate(value:int):void;
		/**
		 * @private 
		 */
		function get stageFrameRate():int;
		/**
		 * 添加周期要执行的监听
		 * @param listener 周期监听对象
		 * @param delay 间隔周期时间(毫秒)
		 */
		function addItem(listener:Function,delay:int=0):void;
		
		/**
		 * 是否有监听对象
		 * @param render
		 * @param frameRate
		 */
		function hasItem(listener:Function):Boolean;
		
		/**
		 * 删除监听对象
		 * @param listener 周期监听对象
		 */
		function removeItem(render:Function):void;
	}
}