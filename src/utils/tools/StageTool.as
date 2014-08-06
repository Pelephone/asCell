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
package utils.tools
{
	import TimerUtils.FrameTimer;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	/**
	 * 显示对象事件管理工具
	 * Pelephone
	 */
	public class StageTool
	{
		/**
		 * 使显示对象加入舞台后执行一次toStageFun方法<br/>
		 * 此方法可减轻显示对象初始的压力<br/>
		 * 如果显示对象有很多对象要创建时，new出的时候并不创建，而在显示对象放入舞台时才创建
		 * @param disp 显示对象
		 * @param toStageFun 加入舞台方法
		 */
		public static function addSkinInit(dsp:DisplayObject,toStageFun:Function):void
		{
			if(dsp.stage)
			{
				toStageFun.apply(null,[]);
				return;
			}
			dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinToStage);
			// 监听舞台加入舞台时的事件，用监听函数存可以不用管回收
			function onSkinToStage(e:Event):void
			{
				dsp.removeEventListener(Event.ADDED_TO_STAGE,onSkinToStage);
				toStageFun.apply(null,[]);
			}
		}
		
		/**
		 * 监听显示对象的加入舞台和移出舞台事件(注，此方法是没有回收的,监听了就没法取消)
		 * @param dsp 被监听的显示对象
		 * @param inStageCall 加入舞台时执行的方法
		 * @param outStageCall 移出舞台时执行的方法
		 */
		public static function addSkinStageInOut(dsp:DisplayObject,inStageCall:Function,outStageCall:Function):void
		{
			dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
			// 监听加入和移除舞台处理，用监听函数存可以不用管回收
			function onSkinInStage(e:Event):void
			{
				dsp.removeEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
				dsp.addEventListener(Event.REMOVED_FROM_STAGE,onOut);
				inStageCall.apply(null,[]);
			}
			function onOut(e:Event):void
			{
				dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
				dsp.removeEventListener(Event.REMOVED_FROM_STAGE,onOut);
				outStageCall.apply(null,[]);
			}
		}
		
		/**
		 * 显示对象添加移出舞台自动添加时间延迟回收重置
		 * @param dsp 要管理舞台的显示对象
		 * @param dispose 移除方法
		 * @param reset 重置方法
		 * @param killTime 移出舞台时延迟回收的时间
		 */
		private function autoDspStageMgr(dsp:DisplayObject,dispose:Function
											 ,reset:Function=null,killTime:int=300000):void
		{
			if(!dsp || dispose==null)
				return;
			
			if(dsp.stage == null)
				dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
			else
				dsp.addEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
			
			var ft:FrameTimer = new FrameTimer(killTime);
			
			function onKillComplete(e:Event):void
			{
				dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
				ft.removeEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
				if(dispose!=null)
					dispose.call(null,[]);
			}
			// 监听加入和移除舞台处理，用监听函数存可以不用管回收
			function onSkinInStage(e:Event):void
			{
				dsp.removeEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
				dsp.addEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
				
				if(ft.running)
				{
					ft.reset();
					return;
				}
				if(reset!=null)
					reset.call(null,[]);
			}
			function onSkinOutStage(e:Event):void
			{
				dsp.removeEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
				ft.addEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
				ft.start();
			}
		}
		
		//---------------------------------------------------
		// 显示对象第一次加入舞台调用监听方法
		//---------------------------------------------------
		
		// 皮肤加入舞台方法监听对应映射 [DisplayObject,Vector.[Function]]
/*		private static var stageFunMap:Dictionary = new Dictionary();
		
		
		public static function addSkinToStage(disp:DisplayObject,toStageFun:Function):void
		{
			if(disp.stage)
				toStageFun.apply(null,[]);
			else
			{
				var ls:Vector.<Function> = stageFunMap[disp];
				if(!ls)
					stageFunMap[disp] = ls = new Vector.<Function>();
				
				if(ls.indexOf(toStageFun)<0)
					ls.push(toStageFun);
				
				disp.addEventListener(Event.ADDED_TO_STAGE,onSkinToStage);
			}
		}*/
		
		/**
		 * 移出显示对象放入舞台的事件
		 * @param disp
		 * @param toStageFun 为空表示删所有skin的舞台监听事件，不空表示只移出对应的指定条
		 
		public static function removeSkinToStage(disp:DisplayObject,toStageFun:Function=null):void
		{
			if(!disp || !stageFunMap.hasOwnProperty(disp))
				return;
			
			var ls:Vector.<Function> = stageFunMap[disp];
			if(!ls) return;
			
			if(toStageFun!=null)
			{
				var tid:int = ls.indexOf(toStageFun);
				if(tid>=0)
					ls.splice(tid,1);
				
				if(ls.length>0)
					return;
			}
			
			disp.removeEventListener(Event.ADDED_TO_STAGE, onSkinToStage);
			stageFunMap[disp] = null;
			delete stageFunMap[disp];
		}*/
		
		/**
		 * 显示对象加入舞台时调用
		 * @param e
		 
		private static function onSkinToStage(e:Event):void
		{
			var disp:DisplayObject = e.currentTarget as DisplayObject;
			var ls:Vector.<Function> = stageFunMap[disp];
			while(ls && ls.length)
			{
				var toStageFun:Function = ls.shift();
				toStageFun.apply(null,[]);
			}
			disp.removeEventListener(Event.ADDED_TO_STAGE, onSkinToStage);
			stageFunMap[disp] = null;
			delete stageFunMap[disp];
		}*/
	}
}