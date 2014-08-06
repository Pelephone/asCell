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
package astar
{
	
	/**
	 * 基本格数据管理
	 * @author Pelephone
	 */
	public class GridDataBase
	{
		public function GridDataBase(numCols:int=0, numRows:int=0)
		{
			setSize(numCols,numRows);
		}
		
		//---------------------------------------------------
		// 行列和初始
		//---------------------------------------------------
		
		protected var _numCols:int;
		/**
		 * 返回网格总列数
		 */
		public function get numCols():int
		{
			return _numCols;
		}
		
		/**
		 * @private
		 */
		public function set numCols(value:int):void 
		{
			if(_numCols == value)
				return;
			_numCols = value;
		}
		
		protected var _numRows:int;
		
		/**
		 * 返回网格总行数
		 */
		public function get numRows():int
		{
			return _numRows;
		}
		
		/**
		 * @private
		 */
		public function set numRows(value:int):void
		{
			if(_numRows == value)
				return;
			_numRows = value;
		}
		
		
		/** 设置网格尺寸 */
		public function setSize( numCols:int, numRows:int ):void
		{
			_numCols = numCols;
			_numRows = numRows;
			nodeLs = [];
			
			for(var i:int = 0; i < _numCols; i++)
			{
				nodeLs[i] = new Vector.<TileNode>();
				for(var j:int = 0; j < _numRows; j++)
				{
					nodeLs[i][j] = newNode(i, j);
				}
			}
		}
		
		//---------------------------------------------------
		// 节点相关
		//---------------------------------------------------
		
		/**
		 * 节点数据
		 */
		public var nodeLs:Array;
		
		// 因为以下形式转不了amf，所以注掉了,
//		public var nodeLs:Vector.<Vector.<TileNode>>;
		
		/**
		 * 所有初始好的节点数据(只get,无set也转不了amf,所以注掉)
		 * @return 
		 
		public function get nodeLs():Vector.<Vector.<TileNode>>
		{
			return _nodeLs;
		}*/
		
		/**
		 * 新一个节点
		 * @param tx
		 * @param ty
		 * @return 
		 */
		protected function newNode(tx:int,ty:int):TileNode
		{
			if(tileClass == null)
				return new TileNode(tx, ty);
			else
			{
				var t:TileNode = new tileClass();
				t.tx = tx;
				t.ty = ty;
				return t;
			}
		}
		
		/**
		 * 每个格子的节点类
		 */
		public var tileClass:Class = null;
		
		/**
		 * 通过格坐标返回对应A星节点数据
		 * @param tx 格子横轴.
		 * @param ty 格子纵轴.
		 */
		public function getTileNode(tx:int,ty:int):TileNode
		{
			if(tx<0 || ty<0 || tx>=numCols || ty>=numRows)
				return null;
			return nodeLs[tx][ty] as TileNode;
		}
		
		/**
		 * 获取某点四周一圈(八方向)的所有能走的点(无障碍的点)
		 * @param node 判断点
		 * @param l 深度.四周离判断点的距离。默认是1
		 * @return 
		 */
		public function getRoundNodes(node:TileNode,l:int=1):Vector.<TileNode>
		{
			var startX:int = (node.tx - l) < 0 ? 0 : node.tx - l;
			var endX:int = (node.tx + l) > (numCols - 1) ? (numCols - 1) : (node.tx + l);
			var startY:int = (node.ty - l) < 0 ? 0 : node.ty - l;
			var endY:int = (node.ty + l) > (numRows - 1) ? (numRows - 1) : (node.ty + l);	
			var res:Vector.<TileNode> = new Vector.<TileNode>();
			
			for(var i:int = startX; i <= endX; i++)
			{
				for(var j:int = startY; j <= endY; j++)
				{
					var testNode:TileNode = getTileNode(i, j);
					if(testNode == node || !testNode.walkable || !node.walkable ||
						!isDiagonalWalkable(node,testNode))
						continue;
					res.push(testNode);
				}
			}
			return res;
		}
		
		/** 判断两个节点的对角线路线是否可走 */
		private function isDiagonalWalkable( node:TileNode, testNode:TileNode ):Boolean
		{
			var node1:TileNode = getTileNode(node.tx,testNode.ty);
			var node2:TileNode = getTileNode(testNode.tx,node.ty);
			if(!node1.walkable && !node2.walkable)
				return false;
			else
				return true;
		}
	}
}