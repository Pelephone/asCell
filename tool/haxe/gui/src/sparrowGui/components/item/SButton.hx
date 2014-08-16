package sparrowGui.components.item;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import sparrowGui.components.STextField;
import sparrowGui.data.ItemState;
import sparrowGui.skinStyle.StyleKeys;
import sparrowGui.SparrowUtil;


/**
 * 按钮组件，相比Item监听鼠标操作相关事件
 * 
 * 例子如下
 * 
 * var itm:SItem = new SButton();
	itm.update("按钮文字");
	addChild(itm);
 * 
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class SButton extends SItem
{
	/**
	 * 构造按钮组件
	 * @param uiVars
	 */
	public function new()
	{
		super();
	}
	
	/**
	 * @inheritDoc
	 */
	override function buildSetUI()
	{
		super.buildSetUI();
		
		selecState = getChildByName(ItemState.SELECT);
		
		var tDsp:DisplayObject = getChildByName("txtLabel");
		if(Std.is(tDsp,TextField))
		labelText = cast tDsp;
		
		this.buttonMode = true;
		this.useHandCursor = true;
		this.mouseChildren = false;
	}
	
	override private function getSkinId():String 
	{
		return StyleKeys.BUTTON;
	}
	
	/**
	 * @inheritDoc
	 */
	override function parseData()
	{
		super.parseData();
		
		if(labelText != null)
		labelText.text = label;
	}
	
	override function set_data(value:Dynamic):Dynamic 
	{
		super.data = value;
		label = Std.string(value);
		return super.data;
	}
	
	/**
	 * 按钮文字显示文字
	 */
	public var label(get,set):String;
	var _label:String;
	function get_label():String
	{
		return _label;
	}
	function set_label(value:String):String
	{
		if(_label == value)
		return _label;
		_label = value;
		SparrowUtil.addNextCall(parseData);
		return _label;
	}
	
	/**
	 * 文字文本
	 */
	public var labelText:STextField;
	
	/**
	 * @inheritDoc
	 */
	override public function setCurrentState(value:String):Void
	{
		if(selected)
			super.setCurrentState(ItemState.SELECT);
		else if(!enabled)
			super.setCurrentState(ItemState.ENABLED);
		else
			super.setCurrentState(value);
	}
	
	override private function getStates():Array<String> 
	{
		return [ItemState.UP,ItemState.OVER,ItemState.DOWN,ItemState.ENABLED,ItemState.SELECT];
	}
	
	/**
	 * 选中状态
	 */
	public var selecState:DisplayObject;
	
	//---------------------------------------------------
	// 事件
	//---------------------------------------------------
	
	function addSkinListen():Void
	{
		// ROLL_OVER无视子对象事件,MOUSE_OVER相反
		this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP,onEvtOut);
		this.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
	}
	
	function removeSkinListen():Void
	{
		this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		this.removeEventListener(MouseEvent.MOUSE_UP,onEvtOut);
		this.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
		if (this.stage == null)
		return;
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, onEvtOut);
		this.stage.removeEventListener(Event.MOUSE_LEAVE, onEvtOut);
	}
	
	/**
	 * 鼠标经过事件
	 * @param e
	 */
	function onRollOver(e:MouseEvent):Void
	{
		if(!enabled || selected)
		return;
		
		//useHandCursor = true;
		setCurrentState(ItemState.OVER);
	}
	
	/**
	 * 鼠标按下
	 * @param e
	 */
	function onMouseDown(e:MouseEvent):Void
	{
		if(!enabled || selected)
			return;
		
		setCurrentState(ItemState.DOWN);
		
		if (this.stage == null)
		return;
		
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onEvtOut);
		this.stage.addEventListener(Event.MOUSE_LEAVE,onEvtOut);
		
		this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		this.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
	}
	
	/**
	 * 移开事件
	 * @param e
	 */
	function onEvtOut(e:Event):Void
	{
		if(!enabled || selected)
			return;
		
		//useHandCursor = false;
		//var me:MouseEvent = null;
		//if(Std.is(e,MouseEvent))
		//me = cast e;
		//var isOver:Bool = (e != null && e.target == this);
		//if(!isOver)
			//setCurrentState(ItemState.UP);
		//else
			//setCurrentState(ItemState.OVER);
		setCurrentState(ItemState.UP);
		
		if (this.stage != null)
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onEvtOut);
			this.stage.removeEventListener(Event.MOUSE_LEAVE, onEvtOut);
		}
		
		this.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
		this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		this.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
	}
	
	/**
	 * 鼠标移开事件
	 */
	function onRollOut(e:MouseEvent):Void
	{
		if(!enabled || selected)
			return;
		
		setCurrentState(ItemState.UP);
	}
	
	override public function setSkinSize(w:Float, h:Float) 
	{
		if(selecState != null)
		{
			selecState.width = w;
			selecState.height = h;
		}
		if (labelText != null)
		{
			labelText.width = w;
			labelText.height = h;
		}
		super.setSkinSize(w, h);
	}
	
	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		removeSkinListen();
		super.dispose();
	}
	
	/**
	 * @inheritDoc
	 */
	override public function reset():Void
	{
		super.reset();
		addSkinListen();	
	}
}