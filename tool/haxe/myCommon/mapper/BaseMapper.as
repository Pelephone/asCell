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
package mapper
{
	import flash.events.EventDispatcher;

	/**
	 * 此类用于存基本对象
	 * @website http://www.cnblogs.com/pelephone 
	 * @author Pelephone
	 */
	public class BaseMapper extends EventDispatcher
	{
		// 关联类,特殊字符
		public static const REFERENCE_CLASS:String = "reference";	//引用属性	(遍历出这个字符就特殊处理)
		
		private static const TOSTRING_CLASS_PREFIX:String = "[class ";	//toString的类字符前缀
		
		private var _isOnlyMapper:Boolean;		//是否只解析映射表有的引用类
		private var _isDynamicAttr:Boolean;	//是否给解析的vo动态添加属性
		
		/** 
		 * 存放Class和对应的名字<String,Class>
		 */
		private var _clzMapper:Object;
		/**
		 * 别名映射<类名,别名><String,String>
		 */
		private var _aliasMapper:Object;
		
		protected var _quoteObj:Object;

		/**
		 * 用于暂存引用对象
		 */
		public function get quoteObj():Object
		{
			if(_quoteObj)
				_quoteObj = {};
			return _quoteObj;
		}

		/**
		 * @private
		 */
		public function set quoteObj(value:Object):void
		{
			if(value == _quoteObj)
				return;
			_quoteObj = value;
		}

		
		public function BaseMapper()
		{
			_clzMapper = {};
			_aliasMapper = {};
		}
		
		/**
		 * 把Class注册映射到clzMapper里面，用于解析xml数据
		 * @param clz		类,用于映射对应xml和localName的解析
		 * @param AliasName	别名,对应xml节点,如果不填默认就是cls的类名
		 */
		public function regClz(clz:Class,aliasName:String=null):void
		{
			try
			{
				if(!(clz is Class))
					throw new Error();
				
				var objClzName:String = String(clz);
				var clsName:String = objClzName.substring(TOSTRING_CLASS_PREFIX.length,
					(objClzName.length-1));
				
				
				var oldAliName:String = getAliasByClzName(clsName);
				if(!oldAliName)
				{
					_aliasMapper[clsName] = aliasName;
					_clzMapper[aliasName] = clz;
					return;
				}
				else
				{
					if(oldAliName == aliasName)
						return;
					else
					{
						delete _aliasMapper[clsName];
						delete _clzMapper[oldAliName];
						
						_aliasMapper[clsName] = aliasName;
						_clzMapper[aliasName] = clz;
					}
				}
			} 
			catch(error:Error) 
			{
				throw new Error(clz + "," + aliasName+"类对象不存在");
			}
		}
		
		/**
		 * 通过别名获取类
		 * @param aliasName
		 * @return 
		 * 
		 */
		public function getClzByAlias(aliasName:String):Class
		{
			return _clzMapper[aliasName];
/*			// 在映射有对象,证明该名字已映射有类
			if(_clzMapper[aliasName]!=null) return false;
			return true;*/
		}
		
		/**
		 * 验证类名是否可以用
		 * @param clzName
		 * @return 
		 */
		public function isVerifyClz(clz:Class):Boolean
		{
			var objClzName:String = String(clz);
			var clzName:String = objClzName.substring(TOSTRING_CLASS_PREFIX.length,
				(objClzName.length-1));
			return Boolean(getAliasByClzName(clzName));
		}
		
		/**
		 * 通过类名获取别名
		 * @param clzName
		 * @return 
		 */
		public function getAliasByClzName(clzName:String):String
		{
			if(_aliasMapper.hasOwnProperty(clzName))
				return _aliasMapper[clzName];
			else
				return null;
/*			// 在映射有对象,证明该类名已绑定了映射
			if(_aliasMapper[clzName]!=null) return false;
			return true;*/
		}

		public function get isOnlyMapper():Boolean
		{
			return _isOnlyMapper;
		}

		public function set isOnlyMapper(value:Boolean):void
		{
			_isOnlyMapper = value;
		}
		
		/**
		 * 转换类名
		 * 将flash.display::Sprite这样形式的字符串换成Sprite
		 * @param reObjStr
		 * @return 
		 */
		protected function getClassByAllSrc(reObjStr:String):String
		{
			var lid:int = reObjStr.lastIndexOf("::");
			if(lid<0) return reObjStr;
			return reObjStr.substring(lid+2);
		}
		
		/**
		 * 通过类名获取绑定在映射表里面的类
		 * 些从类->别名映射中找到别名,再通过别名找到类
		 * @param clzName
		 * @return 
		 */
		protected function getClzByName(clzName:String):Class
		{
//			var mapName:String = TOSTRING_CLASS_PREFIX + clzName + "]";
			var aliasName:String = getAliasName(clzName);
			return _clzMapper[aliasName] as Class;
		}
		
		/**
		 * 通过类别查映射返回映射类的名
		 * @param clzName
		 * @return 
		 */
		protected function getAliasName(clzName:String):String
		{
			var aliasName:String = _aliasMapper[clzName];
			if(!aliasName) return clzName;
			else return aliasName;
		}
		
		/**
		 * 用于暂存引用对象,存储<xml,Object>
		 
		private var quoteObj:Object = {};*/
		/**
		 * xml某节点路径
		 * @param xmlNode
		 
		protected function getXMLParentSrc(xmlNode:XML,nextNode:XML,str:String=null):String
		{
			if(!str){
				str = xmlNode.localName().toString();
			}
			else
			{
				// 数组对象特殊处理
				if(xmlNode.parent() && quoteObj[xmlNode.parent()] is Array)
				{
					var idNum:int = -1;
					for each (var node:Object in xmlNode.children()) 
					{
						if(node===nextNode){
							idNum++;
							break;
						}
					}
					
					str = xmlNode.localName().toString() + "[" + idNum + "]" + "/" + str;
				}
				else
					str = xmlNode.localName().toString() + "/" + str;
			}
			if(xmlNode.parent())
				return getXMLParentSrc(xmlNode.parent(),xmlNode,str);
			else
				return str;
		}*/
		
		/**
		 * 通过别名查找对应的类
		 * @param aliasName
		 
		protected function getClzByAliasName(aliasName:String):Class
		{
			return _clzMapper[aliasName] as Class;
		}*/
		
		/**
		 * 通过实例对象获取绑定在映射类里面对象的类
		 * @param obj
		 * @return 
		 
		protected function getClzByObj(obj:Object):Class
		{
			var objClzName:String = obj.toString();
			var mapName:String = objClzName.substring(TOSTRING_CLASS_PREFIX.length,
				(objClzName.length-1));
			return clzMapper[mapName] as Class;
		}*/

		public function get aliasMapper():Object
		{
			return _aliasMapper;
		}

		public function set aliasMapper(value:Object):void
		{
			_aliasMapper = value;
		}
		
		
		/**
		 * 获取类名与类绑定映射
		 * @return 
		 */
		public function get clzMapper():Object
		{
			return _clzMapper;
		}
		
		/**
		 * 设置类名与类绑定映射
		 * @param value
		 */
		public function set clzMapper(value:Object):void
		{
			_clzMapper = value;
		}
	}
}