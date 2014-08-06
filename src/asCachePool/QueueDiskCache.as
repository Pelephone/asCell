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
package asCachePool
{
	import asCachePool.interfaces.ICacheInfo;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * 排队硬盘缓存
	 * 如果一次性要存入硬盘的数据很多的话会吃CPU，造成界面动画卡钝
	 * 队硬盘是把一堆要硬的数据每隔一定时间存一条记录，避免一次性存过多卡。
	 * @author Pelephone
	 */
	public class QueueDiskCache extends DiskCache
	{
		private var _isFree:Boolean = true;
		/**
		 * 计时器，每隔一定时间存一次队中数据
		 */
		private var storeTimer:Timer;
		/**
		 * 因为存储是吃CPU的，所以用一个队来缓存，每隔一定时间从队中拿一块数据写入硬盘
		 */
		private var storeQueue:Vector.<String>;
		
		/**
		 * 防止队中有重复对象，用一哈希来存储正要上传的数据索引<String,ICacheInfo>
		 */
		private var storeMap:Object;
		
		public function QueueDiskCache(tempFileSize:int=6291456, tempFilePath:String="game/cache-files")
		{
			super(tempFileSize, tempFilePath);
			
			storeQueue = new Vector.<String>();
			storeMap = {};
			storeTimer = new Timer(_storeInterval);
			storeTimer.addEventListener(TimerEvent.TIMER,onTimerPutInDisk);
		}
		
		override protected function onFlushStatus(event:NetStatusEvent):void
		{
			super.onFlushStatus(event);
			if(allowStore) return;
			stopStoreQueue();
			storeTimer.removeEventListener(TimerEvent.TIMER,onTimerPutInDisk);
		}
		
		/**
		 * 覆盖掉了原入硬盘方法，此方法并不会立马入盘，而是会延迟排队入盘
		 * @param keyName
		 * @param cacheInf
		 * @return 
		 */
		override public function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo
		{
			if(!allowStore)
				return cacheInf;
			if(cacheInf.getKeyName()==null)
			{
				trace("主键不能为空");
				return cacheInf;
			}
			
			var resCache:ICacheInfo;
			if(storeQueue && storeQueue.length)
				resCache = storeMap[cacheInf.getKeyName()] as ICacheInfo;
			
			// 如果队列中已缓在同对象就不入队，但会覆盖旧原对象
			if(!resCache)
				storeQueue.push(cacheInf.getKeyName());
			
			storeMap[cacheInf.getKeyName()] = cacheInf;
			
			if(_isFree && !running)
				startStoreQueue();
			
			return cacheInf;
		}
		
		override public function getCacheInfo(keyName:String):ICacheInfo
		{
			if(!allowStore)
				return null;
			// 如果队列中有则返回，无则从硬盘里面查是否有数据
			var resCache:ICacheInfo;
			if(storeQueue && storeQueue.length)
				resCache = storeMap[keyName] as ICacheInfo;
			if(resCache)
				return resCache;
			
			return super.getCacheInfo(keyName);
		}
		
		/**
		 * 每隔一定时间执行一次此方法将存储队数据入硬盘
		 */
		private function onTimerPutInDisk(e:Event):void
		{
			if (!_isFree || !allowStore)
				return; //如果这个时候不空闲
			
			var cacheInf:ICacheInfo;
			// 出队
			if(storeQueue && storeQueue.length)
			{
				cacheInf = storeMap[storeQueue.shift()];
				storeMap[cacheInf.getKeyName()] = null;
				delete storeMap[cacheInf.getKeyName()];
			}
			if(cacheInf)
				super.putCacheInfo(cacheInf);
			else
				stopStoreQueue();
		}
		
		/**
		 * 开始将队数据存储
		 */
		public function startStoreQueue():void
		{
			storeTimer.start();
		}
		
		/**
		 * 停止队数据存入
		 */
		public function stopStoreQueue():void
		{
			storeTimer.stop();
		}
		
		/**
		 * 是否正在运行
		 */
		public function get running():Boolean
		{
			return storeTimer && storeTimer.running;
		}

		/**
		 * 是否空闲
		 */
		public function get isFree():Boolean
		{
			return _isFree;
		}

		/**
		 * @private
		 */
		public function set isFree(value:Boolean):void
		{
			_isFree = value;
			// 空闲的时候就启动排队入库，反之暂停入库
			if(_isFree)
				startStoreQueue();
			else
				stopStoreQueue();
		}
		
		override public function removeAllCache():void
		{
			super.removeAllCache();
			
			pathSO.clear();
			pathSO.flush();
			
			stopStoreQueue();
			storeQueue.length = 0;
			storeMap = {};
		}
		
		override public function removeCache(keyName:String):void
		{
			var sid:int = storeQueue.indexOf(keyName);
			if(sid>=0)
			{
				storeQueue.splice(sid,1);
				storeMap[keyName] = null;
				delete storeMap[keyName];
			}
			super.removeCache(keyName);
		}
		
		override public function dispose():void
		{
			stopStoreQueue();
			storeTimer.removeEventListener(TimerEvent.TIMER,onTimerPutInDisk);
			storeTimer = null;
			storeQueue = null;
			storeMap = null;
			
			super.dispose();
		}
		
		private var _storeInterval:int = 50;

		/**
		 * 存储频率,默认是每秒存20条
		 */
		public function get storeInterval():int
		{
			return _storeInterval;
		}

		/**
		 * @private
		 */
		public function set storeInterval(value:int):void
		{
			_storeInterval = value;
			storeTimer.delay = _storeInterval;
		}
	}
}