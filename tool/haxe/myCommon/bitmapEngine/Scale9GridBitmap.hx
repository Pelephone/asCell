package bitmapEngine;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import timerUtils.StaticEnterFrame;

/**
 * 支持9格缩放的位图(生成的位图bitmapData数据做有缓存处理)
 * @author Pelephone
 */
class Scale9GridBitmap extends Sprite
{
	public function new(sourceImg : BitmapData = null, tScale9Grid : Rectangle = null)
	{
		super();
		source = sourceImg;
		//super(null,PixelSnapping.AUTO);
		super();
		source = sourceImg;
		if(sourceImg != null)
		{
			_width = _source.width;
			_height = _source.height;
		}
		this.scale9 = tScale9Grid;
		bmpMap = new Map<Int,Bitmap>();
		setMouseEvt(false);
	}
	
	/** 下帧渲染之前用于计算长宽的图形
	var preDraw:Shape = null;
	
	function getPreDraw():Shape
	{
		if (preDraw != null)
		return preDraw;
		preDraw = new Shape();
		preDraw.graphics.beginFill(0x000000, 0);
		preDraw.graphics.drawCircle(0, 0, 1);
		preDraw.graphics.endFill();
		return preDraw;
	}*/
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------
	// Blocks
	//---------------------------------------------------------------------------------------------------------------------------------------------------

	var bmpMap:Map<Int,Bitmap>;
	
	// 通过行列数获取对应的位图数据
	function getBmpCR(c:Int, r:Int=0):Bitmap
	{
		var lid:Int = c + r * 3;
		if (bmpMap.exists(lid))
		return bmpMap.get(lid);
		var bmp:Bitmap = new Bitmap();
		bmpMap.set(lid, bmp);
		#if !html5
		bmp.smoothing = BmpRule.SMOOTH_BMP;
		#end
		addChild(bmp);
		return bmp;
	}
	
	#if !html5
	// 用draw的方式复制9切片样式
	// (此方法在对象长宽变动次数小的情况下能提升性能，例如ui背景图只是初始的时候会设一次宽高)
	private function buildScaledImage():Void
	{
		if (_source == null || _scale9 == null)
		return;
		
		var dw:Float = _width >= 0?_width:oldWidth;
		var dh:Float = _height >= 0?_height:oldHeight;
		
		if (dw < 1 || dh < 1)
		{
			visible = false;
			return;
		}
		visible = true;
		
		if (oldWidth == dw && oldHeight == dh)
		{
			setShowBmp(_source);
			return;
		}
		
		if (toBmpd!=null)
		toBmpd.dispose();
		
		toBmpd = new BitmapData(Std.int(dw), Std.int(dh),true,0);
		var _sourceImage:BitmapData = cast _source;
		
		var _grid:Rectangle = _scale9;
		var rows:Array<Int> = [0, Std.int(_grid.top), Std.int(_grid.bottom), Std.int(_sourceImage.height)];
		var cols:Array<Int> = [0, Std.int(_grid.left), Std.int(_grid.right), Std.int(_sourceImage.width)];
		var dRows:Array<Int> = [0, Std.int(_grid.top), Std.int(dh - (_sourceImage.height - _grid.bottom)), Std.int(dh)];
		var dCols:Array<Int> = [0, Std.int(_grid.left), Std.int(dw - (_sourceImage.width - _grid.right)), Std.int(dw)];

		var origin:Rectangle;
		var draw:Rectangle;
		var mat:Matrix = new Matrix();
		var col:Int = 3;
		var row:Int = 3;
		if (dw == oldWidth)
		col = 1;
		if (dh == oldHeight)
		row = 1;
		
		for (cx in 0...col)
		{
			for (cy in 0...row)
			{
				origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
				draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
				mat.identity();
				if(col != 1)
				{
					mat.a = draw.width / origin.width;
					mat.tx = draw.x - origin.x * mat.a;
				}
				else
				{
					draw.x = 0;
					draw.width = oldWidth;
				}
				if(row != 1)
				{
					mat.d = draw.height / origin.height;
					mat.ty = draw.y - origin.y * mat.d;
				}
				else
				{
					draw.y = 0;
					draw.height = oldHeight;
				}
				toBmpd.draw(_sourceImage, mat, null, null, draw, false);
			}
		}
		
		setShowBmp(toBmpd);
	}
	
