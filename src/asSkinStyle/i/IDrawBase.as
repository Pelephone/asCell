package asSkinStyle.i
{
	/**
	 * 绘图基本参数
	 * @author Pelephone
	 */
	public interface IDrawBase
	{
		/**
		 * 绘制宽
		 */
		function set width(value:Number):void;
		
		/**
		 * @private
		 */
		function get width():Number;
		
		/**
		 * 绘制高
		 */
		function set height(value:Number):void;
		
		/**
		 * @private
		 */
		function get height():Number;
		
		/**
		 * 背景alpha值
		 */
		function set bgAlpha(value:Number):void;
		
		/**
		 * @private
		 */
		function get bgAlpha():Number;
		
		/**
		 * @private
		 */
		function get bgColor():int;
		
		/**
		 * 背景颜色,-1表示不填色
		 */
		function set bgColor(value:int):void;
		
		/**
		 *  渐变用色,-1表示不填色
		 */
		function get bgColor2():int;
		
		/**
		 * @private
		 */
		function set bgColor2(value:int):void;
		
		/**
		 * 边线粗细
		 */
		function get border():int;
		
		/**
		 * @private
		 */
		function set border(value:int):void;
		
		/**
		 * 边线颜色
		 */
		function get borderColor():int;
		
		/**
		 * @private
		 */
		function set borderColor(value:int):void;
		
		/** 
		 * 渐变角度
		 */
		function get bgRotaion():Number;
		
		/**
		 * @private
		 */
		function set bgRotaion(value:Number):void;
		
		/**
		 * 内边距
		 * @param value
		 */
		function set padding(value:int):void;
		
		/**
		 * @private
		 */
		function get padding():int;
	}
}