package bitmapEngine.bak
{
	import bitmapEngine.BmpRenderInfo;
	
	/**
	 * 获取位图转换信息
	 * Pelephone
	 */
	public interface IBmpConvert
	{
		/**
		 * 获取帧位图数据信息
		 * @return 
		 */
		function getBmpFrame():BmpRenderInfo;
		
		/**
		 * 通过源对象生成转换信息
		 * @param value
		 
		function set source(value:Object):void;*/
		
		/**
		 * @private 
		 
		function get source():Object;*/
	}
}