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
import flash.events.Event;
import flash.geom.Matrix;

/**
 * 画圆组件
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class CircleSprite extends SpriteDraw
{
	/**
	 * 构造画圆组件
	 */
	public function new()
	{
		super();
	}
	
	override public function draw():Void
	{
		drawCircle();
		super.draw();
	}

	/**
	 * 画圆
	 */
	private function drawCircle():Void
	{
		#if flash
		graphics.clear();
		#end
		var drawInfo:CircleSprite = this;
		if(drawInfo.bgAlpha>0)
		{
			graphics.beginFill(drawInfo.bgColor,drawInfo.bgAlpha);
			
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2>=0)
			{
				var matr:Matrix = new Matrix();
				matr.createGradientBox(drawInfo.width, drawInfo.height, drawInfo.bgRotaion);
				graphics.beginGradientFill(GradientType.LINEAR,[drawInfo.bgColor,drawInfo.bgColor2],
					[drawInfo.bgAlpha,drawInfo.bgAlpha],[0x00, 0xFF],matr);
			}
			
			if(drawInfo.borderColor>0)
				graphics.lineStyle(drawInfo.border,drawInfo.borderColor,1);
			else
				graphics.lineStyle(0,0,0);
			
			if(drawInfo.width==drawInfo.height)
				graphics.drawCircle(drawInfo.width*0.5,drawInfo.height*0.5,drawInfo.width*0.5);
			else
				graphics.drawEllipse(drawInfo.width*0.5,drawInfo.height*0.5,drawInfo.width,drawInfo.height);
			
			graphics.endFill();
		}
	}
	
	/**
	 * 半径
	 */
	public var radius(get, set):Float;
	/**
	 * 设置圆半径
	 */
	function set_radius(value:Float):Float
	{
		width = value;
		height = value;
		return width;
	}
	
	function get_radius():Float
	{
		if(width == height)
			return width;
		else
			return 0;
	}
}