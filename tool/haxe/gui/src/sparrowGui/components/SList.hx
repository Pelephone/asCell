package sparrowGui.components;

import flash.events.Event;
import flash.events.MouseEvent;
import sparrowGUI.components.Component;
import sparrowGui.components.item.SButton;
import sparrowGui.components.item.SItem;
import sparrowGui.data.ListSelectionData;
import sparrowGui.SparrowUtil;

/**
 * 列表组件
 * @author Pelephone
 */
class SList<T> extends Component
{

	public function new() 
	{
		super();
		
		_selectModel = new ListSelectionData();
		_selectModel.addEventListener(Event.CHANGE, onSelectDataChange);
		itemLs = [];
		
		#if !html5
		mouseEnabled = false;
		mouseChildren = true;
		#else
		isNextRender = false;
		#end
	}
	
	var itemLs:Array<SItem>;
	
	var isDataChange:Bool = false;
	
	/**
	 * 数据
	 */
	public var data(get, set):Array<T>;
	var _data:Array<T>;
	function get_data():Array<T>
	{
		return _data;
	}
	function set_data(value:Array<T>):Array<T>
	{
		if (_data == value)
		return _data;
		isDataChange = true;
		_data = value;
		invalidateDraw();
		return _data;
	}
	
/*	override public function invalidateDraw(args:Dynamic = null):Void 
	{
		super.invalidateDraw(args);
		SparrowUtil.addNextCall(layout,false);
	}*/
	
	//----------------------------------
	// 增删改查操作
	//----------------------------------
	
	/**
	 * 更新子项的方法
	 */
	public var updateItem:SItem->T->SItem;
	
	override private function draw():Void 
	{
		if(isDataChange)
		{
			isDataChange = false;
			removeAllItems();
			for (item in _data)
			{
				var sitm:SItem = createItem(item);
				sitm.name = "item_" + itemLs.length;
				sitm.setItemIndex(itemLs.length);
				addItem(sitm,item);
			}
		}
		onSelectDataChange();
		
		#if html5
		SparrowUtil.addNextCall(layout);
		#else
		layout();
		#end
		super.draw();
	}
	
	/**
	 * 添加子项
	 */
	public function addItem(item:SItem,itemData:T):SItem
	{
		if (item == null)
		return null;
		if (updateItem != null)
		updateItem(item,itemData);
		itemLs.push(item);
		addChild(item);
		item.addEventListener(MouseEvent.CLICK, onItemClick);
		return item;
	}
	
	/**
	 * 移除第N项
	 * @param	index
	 * @return
	 */
	public function removeItem(index:Int):SItem
	{
		if (itemLs.length > index)
		return null;
		var itm:SItem = itemLs.splice(index, 1)[0];
		itm.removeEventListener(MouseEvent.CLICK, onItemClick);
		itm.parent.removeChild(itm);
		_selectModel.removeSelect(index);
		return itm;
	}
	
	/**
	 * 查找第N项
	 * @param	index
	 * @return
	 */
	public function getItem(index:Int):SItem
	{
		if (itemLs.length > index)
		return null;
		return itemLs[index];
	}
	
	/**
	 * 子项类
	 */
	public var itemClass:Class<SItem>;
	
	/**
	 * 创建子项
	 * @param	itemData
	 * @return
	 */
	function createItem(itemData:T):SItem
	{
		var itm:SItem;
		if (itemClass == null)
		itm = new SButton();
		else
		itm = Type.createInstance(itemClass,[]);
		//itm = Type.createEmptyInstance(itemClass);
		itm.data = itemData;
		return itm;
	}
		
	/**
	 * 清除所有子项
	 */
	function removeAllItems()
	{
		for (itm in itemLs) 
		{
			itm.removeEventListener(MouseEvent.CLICK,onItemClick);
			itm.parent.removeChild(itm);
			itm.dispose();
			//SparrowMgr.removeInCLsCache(itm);
		}
		itemLs = [];
	}
	/**
	 * 反选
	 */
	public function invertSelect():Void
	{
		_selectModel.invertSelect(itemLs.length);
	}
	
	/**
	 * 子项点击事件
	 * @param	e
	 */
	function onItemClick(e:MouseEvent)
	{
		lastClickItem = cast e.currentTarget;
		_selectModel.setSelect(lastClickItem.getItemIndex());
		//sitm.label = sitm.name + "|" + sitm.labelText.width;
	}
	
