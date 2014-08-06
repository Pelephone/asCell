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
	import TimerUtils.ExpireTimer;
	
	import asCachePool.interfaces.IRecycle;
	
	import bitmapEngine.BmpRenderInfo;
	import bitmapEngine.BmpRenderMgr;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 将Sprite转位图(只有一帧)
	 * @author Pelephone
	 */
	public class SpriteBitmap extends Sprite implements IRecycle
	{
		/**
		 * 位图缓存管理
		 */
		protected var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
		
		protected var _source:DisplayObject;
		
		/**
		 * 待渲染的位图
		 */
		protected var _bitmap:Bitmap;
		
		private var _currentBmtInfo:BmpRenderInfo;
		
		/**
		 * 显示对象转位图数据工具
		 
		protected var dispBitmapData:DisplayBitmapData;*/
		
		public function SpriteBitmap()
		{
//			dispBitmapData = new DisplayBitmapData();
			
			_bitmap = new Bitmap();
			addChild(_bitmap);
			expireTimer = newExpireTimer();
		}
		
		public function doRender(arg:Object=null):void
		{
			rendering();
		}
		
		/**
		 * 正在渲染
		 */
		protected function rendering():void
		{
			if(source==null)
				currentBmtInfo = null;
//			else if(source is Bitmap)
//			{
//				_bitmap.bitmapData = (source as Bitmap).bitmapData;
//			}
			else if(source is Sprite || source is Bitmap || source is Shape)
			{
				currentBmtInfo = getBmpFrame();
			}
		}
		
		/**
		 * 从缓存获取池里面渲染信息
		 * @return 
		 */
		protected function getBmpFrame():BmpRenderInfo
		{
			var key:String = bmpMgr.getKeyByFrame(source,1);
			var res:BmpRenderInfo = bmpMgr.getCache(key);
			if(!res)
			{
				res = bmpMgr.newBmpData(source,1);
				res.key = key;
				bmpMgr.setBmpCache(res);
			}
			return res;
		}
		
		/////////////////////////////////////
		// get/set
		/////////////////////////////////////
		
		/**
		 * 当前帧的Bitmap<br/>
		 * 此bmp里面的bitmapdata不能被其它地方引用，因为它会在管理器中自动回收，
		 * 自动回收时如果外部引用会导致显示错误
		 */
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		/**
		 * 原显示对象(可以是Bitmap,Sprite,Shape)
		 */
		public function get source():DisplayObject
		{
			return _source;
		}
		
		public function get frameRate():int
		{
			return 0;
		}

		/**
		 * @private
		 */
		public function set source(value:DisplayObject):void
		{
			if(_source == value)
				return;
			_source = value;
			rendering();
		}
		
		/**
		 * 当前帧信息<br/>
		 * 此对象里面的bitmapdata不能被其它地方引用，因为它会在管理器中自动回收，
		 * 自动回收时如果外部引用会导致显示错误
		 */
		public function get currentBmtInfo():BmpRenderInfo
		{
			return _currentBmtInfo;
		}

		/**
		 * @private
		 */
		public function set currentBmtInfo(value:BmpRenderInfo):void
		{
			if(value == _currentBmtInfo)
				return;
			
			if(_currentBmtInfo)
				bmpMgr.dropCache(_currentBmtInfo.key);
			
			_currentBmtInfo = value;
			
			if(!value)
				_bitmap.bitmapData = null;
			else
			{
				_bitmap.bitmapData = value.useBitmapData();
//				_bitmap.x = - value.xpos;
//				_bitmap.y = - value.ypos;
			}
			
			
//			if(!_bitmap.bitmapData){
//				_bitmap.bitmapData = new BitmapData(currentBmtInfo.bitmapData.width,currentBmtInfo.bitmapData.height,true,0);
//			}
//			_bitmap.bitmapData.copyPixels(currentBmtInfo.bitmapData,currentBmtInfo.bitmapData.rect,new Point(0,0));
//			if(_bitmap.y != ( - currentBmtInfo.ypos))
		}
		
		/**
		 * 过期管理
		 */
		private var expireTimer:ExpireTimer;
		
		/**
		 * 新建过期管理器
		 */
		protected function newExpireTimer():ExpireTimer
		{
			var etr:ExpireTimer = new ExpireTimer(this,2*60*1000);
			etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			etr.addEventListener(ExpireTimer.RESET,onReset);
			return etr;
		}
		
		/**
		 * 重置
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			rendering();
		}
		
		/**
		 * 当前显示的位图资源过期回收
		 * @param e
		 */
		protected function onExpired(e:Event=null):void
		{
			currentBmtInfo = null;
		}
		
		/**
		 * 销毁对象(销毁会则不能再使用)
		 */
		public function dispose():void
		{
			if(_bitmap && _bitmap.parent)
				_bitmap.parent.removeChild(_bitmap);
			
			currentBmtInfo = null;
			
			source = null;
			
			if(expireTimer)
			{
				expireTimer.removeEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
				expireTimer.removeEventListener(ExpireTimer.RESET,onReset);
			}
			expireTimer = null;
		}
	}
}