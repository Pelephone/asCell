/** Copyright(c) 2011 the original author or authors.** Licensed under the Apache License, Version 2.0 (the "License");* you may not use this file except in compliance with the License.* You may obtain a copy of the License at**     http://www.apache.org/licenses/LICENSE-2.0** Unless required by applicable law or agreed to in writing, software* distributed under the License is distributed on an "AS IS" BASIS,* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,* either express or implied. See the License for the specific language* governing permissions and limitations under the License.*/package netSocket.interfaces{	import flash.events.IEventDispatcher;	/**	 * Socket链接接口	 * @author Michael.Huang	 *	 */	public interface IConnection extends IEventDispatcher	{		/**		 * 连接服务器		 * @param server  服务器地址		 * @param port    服务器端口		 * @param policyFilePort 安全沙箱的连接端口		 */		function connect(server:String, port:int, policyFilePort:int=8080):void;		/**		 * 发送消息		 * @param msg 消息内容		 *		 */		function sendMsg(msg:IMessage):void;	}}