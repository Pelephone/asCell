package anim;

import flash.display.DisplayObject;

/**
 * 解析Flash动画xml组件
 * flash有个功能，右键时间线->将动画复制为actionscript3,这个组件就是用于解析复制出来的代码
 * @author Pelephone
 */
class AnimFl extends AnimBase
{

	public function new(targetDsp:DisplayObject,motionData:MotionData) 
	{
		super();
		_data = motionData;
		target = targetDsp;
		
		_totalFrames = _data.maxLen;
	}
	
	public var target:DisplayObject;
	
	private var _data:MotionData;
	
	function get_data():MotionData 
	{
		return _data;
	}
	
	function set_data(value:MotionData):MotionData 
	{
		if (value == _data)
		return null;
		return _data = value;
		_totalFrames = _data.maxLen;
	}
	
	public var data(get_data, set_data):MotionData;
	
	override public function dispose() 
	{
		super.dispose();
		
		_data = null;
		_totalFrames = 0;
		target = null;
	}
	
	/**
	 * 设置对象属性
	 */
	private function setProperty(v:Dynamic,field:String,val:Dynamic):Void
	{
		var attr = Reflect.field(v, field);
		if (Std.is(attr, String))
		{
			Reflect.setProperty(v, field, Std.string(val));
			return;
		}
		switch( Type.typeof(attr) ) 
		{
			case TNull:
				Reflect.setProperty(v, field, val);
			case TInt:
				Reflect.setProperty(v, field, Std.parseInt(val));
			case TFloat:
				Reflect.setProperty(v, field, Std.parseFloat(val));
			default:
				Reflect.setProperty(v, field, val);
		}
	}
	
	override private function draw() 
	{
		super.draw();
		if (_data == null)
		return;
		
		var map:Map<String,Float> = _data.getFrameProperty(_currentFrame-1);
		for (itm in map.keys())
		setProperty(target, itm, map.get(itm));
	}
}