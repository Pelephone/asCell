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
	 * 格点
	 * @author Pelephone
	 */
	public class TileNode
	{
		/**
		 * X轴格坐标，列数
		 */
		public var tx:int;

		/**
		 * X轴格坐标，列数(为提高A星性能，去掉get/set)
		 
		public function get tileX():int
		{
			return _tileX;
		}

		public function set tileX(value:int):void 
		{
			_tileX = value;
		}*/
		
		/**
		 * Y轴格坐标，行数
		 */
		public var ty:int;

		/**
		 * Y轴格坐标，行数
		 
		public function get tileY():int
		{
			return _tileY;
		}

		public function set tileY(value:int):void 
		{
			_tileY = value;
		}*/
		
		/**
		 * 唯一标记,通过tileXY计算得来
		 */
		public var tilePos:int;
		
		/**
		 * 是否可通过
		 */
		public var walkable:Boolean = true;
		
		/**
		 * 地形
		 */
		public var terrain:int;
		
		public function TileNode(tlx:int=0,tly:int=0)
		{
			tx = tlx;
			ty = tly;
		}
	}
}