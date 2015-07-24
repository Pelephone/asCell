package p1fTween;
import flash.display.DisplayObject;
import flash.events.Event;

/**
 * 跟随移动
 * @author Pelephone
 */
class PFollowTween extends PTween
{

	public function new(target:DisplayObject=null,follow:DisplayObject,duration:Float=0) 
	{
		var prop:Dynamic = { x:follow.x, y:follow.y };
		followTarget = follow;
		super(target,duration,prop);
	}
	
	public var offX:Int = 0;
	public var offY:Int = 0;
	
	var followTarget:DisplayObject;
	
	override function kill()
	{
		super.kill();
		followTarget = null;
	}
	
	override function update(e:Event)
	{
		props.x = followTarget.x + offX;
		props.y = followTarget.y + offY;
		super.update(e);
		if (ratio >= 1)
		followTarget = null;
	}
	
	/**
	 * 跟随对象移动,一定时间后坐标和目标点一至
	 */
	public static function to(target:DisplayObject,follow:DisplayObject,duration:Float=0):PFollowTween
	{
		return new PFollowTween(target,follow,duration);
	}
}