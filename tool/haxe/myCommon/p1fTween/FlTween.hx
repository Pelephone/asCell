package p1fTween;
import haxe.Timer;

/**
 * flash生成的帧数据动画.
 * 在动画帧上面右键->将动画复制为as3.0
 * @author Pelephone
 */
class FlTween extends PTween
{
	public function new(target:Dynamic=null,rate:Int=60) 
	{
		attrFrameMap = new Map < String, Array<Float> > ();
		frameRate = rate;
		super(target);
	}
	
	//帧率 , 必须要在addPropertyArray方法调用之前设计帧率
	public var frameRate:Int = 60;
	var attrFrameMap:Map < String, Array<Float> > ;
	// 最大数组长度
	var maxFrame:Int = 0;
	
	// 是否相对开始位置起移动
	public var isStartProp:Bool = true;
	
	override public function initParams(startT:Float) 
	{
		duration = maxFrame / frameRate;
		ratio = 0;
		
		if(isStartProp)
		{
			startProps = getFrameProperty(0);
			for (attr in startProps.keys()) 
				startProps.set(attr, Reflect.getProperty(target, attr));
		}
		startTime = startT;
	}
	
	override public function kill() 
	{
		super.kill();
		attrFrameMap = new Map < String, Array<Float> > ();
	}
	
	override public function doPassTime(passTime:Float) 
	{
		var dura:Float = getDuration();
		ratio = passTime / dura;
		if (ratio > 1)
		ratio = 1;
		
		var curFrame:Int = Math.round(maxFrame * ratio);
		if (curFrame >= maxFrame)
		curFrame = maxFrame - 1;
		
		var map:Map<String,Float> = getFrameProperty(curFrame);
		for (attr in map.keys())
		{
			var value:Float = map.get(attr);
			if(isStartProp)
			value = startProps.get(attr) + value;
			Reflect.setProperty(target, attr, value);
		}
	}
	
	/** 增加某一属性的动画属性 */
	public function addPropertyArray(property:String, ary:Array<Float>)
	{
		attrFrameMap.set(property, ary);
		if (ary.length > maxFrame)
		maxFrame = ary.length;
		
		initParams(Timer.stamp());
	}
	
	/**
	 * 获取某一帧时各属性状态数据
	 * 帧数从0开始
	 */
	public function getFrameProperty(frame:Int):Map<String,Float>
	{
		var map:Map<String,Float> = new Map<String,Float>();
		for (itm in attrFrameMap.keys())
		{
			var ary:Array<Float> = attrFrameMap.get(itm);
			if(ary.length > frame)
				map.set(itm, ary[frame]);
		}
		return map;
	}
}