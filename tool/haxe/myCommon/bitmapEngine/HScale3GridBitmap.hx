package bitmapEngine;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import timerUtils.StaticEnterFrame;

/**
 * 横向3切片
 * 简化9切片,不用这么多位置对象,节省资源
 * @author Pelephone
 */
class HScale3GridBitmap extends Sprite
{

	public function new(sourceImg : BitmapData = null)
	{
		super();
		source = sourceImg;
		if (source != null)
		{
			oldWidth = _source.width;
			_width = _source.width;
		}
		setMouseEvt(false);
	}
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------
	// Blocks
	//---------------------------------------------------------------------------------------------------------------------------------------------------

	var bmpAry:Array<Bitmap>;
	/**
	 * 初始构造九宫格
	 */
	private function initializeBlocks()
	{
		if (bmpAry != null)
		return;
		
		bmpAry = [];
		var snapping:Dynamic = PixelSnapping.AUTO;
		for (i in 0...3)
		{
			var bmp:Bitmap = new Bitmap(null, snapping);
			addChild(bmp);
			bmpAry.push(bmp);
			#if !html5
			bmp.smoothing = BmpRule.SMOOTH_BMP;
			#end
		}
	}
	
	#if html5
	/**
	 * 跟据长宽重设格子
	 */
	private function resizeDraw()
	{
		if (_source == null || bmpAry == null)
		return;
		
		var rightWidth:Float = oldWidth - sliceX - sliceWidth;
		var dw:Float = _width > 0?_width:oldWidth;
		var xAry:Array<Float> = [0,sliceX,(dw - rightWidth)];
		var widthAry:Array<Float> = [sliceX,(dw - sliceX - rightWidth),rightWidth];

		for (i in 0...xAry.length) 
		{
			var bmp:Bitmap = bmpAry[i];
			var tx:Float = xAry[i];
			var tw:Float = widthAry[i];
			bmp.x = tx;
			if(i==1)
			bmp.width = tw;
		}
	}
	#end
	
	/**
	 * 重设九宫格位图数据
	 */
	function drawBmpd()
	{
		if (_source == null)
		return;
		
		// 设置数据前先清数据引用计数
		var bmpd:BitmapData = _source;
		
		oldWidth = bmpd.width;
		oldHeight = bmpd.height;
		
		if (_source.width == width || width<=0)
		{
			setShowBmp(_source);
			return;
		}
		
		if (sliceX<1 || (sliceWidth+sliceX)>=oldWidth)
		return;
		
		#if html5
		
		initializeBlocks();
		clearBmp();
		
		// 左中右格子宽,x坐标数据
		var sx2:Int = sliceWidth + sliceX;
		var xAry:Array<Float> = [0,sliceX,sx2];
		var widthAry:Array<Float> = [sliceX,sliceWidth,(oldWidth - sliceX - sliceWidth)];

		var pt:Point = new Point(0,0);

		for (i in 0...xAry.length) 
		{
			var bmp:Bitmap = bmpAry[i];
			var tx:Float = xAry[i];
			var tw:Float = widthAry[i];
			var bd:BitmapData;
			
			bd = new BitmapData(Std.int(tw), bmpd.height);
			bd.copyPixels(bmpd, new Rectangle(tx, 0, tw, bmpd.height), pt);
			
			bmp.bitmapData = bd;
			bmp.x = tx;
		}
		
		resizeDraw();
		
		#else
		calcRessize();
		#end
	}
	
