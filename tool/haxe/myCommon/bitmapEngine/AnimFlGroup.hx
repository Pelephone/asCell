package bitmapEngine;

/**
 * 动画集合，时间线
 * @author Pelephone
 */
class AnimFlGroup extends AnimFlash
{

	public function new() 
	{
		super(null, null);
		map = new Map<Int,Array<AnimFlash>>();
	}
	
	var map:Map < Int, Array<AnimFlash> > ;
	
	/**
	 * 在指定帧插入动画
	 * @param	frame
	 * @param	anim
	 */
	public function addAnim(frame:Int, anim:AnimFlash)
	{
		
	}
	
	override private function draw() 
	{
		super.draw();
	}
}