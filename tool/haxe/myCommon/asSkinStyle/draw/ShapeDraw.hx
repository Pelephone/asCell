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

import flash.display.Shape;
import flash.events.Event;
import sparrowGui.SparrowUtil;



/** 组件重绘改变. **/
//[Event(name="component_draw", type="asSkinStyle.draw.ShapeDraw")]
/**
 * 基本给制对象
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class ShapeDraw extends Shape
{
	/**
	 * 组件重绘
	 */
	inline public static var COMPONENT_DRAW:String = "component_draw";
	
	public function new()
	{
		super();
		bgRotaion = Math.PI / 2;
		reDraw();
	}
	
	/**
	 * 绘制对象
	 */
	function draw()
	{
		dispatchEvent(new Event(COMPONENT_DRAW));
	}
	
	//public var isNextDraw:Bool = true;
	/**
	 * Marks the component to be redrawn on the next frame.
	 * 此方法相当于设了一个缓存，如set_width和set_height不是设一个重绘一次，而是两个参数都设好了再重绘
	 */
	public function reDraw():Void
	{
		// 测试发现用下帧渲染的方式比直接渲染慢三倍，但是不用下帧渲染的话，html5会发生莫名bug……
		#if html5
		SparrowUtil.addNextCall(draw, false);
		#else
		draw();
		#end
	}
	
	// getter/setter /////////
	private var _width:Float = 20;
	
	@:setter(width)
	#if flash
	private function set_width(value:Float):Void
	#else
	override public function set_width(value:Float):Float
	#end
	{
		if (_width == value)
		#if !flash
		return _width;
		#else
		return;
		#end
		
		_width = value;
		reDraw();
		
		#if !flash
		return _width;
		#end
	}
	@:getter(width)
	#if flash
	private function get_width():Float
	#else
	override public function get_width():Float
	#end
	{
		return _width;// + border * 2;
	}
	
	private var _height:Float = 20;
	
	@:setter(height)
	#if flash
	private function set_height(value:Float):Void
	#else
	override public function set_height(value:Float):Float
	#end
	{
		if(_height == value)
		#if !flash
		return _height;
		#else
		return;
		#end
		
		_height = value;
		reDraw();
		#if !flash
		return _height;
		#end
	}
	
	@:getter(height)
	#if flash
	private function get_height():Float
	#else
	override public function get_height():Float
	#end
	{
		return _height;// + border * 2;
	}
	
	
	public var bgAlpha(get,set):Float;
	
	var _bgAlpha:Float = 1;
	function get_bgAlpha():Float
	{
		return _bgAlpha;
	}
	
	function set_bgAlpha(value:Float):Float
	{
		if(_bgAlpha == value)
		return _bgAlpha;
		
		_bgAlpha = value;
		reDraw();
		return _bgAlpha;
	}

	public var bgColor(get, set):Int;
	var _bgColor:Int = 0xFFFFFF;
	/**
	 * @private
	 */
	function get_bgColor():Int
	{
		return _bgColor;
	}
	
	/**
	 * 背景颜色,-1表示不填色
	 */
	function set_bgColor(value:Int):Int
	{
		if(_bgColor == value)
			return _bgColor;
		_bgColor = value;
		reDraw();
		return _bgColor;
	}
	
	
	public var bgColor2(get, set):Int;
	var _bgColor2:Int = -1;
	/**
	 *  渐变用色,-1表示不填色
	 */
	function get_bgColor2():Int
	{
		return _bgColor2;
	}
	
	/**
	 * @private
	 */
	function set_bgColor2(value:Int):Int
	{
		if(_bgColor2 == value)
		return _bgColor2;
		
		_bgColor2 = value;
		reDraw();
		return _bgColor2;
	}

	public var border(get, set):Int;
	var _border:Int = 0;
	/**
	 * 边线粗细
	 */
	function get_border():Int
	{
		return _border;
	}

	/**
	 * @private
	 */
	function set_border(value:Int):Int
	{
		if (border == value)
		return _border;
		
		_border = value;
		reDraw();
		return _border;
	}

	
	public var borderColor(get, set):Int;
	var _borderColor:Int = 0;
	/**
	 * 边线颜色
	 */
	function get_borderColor():Int
	{
		return _borderColor;
	}

	/**
	 * @private
	 */
	function set_borderColor(value:Int):Int
	{
		if (borderColor == value)
		return _borderColor;
		
		_borderColor = value;
		reDraw();
		return _borderColor;
	}
	
	public var bgRotaion(get, set):Float;
	var _bgRotaion:Float = 1;
	/** 
	 * 渐变角度
	 */
	function get_bgRotaion():Float
	{
		return _bgRotaion;
	}
	
	/**
	 * @private
	 */
	function set_bgRotaion(value:Float):Float
	{
		if(_bgRotaion == value)
		return _bgRotaion;
		
		this._bgRotaion = value;
		reDraw();
		return _bgRotaion;
	}
	
	public var padding(get, set):Int;
	var _padding:Int = 0;
	
	function set_padding(value:Int):Int
	{
		if (_padding == value)
		return _padding;
		
		_padding = value;
		reDraw();
		return _padding;
	}
	
	function get_padding():Int
	{
		return _padding;
	}
}