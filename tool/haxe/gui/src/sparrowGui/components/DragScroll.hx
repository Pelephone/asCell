package sparrowGui.components;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 * 内容可拖动的工具
 * @author Pelephone
 */
class DragScroll extends EventDispatcher
{

	public function new(scrollTarget:DisplayObject=null) 
	{
		scrollDsp = scrollTarget;
		downPt = new Point();
		downSPt = new Point();
		super();
	}
	
	/**
	 * 被拖动的显示对象
	 */
	public var scrollDsp:DisplayObject;
	
	/**
	 * 用于监听移动事件的显示对象
	 
	public var mouseDsp:DisplayObject;*/
	
	/**
	 * 拖动可超出的比率
	 
	public var scrollDragRatio:Float = 0.5;*/
	
	/**
	 * 激活内容可拖动
	 */
	public var dragScroll(get,set):Bool;
	var _dragScroll:Bool = false;
	
	function get_dragScroll():Bool
	{
		return _dragScroll;
	}
	
	function set_dragScroll(value:Bool):Bool
	{
		if (_dragScroll == value)
		return _dragScroll;
		_dragScroll = value;
		
		if(scrollDsp != null)
		{
			if (_dragScroll)
			scrollDsp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			else
			scrollDsp.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		return _dragScroll;
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		//var mouseDsp:DisplayObject = (scrollDsp.parent != null)?scrollDsp:scrollDsp.parent;
		downPt.x = scrollDsp.stage.mouseX;
		downPt.y = scrollDsp.stage.mouseY;
		downSPt.x = scrollDsp.x;
		downSPt.y = scrollDsp.y;
		
		scrollDsp.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
		scrollDsp.stage.addEventListener(MouseEvent.MOUSE_UP, onContDragEnd);
		scrollDsp.stage.addEventListener(Event.MOUSE_LEAVE, onContDragEnd);
	}
	
	var downPt:Point;
	var downSPt:Point;
	
	private function onContDragEnd(e:Event):Void 
	{
		scrollDsp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
		scrollDsp.stage.removeEventListener(MouseEvent.MOUSE_UP, onContDragEnd);
		scrollDsp.stage.removeEventListener(Event.MOUSE_LEAVE, onContDragEnd);
		
	}
	
	private function onDragMove(e:MouseEvent):Void 
	{
		var tw:Float = scrollDsp.width - width;
		if (tw > 0)
		{
			var dx:Float = scrollDsp.stage.mouseX - downPt.x;
			if ((downSPt.x + dx) < -tw)
			scrollDsp.x = -tw;
			else if ((downSPt.x + dx) > 0)
			scrollDsp.x = 0;
			else
			scrollDsp.x = downSPt.x + dx;
			
			//var scrollDist:Float = scrollDsp.width - width;
			//vScroll.setScrollPercent( -scrollDsp.x / scrollDist);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		var th:Float = scrollDsp.height - height;
		if (th > 0)
		{
			var dy:Float = scrollDsp.stage.mouseY - downPt.y;
			if ((downSPt.y + dy) < -th)
			scrollDsp.y = -th;
			else if ((downSPt.y + dy) > 0)
			scrollDsp.y = 0;
			else
			scrollDsp.y = downSPt.y + dy;
			
			//var scrollDist:Float = scrollDsp.height - height;
			//vScroll.setScrollPercent( -scrollDsp.y / scrollDist);
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	/**
	 * 可拖动的宽范围
	 */
	public var width:Float = 100;
	
	/**
	 * 可拖动高范围
	 */
	public var height:Float = 100;
}