	// 最后点击的项
	public var lastClickItem:SItem;
	
	/**
	 * 选中数据改变
	 * @param	e
	 */
	function onSelectDataChange(e:Event=null):Void 
	{
		//var tarData:T;
		for (i in 0...itemLs.length) 
		{
			var itm:SItem = itemLs[i];
			var itmSelected:Bool = _selectModel.isSelect(i);
			itm.selected = itmSelected;
			//if(itmSelected)
			//selectItm = itm;
			//itm.label = "1" + itmSelected;
		}
		
		dispatchEvent(new Event(Event.SELECT));
	}
	
	//---------------------------------------------------
	// 选择操作
	//---------------------------------------------------
	
	var _selectModel:ListSelectionData;
	
	public var selectIndex(get, set):Int;
	function get_selectIndex():Int
	{
		return _selectModel.getSelectIndex();
	}
	
	function set_selectIndex(value:Int):Int
	{
		return _selectModel.setSelect(value);
	}
	
	/**
	 * 是否支持多选，默认只能单选
	 */
	public var multiSelect(get, set):Bool;
	function get_multiSelect():Bool
	{
		return _selectModel.multiSelect;
	}
	function set_multiSelect(value:Bool):Bool
	{
		_selectModel.multiSelect = value;
		return value;
	}
	
	/**
	 * 至少有一个项被选中
	 */
	public var mustSelect(get, set):Bool;
	public function get_mustSelect():Bool
	{
		return _selectModel.mustSelect;
	}
	public function set_mustSelect(value:Bool):Bool
	{
		_selectModel.mustSelect = value;
		return _selectModel.mustSelect;
	}
	
	/**
	 * 已选中的id组
	 */
	public function getSelectIds():Array<Int>
	{
		return _selectModel.getSelectIds();
	}
	
	/**
	 * 选中项数据
	 * @return 
	 */
	public function getSelectData():T
	{
		if (selectIndex >= 0 && data.length > selectIndex)
		return data[selectIndex];
		if (_selectModel.mustSelect && data != null && data.length > 0)
		return data[0];
		
		return null;
	}
	
	//---------------------------------------------------
	// 布局相关
	//---------------------------------------------------
	
	/**
	 * 子项高
	 */
	public var itemHeight(get,set):Int;
	var _itemHeight:Int = 0;
	function get_itemHeight():Int
	{
		return _itemHeight;
	}
	function set_itemHeight(value:Int):Int
	{
		if (value == _itemHeight)
		return _itemHeight;
		_itemHeight = value;
		SparrowUtil.addNextCall(layout);
		return _itemHeight;
	}
	
	/**
	 * 子项宽
	 */
	public var itemWidth(get, set):Int;
	var _itemWidth:Int = 0;
	function get_itemWidth():Int
	{
		return _itemWidth;
	}
	function set_itemWidth(value:Int):Int
	{
		if (_itemWidth == value)
		return _itemWidth;
		_itemWidth = value;
		SparrowUtil.addNextCall(layout);
		return _itemWidth;
	}
	
	/**
	 * 每列有多少项,-1表示自动通过width和itemWidth计算每列个数
	 */
	public var colNum(get, set):Int;
	var _colNum:Int = 1;
	function get_colNum():Int
	{
		return _colNum;
	}
	function set_colNum(value:Int):Int
	{
		if (_colNum == value)
		return _colNum;
		_colNum = value;
		SparrowUtil.addNextCall(layout);
		return _colNum;
	}
	
	/**
	 * 行列子项间隔
	 */
	public var spacing(get, set):Int;
	var _spacing:Int = 0;
	function get_spacing():Int
	{
		return _spacing;
	}
	function set_spacing(value:Int):Int
	{
		if (_spacing == value)
		return _spacing;
		_spacing = value;
		SparrowUtil.addNextCall(layout);
		return _spacing;
	}
	
	/**
	 * 子项布局方法
	 */
	public var layoutCall:Array<SItem>->Int->Int->Int->Int->Void;
	/**
	 * 进行一次布局
	 */
	function layout() 
	{
		if (layoutCall != null)
		layoutCall(itemLs, colNum, spacing, itemWidth, itemHeight);
		else
		SparrowUtil.layoutUtil(cast itemLs, colNum, spacing, itemWidth, itemHeight);
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 子项数量
	 * @return 
	 */
	function getItemLength():Int 
	{
		return itemLs.length;
	}
}