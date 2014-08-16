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
	import flash.geom.Point;
	
	/**
	 * 添加对A*寻路路径平滑以及点击不可移动点后寻找终点替代点的支持方法
	 * Modified by Pelephone
	 * 
	 * @author Pelephone
	 */
	public class AGridHelper
	{
		public function AGridHelper(grid:GridDataBase=null)
		{
			this.grid = grid;
//			setSize( numCols, numRows );
		}
		
		public var grid:GridDataBase;
		
		/**
		 * 对角价值
		 */
		protected var _diagCost:Number = Math.SQRT2;
		/**
		 * 直线价值
		 */
		protected var _straightCost:Number = 1.0;
		
		/**
		 * 初始四周节点,并计算节点相对价值
		 */
		public function calcDirectLinks():void
		{
			for(var i:int = 0; i < grid.numCols; i++)
			{
				for(var j:int = 0; j < grid.numRows; j++)
				{
					var aNode:ANode = getANode(i,j);
					aNode.directLinks = grid.getRoundNodes(aNode);
					
					var costLinks:Vector.<Number> = new Vector.<Number>();
					var toParentCost:Number;
					for (var k:int = 0; k < aNode.directLinks.length; k++) 
					{
						var testNode:ANode = aNode.directLinks[k] as ANode;
						if(!((aNode.tx == testNode.tx) || (aNode.ty == testNode.ty)))
						{
							toParentCost = _diagCost * testNode.costMultiplier;
//							testNode.toParentCost = _diagCost * testNode.costMultiplier;
						}
						else
						{
							toParentCost = _straightCost * testNode.costMultiplier;
//							testNode.toParentCost = _straightCost * testNode.costMultiplier;
						}
						costLinks.push(toParentCost);
					}
					aNode.costLinks = costLinks;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 
		override protected function newNode(tx:int, ty:int):TileNode
		{
			return new ANode(tx, ty);
		}*/
		
		/**
		 * 判断两节点之间是否存在障碍物 
		 * @param point1
		 * @param point2
		 * @return 
		 */		
		public function hasBarrier( startX:int, startY:int, endX:int, endY:int ):Boolean
		{
			//如果起点终点是同一个点那傻子都知道它们间是没有障碍物的
			if( startX == endX && startY == endY )
				return false;		
			if( grid.getTileNode(endX, endY).walkable == false )
				return true;
			
			//两节点中心位置
			var point1:Point = new Point( startX + 0.5, startY + 0.5 );
			var point2:Point = new Point( endX + 0.5, endY + 0.5 );
			
			var distX:Number = Math.abs(endX - startX);
			var distY:Number = Math.abs(endY - startY);	
			
			/**遍历方向，为true则为横向遍历，否则为纵向遍历*/
			var loopDirection:Boolean = distX > distY ? true : false;
			
			/**起始点与终点的连线方程*/
			var lineFuction:Function;
			
			/** 循环递增量 */
			var i:Number;
			
			/** 循环起始值 */
			var loopStart:Number;
			
			/** 循环终结值 */
			var loopEnd:Number;
			
			/** 起终点连线所经过的节点 */
			var nodesPassed:Array = [];
			var elem:ANode;
			
			//为了运算方便，以下运算全部假设格子尺寸为1，格子坐标就等于它们的行、列号
			if( loopDirection )
			{
				lineFuction = MathUtil.getLineFunc(point1, point2, 0);
				
				loopStart = Math.min( startX, endX );
				loopEnd = Math.max( startX, endX );
				
				//开始横向遍历起点与终点间的节点看是否存在障碍(不可移动点) 
				for( i=loopStart; i<=loopEnd; i++ )
				{
					//由于线段方程是根据终起点中心点连线算出的，所以对于起始点来说需要根据其中心点
					//位置来算，而对于其他点则根据左上角来算
					if( i==loopStart )
						i += .5;
					//根据x得到直线上的y值
					var yPos:Number = lineFuction(i);
					
					
					nodesPassed = getNodesUnderPoint( i, yPos );
					for each( elem in nodesPassed )
					{
						if( elem.walkable == false )
							return true;
					}
					
					if( i == loopStart + .5 )
						i -= .5;
				}
			}
			else
			{
				lineFuction = MathUtil.getLineFunc(point1, point2, 1);
				
				loopStart = Math.min( startY, endY );
				loopEnd = Math.max( startY, endY );
				
				//开始纵向遍历起点与终点间的节点看是否存在障碍(不可移动点)
				for( i=loopStart; i<=loopEnd; i++ )
				{
					if( i==loopStart )
						i += .5;
					//根据y得到直线上的x值
					var xPos:Number = lineFuction(i);
					
					nodesPassed = getNodesUnderPoint( xPos, i );
					for each( elem in nodesPassed )
					{
						if( elem.walkable == false )
							return true;
					}
					
					if( i == loopStart + .5 )
						i -= .5;
				}
			}
			
			return false;			
		}
		
		/**
		 * 得到一个点下的所有节点 
		 * @param xPos		点的横向位置
		 * @param yPos		点的纵向位置
		 * @param grid		所在网格
		 * @param exception	例外格，若其值不为空，则在得到一个点下的所有节点后会排除这些例外格
		 * @return 			共享此点的所有节点
		 */		
		public function getNodesUnderPoint( xPos:Number, yPos:Number, exception:Array=null ):Array
		{
			var result:Array = [];
			// (num%1==0)?1:0 == num&1;
			var xIsInt:Boolean = Boolean(xPos&1);
			var yIsInt:Boolean = Boolean(yPos&1);
			
			//点由四节点共享情况
			if( xIsInt && yIsInt )
			{
				result[0] = grid.getTileNode( xPos - 1, yPos - 1);
				result[1] = grid.getTileNode( xPos, yPos - 1);
				result[2] = grid.getTileNode( xPos - 1, yPos);
				result[3] = grid.getTileNode( xPos, yPos);
			}
				//点由2节点共享情况
				//点落在两节点左右临边上
			else if( xIsInt && !yIsInt )
			{
				result[0] = grid.getTileNode( xPos - 1, int(yPos) );
				result[1] = grid.getTileNode( xPos, int(yPos) );
			}
				//点落在两节点上下临边上
			else if( !xIsInt && yIsInt )
			{
				result[0] = grid.getTileNode( int(xPos), yPos - 1 );
				result[1] = grid.getTileNode( int(xPos), yPos );
			}
				//点由一节点独享情况
			else
			{
				result[0] = grid.getTileNode( int(xPos), int(yPos) );
			}
			
			//在返回结果前检查结果中是否包含例外点，若包含则排除掉
			if( exception && exception.length > 0 )
			{
				for( var i:int=0; i<result.length; i++ )
				{
					if( exception.indexOf(result[i]) != -1 )
					{
						result.splice(i, 1);
						i--;
					}
				}
			}
			
			return result;
		}
		
		public function getANode(tx:int,ty:int):ANode
		{
			return grid.getTileNode(tx,ty) as ANode;
		}
		
		/**
		 * 当终点不可移动时寻找一个离原终点最近的可移动点来替代之 
		 */
		public function findReplacer( fromTile:TileNode, toTile:TileNode ):TileNode
		{
			var fromNode:ANode = getANode(fromTile.tx,fromTile.ty);
			var toNode:ANode = getANode(toTile.tx,toTile.ty);
			var result:ANode;
			//若终点可移动则根本无需寻找替代点
			if( toNode.walkable )
			{
				result = toNode;
			}
				//否则遍历终点周围节点以寻找离起始点最近一个可移动点作为替代点
			else
			{
				//根据节点的埋葬深度选择遍历的圈
				//若该节点是第一次遍历，则计算其埋葬深度
				if( toNode.buriedDepth == -1 )
				{
					toNode.buriedDepth = getNodeBuriedDepth( toNode, Math.max(grid.numCols, grid.numRows) );
				}
				var xFrom:int = toNode.tx - toNode.buriedDepth < 0 ? 0 : toNode.tx - toNode.buriedDepth;
				var xTo:int = toNode.tx + toNode.buriedDepth > grid.numCols - 1 ? grid.numCols - 1 : toNode.tx + toNode.buriedDepth;
				var yFrom:int = toNode.ty - toNode.buriedDepth < 0 ? 0 : toNode.ty - toNode.buriedDepth;
				var yTo:int = toNode.ty + toNode.buriedDepth > grid.numRows - 1 ? grid.numRows - 1 : toNode.ty + toNode.buriedDepth;		
				
				var n:ANode;//当前遍历节点
				
				for( var i:int=xFrom; i<=xTo; i++ )
				{
					for( var j:int=yFrom; j<=yTo; j++ )
					{
						if( (i>xFrom && i<xTo) && (j>yFrom && j<yTo) )
						{
							continue;
						}
						n = getANode(i, j);
						if( n.walkable )
						{
							//计算此候选节点到起点的距离，记录离起点最近的候选点为替代点
							var dist:Number = calcDistanceTo(n,fromNode);
							n.distance = dist;
							//							n.getDistanceTo( fromNode );
							
							if( !result )
							{
								result = n;
							}
							else if( n.distance < result.distance )
							{							
								result = n;
							}
						}
					}
				}
				
			}
			return result;
		}
		
		/**
		 *  得到此节点到另一节点的网格距离
		 */
		public function calcDistanceTo(cuNode:ANode, targetNode:ANode ):Number
		{
			var disX:Number = targetNode.tx - cuNode.tx;
			var disY:Number = targetNode.ty - cuNode.ty;
			var distance:Number = Math.sqrt( disX * disX + disY * disY );
			return distance;
		}
		
		/** 
		 * 计算全部路径点的埋葬深度 
		 */
		public function calculateBuriedDepth():void
		{
			var node:ANode;
			for(var i:int = 0; i < grid.numCols; i++)
			{
				for(var j:int = 0; j < grid.numRows; j++)
				{
					node = grid.nodeLs[i][j];
					if( node.walkable )
					{
						node.buriedDepth = 0;
					}
					else
					{
						node.buriedDepth = getNodeBuriedDepth( node, Math.max(grid.numCols, grid.numRows) );
					}
				}
			}
		}
		
		
		/**
		 * 计算一个节点的埋葬深度,也可以理解为离最外层障碍的有多远 
		 * @param node		欲计算深度的节点
		 * @param loopCount	计算深度时遍历此节点外围圈数。默认值为10
		 */
		private function getNodeBuriedDepth( node:ANode, loopCount:int=10 ):int
		{
			//如果检测节点本身是不可移动的则默认它的深度为1
			var result:int = node.walkable ? 0 : 1;
			var l:int = 1;
			
			while( l <= loopCount )
			{
				var startX:int = node.tx - l < 0 ? 0 : node.tx - l;
				var endX:int = node.tx + l > grid.numCols - 1 ? grid.numCols - 1 : node.tx + l;
				var startY:int = node.ty - l < 0 ? 0 : node.ty - l;
				var endY:int = node.ty + l > grid.numRows - 1 ? grid.numRows - 1 : node.ty + l;                
				
				var n:ANode;
				//遍历一个节点周围一圈看是否周围一圈全部是不可移动点，若是，则深度加一，
				//否则返回当前累积的深度值
				for(var i:int = startX; i <= endX; i++)
				{
					for(var j:int = startY; j <= endY; j++)
					{
						n = getANode(i, j);
						if( n != node && n.walkable )
						{
							return result;
						}
					}
				}
				
				//遍历完一圈，没发现一个可移动点，则埋葬深度加一。接着遍历下一圈
				result++;
				l++;
			}
			return result;
		}
		
		
		////////////////////////////////////////
		// 废弃
		////////////////////////////////////////
		
		/**
		 * 将两个数组合体，元素不重复 
		 * @return 
		 
		 private function concatArrys( array1:Array, array2:Array ):Array
		 {
		 var index:int;
		 for( var i:int=0; i<array2.length; i++ )
		 {
		 index = array1.indexOf( array2[i] );
		 if( index == -1 )
		 {
		 array1.push( array2[i] );
		 }
		 }
		 return array1;
		 }*/	
		
		
		/**
		 * 通过格坐标返回对应节点数据
		 * @param vx 格子横轴.
		 * @param vy 格子纵轴.
		 
		 public function getNode(vx:int, vy:int):ITileNode
		 {
		 var aNode:ANode =  getANode(vx,vy);
		 return (aNode!=null)?aNode.tileNode:null;
		 }*/
		
		/**
		 * 节点数组数据
		 * @return 
		 
		 public function get nodeLs():Array
		 {
		 return _nodeLs;
		 }*/
	}
}