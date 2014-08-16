package sparrowGui.components;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.Timer;
import sparrowGUI.components.Component;
import sparrowGui.skinStyle.StyleKeys;


/** 滚动条值改变. *
[Event(name="change", 	type="flash.events.Event")]*/

/**
 * 滚动组件基类,用于继承,不能实例化
 * 实现纵横向公共部份的功能
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class ScrollBarBase extends Component
{
	/**
	 * 中轴最小值
	 */
	inline public static var MIN_SLIDER_VALUE:Int = 8;
	/**
	 * 滚动条的最小宽/高度(上下按钮高相加)
	 */		
	inline public static var MIN_SCROLL_VALUE:Int = 28;
	
	
	
	/**
	 * 暂存鼠标按slider时滚动的相对坐标
	 */
	var _sliderTrace:Float;	
	// 延迟移动的命令
	var _delayCMD:Int = 0;
	// 延迟移动开始的时间点
	var _delayTime:Float = 0;
	
	public function new()
	{
		super();
		reset();
	}
	
	override function buildSetUI():Void
	{
		super.buildSetUI();
		
		slider = getChildByName("slider");
		skinbg = getChildByName("skinBg");
	}
	
	/**
	 * @inheritDoc
	 
	override public function setUiStyle(uiVars:Object=null):Void
	{
		super.setUiStyle(uiVars);
		
	}*/
	
	/**
	 * 跟椐最大最小滚动位重设滚动条按钮高宽
	 
	override protected function draw():Void
	{
		super.draw();
	}*/
	
	function scrollChange():Void
	{
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 效果同set scrollPercent改变中轴的位置,不过此方法不发送事件
	 * @param value
	 */
	public function setScrollSider(percent:Float):Void
	{
		if (percent > 1)
		_scrollPercent = 1;
		else if (percent < 0)
		_scrollPercent = 0;
		else
		_scrollPercent = percent;
		
		freshSliderPosi();
	}
	
	/**
	 * 刷新slider的位置
	 */
	public function freshSliderPosi():Void
	{
		if (this.slider == null || !enabled)
		return;
		// 减少slider后,能滚动的范围
		var scrollDist:Float = getCanDist() - this.slider.height;
		this.slider.y = scrollDist*this.scrollPercent;
	}
	
	/**
	 * 通过要移动的对象的最小位置和最大位置初始激活滚动条
	 * 中间滚动块在最左边的时间value是min,最右边时value是max
	 * @param min 		滚动条value为0时对应容器的最小位置,Vlist的maskDP.height
	 * @param max 		滚动条value为1时对应容器的最大位置,Vlist的contDP.height
	 * @param stepPercent 每点一次滚动像素
	 */
	public function setSliderParams(min:Float, max:Float, stepVal:Float=0.05):Void
	{
		this._minScrollValue = min;
		this._maxScrollValue = max;
		this.stepValue = stepVal;
		
		if(min<max)
		enabled = true;
		
		invalidateDraw();
	}
	
	/////////////////////////////////////////
	
	public function reset()
	{
		if (slider != null)
		slider.addEventListener(MouseEvent.MOUSE_DOWN,onSliderMouseDown);
		if(skinbg != null)
		skinbg.addEventListener(MouseEvent.MOUSE_DOWN,onSkinBgMouseDown);
	}
	
	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		if(slider != null)
		slider.removeEventListener(MouseEvent.MOUSE_DOWN,onSliderMouseDown);
		if(skinbg != null)
		skinbg.removeEventListener(MouseEvent.MOUSE_DOWN,onSkinBgMouseDown);
		
		super.dispose();
	}
	
	override public function invalidateDraw(args:Dynamic = null):Void 
	{
		if(isNextRender)
			SparrowUtil.addNextCall(draw,false);
		else
			draw();
	}
	
	/**
	 * 背景按下事件
	 * @param	e
	 */
	private function onSkinBgMouseDown(e:MouseEvent):Void 
	{
		
	}
	
	/**
	 * 滑块按下事件
	 * @param	e
	 */
	function onSliderMouseDown(e:MouseEvent):Void 
	{
		
	}
	
	function onEnterFrame(e:Event):Void
	{
		
	}
	
	function onMoveSlider(e:MouseEvent):Void
	{
		
	}
	
	
	/**
	 * 延迟一定时间后快速移动
	 */
	function delayMoveStart(cmdType:Int):Void
	{
		this._delayCMD = cmdType;
		this._delayTime = Timer.stamp();
		addEventListener(Event.ENTER_FRAME,onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_UP,dragOut);
		stage.addEventListener(Event.MOUSE_LEAVE,dragOut);
	}
	
	function dragOut(e:Event):Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMoveSlider);
		stage.removeEventListener(MouseEvent.MOUSE_UP,dragOut);
		stage.removeEventListener(Event.MOUSE_LEAVE,dragOut);
