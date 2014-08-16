package asSkinStyle.i;
/**
 * 绘制矩形
 * @author Pelephone
 */
interface IRectDraw extends IDrawBase
{
	//---------------------------------------------------
	// border
	//---------------------------------------------------
	
	/**
	* 上边框厚度
	*/
	function get_borderTop():Int;
	
	/**
	 * @private
	 */
	function set_borderTop(value:Int):Void;
	
	/**
	 * 右边框厚度
	 */
	function get_borderRight():Int;
	
	/**
	 * @private
	 */
	function set_borderRight(value:Int):Void;
	
	/**
	 * 左边框厚度
	 */
	function get_borderLeft():Int;
	
	/**
	 * @private
	 */
	function set_borderLeft(value:Int):Void;
	
	/**
	 * 下边框厚度
	 */
	function get_borderBottom():Int;
	
	/**
	 * @private
	 */
	function set_borderBottom(value:Int):Void;
	
	//---------------------------------------------------
	// borderColor
	//---------------------------------------------------
	
	/**
	 * 上边框颜色
	 */
	function get_borderTopColor():Int;
	
	/**
	 * @private
	 */
	function set_borderTopColor(value:Int):Void;
	
	/**
	 * 左边框颜色
	 */
	function get_borderLeftColor():Int;
	
	/**
	 * @private
	 */
	function set_borderLeftColor(value:Int):Void;
	
	/**
	 * 右边框颜色
	 */
	function get_borderRightColor():Int;
	
	/**
	 * @private
	 */
	function set_borderRightColor(value:Int):Void;
	
	/**
	 * 下边框颜色
	 */
	function get_borderBottomColor():Int;
	
	/**
	 * @private
	 */
	function set_borderBottomColor(value:Int):Void;
	
	//---------------------------------------------------
	// padding
	//---------------------------------------------------
	
	/**
	 * 上边矩
	 * @param value
	 */
	function set_paddingTop(value:Int):Void;
	/**
	 * @private
	 */
	function get_paddingTop():Int;
	
	/**
	 * 右边距
	 * @param value
	 */
	function set_paddingRight(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_paddingRight():Int;
	
	/**
	 * 左边距
	 * @param value
	 */
	function set_paddingLeft(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_paddingLeft():Int;
	
	/**
	 * 下边距
	 * @param value
	 */
	function set_paddingBottom(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_paddingBottom():Int;
	
	//---------------------------------------------------
	// 其它
	//---------------------------------------------------
	
	/**
	 * 内距形背景色 -1表示无内距形
	 * @param value
	 */
	function set_inBgColor(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_inBgColor():Int;
	
	/** 
	 * 圆角,border不为0是有效
	 */
	function get_ellipse():Int;
	
	/**
	 * @private
	 */
	function set_ellipse(value:Int):Void;
	
	/**
	 * 内矩形圆角
	 * @param value
	 */
	function set_inEllipse(value:Int):Void;
	
	/**
	 * @private
	 */
	function get_inEllipse():Int;
}