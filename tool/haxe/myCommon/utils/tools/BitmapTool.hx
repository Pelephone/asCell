package utils.tools;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class BitmapTool
{
	/**
	 * 绘制一个位图。这个位图能确保容纳整个图像。
	 * 
	 * @param displayObj
	 * @return Bitmap
	 * 
	 */
	public static function toBitmap(obj:DisplayObject,scale:Float=1):Bitmap
	{
		if(obj == null){
			return null;
		}
		var bd:BitmapData = toBitmapData(obj,scale);
		if(bd == null){
			return null;
		}
//			else bd.draw(obj,null);
		var bm:Bitmap = new Bitmap(bd);
		bm.x = obj.x;
		bm.y = obj.y;
		return bm;
	}
	
	/**
	 * 绘制一个位图。这个位图能确保容纳整个图像。
	 * 
	 * @param displayObj
	 * @return BitmapData
	 */
	public static function toBitmapData(displayObj:DisplayObject,scale:Float=1):BitmapData
	{
		var rect:Rectangle = displayObj.getBounds(displayObj);
		rect.width = rect.width*scale;
		rect.height = rect.height*scale;
		// bitmapdata的最大宽度是2880，所以这里要做限制处理
		if(rect.width > 2000)
			rect.width = 2000;
		if(rect.width < 1)
			rect.width = 1;
		if(rect.height > 2000)
			rect.height = 2000;
		if(rect.height < 1)
			rect.height = 1;
		var m:Matrix = new Matrix();
		m.translate(-rect.x,-rect.y);
		m.scale(scale,scale);
		var bitmap:BitmapData = new BitmapData(Std.int(rect.width),Std.int(rect.height),true,0);
//			var bitmap:BitmapData = new BitmapData((rect.width+2),(rect.height+2),true,0);
		bitmap.draw(displayObj,m);
		return bitmap;
	}
	
	/**
	 * 大显示对象转位图(原显示对象会先缩小到限制的像素转位图，然后再拉申)
	 */
	public static function toBigBitmap(dsp:DisplayObject,owidth:Int=0,oheight:Int=0):DisplayObject
	{
		if(owidth <= 0)
			owidth = Std.int(dsp.width);
		if(oheight <= 0)
			oheight = Std.int(dsp.height);
		// 单个bitmapdata的宽高最大像素值
		var maxPix:Int = 2800;
		if(owidth < maxPix && oheight < maxPix)
			return toBitmap(dsp);
		
		// 计算长宽要分成几分
		var bsw:Int = Math.ceil(owidth / maxPix);
		var bsh:Int = Math.ceil(oheight / maxPix);
		
		// 每一份的长宽
		var aw:Float = owidth / bsw;
		var ah:Float = oheight / bsh;
		
		var rect:Rectangle = new Rectangle();
		rect.width = aw;
		rect.height = ah;
		
		var oldRect:Rectangle = dsp.scrollRect;
		
		var sp:Sprite = new Sprite();
		for (i in 0...bsw)
		{
			for (j in 0...bsh)
			{
				var bmpd:BitmapData = new BitmapData(Std.int(aw),Std.int(ah),true,0x000000);
				var bmp:Bitmap = new Bitmap();
				rect.x = i*aw;
				rect.y = j*ah;
				dsp.scrollRect = rect;
				bmpd.draw(dsp);
				bmp.bitmapData = bmpd;
				bmp.x = i*aw;
				bmp.y = j*ah;
				sp.addChild(bmp);
			}
		}
		dsp.scrollRect = oldRect;
		
		return sp;
	}
	
	/**
	 * 缩放BitmapData
	 * @param source
	 * @param scaleX
	 * @param scaleY
	 * @return 
	 */
	public static function scale(source:BitmapData,scaleX:Float =1.0,scaleY:Float = 1.0):BitmapData
	{
		var result:BitmapData = new BitmapData(Std.int(source.width * scaleX),Std.int(source.height * scaleY),true,0);
		var m:Matrix = new Matrix();
		m.scale(scaleX,scaleY);
		result.draw(source,m);
		return result;
	}
	
	/**
	 * 清除位图内容 
	 * 
	 * @param source
	 */
	public static function clear(source:BitmapData):Void
	{
		source.fillRect(source.rect,0);
	}
}