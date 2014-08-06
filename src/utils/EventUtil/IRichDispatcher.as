package utils.EventUtil
{
	import flash.events.IEventDispatcher;

	/**
	 * 事件机制的扩展，多了批量删除的方法。
	 * @author Pelephone
	 */
	public interface IRichDispatcher extends IEventDispatcher
	{
		/**
		 * 监听
		 * @param type
		 * @param listener
		 * @param priority
		 * @param useWeakReference
		 
		function addListener(type:String, listener:Function
								  , priority:int=0, useWeakReference:Boolean=false):void;*/
		/**
		 * 移除事件
		 * @param type
		 * @param listener
		 
		function removeListener(type:String, listener:Function):void;*/
		/**
		 * 移出某消息的所有监听函数
		 * @param type
		 */
		function removeTypeListeners(type:String):void;
		/**
		 * 移出所有监听函数
		 */
		function removeAllListeners():void;
	}
}