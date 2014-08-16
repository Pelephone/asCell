package sparrowGui.components;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.Timer;
import sparrowGui.components.item.SButton;
import sparrowGui.skinStyle.StyleKeys;



/**
 * 横向滚动条
 * 
 * 例子如下
 * 
	var s:ScrollBarBase = new HScrollBar();
	s.width = 100;
 *  //按钮停在最左端时是1，最右端是是100
	s.setSliderParams(1,100);
	addChild(s);
 * 
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class HScrollBar extends ScrollBarBase
{
	/**
	 * 向左按钮延迟命令
	 */
	inline static var DELAY_CMD_LEFTBTN:Int = 2;
	/**
	 * 向右按钮延迟命令
	 */
	inline static var DELAY_CMD_RIGHTBTN:Int = 3;
	
	/**
	 * 向左按钮延迟命令
	 */
	inline static var DELAY_CMD_LEFTBG:Int = 7;
	/**
	 * 向右按钮延迟命令
	 */
	inline static var DELAY_CMD_RIGHTBG:Int = 8;
	
	/**
	 * 构造纵向滚动条
	 * @param uiVars 皮肤变量
	 */
	public function new()
	{
		super();
		reset();
		_width = 100;
		_height = 14;
		invalidateDraw();
	}
	
	override  function buildSetUI():Void 
	{
		super.buildSetUI();
		
		leftBtn = getChildByName("leftBtn");
		rightBtn = getChildByName("rightBtn");
	}
	
	override public function reset():Void
	{
		if(leftBtn != null)
		leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftBtnDown);
		if(rightBtn != null)
		rightBtn.addEventListener(MouseEvent.MOUSE_DOWN, onRightBtnDown);
		super.reset();
	}
	
	override public function dispose():Void
	{
		if(leftBtn != null)
		leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftBtnDown);
		if(rightBtn != null)
		rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onRightBtnDown);
		super.dispose();
	}
	
	override public function setScrollPercent(value:Float) 
	{
		super.setScrollPercent(value);
		var sx:Float = (leftBtn != null)?leftBtn.width:0;
		slider.x = sx + _scrollPercent * (getCanDist() - slider.width);
	}
	
	///////////////////////////////
	// 事件控制
	///////////////////////////////
	
	/**
	 * 向右按钮按下
	 * @param	e
	 */
	private function onRightBtnDown(e:MouseEvent):Void 
	{
		this.scrollPercent = this.scrollPercent + stepValue;
		freshSliderPosi();
		delayMoveStart(DELAY_CMD_RIGHTBTN);
	}
	
	/**
	 * 向左按钮按下
	 * @param	e
	 */
	private function onLeftBtnDown(e:MouseEvent):Void 
	{
		this.scrollPercent = this.scrollPercent - stepValue;
		freshSliderPosi();
		delayMoveStart(DELAY_CMD_LEFTBTN);
	}
	
	override private function onSliderMouseDown(e:MouseEvent):Void 
	{
		super.onSliderMouseDown(e);
		
		_sliderTrace = e.localX*slider.scaleX;
		stage.addEventListener(MouseEvent.MOUSE_MOVE,onMoveSlider);
		stage.addEventListener(MouseEvent.MOUSE_UP,dragOut);
		stage.addEventListener(Event.MOUSE_LEAVE,dragOut);
	}
	
	override private function onSkinBgMouseDown(e:MouseEvent):Void 
	{
		super.onSkinBgMouseDown(e);
		
		_sliderTrace = skinbg.mouseX*skinbg.scaleX;
		if (_sliderTrace > slider.x)
		{
			this.scrollPercent = this.scrollPercent + (this.slider.width / (getCanDist() - this.slider.width));
			delayMoveStart(DELAY_CMD_RIGHTBG);
		}
		else
		{
			this.scrollPercent = this.scrollPercent - (this.slider.width / (getCanDist() - this.slider.width));
			delayMoveStart(DELAY_CMD_LEFTBG);
		}
	}
	
	/**
	 * 听每帧事件,实现延迟快速移动效果
	 * @param e
	 */
	override function onEnterFrame(e:Event):Void
	{
		// 延迟后快速移动
		if((Timer.stamp() - _delayTime) < 0.5)
		return;
		var stepPercent:Float = stepValue;
		switch(this._delayCMD)
		{
			case DELAY_CMD_LEFTBTN:		// 左按钮
			
			this.scrollPercent = this.scrollPercent - stepPercent;
			if (scrollPercent <= 0)
			dragOut(null);
			
			case DELAY_CMD_RIGHTBTN:		// 右按钮
			
			this.scrollPercent = this.scrollPercent + stepPercent;
			if (scrollPercent >= 1)
			dragOut(null);
			
			case DELAY_CMD_LEFTBG:		// 左皮肤
			
			var nextVal:Float = slider.x;// - slider.width;
			if (nextVal < _sliderTrace)
			dragOut(null);
			else
			this.scrollPercent = this.scrollPercent - (this.slider.width / (getCanDist() - this.slider.width));
			
			case DELAY_CMD_RIGHTBG:		// 右皮肤
			var nextVal:Float = slider.x + slider.width;
			if (nextVal > _sliderTrace)
			dragOut(null);
			else
			this.scrollPercent = this.scrollPercent + (this.slider.width/(getCanDist() - this.slider.width));
		}
		freshSliderPosi();
	}
	
	// 滚动条y坐标有变化
	override function onMoveSlider(e:MouseEvent):Void
	{
		var fy:Float = (this.leftBtn!=null)?(this.leftBtn.x + this.leftBtn.width):skinbg.x;
		var ey:Float = (this.rightBtn!=null)?(this.rightBtn.x - this.slider.width):(this.width - this.slider.width);
		
		if((mouseX - this._sliderTrace)<fy)
			slider.x = fy;
		else if((mouseX - this._sliderTrace)>ey)
			slider.x = ey;
		else slider.x = mouseX - this._sliderTrace;
		
		this._scrollPercent = (this.slider.x - fy)/(getCanDist()-this.slider.width);
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 跟椐最大最小滚动位重设滚动条按钮高宽
	 */
	override function draw():Void
	{
		if(this.leftBtn != null)
		this.leftBtn.x = 0;
		if(this.rightBtn != null)
		this.rightBtn.x = this.width - this.rightBtn.width;
		if (this.skinbg != null)
		this.skinbg.width = this.width;
		
		if(this.slider != null && enabled)
		{
			// 最大范围
			if(this.autoSlider)
			{
				var autoVal:Float = this.minScrollValue * getCanDist() / this.maxScrollValue;
				if (autoVal < ScrollBarBase.MIN_SLIDER_VALUE)
				autoVal = ScrollBarBase.MIN_SLIDER_VALUE;
				if (Std.is(slider, SButton))
				{
					var sbn:SButton = cast slider;
					sbn.setSkinSize(autoVal,14);
				}
				else
				this.slider.width = autoVal;
			}
			freshSliderPosi();
		}
		
		scrollChange();
		super.draw();
	}
	
	/**
	 * 刷新slider的位置
	 */
	override public function freshSliderPosi():Void
	{
		if(this.slider == null || !enabled)
		return;
		// 减少slider后,能滚动的范围
		var scrollDist:Float = getCanDist() - this.slider.width;
		this.slider.x = ((this.leftBtn != null)?this.leftBtn.width:0) + scrollDist * scrollPercent;
	}
	
	///////////////////////////////
	// get/set 设置参数
	///////////////////////////////
	
	/**
	 * 除掉左右按钮后可以滚动的距离
	 * @return 
	 */
	override function getCanDist():Float 
	{
		return this.width - (this.leftBtn!=null?this.leftBtn.width:0) - (this.rightBtn!=null?this.rightBtn.width:0);
	}
	
	/**
	 * 是否可用
	 * @param value
	 */
	override function set_enabled(value:Bool):Bool
	{
		super.enabled = value;
		
		if(this.leftBtn != null)
		this.leftBtn.alpha = super.enabled ? 1.0 : 0.5;
		if(this.rightBtn != null)
		this.rightBtn.alpha = super.enabled ? 1.0 : 0.5;
		if(slider != null)
		this.slider.visible = super.enabled;
		
		return super.enabled;
	}
	
	@:setter(width)
	#if flash
	override function set_width(value:Float):Void
	#else
	override function set_width(value:Float):Float
	#end
	{
		if (value < ScrollBarBase.MIN_SCROLL_VALUE)
		value = ScrollBarBase.MIN_SCROLL_VALUE;
		
		super.width = value;
		#if !flash
		return super.width;
		#end
	}
	
	/**
	 * 左按钮
	 */
	public var leftBtn:DisplayObject;

	/**
	 * 右按钮
	 */
	public var rightBtn:DisplayObject;
	
	override private function getSkinId():String 
	{
		return StyleKeys.HSCROLL;
	}
}