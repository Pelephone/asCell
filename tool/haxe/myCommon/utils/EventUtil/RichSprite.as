package utils.EventUtil
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 多功能的Sprite
	 * 增加了事件回收的机制,有效防止回收垃圾问题.
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class RichSprite extends Sprite implements IRichDispatcher
	{
		private var listenerMap:Object;
		
		public function RichSprite()
		{
			listenerMap = {};
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			var ls:Vector.<Function> = listenerMap[type] as Vector.<Function>;
			if(!ls){
				ls = listenerMap[type] = new Vector.<Function>();
			}
			if(ls.indexOf(listener)>0) return;
			ls.push(listener);
		}
		
/*		override public function dispatchEvent(event:Event):Boolean
		{
		var ls:Vector.<Function> = listenerMap[event.type] as Vector.<Function>;
		if(!ls) return false;
		for each (var listener:Function in ls) 
		{
		listener.apply(null,[event]);
		}
		return true;
		}*/
		
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
		
		protected function sendNote(note:String, args:Object=null, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			dispatchEvent(new Event(note,bubbles,cancelable));
		}
		
		/**
		 * 将此对象加到场景
		 * @param parent
		 */
		public function addToParent(toParent:DisplayObjectContainer):void
		{
			toParent.addChild(this);
		}
		
		/**
		 * 对象移出场景
		 */
		public function removeFromParent():void
		{
			if(parent) parent.removeChild(this);
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			removeAllListeners();
			removeFromParent();
		}
	}
}