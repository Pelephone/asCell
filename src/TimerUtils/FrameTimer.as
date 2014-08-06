package TimerUtils
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	
	/** 每当 Timer 对象达到根据 Timer.delay 属性指定的间隔时调度。  */
	[Event(name="timer", type="flash.events.TimerEvent")]
	/** 每当它完成 Timer.repeatCount 设置的请求数后调度。 */
	[Event(name="timerComplete", type="flash.events.TimerEvent")]
	/**
	 * 帧计时器，用法用Timer,不同的是此计时器是用enterframe来回调方法
	 * Pelephone
	 */
	public class FrameTimer extends EventDispatcher
	{
		private static const _shap:Shape = new Shape();
		
		/**
		 * 使用指定的 delay 和 repeatCount 状态构造新的 FrameTimer 对象。
		 * @param delay 计时器事件间的延迟（以毫秒为单位）。
		 * @param repeat 指定重复次数。 如果为 0，则计时器重复无限次数。 如果不为 0，则将运行计时器，运行次数为指定的次数，然后停止。 
		 */
		public function FrameTimer(delay:int=1,repeat:int=0)
		{
			this.delay = delay;
			this.repeatCount = repeat;
			super();
		}
		
		/**
		 * 上次执行函数的时间点
		 */
		private var lastPerTime:int;
		
		private var _currentCount:int;

		/**
		 * 计时器从 0 开始后触发的总次数。
		 * @return 
		 */
		public function get currentCount():int
		{
			return _currentCount;
		}

		/**
		 * 名称，这个字符仅在调试的时候查来源
		 */
		public var name:String;
		
		/**
		 * 计时器事件间的延迟 (秒)
		 */
		public var delay:int;
		
		/**
		 * 设置的计时器运行总次数。
		 */
		public var repeatCount:int;
		
		private var _running:Boolean;

		/**
		 * 计时器的当前状态；如果计时器正在运行，则为 true，否则为 false。
		 */
		public function get running():Boolean
		{
			return _running;
		}

		/**
		 * 响应帧事件
		 * @param e
		 */
		private function onEnterHandler(e:Event):void
		{
			var curTime:int = getTimer();
			if((curTime - lastPerTime)<delay)
				return;
			
			lastPerTime = curTime;
			_currentCount = _currentCount + 1;
			dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			
			if(repeatCount>0 && currentCount >= repeatCount)
			{
				stop();
				dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
		}
		
		/**
		 * 如果计时器正在运行，则停止计时器，并将 currentCount 属性设回为 0，这类似于秒表的重置按钮。 然后，在调用 start() 后，将运行计时器实例，运行次数为指定的重复次数（由 repeatCount 值设置）。 
		 */
		public function reset():void
		{
			_currentCount = 0;
			stop();
		}
		
		/**
		 * 如果计时器尚未运行，则启动计时器。 
		 */
		public function start():void
		{
			if(running)
				return;
			lastPerTime = getTimer();
			_running = true;
			_shap.addEventListener(Event.ENTER_FRAME,onEnterHandler);
		}
		
		/**
		 * 停止计时器。 如果在调用 stop() 后调用 start()，则将继续运行计时器实例，运行次数为剩余的 重复次数（由 repeatCount 属性设置）。 
		 */
		public function stop():void
		{
			_running = false;
			_shap.removeEventListener(Event.ENTER_FRAME,onEnterHandler);
		}
		
		/**
		 * 重新开始
		 * @param repeat
		 */
		public function restart(delay:int=1,repeat:int=0):void
		{
			this.repeatCount = repeat;
			this.delay = delay;
			reset();
			start();
		}
		
		/**
		 * 其它参数
		 */
		private var params:Object;
		
		/**
		 * 自增加标记
		 */
		private static var intervalIndex:int = 0;
		
		/**
		 * 令牌标记与timer映射
		 */
		private static var intervalMap:Object = {};
		
		/**
		 * 延迟执行的方法暂存
		 
		private static var timerCallMap:Dictionary = new Dictionary();*/
		/**
		 * 暂存延迟方法和timer的映射，用于回收 {Function,[FrameTimer]}
		 
		private static var callTimersMap:Dictionary = new Dictionary();*/
		
		/**
		 * 延迟执行方法
		 * (重复执行的方法没法停止回收，所以不提供该功能)
		 * @param delay 延迟毫秒数 (毫秒)
		 * @param call 执行方法
		 * @param callArgs 方法参数
		 * @return 
		 */
		public static function delayCall(delay:int,call:Function,callArgs:Array=null):FrameTimer
		{
			var f:FrameTimer = new FrameTimer(delay,1);
			f.params = [call,callArgs];
			
//			intervalIndex = intervalIndex + 1;
//			intervalMap[intervalIndex] = f;
//			return intervalIndex;
			
//			timerCallMap[f] = [call,callArgs];
//			var ls:Array = callTimersMap[call] as Array;
//			if(!ls)
//				ls = callTimersMap[call] = [];
//			ls.push(f);
			
			f.addEventListener(TimerEvent.TIMER_COMPLETE,onCompleteCall);
			f.start();
			return f;
		}
		
		/**
		 * 延迟完成
		 * @param e
		 */
		private static function onCompleteCall(e:Event):void
		{
			var timer:FrameTimer = e.currentTarget as FrameTimer;
			var arr:Array = timer.params as Array;
//			var arr:Array = timerCallMap[timer];
			var call:Function = arr[0];
			var callArgs:Array = arr[1];
			call.apply(null,callArgs);
			timer.params = null;
			
//			clearMap(call,timer);
		}
		
		/**
		 * 移除此方法关联的所有延迟操作
		 * @return 
		 
		public static function killDelayCall(call:Function):void
		{
			var ls:Array = callTimersMap[call] as Array;
			if(!ls)
				return;
			
			for each (var itm:FrameTimer in ls) 
			{
				itm.removeEventListener(TimerEvent.TIMER_COMPLETE,onCompleteCall);
				delete timerCallMap[itm];
			}
			delete callTimersMap[call];
		}*/
		
		/**
		 * 移除单个延迟对象(killDelayCall是移出多个)
		 * @param timer
		 */
		public static function removeOneDelay(timer:FrameTimer):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onCompleteCall);
			timer.params = null;
			timer.stop();
//			var arr:Array = timerCallMap[timer];
//			if(!arr || arr.length<2)
//				return;
//			var call:Function = arr[0];
//			var callArgs:Array = arr[1];
//			clearMap(call,timer);
		}
		
		/**
		 * 断个映射
		 * @param call
		 * @param timer
		 
		private static function clearMap(call:Function,timer:FrameTimer):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onCompleteCall);
			var ls:Array = callTimersMap[call] as Array;
			var tid:int = ls.indexOf(timer);
			if(tid>=0)
				ls.splice(tid,1);
			if(!ls.length)
				delete callTimersMap[call];
			delete timerCallMap[timer];
		}*/
	}
}