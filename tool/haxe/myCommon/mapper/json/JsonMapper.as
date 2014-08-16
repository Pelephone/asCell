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
package mapper.json
{
	import mapper.ObjectMapper;

	/**
	 * Json转换工具(* 需要官方类库com.adobe.serialization.json)
	 * 暂不实现
	 * @website http://www.cnblogs.com/pelephone
	 * @author Pelephone
	 */
	public class JsonMapper extends ObjectMapper
	{
		public function JsonMapper(voMapperAttr:String="voMapperName")
		{
			super(voMapperAttr);
		}
		
		/**
		 * 把对象转换成xml格式的字符串
		 * @param obj
		 * @return 
		 */
		public function toJson(obj:Object):String
		{
//			return JSON.encode(obj);
			return null;
		}
		
		/**
		 * 把xml字符串转换成obj对象
		 * @param xml
		 */		
		public function fromJson(jsonStr:String,voClz:Class):*
		{
//			var obj:Object = JSON.dncode(jsonStr);
//			objToVOByMapper(obj,voClz);
			return null;
		}
	}
}