package utils.tools{
	import flash.utils.describeType;
	
	/**
	 * @author Pelephone
	 * @version 20090103
	 */
	public class XmlTool {
		
		// 將xml转为新的objcet对象
		public static function xmlDataToVO(xmllist:XMLList,vo:Object=null) : void
		{
			if(!vo) vo = new Object();
			for each (var child:XML in xmllist)
			{
				if (vo.hasOwnProperty(child.name()))
					vo[child.name()] = child;
			}
		}
		
		// 快速设置数据
		static public function xmlToObject_f(obj:Object, xmllist:XMLList):void{
			xmllist = xmllist[0].children();
			for each(var xml:XML in xmllist){
				var key:String = xml.name();
				if(obj.hasOwnProperty( key )){
					var val:Object = decodeURIComponent( xml.valueOf() ); 
					obj[ key ] = val;
				}
			}
		}
		
		/**
		 * 给所有子节点添加属性和值
		 * @param xList		xmlList
		 * @param attrNames	属性名数组列，子项一定是字符型,格式如 str=9,程序自动分析=号左右两边添加属性值
		 */		
		static public function nodeAddAttr(xList:XMLList,...attrList):void
		{
			for each(var o:Object in xList){
				for each(var attStr:String in attrList)
				var attrName:String = attStr.split("=")[0];
				var attrVal:String = attStr.split("=")[1];
				o.@[attrName] = attrVal;
			}
		}
		
		/**
		 * 给子节点列加上一个或者多个父类的属性
		 * @param xList		xmlList
		 * @param attrNames	属性名数组列，子项一定是字符型，不然会报错
		 */		
		static public function xmlAddParentAttr(xList:XMLList,...attrList):void
		{
			for each(var o:Object in xList){
				for each(var attrName:String in attrList)
					o.@[attrName] = o.parent().@[attrName];
			}
		}
		
		/**
		 * 给子节点列加上一个指定的父类的属性
		 * @param xList			XMLList
		 * @param parentName	父节点名
		 * @param attrList		属性名数组列，子项一定是字符型，不然会报错
		 */		
		static public function xmlAddParentAttr2(xList:XMLList,parentName:String,...attrList):void
		{
			var pt:Object = findParentNode(xList,parentName);
			if(!pt) return;
			for each(var o:Object in xList){
				for each(var attrName:String in attrList)
					o.@[attrName] = pt.@[attrName];
			}
		}
		
		/**
		 * 获取节点向上找父节点
		 * @param xList			XMLList节点
		 * @param parentName	父节点的名
		 * @return 
		 */		
		static public function findParentNode(xList:Object,parentName:String):Object
		{
			while(xList.parent()){
				xList = xList.parent();
				if(xList.name().toString()==parentName) return xList;
			}
			return null;
		}
		
		/**
		 * 把 xml 中的属性赋予 obj 对象, 返回是否完全匹配
		 * @param xml		xml 内容
		 * @param obj		目标对象
		 * @param checkPM	是否检测 xml 与 obj 的完全匹配性
		 * @return			返回是否成功匹配
		 */
		static public function xmlToObject(xml:XML, obj:Object, checkPM:Boolean=true) : Boolean {
			
			//
			var key:Array = new Array;
			var value:Array = new Array;
			
			// 从 xml 中读取数据到 key/value 数组中
			for each(var node:XML in xml.*)
			{
				key.push( String(node.name()) );
				value.push( node );
			}
			
			// 设置对象值, 并返回匹配结果
			return setObjectValue(key, value, obj, checkPM);
		}
		
		/**
		 * 从 obj 中建立属性的 xml 描述
		 * @param obj		被建立的对象
		 * @param nodeName	xml的根节点
		 * @return			返回 xml 描述
		 */
		static public function xmlFromObject(obj:Object, type:int=0, nodeName:String="object", ignoreProps:Array=null) : XML {
			
			// 建立 xml
			var xml:XML = new XML("<" + nodeName + "/>");
			
			//
			return copyObjAttrToXml(obj,xml,type,ignoreProps);
		}
		
		/**
		 * 复制对象属性添加到xml节点里面
		 */
		public static function copyObjAttrToXml(obj:Object,xml:Object,type:int=0,ignoreProps:Array=null):*
		{
			// 添加对象 obj 的每个属性到 xml 中
			var desc:XML = describeType(obj);
			for each( var node:XML in desc["variable"])
			{
				var name:String = node.@name;
				var value:Object = obj[ name ];
				
				if(ignoreProps.indexOf(name)>=0) continue;
				//
				if(type==0)
					xml[name] = value;
				else
					xml.@[name] = value;
			}
			
			//
			return xml;
		}
		
		// 从 obj 中建立 URI 编码(encodeURIComponent), 如: "x=3&y=4&name=my%20name"
		// 如果有数组,则以 array_name[0]=value&array_name[1]=value, 数组中仅支持基本类型
		// ignoreDefault 	是否忽略默认值属性
		static public function encodeObject(obj:Object, ignoreDefault:Boolean=false, join_char:String=null):String{
			var arr:Array = new Array;		
			var desc:XML = describeType(obj);
			for each( var node:XML in desc["variable"])
			{
				var name:String = node.@name;
				var type:String = node.@type;
				var value:Object = obj[name];
				if(value == null) continue;
				
				var str:String;
				switch(type)
				{
					case "int":
					case "uint":
						if(!ignoreDefault || (value != 0) )
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "Number":
						if(!ignoreDefault || !isNaN(value as Number) )
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "String":
						if(!ignoreDefault || value!= null)
						{
							str = encodeURIComponent( String(value) );
							arr.push( name + "=" + str );
						}
						break;
					
					case "Array":
						if(!ignoreDefault || value!=null)
						{
							str = encodeArraySimple(name, value as Array);
							arr.push(str);
						}
						break;
				}
			}
			
			if(join_char == null) join_char = "&";
			return arr.join( join_char );
		}
		
		// 编码基本类型数组
		static public function encodeArraySimple(name:String, array:Array):String{
			var arr:Array = new Array;
			const fmt:String = "%s[%d]=%s";
			for(var i:int=0; i<array.length; i++)
			{
				var str:String = encodeURIComponent( String(array[i]) );
				str = StringTool.printf(fmt, name, i, str);
				arr.push( str );
			}
			return arr.join("&");
		}
		
		
		/**
		 * 从 URI 中解码对象 
		 * @param uri		URI 字符串
		 * @param obj		输出的对象
		 * @param checkPM	是否检测 key 与 obj 的完全匹配性
		 * @return			返回是否成功匹配
		 */
		static public function decodeObject(uri:String, obj:Object, checkPM:Boolean=true):Boolean{
			
			var key:Array = new Array;
			var value:Array = new Array;
			
			// 从 uri 中分析数据到 key/value 数组中
			var exp:RegExp = /(.*?)=(.*?)($|&)/g;
			var arr:Array = exp.exec(uri);
			while(arr != null)
			{
				key.push( arr[1] );
				value.push( arr[2] );
				
				arr = exp.exec(uri);
			}
			
			// 设置对象值, 并检测匹配
			return setObjectValue(key, value, obj, checkPM, true);
		}
		
		/**
		 * xml解密,key值可从服务端拿下更新
		 * @author Pelephone
		 * 
		 * @param str
		 * @param sp
		 * @param key
		 */
		public static function decryptWeightXML(str:String,key:String):String
		{
			var sp:String = "";
			var keys:Array = key.split(",");
			var reStr:String = str;
			for (var i:int = 0; i < keys.length; i++) {
				var rStr:String = " " + keys[i] + "=";
				var pStr:String = " "+sp + i+"=";
				var p:RegExp = new RegExp(pStr,"g");
				reStr = reStr.replace(p,rStr);
			}
			return reStr;
		}
		
		
		/**
		 * 设置对象的属性
		 * @param key		关键字表
		 * @param value		值表
		 * @param obj		目标对象
		 * @param checkPM	是否检测 key 与 obj 的完全匹配性
		 * @param decode	是否使用 decodeURIComponent 解码字符串类型的值
		 * @return			返回是否成功匹配
		 */
		static private function setObjectValue(key:Array, value:Array, obj:Object, checkPM:Boolean, decode:Boolean=false):Boolean{
			
			//
			var result:Boolean = true;
			
			// 遍历每个 key/value 到 obj 中
			if(key.length != value.length){
				throw new Error("未知错误");
				return false;
			}
			
			//
			var num:uint = key.length;
			for(var i:uint=0; i<num; i++)
			{
				var k:String = key[i];
				var v:Object = value[i];
				
				//
				if(obj.hasOwnProperty( k ) )
				{
					// 解码
					if(decode && v is String){
						v = decodeURIComponent(String(v));
					}
					
					// 赋值
					obj[k] = v;
				}
				else if(checkPM)
				{
					trace(XmlTool, "字段", k, "无法在对象中找到对应的属性");
					result = false;
				}
			}
			
			// 检测 obj 中的每个属性是否都被设置了
			if(checkPM)
			{
				var desc:XML = describeType( obj );
				for each(var node:XML in desc["variable"])
				{
					k = node.@name;
					if(key.indexOf( k ) < 0)
					{
						trace(XmlTool, "对象属性", k, "无法在已知表中找到对应的字段");
						result = false;
					}
				}
			}
			
			//
			return result;
		}
		
		/**
		 * 把xml的属性转成节点
		 * @param dataXML
		 */
		public static function changeXMLAttrToChild(dataXML:Object):String
		{
			for each (var o:Object in dataXML) 
			{
				for each (var o2:Object in o.attributes()) 
				{
					var str:String = "<" + o2.localName() + ">" + o2 + "</" + o2.localName() + ">";
					(o).appendChild(XML(str));
					var aa:Object = (o).attribute(o2.localName());
					delete (o).@[o2.localName()];
				}
			}
//			System.setClipboard(String(dataXML));
			return dataXML.toString();
		}
	}
}
