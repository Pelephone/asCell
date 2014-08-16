/**
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
* WITHOUT WARRANTIES 
*/
package asCachePool
{
	
	import flash.net.registerClassAlias;

	/**
	 * 类的别名注册器
	 * 可以通过这里给类注册别名，并通过别名创建对象，并加入池的管理
	 * 使用此工具前注册先初始化
	 * @author Pelephone
	 */
	public class ClassAliasMgr
	{
		
		//---------------------------------------------------
		// 单例
		//---------------------------------------------------
		
		/**
		 * 单例 此单例可通过覆盖重用的
		 */
		protected static var instance:ClassAliasMgr;
		
		public function ClassAliasMgr(classPool:ClassObjectPool=null)
		{
			if(instance)
				throw new Error("ClassAliasMap is singleton class and allready exists!");
			
			instance = this;
			instance.pool = classPool || instance.newClassPool();
		}
		
		/**
		 * 初始化本组件
		 */
		public static function active(classPool:ClassObjectPool=null):void
		{
			instance = new ClassAliasMgr(classPool);
		}
		
		/**
		 * 注册类别名
		 * @param aliasName 别名
		 * @param classObject 类对象
		 * @param isAmf 是否注册amf
		 */
		public static function regClassAlias(aliasName:String,classObject:Class,isAmf:Boolean=true):void
		{
			instance.map[aliasName] = classObject;
			if(isAmf)
				registerClassAlias(aliasName,classObject);
		}
		
		/**
		 * 判断是否有注册的别名
		 * @param aliasName
		 * @return 
		 */
		public static function hasClassByAlias(aliasName:String):Boolean
		{
			return instance.map.hasOwnProperty(aliasName);
		}
		
		/**
		 * 通过别名获取类,如果没注册有则返回空
		 * @param aliasName
		 * @return 
		 */
		public static function getClsByAlias(aliasName:String):Class
		{
			if(!hasClassByAlias(aliasName))
				return null;
			return instance.map[aliasName];
		}
		
		/**
		 * 通过别名实例化对象
		 * @return 
		 */
		public static function createObjectByAlias(aliasName:String,params:Array=null):Object
		{
			var cls:Class = getClsByAlias(aliasName);
			if(cls)
				return instance.pool.getAndCreateObj(cls,params);
			else
				return null;
		}
		
		/**
		 * 存类与别名的映射
		 */
		private var map:Object = {};
		
		/**
		 * 池管理
		 */
		private var pool:ClassObjectPool;
		
		/**
		 * 创建对象池，此方法用于覆盖
		 * @return 
		 */
		protected function newClassPool():ClassObjectPool
		{
			return new ClassObjectPool();
		}
	}
}