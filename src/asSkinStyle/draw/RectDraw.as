/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package asSkinStyle.draw
{
	import asSkinStyle.i.IRectDraw;

	/**
	 * 基本绘图组件
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class RectDraw extends ShapeDraw implements IRectDraw
	{
		public function RectDraw()
		{
			super();
		}
		
		/**
		 * 基本绘制函数
		 */
		override protected function draw():void
		{
			graphics.clear();
			DrawTool.drawRect(graphics,this);
			super.draw();
			
//			var pd:int = 1;
//			scale9Grid = new Rectangle((width*0.5-pd),(height*0.5-pd),pd*2,pd*2);
		}
		
		// getter/setter /////////

		/**
		 * 上边框厚度
		 */
		public function get borderTop():int
		{
			return this._borderTop;
		}
		
		/**
		 * @private
		 */
		public function set borderTop(value:int):void
		{
			if(this._borderTop == value) return;
			this._borderTop = value;
			reDraw();
		}
		
		private var _borderRight:int = 0;
		
		/**
		 * 右边框厚度
		 */
		public function get borderRight():int
		{
			return this._borderRight;
		}
		
		/**
		 * @private
		 */
		public function set borderRight(value:int):void
		{
			if(this._borderRight == value) return;
			this._borderRight = value;
			reDraw();
		}
		
		private var _borderLeft:int = 0;
		
		/**
		 * 左边框厚度
		 */
		public function get borderLeft():int
		{
			return this._borderLeft;
		}
		
		/**
		 * @private
		 */
		public function set borderLeft(value:int):void
		{
			if(this._borderLeft == value) return;
			this._borderLeft = value;
			reDraw();
		}
		
		private var _borderBottom:int = 0;
		
		/**
		 * 下边框厚度
		 */
		public function get borderBottom():int
		{
			return this._borderBottom;
		}
		
		/**
		 * @private
		 */
		public function set borderBottom(value:int):void
		{
			if(this._borderBottom == value) return;
			this._borderBottom = value;
			reDraw();
		}
		
		private var _borderTopColor:int = 0;
		
		/**
		 * 上边框颜色
		 */
		public function get borderTopColor():int
		{
			return this._borderTopColor;
		}
		
		/**
		 * @private
		 */
		public function set borderTopColor(value:int):void
		{
			if(this._borderTopColor == value) return;
			this._borderTopColor = value;
			reDraw();
		}
		
		private var _borderLeftColor:int = 0;
		
		/**
		 * 左边框颜色
		 */
		public function get borderLeftColor():int
		{
			return this._borderLeftColor;
		}
		
		/**
		 * @private
		 */
		public function set borderLeftColor(value:int):void
		{
			if(this._borderLeftColor == value) return;
			_borderLeftColor = value;
			reDraw();
		}
		
		private var _borderRightColor:int = 0;
		
		/**
		 * 右边框颜色
		 */
		public function get borderRightColor():int
		{
			return this._borderRightColor;
		}
		
		/**
		 * @private
		 */
		public function set borderRightColor(value:int):void
		{
			if(this._borderRightColor == value) return;
			this._borderRightColor = value;
			reDraw();
		}
		
		private var _borderBottomColor:int = 0;
		
		/**
		 * 下边框颜色
		 */
		public function get borderBottomColor():int
		{
			return this._borderBottomColor;
		}
		
		/**
		 * @private
		 */
		public function set borderBottomColor(value:int):void
		{
			if(this._borderBottomColor == value) return;
			this._borderBottomColor = value;
			reDraw();
		}
		
		private var _ellipse:int = 0;
		
		/** 
		 * 圆角,border不为0是有效
		 */
		public function get ellipse():int
		{
			return this._ellipse;
		}
		
		/**
		 * @private
		 */
		public function set ellipse(value:int):void
		{
			if(this._ellipse == value) return;
			this._ellipse = value;
			reDraw();
		}
		
		private var _borderTop:int = 0;
		
		override public function set border(value:int):void
		{
			if(border == value)
				return;
			super.border = value;
			_borderTop = value;
			_borderBottom = value;
			_borderLeft = value;
			_borderRight = value;
			reDraw();
		}
		
		override public function set borderColor(value:int):void
		{
			_borderTopColor = value;
			_borderBottomColor = value;
			_borderLeftColor = value;
			_borderRightColor = value;
			reDraw();
		}
		
		override public function get borderColor():int
		{
			return _borderTopColor;
		}
		
		/**
		 * 快捷输入左上右下外边框
		 * @param args
		 */	
		public function setBorder(...args):void
		{
			var i:int=0;
			borderLeft = (args.length>i)?args[i++]:0;
			borderTop = (args.length>i)?args[i++]:borderLeft;
			borderRight = (args.length>i)?args[i++]:borderTop;
			borderBottom = (args.length>i)?args[i++]:borderRight;
		}
		
		/**
		 * 快捷输入左上右下外边框颜色
		 * @param args
		 */	
		public function setBorderColor(...args):void
		{
			var i:int=0;
			borderLeftColor = (args.length>i)?args[i++]:0;
			borderTopColor = (args.length>i)?args[i++]:borderLeftColor;
			borderRightColor = (args.length>i)?args[i++]:borderTopColor;
			borderBottomColor = (args.length>i)?args[i++]:borderRightColor;
		}
		
		//---------------------------------------------------
		// padding
		//---------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set padding(value:int):void
		{
			if(padding == value)
				return;
			super.padding = value;
			paddingTop = value;
			paddingBottom = value;
			paddingLeft = value;
			paddingRight = value;
			reDraw();
		}
		
		private var _paddingBottom:int;
		
		public function set paddingBottom(value:int):void
		{
			if(value == _paddingBottom)
				return;
			_paddingBottom = value;
			reDraw();
		}
		
		public function get paddingBottom():int
		{
			return _paddingBottom;
		}
		
		private var _paddingLeft:int;
		
		public function set paddingLeft(value:int):void
		{
			if(value == _paddingLeft)
				return;
			_paddingLeft = value;
			reDraw();
		}
		
		public function get paddingLeft():int
		{
			return _paddingLeft;
		}
		
		private var _paddingRight:int;
		
		public function set paddingRight(value:int):void
		{
			if(value == _paddingRight)
				return;
			_paddingRight = value;
			reDraw();
		}
		
		public function get paddingRight():int
		{
			return _paddingRight;
		}
		
		private var _paddingTop:int;
		
		public function set paddingTop(value:int):void
		{
			if(value == _paddingTop)
				return;
			_paddingTop = value;
			reDraw();
		}
		
		public function get paddingTop():int
		{
			return _paddingTop;
		}
		
		/**
		 * 快捷输入左上右下外边距
		 * @param args
		 */
		public function setPadding(...args):void
		{
			var i:int=0;
			paddingLeft = (args.length>i)?args[i++]:0;
			paddingTop = (args.length>i)?args[i++]:paddingLeft;
			paddingRight = (args.length>i)?args[i++]:paddingTop;
			paddingBottom = (args.length>i)?args[i++]:paddingRight;
		}
		
		private var _inBgColor:int = -1;
		
		public function set inBgColor(value:int):void
		{
			if(value == _inBgColor)
				return;
			_inBgColor = value;
			reDraw();
		}
		
		public function get inBgColor():int
		{
			return _inBgColor;
		}
		
		private var _inEllipse:int;
		
		public function set inEllipse(value:int):void
		{
			if(value == _inEllipse)
				return;
			_inEllipse = value;
			reDraw();
		}
		
		public function get inEllipse():int
		{
			return _inEllipse;
		}
		
		/**
		 * @inheritDoc
		 
		override public function get width():Number
		{
			return _width + borderLeft + borderRight;
		}*/
	}
}