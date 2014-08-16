package sparrowGui.components;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.Timer;
import sparrowGui.components.item.SButton;
import sparrowGui.skinStyle.StyleKeys;



/**
 * 纵向滚动条
 * 
 * 例子如下
 * 
	var s:ScrollBarBase = new VScrollBar();
	s.height = 100;
 *  //按钮停在最左端时是1，最右端是是100
	s.setSliderParams(1,100);
	addChild(s);
 * 
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class VScrollBar extends ScrollBarBase
{
	/**
	 * 向上按钮延迟命令
	 */
	inline static var DELAY_CMD_UPBTN:Int = 0;
	/**
	 * 向下按钮延迟命令
	 */
	inline static var DELAY_CMD_DOWNBTN:Int = 1;
	
	/**
	 * 向上按钮延迟命令
	 */
	inline static var DELAY_CMD_UPBG:Int = 5;
	/**
	 * 向下按钮延迟命令
	 */
	inline static var DELAY_CMD_DOWNBG:Int = 6;
	
	/**
	 * 构造纵向滚动条
	 * @param uiVars 皮肤变量
	 */
	public function new()
	{
		super();
		reset();
		
		_width = 14;
		_height = 100;
		invalidateDraw();
	}
	
	override  function buildSetUI():Void 
	{
		super.buildSetUI();
		
		upBtn = getChildByName("upBtn");
		downBtn = getChildByName("downBtn");
	}
	
	override public function reset():Void
	{
		if(upBtn != null)
		upBtn.addEventListener(MouseEvent.MOUSE_DOWN,onUpBtnDown);
		if(downBtn != null)
		downBtn.addEventListener(MouseEvent.MOUSE_DOWN, onDownBtnDown);
		super.reset();
	}
	
	override public function dispose():Void
	{
		if(upBtn != null)
		upBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onUpBtnDown);
		if(downBtn != null)
		downBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDownBtnDown);
		super.dispose();
	}
	
	override public function setScrollPercent(value:Float) 
	{
		super.setScrollPercent(value);
		var sy:Float = (upBtn != null)?upBtn.height:0;
		slider.y = sy + _scrollPercent * (getCanDist() - slider.height);
	}
	
	///////////////////////////////
	// 事件控制
	///////////////////////////////
	
	/**
	 * 向下按钮按下
	 * @param	e
	 */
	private function onDownBtnDown(e:MouseEvent):Void 
	{
		this.scrollPercent = this.scrollPercent + stepValue;
		freshSliderPosi();
		delayMoveStart(DELAY_CMD_DOWNBTN);
	}
	
	/**
	 * 向上按钮按下
	 * @param	e
	 */
	private function onUpBtnDown(e:MouseEvent):Void 
	{
		this.scrollPercent = this.scrollPercent - stepValue;
		freshSliderPosi();
		delayMoveStart(DELAY_CMD_UPBTN);
	}
	
	override private function onSliderMouseDown(e:MouseEvent):Void 
	{
		super.onSliderMouseDown(e);
		
		_sliderTrace = e.localY*slider.scaleY;
		stage.addEventListener(MouseEvent.MOUSE_MOVE,onMoveSlider);
		stage.addEventListener(MouseEvent.MOUSE_UP,dragOut);
		stage.addEventListener(Event.MOUSE_LEAVE,dragOut);
	}
	
	override private function onSkinBgMouseDown(e:MouseEvent):Void 
	{
		super.onSkinBgMouseDown(e);
		
		_sliderTrace = skinbg.mouseY*skinbg.scaleY;//e.localY*skinbg.scaleY;
		if(_sliderTrace>slider.y)
		{
			this.scrollPercent = this.scrollPercent + (this.slider.height / (getCanDist() - this.slider.height));
			delayMoveStart(DELAY_CMD_DOWNBG);
		}
		else
		{
			this.scrollPercent = this.scrollPercent - (this.slider.height / (getCanDist() - this.slider.height));
			delayMoveStart(DELAY_CMD_UPBG);
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
			case DELAY_CMD_UPBTN:		// 上按钮
			
			this.scrollPercent = this.scrollPercent - stepPercent;
			if (scrollPercent <= 0)
			dragOut(null);
			
			case DELAY_CMD_DOWNBTN:		// 下按钮
			
			this.scrollPercent = this.scrollPercent + stepPercent;
			if (scrollPercent >= 1)
			dragOut(null);
			
			case DELAY_CMD_UPBG:		// 上皮肤
			
			var nextVal:Float = slider.y;// - slider.height;
			if (nextVal < _sliderTrace)
			dragOut(null);
			else
			this.scrollPercent = this.scrollPercent - (this.slider.height / (getCanDist() - this.slider.height));
			
			case DELAY_CMD_DOWNBG:		// 下皮肤
			var nextVal:Float = slider.y + slider.height;
			if (nextVal > _sliderTrace)
			dragOut(null);
			else
			this.scrollPercent = this.scrollPercent + (this.slider.height/(getCanDist() - this.slider.height));
		}
		freshSliderPosi();
	}
	
	// 滚动条y坐标有变化
	override function onMoveSlider(e:MouseEvent):Void
	{
		var fy:Float = (this.upBtn!=null)?(this.upBtn.x + this.upBtn.height):skinbg.y;
		var ey:Float = (this.downBtn!=null)?(this.downBtn.y - this.slider.height):(this.height - this.slider.height);
		
		if((mouseY - this._sliderTrace)<fy)
			slider.y = fy;
		else if((mouseY - this._sliderTrace)>ey)
			slider.y = ey;
		else slider.y = mouseY - this._sliderTrace;
		
		this._scrollPercent = (this.slider.y - fy)/(getCanDist()-this.slider.height);
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 跟椐最大最小滚动位重设滚动条按钮高宽
	 */
	override function draw():Void
	{
		if(this.upBtn != null)
		this.upBtn.y = 0;
		if(this.downBtn != null)
		this.downBtn.y = this.height - this.downBtn.height;
		if (this.skinbg != null)
		this.skinbg.height = this.height;
		
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
					sbn.setSkinSize(14, autoVal);
				}
				else
				this.slider.height = autoVal;
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
		var scrollDist:Float = getCanDist() - this.slider.height;
		this.slider.y = ((this.upBtn != null)?this.upBtn.height:0) + scrollDist * scrollPercent;
	}
	
	///////////////////////////////
	// get/set 设置参数
	///////////////////////////////
	
	/**
	 * 除掉上下按钮后可以滚动的距离
	 * @return 
	 */
	override function getCanDist():Float 
	{
		return this.height - (this.upBtn!=null?this.upBtn.height:0) - (this.downBtn!=null?this.downBtn.height:0);
	}
	
	/**
	 * 是否可用
	 * @param value
	 */
	override function set_enabled(value:Bool):Bool
	{
		super.enabled = value;
		
		if(this.upBtn != null)
		this.upBtn.alpha = super.enabled ? 1.0 : 0.5;
		if(this.downBtn != null)
		this.downBtn.alpha = super.enabled ? 1.0 : 0.5;
		if(slider != null)
		this.slider.visible = super.enabled;
		
		return super.enabled;
	}
	
	@:setter(height)
	#if flash
	override function set_height(value:Float):Void
	#else
	override function set_height(value:Float):Float
	#end
	{
		if (value < ScrollBarBase.MIN_SCROLL_VALUE)
		value = ScrollBarBase.MIN_SCROLL_VALUE;
		
		super.height = value;
		#if !flash
		return super.height;
		#end
	}
	
	/**
	 * 上按钮
	 */
	public var upBtn:DisplayObject;

	/**
	 * 下按钮
	 */
	public var downBtn:DisplayObject;
	
	override private function getSkinId():String 
	{
		return StyleKeys.VSCROLL;
	}
}