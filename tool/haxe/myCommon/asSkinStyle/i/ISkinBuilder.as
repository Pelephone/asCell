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
	import asSkinStyle.data.SkinStyle;

	/**
	 * 创建皮肤的编译器
	 * 例如通过xml生成皮肤和对应样式
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public interface ISkinBuilder
	{
		/**
		 * 通过样式标签等生成皮肤组合
		 * (skinTag对象里面的标签须先registerTag过)
		 * @param skinTag
		 * @return 
		 */
		function initSkinComposite(skinTag:Object):void;
		/**
		 * 通过标签id名创建皮肤
		 * @param tagIdName
		 */
		function createSkinUI(tagIdName:String):Object;
		/**
		 * 跟椐组合标签设置对象样式
		 * @param skin
		 * @param skinId
		 */
		function setSkinChildStyle(skinObject:Object,skinId:String):void
		/**
		 * 通过id名获取标签生成的对象
		 * @param tagIdName
		 * @return 
		 
		function getSkinDataByName(tagIdName:String):SkinStyle;*/
		/**
		 * 通过id名判断是否有标签对象
		 * @param tagIdName
		 * @return 
		 */
		function hasSkinComposite(tagIdName:String):Boolean;
		
		/**
		 * 注册标签
		 * 显示对象通过此标签名生成组件默认皮肤
		 * @param tagName 标签名
		 * @param dispClz 显示对象的类Class
		 */
		function registerTag(tagName:String,dispClz:Class):void;
		/**
		 * 通过名字获取绑定在里面的皮肤类
		 * @param clzName
		 * @return 
		 */
		function getTagClass(clzName:String):Class;
		/**
		 * 是否已注册该标签
		 * @param clzName
		 * @return 
		 */
		function hasTagClass(clzName:String):Boolean;
		/**
		 * 销毁本对象
		 */
		function dispose():void
	}
}