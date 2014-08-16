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
	import asSkinStyle.data.CssStyle;
	import asSkinStyle.data.StyleComposite;
	import asSkinStyle.i.IStyleParser;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	
	/**
	 * as内置对象生成样式组合的编译器
	 * 语法例如
	 * var styleObj:Object:{
	 * "idName":{
	 *    color:8,
	 *    width:10
	 *  }
	 * "name1 nameChild"{
	 *    height:5
	 *  }
	 * }
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class ArrayToStyleParser implements IStyleParser
	{
		/**
		 * 分隔父项样式与子项样式的分隔符
		 */
		public static const SEPARATOR_CHILD:String = " ";
		/**
		 * 分隔字符串里样式
		 */
		protected static const SEPARATOR_STYLE:String = ",";
		
		public static const ROOT:String = "root";
		
		/**
		 * 按钮字特殊属性
		 */
		private const BUTTON_TEXT_EX:String = "btnText";
		
		/**
		 * css组合,通过对策生成
		 */
		protected var cssData:CssStyle;
		
		public function ArrayToStyleParser()
		{
		}
		
		public function initStyle(cssObject:Object):void
		{
			cssData = makeStyleByVars(cssObject as Array);
		}
		
		/**
		 * 给指定样式添加属性
		 * @param newCssObject
		 * @param cssName
		 */
		public function addCssToComposite(newCssObject:Object, cssName:String="root"):void
		{
			var cps:CssStyle = getStyleComposite(cssName);
			StyleUtils.setObjByVars(cps.getStyleVars(),newCssObject,false);
		}
		
		/**
		 * 通过变量生成的UI
		 * 具体思路是通过css哈希对象转变成UI系统能用的哈希皮肤对象
		 * 可以通过系统的皮肤对象生成皮肤和相关属性
		 * 
		 * @param vars
		 * return 返回整理过的哈希皮肤对象
		 */
		private function makeStyleByVars(vars:Array):CssStyle
		{
			var rootStyle:CssStyle = newStyleComposite(ROOT);
			// 第一层循环遍历对象名和名对应的皮肤信息
			for (var i:int = 0; i < vars.length; i+=2) 
			{
				var varName:String = vars[i] as String;
				var styleVars:Object = vars[i+1];
				
				// 第二层循环将名字用","分组,然后在默认皮肤里设置信息
				var names:Array = varName.split(SEPARATOR_STYLE);
				for each (var nameStr:String in names) 
				{
					createBySeparatorName(nameStr,styleVars,rootStyle);
				}
			}
			
			return rootStyle;
		}
		
		/**
		 * 通过分隔符名建立子项，并赋值
		 * @param spName
		 * @param addVars
		 */
		private function createBySeparatorName(spName:String,addVars:Object,rootStyle:StyleComposite):void
		{
			var arr:Array = spName.split(SEPARATOR_CHILD);
			var forCss:StyleComposite = rootStyle;
			// 遍历分隔名生成子项
			for (var i:int = 0; i < arr.length; i++) 
			{
				var nodeName:String = arr[i] as String;
				var childCom:StyleComposite = forCss.getChildByName(nodeName);
				
				// 如果名字不存在则生成新的
				if(!childCom)
				{
					childCom = newStyleComposite(nodeName);
					forCss.add(childCom);
				}
				forCss = childCom;
			}
			StyleUtils.setObjByVars(forCss.getStyleVars(),addVars,false);
		}
		
		/**
		 * 跟椐哈希数据将样式组装起来
		 */
		private function assemblesStype(styleHm:Object):CssStyle
		{
			var parentCss:CssStyle;
			var rootStyle:CssStyle = newStyleComposite(ROOT);
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
		 * 获取父样式项组合
		 * @param ptName 分隔符的名字
		 * @param styleHm
		 * @return 
		 */
		private function getParentStyle(ptName:String,styleHm:Object):CssStyle
		{
			var parentCss:CssStyle;
			var parentName:String = getParentByPtName(ptName);
			if(parentName == ROOT) return getStyleComposite(ROOT);;
			
			parentCss = styleHm[parentName] as CssStyle;
			if(parentCss) return parentCss;
			
			
			return null;
		}
		
		/**
		 * 通过分隔符语法名返回父类点名
		 * @return 
		 */
		private function getParentByPtName(ptName:String):String
		{
			var ptId:int = ptName.lastIndexOf(SEPARATOR_CHILD);
			if(ptId<0) return ROOT;
			return ptName.substring(0,ptId);
		}
		
		/**
		 * 创建单个样式组件
		 * @param name
		 * @param vo
		 * @return 
		 */
		protected function newStyleComposite(pName:String,vo:Object=null):CssStyle
		{
			vo = vo || {};
			return new CssStyle(pName,vo);
		}
		
		public function hasStyleComposite(tagIdName:String):Boolean
		{
			return getStyleComposite(tagIdName)!=null;
		}
		
		/**
		 * 通过名字获取项，支持空格分隔隔查找子项
		 * @param cssName
		 * @return 
		 */
		protected function getStyleComposite(cssName:String):CssStyle
		{
			if(cssName==ROOT) return cssData;
			return StyleUtils.getCssBySplitName(cssName,cssData) as CssStyle;
//			return cssData.getChildByName(cssName) as CssStyle;
		}
		
		/**
		 * 通过样式名设置对象属性
		 * @param skinObject 要设置属性的显示对象（本组件暂只支持改变显示对象)
		 * @param cssName 样式名组,如#aa,.bb,#cba
		 * @return 
		 */
		public function setSkinUI(skinObject:Object, cssName:String):Object
		{
			var styleCP:CssStyle = getStyleComposite(cssName);
			setSkinUIByCss(skinObject,styleCP);
			return skinObject;
		}
		
		/**
		 * 通过样式设置对象属性，并遍历子项递归赋值
		 * @param skin		本组件仅支持显示对象
		 * @param styleCP	样式组对象
		 */
		protected function setSkinUIByCss(skin:Object,styleCP:CssStyle):void
		{
			if(!skin || !styleCP) return;
			setReferenceStyle(skin,styleCP);
			setObjByVars(skin,styleCP.getStyleVars());
			
			var dc:DisplayObjectContainer = skin as DisplayObjectContainer;
			if(dc && styleCP.numChildren()){
				for (var i:int = 0; i < styleCP.numChildren(); i++) 
				{
					// 递归设置子项信息
					var childCss:CssStyle = styleCP.getChildByIndex(i) as CssStyle;
					var childDP:DisplayObject = dc.getChildByName(childCss.getName());
					setSkinUIByCss(childDP,childCss);
					
					// 访css语法，从根节点再找同名样式设置子项
//					var rootChildCss:CssStyle = cssData.getChildByName(childCss.getName()) as CssStyle;
//					setSkinUIByCss(childDP,rootChildCss);
				}
			}
		}
		
		/**
		 * 通过引用样式设置属性
		 * @param cssCom
		 * @return 
		 */
		private function setReferenceStyle(skin:Object,cssCom:CssStyle):CssStyle
		{
			if(!cssCom) return null;
			if(cssCom.getRefName()){
				var resCom:CssStyle = getStyleComposite(cssCom.getRefName());
				if(!resCom) return cssCom;
				setSkinUIByCss(skin,resCom);
				return setReferenceStyle(skin,resCom);
			}
			else
				return cssCom;
		}
		
		/**
		 * 通过对象复制属性数据给resObj
		 * @param resObj
		 * @param newObj
		 * @param isStrict	是否严格，true时resObj有属性才赋值，false则会给resObj动态添属性
		 * @param ignoreProps	忽略的属性名列表
		 * @return 			返回改变属性后的原对象
		 */
		protected function setObjByVars(resObj:Object,newObj:Object
											  ,isStrict:Boolean=true, ignoreProps:Array=null):Object
		{
			if(!newObj) return null;
			
			if(newObj.hasOwnProperty(BUTTON_TEXT_EX)){
				setButtonText(resObj,newObj[BUTTON_TEXT_EX]);
				(ignoreProps!=null)?
					ignoreProps.push(BUTTON_TEXT_EX):(ignoreProps = [BUTTON_TEXT_EX]);
			}
			
			// 遍历样式对象属性改变dc的属性值
			for (var attName:String in newObj) 
			{
				var voVars:Object = newObj[attName] as Object;
				if(ignoreProps && ignoreProps.indexOf(attName)>=0) continue;
				if(isStrict && !resObj.hasOwnProperty(attName)) continue;
				resObj[attName] = voVars;
			}
			return resObj;
		}
		
		
		
		/**
		 * 设置按钮中的文字
		 * @param btn		目标按钮
		 * @param text		新的文字, 当为 null 时, 不设置新文本(仅返回原先的文本)
		 * @param isHtml	是否是html文本
		 * @return			返回新的文本内容
		 */
		private function setButtonText(btn:Object, text:String=null, isHtml:Boolean = false):String
		{
			//
			var prevText:String = "";
			text = text || "";
			
			//
			var list:Array = [ btn["upState"], btn["downState"], btn["overState"], btn["hitTestState"],btn];
			if(btn.hasOwnProperty("selectState")) list.push(btn["selectState"]);
			if(btn.hasOwnProperty("disableState")) list.push(btn["disableState"]);
			for (var key:* in list)
			{
				var disp:DisplayObject = list[key] as DisplayObject;
				if(!disp) continue;
				var tf:TextField = disp as TextField;
				if(tf == null){
					var cont:DisplayObjectContainer = disp as DisplayObjectContainer;
					if(cont) tf = findChild(cont, TextField) as TextField;
				}
				if(tf){
					if(isHtml){
						tf.htmlText = text;
					}else{
						tf.text = text;
					}
					prevText = tf.text;
				} 
			}
			
			//
			return text || prevText;
		}
		/**
		 * 返回指定类型的孩子
		 * @param node		被寻找的父节点
		 * @param tClass	子类孩子的过滤, 如果为 null, 则返回第一个孩子
		 */
		private function findChild(node:DisplayObjectContainer, tClass:Class=null):DisplayObject
		{
			if(tClass == null) tClass = DisplayObject;
			for(var i:int=0; i<node.numChildren; i++){
				var disp:DisplayObject = node.getChildAt(i);
				if(disp is tClass) return disp;
			}
			return null;
		}
	}
}