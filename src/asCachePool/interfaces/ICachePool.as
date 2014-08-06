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
package asCachePool.interfaces
{
	/**
	 * 缓存池接口
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public interface ICachePool extends IRecycle
	{
		/**
		 * 将对象通过主键放入缓存池
		 * @param keyName 主键名
		 * @param body 要级存对象
		 */
		function putInCache(keyName:String, body:Object):*;
		/**
		 * 通过主键名获取池里面缓存对象
		 * @param keyName 主键名
		 */
		function getCache(keyName:String):*;
		/**
		 * 移出缓存
		 * @param keyName 主键名
		 */
		function removeCache(keyName:String):void;
		/**
		 * 池里是否有此主键名对应的缓存
		 * @param keyName 主键名
		 */
		function hasCache(keyName:String):Boolean;
		
		/**
		 * 通过详细缓存信息放入缓存池
		 * @param cacheInf 要缓存的数据信息接口
		 */
		function putCacheInfo(cacheInf:ICacheInfo):ICacheInfo;
		/**
		 * 获取详细缓存信息
		 * @param keyName 主键名
		 */
		function getCacheInfo(keyName:String):ICacheInfo;
		
		/**
		 * 清理过期缓存
		 */
		function clearExpired():void;
		/**
		 * 移出所有缓存
		 */
		function removeAllCache():void;
		
		/**
		 * 缓存容量(能缓存的对象个数)
		 * @return 
		 */
		function set capacity(value:int):void;
		function get capacity():int;
		
		/**
		 * 已缓存的量
		 * @return 
		 */
		function get size():int;
	}
}