	#if !html5
	// 用draw的方式复制9切片样式
	public function buildScaledImage():Void
	{
		var dw:Float = _width > 0?_width:oldWidth;
		var dh:Int = oldHeight;
		
		if (dw == 0 || dh == 0 || sliceX<=0 || sliceWidth>=dw)
		return;
		
		if (toBmpd!=null)
		toBmpd.dispose();
		
		toBmpd = new BitmapData(Std.int(dw), Std.int(dh),true,0);
		var _sourceImage:BitmapData = _source;
		
		var cols:Array<Int> = [0, sliceX, Std.int(sliceX + sliceWidth), oldWidth];
		var dCols:Array<Int> = [0, sliceX, Std.int(dw - (_sourceImage.width - sliceX - sliceWidth)), Std.int(dw)];
		
		var origin:Rectangle;
		var draw:Rectangle;
		var mat:Matrix = new Matrix();
		
		for (cx in 0...3)
		{
			origin = new Rectangle(cols[cx], 0, cols[cx + 1] - cols[cx], dh);
			draw = new Rectangle(dCols[cx], 0, dCols[cx + 1] - dCols[cx], dh);
			mat.identity();
			mat.a = draw.width / origin.width;
			mat.tx = draw.x - origin.x * mat.a;
			toBmpd.draw(_sourceImage, mat, null, null, draw);
		}
		
		setShowBmp(toBmpd);
	}
	
	var toBmpd:BitmapData;
	#end
	
	var showBmp:Bitmap;
	function setShowBmp(bd:BitmapData):Void 
	{
		if(showBmp == null)
		{
			showBmp = new Bitmap();
			addChild(showBmp);
		}
		showBmp.bitmapData = bd;
	}
	
	/**
	 * 未拉申时的宽度
	 */
	private var oldWidth:Int = 0;
	
	/**
	 * 未拉申时的高度
	 */
	private var oldHeight:Int = 0;
	
	var sliceX:Int = 0;
	
	var sliceWidth:Int = 0;
	
	/**
	 * 3切片
	 */
	public function setScale3(sx:Int,swidth:Int):Void 
	{
		if (sliceX == sx && sliceWidth == swidth)
		return;
		
		_scale9 = new Rectangle(sx, oldHeight, swidth, oldHeight);
		sliceX = sx;
		sliceWidth = swidth;
		
		drawBmpd();
	}
	
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
		setScale3(Std.int(_scale9.x), Std.int(_scale9.width));
		return _scale9;
	}
	
	/**
	 * 是否开启下帧渲染模式提升性能(开启后不能马上得到对象正确宽高)
	 */
	public var isNextDraw:Bool = true;
	
	function calcRessize()
	{
		#if html5
		resizeDraw();
		#else
		if(isNextDraw)
		StaticEnterFrame.addNextCall(buildScaledImage);
		else
		buildScaledImage();
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
		
		if (autoScaleRect && value != null && sliceX == 0 && sliceWidth == 0)
		{
			var dx:Int = Std.int(value.width * 0.33333);
			setScale3(dx, dx);
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
	public var assetId(get,set):String;
	var _assetId:String;
	function get_assetId():String
	{
		return _assetId;
	}
	function set_assetId(value:String):String
	{
		if (_assetId == value)
		return _assetId;
		_assetId = value;
		_source = null;
		if (_assetId != null)
		source = Assets.getBitmapData(_assetId);
		
		return _assetId;
	}
	
	
	var _width:Float = 0;
	@:setter(width)
	#if flash
	private function set_width(value:Float)
	#else
	override function set_width(value:Float):Float
	#end
	{
		if(value == _width)
		return#if !flash _width #end;
	
		_width = value;
		calcRessize();
		
		#if !flash
		return value;
		#end
	}
	
	@:getter(width)
	#if flash
	private function get_width():Float
	#else
	override public function get_width():Float
	#end
	{
		if (_width > 0)
		return _width;
		else
		{
			#if html5
			return oldWidth;
			#else
			return super.width;
			#end
		}
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
	
		width = oldWidth * 1;
		_scaleX = value;
		
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
	#end
	
	public function setMouseEvt(value:Bool)
	{
		mouseEnabled = value;
		mouseChildren = value;
	}
	
	/**
	 * 清除回收bitmapData数据
	 */
	public function clearBmp()
	{
		if(bmpAry != null)
 		{
			for (itm in bmpAry)
			{
				if (itm.bitmapData != null)
				{
					itm.bitmapData.dispose();
					itm.bitmapData = null;
				}
			}
		}
		if (showBmp != null)
			showBmp.bitmapData = null;
	}
	
	public function dispose()
	{
		clearBmp();
		assetId = null;
		_source = null;
	}
}