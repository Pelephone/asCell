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

	/**
	 * LRU内存缓存(即如果大于缓存最大size时,使用次数最次的先出)
	 * 
	 * 本组件多用于管理加载外部swf缓存在内存
	 * 为了判断数据是否最新,加了一个version即版本号做为判断
	 * 例如角色服装服务器更新了,可能客户端读取缓存就有可能读到旧的服装数据
	 * 
	 * 
	 * var rc:MemoryCache = new MemoryCache();
	 * 
	 * var obj:TestObj = new TestObj();
	 * // 加载数据要转二进制才能存放到到硬盘缓存
	 * rc.putInCache("test1",obj);
	 * var res:TestObj = rc.getCache("test1") as TestObj;
	 * 
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class MemoryCache extends BaseCache
	{
		/**
		 * 过期间隔(5分钟没有引用就视为过期清除)
		 */
		public static const EXPIRED_INTERVAL:int = 5*60*1000;
		
		/**
		 * 内存缓存图形 <String,PoolInfo>
		 */
		private var cacheMap:Object = {};
		/**
		 * 双链表来写LRU算法,即用次数最少的缓存先删除.<String>,存url即cacheMap的主键
		 * 算法思路,每get和new数据到cacheMap时都把数据放入下表的表头.
		 * 这样表最前面的肯定是用最多的数据,最后的是用最少的.而且还可以用此表知道已缓存的数据长度
		 */		
		private var lruLinks:Vector.<String>;
		
//		private var _clearPeriod:int = 1000*60;
		
		/**
		 * 给缓存分组,组名映射对应主键名数组<String,<Vector.<String>>>
		 
		private var groupMap:Object;*/
		
		public function MemoryCache(size:int=500)
		{
			cacheMap = {};
			lruLinks = new Vector.<String>();
//			groupMap = {};
			super(size);
		}
		
		/**
		 * 新建池缓存信息对象
		 * @param keyName
		 * @param body
		 */
		protected function newPoolInf(keyName:String,body:Object):ICacheInfo
		{
			var currTime:int = (new Date()).getTime()/1000;
			var lCache:ICacheInfo = new CacheInfo();
			lCache.setKeyName(keyName);
			lCache.setBody(body);
			lCache.setUpdateTime(currTime);
			lCache.setCount(0);
			lCache.setExpired(EXPIRED_INTERVAL);
//			lCache.version = version;
			return lCache;
		}
		
		override public function clearExpired():void
		{
			if(lruLinks.length==0 || expired<=0) return;
			var key:String = lruLinks[lruLinks.length-1];
			var poolInf:ICacheInfo = getCacheInfo(key);
			// 过期的时间点
			var pTime:int = poolInf.getUpdateTime() + expired;
			// 当前时间
			var getTime:int = (new Date()).getTime()/1000;
			// 过期时间点比当前时间大表示该缓存已过期
			// 例如过期时间是8点，而当前时间是9点，则对象过期，要清除
			while(pTime<getTime && lruLinks.length>0)
			{
				removeCache(poolInf.getKeyName());
				
				if(lruLinks.length==0) break;
				
				key = lruLinks[lruLinks.length-1];
				poolInf = getCacheInfo(key);
				pTime = poolInf.getUpdateTime() + expired;
			}
		}
		
		override public function getCache(keyName:String):*
		{
			var cacheInf:ICacheInfo = getCacheInfo(keyName);
			if(!cacheInf) return null;
			return cacheInf.getBody();
		}
		
		override public function getCacheInfo(keyName:String):ICacheInfo
		{
			var tid:int = lruLinks.indexOf(keyName);
			if(tid<0) {
//				trace("无",keyName,"对应的缓存对象!");
				return null;
			}
			// 已在表头就不换位置
			if(tid>0){
				//LRU算法,每获取一次就把对象放入对首,这样用得最少的自然就在队尾了.
				lruLinks.splice(tid,1);
				lruLinks.unshift(keyName);
			}
			
			var res:ICacheInfo = cacheMap[keyName] as ICacheInfo;
			var currTime:int = (new Date()).getTime()/1000;
			res.setUpdateTime(currTime);
			res.setCount(res.getCount()+1);
			return res;
		}
		
		override public function hasCache(keyName:String):Boolean
		{
			return (lruLinks.indexOf(keyName)>=0);
		}
		
		override public function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo
		{
			if(cacheInf.getKeyName()==null)
			{
				trace("缓存对象的主键为空!缓存失败");
				return cacheInf;
			}
			
			cacheMap[cacheInf.getKeyName()] = cacheInf;
			
			//有新缓存对象就加入队首,get的时候也把对象放入队首.清除的时候从后面清就可以LRU移除
			//如果>=0表示keyName已缓存有对象,则cacheMap重盖了对象,lruLinks表就不需要添元素,反之lruLinks往前加元素
			if(lruLinks.indexOf(cacheInf.getKeyName())<0)
				lruLinks.unshift(cacheInf.getKeyName());
			
			lruRemoveCache();
			return cacheInf;
		}
		
		override public function putInCache(keyName:String, body:Object):*
		{
			var lCache:ICacheInfo = newPoolInf(keyName,body);
			putCacheInfo(lCache);
			return body;
		}
		
		override public function removeCache(keyName:String):void
		{
			if(!hasCache(keyName))
			{
//				trace("缓存对象不存在内存，或者已回收!");
				return;
			}
			var tid:int = lruLinks.indexOf(keyName);
			lruLinks.splice(tid,1);
			var res:ICacheInfo = cacheMap[keyName] as ICacheInfo;
			res.dispose();
			cacheMap[keyName] = null;
			delete cacheMap[keyName];
		}
		
		override public function removeAllCache():void
		{
			for each (var res:ICacheInfo in cacheMap) 
			{
				res.dispose();
			}
			
			cacheMap = {};
			lruLinks = new Vector.<String>();
		}
		
		/**
		 * 超出缓存的数量就开始移出
		 */
		private function lruRemoveCache():void
		{
			while(capacity>0 && lruLinks.length>capacity)
			{
				var keyName:String = lruLinks.pop();
				var res:ICacheInfo = cacheMap[keyName] as ICacheInfo;
				res.dispose();
				cacheMap[keyName] = null;
				delete cacheMap[keyName];
			}
		}
		
		override public function dispose():void
		{
			removeAllCache();
			super.dispose();
		}
		
		//////////////////////////////////////////
		// getter/setter
		//////////////////////////////////////////

		override public function set capacity(value:int):void
		{
			super.capacity = value;
			lruRemoveCache();
		}
		
		override public function get size():int
		{
			return lruLinks?lruLinks.length:0;
		}
		
		// expired,全局设置此参数可节提高周期回收的效率
		
		private var _expired:int = EXPIRED_INTERVAL;

		/**
		 * 每个子项过期时间,此参数<=0表示永不过期
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
	}
}