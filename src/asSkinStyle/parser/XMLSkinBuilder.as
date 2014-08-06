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
	import asSkinStyle.data.SkinStyle;
	import asSkinStyle.i.ISkinBuilder;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * xml语法的皮肤标签解析生成器
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class XMLSkinBuilder implements ISkinBuilder
	{
		/**
		 * 根组合的名称
		 */
		protected static const XML_ROOT:String = "root";
		/**
		 * class属性名
		 */
		protected static const XML_CLASS:String = "class";
		/**
		 * id属性名
		 */
		protected static const XML_ID:String = "name";
		/**
		 * 获取子项的标签
		 */
		protected static const XML_GET_CHILD:String = "xChild";
		/**
		 * 引用节点
		 */
		protected static const XML_REFERENCE:String = "reference";
		
		/**
		 * 注册在里面的皮肤类,与名称绑定
		 */
		protected var tagClzMap:Object;
		/**
		 * 皮肤组合,通过xml生成
		 */
		protected var skinData:SkinStyle;
		
		public function XMLSkinBuilder()
		{
			tagClzMap = {};
		}
		
		public function initSkinComposite(xmlTagObj:Object):void
		{
			xmlTagObj.@[XML_ID] = XML_ROOT;
			skinData = makeSkinCom(xmlTagObj,xmlTagObj);
		}
		
		public function createSkinUI(tagIdName:String):Object
		{
			var sCom:SkinStyle = getSkinDataByName(tagIdName);
			return createSkinAndChild(sCom);
		}
		
		/**
		 * 返回输入样式子项
		 * @param skin
		 * @param childName
		 * @return 
		 */
		protected function getSkinChild(skin:Object,childName:String):Object
		{
			return skin.getChildByName(childName);
		}
		
		/**
		 * 设置对象样式和子项样式
		 * @param sCom
		 * @return 
		 */
		private function createSkinAndChild(sCom:SkinStyle):Object
		{
			if(!sCom) return null;
			var clz:Class = getTagClass(sCom.classTag);
			if(!clz){
				trace("标签类",sCom.classTag,"未注册,不能生成!");
				return null;
			}
			var resSkin:Object = new clz();
			
			StyleUtils.setObjByVars(resSkin,sCom.getStyleVars(),true,[XML_REFERENCE]);
			createStyleChild(sCom,resSkin);
			
			return resSkin;
		}
		
		/**
		 * 通过样式生成子项皮肤
		 * @param sCom
		 */
		private function createStyleChild(sCom:SkinStyle,resSkin:Object):Object
		{
			var dc:DisplayObjectContainer = resSkin as DisplayObjectContainer;
			if(!dc || !sCom.numChildren()) return resSkin;
			for (var i:int = 0; i < sCom.numChildren(); i++) 
			{
				var ccmp:SkinStyle = sCom.getChildByIndex(i) as SkinStyle;
				
				var skinChild:Object = getSkinChild(dc,ccmp.getName());
				// 如果子项标签是特殊标签则不生成新对象，进行查找子项后斌值
				if((ccmp && ccmp.classTag==XML_GET_CHILD) || skinChild )
				{
					StyleUtils.setObjByVars(skinChild,ccmp.getStyleVars(),true,[XML_REFERENCE]);
				}
				else
				{
					var cdp:DisplayObject = createSkinAndChild(ccmp) as DisplayObject;
					if(!cdp) continue;
					dc.addChild(cdp);
				}
			}
			return resSkin;
		}
		
		/**
		 * 跟椐组合标签设置对象样式
		 * @param skin
		 * @param skinId
		 */
		public function setSkinChildStyle(skinObject:Object,skinId:String):void
		{
			var skinCom:SkinStyle = skinData.getChildByName(skinId) as SkinStyle;
			setSkinStyleCom(skinObject,skinCom);
		}
		
		/**
		 * 通过组件样式设置皮肤及子项属性
		 * @param skinObject
		 * @param skinCom
		 * @return 
		 */
		private function setSkinStyleCom(skinObject:Object,skinCom:SkinStyle):Object
		{
			var dc:DisplayObjectContainer = skinObject as DisplayObjectContainer;
			if(!dc || !skinCom ||!skinCom.numChildren()) return skinObject;
			for (var i:int = 0; i < skinCom.numChildren(); i++) 
			{
				var ccmp:SkinStyle = skinCom.getChildByIndex(i) as SkinStyle;
				
				// 如果子项标签是特殊标签则不生成新对象，进行查找子项后斌值
				if(ccmp && ccmp.classTag==XML_GET_CHILD )
				{
					var skinChild:Object = getSkinChild(dc,ccmp.getName());
					if(skinChild)
						StyleUtils.setObjByVars(skinChild,ccmp.getStyleVars());
				}
			}
			return skinObject;
		}
		
		/**
		 * 通过xml递归子项生成皮肤
		 * @param skinXML
		 * @param rootXml
		 * @param idName
		 * @return 
		 */
		private function makeSkinCom(skinXML:Object,rootXml:Object):SkinStyle
		{
			if(!skinXML) return null;
			var id:String = skinXML.attribute(XML_ID);
			skinXML = getReferenceXml(skinXML,rootXml);
			
			var tagName:String = skinXML.localName();
			var styleVars:Object = StyleUtils.xmlCreateObject(skinXML);
			styleVars[XML_ID] = id;
			var scom:SkinStyle = newSkinComp(id,tagName,styleVars);
			
			for each (var childXML:Object in skinXML.children()) 
			{
				var childCom:SkinStyle = makeSkinCom(childXML,rootXml);
				scom.add(childCom);
			}
			
			return scom;
		}
		
		/**
		 * 归递生成xml对象
		 */
		private function getReferenceXml(refXml:Object,rootXml:Object):Object
		{
			refXml = refXml[0];
			if(!refXml || !refXml.length()) return null;
			var refId:String = refXml.attribute(XML_REFERENCE);
			if(refId && refId.length)
			{
				var scXml:Object = rootXml.children().(attribute(XML_ID)==refId);
				var resXml:Object = getReferenceXml(scXml.copy(),rootXml);
				resXml.appendChild(refXml.children());
				return resXml;
			}
			else
				return refXml;
		}
		
		protected function newSkinComp(idName:String,tagName:String,styleVars:Object):SkinStyle
		{
			return new SkinStyle(idName,tagName,styleVars);
		}
		
		public function getSkinDataByName(tagIdName:String):SkinStyle
		{
			return StyleUtils.getCssBySplitName(tagIdName,skinData) as SkinStyle;
		}
		
		public function hasSkinComposite(tagIdName:String):Boolean
		{
			var skinCom:SkinStyle = StyleUtils.getCssBySplitName(tagIdName,skinData) as SkinStyle;
			return skinCom!=null;
		}
		
		public function registerTag(tagName:String, dispClz:Class):void
		{
			tagClzMap[tagName] = dispClz;
		}
		
		public function getTagClass(clzName:String):Class
		{
			return tagClzMap[clzName] as Class;
		}
		
		public function hasTagClass(clzName:String):Boolean
		{
			return tagClzMap[clzName]!=null;
		}
		
		public function dispose():void
		{
			tagClzMap = {};
			skinData.safeRemove(skinData);
			skinData = null;
		}
	}
}