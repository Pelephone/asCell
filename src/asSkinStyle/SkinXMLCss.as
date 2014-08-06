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
* WITHOUT WARRANTIES 
*/
package asSkinStyle
{
	import asSkinStyle.data.StyleModel;
	import asSkinStyle.draw.CircleDraw;
	import asSkinStyle.draw.CircleSprite;
	import asSkinStyle.draw.RectDraw;
	import asSkinStyle.draw.RectSprite;
	import asSkinStyle.parser.DecodeXmlStyle;
	import asSkinStyle.parser.EncodeXmlStyle;
	
	import flash.display.DisplayObject;
	
	/**
	 * 解析xml生成显示皮肤
	 * 目前支持<new><get>标签,new是创建显示对象并addChild到节点,<get>是getChildByName
	 * 特殊属性name,clzTag,reference,path
	 * <root>
	 * 	<new path="" name="">
	 * </root>
	 * 
	 * 如果节点有path属性则无视标签层级
	 * <root>
	 * 	<get name="" path="" />
	 * 	<get name="" path="" />
	 * </root>
	 * @author Pelephone
	 */
	public class SkinXMLCss
	{
		public function SkinXMLCss(styleModel:StyleModel=null)
		{
			_model = styleModel || new StyleModel();
			encodeStyleClip = new EncodeXmlStyle(model);
			decodeStyleClip = new DecodeXmlStyle(model);
			
			initReg();
		}
		
		protected function initReg():void
		{
			registerClass("rect",RectDraw);
			registerClass("rectSR",RectSprite);
			registerClass("circle",CircleDraw);
			registerClass("circleSR",CircleSprite);
		}
		
		protected var _model:StyleModel;
		
		/**
		 * 样式数据模型
		 * @return 
		 */
		public function get model():StyleModel
		{
			return _model;
		}
		
		/**
		 * 注册引用变量对象
		 * @param tagName
		 * @param target
		 */
		public function registerObject(tagName:String, target:Object):void
		{
			_model.registerObject(tagName,target);
		}
		
		/**
		 * 注册类别名,供反射样式时用
		 * @param tagName
		 * @param target
		 */
		public function registerClass(tagName:String, target:Class):void
		{
			_model.registerClass(tagName,target);
		}
		

		/**
		 * 解析样式
		 */
		protected var encodeStyleClip:EncodeXmlStyle;
		
		
		/**
		 * 将数据解析建立结构
		 * @param dat
		 */
		public function encodeBuilder(dat:Object):void
		{
			encodeStyleClip.encodeBuilder(dat);
		}
		
		/**
		 * 将数据解析成样式结构
		 * @param dat
		 */
		public function encodeStyle(dat:Object):void
		{
			encodeStyleClip.encodeStyle(dat);
		}
		
		/**
		 * 样式
		 */
		protected var decodeStyleClip:DecodeXmlStyle;
		
		/**
		 * 通过id创建皮肤
		 * @param idPath
		 * @param toSkin
		 */
		public function decodeBuildStyle(idPath:String,toSkin:DisplayObject=null):DisplayObject
		{
			return decodeStyleClip.decodeBuildStyle(idPath,toSkin);
		}
		
		/**
		 * 通过样式id路径，设置皮肤
		 * @param idPath
		 * @param skin
		 */
		public function decodeSetStyle(idPath:String,skin:DisplayObject):DisplayObject
		{
			return decodeStyleClip.decodeSetStyle(idPath,skin);
		}
	}
}