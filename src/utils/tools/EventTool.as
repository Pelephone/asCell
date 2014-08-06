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
package utils.tools
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * 消息管理工具
	 * Pelephone
	 */
	public class EventTool
	{
		/**
		 * 将原事件替换发出，发某类型消息时会同时发出另一个同样类型的绑定消息
		 * @param target 要转发事件的对象
		 * @param reType 要被转发的事件类型
		 * @param newType 新事件类型
		 */
		public static function exchangeEvent(target:IEventDispatcher,reType:String,newType:String):void
		{
			target.addEventListener(reType,function():void
			{
				target.dispatchEvent(new Event(newType));
			});
		}
		
		/**
		 * 转换无消息的方法
		 */
		public static function setlistener(target:IEventDispatcher,type:String
										   ,listener:Function,newArgs:Array=null):void
		{
			target.addEventListener(type,function():void
			{
				listener.apply(null,newArgs);
			});
		}
	}
}