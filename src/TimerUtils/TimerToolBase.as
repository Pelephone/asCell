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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	[Event(name = "enter_frame_render", type = "TimerUtils.TimerToolBase")]
	/**
	 * 场景时间轴工具基类
	 * Pelephone
	 */
	public class TimerToolBase extends EventDispatcher implements ITimerTool
	{
		/**
		 * 逐帧渲染消息
		 */
		public static const ENTER_FRAME_RENDER:String = "enter_frame_render";
		
		/**
		 * 渲染方法和帧频映射，用于通过方法反查时间对象 [Function,int]
		 */
		private var renderFrameRateMap:Dictionary;
		
		private var _stageFrameRate:int = 30;
		
		public function TimerToolBase()
		{
			renderFrameRateMap = new Dictionary();
		}
		
		public function addItem(listener:Function,delay:int=0):void
		{
			renderFrameRateMap[listener] = delay;
		}
		
		public function hasItem(listener:Function):Boolean
		{
			return renderFrameRateMap[listener] != undefined;
		}
		
		public function removeItem(listener:Function):void
		{
			renderFrameRateMap[listener] = null;
			delete renderFrameRateMap[listener];
		}
		
		/**
		 * 获取渲染体的帧率
		 * @return 
		 */
		protected function getListenerDelay(listener:Function):int
		{
			return renderFrameRateMap[listener];
		}
		
		/**
		 * 每次渲染句柄
		 * @param e
		 */
		protected function onTimerHandler(e:Event):void
		{
			dispatchEvent(new Event(ENTER_FRAME_RENDER));
		}
		
		/**
		 * 场景的全局帧率(不能为0)
		 */
		public function get stageFrameRate():int
		{
			return _stageFrameRate;
		}
		
		/**
		 * @private
		 */
		public function set stageFrameRate(value:int):void
		{
			if(value<=0) value = 1;
			_stageFrameRate = value;
		}
	}
}