/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package asCachePool
{
	import asCachePool.interfaces.ICacheInfo;

	/**
	 * 池信息，对应一条缓存在里面的对象<br/>
	 * 用这种特殊动态属性的写法有一好处，用新类覆盖的话可以动态添加属性。(用接口属性数量是固定的)
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class CacheInfo implements ICacheInfo
	{
		public function CacheInfo(vars:Object=null)
		{
			_vars = {};
			if(!vars) return;
			for (var oName:String in vars) 
			{
				var val:Object = vars[oName];
				_set(oName,val);
			}
		}
		
		/** @private **/
		protected var _vars:Object;
		
		/** @private **/
		protected function _set(property:String, value:*):CacheInfo
		{
			if (value == null) {
				delete _vars[property]; //in case it was previously set
			} else {
				_vars[property] = value;
			}
			return this;
		}
		
		
		//---- GETTERS / SETTERS ------------------------------------
		
		public function getBody():Object
		{
			return _vars["body"];
		}
		
		public function getCount():int
		{
			return _vars["count"];
		}
		
		public function getExpired():int
		{
			return _vars["expired"];
		}
		
		public function getGroupName():String
		{
			return _vars["groupName"];
		}
		
		public function getKeyName():String
		{
			return _vars["keyName"];
		}
		
		public function getUpdateTime():int
		{
			return _vars["updateTime"];
		}
		
		public function getVersion():String
		{
			return _vars["version"];
		}
		
		public function setBody(value:Object):void
		{
			_set("body",value);
		}
		
		public function setCount(value:int):void
		{
			_set("count",value);
		}
		
		public function setExpired(value:int):void
		{
			_set("expired",value);
		}
		
		public function setGroupName(value:String):void
		{
			_set("groupName",value);
		}
		
		public function setKeyName(value:String):void
		{
			_set("keyName",value);
		}
		
		public function setUpdateTime(value:int):void
		{
			_set("updateTime",value);
		}
		
		public function setVersion(value:String):void
		{
			_set("version",value);
		}
		
		
		/** 动态变量
		 * 用动态变量的好处是提高效率，as可以foreach设置属性 **/
		public function get dyVars():Object
		{
			return _vars;
		}
		
		/** @private **/
		public function get isGSVars():Boolean
		{
			return true;
		}
		
		public function dispose():void
		{
			_vars = {};
		}
	}
}