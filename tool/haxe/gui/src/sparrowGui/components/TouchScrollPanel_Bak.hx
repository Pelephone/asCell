﻿package sparrowGui.components;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Timer;
import sparrowGUI.components.Component;
import sparrowGui.skinStyle.StyleKeys;

/**
 * 滚动面板
 * 仿手机拖动滚动条
 * @author Pelephone
 */
class TouchScrollPanel_Bak extends Component
{
	public function new(target:DisplayObject=null) 
	{
		super();
		maskRect = new Rectangle(0,0,100,100);
		setScrollDsp(target);
		downMPt = new Point();
		downSPt = new Point();
		lastMPt = new Point();
	}
	
	/**
	 * 鼠标抬起状态时的拖动速度,越大越快
	 */
	public var upSpeed:Int = 5;
	/**
	 * 缓动系统数，数字越大，缓动越久.0，表示不缓动
	 */
	public var easeParam:Int = 5;
	// 鼠标抬起时预要飞到的点
	var upPt:Point;
	
	// 被滚动的对象
	var scrollDsp:DisplayObject;
	
	/**
	 * 用于庶照的显示对象
	 */		
	var maskRect:Rectangle;
	
	// 按下时的鼠标坐标
	var downMPt:Point;
	// 按下时，滚动对象的坐标
	var downSPt:Point;
	// 上帧的鼠标坐标，用于计算缓动拖动
	var lastMPt:Point;
	
	// 滚动滑块
	var scrollSlider:DisplayObject;
	// 背景
	var scrollBg:DisplayObject;
	
	// 隐藏开始时间
	var hiddenTime:Float;
	
	override private function buildSetUI() 
	{
		super.buildSetUI();
		
		scrollSlider = getChildByName("slider");
		scrollBg = getChildByName("scrollBg");
	}
	