	var toBmpd:BitmapData;
	#end
	
	function setShowBmp(bd:BitmapData):Void 
	{
		var showBmp:Bitmap = getBmpCR(0);
		showBmp.bitmapData = bd;
	}
	
	// 是否需要建立切片
	var needBuildSlice:Bool = true;
	
	// 建立切片
	function buildSlice()
	{
		clearBmp();
		
		if (_source == null || _scale9 == null)
		return;
		
		if ((oldWidth == _width && oldHeight == _height) || (_width < 0 && _height < 0))
		{
			setShowBmp(_source);
			return;
		}
		
		// 左中右格子宽,x坐标数据
		var xAry:Array<Float> = [0,_scale9.x,(_scale9.width + _scale9.x)];
		var widthAry:Array<Float> = [_scale9.x,_scale9.width,(_source.width - _scale9.x - _scale9.width)];
		// 上中下格子高,y坐标数据
		var yAry:Array<Float> = [0,_scale9.y,(_scale9.height + _scale9.y)];
		var heightAry:Array<Float> = [_scale9.y,_scale9.height,(_source.height - _scale9.y - _scale9.height)];

		var pt:Point = new Point(0, 0);
		var col:Int = xAry.length;
		var row:Int = yAry.length;
		if (_width == oldWidth || _width < 0)
		col = 1;
		if (_height == oldHeight || _height < 0)
		row = 1;
		
		for (j in 0...row)
		{
			var ty:Float = yAry[j];
			var th:Float = heightAry[j];
			for (i in 0...col) 
			{
				var bmp:Bitmap = getBmpCR(i , j);
				var tx:Float = xAry[i];
				var tw:Float = widthAry[i];
				var bd:BitmapData;
				
				if (col == 1)
				{
					tx = 0;
					tw = oldWidth;
				}
				if (row == 1)
				{
					ty = 0;
					th = oldHeight;
				}
				
				bd = new BitmapData(Std.int(tw), Std.int(th));
				bd.copyPixels(_source, new Rectangle(tx, ty, tw, th), pt);
				
				bmp.bitmapData = bd;
				bmp.x = tx;
				bmp.y = ty;
			}
		}
		needBuildSlice = false;
		resizeDraw();
	}
	
