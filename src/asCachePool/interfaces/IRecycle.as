/**
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
package asCachePool.interfaces
{
	/**
	 * 回收器，一般是缓存回收时调用
	 * @author Pelephone
	 */
	public interface IRecycle
	{
		/**
		 * 销毁对象，放于池里
		 */
		function dispose():void;
	}
}