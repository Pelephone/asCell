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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * 大位图
	 * as普通的Bitmap最大只支持2800长宽.所以写了这个类支持的范围无限
	 * @author Pelephone
	 */
	public class BigBitmap extends Sprite
	{
		public function BigBitmap()
		{
			super();
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		/**
		 * 单个位图块最大长宽
		 */
		protected var bmpWidth:int = 2800;
		protected var bmpHeight:int = 2800;
		
		/**
		 * 通过像素点换算对应位图
		 * @param px
		 * @param py
		 */
		protected function getBmpByPt(px:Number,py:Number):Bitmap
		{
			var tx:int = Math.floor(px/bmpWidth);
			var ty:int = Math.floor(py/bmpWidth);
			var key:String = tx + "-" + ty;
			var bmp:Bitmap = getChildByName(key) as Bitmap;
			if(!bmp)
			{
				bmp = new Bitmap();
				bmp.name = key;
				var bmpd:BitmapData = new BitmapData(bmpWidth,bmpHeight,true,0x000000);
				bmp.x = tx*bmpWidth;
				bmp.y = ty*bmpHeight;
				bmp.bitmapData = bmpd;
				addChildAt(bmp,0);
			}
			return bmp;
		}
		
		protected var tmpRect:Rectangle = new Rectangle();
		
		/**
		 * 在目标 BitmapData 对象的目标点将源图像的矩形区域复制为同样大小的矩形区域。 
		 * @param sourceBitmap 要从中复制像素的输入位图图像。 源图像可以是另一个 BitmapData 实例，也可以指当前 BitmapData 实例。  
		 * @param sourceRect 定义要用作输入的源图像区域的矩形。
		 * @param destPoint 目标点，它表示将在其中放置新像素的矩形区域的左上角。  
		 */
		public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point
								   , alphaBitmapData:BitmapData=null, alphaPoint:Point=null, mergeAlpha:Boolean=false):void

		{
			var bmp:Bitmap = getBmpByPt(destPoint.x,destPoint.y);
			var bmpd:BitmapData = bmp.bitmapData;
			var tw:Number = sourceRect.width;
			var th:Number = sourceRect.height;
			var dPt:Point = new Point();
			if((destPoint.x + sourceRect.width) > (bmp.x + bmpWidth))
			{
				tw = bmp.x + bmpWidth - destPoint.x;
				tmpRect.width = tw;
			}
			else
				tmpRect.width = sourceRect.width;
			
			if((destPoint.y + sourceRect.height) > (bmp.y + bmpHeight))
			{
				th = bmp.y + bmpHeight - destPoint.y;
				tmpRect.height = th;
			}
			else
				tmpRect.height = sourceRect.height;
			tmpRect.x = sourceRect.x;
			tmpRect.y = sourceRect.y;
			dPt.x = destPoint.x - bmp.x;
			dPt.y = destPoint.y - bmp.y;
			bmpd.copyPixels(sourceBitmapData,tmpRect,dPt,alphaBitmapData,alphaPoint,mergeAlpha);
			
			// 考虑一个源像素块要复制的范围可能经过了四个bitmap区域(bitmapdata长宽有限制,所以不会经过四个以上)
			if(tw < sourceRect.width)
			{
				dPt.x = destPoint.x - bmp.x + sourceRect.width
				dPt.y = destPoint.y - bmp.y;
				bmp = getBmpByPt(dPt.x,dPt.y);
				bmpd = bmp.bitmapData;
				tmpRect.x = sourceRect.x + tw;
				tmpRect.y = sourceRect.y;
				tmpRect.width = sourceRect.width - tw;
				tmpRect.height = sourceRect.height;
				dPt.x = 0;
				dPt.y = destPoint.y - bmp.y;
				bmpd.copyPixels(sourceBitmapData,tmpRect,dPt,alphaBitmapData,alphaPoint,mergeAlpha);
			}
			
			if(th < sourceRect.height)
			{
				dPt.x = destPoint.x;
				dPt.y = destPoint.y + sourceRect.height;
				bmp = getBmpByPt(dPt.x,dPt.y);
				bmpd = bmp.bitmapData;
				tmpRect.x = sourceRect.x;
				tmpRect.y = sourceRect.y + th;
				tmpRect.width = sourceRect.width;
				tmpRect.height = sourceRect.height - th;
				dPt.x = destPoint.x - bmp.x;
				dPt.y = 0;
				bmpd.copyPixels(sourceBitmapData,tmpRect,dPt,alphaBitmapData,alphaPoint,mergeAlpha);
			}
			
			if(th < sourceRect.height && tw < sourceRect.width)
			{
				dPt.x = destPoint.x + sourceRect.width - bmp.x;
				dPt.y = destPoint.y + sourceRect.height - bmp.y;
				bmp = getBmpByPt(dPt.x,dPt.y);
				bmpd = bmp.bitmapData;
				tmpRect.x = sourceRect.x + tw;
				tmpRect.y = sourceRect.y + th;
				tmpRect.width = sourceRect.width - tw;
				tmpRect.height = sourceRect.height - th;
				dPt.x = 0; 
				dPt.y = 0; 
				bmpd.copyPixels(sourceBitmapData,tmpRect,dPt,alphaBitmapData,alphaPoint,mergeAlpha);
			}
		}
		
		public function get bitmapData():BitmapData
		{
			var key:String = "0-0";
			var bmp:Bitmap = getChildByName(key) as Bitmap;
			if(bmp)
				return bmp.bitmapData;
			else
				return null;
		}

		/**
		 * 最左上角被引用的 BitmapData 对象。
		 * @param value
		 */
		public function set bitmapData(value:BitmapData):void
		{
			var key:String = "0-0";
			var bmp:Bitmap = getChildByName(key) as Bitmap;
			if(bmp)
				bmp.bitmapData = value;
		}
		
		/**
		 * 销毁,不用的时候要调用一次.
		 */
		public function dispose():void
		{
			while(numChildren)
			{
				var bmp:Bitmap = getChildAt(0) as Bitmap;
				if(bmp && bmp.bitmapData)
					bmp.bitmapData.dispose();
				removeChildAt(0);
			}
		}
	}
}