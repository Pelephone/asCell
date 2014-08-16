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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import TimerUtils.ITimerTool;
	import TimerUtils.TimerTool;
	
	import asCachePool.ClassObjectPool;
	
	/**
	 * 渲染信息缓存管理<br/>
	 * 回收池,因为BitmapData.dispose后，场景上的位图显示会变黑掉，所以不能用简单LRU自动dispose回收<br/>
	 * 考虑：<br/>
	 * 1.每get一次数据就添加一个引用计数,每drop一次就减少一引用计数<br/>
	 * 2.当引用计数为0时放入回收池链表头，加入个update时间待回收。<br/>
	 * 3.链表的顺序是时间顺序，越靠后的数据越旧，移除时可从后向前清<br/>
	 * 4.get数据时先从回收池查，有数据的话就增加引用计数，并移出回收池，防止被回收掉。<br/>
	 * 
	 * @author Pelephone
	 */
	public class BmpRenderMgr
	{
		/**
		 * 单例
		 */
		protected static var instance:BmpRenderMgr;
		/**
		 * 获取单例
		 */
		public static function getInstance():BmpRenderMgr
		{
			if(!instance)
				instance = new BmpRenderMgr();
			
			return instance;
		}
		
		public function BmpRenderMgr(clsPool:ClassObjectPool=null,timeTool:ITimerTool=null)
		{
			_timerTool = timeTool || new TimerTool();
//			_timerTool = new FrameTimerTool();
			classPool = clsPool || new ClassObjectPool();
			
			recycleLinks = new Vector.<String>();
			cacheMap = {};
			
//			_recycleTimer = new Timer(_recycleTime);
//			_recycleTimer.start();
//			_recycleTimer.addEventListener(TimerEvent.TIMER,onTimer);
			
			_timerTool.addItem(onClearTimer,_recycleTime);
			addRender(render);
			
			instance = this;
		}
		
		/**
		 * 类型对象池
		 */
		private var classPool:ClassObjectPool;
		
		/**
		 * 回收池(引用为空并过期的回收)
		 */
		private var recycleLinks:Vector.<String>;
		/**
		 * 缓存哈希
		 */
		private var cacheMap:Object;
		
		/**
		 * 默认过期时间是60秒，即60秒后数据还无访问，且引用数为0则将数据dispose了
		 */		
		private var _expired:Number = 60*1000;
		
		private var _recycleTime:int = 10*1000;
		
		private var _timerTool:ITimerTool;
		
		/**
		 * 回收计时
		 */
		private function onClearTimer():void
		{
			clearExpired();
		}
		
		/**
		 * 重设时间工具
		 */
		public function set timerTool(value:ITimerTool):void
		{
			_timerTool = value;
		}
		
		/**
		 * 添加渲染对象
		 * @param render 渲染方法
		 * @param frameRate 帧率(每秒X帧)
		 */
		public function addRender(render:Function,frameRate:int=0):void
		{
			var delay:int;
			if(frameRate==0)
			{
				delay = 1000/frameRate;
			}
			else
			{
				delay = 1000/_timerTool.stageFrameRate;
			}
			_timerTool.addItem(render,delay);
		}
		
		/**
		 * 删除渲染对象
		 * @param objId
		 * @return 
		 */
		public function removeRender(render:Function):void
		{
			_timerTool.removeItem(render)
		}
		
		/**
		 * 是否有渲染对象
		 * @param render
		 */
		public function hasRender(render:Function):Boolean
		{
			return _timerTool.hasItem(render);
		}
		
		/**
		 * 每帧执行一次，用于判断当前帧渲染面积是否超过
		 */
		private function render():void
		{
			curRenderArea = 0;
			
			while(curRenderArea<FRAME_MAX_RENDER_AREA && waitRenderLs.length)
			{
				var bf:BmpRenderInfo = waitRenderLs.shift();
				var dsp:DisplayObject = bf.source;
				// 已销毁了就不渲染了
				if(!bf.waitRendFrames)
					continue;
				while(bf.waitRendFrames.length && curRenderArea<FRAME_MAX_RENDER_AREA)
				{
					var frame:int = bf.waitRendFrames.shift();
					drawBitmapData(bf,dsp,frame);
				}
			}
		}
		
		/**
		 * 当前帧已渲染的面积
		 */
		private var curRenderArea:int = 0;
		
		/**
		 * 待渲染
		 */
		private var waitRenderLs:Vector.<BmpRenderInfo> = new <BmpRenderInfo>[];
		
		/**
		 * 最帧最大渲染面积
		 */
		private static const FRAME_MAX_RENDER_AREA:int = 300*300;
		
		//////////////////////////////
		// 缓存操作
		/////////////////////////////
		
		/**
		 * 将渲染对象引用数减一，让其回收
		 * @param disp
		 */
		public function dropCache(key:String):void
		{
//			var key:String = getCacheKey(disp,frame);
			var bmpInf:BmpRenderInfo = cacheMap[key];
			if(!bmpInf)
				return;
			bmpInf.useCount--;
			if(bmpInf.useCount==0)
			{
				bmpInf.dropTime = getTimer();
				recycleLinks.unshift(key);
			}
		}
		
		/**
		 * 通过反射名获取对应对象
		 * @param reflName
		 * @return 
		 */
		public function getClsIns(reflName:String):*
		{
			if(classPool)
				return classPool.getObj(getQualifiedClassName(reflName));
			else
				return null;
		}
		
		/**
		 * 通过池创建对象
		 */
		public function getAndCreateObj(claKey:Class,params:Array=null):*
		{
			if(classPool)
				return classPool.getAndCreateObj(claKey,params);
			else
				return null;
		}
		
		/**
		 * 类对象加入对象池
		 */
		public function putInPool(obj:Object,key:String=null):void
		{
			if(!classPool)
				return;
			classPool.putInPool(obj,key);
		}
		
		/**
		 * 将渲染信息放入缓存，缓存信息主键不能为空
		 * @param bitmapFrame
		 */
		public function setBmpCache(bitmapFrame:BmpRenderInfo):void
		{
//			bitmapFrame.useCount = bitmapFrame.useCount + 1;
			cacheMap[bitmapFrame.key] = bitmapFrame;
		}
		
		/**
		 * 通过反射名和帧数获取位数据对象
		 * @param mcObj 用于反射字符主键的对象
		 * @param frame 第N帧,也可以是帧标签
		 */
		public function getCache(key:String):BmpRenderInfo
		{
			// 先看看回收链里面是否有缓存
//			var key:String = getCacheKey(mcObj,frame);
			var tid:int = recycleLinks.indexOf(key);
			if(tid>=0)
				recycleLinks.splice(tid,1);
			
			var res:BmpRenderInfo = cacheMap[key];
//			if(res)
//			{
//				res.useCount = res.useCount + 1;
//			}
			return res;
		}
		
		/**
		 * 通过对象和帧获取缓存主键
		 * @param mcObj 用于反射字符主键的对象
		 * @param frame 第N帧,也可以是帧标签
		 */
		public function getKeyByFrame(mcObj:Object,frame:Object):String
		{
			var reflectName:String = getQualifiedClassName(mcObj);
			return reflectName + "|";// + String(frame);
		}
		
		/**
		 * 通过显示对象反射名和帧数获取键
		 * @param reflName
		 * @param frame
		 * @return 
		 */
		public function getKeyByRefl(reflectName:String,frame:Object):String
		{
			return reflectName + "|" + String(frame);
		}
		
		/**
		 * 从缓存获取池里面渲染信息
		 * 获取生成缓存信息
		 * @return 
		 */
		public function getNewCache(sourcekey:String,frame:int=0,sourceDsp:DisplayObject=null):BmpRenderInfo
		{
//			var key:String = getKeyByRefl(sourcekey,1);
			var key:String = getKeyByRefl(sourcekey,"");
			var res:BmpRenderInfo = getCache(key);
			if(!res)
			{
				var s:DisplayObject;
				if(sourceDsp)
					s = sourceDsp;
				else
					s = getClsIns(key);
				
				if(!s)
					return null;
				res = newBmpData(s,frame);
				res.key = key;
				setBmpCache(res);
			}
			return res;
		}
		
		/**
		 * 创建一个位图帧的位图数据信息
		 * @param disp 要转位图的显示对象
		 * @param mcFrame 如果disp是mc的话，此参数表示mc的帧
		 * @return 
		 */
		public function newBmpData(dsp:DisplayObject, mcFrame:int=0 ,soureKey:String=null):BmpRenderInfo
		{
			if(!dsp)
				return null;
			
			if(!soureKey)
				soureKey = getKeyByFrame(dsp,mcFrame);
			var bitFrame:BmpRenderInfo = cacheMap[soureKey];
			if(dsp is Bitmap)
			{
				if(!bitFrame)
					bitFrame = new BmpRenderInfo();
				
				bitFrame.bitmapData = (dsp as Bitmap).bitmapData;
			}
			else
			{
				var rect:Rectangle = dsp.getBounds(dsp);
				
				if (rect.width <= 0 || rect.height <= 0)
					return null;
				
				if(!bitFrame)
					bitFrame = new BmpRenderInfo();
				
				if((curRenderArea + rect.width*rect.height)>FRAME_MAX_RENDER_AREA)
				{
					// 已经在等渲染了就返回
					if(bitFrame.waitRendFrames.indexOf(mcFrame)>=0)
						return bitFrame;
					bitFrame.waitRendFrames.push(mcFrame);
					waitRenderLs.push(bitFrame);
					return bitFrame;
				}
				
				return drawBitmapData(bitFrame,dsp,mcFrame);
			}
			
			bitFrame.key = soureKey;
//			putCache(disp,bitFrame);
			return bitFrame;
		}
		
		/**
		 * 绘制一次
		 * @param bitFrame
		 * @param dsp
		 */
		private function drawBitmapData(bitFrame:BmpRenderInfo,dsp:DisplayObject,frame:int=0):BmpRenderInfo
		{
			var mc:MovieClip = dsp as MovieClip;
			if(mc)
				mc.gotoAndStop(frame);
			
			// 用于调整理注册点
			var rect:Rectangle = dsp.getBounds(dsp);
			
			// 生成位图数据并生成缓存加入LRU缓存池
			var bitmapData:BitmapData = new BitmapData(dsp.width, dsp.height, true, 0);
			var mx:Matrix = new Matrix(1, 0, 0, 1, -rect.x, -rect.y);
			bitmapData.draw(dsp, mx);
			curRenderArea = curRenderArea + rect.width*rect.height;
//			bitmapData.scroll(rect.x,rect.y);
//			bitFrame.xpos = -rect.x;
//			bitFrame.ypos = -rect.y;
			
			mx = new Matrix(1, 0, 0, 1, rect.x, rect.y);
			bitFrame.setBitmapData(bitmapData,mx,frame);
//			bitFrame.matrix = mx;
//			bitFrame.bitmapData = bitmapData;
			
			return bitFrame;
		}
		
		/**
		 * 清理过期缓存(每隔一定时间清过期数据)
		 */
		public function clearExpired():void
		{
//			frameCache.clearExpired();
			if(recycleLinks.length<1) return;
			var key:String = recycleLinks[recycleLinks.length-1];
			var bmpInf:BmpRenderInfo = cacheMap[key];
			var currentTime:int = getTimer();
			// 加上过期时间大于当前时间说明已过期
			while((bmpInf.dropTime + expired)<currentTime && recycleLinks.length>0)
			{
				bmpInf.dispose();
				cacheMap[key] = null;
				delete cacheMap[key];
				recycleLinks.pop();
				
				if(recycleLinks.length <= 0)
					break;
				
				key = recycleLinks[recycleLinks.length-1];
				bmpInf = cacheMap[key];
			}
		}
		
		/**
		 * 过期时间,一定时间后数据还无访问，且引用数为0则将数据dispose了
		 */
		public function get expired():Number
		{
			return _expired;
		}
		
		/**
		 * @private
		 */
		public function set expired(value:Number):void
		{
			_expired = value;
		}
		
		/**
		 * 回收池里的对象
		 * @return 
		 */
		public function get recycleSize():int 
		{
			return recycleLinks.length;
		}
		
		/**
		 * 回收周期，即每隔多少秒清理一次过期数据，默认时间是30秒
		 */
		public function get recycleTime():int
		{
			return _recycleTime;
		}
		
		/**
		 * @private
		 */
		public function set recycleTime(value:int):void
		{
			_recycleTime = value;
			_timerTool.addItem(onClearTimer,value);
		}
	}
}