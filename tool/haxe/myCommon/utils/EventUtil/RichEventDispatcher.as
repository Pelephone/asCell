package utils.EventUtil
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import utils.EventUtil.IRichDispatcher;

	/**
	 * 自写的简单事件托管方法,扩展官方方法可以批量回收事件
	 * @author Pelephone
	 */
	public class RichEventDispatcher extends EventDispatcher implements IRichDispatcher
	{
		/**
		 * 监听绑定数据(本身eventDispatcher不支持先移除全部监听者，所以用一个对象来存储供移除)
		 * <String,Vector.<Function>>
		 */
		private var listenerMap:Object;
		
		/**
		 * 构造事托管器
		 * @param target
		 */
		public function RichEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
			listenerMap = {};
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			var ls:Vector.<Function> = listenerMap[type] as Vector.<Function>;
			if(!ls){
				ls = listenerMap[type] = new Vector.<Function>();
			}
			// 此方法已在监听组里面则不添加
			if(ls.indexOf(listener)>0) return;
			ls.push(listener);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type,listener,useCapture);
			var ls:Vector.<Function> = listenerMap[type] as Vector.<Function>;
			if(!ls) return;
			var lid:int = ls.indexOf(listener);
			while(lid>=0){
				ls.splice(lid,1);
				lid = ls.indexOf(listener);
			}
			if(!ls.length) delete listenerMap[type];
		}
		
		public function removeTypeListeners(type:String):void
		{
			var listeners:Vector.<Function> = listenerMap[type] as Vector.<Function>;
			if(listeners && listeners.length){
				for each (var listener:Function in listeners) 
				{
					super.removeEventListener(type,listener);
				}
			}
			
			listenerMap[type] = null;
			delete listenerMap[type];
		}
		
		public function removeAllListeners():void
		{
			for (var type:String in listenerMap) 
			{
				removeTypeListeners(type);
			}
			
			listenerMap = {};
		}
		
		public function sendEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			dispatchEvent(new Event(type,bubbles,cancelable));
		}
		
		public function dispose():void
		{
			removeAllListeners();
		}
	}
}