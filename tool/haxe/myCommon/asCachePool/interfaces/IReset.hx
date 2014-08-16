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
* WITHOUT WARRANTIES 
*/
package asCachePool.interfaces;
	
/**
 * 重置器，一般是缓存从回收池里面拿出时调用
 * @author Pelephone
 */
interface IReset
{
	/**
	 * 重置对象
	 */
	function reset():Void;
}