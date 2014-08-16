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
 * 纵向3切片
 * 简化9切片,不用这么多位图对象,节省资源
 * @author Pelephone
 */
class VScale3GridBitmap extends Sprite
{

	public function new(sourceImg : BitmapData = null)
	{
		super();
		source = sourceImg;
		if (source != null)
		{
			oldHeight = _source.height;
			_height = _source.height;
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
		
		var bottomHeight:Float = oldHeight - sliceY - sliceHeight;
		var dh:Float = _height > 0?_height:oldHeight;
		var yAry:Array<Float> = [0,sliceY,(dh - bottomHeight)];
		var hAry:Array<Float> = [sliceY,(dh - sliceY - bottomHeight),bottomHeight];

		for (i in 0...yAry.length) 
		{
			var bmp:Bitmap = bmpAry[i];
			var ty:Float = yAry[i];
			var th:Float = hAry[i];
			bmp.y = ty;
			if(i==1)
			bmp.height = th;
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
		
		if (height == oldHeight || height <= 0)
		{
			setShowBmp(_source);
			return;
		}
		
		if (sliceY<1 || (sliceHeight+sliceY)>=oldHeight)
		return;
		
		#if html5
		
		initializeBlocks();
		clearBmp();
		
		// 左中右格子宽,x坐标数据
		var sy2:Int = sliceHeight + sliceY;
		var yAry:Array<Float> = [0,sliceY,sy2];
		var hAry:Array<Float> = [sliceY,sliceHeight,(oldHeight - sliceY - sliceHeight)];

		var pt:Point = new Point(0,0);

		for (i in 0...yAry.length) 
		{
			var bmp:Bitmap = bmpAry[i];
			var ty:Float = yAry[i];
			var th:Float = hAry[i];
			var bd:BitmapData;
			
			bd = new BitmapData(bmpd.width, Std.int(th));
			bd.copyPixels(bmpd, new Rectangle(0, ty, bmpd.width, th), pt);
			
			bmp.bitmapData = bd;
			bmp.y = ty;
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
		var dh:Float = _height > 0?_height:oldHeight;
		var dw:Int = oldWidth;
		
		if (dw == 0 || dh == 0 || sliceY<=0 || sliceHeight>=dh)
		return;
		
		if (toBmpd!=null)
		toBmpd.dispose();
		
		toBmpd = new BitmapData(Std.int(dw), Std.int(dh),true,0);
		var _sourceImage:BitmapData = _source;
		
		var rows:Array<Int> = [0, sliceY, Std.int(sliceY + sliceHeight), Std.int(oldHeight)];
		var dRows:Array<Int> = [0, sliceY, Std.int(dh - (oldHeight - sliceY - sliceHeight)), Std.int(dh)];
		
		var origin:Rectangle;
		var draw:Rectangle;
		var mat:Matrix = new Matrix();
		
		for (cy in 0...3)
		{
			origin = new Rectangle(0,rows[cy], dw, rows[cy + 1] - rows[cy]);
			draw = new Rectangle(0,dRows[cy], dw, dRows[cy + 1] - dRows[cy]);
			mat.identity();
			mat.d = draw.height / origin.height;
			mat.ty = draw.y - origin.y * mat.d;
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
	
	var sliceY:Int = 0;
	
	var sliceHeight:Int = 0;
	
	/**
	 * 3切片
	 */
	public function setScale3(sy:Int,sheight:Int):Void 
	{
		if (sliceY == sy && sliceHeight == sheight)
		return;
		
		_scale9 = new Rectangle(0,sy, 0, sheight);
		sliceY = sy;
		sliceHeight = sheight;
		
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
		setScale3(Std.int(_scale9.y), Std.int(_scale9.height));
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
		
		if (autoScaleRect && value != null && sliceY == 0 && sliceHeight == 0)
		{
			var dy:Int = Std.int(value.height * 0.33333);
			setScale3(dy, dy);
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
	
	
	var _height:Float = 0;
	@:setter(height)
	#if flash
	private function set_height(value:Float)
	#else
	override function set_height(value:Float):Float
	#end
	{
		if(value == _height)
		return#if !flash _height #end;
	
		_height = value;
		calcRessize();
		
		#if !flash
		return value;
		#end
	}
	
	@:getter(height)
	#if flash
	private function get_height():Float
	#else
	override public function get_height():Float
	#end
	{
		if (_height > 0)
		return _height;
		else
		{
			#if html5
			return oldHeight;
			#else
			return super.height;
			#end
		}
	}
	
	#if !html5
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
	
		height = oldHeight * 1;
		_scaleY = value;
		
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