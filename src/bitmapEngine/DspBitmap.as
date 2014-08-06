package bitmapEngine
{
	import TimerUtils.ExpireTimer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * 支持显示对象转位图的组件，能把失量转成位图。<br/>
	 * 功能同SpriteBitmap,不同的是本组件继承于Bitmap没有鼠标事件
	 * Pelephone
	 */
	public class DspBitmap extends Bitmap
	{
		public function DspBitmap(sourceDsp:DisplayObject=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
		}
		
		private var _source:DisplayObject;
		
		/**
		 * 源显示对象,即要换位图的显示对象 (可以是Bitmap,Sprite,Shape,MoviceClip)
		 * @return 
		 */
		public function get source():DisplayObject
		{
			return _source;
		}

		/**
		 * @private
		 */
		public function set source(value:DisplayObject):void
		{
			if(_source == value)
				return;
			_source = value;
			_sourceKey = getQualifiedClassName(value);
			updateBmpInfo();
		}
		
		/**
		 * 反射类主键
		 */
		private var _sourceKey:String;
		
		
		/**
		 * 当前帧渲染信息
		 */
		protected var _currentBmtInfo:BmpRenderInfo;
		
		/**
		 * 刷新当前帧信息
		 */
		private function updateBmpInfo():void
		{
			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			
			var value:BmpRenderInfo = getBmpFrame();
			if(_currentBmtInfo == value)
				return;
			
			// 把旧的数据丢入回收管理
			if(_currentBmtInfo != value && _currentBmtInfo)
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			if(_currentBmtInfo)
				_lastKey = _currentBmtInfo.key;
			
			_currentBmtInfo = value;
			
			if(value == null)
			{
				removeExpireEvt();
				bitmapData = null;
				return;
			}
			
			if(value.bitmapData == null)
			{
				value.addEventListener(Event.COMPLETE,onBmpdComplete);
				actExpireTimer();
				return;
			}
			onBmpdComplete();
		}
		
		/**
		 * 上帧显示的位图键
		 */
		private var _lastKey:String;
		
		/**
		 * 数据渲染完成
		 */
		private function onBmpdComplete(e:Event=null):void
		{
			if(!_currentBmtInfo)
				return;
			
			_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			if(_lastKey != _currentBmtInfo.key)
			{
				if(_lastKey)
				{
					var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
					bmpMgr.dropCache(_lastKey);
					_lastKey = null;
				}
				_currentBmtInfo.useCount = _currentBmtInfo.useCount + 1;
			}
			
			bitmapData = _currentBmtInfo.useBitmapData();
			if(bitmapData)
				transform.matrix = _currentBmtInfo.getFrameMaxtrix();
			actExpireTimer();
		}
		
		/**
		 * 从缓存获取渲染信息
		 */
		protected function getBmpFrame():BmpRenderInfo
		{
			return BmpRenderMgr.getInstance().getNewCache(_sourceKey,0,_source);
		}
		
		//----------------------------------------------------
		// 位图过期管理 (位图数据移出舞台一段时间会调用过期函数)
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
		 * 激活过期管理器
		 */
		protected function actExpireTimer():ExpireTimer
		{
			if(etr)
			{
				if(!etr.hasAct)
				{
					etr.active(this);
					etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
					etr.addEventListener(ExpireTimer.RESET,onReset);
				}
				return etr;
			}
			var etr:ExpireTimer = new ExpireTimer(this,2*60*1000);
			etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			etr.addEventListener(ExpireTimer.RESET,onReset);
			return etr;
		}
		
		/**
		 * 移除过期事件
		 */
		private function removeExpireEvt():void
		{
			if(_currentBmtInfo)
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			if(expireTimer)
			{
				expireTimer.removeEventListener(ExpireTimer.RESET,onReset);
				expireTimer.removeEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
				expireTimer.dispose();
			}
		}
		
		/**
		 * 重置
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			updateBmpInfo();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set bitmapData(value:BitmapData):void
		{
			if(_currentBmtInfo && value == null && value != bitmapData)
			{
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
				var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
				bmpMgr.dropCache(_currentBmtInfo.key);
			}
			super.bitmapData = value;
		}
		
		/**
		 * 当前显示的位图资源过期回收
		 * @param e
		 */
		protected function onExpired(e:Event=null):void
		{
			_currentBmtInfo = null;
			bitmapData = null;
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			onExpired();
			removeExpireEvt();
		}
	}
}