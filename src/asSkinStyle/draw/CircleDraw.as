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
	
	/**
	 * 画圆组件
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class CircleDraw extends ShapeDraw implements IDrawBase
	{
		/**
		 * 构造画圆组件
		 */
		public function CircleDraw(uiName:String="draw")
		{
			super(uiName);
		}
		
		override protected function draw():void
		{
			graphics.clear();
			DrawTool.drawCircle(graphics,this);
			super.draw();
		}
		
		/**
		 * 设置圆半径
		 */
		public function set radius(value:Number):void
		{
			width = height = value;
		}
		
		public function get radius():Number
		{
			if(width==height)
				return width;
			else
				return NaN;
		}
	}
}