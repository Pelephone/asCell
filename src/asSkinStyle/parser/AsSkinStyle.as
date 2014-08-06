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
package asSkinStyle.parser
{
	import asSkinStyle.draw.CircleDraw;
	import asSkinStyle.draw.CircleSprite;
	import asSkinStyle.draw.RectDraw;
	import asSkinStyle.draw.RectSprite;
	import asSkinStyle.i.ISkinBuilder;
	import asSkinStyle.i.IStyleParser;
	
	import flash.display.DisplayObject;
	
	/**
	 * 本工具用于将将皮肤控制分离成文本。修改调整坐样等能通过类似css的文本来控制。
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class AsSkinStyle
	{
		private var _skinBuilder:ISkinBuilder;
		private var _styleParser:IStyleParser;
		
		/**
		 * 构造样式管理器
		 * @param skinTag		标签数据,默认是xml格式
		 * @param styleObject	样式数据,默认是css格式
		 * @param aSkinBuilder	皮肤标签分析器,默认是xml标签
		 * @param aStyleBuilder	样式数据分析器,默认是数组数据分析器,有需要可以换成css分析器
		 */
		public function AsSkinStyle(skinTag:XML=null,styleObject:Object=null
									,aSkinParser:ISkinBuilder=null,aStyleParser:IStyleParser=null)
		{
			_skinBuilder = aSkinParser || newSkinParser();
			_styleParser = aStyleParser || newStyleParser();
			
			initRegisterTags();
			_skinBuilder.initSkinComposite(skinTag);
			_styleParser.initStyle(styleObject);
		}
		
		/**
		 * 设置解析器
		 * @param skinParser
		 * @param styleParse
		 */
		public function setParser(aSkinParser:ISkinBuilder=null,aStyleParser:IStyleParser=null):void
		{
			_skinBuilder = aSkinParser || newSkinParser();
			_styleParser = aStyleParser || newStyleParser();
		}
		
		/**
		 * 创建皮肤解析器
		 * @return 
		 */
		protected function newSkinParser():ISkinBuilder
		{
			return new XMLSkinBuilder();
		}
		
		/**
		 * 创建样式解析器
		 */
		protected function newStyleParser():IStyleParser
		{
			return new ArrayToStyleParser();
		}
		
		/**
		 * 初始注册项
		 */
		protected function initRegisterTags():void
		{
			registerTag("rect",RectDraw);
			registerTag("rectSR",RectSprite);
			registerTag("circle",CircleDraw);
			registerTag("circleSR",CircleSprite);
		}
		
		/**
		 * 创建显示对象，包括子项生成
		 * @param skinId 皮肤名
		 */
		public function createSkinUI(skinId:String):DisplayObject
		{
			var dp:DisplayObject = _skinBuilder.createSkinUI(skinId) as DisplayObject;
			_styleParser.setSkinUI(dp,skinId);
			return dp;
		}
		
		/**
		 * 通过样式名设置皮肤
		 * @param skin
		 * @param skinId
		 */
		public function setSkinUI(skin:DisplayObject,skinId:String):void
		{
			_skinBuilder.setSkinChildStyle(skin,skinId);
			_styleParser.setSkinUI(skin,skinId);
		}
		
		/**
		 * 使用皮肤组件前先注删标签
		 * @param tagName
		 * @param dispClz
		 */
		public function registerTag(tagName:String, dispClz:Class):void
		{
			_skinBuilder.registerTag(tagName,dispClz);
		}
		
		/**
		 * 是否注册有该标签
		 * @param clzName
		 * @return 
		 */
		public function hasTagClass(clzName:String):Boolean
		{
			return _skinBuilder.hasTagClass(clzName);
		}
		
		/**
		 * 皮肤标签分析器
		 */
		public function setSkinParser(value:ISkinBuilder):void
		{
			_skinBuilder = value;
		}
		
		/**
		 * 样式对象分析器
		 */
		public function setStyleParser(value:IStyleParser):void
		{
			_styleParser = value;
		}
	}
}