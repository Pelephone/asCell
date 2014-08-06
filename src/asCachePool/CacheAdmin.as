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
	import asCachePool.interfaces.ICachePool;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * 内存缓存和硬盘缓存同时存取,读的时候先读内存,没有再读硬盘，并加入了定时清过期缓存功能
	 * 结合SharedObject存取（多用于外载资源缓存）
	 * 
	 * 使用例子如下
	 * 
	 * var rc:CacheAdmin = new CacheAdmin();
	 * 
	 * var obj:TestObj = new TestObj();
	 * rc.putInCache("test1",obj);
	 * var res:TestObj = rc.getCache("test1") as TestObj;
	 * 
	 * //var swfloader:Loader;
	 * //swfloader.loadBytes(bytes,_context);
	 * //var bytes:ByteArray = swfloader.content;
	 * ////加载数据要转二进制才能存放到到硬盘缓存
	 * //rc.putInCache(bytes);
	 * 
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class CacheAdmin implements ICachePool
	{
		private var _expired:int;
		
		private var _cacheType:int;
		private var _capacity:int = 500;
		private var _clearPeriod:int = 1000*60;
		
		private var diskCache:ICachePool;	//硬盘缓存
		private var memCache:ICachePool;	//内存缓存
		
		/**
		 * 清理计时器，每隔一定时间会自动清理过期的缓存
		 */
		private var periodTimer:Timer;
		
		/**
		 * 构造富缓存
		 * @param size 缓存最大容量(个数)
		 * @param cacheType 缓存类型(0,先读内存再读硬盘; 1,只读内存; 2,只读硬盘; 3,不读缓存)
		 * @param tempFileSize
		 * @param tempFilePath
		 */
		public function CacheAdmin(size:int=500,cacheType:int=0,tempFileSize:int=6291456
								  ,tempFilePath:String="game/cache-files")
		{
			_capacity = 500;
			_cacheType = cacheType;
			diskCache = newDiskCache(tempFileSize,tempFilePath);
			memCache = newMemoryCache(size); 
		}
		
		/**
		 * 创建硬盘缓存
		 * @param tempFileSize 文件硬盘体积
		 * @param tempFilePath 缓存硬盘路径
		 */
		protected function newDiskCache(tempFileSize:int=6291456
												 ,tempFilePath:String="game/cache-files"):ICachePool
		{
//			return new DiskCache(tempFileSize,tempFilePath);
			return new QueueDiskCache(tempFileSize,tempFilePath);
		}
		
		/**
		 * 创建内存缓存
		 * @param tempFileSize
		 * @param tempFilePath
		 */
		protected function newMemoryCache(size:int=500):ICachePool
		{
			return new MemoryCache(size);
		}
		
		/**
		 * 设置硬盘缓存池
		 * @param cachePool
		 */
		public function setDiskCache(cachePool:ICachePool):void
		{
			diskCache = cachePool;
		}
		
		/**
		 * 设置内存缓存池
		 * @param cachePool
		 */
		public function setMemCache(cachePool:ICachePool):void
		{
			memCache = cachePool;
		}
		
		/**
		 * 新建池缓存信息对象
		 * @param keyName
		 * @param body
		 */
		protected function newPoolInf(keyName:String,body:Object,version:String=null):ICacheInfo
		{
			var lCache:ICacheInfo = new CacheInfo();
			lCache.setKeyName(keyName);
			lCache.setBody(body);
			lCache.setUpdateTime((new Date()).getTime()/1000);
			lCache.setCount(0);
			lCache.setExpired(expired);
			lCache.setVersion(version);
			return lCache;
		}
		
		/**
		 * 放入带版本号的缓存对象
		 * @param keyName 主键
		 * @param body 要被缓存的对象
		 * @param version 版本
		 */
		public function putCacheDoVersion(keyName:String,body:Object,version:String=null):void
		{
			var cacheInf:ICacheInfo = newPoolInf(keyName,body,version);
			putCacheInfo(cacheInf);
		}
		
		/**
		 * 获取缓存并判断版本是否一至
		 * @param keyName 主键
		 * @param body 要被缓存的对象
		 * @param version 版本
		 * @return 缓存对象
		 */
		public function getCacheDoVersion(keyName:String,body:Object,version:String=null):Object
		{
			var cacheInf:ICacheInfo = getCacheInfo(keyName);
			if(cacheInf && cacheInf.getVersion()==version)
				return cacheInf.getBody();
			else
				return null;
		}
		
		
		/**
		 * 将对象同时缓存至内存和硬盘
		 * @param keyName 主键
		 * @param body 要被缓存的对象
		 */
		public function putInCache(keyName:String, body:Object):*
		{
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_MEMORY_ONLY){
//				super.putInCache(keyName,body,version,groupName);
				memCache.putInCache(keyName,body);
			}
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_DISK_ONLY){
				diskCache.putInCache(keyName,body);
			}
			return body;
		}
		
		/**
		 * 将缓存信息放入池中
		 * @param keyName 主键
		 * @param cacheInf
		 */
		public function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo
		{
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_MEMORY_ONLY){
				memCache.putCacheInfo(cacheInf);
			}
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_DISK_ONLY){
				diskCache.putCacheInfo(cacheInf);
			}
			return cacheInf;
		}
		
		/**
		 * 获取加载的二进制缓存的数据,没有则返回null;
		 * 1.先从内存查是否有数据；2.内存无数据就从硬盘查
		 * @param url
		 * @param version
		 */
		public function getCache(keyName:String):*
		{
			var cacheInf:ICacheInfo = getCacheInfo(keyName);
			if(cacheInf) return cacheInf.getBody();
			else return null;
		}
		
		public function getCacheInfo(keyName:String):ICacheInfo
		{
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_MEMORY_ONLY){
				var cacheInf:ICacheInfo = memCache.getCacheInfo(keyName);
				if(cacheInf) return cacheInf;
			}
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_DISK_ONLY)
				return diskCache.getCacheInfo(keyName);
			return null;
		}
		
		/**
		 * 将缓存清除
		 * @param keyName
		 */
		public function removeCache(keyName:String):void
		{
			memCache.removeCache(keyName);
			diskCache.removeCache(keyName);
		}
		
		/**
		 * 移除缓存
		 */
		public function removeAllCache():void
		{
			memCache.removeAllCache();
			diskCache.removeAllCache();
		}
		
		public function clearExpired():void
		{
			diskCache.clearExpired();
			memCache.clearExpired();
		}
		
		public function hasCache(keyName:String):Boolean
		{
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_MEMORY_ONLY)
			{
				var cacheInf:ICacheInfo = memCache.getCacheInfo(keyName);
				if(cacheInf) return true;
			}
			if(cacheType==CacheType.CACHETYPE_MEMORY_AND_DISK || cacheType==CacheType.CACHETYPE_DISK_ONLY)
			{
				cacheInf = diskCache.getCacheInfo(keyName);
				if(cacheInf) return true;
			}
			return false;
		}
		
		/**
		 * 周期清除过期对象
		 * @param e
		 */
		private function onClearTime(e:TimerEvent):void
		{
			memCache.clearExpired();
		}
		
		/**
		 * 移除周期时间
		 */
		public function removeTimer():void
		{
			periodTimer.removeEventListener(TimerEvent.TIMER,onClearTime);
			periodTimer = null;
		}

		public function get cacheType():int
		{
			return _cacheType;
		}

		public function set cacheType(value:int):void
		{
			_cacheType = value;
		}

		/**
		 * 过期时间(以秒为单位)
		 * 整型位数不够，所以不能用毫秒
		 */
		public function get expired():int
		{
			return _expired;
		}

		/**
		 * @private
		 */
		public function set expired(value:int):void
		{
			_expired = value;
		}
		
		/**
		 * 获取绘存容量(最多能缓存的对象个数)
		 * @return 
		 */
		public function get capacity():int
		{
			return _capacity;
		}
		
		/**
		 * 设置缓存容量(能缓存的对象个数)
		 * @param value
		 */
		public function set capacity(value:int):void
		{
			_capacity = value;
			if(memCache) memCache.capacity = value;
		}
		
		/**
		 * 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
		 */
		public function get clearPeriod():int
		{
			return _clearPeriod;
		}
		
		/**
		 * 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
		 * 此值为0会自动关掉过期清理功能
		 */
		public function set clearPeriod(value:int):void
		{
			_clearPeriod = value;
			removeTimer();
			if(value<=0)
				return;
			
			periodTimer = new Timer(_clearPeriod);
			periodTimer.addEventListener(TimerEvent.TIMER,onClearTime);
		}
		
		public function get size():int
		{
			return memCache.size;
		}
		
		public function dispose():void
		{
			removeTimer();
			periodTimer = null;
			memCache.dispose();
			diskCache.dispose();
		}
	}
}