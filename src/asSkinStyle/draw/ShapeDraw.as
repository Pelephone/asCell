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
	import asSkinStyle.i.IDrawBase;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	
	/** 组件重绘改变. **/
	[Event(name="component_draw", type="asSkinStyle.draw.ShapeDraw")]
	/**
	 * 基本给制对象
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class ShapeDraw extends Shape implements IDrawBase
	{
		/**
		 * 组件重绘
		 */
		public static const COMPONENT_DRAW:String = "component_draw";
		
		private var _bgColor:int = 0xFFFFFF;
		private var _bgColor2:int = -1;
		private var _bgRotaion:Number = Math.PI/2;
		
		private var _isNextDraw:Boolean = false;
		
		private var _border:int;
		private var _borderColor:int;
		
		private var _bgAlpha:Number = 1;
		
		protected var _width:Number = 20;
		protected var _height:Number = 20;
		
		public function ShapeDraw(uiName:String="draw")
		{
			super();
			reDraw();
		}
		
		/**
		 * 绘制对象
		 */
		protected function draw():void
		{
			dispatchEvent(new Event(COMPONENT_DRAW));
		}
		
		/**
		 * Marks the component to be redrawn on the next frame.
		 * 此方法相当于设了一个缓存，如set width和set height不是设一个重绘一次，而是两个参数都设好了再重绘
		 */
		protected function reDraw():void
		{
			if(!_isNextDraw){
				draw();
				return;
			}
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		/**
		 * Called one frame after invalidate is called.
		 */
		protected function onInvalidate(event:Event=null):void
		{
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			draw();
		}
		
		// getter/setter /////////
		
		public function get bgAlpha():Number
		{
			return this._bgAlpha;
		}
		
		public function set bgAlpha(value:Number):void
		{
			if(_bgAlpha == value)
				return;
			this._bgAlpha = value;
			reDraw();
		}
		
		override public function set width(value:Number):void
		{
			if(_width == value)
				return;
			_width = value;
			reDraw();
		}
		
		override public function get width():Number
		{
			return _width;// + border * 2;
		}
		
		override public function set height(value:Number):void
		{
			if(_height == value)
				return;
			_height = value;
			reDraw();
		}
		
		override public function get height():Number
		{
			return _height;// + border * 2;
		}
		
		/**
		 * @private
		 */
		public function get bgColor():int
		{
			return this._bgColor;
		}
		
		/**
		 * 背景颜色,-1表示不填色
		 */
		public function set bgColor(value:int):void
		{
			if(this._bgColor == value)
				return;
			this._bgColor = value;
			reDraw();
		}
		
		/**
		 *  渐变用色,-1表示不填色
		 */
		public function get bgColor2():int
		{
			return _bgColor2;
		}
		
		/**
		 * @private
		 */
		public function set bgColor2(value:int):void
		{
			if(this._bgColor2 == value)
				return;
			this._bgColor2 = value;
			reDraw();
		}
		
		/**
		 * 是否下帧重绘
		 */
		public function get isNextDraw():Boolean
		{
			return this._isNextDraw;
		}
		
		/**
		 * @private
		 */
		public function set isNextDraw(value:Boolean):void
		{
			if(this._isNextDraw == value)
				return;
			this._isNextDraw = value;
			reDraw();
		}

		/**
		 * 边线粗细
		 */
		public function get border():int
		{
			return _border;
		}

		/**
		 * @private
		 */
		public function set border(value:int):void
		{
			_border = value;
		}

		/**
		 * 边线颜色
		 */
		public function get borderColor():int
		{
			return _borderColor;
		}

		/**
		 * @private
		 */
		public function set borderColor(value:int):void
		{
			_borderColor = value;
		}
		
		/** 
		 * 渐变角度
		 */
		public function get bgRotaion():Number
		{
			return this._bgRotaion;
		}
		
		/**
		 * @private
		 */
		public function set bgRotaion(value:Number):void
		{
			if(this.bgRotaion == value)
				return;
			this._bgRotaion = value;
			reDraw();
		}
		
		private var _padding:int;
		
		public function set padding(value:int):void
		{
			_padding = value;
		}
		
		public function get padding():int
		{
			return _padding;
		}
	}
}