	override function getSkinId():String
	{
		return StyleKeys.TOUCH_SCROLL;
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		if (height > scrollDsp.height)
		return;
		
		downMPt.x = scrollDsp.stage.mouseX;
		downMPt.y = scrollDsp.stage.mouseY;
		downSPt.x = scrollDsp.x;
		downSPt.y = scrollDsp.y;
		upPt = null;
		hiddenTime = 0;
		
		if (_showType > 1)
		{
			scrollBg.alpha = 1;
			scrollSlider.alpha = 1;
		}
		
		scrollDsp.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		scrollDsp.stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function onMouseUp(e:Event)
	{
		scrollDsp.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		scrollDsp.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		
		var cmx:Float = scrollDsp.stage.mouseX;
		
		var toY:Float = 0;
		var toX:Float = 0;
		if (scrollDsp.height > _height)
		{
			var endy:Float = lastMPt.y + (scrollDsp.stage.mouseY - lastMPt.y) * upSpeed;
			var dy:Float = endy - downMPt.y;
			toY = downSPt.y + dy;
			if (toY > 0)
			toY = 0;
			else if (toY < (height-scrollDsp.height))
			toY = (height - scrollDsp.height);
		}
		
		if (scrollDsp.width > _width)
		{
			var endx:Float = lastMPt.x + (scrollDsp.stage.mouseX - lastMPt.x) * upSpeed;
			var dx:Float = endx - downMPt.x;
			toX = downSPt.x + dx;
			if (toX > 0)
			toX = 0;
			else if (toX < (width - scrollDsp.width))
			toX = (width - scrollDsp.width);
		}
		
		upPt = new Point(toX, toY);
	}
	
	
	// 逐帧计算坐标
	function onEnterFrame(e:Event):Void 
	{
		var toY:Float = 0;
		var toX:Float = 0;
		var hasChange:Bool = false;
		
		if (upPt == null)
		{
			var dy:Float = scrollDsp.stage.mouseY - downMPt.y;
			toY = downSPt.y + dy;
			var dx:Float = scrollDsp.stage.mouseX - downMPt.x;
			toX = downSPt.x + dx;
		}
		else
		{
			toY = upPt.y;
			toX = upPt.x;
		}
		
		// 滚动到的位置在合理位置
		if (toY != scrollDsp.y && scrollDsp.height > _height)
		{
			if (Math.abs(scrollDsp.y - toY) < 1.2)
			scrollDsp.y = toY;
			else
			scrollDsp.y = scrollDsp.y + (toY - scrollDsp.y) / (1 + easeParam);
			hasChange = true;
		}
		if (toX != scrollDsp.x && scrollDsp.width > _width)
		{
			if (Math.abs(scrollDsp.x - toX) < 1.2)
			scrollDsp.x = toX;
			else
			scrollDsp.x = scrollDsp.x + (toX - scrollDsp.x) / (1 + easeParam);
			hasChange = true;
		}
		
		// 滑块的显示
		if (upPt != null && scrollDsp.y == toY)
		{
			if(_showType < 2)
			{
				upPt = null;
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			else
			{
				var curTime:Float = Timer.stamp();
				if(hiddenTime==0)
				hiddenTime = curTime;
				
				var dsTime:Float = curTime - hiddenTime;
				if(dsTime > (_showType - 2))
				{
					var alp:Float = 1 - (dsTime - _showType + 2)*3;
					if (alp < 0)
					alp = 0;
					
					scrollBg.alpha = alp;
					scrollSlider.alpha = alp;
					
					if (alp == 0)
					{
						upPt = null;
						removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					}
				}
			}
		}

		lastMPt.x = scrollDsp.stage.mouseX;
		lastMPt.y = scrollDsp.stage.mouseY;
		
		// 正在滚动的过程
		if(hasChange)
		{
			var sy:Float = getValueY() * (height - scrollSlider.height);
			var padding:Int = 5;
			if (sy < (padding - scrollSlider.height))
			sy = padding - scrollSlider.height;
			else if (sy > (height - padding))
			sy = height - padding;
			scrollSlider.y = sy;
		
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	/**
	 * 绘制遮照
	 * @param w
	 * @param h
	 */
	function drawMask(w:Float,h:Float)
	{
		if (maskRect.width == w && maskRect.height == h)
		return;
		
		maskRect.width = w;
		maskRect.height = h;
		this.scrollRect = maskRect;
		
		invalidateDraw();
	}
	
	override private function draw():Void 
	{
		super.draw();
		
		if (_showType > 0)
		{
			scrollBg.visible = true;
			scrollSlider.visible = true;
		}
		else
		{
			scrollBg.visible = false;
			scrollSlider.visible = false;
		}
		if (_showType > 1 && upPt == null)
		{
			scrollBg.alpha = 0;
			scrollSlider.alpha = 0;
		}
		
		if (scrollBg != null && scrollBg.visible)
		{
			scrollBg.x = scrollRect.width - scrollBg.width;
			scrollBg.height = scrollRect.height;
			scrollSlider.x = scrollRect.width - scrollSlider.width;
			
			if (scrollDsp != null && scrollDsp.height > height)
			{
				scrollSlider.height = height * height / scrollDsp.height;
			}
		}
	}
	
	// y轴滚动比例，0~1的值
	public function getValueY() :Float
	{
		return (scrollDsp.y / (height - scrollDsp.height));
	}
	
	//----------------------------------
	// get/set
	//----------------------------------
	
	var _width:Float = 100;
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
		
		drawMask(_width, _height);
		
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
		return _width;
	}
	
	var _height:Float = 100;
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
		
		drawMask(_width, _height);
		
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
		return _height;
	}
	
	/**
	 * 设置要滚动的显示对象
	 * @param	value
	 */
	public function setScrollDsp(value:DisplayObject):Void
	{
		if (scrollDsp == value)
		return;
		scrollDsp = value;
		if (value == null)
		return;
		addChildAt(scrollDsp,0);
		dragScroll = true;
	}
	
	
	/**
	 * 激活内容可拖动
	 */
	public var dragScroll(get,set):Bool;
	var _dragScroll:Bool = false;
	
	function get_dragScroll():Bool
	{
		return _dragScroll;
	}
	
	function set_dragScroll(value:Bool):Bool
	{
		if (_dragScroll == value)
		return _dragScroll;
		_dragScroll = value;
		
		if(scrollDsp != null)
		{
			if (_dragScroll)
			scrollDsp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			else
			scrollDsp.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		return _dragScroll;
	}
	
	/**
	 * 滚动条显示方式 0,不显示; 1.一直显示; >1拖动的时候显示,一小段时间自动隐藏
	 */
	public var showType(get,set):Float;
	var _showType:Float = 2.5;
	
	function get_showType():Float
	{
		return _showType;
	}
	
	function set_showType(value:Float):Float
	{
		if (_showType == value)
		return _showType;
		_showType = value;
		return _showType;
	}
}