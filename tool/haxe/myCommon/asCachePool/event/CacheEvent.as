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
package asCachePool.event
{
	import flash.events.Event;
	
	/**
	 * 缓存事件
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class CacheEvent extends Event
	{
		/**
		 * 清理过期缓存
		 */
		public static const CLEAR_EXPIRED:String = "clear_expired";
		
		/**
		 * 移出所有缓存
		 */
		public static const REMOVE_ALL_CACHE:String = "remove_all_cache";
		
		/**
		 * 构造缓存事件
		 * @param type 事件类型
		 * @param bubbles 是否冒泡
		 * @param cancelable 是否能取消
		 */
		public function CacheEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		override public function clone():Event
		{
			return new CacheEvent(type, bubbles, cancelable);
		}
	}
}