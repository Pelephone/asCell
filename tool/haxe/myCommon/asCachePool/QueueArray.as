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
* WITHOUT WARRANTIES 
*/
package asCachePool
{
	import flash.utils.Dictionary;
	
	/**
	 * 对象池专用的数组,有堆栈,队列功能,有删除指定节点功能; 查找和删除效率比Array高
	 * Array.splice方法,如果在数组很大,同步删次数又多的情况下会有一定的性能下降,
	 * 所以想出了这个类来优化那一点性能
	 * @author Pelephone
	 */
	public class QueueArray
	{
		public function QueueArray()
		{
		}
		
		/**
		 * 链表第一个节点
		 */
		private var firstNode:ArrayNode;
		
		/**
		 * 链表最后一个节点
		 */
		private var lastNode:ArrayNode;
		
		/**
		 * 数据和节点的映射
		 */
		private var map:Dictionary = new Dictionary();
		
		private var _length:int = 0;

		/**
		 * 长度
		 */
		public function get length():int
		{
			return _length;
		}
		
		/**
		 * 将一个或多个元素添加到链表的结尾，并返回该链表的新长度。
		 * @param obj
		 */
		public function push(obj:*):int
		{
			var curNode:ArrayNode = new ArrayNode();
			if(lastNode)
				lastNode.next = curNode;
			curNode.pre = lastNode;
			lastNode = curNode;
			curNode.body = obj;
			map[obj] = curNode;
//			if(length == 0)
//				firstNode = curNode;
			_length = _length + 1;
			return _length;
		}
		
		/**
		 * 删除链表中第一个元素，并返回该元素。
		 */
		public function shift():void
		{
			remove(firstNode.body);
		}
		
		/**
		 * 删除连表中的元素
		 * @param obj
		 */
		public function remove(obj:*):*
		{
			if(obj!=null && obj in map)
			{
				// 把要删点的上节点和下一节点连接起来,然后把自己移除
				var n:ArrayNode = map[obj] as ArrayNode;
				if(n.pre)
					n.pre.next = n.next;
				if(n.next)
					n.next.pre = n.pre;
				
				if(lastNode == n)
					lastNode = n.pre;
				else if(firstNode == n)
					firstNode = n.next;
				
				n.dispose();
				
				map[obj] = null;
				delete map[obj];
				
				_length = _length - 1;
				if(_length <= 0)
					firstNode = null;
			}
			return obj;
		}
		
		/**
		 * 获取最后一个节点
		 * @return 
		 */
		public function getLastBody():*
		{
			if(lastNode)
				return lastNode.body;
			else
				return null;
		}
		
		/**
		 * 获取第一个节点数据
		 * @return 
		 */
		public function getFirstBody():*
		{
			if(firstNode)
				return firstNode.body;
			else
				return null;
		}
	}
}

class ArrayNode
{
	public var pre:ArrayNode;
	public var next:ArrayNode;
	public var body:Object;
	
	public function dispose():void
	{
		pre = null;
		next = null;
		body = null;
	}
}