	// 跟据长宽重设切片
	private function resizeDraw()
	{
		if (source == null || _scale9 == null)
		return;
		
		var rightWidth:Float = oldWidth - _scale9.x - _scale9.width;
		var bottomHeight:Float = oldHeight - _scale9.y - _scale9.height;
		
		var dw:Float = _width >= 0?_width:oldWidth;
		var dh:Float = _height >= 0?_height:oldHeight;
		
		var sx:Float = _scale9.x;
		var sy:Float = _scale9.y;
		var smw:Float = dw - oldWidth + _scale9.width;
		var smh:Float = dh - oldHeight + _scale9.height;
		var nw:Float = oldWidth - _scale9.width;
		var nh:Float = oldHeight - _scale9.height;
		if (dw < nw)
		{
			sx = dw * 0.5;
			smw = 0;
			rightWidth = dw * 0.5;
		}
		if(dh < nh)
		{
			sy = dh * 0.5;
			smh = 0;
			bottomHeight = dh * 0.5;
		}
		
		var xAry:Array<Float> = [0,sx,(dw - rightWidth)];
		var widthAry:Array<Float> = [sx,smw,rightWidth];
		var yAry:Array<Float> = [0,sy,(dh - bottomHeight)];
		var heightAry:Array<Float> = [sy, smh, bottomHeight];
		
		//var xAry:Array<Float> = [0,_scale9.x,(dw - rightWidth)];
		//var widthAry:Array<Float> = [_scale9.x,(dw - _scale9.x - rightWidth),rightWidth];
		//var yAry:Array<Float> = [0,_scale9.y,(dh - bottomHeight)];
		//var heightAry:Array<Float> = [_scale9.y, (dh - _scale9.y - bottomHeight), bottomHeight];
		
		var col:Int = xAry.length;
		var row:Int = yAry.length;
		if (dw == oldWidth)
		col = 1;
		if (dh == oldHeight)
		row = 1;

		for (j in 0...row)
		{
			var ty:Float = yAry[j];
			var th:Float = heightAry[j];
			for (i in 0...col) 
			{
				var bmp:Bitmap = getBmpCR(i , j);
				var tx:Float = xAry[i];
				var tw:Float = widthAry[i];
				
				if (col == 1)
				{
					tx = 0;
					tw = oldWidth;
				}
				if (row == 1)
				{
					ty = 0;
					th = oldHeight;
				}
				
				bmp.x = tx;
				bmp.y = ty;
				if(tw != bmp.width)
				bmp.width = tw;
				if(j==1)
				bmp.height = th;
			}
		}
	}
	
	/**
	 * 重设九宫格位图数据
	 */
	function drawBmpd()
	{
		if (_source == null || _scale9 == null)
		return;
		
		oldWidth = _source.width;
		oldHeight = _source.height;
		
		#if html5
			StaticEnterFrame.addNextCall(buildSlice);
		#else
		
			if (isMoreBmp)
			StaticEnterFrame.addNextCall(buildSlice);
			else
			calcRessize();
			
		#end
	}
	
	
	/**
	 * 未拉申时的宽度
	 */
	private var oldWidth:Int = 0;
	
	/**
	 * 未拉申时的高度
	 */
	private var oldHeight:Int = 0;
	
	/**
	 * 9切片
	 */
	public var scale9(get,set):Rectangle;
	var _scale9:Rectangle;
	
	function get_scale9():Rectangle
	{
		return _scale9;
	}
	
	function set_scale9(value:Rectangle):Rectangle
	{
		if (_scale9 == value)
		return _scale9;
		_scale9 = value;
		needBuildSlice = true;
		drawBmpd();
		return _scale9;
	}
	
	/**
	 * 是否开启下帧渲染模式提升性能(开启后不能马上得到对象正确宽高)
	 */
	public var isNextDraw:Bool = true;
	
	/**
	 * 用多个位图显示9切片 (图像宽高变化不频繁的话这个字段设为false可提高性能)
	 */
	public var isMoreBmp:Bool = false;
	
	function calcRessize()
	{
		#if html5
			if (needBuildSlice)
			StaticEnterFrame.addNextCall(buildSlice);
			else
			resizeDraw();
		#else
		
		if (isMoreBmp)
		{
			if (needBuildSlice)
			StaticEnterFrame.addNextCall(buildSlice);
			else
			resizeDraw();
		}
		else
		{
			if(isNextDraw)
			StaticEnterFrame.addNextCall(buildScaledImage);
			else
			buildScaledImage();
		}
		
		#end
	}
	
	//---------------------------------------------------
	// 其它get/set
	//---------------------------------------------------
	
	/**
	 * 显示数据源
	 */
	public var source(get,set):BitmapData;
	var _source:BitmapData;
	
	function get_source():BitmapData
	{
		return _source;
	}
	
	function set_source(value:BitmapData):BitmapData
	{
		if (_source == value)
		return _source;
		_source = value;
		needBuildSlice = true;
		
		if (autoScaleRect && value != null && scale9 == null)
		{
			var dx:Int = Std.int(value.width * 0.33333);
			var dy:Int = Std.int(value.height * 0.33333);
			var rct:Rectangle = new Rectangle(dx, dy, dx, dy);
			_scale9 = rct; 
		}
		drawBmpd();
		return _source;
	}
	
