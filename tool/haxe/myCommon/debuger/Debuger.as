package debuger
{
	import flash.system.System;
	import flash.utils.describeType;

	/**
	 * 调试器
	 * 	
	 * 		.实现 warning/error 模式下的输出
	 * 		
	 * 		.实现 assert 断言
	 * 		
	 * 
	 * @author Pelephone
	 */
	public class Debuger {
		
		/**
		 * 是否调试模式 
		 */
		static public function get isDebug():Boolean{
			return true;
		}
		
		////////////////////////////////////////////////////////////////////////////////////
		/**
		 * 警告输出
		 */
		static public function warning(...arg):void{
			Tracer.trace2(false, arg);
		}
		
		/**
		 * 错误输出 
		 */
		static public function error(...arg):void{
			Tracer.trace2(true, arg);
		}
		
		/**
		 * 调试输出
		 */
		static public function trace(...arg):void{
			Tracer.trace2(false, arg);
		}
		
		/**
		 * 断言输出<br>
		 * 		
		 * 		.当 exp 为 false 时, 错误输出
		 * 
		 * 	@param exp			- 表达式, 为 false 时引发错误
		 * 	@param msg			- 发生错误后显示的信息
		 */
		static public function assert(exp:Boolean, msg:String=null):void{
			if(msg==null) msg = "断言失败";
			if(! exp ) error(msg);
		}
		
		/**
		 * 参数断言输出
		 */
		static public function assert_param(exp:Boolean, msg:String=null):void{
			msg = "参数错误 " + (msg || "");
			assert(exp, msg);
		}
		
		
		
		//////////////////////////////////////////////////////
		// 写代码时用的工具
		//////////////////////////////////////////////////////
		
		/** 把xml自动转成变量，并输出，方便复制粘贴
		 * @param xml 为单一项，即length()为1
		 */
		static public function traceVOByXML(xml:XML):void
		{
			if(!xml || !xml.length()) return;
			var vars:String,o:Object;
			
			for each(o in xml.attributes()){
				vars = String(o.name().localName);
				varTrace(vars,String(o));
			}
			for each(o in xml.children()){
				vars = String(o.name().localName);
				varTrace(vars,String(o));
			}
			
			function varTrace(varName:String,str:String):void
			{
				if(!str) return;
				if(isInteger(str)) trace("public var "+varName+":int;");
				else if(isDouble(str)) trace("public var "+varName+":Number;");
				else trace("public var "+varName+":String;");
			}
		}
		
		
		/** 根据VO的属性输出xml格式信息，便于粘贴
		 * @param voObj 为一有属性的对象，像此对象生成xml
		 * @param way 0为以属性的方式输出，1为以节点的方式输出
		 * @param isNoArr 是否过滤数组
		 */
		static public function traceXMLByVO(voObj:Object,way:int=0,isNoArr:Boolean=false):void
		{
			var aa:* = describeType( voObj );
			var desc:XMLList = aa["variable"];
			var ss:String = aa.@name;
			var tid:int = ss.indexOf("::");
			if(tid>=0)
			{
				ss = ss.slice(tid+2);
			}
			var str:String = "<Array>\n";
			str += way?'<'+ss+'>\n':('<' + ss + " ");
			for each(var prop:XML in desc){
				if(isNoArr && (prop.@type=="Array")) continue;
				if(way) str += "<"+prop.@name+">"+voObj[prop.@name]+"</"+prop.@name+">\n";
				else str += ""+prop.@name+"='"+voObj[prop.@name]+"' ";
			}
			str += way?'</' + ss + '>':"/>";
			str += "\n</Array>"
			trace(str);
			System.setClipboard(str);
		}
		
		/**
		 * 创建解析xml字符
		 * @param voObj vo对象
		 * @return 
		 */
		public static function traceParseXML(voObj:Object, xmlName:String="data.children()", voItemStr:String="vo."
											 ,xmlItemStr:String="xmlItem.@"):String
		{
			var desctype:* = describeType( voObj );
			var desc:XMLList = desctype["variable"];
			var desc2:XMLList = desctype["accessor"];
			var tid:int = String(desctype.@name).indexOf("::");
			var voClsName:String = (tid>=0)?String(desctype.@name).substring(tid+2):String(desctype.@name);
			var vaStr:String = "";
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				
				vaStr += voItemStr + propName + " = " + xmlItemStr + propName + ";\n";
			}
			// 设置 obj 的每个属性 prop
			for each(prop in desc2)
			{
				propName = prop.@name;			// 变量名
				var propAccess:String = prop.@access		// 是否可读可写
				
				if(propAccess.indexOf("write")<0) continue;
				
				vaStr += voItemStr + propName + " = " + xmlItemStr + propName + ";\n";
			}
			var lg:String = "var res:Array = [];\nfor each (var $xItm:Object in $xName) \n{\n" +
				"\tvar vo:$ClsName = new $ClsName();\n\t$varStr\n" +
				"\tres.push(vo)\n}";
			var ts:String = xmlItemStr.split(".")[0];
			lg = lg.replace("$xItm",ts);
			lg = lg.replace("$xItm",ts);
			lg = lg.replace("$ClsName",voClsName);
			lg = lg.replace("$ClsName",voClsName);
			lg = lg.replace("$varStr",vaStr);
			lg = lg.replace("$xName",xmlName);
			trace(lg);
			System.setClipboard(lg);
			return lg;
		}
		
		//是否为Double型数据;
		public static function isDouble(char:String):Boolean
		{
			char=trim(char);
			var pattern:RegExp=/^[-\+]?\d+(\.\d+)?$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		//去左右空格;
		public static function trim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			return rtrim(ltrim(char));
		}
		
		//去左空格; 
		public static function ltrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp=/^\s*/;
			return char.replace(pattern, "");
		}
		
		//去右空格;
		public static function rtrim(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp=/\s*$/;
			return char.replace(pattern, "");
		}
		
		//Integer;
		public static function isInteger(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			char=trim(char);
			var pattern:RegExp=/^[-\+]?\d+$/;
			var result:Object=pattern.exec(char);
			if (result == null)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * 将对象属性转成赋值方法
		 */
		public static function changeAttrToArg(obj:Object,varName:String="itm",tarName:String=null):void
		{
			var desctype:* = describeType( obj );
			var desc:XMLList = desctype["variable"];
			var desc2:XMLList = desctype["accessor"];
			var argStr:String = "";
			var vaStr:String = "";
			var arrStr:String = "";
			
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				argStr += propName + ":" + propType + ",";
				vaStr += varName + "." + propName + " = " + String(tarName) + propName + ";\n";
				arrStr += "\"" + propName + "\",";
			}
			// 设置 obj 的每个属性 prop
			for each(prop in desc2)
			{
				propName = prop.@name;			// 变量名
				propType = prop.@type;			// 变量类型
//				var declareBy:String = prop.@declaredBy;
//				if(!(declareBy == "asSkinStyle.draw::ShapeDraw" || declareBy == "asSkinStyle.draw::RectDraw"))
//					continue;
				
				argStr += propName + ":" + propType + ",";
				vaStr += varName + "." + propName + " = " + String(tarName) + propName + ";\n";
			}
			
			trace(argStr);
			trace(vaStr);
			trace(arrStr);
		}
		
		/**
		 * 将语言包对应界面的对象分出来,方便它人帮忙
		 * 以下是格式
		 * <data>
				<mcLang>
					<!--map_create是fla里面的导出名,对应的是皮肤,mcId是皮肤里的id,txt是改变mcId皮肤的文字,vars是给这条语言包命一个变量名-->
					<map_create>
					 	<lang mcId='btn_battlemode4' txt='两字' vars='FIGHT_BATTLE_MODE' />
					 	<lang mcId='btn_battlemode2' txt='两字' vars='FIGHT_BATTLE_MODE2' />
					</map_create>
				</mcLang>
			
				<tipLang>
					<!--这个是提示的文字等变量名,txt是字符,vars是变量名-->
					<lang txt='正在加载进程 {0}' vars='LOAD_PROCESS' />
				</tipLang>
			</data>
		 */
		// 通过特定格式 (data.mcLang里的格式)生成给皮肤里元素命名
