package utils.tools
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class BitmapTool
	{
		/**
		 * 绘制一个位图。这个位图能确保容纳整个图像。
		 * 
		 * @param displayObj
		 * @return Bitmap
		 * 
		 */
		public static function toBitmap(obj:DisplayObject,scale:Number=1):Bitmap
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
		public static function toBitmapData(displayObj:DisplayObject,scale:Number=1):BitmapData
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
			var bitmap:BitmapData = new BitmapData(rect.width,rect.height,true,0);
//			var bitmap:BitmapData = new BitmapData((rect.width+2),(rect.height+2),true,0);
			bitmap.draw(displayObj,m);
			return bitmap;
		}
		
		/**
		 * 大显示对象转位图(原显示对象会先缩小到限制的像素转位图，然后再拉申)
		 */
		public static function toBigBitmap(dsp:DisplayObject,owidth:int=0,oheight:int=0):DisplayObject
		{
			if(owidth <= 0)
				owidth = dsp.width;
			if(oheight <= 0)
				oheight = dsp.height;
			// 单个bitmapdata的宽高最大像素值
			var maxPix:int = 2800;
			if(owidth < maxPix && oheight < maxPix)
				return toBitmap(dsp);
			
			// 计算长宽要分成几分
			var bsw:int = Math.ceil(owidth / maxPix);
			var bsh:int = Math.ceil(oheight / maxPix);
			
			// 每一份的长宽
			var aw:Number = owidth / bsw;
			var ah:Number = oheight / bsh;
			
			var rect:Rectangle = new Rectangle();
			rect.width = aw;
			rect.height = ah;
			
			var oldRect:Rectangle = dsp.scrollRect;
			
			var sp:Sprite = new Sprite();
			for (var i:int = 0; i < bsw; i++) 
			{
				for (var j:int = 0; j < bsh; j++) 
				{
					var bmpd:BitmapData = new BitmapData(aw,ah,true,0x000000);
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
		public static function scale(source:BitmapData,scaleX:Number =1.0,scaleY:Number = 1.0):BitmapData
		{
			var result:BitmapData = new BitmapData(source.width * scaleX,source.height * scaleY,true,0);
			var m:Matrix = new Matrix();
			m.scale(scaleX,scaleY);
			result.draw(source,m);
			return result;
		}
		
		
		public static function mcToBitmap(mc:MovieClip,perWidth:int,perHeight:int,
										  startSuffix:String="_start",endSuffix:String="_end"):Object
		{
			var bmdObj:Object = [],tArr:Array;
			for(var i:int=1;i<=mc.totalFrames;i++){
				mc.gotoAndStop(i);
				if(isLast(mc.currentFrameLabel,startSuffix)){
					tArr = [];
					bmdObj[delStr(mc.currentFrameLabel,startSuffix)] = tArr;
				}
				var bmd:BitmapData = new BitmapData((perWidth),(perHeight+50),true,0);
				var m:Matrix = new Matrix();
				m.translate((perWidth/2),(perHeight));
				bmd.draw(mc,m);
				tArr.push(bmd);
				if(isLast(mc.currentFrameLabel,endSuffix)) tArr = null;
			}
			return bmdObj;
			
			// 判断suffix字符串是否是str的后缀
			function isLast(str:String,suffix:String):Boolean
			{
				if(!str) return false;
				return str.lastIndexOf(suffix)==(str.length-suffix.length);
			}
		}
		
		
		/**
		 * 删除字符串里第一个匹配的字符串refStr
		 * 如str = "123455"; str = delstr(str,"345");
		 * 输出str为 125;
		 * @param srcStr
		 * @param refStr
		 */
		public static function delStr(srcStr:String,refStr:String):String
		{
			var s1:String = srcStr.substring(0,srcStr.indexOf(refStr));
			var s2:String = srcStr.substring((s1.length+refStr.length),srcStr.length);
			return s1+s2;
		}
		
		/**
		 * 清除位图内容 
		 * 
		 * @param source
		 */
		public static function clear(source:BitmapData):void
		{
			source.fillRect(source.rect,0);
		}
		
		/**
		 * 获取位图的非透明区域，可以用来做图片按钮的hitArea区域
		 * 
		 * @param source	图像源
		 * @return 
		 * 
		 */
		public static function getMask(source:BitmapData):Shape
		{
			var s:Shape = new Shape();
			s.graphics.beginFill(0);
			for(var i:int = 0;i < source.width;i++)
			{
				for(var j:int = 0;j < source.height;j++)
				{
					if (source.getPixel32(i,j))
						s.graphics.drawRect(i,j,1,1);
				}
			}
			s.graphics.endFill();
			return s;
		}
		
		/**
		 * 回收一个数组内所有的BitmapData
		 *  
		 * @param bitmapDatas
		 * 
		 */
		public static function dispose(items:Array):void
		{
			for each (var item:* in items)
			{
				if (item is BitmapData)
					(item as BitmapData).dispose();
					
				if (item is Bitmap)
				{
					(item as Bitmap).bitmapData.dispose();
					if ((item as Bitmap).parent)
						(item as Bitmap).parent.removeChild(item as Bitmap);
				}
			}
		}
	}
}