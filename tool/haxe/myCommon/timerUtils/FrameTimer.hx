package timerUtils;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.Lib;
import haxe.Timer;


/** 每当 Timer 对象达到根据 Timer.delay 属性指定的间隔时调度。  
[Event(name="timer", type="flash.events.TimerEvent")]*/
/** 每当它完成 Timer.repeatCount 设置的请求数后调度。 
[Event(name="timerComplete", type="flash.events.TimerEvent")]*/
/**
 * 帧计时器，用法用Timer,不同的是此计时器是用enterframe来回调方法
 * Pelephone
 */
class FrameTimer extends EventDispatcher
{
	//private static var _shap:Sprite = new Sprite();
	
	/**
	 * 使用指定的 delay 和 repeatCount 状态构造新的 FrameTimer 对象。
	 * @param delay 计时器事件间的延迟（以毫秒为单位）。
	 * @param repeat 指定重复次数。 如果为 0，则计时器重复无限次数。 如果不为 0，则将运行计时器，运行次数为指定的次数，然后停止。 
	 */
	public function new(delay:Int=1,repeat:Int=0)
	{
		this.delay = delay;
		this.repeatCount = repeat;
		super();
	}
	
	/**
	 * 上次执行函数的时间点
	 */
	private var lastPerTime:Int = 0;
	
	private var _currentCount:Int = 0;

	/**
	 * 计时器从 0 开始后触发的总次数。
	 * @return 
	 */
	public function getCurrentCount():Int
	{
		return _currentCount;
	}

	/**
	 * 名称，这个字符仅在调试的时候查来源
	 */
	public var name:String;
	
	/**
	 * 计时器事件间的延迟 (毫秒)
	 */
	public var delay:Int = 0;
	
	/**
	 * 设置的计时器运行总次数。
	 */
	public var repeatCount:Int = 0;
	
	private var _running:Bool = false;

	/**
	 * 计时器的当前状态；如果计时器正在运行，则为 true，否则为 false。
	 */
	public function getRunning():Bool
	{
		return _running;
	}

	/**
	 * 响应帧事件
	 * @param e
	 */
	private function onEnterHandler(e:Dynamic)
	{
		var curTime:Int = Std.int(Timer.stamp() * 1000);
		if ((curTime - lastPerTime) < delay)
		return;
		
		lastPerTime = curTime;
		_currentCount = _currentCount + 1;
		dispatchEvent(new TimerEvent(TimerEvent.TIMER));
		
		if (repeatCount > 0 && _currentCount >= repeatCount)
		{
			stop();
			dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		}
	}
	
	/**
	 * 如果计时器正在运行，则停止计时器，并将 currentCount 属性设回为 0，这类似于秒表的重置按钮。 然后，在调用 start() 后，将运行计时器实例，运行次数为指定的重复次数（由 repeatCount 值设置）。 
	 */
	public function reset()
	{
		_currentCount = 0;
		stop();
	}
	
	/**
	 * 如果计时器尚未运行，则启动计时器。 
	 */
	public function start()
	{
		if(_running)
			return;
		lastPerTime = Std.int(Timer.stamp()*1000);
		_running = true;
		//_shap.addEventListener(Event.ENTER_FRAME, onEnterHandler);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterHandler);
	}
	
	/**
	 * 停止计时器。 如果在调用 stop() 后调用 start()，则将继续运行计时器实例，运行次数为剩余的 重复次数（由 repeatCount 属性设置）。 
	 */
	public function stop()
	{
		_running = false;
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME,onEnterHandler);
	}
	
	/**
	 * 重新开始
	 * @param repeat
	 */
	public function restart(delay:Int=1,repeat:Int=0)
	{
		this.repeatCount = repeat;
		this.delay = delay;
		reset();
		start();
	}
	
	var tmpCall:Void -> Void;
	
	/**
	 * 延迟执行方法
	 * (重复执行的方法没法停止回收，所以不提供该功能)
	 * @param call 执行方法
	 * @param delay 延迟毫秒数 (毫秒)
	 * @return 
	 */
	public static function delayCall(call:Void->Void,delay:Int=1000):FrameTimer
	{
		var f:FrameTimer = new FrameTimer(delay, 1);
		f.tmpCall = call;
		f.addEventListener(TimerEvent.TIMER_COMPLETE, changeCall);
		f.start();
		return f;
	}
	
	private static function changeCall(e:TimerEvent):Void
	{
		var target:FrameTimer = cast e.target;
		if(target.tmpCall != null)
		target.tmpCall();
		
		removeTimer(target);
	}
	
	/**
	 * 移出延迟执行,如果延迟的方法还没执行则放弃执行
	 */
	public static function removeTimer(target:FrameTimer):Void
	{
		target.removeEventListener(TimerEvent.TIMER_COMPLETE, changeCall);
		target.stop();
		target.tmpCall = null;
	}
}