/*		public static function traceMC2Key(xml:XMLList):void
		{
			var vars:String,mcId:String,txt:String,o:Object,disp:DisplayObject,sp:DisplayObject;
			disp = new (StaticUI.cls(xml.name().localName) as Class)();
			for each(o in xml.children()){
				mcId = String(o.@mcId);
				txt = String(o.@txt);
				vars = String(o.@vars);
				if(mcId.indexOf(".")<0 && disp.hasOwnProperty(mcId)){
					sp = disp[mcId] as DisplayObject;
					if(!sp) throw new Error("找不到指定容器里的对象 '"+mcId+"' !");
					if(sp is TextField){
						trace("(skin['"+mcId+"'] as TextField).text = String(Lang." + vars + ";");
					}else if((sp is SimpleButton) || (sp.hasOwnProperty("upState"))){
						trace("DispTool.setSimpleButtonText((skin['"+mcId+"'] as DisplayObject),Lang."+vars+");");
					}
				}else if(mcId.indexOf(".")>=0){
					var arr:Array = mcId.split("."),dispStr:String='skin';
					sp = disp;
					for(var i:int=0;i<arr.length;i++){
						var ttsp:DisplayObject = sp[arr[i]];
						if(!sp) throw new Error("找不到指定容器里的对象 '"+arr[i]+"' !");
						sp = ttsp;
						dispStr += "['"+arr[i]+"']";
					}
					if(sp is TextField)
						trace("(skin['"+mcId+"'] as TextField).text = String(Lang." + vars + ";");
					else if((sp is SimpleButton) || (sp.hasOwnProperty("upState")))
						trace("DispTool.setSimpleButtonText(("+dispStr+" as DisplayObject),Lang."+vars+");");
				}
			}
		}*/
		
		// 通过特定格式 (data.tip里的格式)生成语言包变量和对应字符串
		public static function traceLangKey(xml:Object):void
		{
			var vars:String,mcId:String,txt:String,o:Object;
			for each(o in xml){
				txt = String(o.@txt);
				vars = String(o.@vars).toUpperCase();
				trace('public function var ' + vars + ':String = "' + txt + '";');
			}
		}
		
		// 将翻译给过来的skinXML转成程序需要的xml,再将此xml文本粘贴入resLang.xml.
		// *翻译的xml体积大,而且解析效率会慢,所以得转一转. 不过翻译的xml可用excel打开,易读.
		public static function testSkinXML2canXML(testXML:XMLList):XML
		{
			var nXML:XML = XML(<data></data>);
			for each(var o:Object in testXML){
				var cname:String = o.@linkage.toString();
				if(nXML.child(cname).toString()==''){
					nXML.appendChild(<{cname}>
						<lang mcId={o.@mcId} txt={o.@txt} />
					</{cname}>);
				}else{
					nXML.child(cname).appendChild(<lang mcId={o.@mcId} txt={o.@txt} />);
				}
			}
//			System.setClipboard(nXML);
			return nXML;
		}
		//	
	}
}

class Tracer{
	
		/**
		 * 调试输出
		 * 
		 * 	@param error		- 错误模式, 否则为警告模式
		 * 	@param arg			- 参数表, 被显示的多个信息列表
		 */
		static public function trace2(error:Boolean, ...arg):void{
			
			// 获得信息 msg
			var msg:String = new String();
			for each(var abc:Object in arg){
				msg += abc + " ";
			}
			
			// 错误
			if(error){
				throw new Error(msg);
			}
			// 警告
			else{
				trace(msg);
			}
		}
}