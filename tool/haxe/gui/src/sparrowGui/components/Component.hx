package sparrowGui.components;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import sparrowGui.skinStyle.GuiSkinStyle;
import sparrowGui.skinStyle.StyleKeys;
import sparrowGui.SparrowUtil;

/**
 * 基本组件
 * @author Pelephone
 */
class Component extends Sprite
{

	public function new() 
	{
		super();
		buildSetUI();
	}
	
	/**
	 * 建立皮肤样式
	 */
	function buildSetUI()
	{
		if (skinFunc != null)
		{
			skinFunc(this);
			return;
		}
		
		var skinId:String = getSkinId();

		var gss:GuiSkinStyle = GuiSkinStyle.getInstance();
		if(gss.hasStyleFun(skinId))
		{
			var f:DisplayObjectContainer->DisplayObjectContainer = gss.getStyleFun(skinId);
			f(this);
		}
	}
	
	/**
	 * 生成创建的方法
	 */
	public var skinFunc:DisplayObjectContainer->DisplayObjectContainer = null;
	
	public var isNextRender:Bool = true;
	
	/**
	 * 验证重绘,会在下帧渲染的时候调用draw方法
	 */
	public function invalidateDraw(args:Dynamic = null):Void
	{
		if(isNextRender)
		SparrowUtil.addNextCall(draw);
		else
		draw();
	}
	
	function draw():Void
	{
		
	}
	
	function getSkinId():String
	{
		return StyleKeys.COMPONENT;
	}
	
	//---------------------------------------------------
	// enabled
	//---------------------------------------------------
	
	/**
	 * 是否可用
	 */
	public var enabled(get, set):Bool;
	var _enabled:Bool = true;
	function get_enabled():Bool
	{
		return _enabled;
	}
	function set_enabled(value:Bool):Bool
	{
		_enabled = value;
		this.mouseEnabled = value;
		return _enabled;
	}
	
	/**
	 * 设置皮肤尺寸
	 */
	public function setSkinSize(w:Float,h:Float) 
	{
		
	}
	
	/**
	 * 销毁对象
	 */
	public function dispose():Void
	{
		
	}
}