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
package asSkinStyle.i
{
	/**
	 * css皮肤,只有接入此接口，样式中的class和tag标签才会生效。
	 * 不接此接口只能使用"#"样式
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public interface ICssSkin
	{
		function set tagName(value:String):void;
		function get tagName():String;
		function set classStr(value:String):void;
		function get classStr():String;
	}
}