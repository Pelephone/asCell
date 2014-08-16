package bitmapEngine.bak
{
	import TimerUtils.ExpireTimer;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import bitmapEngine.BmpRenderInfo;
	import bitmapEngine.BmpRenderMgr;

	/**
	 * 位图转换组件
	 * Pelephone
	 */
	public class BitmapConvert implements IBmpConvert
	{
		public function BitmapConvert(target:Bitmap=null,sourceDsp:DisplayObject=null)
		{
			setBmpRender(this);
			source = sourceDsp;
			bitmap = target;
			_expireTimer = newExpireTimer();
		}
		
		/**
		 * 渲染管理
		 
		public var bmpMgr:BmpRenderMgr;*/
		
		//----------------------------------------------------
		// source
		//----------------------------------------------------
		
		protected var _source:Object;
		/**
		 * 源显示对象(可以是Bitmap,Sprite,Shape,MoviceClip)
		 */
		public function get source():Object
		{
			return _source;
		}
		
		/**
		 * @private
		 */
		public function set source(value:Object):void
		{
			if(_source == value)
				return;
			_source = value;
			doRender();
		}
		
		/**
		 * 待渲染的目标位图
		 */
		protected var _bitmap:Bitmap;
		
		/**
		 * 当前帧的Bitmap<br/>
		 * 此bmp里面的bitmapdata不能被其它地方引用，因为它会在管理器中自动回收，
		 * 自动回收时如果外部引用会导致显示错误
		 */
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}
		
		/**
		 * @private
		 */
		public function set bitmap(value:Bitmap):void
		{
			if(_bitmap == value)
				return;
			
			_bitmap = value;
			doRender();
		}
		
		//----------------------------------------------------
		// 渲染数据部份
		//----------------------------------------------------
		
		/**
		 * 渲染
		 * @param arg
		 */
		public function doRender(arg:Object=null):void
		{
			if(source==null)
				currentBmtInfo = null;
			else
				currentBmtInfo = _bmpRender.getBmpFrame();
			// 尽量少用Function.applay，提升渲染效率
//			source.addEventListener(Event.ENTER_FRAME,function(e:*):void{rendering()});
//			StaticEnterFrame.addNextCall(rendering);
		}
		
		/**
		 * 正在渲染
		 
		protected function rendering():void
		{
			if(source==null)
				currentBmtInfo = null;
			else
				currentBmtInfo = getBmpFrame();
		}*/
		
		/**
		 * 渲染转换工具
		 */
		private var _bmpRender:IBmpConvert;

		/**
		 * 位图帧数据
		 */
		public function setBmpRender(value:IBmpConvert=null):void
		{
			if(value == _bmpRender)
				return;
			
			if(value == null)
				value = this;
			
			_bmpRender = value;
		}

		
		/**
		 * 从缓存获取池里面渲染信息
		 * @return 
		 */
		public function getBmpFrame():BmpRenderInfo
		{
			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			var key:String = bmpMgr.getKeyByFrame(source,currentFrame);
			var res:BmpRenderInfo = bmpMgr.getCache(key);
			if(!res)
			{
				res = bmpMgr.newBmpData(source as DisplayObject,currentFrame);
				res.key = key;
				bmpMgr.setBmpCache(res);
			}
			return res;
		}
		
		private var _currentFrame:int = 1;

		/**
		 * 当前帧(如果source是mc时才能用)
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		/**
		 * @private
		 */
		public function set currentFrame(value:int):void
		{
			var mc:MovieClip = _source as MovieClip;
			if(_currentFrame == value || !mc)
				return;
			
			if(value > mc.totalFrames)
				value = mc.totalFrames;
			else if(value < 1)
				value = 1;
			
			_currentFrame = value;
			doRender();
		}
		
		private var _currentBmtInfo:BmpRenderInfo;
		
		/**
		 * 当前帧信息<br/>
		 * 此对象里面的bitmapdata不能被其它地方引用，因为它会在管理器中自动回收，
		 * 自动回收时如果外部引用会导致显示错误
		 */
		public function get currentBmtInfo():BmpRenderInfo
		{
			return _currentBmtInfo;
		}
		
		/**
		 * @private
		 */
		public function set currentBmtInfo(value:BmpRenderInfo):void
		{
			if(value == _currentBmtInfo || _bitmap == null)
				return;
			
			if(_currentBmtInfo)
				BmpRenderMgr.getInstance().dropCache(_currentBmtInfo.key);
			
			_currentBmtInfo = value;
			
			if(value == null)
				_bitmap.bitmapData = null;
			else
			{
				_bitmap.bitmapData = value.useBitmapData();
				_bitmap.transform.matrix = value.getFrameMaxtrix();
//				_bitmap.transform.matrix.ty = value.ypos;
//				if(isOffset)
//				{
//					_bitmap.x = - value.xpos;
//					_bitmap.y = - value.ypos;
//				}
			}
			
//			if(!_bitmap.bitmapData){
//				_bitmap.bitmapData = new BitmapData(currentBmtInfo.bitmapData.width,currentBmtInfo.bitmapData.height,true,0);
//			}
//			_bitmap.bitmapData.copyPixels(currentBmtInfo.bitmapData,currentBmtInfo.bitmapData.rect,new Point(0,0));
//			if(_bitmap.y != ( - currentBmtInfo.ypos))
		}
		
		/**
		 * 渲染时是否偏移调整x,y坐标
		 
		public var isOffset:Boolean = true;*/
		
		//----------------------------------------------------
		// 回收管理
		//----------------------------------------------------
		
		private var _expireTimer:ExpireTimer;

		/**
		 * 过期管理
		 */
		public function get expireTimer():ExpireTimer
		{
			return _expireTimer;
		}
		
		/**
		 * 新建过期管理器
		 */
		protected function newExpireTimer():ExpireTimer
		{
			var etr:ExpireTimer = new ExpireTimer(bitmap,2*60*1000);
			etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			etr.addEventListener(ExpireTimer.RESET,onReset);
			return etr;
		}
		
		/**
		 * 重置
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			doRender();
		}
		
		/**
		 * 当前显示的位图资源过期回收
		 * @param e
		 */
		protected function onExpired(e:Event=null):void
		{
			currentBmtInfo = null;
		}
		
		/**
		 * 销毁对象(销毁会则不能再使用)
		 */
		public function dispose():void
		{
			currentBmtInfo = null;
			_source = null;
			_bmpRender = null;
//			_bitmap = null;
			
			if(expireTimer)
			{
				expireTimer.removeEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
				expireTimer.removeEventListener(ExpireTimer.RESET,onReset);
			}
		}
	}
}