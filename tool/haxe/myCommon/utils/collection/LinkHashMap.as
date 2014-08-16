package utils.collection
{
	import utils.collection.HashMap;
	
	/**
	 * 链表哈希,把哈希数据以字典和数组两种方式存内在
	 * @author Pelephone
	 */
	public class LinkHashMap extends HashMap
	{
		private var _list:Array;
		private var _keys:Array;
		
		public function LinkHashMap()
		{
			super();
			_list = [];
			_keys = [];
		}
		
		/**
		 * 放入List
		 * @param key
		 * @param value
		 */
		override public function put(key:*, value:*):void
		{
			if(get(key) == value)
				return;
			if(containsKey(key))
				remove(key);

			super.put(key,value);
			_keys.push(key);
			_list.push(value);
		}
		
		/**
		 * 移出对象
		 * @param key
		 */
		override public function remove(key:*):void
		{
			var hasKey:Boolean = containsKey(key);
			if(!hasKey)
				return;
			var val:Object = get(key);
			super.remove(key);
			var indexObj:int = _list.indexOf(val);
			if(indexObj>=0)
				_list.splice(indexObj, 1)[0];
			var indexKey:int = _keys.indexOf(key);
			if(indexKey>=0)
				_keys.splice(indexKey, 1)[0];
		}
		
		/**
		 * @inheritDoc
		 */
		override public function containsKey(key:*):Boolean
		{
			return _keys.length>0;
		}
		
		/**
		 * 移出全部
		 */
		override public function removeAll():void
		{
			super.removeAll();
			_list = [];
			_keys = [];
		}
		
		/**
		 * 返回键数组
		 * @return 
		 */
		override public function getKeys():Array
		{
			return _keys;
		}
		
		/**
		 * 返回值数组数据
		 * @return 
		 */
		override public function getValues():Array
		{
			return _list;
		}
		
		/**
		 * 长度
		 * @return 
		 */
		public function get size():int
		{
			return _list.length;
		}
	}
}