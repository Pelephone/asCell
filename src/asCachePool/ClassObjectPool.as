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
	import asCachePool.interfaces.IRecycle;
	import asCachePool.interfaces.IReset;
	
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	/**
	 * 类Class和对象new出映射缓存,多用于列表组件等
	 * (本组件用的是LRU算法)
	 * 
	 * 例子如下:
	 * var pool:IClassObjectPool = new ClassObjectPool(100,60000,60000);
	 * 
	 * var obj:TestObj = new TestObj();
	 * pool.putInPool(obj);
	 * 
	 * var getObj:TestObj = pool.getObj(TestObj);
	 * 
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class ClassObjectPool
	{
		public static const DEFAULT_CACHE_CAPACITY:int = 500;		//默认缓存容量
		
		/**
		 * 不缓存项
		 */
		public static const NO_ITEM_CACHE:int = -1;
		/**
		 * 自动缓存项(数据最大长度缓存项)
		 */
		public static const AUTO_ITEM_CACHE:int = 0;
		
		/**
		 * 缓存的哈希对象主键是class转字符串<String,<Vector.<PoolInfo>>>
		 */
		private var cacheMap:Object;
		/**
		 * 对象链表.双链表形式管理LRU缓存对象
		 */
		private var cacheLink:Vector.<ICacheInfo>;
		
		/**
		 * 给缓存分组,组名对应组对象<String,<Array>>
		 */
