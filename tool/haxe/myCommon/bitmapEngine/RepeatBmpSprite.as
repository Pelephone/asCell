package bitmapEngine
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * 重复,平铺位图
	 * Pelephone
	 */
	public class RepeatBmpSprite extends BigBitmap
	{
		public function RepeatBmpSprite()
		{
			super();
		}
		
		private var _source:BitmapData;

		/**
		 * 用于重复显示的数据源
		 * @return 
		 */
		public function get source():BitmapData
		{
			return _source;
		}

		/**
		 * @private
		 */
		public function set source(value:BitmapData):void
		{
			if(_source == value)
				return;
			_source = value;
			if(value)
				invalidateDraw();
		}

		
		private var _type:int = 0;

		/**
		 * 重复方式；0,上下左右全屏平铺；1，横向重复；2，纵向重复；3，居中横向重复； -1 无重复
		 */
		public function get type():int
		{
			return _type;
		}

		/**
		 * @private
		 */
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			_type = value;
			invalidateDraw();
		}

		
		/**
		 * 平铺开始x坐标
		 */
		public var offsetX:int;
		
		/**
		 * 平铺开始y坐标
		 */
		public var offsetY:int;
		
		/**
		 * 横向间距
		 */
		public var spaceX:int = 0;
		/**
		 * 纵向间距
		 */
		public var spaceY:int = 0;
		
		public function set space(value:int):void 
		{
			spaceX = value;
			spaceY = value;
			
			invalidateDraw();
		}
		
		private var _width:Number = 10;

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			if(_width == value)
				return;
			_width = value;
			invalidateDraw();
		}

		
		private var _height:Number = 10;

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			if(_height == value)
				return;
			_height = value;
			invalidateDraw();
		}

		private var isDrawChange:Boolean = true;
		
		private function invalidateDraw():void
		{
			isDrawChange = true;
			addEventListener(Event.ENTER_FRAME,draw);
		}
		
		
		private function draw(e:Event=null):void
		{
			removeEventListener(Event.ENTER_FRAME,draw);
			if(!source || !isDrawChange)
				return;
			
			if(isDrawChange)
				isDrawChange = false;
			copyRepeatBmpd(source);
		}
		
		// 源位图长宽
		private var sliceWidth:Number = 10;
		private var sliceHeight:Number = 10;
		
		/**
		 * @inheritDoc
		 */
		override protected function getBmpByPt(px:Number, py:Number):Bitmap
		{
			var tx:int = Math.floor(px/bmpWidth);
			var ty:int = Math.floor(py/bmpWidth);
			var key:String = tx + "-" + ty;
			var bmp:Bitmap = getChildByName(key) as Bitmap;
			if(!bmp)
			{
				bmp = new Bitmap();
				bmp.name = key;
				bmp.x = tx*bmpWidth;
				bmp.y = ty*bmpHeight;
				
				var dWidth:int = bmpWidth;
				var dHeight:int = bmpHeight;
				if((bmp.x + bmpWidth)>width)
					dWidth = width - bmp.x;
				if((bmp.y + bmpHeight)>height)
					dHeight = height - bmp.y;
				
				var bmpd:BitmapData = new BitmapData(dWidth,dHeight,true,0x000000);
				bmp.bitmapData = bmpd;
				addChildAt(bmp,0);
			}
			return bmp;
		}
		
		/**
		 * 通过源位图数据复制重复显示
		 * @param src
		 */
		public function copyRepeatBmpd(src:BitmapData):void
		{
			dispose();
			sliceWidth = src.width + spaceX;
			sliceHeight = src.height + spaceY;
			//原切片大小
			var sliceRect:Rectangle = new Rectangle(0, 0, src.width, src.height);
			// 横纵向重复个数
			var wrn:int = Math.ceil(width / sliceWidth);
			var hrn:int = Math.ceil(height / sliceHeight);
			if(type == 1)
				hrn = 1;
			else if(type == 2)
				wrn = 1;
			
			var nPt:Point = new Point();
			for (var i:int = 0; i < wrn; i++) 
			{
				for (var j:int = 0; j < hrn; j++) 
				{
					nPt.x = i*sliceWidth + offsetX;
					nPt.y = j*sliceHeight + offsetY;
					copyPixels(src,sliceRect,nPt);
				}
			}
		}
		
		/**
		 * 通过源位图数据复制重复显示
		 * @param src
		 
		public function copyRepeatBmpd(src:BitmapData):void
		{
			copyRepeatBmpd2(src);
			return;
			// 单个bitmapdata的宽高最大像素值
			var maxSize:int = 2800;
			
			// 横纵向大格数量
			var wnum:int = Math.ceil(width/maxSize);
			var hnum:int = Math.ceil(height/maxSize);
			bmpWidth = width/wnum;
			bmpHeight = height/hnum;
			
			sliceWidth = src.width + spaceX;
			sliceHeight = src.height + spaceY;
			//原切片大小
			var sliceRect:Rectangle = new Rectangle(0, 0, src.width, src.height);
			
			// 横纵向重复个数
			var wrn:int = Math.ceil(width / sliceWidth);
			var hrn:int = Math.ceil(height / sliceHeight);
			if(type == 1)
				hrn = 1;
			else if(type == 2)
				wrn = 1;
			
			var bmp:Bitmap;
			var bmpd:BitmapData;
			var ls:Vector.<Bitmap>;
			var nPt:Point = new Point();
			for (var i:int = 0; i < wrn; i++) 
			{
				for (var j:int = 0; j < hrn; j++) 
				{
					var sx:Number = i*sliceWidth + offsetX;
					var sy:Number = j*sliceHeight + offsetY;
					ls = getBmpsBySlice(sx,sy);
					for each (bmp in ls) 
					{
						bmpd = bmp.bitmapData;
						nPt.x = sx - bmp.x;
						nPt.y = sy - bmp.y;
						
						bmpd.copyPixels(src, sliceRect, nPt);
//						drawRect((bmp.x + nPt.x),(bmp.y + nPt.y),sliceRect.width,sliceRect.height);
					}
				}
			}
//			scrollRect = new Rectangle(0,0,_width,_height);
		}
		
		// 单个位图大块的长宽
//		private var bmpWidth:Number = 10;
//		private var bmpHeight:Number = 10;
		
		/**
		 * 根据每一片像素的X,Y格信息获取对应的大位图块数据
		 
		private function getBmpBySliceXY(sx:int,sy:int):Bitmap
		{
			var bx:int = Math.floor(sx*sliceWidth/bmpWidth);
			var by:int = Math.floor(sy*sliceHeight/bmpHeight);
			var key:String = bx + "_" + by;
			var bmp:Bitmap = getChildByName(key) as Bitmap;
			var bpx:Number = bx*bmpWidth;
			var bpy:Number = by*bmpHeight;
			if(!bmp && bpx<_width && bpy<_height)
			{
				bmp = new Bitmap();
				bmp.x = bpx;
				bmp.y = bpy;
				bmp.name = key;
				var bmpd:BitmapData = new BitmapData(bmpWidth,bmpHeight,true,0x000000);
				bmp.bitmapData = bmpd;
				addChildAt(bmp,0);
			}
			return bmp;
		}
		
		/**
		 * 通过单块位图坐标计算出所覆盖的大切块范围
		 
		private function getBmpsBySlice(px:int,py:int):Vector.<Bitmap>
		{
			var ls:Vector.<Bitmap> = new Vector.<Bitmap>();
			var ptLs:Vector.<Number> = new <Number>[0,0,sliceWidth,0,sliceWidth,sliceHeight,0,sliceHeight];
			var pt:Point = new Point();
			for (var i:int = 0; i < ptLs.length; i = i + 2) 
			{
				pt.x = ptLs[i] + px;
				pt.y = ptLs[i+1] + py;
				var bmp:Bitmap = getBmpBySliceXY((pt.x/sliceWidth),(pt.y/sliceHeight));
				if(bmp)
					ls.push(bmp);
			}
			return ls;
		}
		
		/**
		private var sp:Sprite = new Sprite();
		
		 * 测试绘制已渲染的范围
		 
		private function drawRect(tx:int,ty:int,tw:int,th:int):void
		{
			addChild(sp);
			sp.graphics.lineStyle(1,0xFF0000);
			sp.graphics.drawRect(tx,ty,tw,th);
		}*/
	}
}