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
	import asCachePool.event.CacheEvent;
	import asCachePool.interfaces.ICacheInfo;
	import asCachePool.interfaces.ICachePool;
	
	import flash.events.EventDispatcher;
	
	/**
	 * 缓存框架的轴像类,仅用于继承
	 * @author Pelephone
	 * @website http://www.cnblogs.com/pelephone
	 */
	internal class BaseCache extends EventDispatcher implements ICachePool
	{
		public static const DEFAULT_CACHE_CAPACITY:int = 500;		//默认缓存容量
		
		/**
		 * 内存缓存最大个数,超过这个数就跟据情况移除旧数据
		 * 如果是<=0表示容量无限
		 */
		private var _capacity:int = DEFAULT_CACHE_CAPACITY;
		
		public function BaseCache(size:int=500)
		{
			_capacity = size;
		}
		
		public function getCache(keyName:String):*
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function getCacheInfo(keyName:String):ICacheInfo
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function hasCache(keyName:String):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function putInCache(keyName:String, body:Object):*
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function removeCache(keyName:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function clearExpired():void
		{
			dispatchEvent(new CacheEvent(CacheEvent.CLEAR_EXPIRED));
		}
		
		public function removeAllCache():void
		{
			dispatchEvent(new CacheEvent(CacheEvent.REMOVE_ALL_CACHE));
		}
		
		public function dispose():void
		{
			// TODO Auto Generated method stub
			
		}
		
		
		//////////////////////////////////
		// get/setter
		//////////////////////////////////
		
		/**
		 * 获取绘存容量(能缓存的对象个数)
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
		}
		
		/**
		 * 已缓存的量
		 * @return 
		 */
		public function get size():int
		{
			return 0;
		}
	}
}