//		private var groupMap:Dictionary;
//		private var _cacheSize:int;
		
		protected var _clearPeriod:int = 1000*60;
		protected var _expired:int = 1000*60;
		
		/**
		 * 内存缓存最大个数,超过这个数就跟据情况移除旧数据
		 * 如果是<=0表示容量无限
		 */
		private var _capacity:int = DEFAULT_CACHE_CAPACITY;
		
		/**
		 * 清理计时器，每隔一定时间会自动清理过期的缓存
		 */
		private var periodTimer:Timer;

		/**
		 * 类和类new出的对象缓存
		 * 通过此缓存可以控制Class,new了来的对象数量,不过麻烦的是需要put和get
		 * @param aCapacity 容量，即能缓存的最大个数，0表示无限容量
		 * @param periodTime 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
		 * @param expireTime 过期时间，对象放入跟椐此时间判断过期，过期对象并不会马上移除而是一定周期后移除
		 */
		public function ClassObjectPool(aCapacity:int=100,periodTime:int=60000,expireTime:int=60000)
		{
			cacheMap = {};
			cacheLink = new Vector.<ICacheInfo>();
			clearPeriod = periodTime;
			expired = expireTime;
			_capacity = aCapacity;
		}
		
		/**
		 * 用于存储已经放入池里面的对象
		 */
		private var objLs:Array = [];
		
		/**
		 * 将类生成的应实例对象放入缓存池
		 * @param obj 要存到池里面的对象
		 * @param key 存的对象主键，如果为空则会以obj对象的反射路径做为主键放入
		 */
		public function putInPool(obj:Object,key:String=null):void
		{
			if(obj == null)
				return;
			if(obj is Class) 
				throw new Error("只能放入class创建出来的实例对象,不能放入class");
			
			// 如果对象已经在池里了则不处理
			if(objLs.indexOf(obj)>=0)
				return;
			
			var clsName:String;
			if(key && key.length)
				clsName = key;
			else
				clsName = changeClassName(obj);
			
			var arr:Array = cacheMap[clsName];
			if(!arr)
				arr = cacheMap[clsName] = [];
			
			if(obj is IRecycle)
				(obj as IRecycle).dispose();
			
			var poolInf:ICacheInfo = newPoolInf(clsName,obj);
			
			arr.push(poolInf);
			cacheLink.push(poolInf);
			objLs.push(obj);
			
			// 超出长度要清缓存
			lruRemoveCache();
		}
		
		/**
		 * 新建缓存信息对象
		 * @param obj 要缓存的对象
		 * @param expired 过期时间
		 */
		protected function newPoolInf(keyName:String,obj:Object):ICacheInfo
		{
			var poolInf:ICacheInfo = new CacheInfo();
			poolInf.setBody(obj);
			poolInf.setKeyName(keyName);
			poolInf.setExpired(expired);
			poolInf.setUpdateTime(getTimer());
			poolInf.setCount(0);
			return poolInf;
		}
		
		/**
		 * 超出缓存的数量就开始移出
		 */
		protected function lruRemoveCache():void
		{
			while(cacheLink.length>capacity)
			{
				var resObj:ICacheInfo = cacheLink[cacheLink.length-1];
				if(resObj.getBody() is BitmapData && diposeBitmapDate)
					(resObj.getBody() as BitmapData).dispose();
				removePoolInf(resObj);
			}
		}
		
		/**
		 * 从池里删除某对象
		 * @param resObj
		 */
		private function removePoolInf(resObj:ICacheInfo):void
		{
			resObj.setBody( null );
			var clsName:String = resObj.getKeyName();
			resObj.dispose();
			var arr:Array = cacheMap[clsName];
			if(!arr && arr.length == 0)
			{
				trace("无此缓存，删除失败");
				return;
			}
			arr.splice(arr.indexOf(resObj), 1)[0];
			objLs.splice(objLs.indexOf(resObj.getBody()), 1)[0];
			
			var linkId:int = cacheLink.indexOf(resObj);
			cacheLink.splice(linkId, 1)[0];
			
			if(arr.length == 0)
			{
				cacheMap[clsName] = null;
				delete cacheMap[clsName];
			}
		}
		
		/**
		 * 通过对象或者Class获取类名(Class和new Cls两对象的qualified名是一样的)
		 * @param classKey 如果是Class对象将会取其反射路径为主键，如果是String则直接可做为主键
		 */
		private function changeClassName(classKey:Object):String
		{
			if(classKey is String || classKey is Number)
				return String(classKey);
			
			return  getQualifiedClassName(classKey);
		}
		
		/**
		 * 通过类型或者主键名从池里取出对象的实例
		 * @param claKey 类类型,或者主键名
		 * @param key 存的对象主键，如果为空则会以obj对象的反射路径去查对象
		 * @return 
		 */
		public function getObj(claKey:Object,key:String=null):*
		{
			if(key==null)
				var clsName:String = changeClassName(claKey);
			else
				clsName = key;
			var arr:Array = cacheMap[clsName];
			if(arr && arr.length>0)
			{
				var resObj:ICacheInfo = arr[0];
				var res:* = resObj.getBody();
				removePoolInf(resObj);
				return res;
			}
			return null;
		}
		
		/**
		 * 通过Class从缓存池里面取对象，池里不存在则new一个
		 * @param claKey 必须是类类型
		 * @param params
		 */
		public function getAndCreateObj(claKey:Class,params:Array=null):*
		{
			var res:* = getObj(claKey);
			if(!res)
				return construct(claKey,params);
			
			if(res is IReset)
				(res as IReset).reset();
			
			return res;
		}
		
		/**
		 * 回收时是否销毁位图
		 */
		public var diposeBitmapDate:Boolean = true;
		
		/**
		 * 清除一次过期过象
		 */
		public function clearExpired():void
		{
			if(cacheLink.length==0) return;
			var poolInf:ICacheInfo = cacheLink[cacheLink.length-1] as ICacheInfo;
			// 过期的时间点
			var pTime:int = poolInf.getUpdateTime() + poolInf.getExpired();
			// 过期时间点比当前时间大表示该缓存已过期
			// 例如过期时间是8点，而当前时间是9点，则对象过期，要清除
			while(pTime<getTimer() && cacheLink.length>0)
			{
				if(poolInf.getBody() is BitmapData && diposeBitmapDate)
					(poolInf.getBody() as BitmapData).dispose();
				removePoolInf(poolInf);
				
				if(cacheLink.length==0)
					break;
				
				poolInf = cacheLink[cacheLink.length-1];
				pTime = poolInf.getUpdateTime() + poolInf.getExpired();
			}
		}
		
		/**
		 * 清除所有缓存
		 */
		public function removeAllCache():void
		{
			while(cacheLink.length)
			{
				var resObj:ICacheInfo = cacheLink[cacheLink.length-1];
				if(resObj.getBody() is BitmapData && diposeBitmapDate)
					(resObj.getBody() as BitmapData).dispose();
				
				removePoolInf(resObj);
			}
			cacheMap = {};
			objLs = [];
			cacheLink = new Vector.<ICacheInfo>();
		}
		
		/**
		 * 移除周期时间
		 */
		public function removeTimer():void
		{
			if(periodTimer)
				periodTimer.removeEventListener(TimerEvent.TIMER,onClearTime);
			periodTimer = null;
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
		 * @private
		 */
		public function set capacity(value:int):void
		{
			super.capacity = value;
			lruRemoveCache();
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
			if(value==0)
				return;
			
			periodTimer = new Timer(_clearPeriod);
			periodTimer.addEventListener(TimerEvent.TIMER,onClearTime);
		}

		/**
		 * 过期时间，每个对象放进来的时间点+此时间来判断对象是否过期
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
		
		public function dispose():void
		{
			removeAllCache();
			removeTimer();
		}
		
		/**
		 * 根据参数反射构造实例
		 */
		public function construct(type:Class, parameters:Array):*
		{
			if(!parameters) return new type();
			switch( parameters.length )
			{
				case 0:
					return new type();
				case 1:
					return new type( parameters[0] );
				case 2:
					return new type( parameters[0], parameters[1] );
				case 3:
					return new type( parameters[0], parameters[1], parameters[2] );
				case 4:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3] );
				case 5:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4] );
				case 6:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]
						, parameters[5] );
				case 7:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]
						, parameters[5], parameters[6] );
				case 8:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]
						, parameters[5], parameters[6], parameters[7] );
				case 9:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]
						, parameters[5], parameters[6], parameters[7], parameters[8] );
				case 10:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]
						, parameters[5], parameters[6], parameters[7], parameters[8], parameters[9] );
				default:
					return null;
			}
		}
		
		//---------------------------------------------------
		// 事件
		//---------------------------------------------------
		
		/**
		 * 周期清除过期对象
		 * @param e
		 */
		private function onClearTime(e:TimerEvent):void
		{
			clearExpired();
		}
	}
}