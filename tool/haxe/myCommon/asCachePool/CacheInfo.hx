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
package asCachePool;

import asCachePool.interfaces.ICacheInfo;

/**
 * 池信息，对应一条缓存在里面的对象<br/>
 * 用这种特殊动态属性的写法有一好处，用新类覆盖的话可以动态添加属性。(用接口属性数量是固定的)
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class CacheInfo implements ICacheInfo
{
	public function new(vars:Map<String,Dynamic>=null)
	{
		_vars = new Map<String,Dynamic>();
		if (vars == null)
		return;
		for (oName in vars.keys()) 
		{
			var val:Dynamic = vars.get(oName);
			_set(oName,val);
		}
	}
	
	/** @private **/
	var _vars:Map<String,Dynamic>;
	
	/** @private **/
	function _set(property:String, value:Dynamic):CacheInfo
	{
		if (value == null) {
			_vars.remove(property);
		} else {
			_vars.set(property,value);
		}
		return this;
	}
	
	//---- GETTERS / SETTERS ------------------------------------
	
	public function getBody():Dynamic
	{
		return _vars.get("body");
	}
	
	public function getCount():Int
	{
		return _vars.get("count");
	}
	
	public function getExpired():Int
	{
		return _vars.get("expired");
	}
	
	public function getGroupName():String
	{
		return _vars.get("groupName");
	}
	
	public function getKeyName():String
	{
		return _vars.get("keyName");
	}
	
	public function getUpdateTime():Int
	{
		return _vars.get("updateTime");
	}
	
	public function getVersion():String
	{
		return _vars.get("version");
	}
	
	public function setBody(value:Dynamic)
	{
		_set("body",value);
	}
	
	public function setCount(value:Int)
	{
		_set("count",value);
	}
	
	public function setExpired(value:Int)
	{
		_set("expired",value);
	}
	
	public function setGroupName(value:String)
	{
		_set("groupName",value);
	}
	
	public function setKeyName(value:String)
	{
		_set("keyName",value);
	}
	
	public function setUpdateTime(value:Int)
	{
		_set("updateTime",value);
	}
	
	public function setVersion(value:String)
	{
		_set("version",value);
	}
	
	
	/** 动态变量
	 * 用动态变量的好处是提高效率，as可以foreach设置属性 **/
	public function getDyVars():Dynamic
	{
		return _vars;
	}
	
	/** @private **/
	public function getIsGSVars():Bool
	{
		return true;
	}
	
	public function dispose()
	{
		_vars = new Map<String,Dynamic>();
	}
}