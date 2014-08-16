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
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * 硬盘缓存框架(配合SharedObject来存)
	 * 
	 * 使用例子如下
	 * 
	 * var rc:RichCache = new RichCache();
	 * 
	 * var obj:TestObj = new TestObj();
	 * // 加载数据要转二进制才能存放到到硬盘缓存
	 * rc.putInCache("test1",obj);
	 * var res:TestObj = rc.getCache("test1") as TestObj;
	 * 
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class DiskCache extends BaseCache
	{
		/**
		 * 将缓存对象路径映射数据存储的默认路径
		 */
		public static const DEFAULT_CACHE_DATA_SRC:String = "default_cache_data_src";
		
		/**
		 * 缓存的最大体积6M
		 */
		public static const FLUSH_DISK_SIZE:int = 6 * 1024 * 1024;
		/**
		 * 把文件缓存至硬盘的路径
		 */
		public static const DEFAULT_FILE_PATH:String = "game/cache-files";
		
		/**
		 * 硬盘缓存变量
		 */
		protected var _so:SharedObject;
		/**
		 * 用于存路径的共享对象
		 */
		private var _pathSO:SharedObject;
		
		/**
		 * 缓存硬盘路径
		 */
		private var _tempFilePath:String;
		/**
		 * 缓存硬盘最大体积
		 */
		private var _tempFileSize:int = 1024*1024*1024;
		
		public function DiskCache(tempFileSize:int=6291456,tempFilePath:String="game/cache-files")
		{
//			super(size);
			_tempFilePath = tempFilePath;
			_tempFileSize = tempFileSize;
		}
		
		/**
		 * 新建池缓存信息对象
		 * @param keyName
		 * @param body
		 */
		protected function newPoolInf(keyName:String,body:Object):ICacheInfo
		{
			var lCache:ICacheInfo = new CacheInfo();
			lCache.setKeyName(keyName);
			lCache.setBody(body);
			lCache.setUpdateTime((new Date()).getTime()/1000);
			lCache.setCount(0);
//			lCache.setExpired(expired);
//			lCache.version = version;
			return lCache;
		}
		
		/**
		 * 将要缓存的数据对象缓存至硬盘
		 * @param keyName
		 * @param body
		 * @return 
		 */
		override public function putInCache(keyName:String, body:Object):*
		{
			var lCache:ICacheInfo = newPoolInf(keyName,body);
			putCacheInfo(lCache);
			return body;
		}
		
		/**
		 * 通过池信息缓存至硬盘(池信息除了缓存的对象体外还会存更新时间，版本号等信息)
		 * @param keyName
		 * @param pInf
		 */
		override public function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo
		{
			// 用户不允许使用硬盘
			if(!allowStore)
				return cacheInf;
			
//			initPathShareObject();
			
			if(!cacheInf.getKeyName())
			{
				trace("主键不能为空，缓存失败");
				return cacheInf;
			}
			try
			{
				_so = SharedObject.getLocal(_tempFilePath+"/"+cacheInf.getKeyName(),"/");
			}
			catch (e:*)
			{
				//do nothing
			}
			if (_so == null)
				return cacheInf;
			
			_so.data["body"] = cacheInf.getBody();
			
			if(cacheInf.isGSVars && cacheInf.dyVars)
			{
				for (var oName:String in cacheInf.dyVars) 
				{
					var val:Object = cacheInf.dyVars[oName];
					_so.data[oName] = val;
				}
			}
			else
			{
				_so.data["body"] = cacheInf.getBody();
				_so.data["count"] = cacheInf.getCount();
				_so.data["expired"] = cacheInf.getExpired();
				_so.data["groupName"] = cacheInf.getGroupName();
				_so.data["keyName"] = cacheInf.getKeyName();
				_so.data["updateTime"] = cacheInf.getUpdateTime();
				_so.data["version"] = cacheInf.getVersion();
			}
			
			var ls:Array = cachePathLs;
			if(ls.indexOf(cacheInf.getKeyName())<0)
				ls.push(cacheInf.getKeyName());
			
			var flushStatus:String = null;
			try
			{	
				flushStatus = _so.flush(_tempFileSize);
			}
			catch(error:Error) 
			{
				//do nothing
				trace("电脑不支持SharedObject缓存!硬盘缓存失败");
				allowStore = false;
			}
			
			if (flushStatus == SharedObjectFlushStatus.PENDING && !hasTip)
			{
				allowStore = false;
				hasTip = true;
				_so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
				dispatchEvent(new Event(Event.SELECT));
			}
			else if (flushStatus == SharedObjectFlushStatus.FLUSHED)
			{
			}
			
			writePathInf();
			
			return cacheInf;
		}
		
		/**
		 * 判断是否弹过警告提示
		 */
		private var hasTip:Boolean = false;
		
		/**
		 * 写入硬盘事件状态
		 * @param event
		 */
		protected function onFlushStatus(event:NetStatusEvent):void
		{
			var tmpSo:SharedObject = event.currentTarget as SharedObject;
			switch (event.info.code)
			{
				case "SharedObject.Flush.Success":
					allowStore = true;
					break;
				case "SharedObject.Flush.Failed":
					// 用户不允许存储任何内容到客户端
					allowStore = false;
					break;
			}
			tmpSo.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override public function getCache(keyName:String):*
		{
			var pinf:ICacheInfo = getCacheInfo(keyName);
			if(pinf)
				return pinf.getBody();
			else
				return null;
		}
		
		override public function getCacheInfo(keyName:String):ICacheInfo
		{
			// 用户不允许使用硬盘缓存
			if(!allowStore)
				return null;
			
//			initPathShareObject();
			
			try
			{
				var pathStr:String = _tempFilePath+"/"+keyName;
				_so = SharedObject.getLocal(pathStr,"/");
				var pinf:ICacheInfo = new CacheInfo(_so.data);
				return pinf;
			}
			catch(error:Error) 
			{
				trace(error,keyName,"so创建失败");
//				trace("电脑不支持SharedObject缓存!");
				return null;
			}
			return null;
		}
		
		/**
		 * 将缓存清除
		 * @param keyName
		 */
		override public function removeCache(keyName:String):void
		{
			// 用户不允许使用硬盘缓存
			if(!allowStore)
				return;
			
//			initPathShareObject();
			
			if(!hasCache(keyName))
			{
				trace("缓存对象不存在硬盘里!或者已删除掉了");
				return;
			}
			
			try
			{
				_so = SharedObject.getLocal(_tempFilePath+"/"+keyName,"/");
				_so.data["body"] = null;
				_so.clear();
				_so.flush();
				
				
				removePathInf(keyName);
				writePathInf();
			}
			catch(error:Error) 
			{
				trace("电脑不支持SharedObject缓存!");
			}
		}
		
		override public function hasCache(keyName:String):Boolean
		{
			var ls:Array = cachePathLs;
			if(!ls)
				return false;
			else
				return ls.indexOf(keyName)>=0;
//			return getCacheInfo(keyName)!=null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeAllCache():void
		{
			var ls:Array = cachePathLs;
			for each (var itm:String in ls) 
			{
				removeCache(itm);
			}
			super.removeAllCache();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clearExpired():void
		{
			// 当前时间
			var getTime:int = (new Date()).getTime()/1000;
			
			var arr:Array = [];
			for each (var itm:ICacheInfo in cachePathLs) 
			{
				if((itm.getUpdateTime() + itm.getExpired())>getTime)
					arr.push(itm.getKeyName());
			}
			for each (var key:String in arr) 
			{
				removeCache(key);
			}
			
			super.clearExpired();
		}
		
		//---------------------------------------------------
		// allowStore
		//---------------------------------------------------
		
		private var _allowStore:Boolean = true;

		/**
		 * 指示是否允许通过ShareObject将资源存储到本地计算机
		 */
		public function get allowStore():Boolean
		{
			return _allowStore;
		}

		/**
		 * @private
		 */
		public function set allowStore(value:Boolean):void
		{
			_allowStore = value;
		}

		//---------------------------------------------------
		// 缓存路径映射相关
		//---------------------------------------------------
		
		/**
		 * 移出一条缓存映射信息
		 * @return 
		 */
		private function removePathInf(keyName:String):void
		{
			var ls:Array = cachePathLs;
			if(!ls) return;
			var tid:int = ls.indexOf(keyName);
			if(tid<0)
				return;
			
			ls.splice(tid,1);
			writePathInf();
		}
		
		/**
		 * 将缓存列表写入硬盘
		 */
		private function writePathInf():void
		{
			var pso:SharedObject = pathSO;
			if(!pso)
				return;
			var flushStatus:String = null;
			try
			{
				if(_cachePathLs && _cachePathLs.length)
				{
					pso.data["pathLs"] = _cachePathLs;
					flushStatus = pso.flush();
				}
				else
				{
					pso.clear();
					pso.flush();
				}
			} 
			catch(error:Error) 
			{
				trace("路径错误",error);
				// 用户不允许存储任何内容到客户端
				this.allowStore = false;
			}
			
			if (flushStatus == SharedObjectFlushStatus.PENDING && !hasTip)
			{
				allowStore = false;
				hasTip = true;
				_so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
				dispatchEvent(new Event(Event.SELECT));
			}
			else if (flushStatus == SharedObjectFlushStatus.FLUSHED)
			{
			}
		}
		
		/**
		 * 判断和初始共享对象
		 */
		protected function get pathSO():SharedObject
		{
			if(!allowStore)
				return null;
			
			if(!_pathSO)
			{
				_pathSO = SharedObject.getLocal(DEFAULT_CACHE_DATA_SRC);
				
				try
				{
					var arr:Array = _pathSO.data["pathLs"];
//					_cachePathLs = [];
					for each (var keyItem:String in arr) 
					{
						if(_cachePathLs.indexOf(keyItem)<0)
							_cachePathLs.push(keyItem);
					}
				}
				catch(error:Error)
				{
					try
					{
						_pathSO.clear();
						_pathSO.flush();
					}
					catch(error:Error)
					{
						trace(error,"读取路径出错");
					}
				}
			}
			
/*			if(_pathSO || _cachePathFile!=null)
				return _pathSO;
			
			cachePathFile = DEFAULT_CACHE_DATA_SRC;*/
			return _pathSO;
		}
		
		private var _cachePathLs:Array = [];
		
		/**
		 * 缓存路径列表，初始的时候获换路径映射的时候读一次，肯定不能为空
		 */
		public function get cachePathLs():Array
		{
			var so:SharedObject = pathSO
			return _cachePathLs;
		}

		override public function dispose():void
		{
			_so = null;
			_pathSO = null;
			super.dispose();
		}
	}
}