	/**
	 * 自动三等分9切片矩形
	 */
	public var autoScaleRect:Bool = true;
	
	/**
	 * 皮肤id
	 */
	public var bgSrc(get,set):String;
	var _bgSrc:String;
	function get_bgSrc():String
	{
		return _bgSrc;
	}
	function set_bgSrc(value:String):String
	{
		if (_bgSrc == value)
		return _bgSrc;
		_bgSrc = value;
		_source = null;
		if (_bgSrc != null)
			source = Assets.getBitmapData(_bgSrc);
		
		return _bgSrc;
	}
	
	
	var _width:Float = -1;
	@:setter(width)
	#if flash
	private function set_width(value:Float)
	#else
	override function set_width(value:Float):Float
	#end
	{
		if(value == _width)
		return#if !flash _width #end;
	
		var rw:Float = _width;

		_width = value;
		
		if (rw == -1)
		needBuildSlice = true;
		calcRessize();
		
		#if !flash
		return _width;
		#end
	}
	
	@:getter(width)
	#if flash
	private function get_width():Float
	#else
	override public function get_width():Float
	#end
	{
		if (_width >= 0)
		return _width;
		else
		return oldWidth;
	}
	
	
	
	var _height:Float = -1;
	@:setter(height)
	#if flash
	private function set_height(value:Float)
	#else
	override function set_height(value:Float):Float
	#end
	{
		if(value == _height)
		return#if !flash _height #end;
	
		var rh:Float = _height;
		_height = value;
		if (rh == -1)
		needBuildSlice = true;
		calcRessize();
		#if !flash
		return _height;
		#end
	}
	
	@:getter(height)
	#if flash
	private function get_height():Float
	#else
	override public function get_height():Float
	#end
	{
		if (_height >= 0)
		return _height;
		else
		return oldHeight;
	}
	
	#if !html5
	
	var _scaleX:Float = 0;
	@:setter(scaleX)
	#if flash
	private function set_scaleX(value:Float)
	#else
	override function set_scaleX(value:Float):Float
	#end
	{
		if(value == _scaleX)
		return#if !flash _scaleX #end;
	
		width = oldWidth*value;
		
		#if !flash
		return value;
		#end
	}
	
	@:getter(scaleX)
	#if flash
	private function get_scaleX():Float
	#else
	override public function get_scaleX():Float
	#end
	{
		if(oldWidth>0)
			return width/oldWidth;
		else
			return super.scaleX;
	}
	
	var _scaleY:Float = 0;
	@:setter(scaleY)
	#if flash
	private function set_scaleY(value:Float)
	#else
	override function set_scaleY(value:Float):Float
	#end
	{
		if(value == _scaleY)
		return#if !flash _scaleY #end;
	
		height = oldHeight*value;
		
		#if !flash
		return value;
		#end
	}
	
	@:getter(scaleY)
	#if flash
	private function get_scaleY():Float
	#else
	override public function get_scaleY():Float
	#end
	{
		if(oldHeight>0)
			return height/oldHeight;
		else
			return super.scaleY;
	}
	
	#end
	
	/**
	 * 去掉鼠标事件
	 */
	public function setMouseEvt(value:Bool)
	{
		mouseChildren = value;
		mouseEnabled = value;
	}
	
	/**
	 * 清除回收bitmapData数据
	 */
	public function clearBmp()
	{
		for (k in bmpMap.keys())
		{
			var itm:Bitmap = bmpMap.get(k);
			if(itm.bitmapData != null && itm.bitmapData != _source)
			itm.bitmapData.dispose();
			itm.bitmapData = null;
			bmpMap.remove(k);
		}
	}
	
	public function dispose()
	{
		clearBmp();
		_scale9 = null;
		bgSrc = null;
		_source = null;
	}
}