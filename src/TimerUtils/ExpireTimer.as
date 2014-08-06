package TimerUtils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	/** 重置 */
	[Event(name="reset", type="TimerUtils.ExpireTimer")]
	/** 回收 */
	[Event(name="expired_recyle", type="TimerUtils.ExpireTimer")]
	
	/**
	 * 计时回收和重置显示对象小组件
	 * 当显示对象离开舞台并且超过了过期时间则进行回收处理,对象重新加入舞台时,如果已回收则执行重置处理
	 * @author Pelephone
	 */
	public class ExpireTimer extends EventDispatcher
	{
		/**
		 * 重置
		 */
		public static const RESET:String = "reset";
		
		/**
		 * 管理的显示对象过期回收
		 */
		public static const EXPIRED_RECYLE:String = "expired_recyle";
		
		/**
		 * 要管理的显示对象
		 */
		private var target:DisplayObject;
		
		/**
		 * 回收时间计时器
		 */
		private var killTimer:FrameTimer;
		
		public function ExpireTimer(dsp:DisplayObject,recyleDelayTimer:int=2*60*1000)
		{
			active(dsp);
			_recyleDelay = recyleDelayTimer;
		}
		
		private var _recyleDelay:int = 120000;
		
		/**
		 * 回收延迟时间
		 */
		public function get recyleDelay():int
		{
			return _recyleDelay;
		}

		/**
		 * @private
		 */
		public function set recyleDelay(value:int):void
		{
			if(_recyleDelay == value)
				return;
			
			if(killTimer)
				killTimer.delay = value;
			_recyleDelay == value;
		}

		
		/**
		 * 显示对象添加移出舞台自动添加时间制管理
		 */
		public function active(dsp:DisplayObject):void
		{
			if(!dsp || dsp == target)
				return;
			
			if(target)
				dispose();
			
			target = dsp;
			
			_hasAct = true;
			dsp = dsp;
			
			if(dsp.stage == null)
				dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
			else
				dsp.addEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
		}
		
		/**
		 * 反激活显示对象回收管理
		 */
		public function dispose():void
		{
			_hasAct = false;
			killTimer.stop();
			killTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
			if(target)
			{
				target.removeEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
				target.removeEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
				target = null;
			}
		}
		
		/**
		 * 监听加入和移除舞台处理，用监听函数存可以不用管回收
		 */
		private function onSkinInStage(e:Event):void
		{
			var dsp:DisplayObject = e.target as DisplayObject;
			dsp.removeEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
			dsp.addEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
			
			if(killTimer)
			{
				killTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
				killTimer.reset();
			}
			
			if(hasKill)
				dispatchEvent(new Event(ExpireTimer.RESET));
			
			hasKill = false;
		}
		
		/**
		 * 监听移出舞台的时候开始计时执行移除方法
		 * @param e
		 */
		private function onSkinOutStage(e:Event):void
		{
			var dsp:DisplayObject = e.target as DisplayObject;
			dsp.removeEventListener(Event.REMOVED_FROM_STAGE,onSkinOutStage);
			if(!killTimer)
				killTimer = new FrameTimer(_recyleDelay,1);
			dsp.addEventListener(Event.ADDED_TO_STAGE,onSkinInStage);
			killTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
			killTimer.start();
		}
		
		/**
		 * 是否已调用移除
		 */
		private var hasKill:Boolean = false;
		
		/**
		 * 回收时间计时完成
		 * @param e
		 */
		private function onKillComplete(e:Event):void
		{
			killTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onKillComplete);
			dispatchEvent(new Event(ExpireTimer.EXPIRED_RECYLE));
			hasKill = true;
		}
		
		/**
		 * 是否激活
		 */
		protected var _hasAct:Boolean = false;
		
		public function get hasAct():Boolean
		{
			return _hasAct;
		}
		
		/**
		 * 重置回收计算
		 */
		public function reset():void
		{
			killTimer.reset();
		}
		
		/**
		 * 停止回收计算
		 */
		public function stop():void
		{
			killTimer.stop();
		}
	}
}