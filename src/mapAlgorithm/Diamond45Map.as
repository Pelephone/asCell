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
	 * Diamond方式排列的45度地图算法
	 * @author Pelephone
	 */
	public class Diamond45Map extends BaseMapAlgorithm
	{
		public function Diamond45Map(tileWidth:int=20, tileHeight:int=20)
		{
			super(tileWidth, tileHeight);
		}
		
		override public function getPixelPoint(tx:int, ty:int):Point
		{
			var pixelPt:Point = new Point();
			pixelPt.x = (tx - ty) * gridWidth/2 + oPoint.x;
			pixelPt.y = (ty + tx) * gridHeight/2 + oPoint.y;
			return pixelPt;
		}
		
		override public function getTilePoint(px:int, py:int):Point
		{
			var logic : Point = new Point;
			
			var wq:int = (px - oPoint.x);
			var hq:int = (py - oPoint.y + gridHeight/2);
			
			logic.x = Math.floor((2 * hq + wq) / gridWidth - 1) + 1;
			logic.y = Math.floor((2 * hq - wq) / (gridHeight * 2));
			
			return logic;
		}
	}
}