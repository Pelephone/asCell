package utils.tools
{
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.describeType;

	/**
	 * 解释工具，解释xml，obj...
	 * xml解析,json解析
	 * @author Pelephone
	 */	
	public class ParseTool
	{
		public function ParseTool()
		{
		}
		
		////////////////////////////////////////////////
		// xml解析部分
		///////////////////////////////////////////////
		
		/**
		 * 将xml上的属性信息解析到单个对象
		 * @param xml			要解析的xml
		 * @param obj	  		要将xml解析到对象类
		 * @param ignoreProps	忽略的属性名列表
		 * @return 
		 */		
		static public function parseXMLItem(xml:Object, obj:Object, ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):*
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return;
			
			var desc:XMLList = describeType( obj )["variable"];
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				
				var list:XMLList = xml.attribute(propName);
				// 先判断是否有此属性,没有再判断是否有些节点
				if(!list.length()) list = xml.child(propName);
				// 如果无节点或者节点是数组则不解析
				if(!list.length() || list.length()>1) continue;
				
				switch(propType)
				{
					// 基本类型
					case "Boolean":
						obj[propName] = Boolean(int(list))
						break;
					case "int":
					case "uint":
					case "String":
					case "Number":
					{
						obj[propName] = list;		// 变量名 和 xml节点名 必须相同 
					}
						break;
					case "Array":
					{
						if(isChangArr){
							if(String(list).length<1)	continue;
							var arr:Array = String(list).split(",");		// 将xx,xx,xx形式转为数组
							if(isArrInt && arr){
								for(var i:int=0;i<arr.length;i++)
									arr[i] = int(arr[i]);
							}
							obj[propName] = arr;
						}
					}
						break;
				}
			}
			return obj;
		}
		
		/**
		 * 解析xml并生成新的对象返回
		 * @param xml		  要解析的xml
		 * @param tClass	  要将xml解析生成的类
		 * @param ignoreProps 忽略的属性名列表
		 * @return 
		 */		
		static public function parseXMLByClass(xml:Object, tClass:Class, ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):*
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return;
			var obj:Object = new (tClass)();
			parseXMLItem(xml,obj,ignoreProps,isChangArr,isArrInt);
			return obj;
		}
		
		/**
		 * 将xml解析到数组对象里面,不包括子节点
		 * @param xmlList
		 * @param defaultClass
		 * @param ignoreProps
		 * @return 
		 */		
		static public function parseXMLList(xmlList:XMLList, defaultClass:Class, ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):Array
		{
			if(xmlList==null || defaultClass==null) return null;
			var arr:Array = new Array;
			for each(var xml:XML in xmlList)
			{
				var obj:Object = parseXMLByClass(xml, defaultClass, ignoreProps,isChangArr,isArrInt);
				arr.push( obj ); 
			}
			return arr;
		}
		
		public static const DEFAULT_HASH_KEY:String = "id";	//默认的哈希id
		
		/**
		 * 通过xml，以键值方式解析到哈希对象里面
		 * @param xmlList
		 * @param defaultClass
		 * @param key			以某个字段值为键值,并以该key为前缀
		 * @param ignoreProps
		 * @param isChangArr
		 * @param isArrInt
		 * @return 
		 */
		static public function parseXMLHashObj(xmlList:XMLList, defaultClass:Class,key:String='id', ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):Object
		{
			if(xmlList==null || defaultClass==null) return null;
			if(!key || key=="")
				throw new Error("解析" + String(defaultClass) + "缺少主键!");
			var obj:Object = new Object();
			for each(var xml:XML in xmlList)
			{
				var obj2:Object = parseXMLByClass(xml, defaultClass, ignoreProps,isChangArr,isArrInt);
				
				if(!obj2.hasOwnProperty(key))
					throw new Error(obj2+" 对象没有主键对应的值 " + key);
				
				var keyVal:Object = obj2[key];
				obj[key+"|"+keyVal] = obj2;
			}
			return obj;
		}
		
		/**
		 * 通过xml，以键值方式解析到哈希对象里面
		 * @param xmlList
		 * @param defaultClass
		 * @param keys			以多个字段值为键值,并以该第一个key为前缀,用","隔开
		 * @param ignoreProps
		 * @param isChangArr
		 * @param isArrInt
		 * @return 
		 * 
		 */
		static public function parseXMLHashObj2(xmlList:XMLList, defaultClass:Class,keys:String, ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):Object
		{
			if(xmlList==null || defaultClass==null) return null;
			var obj:Object = new Object();
			var keyArr:Array = keys.split(",");
			if(keyArr.length<1) throw new Error("解析" + String(defaultClass) + "缺少主键!");
			
			for each(var xml:XML in xmlList)
			{
				var obj2:Object = parseXMLByClass(xml, defaultClass, ignoreProps,isChangArr,isArrInt);
				var keyStr:String = keys + "|";
				for (var i:int = 0; i < keyArr.length; i++) 
				{
					var key:String = keyArr[i];
					
					if(!obj2.hasOwnProperty(key))
						throw new Error(obj2+" 对象没有主键对应的值 " + key);
					
					if(i!=0) keyStr += ",";
					keyStr += obj2[key];
				}
				
				obj[keyStr] = obj2;
			}
			return obj;
		}
		
		/**
		 * 通过多键值查找解析的对象
		 * @param hashObj
		 * @param keys
		 * @param argKeys
		 
		public static function getObjByHashKey(hashObj:Object,keys:String="id",...argKeys):*
		{
//			var keyArr:Array = keys.split(",");
			var keyStr:String = keys + "|" + argKeys.join(",");
			if(!hashObj.hasOwnProperty(keyStr)) return null;
			return hashObj[keyStr];
		}*/
		
		/**
		 * 通过默认的id键值查找解析的对象
		 * @param hashObj
		 * @param keys
		 * @param argKeys
		 
		public static function getObjByHashID(hashObj:Object,...argKeys):*
		{
//			var keyStr:String = getKeyByArg(DEFAULT_HASH_KEY,argKeys);
//			var keyArr:Array = DEFAULT_HASH_KEY.split(",");
			var keyStr:String = DEFAULT_HASH_KEY + "|" + argKeys.join(",");
			if(!hashObj.hasOwnProperty(keyStr)) return null;
			return hashObj[keyStr];
		}*/
		
		/**
		 * 通过参数生成Key组合字符
		 * @param keys
		 * @param argKeys
		 * @return 
		 
		public static function getKeyByArg(keys:String = "id",...argKeys):String
		{
			var keyArr:Array = keys.split(",");
			return keys + "|" + argKeys.join(",");
		}*/
		
		/**
		 * 通过参数生成默认的id键字符
		 
		public static function getDefaultKeyById(id:int):String
		{
			return DEFAULT_HASH_KEY + id;
		}*/
		
		/**
		 * 复制srcObj对象的属性给refObj，如果原对象与新对象的属性名相同，并且类型相同则复制属性值。
		 * (属性必须是public型)
		 * @param srcObj		要移的数据对象
		 * @param refObj		要改变值的对象
		 * @param defaultClass
		 * @param ignoreProps
		 * @param isStrict	是否严格匹配，即srcObj上的属性必须不为0才赋值给refObj
		 * @return 
		 */
		static public function parseObjToNew(srcObj:Object, refObj:Object, ignoreProps:Array=null, isStrict:Boolean=false):void
		{
			var desc:XMLList = describeType( refObj )["variable"];
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				//严格匹配
				if(isStrict && !srcObj[propName]) continue;
				
				// 如果类型一样则复制
				if(srcObj.hasOwnProperty(propName)){
					if((srcObj[propName] is String) || (srcObj[propName] is Number))
						refObj[propName] = srcObj[propName];
					else if(srcObj[propName] is TextField)
						refObj[propName].text = srcObj[propName];
					else if(srcObj[propName] is MovieClip){
						(refObj[propName] as MovieClip).gotoAndStop(int(srcObj[propName]));
					}
				}
			}
		}
		
		/**
		 * 将xml解析到数组对象里面,不包括子节点(此解析方法会连同get/set属性一起解)
		 * @param xmlList
		 * @param defaultClass
		 * @param ignoreProps
		 * @return 
		 */		
		static public function parseXMLList2(xmlList:XMLList, defaultClass:Class, ignoreProps:Array=null,isChangArr:Boolean=false,isArrInt:Boolean=false):Array
		{
			if(xmlList==null || defaultClass==null) return null;
			var arr:Array = new Array;
			for each(var xml:XML in xmlList)
			{
				var obj:Object = new (defaultClass)();
				var desc:XMLList = describeType( obj )["accessor"];
				for each(var prop:XML in desc)
				{
					var propName:String = prop.@name;			// 变量名
					var propType:String = prop.@type;			// 变量类型
					var propAccess:String = prop.@access		// 是否可读可写
						
					if(propAccess.indexOf("write")<0) continue;
					if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
					
					var list:XMLList = xml.attribute(propName);
					// 先判断是否有此属性,没有再判断是否有些节点
					if(!list.length()) list = xml.child(propName);
					// 如果无节点或者节点是数组则不解析
					if(!list.length() || list.length()>1) continue;
					
					obj[propName] = list;
				}
				parseXMLItem(xml,obj,ignoreProps,isChangArr,isArrInt);
				arr.push( obj ); 
			}
			return arr;
		}
		
		/**
		 * 数组数据转哈希数据
		 * @param ary 要转的数组数据
		 * @param keys 键数据
		 */
		public static function aryToHash(ary:Object,keys:Array=null):Object
		{
			if(!keys)
				keys = [DEFAULT_HASH_KEY];
			var obj:Object = {};
			for each (var itm:Object in ary) 
			{
				var key:String = keyObjectValue(itm,keys);
				obj[key] = itm;
			}
			return obj;
		}
		
		/**
		 * 通过对象和键名生成键值字符数据
		 * @param keys
		 * @param obj
		 * @return 
		 */
		public static function keyObjectValue(obj:Object,keys:Array):String
		{
			if(!keys)
				keys = [DEFAULT_HASH_KEY];
			var keyStr:String = "";
			var keyVal:String = "";
			for (var i:int = 0; i < keys.length; i++) 
			{
				var key:String = String(keys[i]);
				if(i<(keys.length - 1))
				{
					keyStr = keyStr + key + ",";
					keyVal = keyVal + obj[key] + ",";
				}
				else
				{
					keyStr = keyStr + key ;
					keyVal = keyVal + obj[key] ;
				}
			}
			return keyStr + "|" + keyVal;
		}
		
		////////////////////////////////////////////////
		// json解析部分
		///////////////////////////////////////////////
		
	}
}