package bitmapEngine;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.Lib;
import timerUtils.FrameTimer;
import timerUtils.StaticEnterFrame;

/**
 * 表示对象过期管理，即对象移出舞台后一段时间回收
 * @author Pelephone
 */
class DspExpire extends EventDispatcher
{
	/** 过期清空后恢复 */
	inline public static var RESTORE:String = "restore";
	
	/** 过期清数据事件 */
	inline public static var EXPIRE:String = "expire";
	
	/** 使所有显示对象执行一次过期处理 */
	inline public static var EXPIRE_ALL:String = "expire_all";
	
	public var target:DisplayObject;

	public function new(aTarget:DisplayObject=null) 
	{
		super();
		
		active(aTarget);
	}
	
	/** 激活过期管理 */
	public function active(aTarget:DisplayObject)
	{
		if (this.target == aTarget)
		return;
		if (target != null)
		target.removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
		
		this.target = aTarget;
		if (aTarget == null)
		return;
		
		aTarget.removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
		aTarget.addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		
		Lib.current.removeEventListener(EXPIRE_ALL, onExpireAll);
		Lib.current.addEventListener(EXPIRE_ALL, onExpireAll);
		
		
		if (aTarget.root == null)
		StaticEnterFrame.addNextCall(nextCalcRemove);
	}
	
	function nextCalcRemove()
	{
		if (target != null && target.root == null)
		calcRemveStage();
	}
	
	//----------------------------------
	// 移出舞台到期计时控制
	//----------------------------------
	
	/** 移出舞台后多少秒清除对象的位置数据(ms),<0表示不回收 */
	public var expireTime:Int = 21000;
	// 是否到期
	var hasExpire:Bool = false;
	var timer:FrameTimer = null;
	
	private function onAddStage(e:Event):Void 
	{
		if (expireTime >= 0)
		{
			var tar:DisplayObject = cast e.currentTarget;
			tar.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
		}
		if (timer != null)
		timer.stop();
		if (hasExpire)
		dispatchEvent(new Event(RESTORE));
		hasExpire = false;
	}
	
	private function onRemoveStage(e:Event):Void 
	{
		var tar:DisplayObject = cast e.currentTarget;
		tar.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
		
		calcRemveStage();
	}
	
	// 离开舞台计时判断
	function calcRemveStage()
	{
		if (expireTime == 0)
		{
			onExpireMe();
			return;
		}
		if(timer == null)
		{
			timer = new FrameTimer(expireTime,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onExpireMe);
		}
		timer.restart(expireTime, 1);
	}
	
	private function onExpireMe(e:Event=null):Void 
	{
		hasExpire = true;
		dispatchEvent(new Event(EXPIRE));
	}
	
	private function onExpireAll(e:Event):Void 
	{
		if (target == null || target.parent == null)
		return;
		if(timer != null)
		timer.stop();
		onExpireMe();
	}
	
	public function dispose()
	{
		hasExpire = false;
		StaticEnterFrame.removeNextCall(nextCalcRemove);
		if(target != null)
		{
			target.removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
			target.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
			target = null;
		}
		Lib.current.removeEventListener(EXPIRE_ALL, onExpireAll);
		if(timer != null)
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onExpireMe);
			timer = null;
		}
	}
}