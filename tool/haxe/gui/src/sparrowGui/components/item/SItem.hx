package sparrowGui.components.item;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import sparrowGUI.components.Component;
import sparrowGui.data.ItemState;
import sparrowGui.skinStyle.StyleKeys;
import sparrowGui.SparrowUtil;

/**
 * 基本项,带有基本的按钮四态，类似于SimplyButton
 * (此组件并没绑定鼠标事件)
 * 
 * 例子如下
 * 
 * var itm:SItem = new SListItem();
	itm.update("按钮文字");
	addChild(itm);
 * 
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class SItem extends Component
{
	public function new()
	{
		super();
		
		//isNextRender = false;
		reset();
	}
	
	override function buildSetUI() 
	{
		super.buildSetUI();
		
		this.mouseChildren = false;
		
		upState = getChildByName(ItemState.UP);
		overState = getChildByName(ItemState.OVER);
		downState = getChildByName(ItemState.DOWN);
		hitTestState = getChildByName(ItemState.HITTEST);
		enableState = getChildByName(ItemState.ENABLED);
		
		
		#if flash
		if (hitTestState != null && Std.is(hitTestState,Sprite))
		this.hitArea = cast hitTestState;
		#else
		if(hitTestState!=null && hitTestState.parent != null)
		hitTestState.parent.removeChild(hitTestState);
		#end
		
		setCurrentState(ItemState.UP);
	}
	
	/**
	 * UI改变,留接口给MyList调用
	 */
	public function changeUI()
	{
		
	}
	
	override private function getSkinId():String 
	{
		return StyleKeys.ITEM;
	}
	
	/**
	 * @inheritDoc
	 
	override private function draw():Void
	{
		if(isRendering)
		{
			if(hitTestState)
				hitTestState.width = _width;
			if(upState)
				upState.width = _width;
			if(overState)
				overState.width = _width;
			if(downState)
				downState.width = _width;
			
			if(hitTestState)
				hitTestState.height = _height;
			if(upState)
				upState.height = _height;
			if(overState)
				overState.height = _height;
			if(downState)
				downState.height = _height;
			
			if(parent && parent is SList)
				(parent as SList).invalidateLayout();
		}
		
		super.draw();
	}*/
	
	public var data(get, set):Dynamic;
	var _data:Dynamic;
	function set_data(value:Dynamic):Dynamic
	{
		if(_data == value)
		return _data;
		
		_data = value;
		SparrowUtil.addNextCall(parseData);
		return _data;
	}
	function get_data():Dynamic
	{
		return _data;
	}
	
	/**
	 * 将数据解析到此项
	 */
	function parseData():Void
	{
	}
		
	var _itemIndex:Int = -1;
	
	public function setItemIndex(value:Int):Void
	{
		if(value == _itemIndex)
			return;
		_itemIndex = value;
	}
	
	public function getItemIndex():Int
	{
		return _itemIndex;
	}
	
	//---------------------------------------------------
	// 状态相关
	//---------------------------------------------------
	
	var _currentState:String;
	
	public function getCurrentState():String
	{
		return _currentState;
	}
	
	public function setCurrentState(value:String):Void
	{
		if(_currentState == value)
			return;
		_currentState = value;
		intvalStateRender();
	}
	
	/**
	 * 验证渲染状态显示
	 */
	function intvalStateRender():Void
	{
		isStateRendering = true;
		if(isNextRender)
			SparrowUtil.addNextCall(stateRender);
		else
			stateRender();
	}
	
	/**
	 * 状态是否正在渲染
	 */
	var isStateRendering:Bool = true;
	
	/**
	 * 状态渲染
	 */
	public function stateRender():Void
	{
		if(isStateRendering)
		{
			isStateRendering = false;
			hiddenState();
			var stateDsp:DisplayObject = getChildByName(_currentState);
			if (stateDsp == null && _currentState == ItemState.SELECT)
			{
				stateDsp = getChildByName(ItemState.SELECT);
				if (stateDsp == null)
				stateDsp = overState;
			}
			if (stateDsp != null)
			stateDsp.visible = true;
			else if (upState != null)
			upState.visible = true;
		}
	}
	
	override function set_enabled(value:Bool):Bool
	{
		if(value == _enabled)
			return _enabled;
		_enabled = value;
		super.enabled = value;
		if(!value)
		setCurrentState(ItemState.ENABLED);
		else
		setCurrentState(ItemState.UP);
		
		return _enabled;
	}
	
	public var selected(get,set):Bool;
	private var _selected:Bool = false;
	
	/**
	 * @private
	 */
	function get_selected():Bool
	{
		return _selected;
	}
	
	/**
	 * 是否已选择
	 * @param value
	 */
	function set_selected(value:Bool):Bool
	{
		if(_selected == value)
		return _selected;
		
		_selected = value;
		
		if(value)
		setCurrentState(ItemState.SELECT);
		else
		setCurrentState(ItemState.UP);
		
		return _selected;
	}
	
	public function setState(stateName:String, value:Dynamic = null):Void
	{
		switch(stateName)
		{
			case ItemState.ENABLED:
			{
				enabled = value;
			}
			case ItemState.SELECT:
			{
				selected = value;
			}
			default:
			{
				if (SparrowUtil.indexOf(getStates(), stateName) >= 0)
					setCurrentState(stateName);
			}
		}
	}
	
	/**
	 * 可以改变的状态数组
	 * @return 
	 */
	function getStates():Array<String>
	{
		return [ItemState.UP,ItemState.OVER,ItemState.DOWN,ItemState.ENABLED];
	}
	
	/**
	 * 隐藏所有状态
	 */
	function hiddenState():Void
	{
		for(sName in getStates())
		{
			var dp:DisplayObject = getChildByName(sName);
			if(dp != null)
			dp.visible = false;
		}
	}
	
	/**
	 * 抬起状态
	 */
	public var upState:DisplayObject;

	/**
	 * 经过状态
	 */
	public var overState:DisplayObject;
	/**
	 * 按下状态
	 */
	public var downState:DisplayObject;
	/**
	 * 热区
	 */
	public var hitTestState:DisplayObject;
	/**
	 * 不可操作状态
	 */
	public var enableState:DisplayObject;
	
	override public function setSkinSize(w:Float, h:Float) 
	{
		if(upState != null)
		{
			upState.width = w;
			upState.height = h;
		}
		if(overState != null)
		{
			overState.width = w;
			overState.height = h;
		}
		if (downState != null)
		{
			downState.width = w;
			downState.height = h;
		}
		if(hitTestState != null)
		{
			hitTestState.width = w;
			hitTestState.height = h;
			
			#if flash
			if (Std.is(hitTestState,Sprite))
			this.hitArea = cast hitTestState;
			#end
		}
		if(enableState != null)
		{
			enableState.width = w;
			enableState.height = h;
		}
		super.setSkinSize(w, h);
	}
		
	//---------------------------------------------------
	// 池用接口
	//---------------------------------------------------
	
	override public function dispose():Void
	{
		_itemIndex = -1;
		_data = null;
		if(this.parent != null)
			parent.removeChild(this);
	}
	
	public function reset():Void
	{
		enabled = true;
		selected = false;
	}
	
	/* INTERFACE sparrowGui.i.IItem */
	
	public function addToParent(parentDSP:DisplayObjectContainer):Void 
	{
		if (parentDSP != null)
		parentDSP.addChild(this);
	}
	
	/* INTERFACE sparrowGui.i.IItem */
	
	public function setName(value:String):Void 
	{
		name = value;
	}
	
	public function getName():String 
	{
		return name;
	}
}