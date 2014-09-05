package sparrowGui.components;
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
class TouchScrollPanel extends Component
{
	public function new(target:DisplayObject=null) 
	{
		super();
		maskRect = new Rectangle(0,0,100,100);
		setScrollDsp(target);
		downMPt = new Point();
		downSPt = new Point();
		lastMPt = new Point();
		this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}
	
	// 鼠标中键滚动
	private function onMouseWheel(e:MouseEvent):Void 
	{
		if (scrollDsp == null)
		return;
		var scrollDst:Float = Math.abs(height - scrollBound.height) * 0.003;
		if (scrollDst < 5)
		scrollDst = 5;
		var ey:Float = scrollDsp.y + e.delta * scrollDst;
		scrollDsp.y = validaToY(ey);
	}
	
	/**
	 * 鼠标抬起状态时的拖动速度,越大越快
	 */
	public var upSpeed:Int = 10;
	/**
	 * 缓动系统数，数字越大，缓动越久.0，表示不缓动
	 */
	public var easeParam:Int = 3;
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
		
		var toY:Float = 0;
		var toX:Float = 0;
		if (scrollBound.height > _height)
		{
			var endy:Float = lastMPt.y + (scrollDsp.stage.mouseY - lastMPt.y) * upSpeed;
			var dy:Float = endy - downMPt.y;
			toY = downSPt.y + dy;
			toY = validaToY(toY);
		}
		
		if (scrollBound.width > _width)
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
		
		// 用于判断x,y坐标是否滚动完成
		var yComplete:Bool = false;
		var xComplete:Bool = false;
		
		// 滚动到的位置在合理位置
		if (toY != scrollDsp.y && scrollDsp.height > _height)
		{
			if (Math.abs(scrollDsp.y - toY) < 1.2)
			{
				scrollDsp.y = toY;
				yComplete = true;
			}
			else
			scrollDsp.y = scrollDsp.y + (toY - scrollDsp.y) / (1 + easeParam);
			hasChange = true;
		}
		else
		yComplete = true;
		
		if (toX != scrollDsp.x && scrollDsp.width > _width)
		{
			if (Math.abs(scrollDsp.x - toX) < 1.2)
			{
				scrollDsp.x = toX;
				xComplete = true;
			}
			else
			scrollDsp.x = scrollDsp.x + (toX - scrollDsp.x) / (1 + easeParam);
			hasChange = true;
		}
		else
		xComplete = true;
		
		// 滑块的显示
		if (upPt != null && (scrollDsp.y - toY)<1)
		{
			if(_showType < 2)
			{
				if(yComplete && xComplete)
				{
					upPt = null;
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				}
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
		
		// 正在自动滚动的过程
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
	 * 设置Y轴滚动比率
	 * @param	value 0~1之间的数
	 */
	public function setScrollYRate(value:Float)
	{
		if (value > 1)
		value = 1;
		else if (value < 0)
		value = 0;
		
		var toY:Float;
		if (scrollBound.height > _height)
		{
			toY = (_height - scrollBound.height) * value + scrollBound.y;
			scrollDsp.y = validaToY(toY);
		}
	}
	
	function validaToY(toY:Float):Float
	{
		if (scrollBound.height > height)
		{
			if (toY > scrollBound.y)
			return scrollBound.y;
			else if (toY < (height - scrollBound.height + scrollBound.y))
			return height - scrollBound.height + scrollBound.y;
			else
			return toY;
		}
		return scrollBound.y;
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
		scrollDsp.y = validaToY(scrollDsp.y);
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
		return ((scrollDsp.y - scrollBound.y) / (height - scrollBound.height));
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
	 * @param isBound 是否按真实像素的左上角坐标来判断位置 (有些显示对象的滚动左上坐标并不是0,0。例如Sprite里面有一个负数坐标的子对象)
	 */
	public function setScrollDsp(value:DisplayObject,isBound:Bool=true):Void
	{
		if (scrollDsp == value)
		return;
		scrollDsp = value;
		if (value == null)
		return;
		
		addChildAt(scrollDsp, 0);
		calcScrollBound(isBound);
		
		scrollDsp.x = scrollBound.x;
		scrollDsp.y = scrollBound.y;
		
		dragScroll = true;
	}
	
	// 跟据显示对象刷新滚动范围
	public function calcScrollBound(isBound:Bool=true)
	{
		if (scrollDsp == null)
		return;
		
		if (isBound)
		{
			scrollBound = scrollDsp.getBounds(scrollDsp);
			scrollBound.x = scrollBound.x * -1;
			scrollBound.y = scrollBound.y * -1;
		}
		else
		scrollBound = new Rectangle(0, 0, scrollDsp.width, scrollDsp.height);
		
		if (scrollDsp.height > height)
		scrollSlider.height = height * height / scrollDsp.height;
	}
	
	// 开始滚动的左上点。
	// (有些显示对象的滚动左上坐标并不是0,0。例如Sprite里面有一个负数坐标的子对象)
	var scrollBound:Rectangle;
	
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
		invalidateDraw();
		return _showType;
	}
}