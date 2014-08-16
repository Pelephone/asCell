package sparrowGui.i;

import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;

interface IItem extends IEventDispatcher
{
	/**
	 * 更新数据
	 
	function update(o:Object):Void;*/
	/**
	 * 用字符改变状态可以解耦，比如在列表中想要添新状态可以继承SItem,SList 
	 * @param stateName
	 */
	function setState(stateName:String,value:Dynamic=null):Void;
	/**
	 * 当前状态，类型见ItemState
	 * @return 
	 
	function getCurrentState():String;*/
//		function get skin():DisplayObject;
	/**
	 * 项数据
	 */
	function getData():Dynamic;
	/**
	 * @private
	 */
	function setData(value:Dynamic):Void;
	
	/**
	 * 项名
	 * @param value
	 */
	function setName(value:String):Void;
	
	/**
	 * @private 
	 */
	function getName():String;
	
	/**
	 * 项在组里的索引
	 * @param value
	 */
	function setItemIndex(value:Int):Void;
	
	/**
	 * @private 
	 */
	function getItemIndex():Int;
	
	/**
	 * 将自己添加到父容器
	 * @param parent
	 */
	function addToParent(parentDSP:DisplayObjectContainer):Void;
}