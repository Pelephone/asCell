package bitmapEngine;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;

/**
 * 支持9格缩放的位图(生成的位图bitmapData数据做有缓存处理)
 * @author Pelephone
 */
class Scale9GridBitmap3 extends Sprite
{
	public function new(sourceDsp : DisplayObject = null, tScale9Grid : Rectangle = null)
	{
		super();
		source = sourceDsp;
		if(source)
		{
			_width = _source.width;
			_height = _source.height;
		}
		initializeBlocks();
		this.scale9 = tScale9Grid;
		setMouseEvt(false);
	}
	
	//---------------------------------------------------------------------------------------------------------------------------------------------------
	// Blocks
	//---------------------------------------------------------------------------------------------------------------------------------------------------
	
	// TopLeft
	private var _topLeft:Bitmap = null;
	
	// Top
	private var _top:Bitmap = null;
	
	// TopRight
	private var _topRight:Bitmap = null;
	
	// Left
	private var _left:Bitmap = null;
	
	// Center
	private var _center:Bitmap = null;
	
	// Right
	private var _right:Bitmap = null;
	
	// BottomLeft
	private var _bottomLeft:Bitmap = null;
	
	// Bottom
	private var _bottom:Bitmap = null;
	
	// BottomRight
	private var _bottomRight:Bitmap = null;

	/**
	 * 初始构造九宫格
	 */
	private function initializeBlocks()
	{
		var snapping:Dynamic = PixelSnapping.AUTO;
		_topLeft = new Bitmap(null, snapping);
		addChild(_topLeft);
		
		_top = new Bitmap(null, snapping);
		addChild(_top);
		
		_topRight = new Bitmap(null, snapping);
		addChild(_topRight);
		
		_left = new Bitmap(null, snapping);
		addChild(_left);
		
		_center = new Bitmap(null, snapping);
		addChild(_center);
		
		_right = new Bitmap(null, snapping);
		addChild(_right);
		
		_bottomLeft = new Bitmap(null, snapping);
		addChild(_bottomLeft);
		
		_bottom = new Bitmap(null, snapping);
		addChild(_bottom);
		
		_bottomRight = new Bitmap(null, snapping);
		addChild(_bottomRight);
		
		bmpAry = [_topLeft, _top, _topRight, _left, _center, _right, _bottomLeft, _bottom, _bottomRight];
		
		#if !html5
			for (itm in bmpAry) 
			{
				itm.smoothing = BmpRule.SMOOTH_BMP;
			}
		#end
	}
	
