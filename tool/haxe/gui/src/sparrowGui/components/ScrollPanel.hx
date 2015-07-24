package sparrowGui.components;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
	var sp:ScrollPanel = new ScrollPanel();
	sp.x = 300;
	sp.source = cb;
	addChild(sp);
 * 
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class ScrollPanel extends Component
{
	/**
	 * 构造滚动面板
	 * @param	scrollTarget 需要被滚动的显示对象，该对象将被addChild到此容器里
	 */
	public function new(scrollTarget:DisplayObject) 
	{
		super();
		maskRect = new Rectangle();
		addScrollTarget(scrollTarget);
		reset();
	}
	
	/**
	 * 被滚动的显示对象
	 */
	public var scrollDsp:DisplayObject;
	
	/**
	 * 放滚动对象的容器
	 */
	var contDP:Sprite;
	/**
	 * 用于庶照的显示对象
	 */		
	var maskRect:Rectangle;
	
	public var vScroll:VScrollBar;
	public var hScroll:HScrollBar;
	var dragClip:DragScroll;
	
	override private function buildSetUI() 
	{
		contDP = new Sprite();
		addChild(contDP);
		vScroll = new VScrollBar();
		addChild(vScroll);
		hScroll = new HScrollBar();
		addChild(hScroll);
		
		dragClip = new DragScroll();
	}
	
	function reset()
	{
		dragScroll = true;
		dragClip.addEventListener(Event.CHANGE, onDragChange);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		vScroll.addEventListener(Event.CHANGE, onVScrollChange);
		hScroll.addEventListener(Event.CHANGE, onHScrollChange);
	}
	
	override public function dispose():Void 
	{
		dragScroll = false;
		dragClip.removeEventListener(Event.CHANGE, onDragChange);
		removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		if (vScroll != null)
		vScroll.removeEventListener(Event.CHANGE, onVScrollChange);
		if (hScroll != null)
		hScroll.removeEventListener(Event.CHANGE, onHScrollChange);
		super.dispose();
	}
	
	/**
	 * 设置要被滚动的显示对象
	 * @param	scrollTarget
	 */
	public function addScrollTarget(scrollTarget:DisplayObject)
	{
		if (scrollDsp == scrollTarget)
		return;
		
		if (scrollDsp != null && scrollDsp.parent != null)
		scrollDsp.parent.removeChild(scrollDsp);
		
		scrollDsp = scrollTarget;
		contDP.addChild(scrollDsp);
		dragClip.scrollDsp = scrollDsp;
		
		invalidateDraw();
	}
	
	/**
	 * 每次点击滚动条移动的像素
	 */
	public var stepPix:Int = 10;
		
	/**
	 * @inheritDoc
	 */
	override function draw()
	{
		var scrollWidth:Float = this.width;
		var scrollHeight:Float = this.height;
		// 是否显示纵向滚动条的判断
		if (scrollDsp.height <= this.height #if html5 && scrollDsp.height > 0 #end)
		{
			if(autoVhidden)
			vScroll.visible = false;
			else
			{
				vScroll.visible = true;
				vScroll.enabled = false;
				
				scrollWidth = this.width - (autoScroll?vScroll.width:0);
			}
		}
		else
		{
			var stepV:Float = (stepPix == 0 || scrollDsp.height == 0)?0.05:(stepPix / scrollDsp.height);
			vScroll.visible = true;
			vScroll.setSliderParams(this.height,scrollDsp.height,stepV);
			
			scrollWidth = this.width - (autoScroll?vScroll.width:0);
		}
		if(autoScroll && vScroll.visible)
		vScroll.x = this.width - vScroll.width;
		
		if(!vScroll.visible)
		vScroll.scrollPercent = 0;
		
		if (hScroll == null)
		{
			if (autoScroll && vScroll.visible)
			vScroll.height = height;
			drawMask(scrollWidth,scrollHeight);
			return;
		}
		// 是否显示横向滚动条的判断
		if (scrollDsp.width<=scrollWidth  #if html5 && scrollDsp.width > 0 #end)
		{
			if(autoHhidden)
			hScroll.visible = false;
			else
			{
				hScroll.visible = true;
				hScroll.enabled = false;
				scrollHeight = this.height - (autoScroll?hScroll.height:0);
			}
		}
		else
		{
			var stepH:Float = (stepPix == 0 || scrollDsp.width == 0)?0.05:(stepPix / scrollDsp.width);
			hScroll.visible = true;
			hScroll.setSliderParams(scrollWidth,scrollDsp.width,stepH);
			scrollHeight = this.height - (autoScroll?hScroll.height:0);
		}
		// 自动跟椐长宽改变滚动条位置
		if(autoScroll)
		{
			if(vScroll.visible)
			vScroll.height = this.height - (hScroll.visible?hScroll.height:0);
			if(hScroll.visible)
			{
				hScroll.y = this.height - hScroll.height;
				hScroll.width = this.width - (vScroll.visible?vScroll.width:0);
			}
		}
		
		if(!hScroll.visible)
			hScroll.scrollPercent = 0;
		
		drawMask(scrollWidth,scrollHeight);
		super.draw();
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
		contDP.scrollRect = maskRect;
	}
	
	//----------------------------------
	// 事件
	//----------------------------------
	
	private function onDragChange(e:Event):Void 
	{
		if(hScroll != null)
		{
			var sw:Float = scrollDsp.width - width;
			hScroll.setScrollPercent( -scrollDsp.x / sw);
		}
		
		if(vScroll != null)
		{
			var sh:Float = scrollDsp.height - height;
			vScroll.setScrollPercent( -scrollDsp.y / sh);
		}
	}
	
	// 其它基本事件
	
	private function onMouseWheel(e:MouseEvent):Void 
	{
		var scrollDist:Float = scrollDsp.height - maskRect.height;
		vScroll.scrollPercent -= e.delta/scrollDist*2;
	}
	
	private function onHScrollChange(e:Event):Void 
	{
		var scrollNum:Float = scrollDsp.width - width;
		scrollDsp.x = -1 * hScroll.scrollPercent * scrollNum;
		drawMask(maskRect.width, maskRect.height);
	}
	
	private function onVScrollChange(e:Event):Void 
	{
		var scrollNum:Float = scrollDsp.height - height;
		scrollDsp.y = -1 * vScroll.scrollPercent * scrollNum;
		drawMask(maskRect.width, maskRect.height);
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
		dragClip.width = value;
		
		invalidateDraw();
		
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
		dragClip.height = value;
		invalidateDraw();
		
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
	 * 自动隐藏纵向滚动条
	 */
	public var autoVhidden(get,set):Bool;
	var _autoVhidden:Bool = true;
	
	function get_autoVhidden():Bool
	{
		return _autoVhidden;
	}
	
	function set_autoVhidden(value:Bool):Bool
	{
		if (_autoVhidden == value)
		return _autoVhidden;
		_autoVhidden = value;
		invalidateDraw();
		return _autoVhidden;
	}
	
	/**
	 * 自动隐藏横向滚动条
	 */
	public var autoHhidden(get,set):Bool;
	var _autoHhidden:Bool = true;
	
	function get_autoHhidden():Bool
	{
		return _autoHhidden;
	}
	
	function set_autoHhidden(value:Bool):Bool
	{
		if (_autoHhidden == value)
		return _autoHhidden;
		_autoHhidden = value;
		invalidateDraw();
		return _autoHhidden;
	}
	
	/**
	 * 自动移动滚动条的位置，移至容器的右侧和下侧
	 */
	public var autoScroll(get,set):Bool;
	var _autoScroll:Bool = true;
	
	function get_autoScroll():Bool
	{
		return _autoScroll;
	}
	
	function set_autoScroll(value:Bool):Bool
	{
		if (_autoScroll == value)
		return _autoScroll;
		_autoScroll = value;
		invalidateDraw();
		return _autoScroll;
	}
	
	/**
	 * 内容是否可拖动
	 */
	public var dragScroll(get,set):Bool;
	function get_dragScroll():Bool
	{
		return dragClip.dragScroll;
	}
	function set_dragScroll(value:Bool):Bool
	{
		dragClip.dragScroll = value;
		return dragClip.dragScroll;
	}
}