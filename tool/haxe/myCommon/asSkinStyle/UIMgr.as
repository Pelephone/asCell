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
package asSkinStyle
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import asSkinStyle.data.CssStyle;
	import asSkinStyle.data.SkinComposite;
	import asSkinStyle.data.StyleComposite;
	import asSkinStyle.draw.RectDraw;

	/**
	 * UI管理,默认皮肤,绑定皮肤等管理
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class UIMgr
	{
		/**
		 * 分隔父项样式与子项样式的分隔符
		 */
		public static const SEPARATOR_CHILD:String = " ";
		/**
		 * 分隔字符串里样式
		 */
		public static const SEPARATOR_STYLE_CLASS:String = ",";
		
		public static const CLAZZ:String = "clazz";
		public static const ROOT:String = "root";
		
		/**
		 * 默认皮肤标签组合
		 */
		private var defaultSkin:SkinComposite;
		/**
		 * 默认样式组合
		 */
		private var defaultStyle:CssStyle;
		
		/**
		 * 注册在里面的皮肤类,与名称绑定
		 */
		private var skinClassHash:Object;
		
		
		public function UIMgr()
		{
			skinClassHash = {};
			initTags();
			initDefaultUI();
			initDefaultSkin();
		}
		
		/**
		 * 初始注册标签对象的显示对象
		 */
		protected function initTags():void
		{
			registerTag("draw",RectDraw);
			registerTag("sprite",Sprite);
			registerTag("text",TextField);
		}
		
		/**
		 * 初始默认样式
		 * @return 
		 */
		protected function initDefaultUI():Object
		{
			return null;
		}
		
		/**
		 * 初始默认皮肤组合
		 */
		protected function initDefaultSkin():void
		{
		}
		
		/**
		 * 创建单个样式组件
		 * @param name
		 * @param vo
		 * @return 
		 */
		protected function createStyleComposite(name:String,vo:Object=null):CssStyle
		{
			return new CssStyle(name,vo);
		}
		
		/**
		 * 通过xml数据创建皮肤组合
		 * @param skinXML
		 * @param idName
		 * @param tagName
		 * @param skinClass
		 * @return 
		 
		private function makeSkinCompositeByXML(skinXML:Object
				,idName:String="root",tagName:String=null,skinClass:Vector.<String>=null):SkinComposite
		{
			var scom:SkinComposite = new SkinComposite(idName,tagName);
			for each (var childXML:Object in skinXML.children()) 
			{
				var tag:String = childXML.localName();
				var id:String = childXML.attribute("id");
				var clzStr:String = childXML.attribute("class");
				if(clzStr && clzStr.length>0)
					var clzArr:Array = String(childXML.attribute("class")).split(",");
				else
					clzArr = null;
				var skinClz:Vector.<String> = clzArr?Vector.<String>(clzArr):null;
				
				var childCom:SkinComposite = makeSkinCompositeByXML(childXML,id,tag,skinClz);
				scom.add(childCom);
			}
			return scom;
		}*/
		
		/**
		 * 通过变量生成的UI
		 * 具体思路是通过css哈希对象转变成UI系统能用的哈希皮肤对象
		 * 可以通过系统的皮肤对象生成皮肤和相关属性
		 * 
		 * @param vars
		 * return 返回整理过的哈希皮肤对象
		 
		private function makeStyleByVars(vars:Array):CssStyle
		{
			var uiVars:Object = {};
			var styleHm:Object = {};

			// 第一层循环遍历对象名和名对应的皮肤信息
			for (var i:int = 0; i < vars.length; i+=2) 
			{
				var varName:String = vars[i] as String;
				var styleVars:Object = vars[i+1];

				// 第二层循环将名字用","分组,然后在默认皮肤里设置信息
				var names:Array = varName.split(",");
				for each (var nameStr:String in names) 
				{
					if(!uiVars.hasOwnProperty(nameStr))
						uiVars[nameStr] = {};
					
//					uiVars[nameStr] = copySetVars(uiVars[nameStr],vars[varName]);
					StyleUtils.setObjByVars(uiVars[nameStr],styleVars,false);
					
					if(!styleHm.hasOwnProperty(nameStr))
						styleHm[nameStr] = createStyleComposite(nameStr,uiVars[nameStr]);
					
//					(styleHm[nameStr] as CssComposite).setStyleVars();
				}
			}
			
			return assemblesStype(styleHm);
		}*/
		
		/**
		 * 跟椐哈希数据将样式组装起来
		 */
		private function assemblesStype(styleHm:Object):CssStyle
		{
			var parentCss:CssStyle;
			var rootStyle:CssStyle = createStyleComposite(ROOT);
			for (var oName:String in styleHm) 
			{
				var vo:CssStyle = styleHm[oName] as CssStyle;
				var parentName:String = getParentByPtName(oName);
				if(parentName == ROOT)
					parentCss = rootStyle;
				else
					parentCss = styleHm[parentName] as CssStyle;
					
				if(!parentCss) continue;
				
				parentCss.add(vo);
			}
			return rootStyle;
		}
		
		/**
		 * 通过点语法名返回父类点名
		 * @return 
		 */
		private function getParentByPtName(ptName:String):String
		{
			var ptId:int = ptName.lastIndexOf(SEPARATOR_CHILD);
			if(ptId<0) return ROOT;
			return ptName.substring(0,ptId);
		}
		
		public function setSkinDefaultUI(skin:Object,uiName:String):Object
		{
			
			return skin;
		}
		
		/**
		 * 通过样式设置对象属性，并遍历子项赋值
		 * @param skin
		 * @param styleCP
		 
		private function setSkinUIByCss(skin:Object,styleCP:CssStyle):void
		{
			if(!skin || !styleCP) return;
			StyleUtils.setObjByVars(skin,styleCP.getStyleVars());
			
			var dc:DisplayObjectContainer = skin as DisplayObjectContainer;
			if(dc && styleCP.numChildren()){
			}
		}*/
		
		public function getDefaultUIByName(uiName:String):DisplayObject
		{
			var styleCP:StyleComposite = defaultSkin.getChildByName(uiName);
			return (!styleCP)?null:styleCP.makeDisps();
		}
		
		/////////////////////////////////////////
		// 标签管理
		/////////////////////////////////////////
		
		/**
		 * 注册标签
		 * 显示对象通过此标签名生成组件默认皮肤
		 * @param tagName
		 * @param dispClz
		 */
		public function registerTag(tagName:String,dispClz:Class):void
		{
			skinClassHash[tagName] = dispClz;
		}
		
		/**
		 * 通过名字获取绑定在里面的皮肤类
		 * @param clzName
		 * @return 
		 */
		public function getTagClass(clzName:String):Class
		{
			return skinClassHash[clzName] as Class;
		}
		
		public function hasTagClass(clzName:String):Boolean
		{
			return skinClassHash[clzName] != null;
		}
	}
}