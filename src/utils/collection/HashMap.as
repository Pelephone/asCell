package utils.collection
{
	import flash.utils.Dictionary;

	/**
	 * 哈希表
	 * @author Pelephone
	 */	
	public class HashMap
	{
		private var _map:Dictionary

		public function HashMap()
		{
			_map=new Dictionary(false);
		}

		/**
		 * 添加哈希键映射对象
		 * @param key
		 * @param value
		 */
		public function put(key:*, value:*):void
		{
			_map[key]=value;
		}

		/**
		 * 通过主键移出映射对象
		 * @param key
		 */
		public function remove(key:*):void
		{
			delete _map[key];
		}

		/**
		 * 主键是否已映射在哈希表上
		 * @param key
		 * @return 
		 */
		public function containsKey(key:*):Boolean
		{
			if(!key)
				return false;
			if(key is String || key is Number)
				return map.hasOwnProperty(key);
			return map[key]!=null;
		}

		/**
		 * 获取键映射对象
		 * @param key
		 * @return 
		 */
		public function get(key:*):*
		{
			return map[key];
		}

		/**
		 * 获取映射在哈希表上的所有值
		 * @return 
		 */
		public function getValues():Array
		{
			var values:Array=[];

			for (var key:*in map)
			{
				values.push(map[key]);
			}

			return values;
		}

		/**
		 * 获取映射在哈希表上的所有键
		 * @return 
		 */
		public function getKeys():Array
		{
			var keys:Array=[];

			for (var key:*in map)
			{
				keys.push(key);
			}

			return keys;
		}
		
		/**
		 * 清空哈希表
		 */
		public function removeAll():void
		{
			_map=new Dictionary(true);
		}

		/**
		 * 字典数据
		 * @return 
		 */
		public function get map():Dictionary
		{
			return _map;
		}
	}
}