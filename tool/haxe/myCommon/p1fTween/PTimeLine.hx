package p1fTween;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.Lib;
import haxe.Timer;

/**
 * 时间轴
 * @author Pelephone
 */
class PTimeLine
{
	public function new() 
	{
		tweenMap = new Map<PTween,Float>();
	}
	
	// 播放速度
	public var speed:Float = 1;
	var tweenMap:Map<PTween,Float>;
	
	public var completeCall:Dynamic->Void;
	public var completeParams:Dynamic;
	public var ratio:Float = 0;
	/** 播放完成之后是否立刻清除 */
	public var autoKill:Bool = true;
	
	var duration:Float = 0;
	var startTime:Float = 0;
	
	public function start()
	{
		startTime = Timer.stamp();
		ratio = 0;
		
		for (pt in tweenMap.keys()) 
		pt.ratio = 0;
		
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	public function stop()
	{
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
	}
	
	public function kill()
	{
		stop();
		for (pt in tweenMap.keys()) 
		pt.kill();
		duration = 0;
		tweenMap = new Map<PTween,Float>();
		completeCall = null;
		completeParams = null;
		ratio = 1;
	}
	
	private function update(e:Event):Void 
	{
		calcTime();
		if (ratio >= 1)
		{
			stop();
			if(completeCall != null)
			completeCall(completeParams);
			if (autoKill)
			kill();
		}
	}
	
	private function calcTime()
	{
		var curTime:Float = Timer.stamp();
		var passTime:Float = curTime - startTime;
		
		passTime = passTime * speed;
		
		doPassTime(passTime);
	}
	
	private function getDuration():Float
	{
		return duration;
	}
	
	public function doPassTime(passTime:Float)
	{
		ratio = passTime / getDuration();
		if (ratio > 1)
		ratio = 1;
		
		for (pt in tweenMap.keys()) 
		{
			var insertTime:Float = tweenMap.get(pt);
			if (passTime < insertTime)
			continue;
			if (!pt.isInitTimeLine)
			{
				pt.isInitTimeLine = true;
				pt.initParams(insertTime + startTime);
			}
			if(pt.ratio < 1)
			pt.doPassTime(passTime - insertTime);
		}
	}
	
	/**
	 * 将动画插入到时间轴
	 * @param	tween
	 * @param	time (s);
	 */
	public function insert(tween:PTween,time:Float)
	{
		tween.autoKill = false;
		tween.stop();
		tweenMap.set(tween, time);
		if ((time + tween.duration) > duration)
		duration = time + tween.duration;
		
		start();
	}
	
	/**
	 * 将动画添加到时间轴
	 * @param	tween
	 */
	public function append(tween:PTween)
	{
		insert(tween,duration);
	}
	
	/**
	 * 插入对象动画
	 * @param	target
	 * @param	duration (s)
	 * @param	props
	 * @param	insertTime (s)
	 */ 
	public function insertTween(target:DisplayObject, duration:Float, props:Dynamic,insertTime:Float=0)
	{
		var tween:PTween = PTween.to(target, duration, props);
		insert(tween,insertTime);
	}
	
	// 添加对象动画
	public function appendTween(target:DisplayObject, duration:Float, props:Dynamic)
	{
		var tween:PTween = PTween.to(target, duration, props);
		append(tween);
	}
}