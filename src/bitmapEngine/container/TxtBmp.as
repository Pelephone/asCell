package bitmapEngine.container
{
	import flash.text.TextField;

	/**
	 * 文本转位图工具(此工具末完善)
	 * @author Pelephone
	 */
	public class TxtBmp extends SpriteBitmap
	{
		public function TxtBmp()
		{
			super();
		}
		
		public function set text(value:String):void
		{
			sourcTxt.text = value;
		}
		
		public function get text():String 
		{
			return sourcTxt.text;
		}
		
		public function set htmlText(value:String):void 
		{
			sourcTxt.htmlText = value;
		}
		
		public function get htmlText():String 
		{
			return sourcTxt.htmlText;
		}
		
		override public function doRender(arg:Object=null):void
		{
			// 文本文字改变或者滤镜改变须掉此方法重新生成一次位图信息
			currentBmtInfo =  bmpMgr.newBmpData(source,1);
		}
		
/*		override protected function getBmpFrame():BmpRenderInfo
		{
			var bmpFrame:BmpRenderInfo = bmpMgr.getCache(source,1);
			
			if(!bmpFrame) 
			{
				bmpFrame = bmpMgr.newBmpData(source);
				// 不用缓存了，文本显示改变很频繁
//				bmpMgr.putCache(source,1);
			}
			
			return bmpFrame;
		}*/
		
		public function get sourcTxt():TextField 
		{
			return source as TextField;
		}
	}
}