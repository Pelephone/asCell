package asSkinStyle.draw
{
	import asSkinStyle.i.IRectDraw;
	
	import bitmapEngine.Scale9GridBitmap;
	
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * 绘制矩形，转成位图9切片
	 * @author Pelephone
	 */
	public class RectDrawBmp extends Scale9GridBitmap implements IRectDraw
	{
		/**
		 * 绘制元件
		 */
		private var rectDraw:RectDraw;
		
		public function RectDrawBmp()
		{
			rectDraw = new RectDraw();
			rectDraw.addEventListener(ShapeDraw.COMPONENT_DRAW,onDraw);
			super(rectDraw);
		}
		
		private function onDraw(e:Event):void
		{
			var rx:int = ((paddingLeft>ellipse)?paddingLeft:ellipse) + borderLeft + 1;
			var ry:int = ((paddingTop>ellipse)?paddingTop:ellipse) + borderTop + 1;
			var s1:int = ((paddingRight>ellipse)?paddingRight:ellipse) + borderRight + 1;
			var s2:int = ((paddingBottom>ellipse)?paddingBottom:ellipse) + borderBottom + 1;
			var rw:int = rectDraw.width - rx - s1;
			var rh:int = rectDraw.height - ry - s2;
			scale9Grid = new Rectangle(rx,ry,rw,rh);
//			StaticEnterFrame.addNextCall(drawBmpd);
		}
		
		/**
		 * @inheritDoc
		 
		override protected function drawBmpd():void
		{
			super.drawBmpd();
			
			trace(idx++,myId,scale9Grid);
		}*/
		
		/**
		 * @inheritDoc
		 
		override protected function getCacheKey():String
		{
			var ary:Array = [border,borderColor,bgColor,borderRight,borderLeft
				,borderTop,borderBottom,borderTopColor,bgAlpha,borderLeftColor,borderRightColor,bgColor2
				,borderBottomColor,paddingTop,padding,paddingBottom,paddingRight,paddingLeft,inBgColor
				,bgRotaion,ellipse,inEllipse];
			return "rect#" + ary.join("#");
		}*/
		
		//---------------------------------------------------
		// get//set
		//---------------------------------------------------
		
		/**
		 * @inheritDoc
		 
		override public function set width(value:Number):void
		{
			rectDraw.width = value;
		}*/
		
		/**
		 * @inheritDoc
		 
		override public function set height(value:Number):void
		{
			rectDraw.height = value;
		}*/
		
		public function set bgAlpha(value:Number):void
		{
			rectDraw.bgAlpha = value;
		}
		
		public function get bgAlpha():Number
		{
			return rectDraw.bgAlpha;
		}
		
		public function get bgColor():int
		{
			return rectDraw.bgColor;
		}
		
		public function set bgColor(value:int):void
		{
			rectDraw.bgColor = value;
		}
		
		public function get bgColor2():int
		{
			return rectDraw.bgColor2;
		}
		
		public function set bgColor2(value:int):void
		{
			rectDraw.bgColor2 = value;
		}
		
		public function get bgRotaion():Number
		{
			return rectDraw.bgRotaion;
		}
		
		public function set bgRotaion(value:Number):void
		{
			rectDraw.bgRotaion = value;
		}
		
		public function get border():int
		{
			return rectDraw.border;
		}
		
		public function set border(value:int):void
		{
			rectDraw.border = value;
		}
		
		public function get borderColor():int
		{
			return rectDraw.borderColor;
		}
		
		public function set borderColor(value:int):void
		{
			rectDraw.borderColor = value;
		}
		
		public function set padding(value:int):void
		{
			rectDraw.padding = value;
		}
		
		public function get padding():int
		{
			return rectDraw.padding;
		}
		
		public function get borderBottom():int
		{
			return rectDraw.borderBottom;
		}
		
		public function set borderBottom(value:int):void
		{
			rectDraw.borderBottom = value;
		}
		
		public function get borderBottomColor():int
		{
			return rectDraw.borderBottomColor;
		}
		
		public function set borderBottomColor(value:int):void
		{
			rectDraw.borderBottomColor = value;
		}
		
		public function get borderLeft():int
		{
			return rectDraw.borderLeft;
		}
		
		public function set borderLeft(value:int):void
		{
			rectDraw.borderLeft = value;
		}
		
		public function get borderLeftColor():int
		{
			return rectDraw.borderLeftColor;
		}
		
		public function set borderLeftColor(value:int):void
		{
			rectDraw.borderLeftColor = value;
		}
		
		public function get borderRight():int
		{
			return rectDraw.borderRight;
		}
		
		public function set borderRight(value:int):void
		{
			rectDraw.borderRight = value;
		}
		
		public function get borderRightColor():int
		{
			return rectDraw.borderRightColor;
		}
		
		public function set borderRightColor(value:int):void
		{
			rectDraw.borderRightColor = value;
		}
		
		public function get borderTop():int
		{
			return rectDraw.borderTop;
		}
		
		public function set borderTop(value:int):void
		{
			rectDraw.borderTop = value;
		}
		
		public function get borderTopColor():int
		{
			return rectDraw.borderTopColor;
		}
		
		public function set borderTopColor(value:int):void
		{
			rectDraw.borderTopColor = value;
		}
		
		public function get ellipse():int
		{
			return rectDraw.ellipse;
		}
		
		public function set ellipse(value:int):void
		{
			rectDraw.ellipse = value;
		}
		
		public function set inBgColor(value:int):void
		{
			rectDraw.inBgColor = value;
		}
		
		public function get inBgColor():int
		{
			return rectDraw.inBgColor;
		}
		
		public function set inEllipse(value:int):void
		{
			rectDraw.inEllipse = value;
		}
		
		public function get inEllipse():int
		{
			return rectDraw.inEllipse;
		}
		
		public function set paddingBottom(value:int):void
		{
			rectDraw.paddingBottom = value;
		}
		
		public function get paddingBottom():int
		{
			return rectDraw.paddingBottom;
		}
		
		public function set paddingLeft(value:int):void
		{
			rectDraw.paddingLeft = value;
		}
		
		public function get paddingLeft():int
		{
			return rectDraw.paddingLeft;
		}
		
		public function set paddingRight(value:int):void
		{
			rectDraw.paddingRight = value;
		}
		
		public function get paddingRight():int
		{
			return rectDraw.paddingRight;
		}
		
		public function set paddingTop(value:int):void
		{
			rectDraw.paddingTop = value;
		}
		
		public function get paddingTop():int
		{
			return rectDraw.paddingTop;
		}
	}
}