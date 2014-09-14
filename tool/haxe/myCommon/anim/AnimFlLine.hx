package anim;

/**
 * 动画集合，时间线
 * @author Pelephone
 */
class AnimFlLine extends AnimBase
{

	public function new() 
	{
		super();
		animMap = new Map<Int,Array<AnimFl>>();
	}
	
	var animMap:Map < Int, Array<AnimFl> > ;
	
	/**
	 * 在指定帧插入动画
	 * @param	frame
	 * @param	anim
	 */
	public function addAnim(frame:Int, anim:AnimFl)
	{
		var ary:Array<AnimFl> = animMap.get(frame);
		if (ary == null)
		{
			ary  = [];
			animMap.set(frame, ary);
		}
		ary.push(anim);
		if ((anim.totalFrames + frame) > _totalFrames)
		_totalFrames = anim.totalFrames + frame;
	}
	
	/**
	 * 移出动画
	 * @param	frame
	 * @param	anim
	 */
	public function removeAnim(frame:Int, anim:AnimFl)
	{
		var ary:Array<AnimFl> = animMap.get(frame);
		if (ary != null)
		ary.remove(anim);
		if (ary.length == 0)
		animMap.remove(frame);
	}
	
	override private function draw() 
	{
		//super.draw();
		var cFrame:Int;
		for (itmFrame in animMap.keys()) 
		{
			// 当前帧数减去子项组件插入帧得出组件当前停留帧
			cFrame = _currentFrame - itmFrame;
			var ary:Array<AnimFl> = animMap.get(itmFrame);
			for (itm in ary) 
			itm.currentFrame = cFrame;
		}
	}
	
	override public function dispose() 
	{
		super.dispose();
		
		for (itm in animMap.keys()) 
		{
			animMap.remove(itm);
		}
	}
}