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
	 * Staggered方式排列的45度地图算法
	 * @author Pelephone
	 */
	public class Staggered45Map extends BaseMapAlgorithm
	{
		/**
		 * 初始默认的菱形宽高
		 * @param tileWidth
		 * @param tileHeight
		 */
		public function Staggered45Map(tileWidth:int=0, tileHeight:int=0)
		{
			super(tileWidth,tileHeight);
		}
		
		override public function getPixelPoint(tx:int, ty:int):Point
		{
			//偶数行tile中心
			var tileCenter:int = (tx * gridWidth) + gridWidth/2;
			// x象素  如果为奇数行加半个宽
			var xPixel:int = tileCenter + (ty&1) * gridWidth/2 + oPoint.x;
			
			// y象素
			var yPixel:int = (ty + 1) * gridHeight/2 + oPoint.y;
			
			return new Point(xPixel, yPixel);
		}
		
		override public function getTilePoint(px:int, py:int):Point
		{
			var xtile:int = 0;        //网格的x坐标
			var ytile:int = 0;        //网格的y坐标
			
			var cx:int, cy:int, rx:int, ry:int;
			cx = int(px / gridWidth) * gridWidth + gridWidth/2;		//计算出当前X所在的以gridWidth为宽的矩形的中心的X坐标
			cy = int(py / gridHeight) * gridHeight + gridHeight/2;	//计算出当前Y所在的以gridHeight为高的矩形的中心的Y坐标
			
			rx = (px - cx) * gridHeight/2;
			ry = (py - cy) * gridWidth/2;
			
			if (Math.abs(rx)+Math.abs(ry) <= gridWidth * gridHeight/4)
			{
				xtile = int(px / gridWidth);
				ytile = int(py / gridHeight) * 2;
			}
			else
			{
				px = px - gridWidth/2;
				xtile = int(px / gridWidth) + 1;
				
				py = py - gridHeight/2;
				ytile = int(py / gridHeight) * 2 + 1;
			}
			
			return new Point(xtile - (ytile&1), ytile);
		}
	}
}