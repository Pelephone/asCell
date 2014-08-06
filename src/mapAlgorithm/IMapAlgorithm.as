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
	 * 地图格点转换接品；像素坐标和网格坐标相互转换
	 * @author Pelephone
	 */
	public interface IMapAlgorithm
	{
		/**
		 * 设置每格的长宽
		 * @param gridWidth
		 * @param gridHeight
		 */
		function setGridWH(gridWidth:int,gridHeight:int):void;
		
		/**
		 * 设置左上原点坐标(像素坐标)
		 * @param numRow
		 * @param numCol
		 */
		function setOPoint(px:int,py:int):void;
		/**
		 * 获取原点坐标
		 * @return 
		 */
		function getOPoint():Point;
		/**
		 * 网格坐标转像素坐标
		 * @param tx
		 * @param ty
		 */
		function getPixelPoint(tx:int, ty:int):Point;
		
		/**
		 * 像素坐标转网格坐标
		 * @param px
		 * @param py
		 */
		function getTilePoint(px:int, py:int):Point;
	}
}