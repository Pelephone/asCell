package utils.tools
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	
	/**
	 * 颜色工具
	 */
	public class ColorTool
	{
		// 灰度色调
		static public const matrix_gray:Array = [0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0];
		static public const filter_gray:ColorMatrixFilter = new ColorMatrixFilter(matrix_gray);
		
		// 红色遮罩
		static public const matrix_red:Array = [
			0.5, 0, 0, 0, 127,
			0, 0.5, 0, 0, 0, 
			0, 0, 0.5, 0, 0,
			0, 0, 0, 1, 0];
		static public const filter_red:ColorMatrixFilter = new ColorMatrixFilter(matrix_red);
		
		/**
		 * 添加/删除 滤镜到控件中, 使控件改变色调
		 * @param disp			被添加/删除的目标窗口
		 * @param filter		被添加/删除的滤镜
		 * @param addRemove		true=添加, false=删除
		 */
		static public function applyFilter_colorMatrix(disp:DisplayObject, filter:ColorMatrixFilter, addRemove:Boolean):void{
			if(!disp || !filter) return;			
			var filters:Array = disp.filters;
			
			// remove
//			var index:int = filters.indexOf(filter);
//			if(index >= 0) filters.splice(index, 1);
			for(var i:int=0; i<filters.length; ){
				if(filters[i] is ColorMatrixFilter) filters.splice(i, 1);
				else i++;
			}
			
			// add
			if(addRemove) filters.push( filter );
			
			// assign
			disp.filters = filters; 
		}
		
		/**
		 * 添加/删除 灰色滤镜, 加入灰色滤镜后, 控件显示 黑白 单色而非彩色
		 * @param disp			被添加/删除的目标窗口
		 * @param addRemove		true=添加, false=删除
		 */
		static public function applyFilter_gray(disp:DisplayObject, addRemove:Boolean):void{
			ColorTool.applyFilter_colorMatrix( disp, ColorTool.filter_gray, addRemove );
		}
		
		/**
		 * 设置容器颜色
		 * @param sp 要设置颜色的MC
		 * @param color	要设置的颜色
		 * @param light 亮度默认为0.1
		 */
		static public function setSpColor(sp:DisplayObject,color:uint,light:Number=0.1):void
		{
			sp.filters = [getColorFilter(color,light)];
		}
		
		/**
		 * 获取颜色滤镜
		 * @param color
		 * @param ligtht
		 */		
		static public function getColorFilter(color:uint,ligtht:Number=0.1):ColorMatrixFilter
		{
			var colorTrans:ColorTransform = new ColorTransform();
			colorTrans.color = color;
			var colorArr:Array = [ colorTrans.redOffset/255, ligtht, ligtht, 0, 0,
				ligtht, colorTrans.greenOffset/255, ligtht, 0, 0,
				ligtht, ligtht, colorTrans.blueOffset/255, 0, 0,
				0, 0, 0, 1, 0];
			var colorFilter:ColorMatrixFilter = new ColorMatrixFilter(colorArr);
			return colorFilter;
		}
		
		/**
		 * 添加红色滤镜
		 */
		static public function applyFilter_red(disp:DisplayObject, addRemove:Boolean):void{
			ColorTool.applyFilter_colorMatrix( disp, ColorTool.filter_red, addRemove );
		}
		
		/**
		 * 通过RGB三色色值计算返回十六进制色值
		 * @param rr red channel
		 * @param gg green channel
		 * @param bb blue channel
		 */
		public static function getRGBWith(rr:uint, gg:uint, bb:uint):uint {
			var r:uint = rr;
			var g:uint = gg;
			var b:uint = bb;
			if(r > 255){
				r = 255;
			}
			if(g > 255){
				g = 255;
			}
			if(b > 255){
				b = 255;
			}
			var color_n:uint = (r<<16) + (g<<8) +b;
			return color_n;
		}
	}
}