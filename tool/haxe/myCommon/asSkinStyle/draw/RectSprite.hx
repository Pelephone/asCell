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
package asSkinStyle.draw;

import flash.display.GradientType;
import flash.geom.Matrix;

/**
 * 基本绘图组件
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class RectSprite extends SpriteDraw
{
	public function new()
	{
		super();
	}
	
	/**
	 * 基本绘制函数
	 */
	override public function draw():Void
	{
		drawRect();
		//DrawTool.drawRect(graphics,this);
		super.draw();
	}
	
	
		/**
	 * 绘制矩形
	 * @param drawInfo 矩形数据
	 * @param graphics 图形 
	 */
	private function drawRect():Void
	{
		graphics.clear();
		
		var drawInfo:RectSprite = this;
		if(drawInfo.bgAlpha > 0)
		{
			graphics.beginFill(drawInfo.bgColor, drawInfo.bgAlpha);
			
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2>=0)
			{
				var matr:Matrix = new Matrix();
				matr.createGradientBox(drawInfo.width, drawInfo.height, drawInfo.bgRotaion);
				graphics.beginGradientFill(GradientType.LINEAR,[drawInfo.bgColor,drawInfo.bgColor2],
					[drawInfo.bgAlpha, drawInfo.bgAlpha], [0x00, 0xFF], matr);
			}
			
			var isSameBorder:Bool = (drawInfo.borderTop == drawInfo.borderBottom && drawInfo.borderBottom == drawInfo.borderLeft
				&& drawInfo.borderLeft == drawInfo.borderRight && drawInfo.borderTopColor == drawInfo.borderBottomColor
				&& drawInfo.borderBottomColor == drawInfo.borderLeftColor && drawInfo.borderLeftColor == drawInfo.borderRightColor);
			
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2<0)
			{
				graphics.beginFill(drawInfo.bgColor,drawInfo.bgAlpha);
				graphics.lineStyle(0,0,0);
				
				if(drawInfo.ellipse<=0)
					graphics.drawRect(0,0,drawInfo.width,drawInfo.height);
				else
					graphics.drawRoundRect(0,0,drawInfo.width,drawInfo.height,drawInfo.ellipse,drawInfo.ellipse);
				graphics.endFill();
			}
			
			if(drawInfo.inBgColor>=0)
			{
				graphics.beginFill(drawInfo.inBgColor, drawInfo.bgAlpha);
				var pw:Float = drawInfo.width - drawInfo.paddingLeft - drawInfo.paddingRight;
				var ph:Float = drawInfo.height - drawInfo.paddingTop - drawInfo.paddingBottom;
				graphics.lineStyle(0,0,0);
				if(drawInfo.inEllipse<=0)
					graphics.drawRect(drawInfo.paddingLeft,drawInfo.paddingTop,pw,ph);
				else
					graphics.drawRoundRect(drawInfo.paddingLeft,drawInfo.paddingTop,pw,ph
						,drawInfo.inEllipse,drawInfo.inEllipse);
				graphics.endFill();
			}
			
			if(isSameBorder)
			{
				if(drawInfo.border>0 && drawInfo.borderColor>0)
				{
					graphics.lineStyle(drawInfo.border,drawInfo.borderColor,1);
					if(drawInfo.ellipse<=0)
						graphics.drawRect(0,0,drawInfo.width,drawInfo.height);
					else
						graphics.drawRoundRect(0,0,drawInfo.width,drawInfo.height,drawInfo.ellipse,drawInfo.ellipse);
				}
			}
			else
			{
				var linAlpha:Int = 0;
				if(drawInfo.borderTop>0)
				{
					linAlpha = (drawInfo.borderTopColor>0)?1:0;
					graphics.moveTo(0,0);
					graphics.lineStyle(drawInfo.borderTop,drawInfo.borderTopColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),0);
				}
				if(drawInfo.borderLeft>0)
				{
					linAlpha = (drawInfo.borderLeftColor>0)?1:0;
					graphics.moveTo(0,0);
					graphics.lineStyle(drawInfo.borderLeft,drawInfo.borderLeftColor,linAlpha);
					graphics.lineTo(0,(drawInfo.height));
				}
				if(drawInfo.borderRight>0)
				{
					linAlpha = (drawInfo.borderRightColor>0)?1:0;
					graphics.moveTo((0+drawInfo.width),0);
					graphics.lineStyle(drawInfo.borderRight,drawInfo.borderRightColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),(0+drawInfo.height));
				}
				if(drawInfo.borderBottom>0)
				{
					linAlpha = (drawInfo.borderBottomColor>0)?1:0;
					graphics.moveTo(0,(0+drawInfo.height));
					graphics.lineStyle(drawInfo.borderBottom,drawInfo.borderBottomColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),(0+drawInfo.height));
				}
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
	//----------------------------------
	// getter/setter /////////
	//----------------------------------

	public var borderTop(get,set):Int;
	var _borderTop:Int = 0;
	/**
	 * 上边框厚度
	 */
	function get_borderTop():Int
	{
		return this._borderTop;
	}
	
	/**
	 * @private
	 */
	function set_borderTop(value:Int):Int
	{
		if (this._borderTop == value)
		return _borderTop;
		this._borderTop = value;
		reDraw();
		return _borderTop;
	}
	
	public var borderRight(get,set):Int;
	var _borderRight:Int = 0;
	
	/**
	 * 右边框厚度
	 */
	function get_borderRight():Int
	{
		return this._borderRight;
	}
	
	/**
	 * @private
	 */
	function set_borderRight(value:Int):Int
	{
		if (this._borderRight == value)
		return _borderRight;
		this._borderRight = value;
		reDraw();
		return _borderRight;
	}
	
	public var borderLeft(get,set):Int;
	var _borderLeft:Int = 0;
	
	/**
	 * 左边框厚度
	 */
	function get_borderLeft():Int
	{
		return this._borderLeft;
	}
	
	/**
	 * @private
	 */
	function set_borderLeft(value:Int):Int
	{
		if (this._borderLeft == value)
		return _borderLeft;
		this._borderLeft = value;
		reDraw();
		return _borderLeft;
	}
	
	public var borderBottom(get,set):Int;
	var _borderBottom:Int = 0;
	
	/**
	 * 下边框厚度
	 */
	function get_borderBottom():Int
	{
		return this._borderBottom;
	}
	
	/**
	 * @private
	 */
	function set_borderBottom(value:Int):Int
	{
		if (this._borderBottom == value)
		return _borderBottom;
		this._borderBottom = value;
		reDraw();
		return _borderBottom;
	}
	
	public var borderTopColor(get,set):Int;
	var _borderTopColor:Int = 0;
	
	/**
	 * 上边框颜色
	 */
	function get_borderTopColor():Int
	{
		return this._borderTopColor;
	}
	
	/**
	 * @private
	 */
	function set_borderTopColor(value:Int):Int
	{
		if (this._borderTopColor == value)
		return _borderTopColor;
		this._borderTopColor = value;
		reDraw();
		return _borderTopColor;
	}
	
	public var borderLeftColor(get,set):Int;
	var _borderLeftColor:Int = 0;
	
	/**
	 * 左边框颜色
	 */
	function get_borderLeftColor():Int
	{
		return this._borderLeftColor;
	}
	
	/**
	 * @private
	 */
	function set_borderLeftColor(value:Int):Int
	{
		if (this._borderLeftColor == value)
		return _borderLeftColor;
		_borderLeftColor = value;
		reDraw();
		return _borderLeftColor;
	}
	
	public var borderRightColor(get,set):Int;
	private var _borderRightColor:Int = 0;
	
	/**
	 * 右边框颜色
	 */
	function get_borderRightColor():Int
	{
		return this._borderRightColor;
	}
	
	/**
	 * @private
	 */
	function set_borderRightColor(value:Int):Int
	{
		if (this._borderRightColor == value)
		return _borderRightColor;
		this._borderRightColor = value;
		reDraw();
		return _borderRightColor;
	}
	
	public var borderBottomColor(get,set):Int;
	var _borderBottomColor:Int = 0;
	
	/**
	 * 下边框颜色
	 */
	function get_borderBottomColor():Int
	{
		return this._borderBottomColor;
	}
	
	/**
	 * @private
	 */
	function set_borderBottomColor(value:Int):Int
	{
		if (this._borderBottomColor == value)
		return _borderBottomColor;
		this._borderBottomColor = value;
		reDraw();
		return _borderBottomColor;
	}
	
	public var ellipse(get,set):Int;
	var _ellipse:Int = 0;
	
	/** 
	 * 圆角,border不为0是有效
	 */
	function get_ellipse():Int
	{
		return this._ellipse;
	}
	
	/**
	 * @private
	 */
	function set_ellipse(value:Int):Int
	{
		if (this._ellipse == value)
		return _ellipse;
		this._ellipse = value;
		reDraw();
		return _ellipse;
	}
	
	override function set_border(value:Int):Int
	{
		super.border = value;
		_borderTop = value;
		_borderBottom = value;
		_borderLeft = value;
		_borderRight = value;
		reDraw();
		return _borderTop;
	}
	
	override function set_borderColor(value:Int):Int
	{
		_borderTopColor = value;
		_borderBottomColor = value;
		_borderLeftColor = value;
		_borderRightColor = value;
		reDraw();
		return _borderTopColor;
	}
	
	override function get_borderColor():Int
	{
		return _borderTopColor;
	}
	
	/**
	 * 快捷输入左上右下外边框
	 * @param args
	 */	
	function setBorder(args:Array<Int>):Void
	{
		var i:Int=0;
		borderLeft = (args.length>i)?args[i++]:0;
		borderTop = (args.length>i)?args[i++]:borderLeft;
		borderRight = (args.length>i)?args[i++]:borderTop;
		borderBottom = (args.length>i)?args[i++]:borderRight;
	}
	
	/**
	 * 快捷输入左上右下外边框颜色
	 * @param args
	 */	
	function setBorderColor(args:Array<Int>):Void
	{
		var i:Int=0;
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
	override function set_padding(value:Int):Int
	{
		if(padding == value)
		return _padding;
		super.padding = value;
		paddingTop = value;
		paddingBottom = value;
		paddingLeft = value;
		paddingRight = value;
		reDraw();
		return _padding;
	}
	
	public var paddingBottom(get,set):Int;
	private var _paddingBottom:Int = 0;
	
	function set_paddingBottom(value:Int):Int
	{
		if(value == _paddingBottom)
		return _paddingBottom;
		_paddingBottom = value;
		reDraw();
		return _paddingBottom;
	}
	
	function get_paddingBottom():Int
	{
		return _paddingBottom;
	}
	
	public var paddingLeft(get,set):Int;
	var _paddingLeft:Int = 0;
	
	function set_paddingLeft(value:Int):Int
	{
		if(value == _paddingLeft)
		return _paddingLeft;
		_paddingLeft = value;
		reDraw();
		return _paddingLeft;
	}
	
	function get_paddingLeft():Int
	{
		return _paddingLeft;
	}
	
	public var paddingRight(get,set):Int;
	var _paddingRight:Int = 0;
	
	function set_paddingRight(value:Int):Int
	{
		if(value == _paddingRight)
		return _paddingRight;
		_paddingRight = value;
		reDraw();
		return _paddingRight;
	}
	
	function get_paddingRight():Int
	{
		return _paddingRight;
	}
	
	public var paddingTop(get,set):Int;
	var _paddingTop:Int = 0;
	
	function set_paddingTop(value:Int):Int
	{
		if(value == _paddingTop)
		return _paddingTop;
		_paddingTop = value;
		reDraw();
		return _paddingTop;
	}
	
	function get_paddingTop():Int
	{
		return _paddingTop;
	}
	
	/**
	 * 快捷输入左上右下外边距
	 * @param args
	 */
	public function setPadding(args:Array<Int>):Void
	{
		var i:Int=0;
		paddingLeft = (args.length>i)?args[i++]:0;
		paddingTop = (args.length>i)?args[i++]:paddingLeft;
		paddingRight = (args.length>i)?args[i++]:paddingTop;
		paddingBottom = (args.length>i)?args[i++]:paddingRight;
	}
	
	public var inBgColor(get,set):Int;
	var _inBgColor:Int = -1;
	
	function set_inBgColor(value:Int):Int
	{
		if(value == _inBgColor)
		return _inBgColor;
		_inBgColor = value;
		reDraw();
		return _inBgColor;
	}
	
	function get_inBgColor():Int
	{
		return _inBgColor;
	}
	
	public var inEllipse(get,set):Int;
	private var _inEllipse:Int = 0;
	
	function set_inEllipse(value:Int):Int
	{
		if(value == _inEllipse)
		return _inEllipse;
		_inEllipse = value;
		reDraw();
		return _inEllipse;
	}
	
	function get_inEllipse():Int
	{
		return _inEllipse;
	}
	
	/**
	 * @inheritDoc
	 
	override function get_width():Number
	{
		return _width + borderLeft + borderRight;
	}*/
}