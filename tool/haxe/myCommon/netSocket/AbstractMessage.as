/** Copyright(c) 2011 the original author or authors.** Licensed under the Apache License, Version 2.0 (the "License");* you may not use this file except in compliance with the License.* You may obtain a copy of the License at**     http://www.apache.org/licenses/LICENSE-2.0** Unless required by applicable law or agreed to in writing, software* distributed under the License is distributed on an "AS IS" BASIS,* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,* either express or implied. See the License for the specific language* governing permissions and limitations under the License.*/package netSocket{	/**	 * 协议抽象类	 * @author Michael.Huang	 * @modify Pelephone	 */	public class AbstractMessage	{		private var _msgId:int;		/**		 * 消息协议ID		 */		public function get msgId():int		{			return _msgId;		}		/**		 * @private		 */		public function set msgId(value:int):void		{			_msgId = value;		}		private var _msgData:MessageData;		/**		 * 协议内容		 */		public function get msgData():MessageData		{			return _msgData;		}		/**		 * @privatea		 */		public function set msgData(value:MessageData):void		{			_msgData = value;		}	}}