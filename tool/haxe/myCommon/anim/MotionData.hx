package anim;

/**
 * 动画数据
 * @author Pelephone
 */
class MotionData
{

	public function new() 
	{
		attrFrameMap = new Map < String, Array<Float> > ();
	}
	
	var attrFrameMap:Map < String, Array<Float> > ;
	
	// 添加一属性的每一帧数据
	public function addPropertyArray(property:String, ary:Array<Float>)
	{
		attrFrameMap.set(property, ary);
		if (ary.length > _maxLen)
		_maxLen = ary.length;
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
	
	/**
	 * 最长的帧数
	 */
	private var _maxLen:Int;
	
	function get_maxLen():Int 
	{
		return _maxLen;
	}
	
	public var maxLen(get_maxLen, null):Int;
}