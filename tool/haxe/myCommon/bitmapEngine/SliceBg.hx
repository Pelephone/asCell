package bitmapEngine;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import format.SWF.Map;
import openfl.Assets;
import utils.StringUtil;

/**
 * 切片背景
 * @author ...
 */
class SliceBg extends Sprite
{

	public function new() 
	{
		super();
		
	}
	
	/**
	 * 切片路径
	 */
	public var sliceUrl:String = "asset/scene/$3/slice_$1_$2.jpg";
	
	var sliceWidth:Int = 200;
	
	var sliceHeight:Int = 200;
	
	//private var _smallUrl:String = "asset/scene/$1/thumb.jpg"
	
	// 显示矩形范围内的所有切片
	function showRect(rectPx:Rectangle) 
	{
		// 将像素矩形转换成小切片行列数
		var startSX:Int = Math.ceil(rectPx.x / sliceWidth);
		var startSY:Int = Math.ceil(rectPx.y / sliceHeight);
		var endSCol:Int = Math.ceil(rectPx.width / sliceWidth);
		var endSRow:Int = Math.ceil(rectPx.height / sliceHeight);
		
		for (i in startSX...endSCol)
		{
			for (j in startSY...endSRow)
			{
				var key:String = i + "-" + j;
				if (hasSliceKeys.indexOf(key)>=0)
				continue;
				var bmpd:BitmapData = getBmpdByCR(i, j);
				var bmp:Bitmap = setBitmapByCR(i, j, bmpd);
			}
		}
	}
	
	// 已经生成过位图的键
	var hasSliceKeys:Array<String>;
	
	// 通过行列数获取对应的切片位图数据
	function getBmpdByCR(scol:Int, srow:Int):BitmapData
	{
		var url:String = StringUtil.format(sliceUrl, [i, j]);
		return Assets.getBitmapData(url);
	}
	
	var bigSliceWidth:Int = 2800;
	var bigSliceHeight:Int = 2800;
	// 通过行列获取对应的位置块,
	// 因为bitmap最大的长宽像素是2880 所以不能简单的将bitmapdata.draw到同一个位图上
	// 可以能分多个bitmap,即大切片来draw
	function setBitmapByCR(scol:Int, srow:Int, sliceBmpd:BitmapData):Bitmap
	{
		// 大切片的宽高必须是小切片的整倍
		var bsw:Int = Math.floor(bigSliceWidth / sliceWidth);
		var bsh:Int = Math.floor(bigSliceHeight / sliceHeight);
		
		// 通过切片的x,y坐标转大切片的x,y坐标
		var btx:Int = tx / (bsw );
		var bty:Int = ty / (bsh );
		
		var key:String = btx + "-" + bty;
		var bsb:Bitmap = null;
		if(!bigSliceMap.exists(key))
		{
			bsb = new Bitmap();
			bsb.x = btx * bsw * sliceWidth;
			bsb.y = bty * bsh * sliceHeight;
			var bsbmpd:BitmapData = new BitmapData(sliceWidth*bsw,sliceHeight*bsh,true,bgColor);
			addChild(bsb);
			bigSliceMap.set(key, bsb);
		}
		else
		{
			bsb = bigSliceMap.get(key);
			bsbmpd = bsb.bitmapData;
		}
		
		var nPt:Point = new Point((tx - (btx * bsw))*sliceWidth,(ty - (bty * bsh))*sliceHeight);
		bsbmpd.copyPixels(sliceBmpd, sliceRect, nPt);
		bsb.bitmapData = bsbmpd;
		
		return bsb;
	}
	
	/**
	 * 原切片大小
	 */
	private var sliceRect:Rectangle = new Rectangle(0, 0, sliceWidth, sliceHeight);
	
	var bigSliceMap:Map<String,Bitmap>;
}