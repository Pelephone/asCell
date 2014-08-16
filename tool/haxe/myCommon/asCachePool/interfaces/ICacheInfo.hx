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
package asCachePool.interfaces;

/**
 * 缓存信息接口
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
interface ICacheInfo extends IRecycle
{
	/**
	 * 被缓存的对象
	 */
	function getBody():Dynamic;
	/**
	 * 被缓存的对象
	 */
	function setBody(value:Dynamic):Void;
	
	/**
	 * 缓存更新时间
	 */
	function getUpdateTime():Int;
	/**
	 * 缓存更新时间
	 */
	function setUpdateTime(value:Int):Void;
	
	/**
	 * 使用次数
	 */
	function getCount():Int;
	/**
	 * 使用次数
	 */
	function setCount(value:Int):Void;
	
	/**
	 * 过期时间，即到了此时间会有timer自动清理
	 */
	function getExpired():Int;
	/**
	 * 过期时间，即到了此时间会有timer自动清理
	 */
	function setExpired(value:Int):Void;
	
	/**
	 * 缓存主键
	 */
	function getKeyName():String;
	/**
	 * 缓存主键
	 */
	function setKeyName(value:String):Void;
	
	/**
	 * 缓存版本
	 */
	function getVersion():String;
	/**
	 * 缓存版本
	 */
	function setVersion(value:String):Void;
	
	/**
	 * 缓存存的组名
	 */
	function getGroupName():String;
	/**
	 * 缓存存的组名
	 */
	function setGroupName(value:String):Void;
	
	/**
	 * 动态变量
	 * 用动态变量的好处是提高效率，as可以for in设置属性
	 */
	function getDyVars():Dynamic;
	/**
	 * 是否启用动态变量赋值
	 */
	function getIsGSVars():Bool;
}