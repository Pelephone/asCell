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
	 * UI样式生成器,生成和管理样式组合
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public interface IStyleParser
	{
		/**
		 * 通过样式标签等生成皮肤组合
		 * (skinTag对象里面的标签须先registerTag过)
		 * @param skinTag
		 * @return 
		 */
		function initStyle(cssObject:Object):void;
		/**
		 * 增加属性到对应的样式上
		 * @param newCssObject
		 */
		function addCssToComposite(newCssObject:Object,cssName:String="root"):void;
		/**
		 * 通过id名获取css样式对象
		 * @param tagIdName
		 * @return 
		 
		function getCssByName(cssIdName:String):CssComposite;*/
		/**
		 * 跟椐样式名设置对象属性
		 * @param skinObject
		 * @param cssName
		 * @return 
		 */
		function setSkinUI(skinObject:Object,cssName:String):Object;
		/**
		 * 通过id名判断是否有css样式对象
		 * @param tagIdName
		 * @return 
		 */
		function hasStyleComposite(tagIdName:String):Boolean;
	}
}