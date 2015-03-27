package pTween;
import flash.events.Event;
import flash.Lib;
import haxe.Timer;

/**
 * 缓动组件
 * @author Pelephone
 */
class PTween
{
	public function new(target:Dynamic,duration:Float,propItem:Dynamic) 
	{
		this.target = target;
		this.duration = duration;
		this.props = propItem;
		ease = Linear.easeNone;
		start();
	}
	
	public var target:Dynamic;
	
	public var duration:Float = 0;
	
	public var props:Dynamic;
	
	public var startProps:Map<String,Float>;
	
	var ease:Float->Float->Float->Float->Float;
	
	public var completeCall:Dynamic->Void;
	
	public var completeParams:Dynamic;
	
	var startTime:Float;
	
	public function start()
	{
		startTime = Timer.stamp();
		startProps = new Map<String,Float>();
		for (field in Reflect.fields(props)) 
		{
			startProps.set(field, Reflect.getProperty(target, field));
		}
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	
	public var ratio:Float = 0;
	
	private function update(e:Event):Void 
	{
		var curTime:Float = Timer.stamp();
		var passTime:Int = curTime - passTime;
		ratio = passTime / duration;
		if (ratio > 1)
		ratio = 1;
		for (field in Reflect.fields(props)) 
		{
			var rate:Float = ease(passTime, 0, 1, duration);
			var fa:Float = Reflect.getProperty(props, field);
			var sar:Float = startProps.get(field);
			var value:Float = sar + (fa - sar) * rate;
			Reflect.setProperty(target, field, value);
		}
		if (ratio >= 1)
		{
			Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
			if(completeCall != null)
			{
				completeCall(completeParams);
				completeCall = null;
			}
		}
	}
	
	
	/**
	 * 使对象缓动至
	 */
	public static function to(target:Dynamic,duration:Float,propItem:Dynamic):PTween
	{
		return new PTween(target,duration,propItem);
	}
}