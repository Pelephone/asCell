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
package astar
{
	import asCachePool.interfaces.IRecycle;
	import asCachePool.interfaces.IReset;

	/**
	 * 一个特殊的节点数据，用于A星寻路算法<br/>
	 * 节点属性尽量不用get/set，追求最大性能
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class ANode extends TileNode implements IReset,IRecycle
	{
		/**
		 * 路径评分
		 */
		public var f:Number;
		/**
		 * 起点到该点移动损耗
		 */
		public var g:Number;
		/**
		 * 该点到终点（启发式）预计移动损耗
		 */
		public var h:Number;
		
		/**
		 * 是否在打开列表中(替换掉indexOf,提高寻路效率)
		 */
		public var openMark:int;
		/**
		 * 是否在关闭列表中(替换掉indexOf,提高寻路效率)
		 */
		public var closeMark:int;
		
		/**
		 * 父节点,上一节点
		 */
		public var parentNode:ANode;
		
		/**
		 * 相对上一节点的距离价值阶数
		 
		public var toParentCost:Number;*/
		/**
		 * 价值阶数(用于不同地形给出不同价值)
		 */
		public var costMultiplier:Number = 1.0;
		/**
		 * 周围各方向可移动的点
		 */
		public var directLinks:Vector.<TileNode>;
		/**
		 * 各方向节点对应的价值,此数组顺序同directLinks，每个位置表示方向相对此点的价值
		 */
		public var costLinks:Vector.<Number>;
		
		/**
		 * 埋葬深度 用于找障碍替代点
		 */
		public var buriedDepth:int = -1;
		
		/**
		 * 用存储到某目前点的距离，找替代点时用到
		 */
		public var distance:Number;
		
		public function ANode(x:int=0, y:int=0)
		{
			tx = x;
			ty = y;
		}
		
		public function dispose():void
		{
			parentNode = null;
			buriedDepth = -1;
			distance = 0;
			tx = 0;
			ty = 0;
			directLinks = null;
			costLinks = null;
			closeMark = 0;
			openMark = 0;
			f = 0;
			g = 0;
			h = 0;
			terrain = 0;
			walkable = true;
		}
		
		public function reset():void
		{
			dispose();
		}
	}
}