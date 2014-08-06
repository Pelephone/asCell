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
package netSocket.core
{

	import flash.utils.Dictionary;

	/**
	 * 消息仓库, 使用前会先初始化
	 * @author Michael.Huang
	 */
	public class MessageRepository
	{

		/**
		 * 保存以协议ID作为key,协议类作为value
		 */
		private static var commands:Dictionary;

		/**
		 * 获取服务器端消息实例
		 *
		 * @param id:int 消息号
		 * @return ReceiveMessage	服务器消息类的实例对象
		 */
		public static function getMessage(id:int):ReceiveMessage
		{
			if (null == commands)
				return null;
			if (null == commands[id])
			{
				return null;
			}
			return commands[id];
		}

		/**
		 * 注册消息解析命令
		 * @param cls 协议类
		 *
		 */
		public static function register(cls:Class):void
		{
			if (null == commands)
				commands = new Dictionary();
			if (cls != null)
			{
				try
				{
					var obj:Object = commands[cls["MSGNO"]];
					if (null == obj)
					{
						commands[cls["MSGNO"]] = new cls();
					}
				}
				catch (e:*)
				{
					trace("Register command error " + cls);
				}
			}
		}

		/**
		 * 反注册消息命令
		 * @param cls
		 *
		 */
		public static function unregister(cls:Class):void
		{
			if (cls != null)
			{
				try
				{
					delete commands[cls["MSGNO"]];
				}
				catch (e:*)
				{
					trace("Register command error " + cls);
				}
			}
		}

	}
}
