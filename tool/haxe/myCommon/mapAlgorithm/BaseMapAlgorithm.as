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
package mapAlgorithm
{
	import flash.geom.Point;

	/**
	 * 基本地图坐标转换算法，用于继承
	 * @author Pelephone
	 */
	public class BaseMapAlgorithm implements IMapAlgorithm
	{
		// 行列数
		protected var gridWidth:int;
		protected var gridHeight:int;
		
		/**
		 * 左上角原点
		 */
		protected var oPoint:Point = new Point(0,0);
		
		public function BaseMapAlgorithm(tileWidth:int=20, tileHeight:int=20)
		{
			setGridWH(tileWidth, tileHeight);
		}
		
		public function getPixelPoint(tx:int, ty:int):Point
		{
			var stagePt:Point = new Point();
			stagePt.x = tx * gridWidth + oPoint.x;
			stagePt.y = ty * gridHeight + oPoint.y;
			return stagePt;
		}
		
		public function getTilePoint(px:int, py:int):Point
		{
			var tilePt:Point = new Point();
			tilePt.x = Math.floor(px/gridWidth) + oPoint.x;
			tilePt.y = Math.floor(py/gridHeight) + oPoint.y;
			return tilePt;
		}
		
		public function setGridWH(tileWidth:int, tileHeight:int):void
		{
			gridWidth = tileWidth;
			gridHeight = tileHeight;
		}
		
		public function setOPoint(px:int, py:int):void
		{
			oPoint = new Point(px,py);
		}
		
		public function getOPoint():Point
		{
			return oPoint;
		}
	}
}