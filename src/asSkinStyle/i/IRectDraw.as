package asSkinStyle.i
{
	/**
	 * 绘制矩形
	 * @author Pelephone
	 */
	public interface IRectDraw extends IDrawBase
	{
		//---------------------------------------------------
		// border
		//---------------------------------------------------
		
		/**
		* 上边框厚度
		*/
		function get borderTop():int;
		
		/**
		 * @private
		 */
		function set borderTop(value:int):void;
		
		/**
		 * 右边框厚度
		 */
		function get borderRight():int;
		
		/**
		 * @private
		 */
		function set borderRight(value:int):void;
		
		/**
		 * 左边框厚度
		 */
		function get borderLeft():int;
		
		/**
		 * @private
		 */
		function set borderLeft(value:int):void;
		
		/**
		 * 下边框厚度
		 */
		function get borderBottom():int;
		
		/**
		 * @private
		 */
		function set borderBottom(value:int):void;
		
		//---------------------------------------------------
		// borderColor
		//---------------------------------------------------
		
		/**
		 * 上边框颜色
		 */
		function get borderTopColor():int;
		
		/**
		 * @private
		 */
		function set borderTopColor(value:int):void;
		
		/**
		 * 左边框颜色
		 */
		function get borderLeftColor():int;
		
		/**
		 * @private
		 */
		function set borderLeftColor(value:int):void;
		
		/**
		 * 右边框颜色
		 */
		function get borderRightColor():int;
		
		/**
		 * @private
		 */
		function set borderRightColor(value:int):void;
		
		/**
		 * 下边框颜色
		 */
		function get borderBottomColor():int;
		
		/**
		 * @private
		 */
		function set borderBottomColor(value:int):void;
		
		//---------------------------------------------------
		// padding
		//---------------------------------------------------
		
		/**
		 * 上边矩
		 * @param value
		 */
		function set paddingTop(value:int):void;
		/**
		 * @private
		 */
		function get paddingTop():int;
		
		/**
		 * 右边距
		 * @param value
		 */
		function set paddingRight(value:int):void;
		
		/**
		 * @private
		 */
		function get paddingRight():int;
		
		/**
		 * 左边距
		 * @param value
		 */
		function set paddingLeft(value:int):void;
		
		/**
		 * @private
		 */
		function get paddingLeft():int;
		
		/**
		 * 下边距
		 * @param value
		 */
		function set paddingBottom(value:int):void;
		
		/**
		 * @private
		 */
		function get paddingBottom():int;
		
		//---------------------------------------------------
		// 其它
		//---------------------------------------------------
		
		/**
		 * 内距形背景色 -1表示无内距形
		 * @param value
		 */
		function set inBgColor(value:int):void;
		
		/**
		 * @private
		 */
		function get inBgColor():int;
		
		/** 
		 * 圆角,border不为0是有效
		 */
		function get ellipse():int;
		
		/**
		 * @private
		 */
		function set ellipse(value:int):void;
		
		/**
		 * 内矩形圆角
		 * @param value
		 */
		function set inEllipse(value:int):void;
		
		/**
		 * @private
		 */
		function get inEllipse():int;
	}
}