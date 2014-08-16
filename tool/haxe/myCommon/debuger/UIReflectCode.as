/**
 * Copyright(c) 2012 the original author or authors.
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
package debuger
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import utils.collection.LinkHashMap;

	/**
	 * 反射UI创建工具，用于将fla里面的导出拼装生成as创建代码<br/>
	 * 
	 * 思路
	 * 遍历所有子项
	 * 通过子项name和descriptType反射出创建子项的代码
	 * 子项属性是Array型则遍历数组，生成创建代码后加入数组
	 * 子项是字符数字型则比较默认项时的属性，不一样则生成设置属性
	 * 子项是其它特殊型，判断是否在需生成组，是就创建对象set进去，反之过滤
	 * 
	 * 此工具仅用于生成UI对象代码，项目中无用。
	 * 
	 * Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class UIReflectCode
	{
		/**
		 * 单例
		 */
		private static var instance:UIReflectCode;
		/**
		 * 获取单例
		 */
		public static function getInstance():UIReflectCode
		{
			if(!instance)
				instance = new UIReflectCode();
			
			return instance;
		}
		
		public function UIReflectCode()
		{
			regReflObj(TextField);
			regReflObj(SimpleButton);
			regReflObj(MovieClip);
			regReflObj(Sprite);
			regReflObj(TextFormat);
			regReflObj(GradientGlowFilter);
			regReflObj(GradientBevelFilter);
			regReflObj(GlowFilter);
			regReflObj(DropShadowFilter);
			regReflObj(DisplacementMapFilter);
			regReflObj(ConvolutionFilter);
			regReflObj(ColorMatrixFilter);
			regReflObj(BevelFilter);
			regReflObj(BlurFilter);
			regReflObj(Object);
			regReflObj(Point);
			
//			tmpImportArr.push("utils.LinkageRefl");
			
			if(instance)
				throw new Error("UIReflectCode is singleton class and allready exists!");
			
			instance = this;
		}
		
		private var file:FileReference;
		
		//---------------------------------------------------
		// lang字符规则，语言包
		//---------------------------------------------------
		
		/**
		 * 新建变量字符规则
		 */
		private static const varLang:String = "var {name}:{type};";
		/**
		 * 新建对象字符规则
		 */
		private static const newLang:String = "{name} = {create};";
		
		/**
		 * 新建监时变量并设新值
		 */
		private static const varNewLang:String = "var {name}:{type} = {create};";
		
		/**
		 * 转义创建对象
		 */
		private static const otherNewLang:String = "var {name:{type2} = reflNewUI.sp(type3)}";
		
		/**
		 * 设置对象字符规则
		 */
		private static const setLang:String = "{name}.{attr} = {val};";
		/**
		 * 动态属性设置对象字符规则
		 */
		private static const setLang2:String = "{name}[{attr}] = {val};";
		/**
		 * 添加子项规则
		 */
		private static const setLang3:String = "{name}.addChild({val});";
		
		/**
		 * 根字符串
		 */
		public static var ROOT_STR:String = "skin";
		
		/**
		 * 需要强制转整型的属性(四舍五入)
		 */
		public static var forceIntAttr:Vector.<String> = new <String>["width","height","x","y"];
		
		/**
		 * 基本类型
		 */		
		private static const normalTypes:Array = ["Boolean","int","uint","Number","String"];
		
		/**
		 * 完成包生成字符规则
		 */
		private static const fullPackLang:String = "package {package}\n" +
			"{\n" +
			"{Import}\n" +
			"	\/**\n" +
			" 	 * {note}\n" +
			" 	 * 此代码由程序自动生成\n" +
			" 	 * @author {user}\n" +
			" 	 *\/\n" +
			"	public class {clsname}\n" +
			"	{\n" +
			"{attr}" +
			"		\n" +
			"		// 生成到的皮肤\n" +
			"		private var skin:Sprite;\n" +
			"" +
			"		public function {clsname}(viewSkin:Sprite)\n" +
			"		{\n" +
			"			skin = viewSkin;\n" +
			"			init();\n" +
			"		}\n" +
			"\n" +
			"		private function init():void\n" +
			"		{\n" +
			"{init}\n" +
			"		}\n" +
			"{other}" +
			"	}\n" +
			"}";
		
		/**
		 * 简单字符规则
		 */
		private static const simplyCodeLang:String = "	\n{pubVar}\n" +
			"		\n" +
			"		public function init():void\n" +
			"		{\n" +
			"			{init}\n" +
			"		}\n";
		
		//---------------------------------------------------
		// 生成时用的临时变量
		//---------------------------------------------------
		
		/**
		 * 暂存某次生成的代码的导入组
		 */
		private static var tmpImportArr:Vector.<String> = new Vector.<String>();
		
		/**
		 * 公共变量生成组
		 */
		private static var pubValArr:Vector.<String> = new Vector.<String>();
		
		/**
		 * 已经生成过代码的对象，防止一个对象创建2次代码,键是对象，值是对象名 {Object,KeyObject}
		 */
		private var hadCreateObjMap:LinkHashMap = new LinkHashMap();
		/**
		 * 以路径做为主键的映射
		 */
		private var pathKOMap:Object = {};
		
		/**
		 * 映射已创建的键对象
		 * @param obj
		 */
		private function setKeyObj(obj:KeyObject):void
		{
			hadCreateObjMap.put(obj.target,obj);
			pathKOMap[obj.pathKey] = obj;
		}
		
		/**
		 * 父类ko
		 * @param ko
		 * @return 
		 */
		private function getParentKO(ko:KeyObject):KeyObject
		{
			var tid:int = ko.pathKey.lastIndexOf(".");
			var str:String = ko.pathKey.substring(0,tid);
			var reKo:KeyObject = pathKOMap[str] as KeyObject;
			if(!reKo)
				return null;
			else
				return reKo;
		}
		
		/**
		 * 通过当前的ko获取父类ko
		 * @return 
		 */
		private function getParentKOTmpVar(ko:KeyObject):String
		{
			var tid:int = ko.pathKey.lastIndexOf(".");
			var str:String = ko.pathKey.substring(0,tid);
			var reKo:KeyObject = pathKOMap[str] as KeyObject;
			if(!reKo)
				return ROOT_STR;
			else
				return reKo.tmpVarName;
		}
		
		//---------------------------------------------------
		// 待注入的变量
		//---------------------------------------------------
		
		/**
		 * 特殊gui前缀转换
		 */
		public var GUI_RULE_STR:String = "gui_";
		/**
		 * 注册前缀类
		 */
		public var REG_RULE_STR:String = "reg_";
		/**
		 * 忽略前缀类型
		 */
		public var IGNORE_STR:String = "ign_";
		/**
		 * 包名
		 */
		public var pathRoot:String = "";
		/**
		 * 生成的当前对象类名
		 */
		public var doClsName:String;
		private function get oClsName():String 
		{
			var tid:int = doClsName.lastIndexOf(".");
			if(tid>=0)
				return doClsName.substring(tid+1);
			return doClsName;
		}
		/**
		 * 注释
		 */
		public var note:String = "皮肤";
		/**
		 * 作者名
		 */
		public var uesrName:String = "Pelephone";
		
		/**
		 * 反射类名
		 */
		public var linageReflStr:String;
		
		//---------------------------------------------------
		// 待解析子项字符组
		//---------------------------------------------------
		
		/**
		 * 能解释的子项类名
		 */
		public static var regObjCodeLs:Vector.<String> = new Vector.<String>();
		
		/**
		 * 注册要解析的子型名
		 * @param clsName 类名字符串，全名，例如"flash.text.TextField"
		 */
		public static function regReflName(clsName:String):void
		{
			if(regObjCodeLs.indexOf(clsName)<0)
				regObjCodeLs.push(clsName);
		}
		
		/**
		 * 注册能解析的类
		 * @param obj
		 */
		public static function regReflObj(obj:Class):void
		{
			var clsName:String = getQualifiedClassName(obj);
			clsName = clsName.replace("::",".");
			regObjCodeLs.push(clsName);
		}
		
		/**
		 * 过滤不生成的属性名
		 */
		public var filterAttrName:Vector.<String> = new <String>["htmlText","trackAsMenu","enabled"];
		
		/**
		 * 只生成的属性，如果这个数组有数据，则只生成数组有的属性
		 */
		public var onlyAttrName:Vector.<String> = null;
		
		/**
		 * 是否生成字体格式
		 */
		public var isCreateFormat:Boolean = false;
		
		//---------------------------------------------------
		// 反射生成开始
		//---------------------------------------------------
		
		/**
		 * 生成方法注入信息
		 * @param obj
		 * @param beNewObj
		 * @return 
		 */
		public function reflCreateFunc(obj:Object,beNewObj:Object=null):String
		{
			if(beNewObj == null)
				beNewObj = new Sprite();
			
			reflValue(obj,beNewObj);
			
			var initStr:String =  packKeyObject();
			var pubStrr:String = packPubVarKeyObject();
			
			var astr:String = simplyCodeLang.replace("{init}",initStr);
			astr = astr.replace("{pubVar}",pubStrr);
			return astr;
		}
		
		/**
		 * 生成包类信息
		 * @param obj
		 * @param beNewObj
		 * @return 
		 */
		public function reflCreateCls(obj:Object,beNewObj:Object=null):String
		{
			if(beNewObj == null)
				beNewObj = new Sprite();
			
			reflValue(obj,beNewObj);
			
			var tid:int = doClsName.lastIndexOf(".");
			if(tid>=0)
				var ocname:String = doClsName.substring(tid+1);
			else
				ocname = doClsName;
			ocname = ocname || getObjCName(obj);
			var ncname:String = getObjCName(beNewObj);
			pushImportCode(getQualifiedClassName(beNewObj));
			
			var packName:String = doClsName.substring(0,tid);
			
			// 导入包字符
			var impstr:String = "";
			for each (var itm:String in tmpImportArr) 
				impstr += "\timport " + itm + ";\n";
			
			var initStr:String =  packKeyObject();
			var pubStrr:String = packPubVarKeyObject();
			
			var astr:String = fullPackLang.replace("{package}",packName);
			astr = astr.replace("{Import}",impstr);
			astr = astr.replace("{note}",note);
			astr = astr.replace("{user}",uesrName);
			astr = astr.replace("{clsname}",ocname);
			astr = astr.replace("{clsname}",ocname);
			astr = astr.replace("{beClsName}",ncname);
			
			astr = astr.replace("{init}",initStr);
			astr = astr.replace("{attr}",pubStrr);
			astr = astr.replace("{other}","");
			return astr;
		}
		
		/**
		 * 对象对象生成反射代码并导出as文件
		 * @return 
		 */
		public function createAndExportClass(obj:Object,beNewObj:Object=null):String
		{
			if(!file)
				file = new FileReference();
			var str:String = reflCreateCls(obj,beNewObj);
			var tid:int = doClsName.lastIndexOf(".");
			if(tid>=0)
				var ocname:String = doClsName.substring(tid+1);
			else
				ocname = doClsName;
			ocname = ocname || getObjCName(obj);
			var packName:String = doClsName.substring(0,tid);
			var path:String = pathRoot + "/" + packName + "/" + ocname;
			
			file.save(str,ocname + ".as");
			
			return str;
		}
		
		/**
		 * 通过对象反射生成样式文件
		 * @param obj
		 * @param beNewObj
		 * @return 
		 */
		public function createAndExportXML(obj:Object,beNewObj:Object=null):String
		{
			if(!file)
				file = new FileReference();
			var str:String = createStyleXML(obj,beNewObj);
			file.save(str,oClsName + ".xml");
			return str;
		}
		
		/**
		 * 组装样式xml
		 * @return 
		 */
		public function createStyleXML(obj:Object,beNewObj:Object=null):String
		{
			reflValue(obj,beNewObj);
			var xml:XML = new XML(<root/>);
//			xml.appendChild(<!--  -->);
			for each (var itm:KeyObject in hadCreateObjMap.getValues()) 
			{
				if(!(itm.target is DisplayObject || (isCreateFormat && itm.target is TextFormat && itm.setAttrLs.length>1)))
					continue;
				
				var parentKo:KeyObject = getParentKO(itm);
				var pathStr:String;
				if(itm.pathKey == itm.attrName)
					pathStr = "";
				else
					pathStr = itm.pathKey.replace("." + itm.attrName,"");
				
				if(!parentKo)
				{
					child = XMLList(<new/>);
					child.@name = oClsName;
					child.@pathStr = pathStr;
					xml.appendChild(child);
				}
				else
				{
					var child:* = getChildXMLByPath2(itm.pathKey,itm.attrName,xml);
					
					if(child==null || !String(child).length)
					{
						child = XMLList(<new/>);
						child.@clzTag = itm.qType;
						child.@name = itm.attrName;
						if(pathStr)
							child.@pathStr = pathStr;
						xml.appendChild(child);
					}
				}
				createXmlAttr(itm,child);
				
				// 如果要生成文本样式的话，这里要特殊处理
				if(itm.target is TextFormat)
				{
					// 引用用#前缀。
					child.@name = itm.tmpVarName;
					var parentStr:String = pathStr.replace("." + parentKo.attrName,"");
					var parentX:* = getChildXMLByPath2(parentStr,parentKo.attrName,xml);
					if(parentX)
					{
						parentX.@defaultTextFormat = "#" + parentKo.pathKey + "." + itm.tmpVarName;
						var t:String = parentX.@text;
						delete parentX.@text;
						if(t && t.length)
							parentX.@text = t;
					}
					continue;
				}
			}
			return xml.toString();
		}
		
		/**
		 * 生成数据到xml节点
		 * @param itm
		 * @param xmlChild
		 */
		private function createXmlAttr(itm:KeyObject,xmlChild:Object):void
		{
			var tar:Object = itm.target;
			for each (var itmAttr:String in itm.setAttrLs) 
			{
				if(itmAttr=="name" || !tar.hasOwnProperty(itmAttr))
					continue;
				// 根节点不生成
				if(itm.pathKey.indexOf(".")<0 && forceIntAttr.indexOf(itmAttr)>=0)
					continue;
				
				if(tar[itmAttr] is String || tar[itmAttr] is Number
					|| tar[itmAttr]==null)
				{
					if(forceIntAttr.indexOf(itmAttr)>=0)
						xmlChild.@[itmAttr] = Math.round(Number(tar[itmAttr]));
					else
						xmlChild.@[itmAttr] = tar[itmAttr];
				}
				else if(tar[itmAttr] is TextFormat)
				{
					xmlChild.@[itmAttr] = "#" + itmAttr;
				}
			}
		}
		
		private function getChildXMLByPath2(pathKey:String,nodeName:String,xml:*):*
		{
			return xml.children().(@pathStr == pathKey && @name == nodeName);
		}
		private function getChildXMLByPath3(pathKey:String,xml:*):*
		{
			return xml.children().(@pathStr == pathKey);
		}
		/**
		 * 通过路径获取节点
		 * @param pathKey
		 * @return 
		 */
		private function getChildXMLByPath(pathKey:String,xml:*):*
		{
			var tid:int = pathKey.indexOf(".");
			if(tid<0)
			{
				var s:String = pathKey.replace(ROOT_STR,oClsName);
				return xml.children().(@name == s);
			}
			var curStr:String = pathKey.substring(0,tid);
			var nextStr:String = pathKey.substring(tid+1);
			var cx:* = xml.children().(@name == curStr)
			if(cx==null || cx.length()==0)
				return null;
			
			return getChildXMLByPath(nextStr,cx);
		}
		
		/**
		 * 组装生成的字符
		 */
		private function packKeyObject():String
		{
			// 这个循环是整理把text设置放到TextFormat生成完之后
			var arr:Array = hadCreateObjMap.getValues();
//			for each (var itm:KeyObject in hadCreateObjMap.getValues()) 
			for (var k:int = 0; k < arr.length; k++) 
			{
				var itm:KeyObject = arr[k] as KeyObject;
				if(!(itm.target is TextFormat))
					continue;
				
				var parentKo:KeyObject = getParentKO(itm);
				// 如果textFormat没有生成属性，则不生成到defaultTextFormat
				if(itm.setStrLs.length<=1)
				{
//					itm.clear();
					hadCreateObjMap.remove(itm.target);
					for (i = 0; i < parentKo.setStrLs.length; i++) 
					{
						setItemStr = parentKo.setStrLs[i] as String;
						if(setItemStr.indexOf(".defaultTextFormat = ")>=0)
						{
							parentKo.setStrLs.splice(i,1);
							break;
						}
					}
					k--;
					continue;
				}
				
				var txtName:String = "text";
				if(!parentKo || !(parentKo.target is TextField) || parentKo.setAttrLs.indexOf(txtName)<0)
					continue;
				
				var val:String = changeValStr(parentKo.target[txtName]);
				doSetCode(itm,parentKo.tmpVarName,txtName,val);
				
				for (var i:int = 0; i < parentKo.setStrLs.length; i++) 
				{
					var setItemStr:String = parentKo.setStrLs[i] as String;
					if(setItemStr.indexOf(".text = ")>=0)
					{
						parentKo.setStrLs.splice(i,1);
						break;
					}
				}
			}
			
			
			var str:String = "";
			for each (itm in hadCreateObjMap.getValues()) 
			{
				var aStr:String = "";
				
				if(itm.target is TextField && itm.target.text && itm.target.text.length)
				{
					var txtN:String = itm.target.text;
					var tid:int = txtN.search(/\n|\r/);
					txtN = txtN.substring(0,tid);
					aStr += "\t\t\t// " + txtN + " " + itm.attrName + "\n";
				}
				
				if(itm.varStr)
					aStr += "\t\t\t" + itm.varStr + "\n";
				
				if(itm.newStr)
					aStr += "\t\t\t" + itm.newStr + "\n";
				
				for (var j:int = 0; j < itm.setStrLs.length; j++) 
				{
					var itmStr:String = itm.setStrLs[j] as String;
					var attrStr:String = itm.setAttrLs[j] as String;
					if(!itmStr || !attrStr)
						continue;
					// 根的长宽不输出
					if(itm.pathKey == ROOT_STR && ["width","height"].indexOf(attrStr)>=0)
						continue;
					aStr += "\t\t\t" + itmStr + "\n";
					
				}
				
/*				for each (var itmStr:String in itm.setStrLs) 
				{
					if(itmStr)
						aStr += "\t\t\t" + itmStr + "\n";
				}*/
				if(itm.childStr)
					aStr += "\t\t\t" + itm.childStr + "\n";
				
				var pathLs:Array = itm.pathKey.split(".");
				if(pathLs.length<2)
					str += "\n"
						
				if(aStr)
					str += aStr + "\n";
			}
			
			return str;
		}
		
		/**
		 * 组装public属性
		 */
		private function packPubVarKeyObject():String
		{
			var str:String = "";
			for each (var itm:String in pubValArr) 
			{
				str += "\t\t" + itm + "\n";
			}
			return str;
		}
		
		//---------------------------------------------------
		// 创建过程
		//---------------------------------------------------
		
		/**
		 * 对比两对象反射生成
		 * @param obj
		 */
		private function reflValue(obj:Object,toObj:Object=null,varPre:String="public "):void
		{
			var qname:String = getQualifiedClassName(obj);
			qname = qname.replace("::",".");
			if(doClsName == null)
				doClsName = qname;
			
			var dest:Object = getPoolDescribeType(obj);
			var variable:XMLList = dest["variable"];
			
			var keyObj:KeyObject = new KeyObject(ROOT_STR,obj);
			keyObj.pathKey = ROOT_STR;
			keyObj.tmpVarName = ROOT_STR;
			setKeyObj(keyObj);
			
			reflObjectAttrValue(obj,toObj,keyObj);
		}
		
		/**
		 * 反射属性信息
		 * @param obj 要反射的对象
		 * @param keyObj 生成字符到键对象里
		 * @param parentStr {parentStr}.{attrName} = obj[attr];
		 * @param tmpName
		 */
		private function reflObjectAttrValue(obj:Object,beNewObj:Object,keyObj:KeyObject):KeyObject
		{
			// 生成addChild
			var qname:String = getQualifiedClassName(obj);
			var tqname:String = qname.replace("::",".");
			var isDoDsp:Boolean = false;
			if(qname == "flash.display::Sprite" || qname == "flash.display::MovieClip"
			|| tqname == doClsName)
			{
				isDoDsp = true;
				var dsc:DisplayObjectContainer = obj as DisplayObjectContainer;
				for (var i:int = 0; i < dsc.numChildren; i++) 
				{
					var itm:DisplayObject = dsc.getChildAt(i);
					propName = itm.name;
					var beItm:DisplayObject = (beNewObj is DisplayObjectContainer)?beNewObj.getChildByName(propName):null;
					propType = getQualifiedClassName(itm);
					var pType:String = propType.replace("::",".");
					var itmPath:String = joinPath(keyObj.pathKey,propName);
					beItm = beItm || getDefObj(propType) as DisplayObject;
					
//					var itmKo:KeyObject = new KeyObject(itmPath,itm);
//					setKeyObj(itmKo);
//					itmKo.tmpVarName = getAttrName(obj);
//					reflObjectAttrValue(itm,beItm,itmKo);
					
					
					var itmKo:KeyObject;
					if(pType.indexOf(REG_RULE_STR)==0)
					{
						pType = pType.replace(REG_RULE_STR,"");
						regReflName(pType);
					}
					
					if(regObjCodeLs.indexOf(pType)>=0)
					{
						itmKo = reflRegObj(itm,beItm,itmPath,2);
					}
					else if(propType.indexOf(GUI_RULE_STR)==0)
					{
						itmKo = reflGUICode(itm,itmPath,2);
					}
					else if(itm is DisplayObject)
					{
						itmKo = reflOtherDspCode(itm,beItm,itmPath,2);
					}
					
					if(itmKo && keyObj.pathKey == ROOT_STR && obj.hasOwnProperty(propName))
					{
						var aStr:String = "public " + varLang;
						aStr = aStr.replace("{name}",propName);
						aStr = aStr.replace("{type}",itmKo.typeStr);
//						itmKo.pubVar = aStr;
						pubValArr.push(aStr);
					}
				}
			}
			
			var dest:Object = getPoolDescribeType(obj);
			var variable:XMLList = dest["variable"];
			var accessor:XMLList = dest["accessor"];
			beNewObj = beNewObj || getDefObj(qname);
			
			for each(var prop:XML in variable)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 排除动态属性
				var objDC:DisplayObjectContainer = obj as DisplayObjectContainer;
				if(!isDoDsp && objDC && objDC.getChildByName(propName) == obj[propName])
					continue;

				reflOneAttr(obj,beNewObj,keyObj,propType,propName,keyObj.tmpVarName);
			}
			for each(prop in accessor)
			{
				propName = prop.@name;			// 变量名
				propType = prop.@type;			// 变量类型
				var propAccess:String = prop.@access;		// 是否可读可写
				
				if(propAccess.indexOf("write")<0 || propAccess.indexOf("writeonly")>=0)
					continue;
				
				reflOneAttr(obj,beNewObj,keyObj,propType,propName,keyObj.tmpVarName);
			}
			
			for (propName in obj) 
			{
				var itm2:Object = obj[propName] as Object;
				if(!itm2) continue;
				propType = getQualifiedClassName(itm2);
				reflOneAttr(obj,beNewObj,keyObj,propType,propName,keyObj.tmpVarName);
			}
			return keyObj;
		}
		
		/**
		 * 生成单个属性反射
		 * @param obj
		 * @param keyObj
		 * @param propType
		 * @param propName
		 * @param type 0是点语法，1是[]语法
		 */
		private function reflOneAttr(obj:Object,beNewObj:Object,keyObj:KeyObject,propType:String
									 ,propName:Object,parentStr:String,type:int=0):KeyObject
		{
			var itmPath:String = joinPath(keyObj.pathKey,String(propName));
			
			var tmpKo:KeyObject = hadCreateObjMap.get(obj[propName]);
			if(normalTypes.indexOf(propType)<0 && tmpKo && tmpKo.tmpVarName)
			{
				doSetCode(tmpKo,getParentKOTmpVar(tmpKo),propName,tmpKo.tmpVarName);
				return tmpKo;
			}
			
			var qType:String = propType.replace("::",".");
			
			if(!propType || propType.indexOf(IGNORE_STR)==0)
				return null;
			
			if(keyObj.pathKey == ROOT_STR && ["name"].indexOf(propName)>=0)
				return null;
			
			if(!(obj is TextField) && (obj is DisplayObject)
				&& ["scaleX","scaleY"].indexOf(propName)>=0)
				return null;
			
			if(filterAttrName.indexOf(propName)>=0 )
				return null;
			
			if(onlyAttrName && onlyAttrName.indexOf(propName<0))
				return null;
			
			if(propName == "font" && obj[propName] == "_sans")
				return null;
			
			var beItmNew:Object = (beNewObj==null || !beNewObj.hasOwnProperty(propName))?null:beNewObj[propName];
			
			// 跟比对对象一样就不用生成
			if(obj1EqObj2(obj[propName],beItmNew))
				return null;
			
			var val:String = changeValStr(obj[propName]);
			
			if(qType.indexOf(REG_RULE_STR)==0)
			{
				qType = qType.replace(REG_RULE_STR,"");
				regReflName(qType);
			}
			
			// 生成set设置属性
			if(normalTypes.indexOf(propType)>=0)
			{
				doSetCode(keyObj,parentStr,propName,val,type);
			}
			else if(obj[propName]==null && beItmNew!=null)
			{
				doSetCode(keyObj,parentStr,String(propName),"null",type);
			}
			else if(propType == "Object")
			{
				if(obj[propName]!=null && beItmNew==null || obj[propName]!=beItmNew)
				{
					reflObjectCode(obj[propName],beItmNew,keyObj,propName,keyObj.tmpVarName,type);
				}
			}
			else if(propType == "Array")
			{
				reflArr(obj[propName] as Array,beItmNew as Array,itmPath);
			}
			else if(regObjCodeLs.indexOf(qType)>=0)
			{
				reflRegObj(obj[propName],beItmNew,itmPath,type);
			}
			else if(propType.indexOf(GUI_RULE_STR)==0)
			{
				reflGUICode(obj[propName],itmPath,type);
			}
			else if(obj[propName] is DisplayObject)
			{
				reflOtherDspCode(obj[propName],beItmNew as DisplayObject,itmPath,type);
			}
			return keyObj;
		}
		
		/**
		 * 转换值字符
		 * @param val
		 * @return 
		 */
		private function changeValStr(val:Object):String
		{
			if(val is String)
			{
				var reStr:String = String(val);
				reStr = reStr.replace(/\n/g,"\\n");
				reStr = reStr.replace(/\t/g,"\\t");
				reStr = reStr.replace(/\r/g,"\\r");
				return "\"" + reStr + "\"";
			}
			else
				return String(val);
		}
		
		/**
		 * 反射动态对象
		 * @param obj
		 * @param pathStr
		 * @param type
		 */
		private function reflObjectCode(obj:Object,beNewObj:Object,keyObj:KeyObject
										,propName:Object,parentStr:String,type:int=0):KeyObject
		{
			var propType:String = getQualifiedClassName(obj);
			var itmPath:String = joinPath(keyObj.pathKey,String(propName));
			propType = propType.replace("::",".");
			
			if(filterAttrName.indexOf(propName)>=0)
				return null;
			
			if(onlyAttrName && onlyAttrName.indexOf(propName<0))
				return null;
			
			var val:String = changeValStr(obj);
			
			if(propName == "font" && obj[propName] == "_sans")
				return null;
			
			if(propType.indexOf(REG_RULE_STR)==0)
			{
				propType = propType.replace(REG_RULE_STR,"");
				regReflName(propType);
			}
			
			// 生成set设置属性
			if(normalTypes.indexOf(propType)>=0)
			{
				doSetCode(keyObj,parentStr,propName,val,type);
			}
			else if(propType == "Array")
			{
				reflArr((obj as Array),(beNewObj as Array),itmPath);
			}
			else if(regObjCodeLs.indexOf(propType)>=0)
			{
				reflRegObj(obj,beNewObj,itmPath);
			}
			else if(propType.indexOf(GUI_RULE_STR)==0)
			{
				reflGUICode(obj,itmPath);
			}
			else if(obj is DisplayObject)
			{
				reflOtherDspCode((obj as DisplayObject),(beNewObj as DisplayObject),itmPath);
			}
			return keyObj;
		}
		
		/**
		 * 反射其它显示对象
		 * @param obj
		 */
		private function reflOtherDspCode(obj:DisplayObject,beNewObj:DisplayObject,pathStr:String,type:int=0):KeyObject
		{
			var keyObj:KeyObject = new KeyObject(pathStr,obj);
			setKeyObj(keyObj);
			var parentStr:String = getParentKOTmpVar(keyObj);
			var attrName:String = keyObj.attrName;
			
			var qname:String = getQualifiedClassName(obj);
			var tname:String = qname.replace("::",".");
//			pushImportCode(qname);
			
			var cname:String = getObjCName(obj);
			
			keyObj.tmpVarName = getAttrName(obj,attrName);
			var typeStr:String = changeTypeStr2(obj);
			var newStr:String = changeTypeNewStr(obj,tname);
			
			var varStr:String = varNewLang.replace("{name}",keyObj.tmpVarName);
			varStr = varStr.replace("{type}",typeStr);
			varStr = varStr.replace("{create}",newStr);
			keyObj.varStr = varStr;
			keyObj.typeStr = typeStr;
			
			tname = tname.replace("::",".");
			if(tname.indexOf(REG_RULE_STR)==0)
			{
				tname = tname.replace(REG_RULE_STR,"");
			}
			keyObj.qType = tname;
			
			reflObjectAttrValue(obj,beNewObj,keyObj);
			doSetCode(keyObj,parentStr,attrName,keyObj.tmpVarName,type);
			
			return keyObj;
		}
		
		/**
		 * 生成数组对象
		 * @param obj
		 * @param pathStr
		 * @return 
		 */
		private function reflArr(obj:Array,beNewObj:Array,pathStr:String,type:int=0):KeyObject
		{
			var keyObj:KeyObject = new KeyObject(pathStr,obj);
			setKeyObj(keyObj);
			var parentStr:String = getParentKOTmpVar(keyObj);
			var attrName:String = keyObj.attrName;
			
			keyObj.tmpVarName = getAttrName(obj,attrName);
			
			var varStr:String = varNewLang.replace("{name}",keyObj.tmpVarName);
			varStr = varStr.replace("{type}","Array");
			varStr = varStr.replace("{create}","[]");
			keyObj.varStr = varStr;
			keyObj.typeStr = "Array";
			keyObj.qType = "Array";
			
			for (var i:int = 0; i < obj.length; i++) 
			{
				var itm:Object = obj[i] as Object;
				var itmType:String = getQualifiedClassName(itm);
				reflOneAttr(obj,beNewObj,keyObj,itmType,i,keyObj.tmpVarName,1);
			}
			
			doSetCode(keyObj,parentStr,attrName,keyObj.tmpVarName,type);
			
			return keyObj;
		}
		
		/**
		 * 生成已注册对象
		 * @param obj
		 */
		private function reflRegObj(obj:Object,beNewObj:Object,pathStr:String,type:int=0):KeyObject
		{
			var keyObj:KeyObject = new KeyObject(pathStr,obj);
			setKeyObj(keyObj);
			var parentKo:KeyObject = getParentKO(keyObj);
			var attrName:String = keyObj.attrName;
			
			var qname:String = getQualifiedClassName(obj);
			var cname:String = getObjCName(obj);
			if(doTxtName && obj is TextField)
			{
				qname = doTxtName;
				var tid:int = doTxtName.lastIndexOf(".");
				if(tid>=0)
					cname = doTxtName.substring(tid+1);
			}
			
			pushImportCode(qname);
			
			keyObj.tmpVarName = getAttrName(obj,attrName);
			
			var varStr:String = varNewLang.replace("{name}",keyObj.tmpVarName);
			varStr = varStr.replace("{type}",cname);
			varStr = varStr.replace("{create}","new " + cname + "()");
			keyObj.varStr = varStr;
			keyObj.typeStr = cname;
			
			
			qname = qname.replace("::",".");
			if(qname.indexOf(REG_RULE_STR)==0)
			{
				qname = qname.replace(REG_RULE_STR,"");
			}
			keyObj.qType = qname;
			
			reflObjectAttrValue(obj,beNewObj,keyObj);
			doSetCode(keyObj,parentKo.tmpVarName,attrName,keyObj.tmpVarName,type);
/*			if(keyObj.target is TextFormat && parentKo.target is TextField)
			{
				var val:String = changeValStr(parentKo.target["text"]);
				doSetCode(keyObj,parentKo.tmpVarName,"text",val,type);
			}*/
			return keyObj;
		}
		
		/**
		 * gui特殊生成方案 {parentStr}.{propName} = obj[name]|attrName;
		 * @param qType
		 * @return 
		 */
		private function reflGUICode(obj:Object,pathStr:String,type:int=0):KeyObject
		{
			var keyObj:KeyObject = new KeyObject(pathStr,obj);
			setKeyObj(keyObj);
			var parentStr:String = getParentKOTmpVar(keyObj);
			var attrName:String = keyObj.attrName;
			
			keyObj.tmpVarName = getAttrName(obj,attrName);
			var propType:String = getQualifiedClassName(obj);
			propType = propType.replace(GUI_RULE_STR,"");
			pushImportCode(propType);
			var clsName:String = getObjCName(obj);
			
			var varStr:String = varNewLang.replace("{name}",keyObj.tmpVarName);
			varStr = varStr.replace("{type}",propType);
			varStr = varStr.replace("{create}","new " + propType + "()");
			keyObj.varStr = varStr;
			keyObj.typeStr = clsName;
			keyObj.qType = propType;
			
			var arr:Array = "x,y,width,height,scaleX,scaleY".split(",");
			for each (var itm:String in arr) 
			{
				if(itm.indexOf("scale")>=0 && obj[itm] != 1)
					continue;
				if(obj[itm] != 1)
					continue;
				var pathItmStr:String = joinPath(pathStr,itm);
				doSetCode(keyObj,parentStr,itm,obj[itm]);
			}
			
			doSetCode(keyObj,parentStr,attrName,keyObj.tmpVarName,type);
			return keyObj;
		}
		
		/**
		 * 添加导入字符
		 * @return 
		 */
		public function pushImportCode(qname:String):void
		{
			qname = qname.replace("::",".");
			
			if(qname.indexOf(REG_RULE_STR)==0)
				qname = qname.replace(REG_RULE_STR,"");
				
			if(tmpImportArr.indexOf(qname)>=0)
				return;
			
			if(qname.indexOf(".")<0)
				return;
			
			tmpImportArr.push(qname);
		}
		
		/**
		 * 新建议设置代码 {name}.{attr} = {val};
		 * @param tmpName 监听变量名
		 */
		private function doSetCode(keyObj:KeyObject,parentStr:String,attrName:Object,val:String,type:int=0):KeyObject
		{
			var aStr:String = "";
			
			if(type==0)
			{
				aStr = setLang;
			}
			else if(type == 1)
			{
				aStr = setLang2;
				
				var atr:String;
				if(attrName is String)
					atr = "\"" + attrName + "\"";
				else
					atr = String(attrName);
			}
			else
				aStr = setLang3;
			
			atr = String(attrName);
			
			if(parentStr == ROOT_STR && type<2 && val.indexOf(atr)>=0)
				parentStr = "this";
			
			
			if(forceIntAttr.indexOf(atr)>=0)
			{
				val = String(Math.round(Number(val)));
			}
			
			aStr = aStr.replace("{name}",parentStr);
			aStr = aStr.replace("{attr}",atr);
			aStr = aStr.replace("{val}",val);
			
			if(type == 2)
				keyObj.childStr = aStr;
			else
			{
				keyObj.setAttrLs.push(atr);
				keyObj.setStrLs.push(aStr);
			}
			return keyObj;
		}
		
		//---------------------------------------------------
		// 其它共用方法
		//---------------------------------------------------
		
		/**
		 * 是否是英文字符
		 * @param char
		 * @return 
		 */
		private static function isEnglish(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			var pattern:RegExp=/^[A-Za-z]+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * 获取对象类名(非全名)
		 * @param obj
		 * @return 
		 */
		private function getObjCName(obj:Object):String
		{
			var qname:String = getQualifiedClassName(obj);
			var tid:int = qname.indexOf("::");
			if(tid>0)
				return qname.substring(tid+2);
			else
				return qname;
		}
		
		/**
		 * 通过type类型转要生成的对象类型
		 * @return 
		 */
		private function changeTypeStr(qType:String):String
		{
			if(qType == null)
				return null;
			
			if(normalTypes.indexOf(qType)>=0 || qType=="Array" || qType=="Object")
				return qType;
			
			if(regObjCodeLs.indexOf(qType)>=0)
			{
				var tid:int = qType.indexOf("::");
				if(tid>=0)
					return qType.substring(tid+2);
				else
					return qType;
			}
			
			return null;
		}
		
		/**
		 * 转换文本改
		 */
		public var doTxtName:String = null;
		
		/**
		 * 通过Object转要生成的对象类型
		 * @return 
		 */
		private function changeTypeStr2(obj:DisplayObject):String
		{
			if(obj is MovieClip)
			{
				pushImportCode("flash.display.MovieClip");
				return "MovieClip";
			}
			else if(obj is Sprite)
			{
				pushImportCode("flash.display.Sprite");
				return "Sprite";
			}
			else if(obj is TextField)
			{
				if(!doTxtName)
				{
					pushImportCode("flash.text.TextField");
					return "TextField";
				}
				else
				{
					pushImportCode(doTxtName);
					var tid:int = doTxtName.lastIndexOf(".");
					if(tid>=0)
						return doTxtName.substring(tid+1);
					else
						return "TextField";
				}
			}
			else if(obj is SimpleButton)
			{
				pushImportCode("flash.display.SimpleButton");
				return "SimpleButton";
			}
			else if(obj is Bitmap)
			{
				pushImportCode("flash.display.Bitmap");
				return "Bitmap";
			}
			else if(obj is Shape)
			{
				pushImportCode("flash.display.Shape");
				return "Shape";
			}
			else if(obj is InteractiveObject)
			{
				pushImportCode("flash.display.InteractiveObject");
				return "InteractiveObject";
			}
			else if(obj is DisplayObjectContainer)
			{
				pushImportCode("flash.display.DisplayObjectContainer");
				return "DisplayObjectContainer";
			}
			else
			{
				pushImportCode("flash.display.DisplayObject");
				return "DisplayObject";
			}
		}
		
		/**
		 * 通过Object转要生成的对象类型
		 * @return 
		 */
		private function changeTypeNewStr(obj:DisplayObject,name:String):String
		{
			var lang:String;
			var refLang:String = "utils.LinkageRefl";
			if(obj is MovieClip)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.mc({reflCls})";
			}
			else if(obj is Sprite)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.sp({reflCls})";
			}
			else if(obj is SimpleButton)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.sb({reflCls})";
			}
			else if(obj is Bitmap)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.bmp({reflCls})";
			}
			else if(obj is Shape)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.shap({reflCls})";
			}
			else if(obj is DisplayObject)
			{
				if(tmpImportArr.indexOf(refLang)<0)
					tmpImportArr.push(refLang);
				lang = "LinkageRefl.dsp({reflCls})";
			}
			if(!lang)
				return null;
			var reflCls:String;
			if(linageReflStr)
				reflCls = linageReflStr + "." + name.toUpperCase();
			else
				reflCls = "\"" + name + "\"";
			lang = lang.replace("{reflCls}",reflCls);
			return lang;
		}
		
		/**
		 * 连接路径
		 * @param rePath
		 * @param attr
		 * @return 
		 */
		private static function joinPath(rePath:String,attr:String):String
		{
			return rePath + "." + attr + "";
		}
		
		/**
		 * 对象池,提高点性能用的
		 */
		private static var poolMap:Object = {};
		private static var descMap:Object = {};
		
		/**
		 * 通过q全名生成对象
		 * @param qName
		 * @return 
		 */
		private static function getDefObj(qName:String):Object
		{
			var cqName:String = qName.replace("::",".");
			if(poolMap.hasOwnProperty(cqName))
				return poolMap[cqName];
			var cls:Class = ApplicationDomain.currentDomain.getDefinition(cqName) as Class;
			poolMap[cqName] = new cls();
			return poolMap[cqName];
		}
		
		/**
		 * 从缓存获取describeType反射对象相关信息
		 * 如果缓存中没有信息就创建一个放进去
		 */
		private static function getPoolDescribeType(body:Object):*
		{
			var key:String = getQualifiedClassName(body);
			
			if(descMap.hasOwnProperty(key))
				return descMap[key];
			descMap[key] = describeType(body);
			return descMap[key];
		}
		
		//---------------------------------------------------
		// 比对对象属性全等
		//---------------------------------------------------
		
		/**
		 * 判断两个对象是否所有属性都相同
		 * @param obj1
		 * @param obj2
		 */
		private static function obj1EqObj2(obj1:Object,obj2:Object):Boolean
		{
			var qname:String = getQualifiedClassName(obj1);
			var qname2:String = getQualifiedClassName(obj2);
			var qType:String = qname.replace("::",".");
			if(qname != qname2)
				return false;
			else if(obj1 == obj2)
				return true;
			else if(normalTypes.indexOf(qname)>=0 && obj1 != obj2)
				return false;
			else if(qname == "Array")
				return arr1EqArr2(obj1 as Array,obj2 as Array);
			else if(regObjCodeLs.indexOf(qType)>=0)
				return exObj1EqExObj2(obj1,obj2);
			else
				return false;
		}
		
		/**
		 * 判断两个数组是否每个元素都相等
		 * @param arr1
		 * @param arr2
		 */
		private static function arr1EqArr2(arr1:Array,arr2:Array):Boolean
		{
			if((!arr1 && !arr2) || (!arr1.length && !arr2.length))
				return true;
			else if(!arr1 || !arr2 || arr1.length != arr2.length)
				return false;
			
			for (var i:int = 0; i < arr1.length; i++) 
			{
				if(!obj1EqObj2(arr1[i],arr2[i]))
					return false;
			}
			return true;
		}
		
		/**
		 * 比较两个对象是否所有属性相等
		 * @param obj1
		 * @param obj2
		 * @return 
		 */
		private static function exObj1EqExObj2(obj1:Object,obj2:Object):Boolean
		{
			var dest:Object = getPoolDescribeType(obj1);
			var variable:XMLList = dest["variable"];
			var accessor:XMLList = dest["accessor"];
			
			for each(var prop:XML in variable)
			{
				var propName:String = prop.@name;			// 变量名
				if(!obj1EqObj2(obj1[propName],obj2[propName]))
					return false;
			}
			for each(prop in accessor)
			{
				propName = prop.@name;			// 变量名
				var propAccess:String = prop.@access;		// 是否可读可写
				if(propAccess.indexOf("write")<0 || propAccess.indexOf("writeonly")>=0)
					continue;
				if(!obj1EqObj2(obj1[propName],obj2[propName]))
					return false;
			}
			
			return true;
		}
		
		
		//---------------------------------------------------
		// 自动命名
		//---------------------------------------------------
		
		private static var _autoIndex:int = 0;
		
		private static function get autoIndex():int
		{
			return _autoIndex++;
		}
		
		/**
		 * 通过对象转换变量命名
		 * @param obj
		 * @return 
		 */
		private static function getAttrName(obj:Object,atName:String=null):String
		{
			if(atName && isEnglish(atName.charAt()))
				return atName + autoIndex;
			else if(obj.hasOwnProperty("name"))
				return obj["name"] + autoIndex;
			else
				return "local" + autoIndex;
		}
	}
}

/**
 * 单节点生成对象
 * @author Pelephone
 */
class KeyObject
{
	/**
	 * 唯一的键路径名 this.aa.bb.cc
	 */
	public var pathKey:String;
	public var varStr:String;
	public var newStr:String;
	public var childStr:String;
	public var setStrLs:Vector.<String> = new Vector.<String>();
	public var setAttrLs:Vector.<String> = new Vector.<String>();
	/**
	 * 临时名
	 */
	public var tmpVarName:String;
	
	/**
	 * 类型字符
	 */
	public var typeStr:String;
	public var attrName:String;
	
	/**
	 * 类型全名
	 */
	public var qType:String;
	
	/**
	 * 代码生成于此对象
	 */
	public var target:Object;
	
	public function KeyObject(pathStr:String,tar:Object)
	{
		target = tar;
		pathKey = pathStr;
		var pathLs:Array = pathStr.split(".");
		attrName = pathLs[pathLs.length-1];
	}
}