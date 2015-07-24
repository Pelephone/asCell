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
package asCachePool;

import asCachePool.interfaces.ICacheInfo;
import asCachePool.interfaces.IRecycle;
import asCachePool.interfaces.IReset;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;


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
class ClassObjectPool
{
	inline public static var DEFAULT_CACHE_CAPACITY:Int = 500;		//默认缓存容量
	
	/**
	 * 不缓存项
	 */
	inline public static var NO_ITEM_CACHE:Int = -1;
	/**
	 * 自动缓存项(数据最大长度缓存项)
	 */
	inline public static var AUTO_ITEM_CACHE:Int = 0;
	
	/**
	 * 缓存的哈希对象主键是class转字符串<String,<Vector.<PoolInfo>>>
	 */
	private var cacheMap:Map<String,Array<ICacheInfo>>;
	/**
	 * 对象链表.双链表形式管理LRU缓存对象
	 */
	private var cacheLink:Array<ICacheInfo>;

	/**
	 * 类和类new出的对象缓存
	 * 通过此缓存可以控制Class,new了来的对象数量,不过麻烦的是需要put和get
	 * @param aCapacity 容量，即能缓存的最大个数，0表示无限容量
	 * @param periodTime 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
	 * @param expireTime 过期时间，对象放入跟椐此时间判断过期，过期对象并不会马上移除而是一定周期后移除
	 */
	public function new(aCapacity:Int=100,periodTime:Int=60000,expireTime:Int=60000)
	{
		cacheMap = new Map < String, Array<ICacheInfo> > ();
		cacheLink = new Array<ICacheInfo>();
		setClearPeriod(periodTime);
		setExpired(expireTime);
		_capacity = aCapacity;
	}
	
	/**
	 * 用于存储已经放入池里面的对象
	 */
	private var objLs:Array<Dynamic> = [];
	
