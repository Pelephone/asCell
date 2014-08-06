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
package bitmapEngine
{
	import astar.TileNode;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * 防魔兽的地图背景数据拼接
	 * 传入的位图图片要求用以下格式放
	 * [
		[0,4,8,12],
		[1,5,9,13],
		[2,6,10,14],
		[3,7,11,15],
		];
	 * 思路修改于 http://www.cnblogs.com/pelephone/p/mapedit_black.html
	 * @author Pelephone
	 */
	public class MapSliceConnectBg extends Bitmap
	{
		public function MapSliceConnectBg()
		{
			super()
		}
		
		private var _source:BitmapData;

		/**
		 * 背景源显示
		 */
		public function get source():BitmapData
		{
			return _source;
		}

		/**
		 * @private
		 */
		public function set source(value:BitmapData):void
		{
			if(_source == value)
				return;
			_source = value;
			
			if(!value)
				return;

			// 先把旧数据移除
			if(sliceImgLs.length)
			{
				for each (var itm:BitmapData in sliceImgLs) 
					itm.dispose();
				sliceImgLs = new Vector.<BitmapData>();
			}
			
			var rect:Rectangle = new Rectangle(0,0,sliceWidth,sliceHeight);
			var dpt:Point = new Point();
			for (var i:int = 0; i < 4; i++) 
			{
				for (var j:int = 0; j < 4; j++) 
				{
					var itmbd:BitmapData = new BitmapData(sliceWidth,sliceHeight);
					rect.x = i*sliceWidth;
					rect.y = j*sliceHeight;
					itmbd.copyPixels(value,rect,dpt);
					sliceImgLs.push(itmbd);
				}
			}
		}
		
		/**
		 * 每一切片宽
		 */
		public var sliceWidth:int = 50;
		/**
		 * 每一切片高
		 */
		public var sliceHeight:int = 50;
		
		/**
		 * 位图数据宽
		 */
		public var bmpdWidth:int = 1500;
		/**
		 * 位图数据高
		 */
		public var bmpdHeight:int = 1500;

		/**
		 * 暂时存切好的切片数组
		 */
		private var sliceImgLs:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		/**
		 * 格映射
		 */
		private var nodeMap:Object = {};
		
		/**
		 * 通过格映射数据创建背景
		 * @param tileMap
		 */
		public function createByTiles(tileMap:Object):void
		{
			this.nodeMap = tileMap;
			tileOtherMap = new Object();
			if(bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			var bmpd:BitmapData = new BitmapData(bmpdWidth,bmpdHeight);
			var rect:Rectangle = new Rectangle(0,0,sliceWidth,sliceHeight);
			var dPt:Point = new Point();
			for each (var tn:TileNode in tileMap) 
				doNode(tn);

			for each (var itmls:Vector.<int> in tileOtherMap) 
			{
				var b:int = itmls[0] + itmls[1] + itmls[2] + itmls[3];
				if(b == 0)
					continue;
				if(b > 15)
					b = 15;
				dPt.x = itmls[4] * sliceWidth;
				dPt.y = itmls[5] * sliceHeight;
				bmpd.copyPixels(sliceImgLs[b],rect,dPt,null,null,true);
			}
			
			bitmapData = bmpd;
		}
		
		/**
		 * 处理节点四周位置数据
		 */
		private function doNode(tn:TileNode):void
		{
			var ols:Vector.<int> = getTileOthers(tn.tx,tn.ty);
			if(ols[3] != 4)
				ols[3] += 4;
			ols = getTileOthers(tn.tx+1,tn.ty);
			if(ols[1] != 8)
				ols[1] += 8;
			ols = getTileOthers(tn.tx,tn.ty+1);
			if(ols[2] != 1)
				ols[2] += 1;
			ols = getTileOthers(tn.tx+1,tn.ty+1);
			if(ols[0] != 2)
				ols[0] += 2;
		}
		
		private var tileOtherMap:Object;
		
		/**
		 * 获取其它参数数据
		 */
		private function getTileOthers(tx:int,ty:int):Vector.<int>
		{
			var key:String = tx + '-' + ty;
			if(!(key in tileOtherMap))
			{
				var ls:Vector.<int> = new <int>[0,0,0,0,tx,ty];
				tileOtherMap[key] = ls;
			}
			return tileOtherMap[key] as Vector.<int>;
		}
	}
}