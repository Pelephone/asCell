package utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	public class CmmFun
	{
		public function CmmFun()
		{
		}
		
		/**
		 * 清理对象里的所有引用对象,一般是要删除某对象时用此方法
		 * @param obj
		 * @return 
		 */		
		public static function killObject(obj:Object):Object
		{
			for(var strName:String in obj){
				if((obj[strName] is Number) || (obj[strName] is String)) continue;
				if((obj[strName] is DisplayObject) && (obj[strName] as DisplayObject).parent){
					(obj[strName] as DisplayObject).parent.removeChild((obj[strName] as DisplayObject));
				}
				obj[strName]=null;
			}
			return obj;
		}
		
		/**
		 * 通过类类型查找父级容器 
		 * @param type 要查找的类
		 * @param startD 从startD容器开始向上级容器找
		 * @return 如果没找到则返回null,找到则返回该容器
		 */		
		static public function getParentByType(type:Class,startD:DisplayObject):*{
			if(!startD.parent) return null;
			if(startD.parent is type) return startD.parent;
			else return getParentByType(type,startD.parent);
		}
		
		/**
		 * 延迟一个时间执行函数 
		 * @param delayTime 延迟的毫秒数
		 * @param fun 执行返回函数
		 *  */		
		static public function delayCall(delayTime:int,fun:Function,args:Array=null):void
		{
			var dTimer:Timer = new Timer(delayTime,1);
			dTimer.addEventListener(TimerEvent.TIMER_COMPLETE,callBack);
			dTimer.start();
			function callBack(e:TimerEvent):void
			{
				if(!dTimer) return;
				dTimer.stop();
				dTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,callBack);
				dTimer = null;
				if(fun!=null) fun.apply(null,args);
			}
		}
		
		/**
		 * 用于判断两点是否靠得很近.即两点距离是否小于某数.
		 * @param myPoint 点1
		 * @param TarPoint 点2
		 * @param Dif 差值,用于判断是否在该范围点
		 * */
		static public function isNear(MyPoint:Point,TarPoint:Point,Dif:int=2):Boolean
		{
			if(Point.distance(MyPoint,TarPoint)<=Dif)
				return true;
			else
				return false;
		}
		
		/**
		 * 如果对象离目标点很近的话,则直接使对象的x,y坐标移动目标点
		 * @param TarMC mc对象
		 * @param TarPoint 目标点
		 * @param Dif 差值,用于判断是否在该范围点
		 * */
		static public function NearMove(TarMC:MovieClip,TarPoint:Point,Dif:int=2):void
		{
			var MyPoint:Point = new Point(TarMC.x,TarMC.y);
			if(isNear(MyPoint,TarPoint,Dif) && MyPoint!=TarPoint){
				TarMC.x = TarPoint.x;
				TarMC.y = TarPoint.y;
			}
		}
		
		/**
		 * 通过对象获取对象的类名
		 * @return 
		 */		
		static public function getClassName(value:*):String
		{
			var qname:String = getQualifiedClassName(value);
			return (qname.indexOf("::")<0)?qname:
				qname.substring((qname.lastIndexOf("::")+2),qname.length);
		}
		
		/**
		 * 对齐窗口 t 到父窗口的中间
		 * @param t
		 */		
		static public function alignCenter(t:DisplayObject):void{
			if(!t || !t.parent) return;
			
			var p:DisplayObjectContainer = t.parent;
			t.x = int( (p.width - t.width) / 2 );
			t.y = int( (p.height - t.height) / 2 ); 
		}
		
		/**
		 * 从一个键盘 keyCode(ascii) 中获取对应的字符串名, 例如: 112->"F1", 65->"A". 如果失败, 返回 null
		 * @param keyCode
		 * @return 
		 */		
		static public function getKeyCodeName(keyCode:int):String{
			
			// A->Z
			if(keyCode >= ("A").charCodeAt() && keyCode <= ("Z").charCodeAt()){
				return String.fromCharCode(keyCode); 
			}
			
			// 其它
			var desc:XML = describeType( Keyboard );
			var constant_list:XMLList = desc.constant.(@type=="uint");
			for each(var constant:XML in constant_list)
			{
				var name:String = constant.@name;
				if(Keyboard[name] == keyCode) return name;
			}
			
			// 失败
			return null;
		}
		
		/**
		 * 显示Bytes内容
		 * @param bytes
		 */		
		public static function showBytes(bytes:ByteArray):void
		{
			var s:String = "";
			bytes.position = 0;
			while (bytes.bytesAvailable)
			{
				s += "0x" + bytes.readByte().toString(16) + " ";
			}
			if (s.length > 0) s = s.substr(0, s.length - 1);
			trace("bytes:", s);
		}
		
		/**
		 * 以二进制方法复制一个对象
		 * @param obj1 要被复制的对象
		 * @return Object 返回复制出的数对象
		 */		
		public static function copyObjByByte(obj1:Object):Object
		{
			var byteArray:ByteArray=new ByteArray();
			byteArray.writeObject(obj1);
			
			byteArray.position=0;
			var obj2:Object=byteArray.readObject();
			return obj2;
		}
		
		/**
		 * 复制对象属性值
		 * @param Jobj		要解析的Object对象
		 * @param voClz		要转成的vo对象的类名
		 */
		public static function copyObjectValue(reObj:Object,vars:Object,ignoreProps:Array=null):*
		{
			var desc:XML = describeType( vars );
			// 设置 obj 的每个属性 prop
			for each(var prop:XML in desc.variable)
			{
				var propName:String = prop.@name;			// 变量名
				var propType:String = prop.@type;			// 变量类型
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				if(!reObj.hasOwnProperty(propName)) continue;
				
				reObj[propName] = vars[propName];
			}
			// 设置 obj 的每个属性 set/get
			for each(prop in desc.accessor)
			{
				propName = prop.@name;			// 变量名
				propType = prop.@type;			// 变量类型
				var access:String = prop.@access;
				
				// 忽略了
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				if(!reObj.hasOwnProperty(propName) || access=="readonly") continue;
				
				reObj[propName] = vars[propName];
			}
			// 如果是动态类就设置动态属性
			for (propName in vars)
			{
				if(ignoreProps && ignoreProps.indexOf(propName)>=0) continue;
				if(!reObj.hasOwnProperty(propName)) continue;
				reObj[propName] = vars[propName];
			}
			
			return reObj;
		}
		
		// 画虚线
		static public function graphics_drawDashed(graphics:Graphics, p1:Point, p2:Point, length:Number=5, gap:Number=5):void	{    
			var max:Number = Point.distance(p1,p2);    
			var l:Number = 0;    
			var p3:Point;    
			var p4:Point;    
			while(l<max){
				p3 = Point.interpolate(p2,p1,l/max);    
				l+=length;    
				if(l>max)l=max    
				p4 = Point.interpolate(p2,p1,l/max);    
				graphics.moveTo(p3.x,p3.y)    
				graphics.lineTo(p4.x,p4.y)    
				l+=gap;    
			}    
		}
		
		/**
		 * 测试当前运行的 swf 实例数是否 <= max 个
		 * @param max
		 * @param prefix
		 * @return 
		 */		
		static public function test_swf_instance(max:int, prefix:String=null):Boolean{
			if(! prefix ) prefix = "test_swf_instance";
			for(var i:int = 1; i<=max; i++){
				try{
					var myConn:LocalConnection = new LocalConnection();
					myConn.connect( prefix + i );
					break;
				}
				catch(e:ArgumentError){
				}
			}
			return i <= max;
		}
		
		/**
		 * 获取容器的某滤镜
		 * @param disp	容器
		 * @param cla	容器类型
		 * @return 		返回滤镜
		 */		
		static public function getDispFiters(disp:DisplayObject,cla:Class):BitmapFilter
		{
			if(disp.filters)
				for each(var f:BitmapFilter in disp.filters){
				if(f is cla) return f;
			}
			return null;
		}
		
		/**
		 * 获取容器的某滤镜的位置
		 * @param disp	容器
		 * @param cla	容器类型
		 * @return 		返回位置,没有返回-1;
		 */
		static public function dispFitersIndexOf(disp:DisplayObject,cla:Class):int
		{
			if(disp.filters)
				for(var i:int=0;i<disp.filters.length;i++){
					if(disp.filters[i] is cla) return i;
			}
			return -1;
		}
		
		/**
		 * 给显示对象画孤线，孤线从startPt开始，经过thougnPt,在endPt结果
		 * @param disp
		 * @param startPt
		 * @param endPt
		 * @param thoughPt
		 */		
		public static function drawCurve(disp:Sprite,startPt:Point,endPt:Point,thoughPt:Point):void
		{
			var x1:Number = thoughPt.x*2 - (startPt.x + endPt.x)/2;
			var y1:Number = thoughPt.y*2 - (startPt.y + endPt.y)/2;
			disp.graphics.moveTo(startPt.x, startPt.y);
			disp.graphics.curveTo(x1, y1, endPt.x, endPt.y);
		}
		
		
		private static const SHAPE:Shape = new Shape();
		private static var shakeMap:Array = [];
		/**
		 * 屏幕振动			
		 * @param disp			要震动的容器
		 * @param strength		震动强度
		 * @param shakeTime		震动时长(毫秒为单位)
		 * @param endPt			震动完之后停在某坐标点
		 */		
		public static function shakeScene(disp:DisplayObject,shakeTime:int=300,strength:int=10,endPt:Point=null):void
		{
			var obj:Object = getShakeVO(disp);
			if(obj){
				obj.count += 1;
			}else{
				obj = {disp:disp,x:disp.x,y:disp.y,count:1};
				shakeMap.push(obj);
			}
			if(endPt){
				obj.x = endPt.x;
				obj.y = endPt.y;
			}
			for (var i:int = 0; i < shakeTime; i++) 
			{
				
			}
			
			var startTime:Number = getTimer();
			SHAPE.addEventListener(Event.ENTER_FRAME,onEnter);
			function onEnter(e:Event):void
			{
				if((getTimer() - startTime)>shakeTime){
					obj.count -= 1;
					disp.x = obj.x;
					disp.y = obj.y;
					SHAPE.removeEventListener(Event.ENTER_FRAME,onEnter);
					if(obj.count<1){
						shakeMap.splice(shakeMap.indexOf(obj),1);
					}
					return;
				}
				disp.x = obj.x + Math.random()*strength*2 - strength;
				disp.y = obj.y + Math.random()*strength*2 - strength;
			}
		}
		
		// 多加这步是为了防止多对象震动后回不了原来的位标
		// 通过容器查找震动表里的对象
		private static function getShakeVO(disp:DisplayObject):Object
		{
			for each(var obj:Object in shakeMap) if(obj.disp==disp) return obj;
			return null;
		}
	}
}