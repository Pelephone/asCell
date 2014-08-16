/** Copyright(c) 2011 the original author or authors.** Licensed under the Apache License, Version 2.0 (the "License");* you may not use this file except in compliance with the License.* You may obtain a copy of the License at**     http://www.apache.org/licenses/LICENSE-2.0** Unless required by applicable law or agreed to in writing, software* distributed under the License is distributed on an "AS IS" BASIS,* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,* either express or implied. See the License for the specific language* governing permissions and limitations under the License.*/package netSocket.core{	import netSocket.AbstractMessage;
	import netSocket.MessageData;
	/**	 * 接收协议基类	 * @author Michael.Huang	 *	 */	public class ReceiveMessage extends AbstractMessage	{		/**		 * ReceiveMessage construct		 * @param msgId 协议id		 *		 */		public function ReceiveMessage(msgId:int)		{			this.msgId = msgId;		}		/**		 * @inheritDoc		 */		override public function set msgData(value:MessageData):void		{			super.msgData = value;			if (msgData && msgData.body)				msgData.body.position = 0;		}		/**		 * @inheritDoc		 */		public function toString():String		{			var res:String = "";			res = "[class ReceiveMessage] : 消息解析 >> " + res;			return res;		}	}}