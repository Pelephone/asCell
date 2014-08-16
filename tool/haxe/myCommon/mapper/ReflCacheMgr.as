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
package mapper
{
	import asCachePool.CacheAdmin;
	import asCachePool.CacheType;
	
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	/**
	 * 反射缓存管理
	 * 此类引用了缓存工具包
	 * @author Pelephone
	 */
	public class ReflCacheMgr
	{
		private var cacheAdmin:CacheAdmin;
		
		public function ReflCacheMgr()
		{
			cacheAdmin = new CacheAdmin();
			cacheAdmin.cacheType = CacheType.CACHETYPE_MEMORY_ONLY;
		}
		
		/**
		 * 从缓存获取describeType反射对象相关信息
		 * 如果缓存中没有信息就创建一个放进去
		 */
		public static function getDescribeType(body:Object):*
		{
			var key:String = getQualifiedClassName(body);
			var classInfo:Object = getInstance().cacheAdmin.getCache(key);
			if(classInfo) return classInfo;
			classInfo = describeType(body);
			getInstance().cacheAdmin.putInCache(key,classInfo);
			return classInfo;
		}
		
		/**
		 * 单例
		 */
		private static var instance:ReflCacheMgr;
		/**
		 * 获取单例
		 */
		private static function getInstance():ReflCacheMgr
		{
			if(!instance)
				instance = new ReflCacheMgr();
			
			return instance;
		}
	}
}