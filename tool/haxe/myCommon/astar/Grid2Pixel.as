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
	import flash.geom.Point;
	
	
	
	/**
	 * 格与像素转换
	 * @author Pelephone
	 */
	public class Grid2Pixel
	{
		public function Grid2Pixel(tw:int=20,th:int=20)
		{
			tileWidth = tw;
			tileHeight = th;
		}
		
		/**
		 * 格数据
		 */
		public var grid:GridDataBase;
		
		//---------------------------------------------------
		// 格宽高数据
		//---------------------------------------------------
		
		private var _tileWidth:int = 20;
		
		/**
		 * 半宽
		 */
		private var _halfTileW:int = 10;
		
		/**
		 * 每格宽
		 */
		public function get tileWidth():int
		{
			return _tileWidth;
		}
		
		/**
		 * @private
		 */
		public function set tileWidth(value:int):void
		{
			if(_tileWidth == value)
				return;
//			_halfTileW = value * 0.5;
			_halfTileW = 0;
			_tileWidth = value;
		}
		
		
		private var _tileHeight:int = 20;
		
		/**
		 * 半高
		 */
		private var _halfTileH:int = 10;
		
		/**
		 * 每格高
		 */
		public function get tileHeight():int
		{
			return _tileHeight;
		}
		
		/**
		 * @private
		 */
		public function set tileHeight(value:int):void
		{
			if(_tileHeight == value)
				return;
//			_halfTileH = value * 0.5;
			_halfTileH = 0;
			_tileHeight = value;
		}
		
		//---------------------------------------------------
		// 像素和格转换方法
		//---------------------------------------------------
		
		/**
		 * 像素点映射
		 */
		private var pixelMap:Object = {};
		
		/**
		 * 像素坐标转格坐标
		 * @return 
		 */
		public function pixelToTile(px:int,py:int):TileNode
		{
			var tx:int = px/_tileWidth;
			var ty:int = py/_tileHeight;
			return grid.getTileNode(tx,ty);
		}
		
		/**
		 * 格坐标转像素坐标
		 * @param tx
		 * @param ty
		 */
		public function tileToPixel(tx:int,ty:int):Point
		{
			var res:Point = pixelMap[tx+"-"+ty];
			if(res)
				return res;
			res = new Point((tx*_tileWidth + _halfTileW),(ty*_tileHeight + _halfTileH));
			pixelMap[tx+"-"+ty] = res;
			return res;
		}
		
		/**
		 * 验证格坐标是否合法
		 * @param tx
		 * @param ty
		 */
		public function vaildNode(tx:int,ty:int):Boolean
		{
			if(tx<0 || ty<0)
				return false;
			else if(tx > grid.numCols || ty > grid.numRows)
				return false;
			else
				return true;
		}
		
		/**
		 * 格式化像素点转成点所以格的标准像素坐标
		 */
		public function formatPixel(px:int,py:int):Point
		{
			var tn:TileNode = pixelToTile(px,py);
			if(!tn)
				return null;
			return tileToPixel(tn.tx,tn.ty);
		}
		
		/**
		 * 标记转格数据
		 * @param markPos
		 * @return 
		 */
		public function markPosToTile(markPos:int):TileNode
		{
			var tx:int = int(markPos%grid.numCols);
			var ty:int = int(markPos/grid.numCols);
			return grid.getTileNode(tx,ty);
		}
		
		/**
		 * 格数据转标记数据
		 */
		public function tileToMarkPos(tx:int,ty:int):int
		{
			if(!vaildNode(tx,ty))
				return -1;
			return ty*grid.numCols + tx;
		}
	}
}