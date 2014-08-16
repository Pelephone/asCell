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
	import flash.utils.describeType;

	/**
	 * Object映射转换工具,可以将vo/po与Object对象互相转换
	 * @website http://www.cnblogs.com/pelephone
	 * @author Pelephone
	 */
	public class ObjectMapper extends BaseMapper
	{
		/**
		 * 对象里存vo的属性名. 如果对象无此属性,只能不解析.
		 */
		private var _voMapperName:String = "voMapperName";
		
		public function ObjectMapper(voMapperAttr:String="voMapperName")
		{
			super();
			_voMapperName = voMapperAttr;
		}
		
		/**
		 * 把对象解析成vo,不过对象里面的数组和Object数据获了类型,所以数组和不解析
		 * @param val
		 * @param clzType	必须是mapper里面绑定过的对象,不然不解析
		 * @return 
		 */
		private function parseObjToVOByMapper(val:Object,clzType:String):*
		{
			switch(clzType)
			{
				// 基本类型 如果是基本类型就直接在节点斌值
				case "int":
					return int(val);
				case "uint":
					return uint(val);
				case "Boolean":
					return Boolean(val);
				case "Number":
					return Number(val);
				case "String":
					return decodeURIComponent(String(val));
				case "Object":
					return specObjToVOByMapper(val);
					// 数组类型
				case "Array":
					return objToArrayByMapper(val as Array);
				default:
					var clz:Class = getClzByName(clzType);
					if(!clz){
						return null;
					}
					return objToVOByMapper(val,clz);
					break;
			}
		}
		
		/**
		 * 解析特殊对象(有VO_MAPPER_NAME属性的对象)转成vo
		 * @param Jobj
		 */
		private function specObjToVOByMapper(Jobj:Object):*
		{
			var voType:String = Jobj[voMapperName];
			if(!voType) return Jobj;
			var clz:Class = getClzByName(voType);
			if(clz==null) return Jobj;
			return objToVOByMapper(Jobj,clz);
		}
		
		/**
		 * 解析有特殊属性对象数组(有VO_MAPPER_NAME属性的对象)
		 * @param Jobj
		 * @return 
		 */
		private function objToArrayByMapper(arr:Array):Array
		{
			for (var i:int = 0; i < arr.length; i++) 
			{
				if(!arr[i] || !arr[i].hasOwnProperty(voMapperName)) continue;
				var voType:String = arr[i][voMapperName];
				if(!voType) continue;
				arr[i] = parseObjToVOByMapper(arr[i],voType);
			}
			return arr;
		}
		
		
		/**
		 * 把对象解析成vo,不过对象里面的数组和Object数据获了类型,所以数组和不解析
		 * @param val
		 * @param clzType	必须是mapper里面绑定过的对象,不然不解析
		 * @return 
		 */
		public function objToVOByMapper(Jobj:Object,voClz:Class=null,ignoreProps:Array=null):*
		{
			var newObj:Object = new voClz();
			var desc:XMLList = describeType( newObj )["variable"];
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				
				propType = getClassByAllSrc(propType);
				var clz:Class = getClzByName(propType);
				
				var val:Object = Jobj[propName];
				// 如果无节点或者节点是数组则不解析
				if(!val) continue;
				
				newObj[propName] = parseObjToVOByMapper(val, propType);
			}
			
			return newObj;
		}

		/**
		 * 对象里存vo的属性名. 如果对象无此属性,就不解析.
		 */
		public function get voMapperName():String
		{
			return _voMapperName;
		}

		/**
		 * 对象里存vo的属性名. 如果对象无此属性,就不解析.
		 * @private
		 */
		public function set voMapperName(value:String):void
		{
			_voMapperName = value;
		}

	}
}