package asSkinStyle.i;

/**
 * 绘图基本参数
 * @author Pelephone
 */
interface IDrawBase
{
	function set_width(value:Float):Void;
	function get_width():Float;
	function set_height(value:Float):Void;
	function get_height():Float;
	
	/**
	 * 背景alpha值
	 */
	function set_bgAlpha(value:Float):Void;
	
	/**
	 * @private
	 */
	function get_bgAlpha():Float;
	
	/**
	 * @private
	 */
	function get_bgColor():Int;
	
	/**
	 * 背景颜色,-1表示不填色
	 */
	function set_bgColor(value:Int):Void;
	
	/**
	 *  渐变用色,-1表示不填色
	 */
	function get_bgColor2():Int;
	
	/**
	 * @private
	 */
	function set_bgColor2(value:Int):Void;
	
	/**
	 * 边线粗细
	 */
	function get_border():Int;
	
	/**
	 * @private
	 */
	function set_border(value:Int):Void;
	
	/**
	 * 边线颜色
	 */
	function get_borderColor():Int;
	
	/**
	 * @private
	 */
	function set_borderColor(value:Int):Void;
	
	/** 
	 * 渐变角度
	 */
	function get_bgRotaion():Float;
	
	/**
	 * @private
	 */
	function set_bgRotaion(value:Float):Void;
	
	/**
	 * 内边距
	 * @param value
	 */
	function set_padding(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_padding():Int;
}