	/**
	 * 跟据长宽重设格子
	 */
	private function resizeDraw()
	{
		if (source == null || _scale9 == null)
			return;
		
		var rightWidth:Float = oldWidth - _scale9.x - _scale9.width;
		var bottomHeight:Float = oldHeight - _scale9.y - _scale9.height;
		
		var dw:Float = _width > 0?_width:oldWidth;
		var dh:Float = _height > 0?_height:oldHeight;
		
		var xAry:Array<Float> = [0,_scale9.x,(dw - rightWidth)];
		var widthAry:Array<Float> = [_scale9.x,(dw - _scale9.x - rightWidth),rightWidth];
		var yAry:Array<Float> = [0,_scale9.y,(dh - bottomHeight)];
		var heightAry:Array<Float> = [_scale9.y,(dh - _scale9.y - bottomHeight),bottomHeight];

		for (j in 0...yAry.length)
		{
			var ty:Float = yAry[j];
			var th:Float = heightAry[j];
			for (i in 0...xAry.length) 
			{
				var bmp:Bitmap = bmpAry[i + j*3];
				var tx:Float = xAry[i];
				var tw:Float = widthAry[i];
				bmp.x = tx;
				bmp.y = ty;
				if(i==1)
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
		if(_source == null || _scale9 == null)
		return;
		
		// 设置数据前先清数据引用计数
		var bitmapData:BitmapData;
		
		if(Std.is(source,BitmapData))
		{
			bitmapData = cast source;
		}
		else if (Std.is(source, Bitmap))
		{
			var bmp:Bitmap = cast source;
			bitmapData = bmp.bitmapData;
		}
		else
		{
			var rect:Rectangle = source.getBounds(source);
			var m:Matrix = new Matrix();
			m.translate(-rect.x,-rect.y);
			bitmapData = new BitmapData(Std.int(rect.width),Std.int(rect.height),true,0);
			bitmapData.draw(source,m);
		}
		if (bitmapData == null)
		return;
		
		// 左中右格子宽,x坐标数据
		var xAry:Array<Float> = [0,_scale9.x,(_scale9.width + _scale9.x)];
		var widthAry:Array<Float> = [_scale9.x,_scale9.width,(bitmapData.width - _scale9.x - _scale9.width)];
		// 上中下格子高,y坐标数据
		var yAry:Array<Float> = [0,_scale9.y,(_scale9.height + _scale9.y)];
		var heightAry:Array<Float> = [_scale9.y,_scale9.height,(bitmapData.height - _scale9.y - _scale9.height)];

		var pt:Point = new Point(0,0);
		
		for (j in 0...yAry.length)
		{
			var ty:Float = yAry[j];
			var th:Float = heightAry[j];
			for (i in 0...xAry.length) 
			{
				var bmp:Bitmap = bmpAry[i + j*3];
				var tx:Float = xAry[i];
				var tw:Float = widthAry[i];
				var bd:BitmapData;
				
				if(tw<1)
				tw = 1;
				if(th<1)
				th = 1;
				
				bd = new BitmapData(Std.int(tw), Std.int(th));
				bd.copyPixels(bitmapData, new Rectangle(tx, ty, tw, th), pt);
				
				bmp.bitmapData = bd;
				bmp.x = tx;
				bmp.y = ty;
			}
		}
		
		oldWidth = bitmapData.width;
		oldHeight = bitmapData.height;
		
		resizeDraw();
	}
	
	var bmpAry:Array<Bitmap>;
	
	/**
	 * 未拉申时的宽度
	 */
	private var oldWidth:Int;
	
	/**
	 * 未拉申时的高度
	 */
	private var oldHeight:Int;
	
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
		if (source != null && _scale9 != null)
		drawBmpd();
		return _scale9;
	}
	
	
	/**
	 * 把一个9格矩形校正
	 */
	private function correctGridRect(rect : Rectangle) : Rectangle
	{
		var minMargin:Int = 1;
		if(rect.left < 1)
			rect.left = minMargin;
		if(rect.top < 1)
			rect.top = minMargin;
		if(rect.right > _source.width - minMargin)
			rect.right = _source.width - minMargin; 
		if(rect.bottom > _source.height - minMargin)
			rect.bottom = _source.height - minMargin; 
		return rect;
	}	
	
	//---------------------------------------------------
	// 其它get/set
	//---------------------------------------------------
	
	/**
	 * 显示数据源
	 */
	public var source(get,set):Dynamic;
	var _source:Dynamic;
	
	function get_source():Dynamic
	{
		return _source;
	}
	
	function set_source(value:Dynamic):Dynamic
	{
		if (_source == value)
		return _source;
		_source = value;
		clearBmp();
		drawBmpd();
		return _source;
	}
	
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
		resizeDraw();
		
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
		return super.width;
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
		resizeDraw();
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
		if(_height>0)
		return _height;
		else
		return super.height;
	}
	
	
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
	
		width = oldWidth*1;
		
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
 		for (itm in bmpAry)
		{
			if (itm.bitmapData != null)
			{
				itm.bitmapData.dispose();
				itm.bitmapData = null;
			}
		}
/*		var bitmapData:BitmapData;
		if(Std.is(source,BitmapData))
		{
			bitmapData = cast source;
			bitmapData.dispose();
		}
		else if (Std.is(source, Bitmap))
		{
			var bmp:Bitmap = cast source;
			bitmapData = bmp.bitmapData;
			bitmapData.dispose();
		}*/
	}
	
	public function dispose()
	{
		assetId = null;
		_source = null;
	}
}