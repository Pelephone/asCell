package utils.tools
{
	import flash.utils.describeType;

	/**
	 * 将对象通过vo的属性和类型解析成vo
	 * @author Pelephone
	 */
	public class VOTool
	{
		private static const TOSTRING_CLASS_PREFIX:String = "[class ";	//toString的类字符前缀
		
		// 如果要解析的Object对象里是否有此属性,有的话就查映射找到相应的Class来解析
		private static const VO_MAPPER_NAME:String = "voMapperName";
		
		// 映射引用对象的绑定.对象里的变量有类型，并映射在这个对象里才解析，反之不解析
		private var clzMapper:Object={};
		
		public function VOTool()
		{
		}
		
		/**
		 * 把对象解析为VO数组数据,可以把obj数组里跟clz字段相同的对象斌值过去
		 * @param obj		要解析的Object对象
		 * @param clz		要解析成的vo对象的类名
		 * @return 
		 */
		public static function objToVOArray(Jobj:Array,voClz:Class):Array
		{
			var arr:Array = [];
			for each (var o:Object in Jobj) 
			{
				arr.push(objToVO(Jobj,voClz));
			}
			return arr;
		}
		
		/**
		 * 把对象解析成vo,不过不解析引用类型的属性
		 * @param Jobj		要解析的Object对象
		 * @param voClz		要转成的vo对象的类名
		 */
		public static function objToVO(Jobj:Object,voClz:Class,ignoreProps:Array=null):*
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
				
//				propType = getClassByAllSrc(propType);
//				var clz:Class = getClzByName(propType);
				
				var val:Object = Jobj[propName];
				// Jobj里面有newObj一样的数据才解析
				if(!val) continue;
				
				newObj[propName] = val;
			}
			
			return newObj;
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
			var voType:String = Jobj[VO_MAPPER_NAME];
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
				if(!arr[i].hasOwnProperty(VO_MAPPER_NAME)) continue;
				var voType:String = arr[i][VO_MAPPER_NAME];
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
		////////////////////////////////////////////////////
		
		
		/**
		 * 把Class注册映射到clzMapper里面，用于解析xml数据
		 * @param cls
		 */
		public function regClz(...cls):void
		{
			try
			{
				for each (var clz:* in cls) 
				{
					if(!(clz is Class)) throw new Error();
					clzMapper[clz.toString()] = clz;
				}
			} 
			catch(error:Error) 
			{
				throw new Error("regClz进的参数必须是Class");
			}
		}
		
		/////////////////////////////////////
		
		/**
		 * 转换类名
		 * 将flash.display::Sprite这样形式的字符串换成Sprite
		 * @param reObjStr
		 * @return 
		 */
		private function getClassByAllSrc(reObjStr:String):String
		{
			var lid:int = reObjStr.lastIndexOf("::");
			if(lid<0) return reObjStr;
			return reObjStr.substring(lid+2);
		}
		
		/**
		 * 通过类名获取绑定在映射表里面的类
		 * @param clzName
		 * @return 
		 */
		private function getClzByName(clzName:String):Class
		{
			var mapName:String = TOSTRING_CLASS_PREFIX + clzName + "]";
			return clzMapper[mapName] as Class;
		}
		
		/**
		 * 通过实例对象获取绑定在映射类里面对象的类
		 * @param obj
		 * @return 
		 
		private function getClzByObj(obj:Object):Class
		{
			var objClzName:String = obj.toString();
			var mapName:String = objClzName.substring(TOSTRING_CLASS_PREFIX.length,
				(objClzName.length-2));
			return clzMapper[mapName] as Class;
		}*/
	}
}