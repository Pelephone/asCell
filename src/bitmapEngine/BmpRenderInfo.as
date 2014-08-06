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
package bitmapEngine
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	
	/** 渲染完成 */
	[Event(name="complete", type="flash.events.Event")]
	/** 销毁的时候发个消息把所有引用此数据对象回收掉 */
	[Event(name="clear", type="flash.events.Event")]
	
	/**
	 * 位图渲染数据信息，位图帧<br/>
	 * 此对象用于回收缓存和播放帧用。(有部份类似于FrameLabel)
	 * @author Pelephone
	 */
	final public class BmpRenderInfo extends EventDispatcher
	{
		/**
		 * 第N帧
		 
		public var frame:Object;*/
		
		/**
		 * 待渲染显示对象，（待渲染的时候用）
		 */
		public var source:DisplayObject;
		
		/**
		 * 帧标签
		 
		public var name:String;*/
		
		/**
		 * 矩阵数据组
		 */
		private var _matrixLs:Object = {};
		
		
		/**
		 * 获取某帧生成的矩阵
		 * @param frame
		 * @return 
		 */
		public function getFrameMaxtrix(frame:int=0):Matrix
		{
			if(_matrixLs.hasOwnProperty(frame))
				return _matrixLs[frame];
			else
				return null;
		}
		
		/**
		 * 位图数据组(如果被渲染的对象是mc时使用)
		 */
		private var _bmpdLs:Object = {};
		
		/**
		 * 等待渲染的帧
		 */
		public var waitRendFrames:Vector.<int> = new Vector.<int>();
		
//		private var _bitmapData:BitmapData;
		
		/**
		 * 获取某
		 * @param frame
		 * @return 
		 */
		public function getFrameBitmapData(frame:int=0):BitmapData
		{
			if(_bmpdLs.hasOwnProperty(frame))
				return _bmpdLs[frame];
			else
				return null;
		}

		/**
		 * 位图数据 (此数据带自动回收机制，引用需要注意）
		 */
		public function get bitmapData():BitmapData
		{
			if(_bmpdLs.hasOwnProperty(0))
				return _bmpdLs[0];
			else
				return null;
		}

		/**
		 * @private
		 */
		public function set bitmapData(value:BitmapData):void
		{
			if(_bmpdLs.hasOwnProperty(0) && _bmpdLs[0] == value)
				return;
			_bmpdLs[0] = value;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 添加一条帧数据
		 * @param value
		 * @param mx
		 * @param frame
		 */
		public function setBitmapData(value:BitmapData,mx:Matrix,frame:int=0):void
		{
			_bmpdLs[frame] = value;
			_matrixLs[frame] = mx;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 引用一次位图数据 (设置bitmap数据的时候调用)
		 * @return 
		 */
		public function useBitmapData(frame:int=0):BitmapData
		{
			useCount = useCount + 1;
			return _bmpdLs[frame];
		}
		
		/**
		 * 显示矩阵
		 
		public var matrix:Matrix;*/
		
		/**
		 * x位置 
		 	
		public var xpos:Number = 0;*/	
		
		/**
		 * y位置 
		 	
		public var ypos:Number = 0;*/	
		
		
		////////////////////
		// 缓存用的属性
		///////////////////
		
		/**
		 * 存入缓存的键前缀(一般是类的反射名或者资源URL地址)
		 
		public var keyPrefix:String;*/
		
		/**
		 * 引用计数，即有多少对象引用了它(只有这个数字为0才能dispose回收)
		 */
		public var useCount:int;
		
		/**
		 * 最后一次引用为0时的时间
		 */
		public var dropTime:int;
		
		/**
		 * 缓存键名
		 */
		public var key:String;
		
		/**
		 * 渲染draw完成调用的方法,这个属性为空表示已经draw完或者不能draw
		 */
		public var drawComplete:Function;
		
		/**
		 * 缓存的键名
		 * @return 
		 
		public function get key():String
		{
			if(keyPrefix)
				return keyPrefix + "|" + frame;
			else
				return null;
		}*/
		
		/**
		 * 销毁此缓存数据
		 */
		public function dispose():void
		{
			for each (var bmpd:BitmapData in _bmpdLs) 
				bmpd.dispose();
			
			_bmpdLs = {};
			source = null;
			_matrixLs = new Vector.<Matrix>();
			waitRendFrames = null;
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		/**
		 * 对应源数据的名字，缓存找唯一ID用得上
		 
		 public var source:String;*/
		/**
		 * 最后一次引用时间 
		 	
		public var lastTime:int;*/	
		
	}
}