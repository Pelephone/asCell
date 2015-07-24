package p1fTween;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.Lib;
import haxe.Timer;
import openfl.utils.Object;
import p1fTween.easing.Expo;

/**
 * 缓动组件
 * @author Pelephone
 */
class PTween
{
	public function new(target:Dynamic=null,duration:Float=0,propItem:Dynamic=null) 
	{
		this.target = target;
		this.duration = duration;
		this.props = propItem;
		ease = Expo.easeOut;
		start();
	}
	
	public var target:Dynamic;
	
	public var duration:Float = 0;
	
	public var props:Dynamic;
	
	public var startProps:Map<String,Float>;
	
	public var ease:Float->Float->Float->Float->Float;
	
	public var completeCall:Dynamic->Void;
	
	public var completeParams:Dynamic;
	
	/** 播放完成之后是否立刻清除 */
	public var autoKill:Bool = true;
	
	/** 是否已在时间轴上面初始过 */
	public var isInitTimeLine:Bool = false;
	
	var startTime:Float = 0;
	
	// 初始动画参数
	public function initParams(startT:Float)
	{
		startTime = startT;
		ratio = 0;
		startProps = new Map<String,Float>();
		for (field in Reflect.fields(props)) 
		{
			startProps.set(field, Reflect.getProperty(target, field));
		}
	}
	
	// 开始动画
	public function start()
	{
		initParams(Timer.stamp());
		Lib.current.removeEventListener(Event.ENTER_FRAME, update);
		Lib.current.addEventListener(Event.ENTER_FRAME, update);
	}
	
	public function kill()
	{
		stop();
		completeCall = null;
		completeParams = null;
		ratio = 1;
		duration = 0;
		this.target = null;
		this.props = null;
		autoKill = true;
		//tweeningTarget.remove(target);
	}
	
	public function stop()
	{
		Lib.current.removeEventListener(Event.ENTER_FRAME, update);
	}
	
	public var ratio:Float = 1;
	
	private function update(e:Event):Void 
	{
		calcTime();
		if (ratio >= 1)
		{
			stop();
			if(completeCall != null)
			{
				//if(Std.is(completeParams,Array))
				//Reflect.callMethod(this, completeCall, completeParams);
				//else
				completeCall(completeParams);
			}
			if(autoKill)
			{
				//killTween(this);
				completeCall = null;
				completeParams = null;
				this.target = null;
				this.props = null;
			}
		}
	}
	
	// 计算当前时间改变
	function calcTime()
	{
		var curTime:Float = Timer.stamp();
		var passTime:Float = curTime - startTime;
		doPassTime(passTime);
	}
	
	private function getDuration():Float
	{
		return duration;
	}
	
	// 通过经过时间设置坐标
	public function doPassTime(passTime:Float)
	{
		var dura:Float = getDuration();
		ratio = passTime / dura;
		if (ratio > 1)
		ratio = 1;
		for (field in Reflect.fields(props)) 
		{
			var rate:Float = ease(passTime, 0, 1, dura);
			var fa:Float = Reflect.getProperty(props, field);
			var sar:Float = startProps.get(field);
			var value:Float = sar + (fa - sar) * rate;
			if (ratio == 1)
			value = fa;
			
			Reflect.setProperty(target, field, value);
		}
	}
	
	/**
	 * 延迟处理方法
	 * @param	delay 延迟秒数(s)
	 * @param	complete
	 * @param	params
	 * @return
	 */
	public static function delayCall(delay:Float,complete:Dynamic->Void,params:Dynamic=null):PTween
	{
		var pt:PTween = new PTween(null, delay, null);
		pt.completeCall = complete;
		pt.completeParams = params;
		return pt;
	}
	
	
	/**
	 * 使对象缓动至
	 */
	public static function to(target:DisplayObject,duration:Float,propItem:Dynamic):PTween
	{
		var ptn:PTween = new PTween(target, duration, propItem);
		//getLib(target).push(ptn);
		return ptn;
	}
	
	/**
	 * 获取对象对应的缓动组
	 
	private static function getLib(target:Object):Array<PTween>
	{
		if (!targetLibraries.exists(target))
			targetLibraries.set (target, new Array <PTween> ());
		
		return targetLibraries.get (target);
	}*/
	
	/**
	 * 清除某动画
	 
	public static function killTween(tween:PTween):Void
	{
		if (!targetLibraries.exists(target))
		return;
		tween.kill();
		targetLibraries.get(target).remove(tween);
	}*/
	
	/**
	 * 清除对象的所有动画
	 
	public static function killTarget(target:Object):Void
	{
		if (!targetLibraries.exists(target))
		return;
		var aryLib:Array<PTween> = getLib(target);
		for (itm in aryLib) 
			itm.kill();
		
		targetLibraries.remove(target);
	}*/
	
	/** 当前正在动画的对象映射 
	private static var targetLibraries:Map<Object,Array<PTween>> = new Map<Object,Array<PTween>>();*/
}