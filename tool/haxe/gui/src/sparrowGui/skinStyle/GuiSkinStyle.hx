package sparrowGui.skinStyle;
import flash.display.DisplayObjectContainer;
import flash.errors.Error;

/**
 * 样式管理
 * 用静态工厂创建默认的GUI皮肤
 * @author Pelephone
 */
class GuiSkinStyle
{

	public function new() 
	{
		if(instance != null)
			throw new Error("SkinStyle is singleton class and allready exists!");
		
		init();
		instance = this;
	}
	
	/**
	 * 单例
	 */
	private static var instance:GuiSkinStyle;
	/**
	 * 获取单例
	 */
	public static function getInstance():GuiSkinStyle
	{
		if(instance == null)
			instance = new GuiSkinStyle();
		
		return instance;
	}
	
	/**
	 * 样式名与创建方法的映射
	 */
	var idToFunMap:Map<String,DisplayObjectContainer->DisplayObjectContainer>;
	
	function init()
	{
		idToFunMap = new Map < String, DisplayObjectContainer->DisplayObjectContainer > ();
		
		// 在这里注册映射样式方法
		regStyleFun(StyleKeys.BUTTON, StyleCreator.createButton);
		regStyleFun(StyleKeys.ITEM, StyleCreator.createItem);
		regStyleFun(StyleKeys.VSCROLL, StyleCreator.createVScrollBar);
		regStyleFun(StyleKeys.HSCROLL, StyleCreator.createHScrollBar);
		regStyleFun(StyleKeys.ALERT, StyleCreator.createAlert);
		regStyleFun(StyleKeys.TOUCH_SCROLL, StyleCreator.createTouchScroll);
	}
	
	/**
	 * 创建样式映射
	 * @param	id
	 * @param	DisplayObject->DisplayObject
	 */
	public function regStyleFun(id:String,f:DisplayObjectContainer->DisplayObjectContainer):Void 
	{
		idToFunMap.set(id, f);
	}
	
	/**
	 * 是否存在样式的映射
	 */
	public function hasStyleFun(id:String):Bool 
	{
		return idToFunMap.exists(id);
	}
	
	/**
	 * 获取样式对应的方法
	 */
	public function getStyleFun(id:String) :DisplayObjectContainer->DisplayObjectContainer
	{
		if (!idToFunMap.exists(id))
		return null;
		return idToFunMap.get(id);
	}
}