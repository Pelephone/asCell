package bitmapEngine
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import TimerUtils.ExpireTimer;
	import TimerUtils.StaticEnterFrame;
	
	/**
	 * 支持9格缩放的位图(生成的位图bitmapData数据做有缓存处理)
	 * @author Pelephone
	 */
	public class Scale9GridBitmap extends Sprite
	{
		public function Scale9GridBitmap(sourceDsp : DisplayObject = null, scale9Grid : Rectangle = null
										 , pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
			source = sourceDsp;
			if(source)
			{
				_width = _source.width;
				_height = _source.height;
			}
			this.scale9Grid = scale9Grid;
			initializeBlocks();
			newExpireTimer();
		}
		
		//---------------------------------------------------------------------------------------------------------------------------------------------------
		// Blocks
		//---------------------------------------------------------------------------------------------------------------------------------------------------
		
/*		// TopLeft
		private var _topLeft:Bitmap = null;
		
		// Top
		private var _top:Bitmap = null;
		
		// TopRight
		private var _topRight:Bitmap = null;
		
		// Left
		private var _left:Bitmap = null;
		
		// Center
		private var _center:Bitmap = null;
		
		// Right
		private var _right:Bitmap = null;
		
		// BottomLeft
		private var _bottomLeft:Bitmap = null;
		
		// Bottom
		private var _bottom:Bitmap = null;
		
		// BottomRight
		private var _bottomRight:Bitmap = null;*/
		
		private var bmpAry:Vector.<Bitmap>;

		/**
		 * 初始构造九宫格
		 */
		private function initializeBlocks():void
		{
			var snapping:String = PixelSnapping.AUTO;
			var _topLeft:Bitmap = new Bitmap(null, snapping);
			addChild(_topLeft);
			
			var _top:Bitmap = new Bitmap(null, snapping);
			addChild(_top);
			
			var _topRight:Bitmap = new Bitmap(null, snapping);
			addChild(_topRight);
			
			var _left:Bitmap = new Bitmap(null, snapping);
			addChild(_left);
			
			var _center:Bitmap = new Bitmap(null, snapping);
			addChild(_center);
			
			var _right:Bitmap = new Bitmap(null, snapping);
			addChild(_right);
			
			var _bottomLeft:Bitmap = new Bitmap(null, snapping);
			addChild(_bottomLeft);
			
			var _bottom:Bitmap = new Bitmap(null, snapping);
			addChild(_bottom);
			
			var _bottomRight:Bitmap = new Bitmap(null, snapping);
			addChild(_bottomRight);
			
			bmpAry = new <Bitmap>[_topLeft,_top,_topRight,_left,_center,_right,_bottomLeft,_bottom,_bottomRight];
		}
		
		/**
		 * 跟据长宽重设格子
		 */
		private function resizeDraw():void
		{
			if(!source || !_scale9Grid)
				return;
			
			var rightWidth:int = oldWidth - _scale9Grid.width;
			var bottomHeight:int = oldHeight - _scale9Grid.height;
			var dh:int = (_height>0)?_height:oldHeight;
			var dw:int = (_width>0)?_width:oldWidth;
			
			var xAry:Vector.<int> = new <int>[0,_scale9Grid.x,(dw - rightWidth)];
			var widthAry:Vector.<int> = new <int>[_scale9Grid.x,(dw - _scale9Grid.x - rightWidth),rightWidth];
			var yAry:Vector.<int> = new <int>[0,_scale9Grid.y,(dh - bottomHeight)];
			var heightAry:Vector.<int> = new <int>[_scale9Grid.y,(dh - _scale9Grid.y - bottomHeight),bottomHeight];

			for (var j:int = 0; j < yAry.length; j++)
			{
				var ty:int = yAry[j];
				var th:int = heightAry[j];
				for (var i:int = 0; i < xAry.length; i++) 
				{
					var bmp:Bitmap = bmpAry[i + j*3] as Bitmap;
					var tx:int = xAry[i];
					var tw:int = widthAry[i];
					bmp.x = tx;
					bmp.y = ty;
					if(i==1)
						bmp.width = tw;
					if(j==1)
						bmp.height = th;
				}
			}
		}
		
		/**
		 * 重设九宫格位图数据
		 */
		protected function drawBmpd():void
		{
			if(!_source || !_scale9Grid)
				return;
			// 设置数据前先清数据引用计数
//			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			onExpired();
			
//			bmtLs = new Vector.<BmpRenderInfo>();
			
//			var key:String = getCacheKey();
			var pt:Point = new Point();
			var bitmapData:BitmapData;
			
			if(_source is BitmapData)
				bitmapData = _source as BitmapData;
			else if(_source is Bitmap)
				bitmapData = (_source as Bitmap).bitmapData;
			else if(_source is DisplayObject)
			{
				var rect:Rectangle = source.getBounds(_source);
				var m:Matrix = new Matrix();
				m.translate(-rect.x,-rect.y);
				bitmapData = new BitmapData(rect.width,rect.height,true,0);
				bitmapData.draw(_source as DisplayObject,m);
			}
			
/*			var brio:BmpRenderInfo = bmpMgr.getCache(key);
			if(brio)
				bitmapData = brio.useBitmapData();
			else
			{
				var rect:Rectangle = source.getBounds(source);
				
				var m:Matrix = new Matrix();
				m.translate(-rect.x,-rect.y);
				bitmapData = new BitmapData(rect.width,rect.height,true,0);
				bitmapData.draw(source,m);
				
				brio = new BmpRenderInfo();
				brio.useCount = brio.useCount + 1;
				brio.bitmapData = bitmapData;
				brio.key = key;
				bmpMgr.setBmpCache(brio);
			}
			bmtLs.push(brio);*/
			
//			var bmpAry:Vector.<Bitmap> = new <Bitmap>[_topLeft,_top,_topRight,_left,_center,_right,_bottomLeft,_bottom,_bottomRight];
			// 左中右格子宽,x坐标数据
			var xAry:Vector.<int> = new <int>[0,_scale9Grid.x,_scale9Grid.width];
			var widthAry:Vector.<int> = new <int>[_scale9Grid.x,_scale9Grid.width,(bitmapData.width - _scale9Grid.width)];
			// 上中下格子高,y坐标数据
			var yAry:Vector.<int> = new <int>[0,_scale9Grid.y,_scale9Grid.height];
			var heightAry:Vector.<int> = new <int>[_scale9Grid.y,_scale9Grid.height,(bitmapData.height - _scale9Grid.height)];

			
			var tlb:BmpRenderInfo;
			for (var j:int = 0; j < yAry.length; j++)
			{
				var ty:int = yAry[j];
				var th:int = heightAry[j];
				for (var i:int = 0; i < xAry.length; i++) 
				{
					var bmp:Bitmap = bmpAry[i + j*3] as Bitmap;
					var tx:int = xAry[i];
					var tw:int = widthAry[i];
//					var tKey:String = key + "|" + i + ":" + j;
//					tlb = bmpMgr.getCache(tKey);
					var bd:BitmapData;
					bd = new BitmapData(tw, th);
					bd.copyPixels(bitmapData, new Rectangle(tx, ty, tw, th), pt);
					
					
//					if(tlb)
//						bd = tlb.bitmapData;
//					else
//					{
//						if(tw<1)
//							tw = 1;
//						if(th<1)
//							th =1;
//						bd = new BitmapData(tw, th);
//						bd.copyPixels(bitmapData, new Rectangle(tx, ty, tw, th), pt);
//						tlb = new BmpRenderInfo();
//						tlb.bitmapData = bd;
//						tlb.key = tKey;
//						tlb.useCount = tlb.useCount + 1;
//						bmpMgr.setBmpCache(tlb);
//					}
					bmp.bitmapData = bd;
					bmp.x = tx;
					bmp.y = ty;
//					bmtLs.push(tlb);
				}
			}
			
			oldWidth = bitmapData.width;
			oldHeight = bitmapData.height;
			
//			StaticEnterFrame.addNextCall(resizeDraw);
			resizeDraw();
		}
		
		/**
		 * 未拉申时的宽度
		 */
		private var oldWidth:int;
		
		/**
		 * 未拉申时的高度
		 */
		private var oldHeight:int;
		
		private var _scale9Grid:Rectangle;
		
		override public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}
		
		override public function set scale9Grid(value:Rectangle):void
		{
			if(_scale9Grid == value)
				return;
			_scale9Grid = value;
			if(!source)
				return;
			_scale9Grid = correctGridRect(value);
			if(source && _scale9Grid)
				StaticEnterFrame.addNextCall(drawBmpd);
		}
		
		/**
		 * 把一个9格矩形校正
		 */
		private function correctGridRect(rect : Rectangle) : Rectangle
		{
			var minMargin : int = 1;
			if(rect.left < 1)
				rect.left = minMargin;
			if(rect.top < 1)
				rect.top = minMargin;
			if(rect.right > _source.width - minMargin)
				rect.right = _source.width - minMargin; 
			if(rect.bottom > _source.height - minMargin)
				rect.bottom = _source.height - minMargin; 
			return rect;
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
		 * 新建过期管理器
		 */
		protected function newExpireTimer():ExpireTimer
		{
			_expireTimer = new ExpireTimer(this,2*60*1000);
			_expireTimer.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			_expireTimer.addEventListener(ExpireTimer.RESET,onReset);
			return _expireTimer;
		}
		
		/**
		 * 重置
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			drawBmpd();
		}
		
		/**
		 * 当前显示的位图资源过期回收
		 * @param e
		 */
		protected function onExpired(e:Event=null):void
		{
//			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
//			if(bmtLs)
//			{
//				for each (var itm:BmpRenderInfo in bmtLs) 
//				bmpMgr.dropCache(itm.key);
//			}
			
			var item:Bitmap;
			for each (item in bmpAry) 
			{
				if(item.bitmapData)
					item.bitmapData.dispose();
			}
			
		}		
		
		//---------------------------------------------------
		// 其它get/set
		//---------------------------------------------------
		
		
		private var _source:Object;
		
		/**
		 * 源数据
		 */
		public function get source():Object
		{
			return _source;
		}
		
		/**
		 * 主键
		 
		protected var _sourceKey:String;*/
		
		/**
		 * @private
		 */
		public function set source(value:Object):void
		{
			if(_source == value)
				return;
			_source = value;
//			_sourceKey = getQualifiedClassName(value);
			if(source && _scale9Grid)
				StaticEnterFrame.addNextCall(drawBmpd);
		}
		
		/**
		 * 获取缓存主键
		 * @return 
		 
		protected function getCacheKey():String
		{
			return _sourceKey;
		}*/
		
		/**
		 * 当前显示的渲染信息
		 
		private var bmtLs:Vector.<BmpRenderInfo>;*/
		
		private var _width:Number;
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if(_width == value)
				return;
			_width = value;
			StaticEnterFrame.addNextCall(resizeDraw);
		}
		
		private var _height:Number;
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if(_height == value)
				return;
			_height = value;
			StaticEnterFrame.addNextCall(resizeDraw);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set scaleX(value:Number):void
		{
			width = oldWidth*1;
//			super.scaleX = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get scaleX():Number
		{
			if(oldWidth>0)
				return width/oldWidth;
			else
				return super.scaleX;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set scaleY(value:Number):void
		{
			height = oldHeight*value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get scaleY():Number
		{
			if(oldHeight>0)
				return height/oldHeight;
			else
				return super.scaleY;
		}
	}
}