	/**
	 * 将类生成的应实例对象放入缓存池
	 * @param obj 要存到池里面的对象
	 * @param key 存的对象主键，如果为空则会以obj对象的反射路径做为主键放入
	 */
	public function putInPool(obj:Dynamic,key:String=null)
	{
		if(obj == null)
			return;
		
		// 如果对象已经在池里了则不处理
		if(objLs.indexOf(obj)>=0)
			return;
		
		var clsName:String;
		if(key!=null && key.length>0)
			clsName = key;
		else
			clsName = changeClassName(obj);
		
		var arr:Array<ICacheInfo> = cacheMap.get(clsName);
		if(arr == null)
		{
			arr = [];
			cacheMap.set(clsName, arr);
		}
		
		if(Std.is(obj,IRecycle))
			(cast obj).dispose();
		
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
	function newPoolInf(keyName:String,obj:Dynamic):ICacheInfo
	{
		var poolInf:ICacheInfo = new CacheInfo();
		poolInf.setBody(obj);
		poolInf.setKeyName(keyName);
		poolInf.setExpired(getExpired());
		poolInf.setUpdateTime(getTimer());
		poolInf.setCount(0);
		return poolInf;
	}
	
	/**
	 * 超出缓存的数量就开始移出
	 */
	function lruRemoveCache()
	{
		while(cacheLink.length>_capacity)
		{
			var resObj:ICacheInfo = cacheLink[cacheLink.length-1];
			if(Std.is(resObj.getBody() , BitmapData) && diposeBitmapDate)
				(cast resObj.getBody()).dispose();
			removePoolInf(resObj);
		}
	}
	
	/**
	 * 从池里删除某对象
	 * @param resObj
	 */
	private function removePoolInf(resObj:ICacheInfo)
	{
		var bdy:Dynamic = resObj.getBody();
		resObj.setBody( null );
		var clsName:String = resObj.getKeyName();
		resObj.dispose();
		var arr:Array<ICacheInfo> = cacheMap.get(clsName);
		if (arr == null && arr.length == 0)
		{
			trace("无此缓存，删除失败");
			return;
		}
		arr.splice(arr.indexOf(resObj), 1)[0];
		objLs.splice(objLs.indexOf(bdy), 1)[0];
		
		var linkId:Int = cacheLink.indexOf(resObj);
		cacheLink.splice(linkId, 1)[0];
		
		if(arr.length == 0)
		{
			cacheMap.set(clsName,null);
			cacheMap.remove(clsName);
		}
	}
	
	/**
	 * 通过对象或者Class获取类名(Class和new Cls两对象的qualified名是一样的)
	 * @param classKey 如果是Class对象将会取其反射路径为主键，如果是String则直接可做为主键
	 */
	private function changeClassName(classKey:Dynamic):String
	{
		if(Std.is(classKey,String) || Std.is(classKey,Float) || Std.is(classKey,Int))
		return Std.string(classKey);
		
		if (Std.is(classKey, Class))
		return Type.getClassName(classKey);
		
		var k:Class<Dynamic> = Type.getClass(classKey);
		return Type.getClassName(k);
		//return getQualifiedClassName(classKey);
	}
	
	/**
	 * 通过类型或者主键名从池里取出对象的实例
	 * @param claKey 类类型,或者主键名
	 * @param key 存的对象主键，如果为空则会以obj对象的反射路径去查对象
	 * @return 
	 */
	public function getObj(claKey:Dynamic,key:String=null):Dynamic
	{
		var clsName:String;
		if(key==null)
		clsName = changeClassName(claKey);
		else
		clsName = key;
		var arr:Array<ICacheInfo> = cacheMap.get(clsName);
		if(arr!=null && arr.length>0)
		{
			var resObj:ICacheInfo = arr[0];
			var res:Dynamic = resObj.getBody();
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
	public function getAndCreateObj<T>(claKey:Class<T>,params:Array<Dynamic>=null):T
	{
		var res:T = getObj(claKey);
		if(res == null)
			return construct(claKey,params);
		
		if(Std.is(res , IReset))
			(cast res).reset();
		
		return res;
	}
	
	/**
	 * 回收时是否销毁位图
	 */
	public var diposeBitmapDate:Bool = true;
	
	/**
	 * 清除一次过期过象
	 */
	public function clearExpired()
	{
		if(cacheLink.length==0) return;
		var poolInf:ICacheInfo = cacheLink[cacheLink.length-1];
		// 过期的时间点
		var pTime:Int = poolInf.getUpdateTime() + poolInf.getExpired();
		// 过期时间点比当前时间大表示该缓存已过期
		// 例如过期时间是8点，而当前时间是9点，则对象过期，要清除
		while(pTime<getTimer() && cacheLink.length>0)
		{
			if(Std.is(poolInf.getBody() , BitmapData) && diposeBitmapDate)
				(cast poolInf.getBody()).dispose();
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
	public function removeAllCache()
	{
		while(cacheLink.length>0)
		{
			var resObj:ICacheInfo = cacheLink[cacheLink.length-1];
			if(Std.is(resObj.getBody(), BitmapData) && diposeBitmapDate)
			{
				var bd:BitmapData = cast resObj.getBody();
				bd.dispose();
			}
			
			removePoolInf(resObj);
		}
		cacheMap = new Map<String,Array<ICacheInfo>>();
		objLs = [];
		cacheLink = new Array<ICacheInfo>();
	}
	
	/**
	 * 移除周期时间
	 */
	public function removeTimer()
	{
		if(periodTimer != null)
			periodTimer.removeEventListener(TimerEvent.TIMER,onClearTime);
		periodTimer = null;
	}
	
	/**
	 * 清理计时器，每隔一定时间会自动清理过期的缓存
	 */
	private var periodTimer:Timer;
	
	//////////////////////////////////
	// get/setter
	//////////////////////////////////
	
	function getTimer() :Int
	{
		return Std.int(haxe.Timer.stamp() * 1000);
	}
	
	/**
	 * 获取绘存容量(能缓存的对象个数)
	 * @return 
	 */
	public function getCapacity():Int
	{
		return _capacity;
	}
	
	/**
	 * 内存缓存最大个数,超过这个数就跟据情况移除旧数据
	 * 如果是<=0表示容量无限
	 */
	private var _capacity:Int = DEFAULT_CACHE_CAPACITY;
	
	/**
	 * @private
	 */
	public function setCapacity(value:Int)
	{
		_capacity = value;
		lruRemoveCache();
	}

	var _clearPeriod:Int = 1000 * 60;
	
	/**
	 * 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
	 */
	public function getClearPeriod():Int
	{
		return _clearPeriod;
	}

	/**
	 * 清除周期,每隔一定时间清一次过期缓存，为0表示不清理
	 * 此值为0会自动关掉过期清理功能
	 */
	public function setClearPeriod(value:Int)
	{
		_clearPeriod = value;
		removeTimer();
		if(value==0)
			return;
		
		periodTimer = new Timer(_clearPeriod);
		periodTimer.addEventListener(TimerEvent.TIMER,onClearTime);
	}

	var _expired:Int = 1000 * 60;
	
	/**
	 * 过期时间，每个对象放进来的时间点+此时间来判断对象是否过期
	 */
	public function getExpired():Int
	{
		return _expired;
	}

	/**
	 * @private
	 */
	public function setExpired(value:Int)
	{
		_expired = value;
	}
	
	public function dispose()
	{
		removeAllCache();
		removeTimer();
	}
	
	/**
	 * 根据参数反射构造实例
	 */
	public function construct<T>(type:Class<T>, parameters:Array<Dynamic>):T
	{
		if (parameters == null)
		parameters = [];
		return Type.createInstance(type,parameters);
	}
	
	//---------------------------------------------------
	// 事件
	//---------------------------------------------------
	
	/**
	 * 周期清除过期对象
	 * @param e
	 */
	private function onClearTime(e:Event)
	{
		clearExpired();
	}
}