package bitmapEngine;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import utils.StringUtil;

/**
 * 切片背景
 * @author Pelephone
 */
class SliceBg extends Sprite
{

	public function new() 
	{
		super();
		sliceRect = new Rectangle(0, 0, 200, 200);
		bigSliceMap = new Map<String,Bitmap>();
		hasSliceKeys = [];
	}
	
	/**
	 * 切片路径
	 */
	public var sliceUrl:String = "img2/bg/pic$1_$2.jpg";
	
	public function setSliceWH(sw:Int=200, sh:Int=200)
	{
		sliceRect.width = sw;
		sliceRect.height = sh;
	}
	
	//private var _smallUrl:String = "asset/scene/$1/thumb.jpg"
	
	// 显示矩形范围内的所有切片
	public function showRect(rectPx:Rectangle) 
	{
		// 将像素矩形转换成小切片行列数
		var startSX:Int = Math.ceil(rectPx.x / sliceRect.width);
		var startSY:Int = Math.ceil(rectPx.y / sliceRect.height);
		var endSCol:Int = Math.ceil(rectPx.width / sliceRect.width);
		var endSRow:Int = Math.ceil(rectPx.height / sliceRect.height);
		
		for (i in startSX...endSCol)
		{
			for (j in startSY...endSRow)
			{
				var key:String = i + "-" + j;
				if (hasSliceKeys.indexOf(key)>=0)
				continue;
				var bmpd:BitmapData = getBmpdByCR(i, j);
				trace(key,rectPx);
				setBitmapByCR(i, j, bmpd);
				hasSliceKeys.push(key);
			}
		}
	}
	
	// 已经生成过位图的键
	var hasSliceKeys:Array<String>;
	
	// 通过行列数获取对应的切片位图数据
	function getBmpdByCR(scol:Int, srow:Int):BitmapData
	{
		var url:String = StringUtil.format(sliceUrl, [scol, srow]);
		return Assets.getBitmapData(url);
	}
	
	var bigSliceWidth:Int = 2800;
	var bigSliceHeight:Int = 2800;
	
	// 通过行列获取对应的位置块,
	// 因为bitmap最大的长宽像素是2880 所以不能简单的将bitmapdata.draw到同一个位图上
	// 可以能分多个bitmap,即大切片来draw
	function setBitmapByCR(scol:Int, srow:Int, sliceBmpd:BitmapData):Void
	{
		if (sliceBmpd == null)
		return;
		var bsb:Bitmap = null;
		var key:String;
		// 如果小切片和bitmap块一样大，则直接设置bitmapdata即可
		if (bigSliceHeight <= sliceRect.height && bigSliceWidth <= sliceRect.width)
		{
			key = scol + "-" + srow;
			if (!bigSliceMap.exists(key))
			{
				bsb = new Bitmap();
				bsb.x = scol * sliceRect.width;
				bsb.y = srow * sliceRect.height;
				addChild(bsb);
				bigSliceMap.set(key, bsb);
				bsb.bitmapData = sliceBmpd;
			}
			return;
		}
		
		// 大切片(bitmap片)和小切片大小不一样，则把小切片的像素draw到对应的bitmap上面
		// 大切片的宽高必须是小切片的整倍
		var bsw:Int = Math.floor(bigSliceWidth / sliceRect.width);
		var bsh:Int = Math.floor(bigSliceHeight / sliceRect.height);
		
		// 通过切片的x,y坐标转大切片的x,y坐标
		var btx:Int = Math.floor(scol / bsw);
		var bty:Int = Math.floor(srow / bsh);
		
		key = btx + "-" + bty;
		var bsbmpd:BitmapData;
		
		if(!bigSliceMap.exists(key))
		{
			bsb = new Bitmap();
			bsb.x = btx * bsw * sliceRect.width;
			bsb.y = bty * bsh * sliceRect.height;
			addChild(bsb);
			bigSliceMap.set(key, bsb);
			bsbmpd = new BitmapData(Std.int(sliceRect.width * bsw), Std.int(sliceRect.height * bsh), true, bgColor);
			bsb.bitmapData = bsbmpd;
		}
		else
		{
			bsb = bigSliceMap.get(key);
			bsbmpd = bsb.bitmapData;
		}
		
		var nPt:Point = new Point((scol - (btx * bsw)) * sliceRect.width, (srow - (bty * bsh)) * sliceRect.height);
		bsbmpd.copyPixels(sliceBmpd, sliceRect, nPt);
	}
	
	/**
	 * 单切片大小
	 */
	private var sliceRect:Rectangle;
	/**
	 * 背景颜色
	 */
	private var bgColor:Int = 0x000000;
	
	var bigSliceMap:Map<String,Bitmap>;
}