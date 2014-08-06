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
package TimerUtils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * 时间工具
	 * Pelephone
	 */
	public class TimerTool extends TimerToolBase implements ITimerTool
	{
		/**
		 * 存储创建的timer, key为指定的delay [int,TimerInfo]
		 */		
		private var timerInfMap:Object;
		
		public function TimerTool()
		{
			super();
			timerInfMap = {};
		}
		
		override public function addItem(listener:Function,delay:int=0):void
		{
			var tInf:TimerInfo;
			
			// 这个判断能防止添加同一listener
			if(hasItem(listener))
			{
				var oldDelay:int = super.getListenerDelay(listener);
				// 如果帧率修改要重设时间信息
				if(oldDelay != delay)
				{
					tInf = timerInfMap[oldDelay] as TimerInfo;
					disposeListener(tInf,listener);
					
//					renderFrameRateMap[listener] = frameRate;
					super.addItem(listener,delay);
					tInf = getCreateTimerInf(delay);
					tInf.funcLs.push(listener);
				}
				return;
			}
			
			// 映射没有listener
			tInf = getCreateTimerInf(delay);
			tInf.funcLs.push(listener);
			timerInfMap[delay] = tInf;
			super.addItem(listener,delay);
		}
		
		override public function removeItem(listener:Function):void
		{
			if(!hasItem(listener))
				return;
			
			var delay:int = super.getListenerDelay(listener);
			var tInf:TimerInfo = timerInfMap[delay] as TimerInfo;
			disposeListener(tInf,listener);
			super.removeItem(listener);
		}
		
		/**
		 * 从数据中删除渲染方法
		 * @param timerInfo
		 * @param listener
		 */
		private function disposeListener(timerInfo:TimerInfo,listener:Function):void
		{
			timerInfo.funcLs.splice(timerInfo.funcLs.indexOf(listener),1);
			if(timerInfo.funcLs.length>0) return;
			timerInfo.timer.removeEventListener(TimerEvent.TIMER,onTimerHandler);
			timerInfo.timer.stop();
			timerInfo.timer = null;
			timerInfMap[timerInfo.delay] = null;
			delete timerInfMap[timerInfo.delay];
		}
		
		/**
		 * 帧率转延迟时间
		 * @param frameRate
		 
		private function changeDelay(frameRate:int):int
		{
			var fr:int;
			if(frameRate<=0)
			{
				fr = stageFrameRate;
			}
			
			// 每秒X帧 转 每延迟y秒执行一次
			return 1000/frameRate;
		}*/
		
		/**
		 * 获取timer数据信息
		 * @return 
		 */
		protected function getCreateTimerInf(delay:int):TimerInfo
		{
			var tInf:TimerInfo = timerInfMap[delay];
			if(!tInf)
			{
				tInf = newTimerInf(delay);
				timerInfMap[delay] = tInf;
			}
			return tInf;
		}
		
		/**
		 * 创建一个时间数据
		 * @param delay
		 * @param func
		 * @return 
		 */
		protected function newTimerInf(delay:int):TimerInfo
		{
//			var delay:int = changeDelay(frameRate);
			var tInf:TimerInfo = new TimerInfo();
//			tInf.frameRate = frameRate;
			tInf.delay = delay;
			tInf.timer = new Timer(delay);
			tInf.timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			tInf.timer.start();
			return tInf;
		}
		
		/**
		 * 周期时间句柄监听响应
		 * @param e
		 */
		override protected function onTimerHandler(e:Event):void
		{
//			var fr:int = 1000/Timer(e.target).delay;
			var tInf:TimerInfo = timerInfMap[Timer(e.target).delay];
			
			for each(var f:Function in tInf.funcLs)
			{
				f.apply(null,[]);
			}
			super.onTimerHandler(e);
		}
	}
}
import flash.utils.Timer;

class TimerInfo
{
	/**
	 * 帧率(主键)
	 
	public var frameRate:int;*/
	/**
	 * 执行间隔时间
	 */
	public var delay:int;
	/**
	 * 时间
	 */
	public var timer:Timer;
	/**
	 * 渲染组
	 */
	public var funcLs:Vector.<Function> = new Vector.<Function>();
}