//		skin.stage.removeEventListener(Event.ENTER_FRAME,onMove);
		
		removeEventListener(Event.ENTER_FRAME,onEnterFrame);
	}
	
	///////////////////////////////////////
	
	/**
	 * 除掉上下按钮后可以滚动的距离
	 * @return 
	 */
	function getCanDist():Float
	{
		//if (direction == SparrowMgr.VERTICAL)
		return this.height;
		//else
		//return this.width;
	}
	
	/**
	 * 判断返回滚动条是否可用
	 * 是否能滚动,当显示内容比可视内容的高宽小时,不能滚动
	 * @return 
	 */
	override function get_enabled():Bool
	{
		if(!super.enabled)
		return super.enabled;
		
		if (minScrollValue >= maxScrollValue)
		return false;
		
		return super.enabled;
	}
	
	/**
	 * 设置中轴滚动的比例，不发滚动事件
	 * @param	value
	 */
	public function setScrollPercent(value:Float) 
	{
		if (value > 1)
		value = 1;
		else if (value < 0)
		value = 0;
		
		_scrollPercent = value;
	}
	
	/**
	 * 表示当前滚动位置的数值。值介于 minScrollValue 和 maxScrollValue 之间（包括两者）。
	 */
	public function getScrollPosition():Float
	{
		return _scrollPercent * (maxScrollValue - minScrollValue) / getCanDist();
	}
	
	/**
	 * 0~1之间的数,表示被盖住的显示容器与遮照容器的坐标比
	 * 以组件父代大小百分比的方式指定组件高度。允许的值为 0-1。默认值为 NaN。
	 */
	public var scrollPercent(get,set):Float;
	var _scrollPercent:Float = 0;
	function get_scrollPercent():Float
	{
		return _scrollPercent;
	}
	function set_scrollPercent(value:Float):Float
	{
		if(value>1) _scrollPercent = 1;
		else if(value<0) _scrollPercent = 0;
		else _scrollPercent = value;
		invalidateDraw();
		return _scrollPercent;
	}
	
	/**
	 * 最小滚动值
	 * 可以认为可视高度/宽度
	 */
	public var minScrollValue(get,set):Float;
	var _minScrollValue:Float = 0;
	function get_minScrollValue():Float
	{
		return _minScrollValue;
	}
	function set_minScrollValue(value:Float):Float
	{
		_minScrollValue = value;
		invalidateDraw();
		return _minScrollValue;
	}
	
	
	/**
	 * 最大滚动位值
	 * 可以认为是内容实际高度/宽度
	 */
	public var maxScrollValue(get,set):Float;
	var _maxScrollValue:Float = 10;
	function get_maxScrollValue():Float
	{
		return _maxScrollValue;
	}
	function set_maxScrollValue(value:Float):Float
	{
		_maxScrollValue = value;
		invalidateDraw();
		return _maxScrollValue;
	}
	
	/** 
	 * 被分隔成N分,上下箭头每点击一次移动的百分比
	 */
	public var stepValue:Float = 0.05;
		
	/**
	 * 是否跟椐位置信息自动设置slider的长宽
	 */
	public var autoSlider(get, set):Bool;
	var _autoSlider:Bool = true;
	
	function get_autoSlider():Bool
	{
		return _autoSlider;
	}
	
	function set_autoSlider(value:Bool):Bool
	{
		if (_autoSlider == value)
		return _autoSlider;
		_autoSlider = value;
		invalidateDraw();
		return _autoSlider;
	}
	
	/**
	 * 宽
	 */
	var _width:Float = 14;
	
	@:getter(width)
	#if flash
	function get_width():Float
	#else
	override function get_width():Float
	#end
	{
		return _width;
	}
	
	@:setter(width)
	#if flash
	function set_width(value:Float):Void
	#else
	override function set_width(value:Float):Float
	#end
	{
		if (_width == value)
		return#if !flash _width #end;
		_width = value;
		invalidateDraw();
		#if !flash return _width; #end
	}
	
	/**
	 * 高
	 */
	var _height:Float = 14;
	
	@:getter(height)
	#if flash
	function get_height():Float
	#else
	override function get_height():Float
	#end
	{
		return _height;
	}
	
	@:setter(height)
	#if flash
	function set_height(value:Float):Void
	#else
	override function set_height(value:Float):Float
	#end
	{
		if (_height == value)
		return #if !flash _height #end;
		_height = value;
		invalidateDraw();
		#if !flash return _height; #end
	}
	
	/**
	 * 按钮基本尺寸
	 
	public var compSize(get,set):Int = 14;
	var _compSize:Int = 14;
	
	function get_compSize():Int
	{
		return _compSize;
	}
	
	function set_compSize(value:Int):Int
	{
		if (_compSize == value)
		return _compSize;
		_compSize = value;
		invalidateDraw();
		return _compSize;
	}*/

	/**
	 * @private
	 
	public function get direction():String
	{
		return _direction;
	}*/
	
	/**
	 * 滚动样方便,横向还是纵向(ScrollBarBase.HORIZONTAL,ScrollBarBase.VERTICAL)
	 
	public function set direction(value:String):Void
	{
		if(value==SparrowMgr.HORIZONTAL)
			this._direction = SparrowMgr.HORIZONTAL;
		else
			this._direction = SparrowMgr.VERTICAL;
	}*/

	public var slider:DisplayObject;
	public var skinbg:DisplayObject;
	
	override private function getSkinId():String 
	{
		return StyleKeys.VSCROLL;
	}
}