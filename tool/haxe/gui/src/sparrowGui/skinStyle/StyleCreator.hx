package sparrowGui.skinStyle;
import asSkinStyle.draw.RectDraw;
import asSkinStyle.draw.RectSprite;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import sparrowGui.components.item.SButton;
import sparrowGui.components.STextField;
import sparrowGui.data.ItemState;
import sparrowGui.SparrowUtil;

/**
 * 样式方法,在这里创建默认的GUI皮肤
 * @author Pelephone
 */
class StyleCreator
{
	/**
	 * 创建按钮样式
	 */
	public static function createButton(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		createItem(skin);
		
		var selectState:RectDraw = getBaseRect();
		selectState.bgColor = 0xC6D0D0;
		selectState.name = ItemState.SELECT;
		skin.addChild(selectState);
		
		var txtLabel:STextField = getBaseText();
		txtLabel.textColor = 0x000000;
		skin.addChild(txtLabel);
		return skin;
	}
	
	/**
	 * 子项
	 */
	public static function createItem(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		#if flash
		var hitState:RectSprite = new RectSprite();
		//hitState.isNextDraw = false;
		hitState.bgColor = 0x000000;
		hitState.width = 80;
		hitState.height = 24;
		hitState.name = ItemState.HITTEST;
		skin.addChild(hitState);
		#end
		
		var enableState:RectDraw = getBaseRect();
		enableState.bgColor = 0xCCCCCC;
		enableState.name = ItemState.ENABLED;
		skin.addChild(enableState);
		
		var downState:RectDraw = getBaseRect();
		downState.bgColor = 0xc0cbcb;
		downState.borderColor = 0x3c7fb1;
		downState.name = ItemState.DOWN;
		skin.addChild(downState);
		
		var overState:RectDraw = getBaseRect();
		overState.bgColor = 0xFFFFFF;
		overState.borderColor = 0x3778a2;
		overState.inBgColor = 0xdaf0f0;
		overState.paddingTop = 2;
		overState.paddingLeft = 2;
		overState.name = ItemState.OVER;
		skin.addChild(overState);
		
		var upState:RectDraw = getBaseRect();
		upState.name = ItemState.UP;
		skin.addChild(upState);
		
		return skin;
	}
	
	/**
	 * 横向滚动条
	 */
	public static function createHScrollBar(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		var skinBg:RectSprite = new RectSprite();
		skinBg.name = "skinBg";
		skinBg.width = 100;
		skinBg.height = 14;
		skinBg.bgColor = 0xF0F0F0;
		skin.addChild(skinBg);
		
		var slider:SButton = new SButton();
		slider.setSkinSize(14, 14);
		slider.x = 14;
		slider.name = "slider";
		if (slider.labelText.parent != null)
		slider.labelText.parent.removeChild(slider.labelText);
		skin.addChild(slider);
		
		var shp:Shape = new Shape();
		shp.x = 4;
		shp.y = 4;
		SparrowUtil.drawArrow(shp.graphics,2);
		var leftBtn:SButton = new SButton();
		leftBtn.setSkinSize(14, 14);
		leftBtn.name = "leftBtn";
		if (leftBtn.labelText.parent != null)
		leftBtn.labelText.parent.removeChild(leftBtn.labelText);
		leftBtn.addChild(shp);
		skin.addChild(leftBtn);
		
		shp = new Shape();
		shp.x = 4;
		shp.y = 4;
		SparrowUtil.drawArrow(shp.graphics,3);
		var rightBtn:SButton = new SButton();
		rightBtn.name = "rightBtn";
		rightBtn.x = 86;
		rightBtn.setSkinSize(14, 14);
		if (rightBtn.labelText.parent != null)
		rightBtn.labelText.parent.removeChild(rightBtn.labelText);
		rightBtn.addChild(shp);
		skin.addChild(rightBtn);
		
		return skin;
	}
	
	/**
	 * 纵向滚动条
	 */
	public static function createVScrollBar(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		var skinBg:RectSprite = new RectSprite();
		skinBg.name = "skinBg";
		skinBg.width = 14;
		skinBg.height = 100;
		skinBg.bgColor = 0xF0F0F0;
		skin.addChild(skinBg);
		
		var slider:SButton = new SButton();
		slider.setSkinSize(14, 14);
		slider.y = 14;
		slider.name = "slider";
		if (slider.labelText.parent != null)
		slider.labelText.parent.removeChild(slider.labelText);
		skin.addChild(slider);
		
		var shp:Shape = new Shape();
		shp.x = 4;
		shp.y = 4;
		SparrowUtil.drawArrow(shp.graphics,0);
		var upBtn:SButton = new SButton();
		upBtn.setSkinSize(14, 14);
		upBtn.name = "upBtn";
		if (upBtn.labelText.parent != null)
		upBtn.labelText.parent.removeChild(upBtn.labelText);
		upBtn.addChild(shp);
		skin.addChild(upBtn);
		
		shp = new Shape();
		shp.x = 4;
		shp.y = 4;
		SparrowUtil.drawArrow(shp.graphics,1);
		var downBtn:SButton = new SButton();
		downBtn.name = "downBtn";
		downBtn.y = 86;
		downBtn.setSkinSize(14, 14);
		if (downBtn.labelText.parent != null)
		downBtn.labelText.parent.removeChild(downBtn.labelText);
		downBtn.addChild(shp);
		skin.addChild(downBtn);
		
		return skin;
	}
	
	/**
	 * 安卓滚动条
	 */
	public static function createTouchScroll(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		var rect:RectDraw = new RectDraw();
		rect.name = "scrollBg";
		rect.bgColor = 0xA0A0A1;
		rect.width = 10;
		rect.height = 80;
		var rect2:RectDraw = new RectDraw();
		rect2.name = "slider";
		rect2.bgColor = 0x454545;
		rect2.width = 10;
		rect2.height = 80;
		skin.addChild(rect);
		skin.addChild(rect2);
		return skin;
	}
	
	/**
	 * 提示窗
	 */
	public static function createAlert(skin:DisplayObjectContainer):DisplayObjectContainer
	{
		var padding:Int = 10;
		var rect:RectDraw = new RectDraw();
		rect.name = "bg";
		rect.bgColor = 0xFFFFFF;
		rect.width = 300;
		rect.height = 250;
		skin.addChild(rect);
		
		var txt:STextField = getBaseText();
		txt.width = 300 - padding * 2;
		txt.height = 200; 
		txt.x = padding;
		txt.y = padding;
		skin.addChild(txt);
		return skin;
	}
	
	/**
	 * 产生公共的矩形
	 */
	public static function getBaseRect():RectDraw
	{
		var rect:RectDraw = new RectDraw();
		//rect.setMouseEnable(false);
		rect.border = 1;
		rect.borderColor = 0x717171;
		rect.bgColor = 0xFFFFFF;
		rect.width = 80;
		rect.height = 24;
		return rect;
	}
	
	/**
	 * 基本样式
	 */
	public static function getBaseText():STextField
	{
		var txtLabel:STextField = new STextField();
		txtLabel.y = 2;
		//txtLabel.border = true;
		txtLabel.defaultTextFormat = TextStyle.getInstance().centerNormal;
		txtLabel.name = "txtLabel";
		txtLabel.setMouseEnable(false);
		txtLabel.width = 80;
		txtLabel.height = 22;
/*		#if html5
		txtLabel.border = true;
		txtLabel.borderColor = 0xFFFFFF;
		#end*/
		return txtLabel;
	}
}