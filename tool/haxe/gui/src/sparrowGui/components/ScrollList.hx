package sparrowGUI.components;
import flash.events.Event;
import haxe.Timer;
import sparrowGui.components.ScrollPanel;
import sparrowGui.components.SList.SList;
import sparrowGui.SparrowUtil;

/**
 * 带滚动条的列表组件
 * @author Pelephone
 */
class ScrollList<T> extends ScrollPanel
{
	public function new() 
	{
		list = new SList<T>();
		super(list);
	}
	
	override private function reset() 
	{
		list.addEventListener(Event.CHANGE, onListDrawChange);
		super.reset();
	}
	
	override public function dispose():Void 
	{
		list.removeEventListener(Event.CHANGE, onListDrawChange);
		super.dispose();
	}
	
	private function onListDrawChange(e:Event):Void 
	{
		draw();
	}
	
	public var list:SList<T>;
	
	public var data(get,set):Array<T>;
	function get_data():Array<T>
	{
		return list.data;
	}
	function set_data(value:Array<T>):Array<T>
	{
		list.data = value;
		return list.data;
	}
}