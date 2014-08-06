package bitmapEngine.bak
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	
	/**
	 * 支持显示对象转位图的组件，能把失量转成位图。<br/>
	 * 功能同SpriteBitmap,不同的是本组件继承于Bitmap没有鼠标事件
	 * Pelephone
	 */
	public class DspBmp extends Bitmap
	{
		public function DspBmp(sourceDsp:DisplayObject=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
			_convertClip = newConverClip(sourceDsp);
//			_convertClip.isOffset = false;
		}
		
		/**
		 * 新建转换组件
		 * @param source
		 * @return 
		 */
		protected function newConverClip(source:DisplayObject):BmpConvert
		{
			return new BmpConvert();
		}
		
		protected var _convertClip:BmpConvert;

		/**
		 * 位图转换器
		 */
		public function get convertClip():BmpConvert
		{
			return _convertClip;
		}
		
		/**
		 * 源显示对象(可以是Bitmap,Sprite,Shape,MoviceClip)
		 * @return 
		 */
		public function get source():DisplayObject
		{
			return _convertClip.source as DisplayObject;
		}

		/**
		 * @private
		 */
		public function set source(value:DisplayObject):void
		{
			_convertClip.source = value;
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			_convertClip = null;
		}
	}
}