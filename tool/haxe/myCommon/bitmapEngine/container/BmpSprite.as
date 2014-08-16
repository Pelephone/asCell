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
package bitmapEngine.container
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import bitmapEngine.bak.BitmapConvert;
	import bitmapEngine.BmpRenderInfo;
	
	/**
	 * 将Sprite转位图(只有一帧)
	 * @author Pelephone
	 */
	public class BmpSprite extends Sprite
	{
		public function BmpSprite(sourceDsp:DisplayObject=null)
		{
			_bitmap = new Bitmap();
			addChild(_bitmap);
			
			_convertClip = newConverClip(sourceDsp);
		}
		
		/**
		 * 待渲染的位图
		 */
		protected var _bitmap:Bitmap;
		
		/**
		 * 新建转换组件
		 * @param source
		 * @return 
		 */
		protected function newConverClip(source:DisplayObject):BitmapConvert
		{
			return new BitmapConvert(_bitmap,source);
		}
		
		private var _convertClip:BitmapConvert;
		
		/**
		 * 位图转换器
		 */
		public function get convertClip():BitmapConvert
		{
			return _convertClip;
		}
		
		/**
		 * 当前帧数据
		 * @return 
		 */
		public function get currentBmpInfo():BmpRenderInfo 
		{
			return _convertClip.currentBmtInfo;
		}
		
		/**
		 * 销毁对象(销毁会则不能再使用)
		 */
		public function dispose():void
		{
			if(_bitmap && _bitmap.parent)
				_bitmap.parent.removeChild(_bitmap);
			
			_convertClip.dispose();
		}
	}
}