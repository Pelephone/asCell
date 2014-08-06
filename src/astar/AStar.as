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
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package astar
{
	/**
	 * A星寻路算法(参考，整理优化思路全都源于网络)
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class AStar
	{
//		private var _heuristic:Function = manhattan;
//		private var _heuristic:Function = euclidian;
//		private var _heuristic:Function = diagonal;
		private var _straightCost:Number = 1.0;
		private var _diagCost:Number = Math.SQRT2;

//		private var _floydPath:Array;
		
		public function AStar(grid:GridDataBase=null)
		{
			this._gridHelper = new AGridHelper(grid);
			this.grid = grid;
		}
		
		private var _grid:GridDataBase;

		public function get grid():GridDataBase
		{
			return _grid;
		}

		public function set grid(value:GridDataBase):void
		{
			if(value == _grid)
				return;
			_grid = value;
			gridHelper.grid = value;
		}
		
		private var _gridHelper:AGridHelper;

		/**
		 * 格扩展方法
		 */
		public function get gridHelper():AGridHelper
		{
			return _gridHelper;
		}
		
		/**
		 * 计算A星和平滑路径
		 * @param startNode
		 * @param endNode
		 * @return 
		 */
		public function findSmoothPath(startNode:TileNode,endNode:TileNode):Vector.<TileNode>
		{
			var path:Vector.<TileNode> = findPath(startNode,endNode);
			path = floyd(path);
			return path;
		}
		
		
		/**
		 * 判定哪个值大
		 * @param x
		 * @param y
		 * @return 
		 */
		private function justMin(x:Object, y:Object):Boolean
		{
			return x.f < y.f;
		}
		
		/**
		 * 某次计算寻路点时用于判断是否开启或关闭,每次计算完之后会自动加1。<br/>
		 * 如果节点的openMark和这个值相等则表示本次计算中打开过.用此标记可以不用重置节点数据，提升性能。
		 */
		private var markIndex:int = 1;
		
		/**
		 * 通过起点和结束点寻路
		 * @param startTile
		 * @param endTile
		 * @return 
		 */
		public function findPath(startTile:TileNode,endTile:TileNode):Vector.<TileNode>
		{
			var startNode:ANode = gridHelper.getANode(startTile.tx,startTile.ty);
			var endNode:ANode = gridHelper.getANode(endTile.tx,endTile.ty);
			
			startNode.g = 0;
			startNode.h = heuristic(startNode,endNode);
			startNode.f = startNode.g + startNode.h;
			startNode.closeMark = markIndex;
			
			var openArr:BinaryHeap = new BinaryHeap(justMin);
			
			//异步运算。当上一次遍历超出最大允许值后停止遍历，下一次从
			//上次暂停处开始继续遍历		
			var node:ANode = startNode;
			var cost:Number;
			var testNode:ANode;
			while(node != endNode)
			{
//				for each (testNode in node.directLinks) 
				for (var j:int = 0; j < node.directLinks.length; j++) 
				{
					testNode = node.directLinks[j] as ANode;
					cost = node.costLinks[j];
					// 关闭，打开都略过 (障碍在NodeGridData.getRoundNodes已经过滤了)
//					if(isOpen(test) || isClose(test))
					if(testNode.openMark == markIndex || testNode.closeMark == markIndex)
						continue;

					testNode.g = node.g + cost * node.costMultiplier;
					// 循环里面少用函数和set/get，尽最大提升效率
					var h:Number = Math.abs(testNode.tx - endNode.tx) + Math.abs(testNode.ty - endNode.ty);
//					testNode.h = heuristic(testNode,endNode);
					testNode.h = h;
					testNode.f = testNode.g + testNode.h;
					testNode.parentNode = node;
					testNode.openMark = markIndex;
					openArr.push( testNode );
					
				}// 八方向循环结束
				
				node.closeMark = markIndex;
				if(openArr.length == 0)
					return null;

				node = openArr.shift() as ANode;
				node.openMark = 0;
			}// 关闭计算结束
			
			// 跟椐关闭路径生成结果路径
			var path:Vector.<TileNode> = new Vector.<TileNode>();
			node = endNode;
			path.push(node);
			
			while(node != startNode)
			{
				node = node.parentNode;
//				path.unshift(node.tileNode);
				path.push(node);
			}
			// Array.unshift方法效率不高，所以用push之后再倒序
			path.reverse();

			markIndex = markIndex + 1;
			return path;
		}
		
		/**
		 * 判断某节点是否开启
		 * @param node
		 * @return 
		 */
		private function isOpen(node:ANode):Boolean
		{
			return node.openMark == markIndex;
		}
		
		/**
		 * 判断某节点是否关闭
		 * @param node
		 * @return 
		 */
		private function isClose(node:ANode):Boolean
		{
			return node.closeMark == markIndex;
		}
		
		/**
		 * 启发函数
		 */
		protected function heuristic(startNode:ANode,endNode:ANode):Number
		{
//			return euclidian(startNode,endNode);
//			return manhattan(startNode,endNode);
			return manhattan2(startNode,endNode);
//			return diagonal(startNode,endNode);
		}
		
		
		/** 将A星计算好后的路径再进行弗洛伊德路径平滑处理 
		 * @param path 计算好的路径
		 */
		public function floyd(path:Vector.<TileNode>):Vector.<TileNode>
		{
			if (path == null)
				return null;
			var floydPath:Vector.<TileNode> = path.concat();
			var len:int = floydPath.length;
			if (len > 2)
			{
				var vector:ANode = new ANode(0, 0);
				var tempVector:ANode = new ANode(0, 0);
				//遍历路径数组中全部路径节点，合并在同一直线上的路径节点
				//假设有1,2,3,三点，若2与1的横、纵坐标差值分别与3与2的横、纵坐标差值相等则
				//判断此三点共线，此时可以删除中间点2
				floydVector(vector, getFloyNode((len - 1),floydPath), getFloyNode((len - 2),floydPath));
				for (var i:int = floydPath.length - 3; i >= 0; i--)
				{
					floydVector(tempVector, getFloyNode((i + 1),floydPath), getFloyNode(i,floydPath));
					if (vector.tx == tempVector.tx && vector.ty == tempVector.ty)
					{
						floydPath.splice(i + 1, 1);
					} 
					else 
					{
						vector.tx = tempVector.tx;
						vector.ty = tempVector.ty;
					}
				}
			}
			//合并共线节点后进行第二步，消除拐点操作。算法流程如下：
			//如果一个路径由1-10十个节点组成，那么由节点10从1开始检查
			//节点间是否存在障碍物，若它们之间不存在障碍物，则直接合并
			//此两路径节点间所有节点。
			len = floydPath.length;
			for (i = len - 1; i >= 0; i--)
			{
				for (var j:int = 0; j <= i - 2; j++)
				{
					if ( !gridHelper.hasBarrier(getFloyNode(i,floydPath).tx, getFloyNode(i,floydPath).ty
						, getFloyNode(j,floydPath).tx, getFloyNode(j,floydPath).ty) )
					{
						for (var k:int = i - 1; k > j; k--)
						{
							floydPath.splice(k, 1);
						}
						i = j;
						len = floydPath.length;
						break;
					}
				}
			}
			return floydPath;
		}
		
		private function getFloyNode(id:int,floydPath:Vector.<TileNode>):TileNode
		{
			return floydPath[id] as TileNode;
		}
		
		private function floydVector(target:TileNode, n1:TileNode, n2:TileNode):void
		{
			target.tx = n1.tx - n2.tx;
			target.ty = n1.ty - n2.ty;
		}
		
		private function manhattan(node:ANode,endNode:ANode):Number
		{
//			return Math.abs(node.vx - endNode.vx) * _straightCost + Math.abs(node.vy + endNode.vy) * _straightCost;
			return (Math.abs(node.tx - endNode.tx) + Math.abs(node.ty + endNode.ty)) * _straightCost;
		}
		
		private function manhattan2(node:ANode,endNode:ANode):Number
		{
			return Math.abs(node.tx - endNode.tx) + Math.abs(node.ty - endNode.ty);
		}
		
		private function euclidian(node:ANode,endNode:ANode):Number
		{
			var dx:Number = node.tx - endNode.tx;
			var dy:Number = node.ty - endNode.ty;
			return Math.sqrt(dx * dx + dy * dy) * _straightCost;
		}
		
		private function diagonal(node:ANode,endNode:ANode):Number
		{
			var dx:Number = node.tx - endNode.tx < 0 ? endNode.tx - node.tx : node.tx - endNode.tx;
			var dy:Number = node.ty - endNode.ty < 0 ? endNode.ty - node.ty : node.ty - endNode.ty;
			var diag:Number = dx < dy ? dx : dy;
			var straight:Number = dx + dy;
			return _diagCost * diag + _straightCost * (straight - 2 * diag);
		}

		
	//---------------------------------------get/set functions-----------------------------//
		
		/**
		 * 网格对象，数据model层
		 
		public function set grid(value:AGridData):void
		{
			_grid = value;
		}
		
		public function get grid():AGridData 
		{
			return _grid;
		}*/
		
/*		public function get path():Array
		{
			return _path;
		}
		
		
		public function get floydPath():Array
		{
			return _floydPath;
		}
		*/
	}
}
