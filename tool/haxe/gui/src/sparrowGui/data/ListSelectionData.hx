package sparrowGui.data;

import flash.events.Event;
import flash.events.EventDispatcher;


/**
 * 选中数据(Model)
 * 有添加删除选中项等方法
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class ListSelectionData extends EventDispatcher
{
	/** 项选中状态改变. **/
	//[Event(name="list_item_select", 	type="sparrowGui.event.ListEvent")]
	
	/**
	 * 选中项index索引数组数据
	 */
	private var indexLs:Array<Int>;
	
	/**
	 * 构造选中项数据
	 * @param target
	 */
	public function new()
	{
		super();
		indexLs = [];
	}
	
	/**
	 * 设置选中项
	 * @param index
	 */
	public function setSelect(index:Int):Int
	{
		if(isSelect(index))
		{
			removeSelect(index);
			dispatchEvent(new Event(Event.CHANGE));
			return index;
		}
		
		if(!multiSelect)
			indexLs = [index];
		else
			indexLs.push(index);
		
		dispatchEvent(new Event(Event.CHANGE));
		return index;
	}
	
	/**
	 * 添加选项
	 * @param index
	 */
	public function addSelect(index:Int):Void
	{
		if(!multiSelect)
			setSelect(index);
		else if(multiSelect && indexOf(indexLs,index)<0)
			indexLs.push(index);
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 移除选项
	 * @param index
	 */
	public function removeSelect(index:Int):Void
	{
		// 至少选中一项
		if (mustSelect && indexLs.length <= 1)
		return;
		
		var vid:Int = indexOf(indexLs,index);
		if (vid >= 0)
		indexLs.splice(vid,1);
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	/**
	 * 移除所有选中项
	 */
	public function removeAllSelect():Void
	{
		// 至少选中一项
		if(mustSelect && indexLs.length>1)
			indexLs = indexLs.splice(0,1);
		else
			indexLs = [];
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	public function addListSelectionListener(listener:Dynamic->Void):Void
	{
		addEventListener(Event.CHANGE,listener);
	}
	
	public function removeListSelectionListener(listener:Dynamic->Void):Void
	{
		removeEventListener(Event.CHANGE,listener);
	}
	
	/**
	 * 反选(此方法用时必须传一个最大项,即当前组件有多少项)
	 */
	public function invertSelect(max:Int=0):Void
	{
		if (!multiSelect && max < 2)
		return;
		
		var newValue:Array<Int> = [];
		for (i in 0...max) 
		{
			if(indexOf(indexLs,i)<0)
				newValue.push(i);
		}
		if (!multiSelect && newValue.length > 1)
		newValue = newValue.splice(0, 1);
		indexLs = newValue;
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	public function getSelectIndex():Int
	{
		if(indexLs.length > 0)
		return indexLs[0];
		else
		return -1;
	}
	
	public function getSelectIds():Array<Int>
	{
		return indexLs;
	}
	
	
	public function isSelect(index:Int):Bool
	{
		return indexOf(indexLs,index)>=0;
	}
	
	/////////////////////////////////////////////////////
	// multiSelect
	/////////////////////////////////////////////////////
	
	/**
	 * 是否支持多选，默认只能单选
	 */
	public var multiSelect(get,set):Bool;
	var _multiSelect:Bool = false;
	
	function get_multiSelect():Bool
	{
		return _multiSelect;
	}
	function set_multiSelect(value:Bool):Bool
	{
		if (_multiSelect == value)
		return _multiSelect;
		_multiSelect = value;
		return _multiSelect;
	}
	
	/////////////////////////////////////////////////////
	// mushSelect
	/////////////////////////////////////////////////////
	
	/**
	 * 至少有一个项被选中
	 */
	public var mustSelect(get,set):Bool;
	var _mustSelect:Bool = true;
	function get_mustSelect():Bool
	{
		return _mustSelect;
	}
	function set_mustSelect(value:Bool):Bool
	{
		if (_mustSelect == value)
		return _mustSelect;
		_mustSelect = value;
		return _mustSelect;
	}
	
	/**
	 * 在数组中搜索元素的位置, 存在此值返回位置，不存在则返回-1
	 * @param	list 被搜索的数组
	 * @param	value 要搜的元素
	 * @return
	 */ 
	private static function indexOf(list:Array<Dynamic>, value:Dynamic):Int
	{
		if (list == null || list.length <= 0)
		return -1;
		
		for (i in 0...list.length)
		{
			if (list[i] == value)
			return i;
		}
		return -1;
	}
}