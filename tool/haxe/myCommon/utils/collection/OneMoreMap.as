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
package utils.collection
{
	import flash.utils.Dictionary;
	
	/**
	 * 表示一对多的哈希数据
	 * Pelephone
	 */
	public class OneMoreMap
	{
		private var _map:Dictionary;
		
		/**
		 * 构造一对多哈希
		 */
		public function OneMoreMap()
		{
			_map = new Dictionary(true);
		}
		
		/**
		 * 设置一对多关系
		 * @param key
		 * @param value
		 */
		public function set(key:*, value:Array):void
		{
			_map[key] = value;
		}
		
		/**
		 * 获取键对应的多个值
		 * @param key
		 * @return 
		 */
		public function get(key:*):Array
		{
			return _map[key];
		}
		
		/**
		 * 判断键是否有映对值
		 * @param key
		 * @return 
		 */
		public function containsKey(key:*):Boolean
		{
			return _map[key] != null;
		}
		
		/**
		 * 移出一条关系
		 * @param key
		 */
		public function remove(key:*):void
		{
			_map[key] = null;
			delete _map[key];
		}
		
		/**
		 * 移出所有关系
		 */
		public function removeAll():void
		{
			_map = new Dictionary(true);
		}
		
		/**
		 * 获取关系字典
		 * @return 
		 */
		public function get map():Dictionary
		{
			return _map;
		}
		
		/**
		 * 给某一主键添加一条映对记录
		 * @param key
		 * @param value
		 */
		public function addToKey(key:*, value:*):void
		{
			var ls:Array = _map[key];
			if(!ls)
				_map[key] = ls = [];
			
			ls.push(value);
		}
		
		/**
		 * 移出某主键里的一条记录
		 * @param key
		 * @param value
		 */
		public function removeToKey(key:*,value:*):void
		{
			var ls:Array = _map[key];
			if(!ls) return;
			var tid:int = ls.indexOf(value);
			if(tid<0) return;
			ls.splice(tid,1);
		}
	}
}