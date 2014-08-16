package TimerUtils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * 刷新事件 , 
	 * 保证所有处理都在同一帧 , 因为是使用timer，所有建议场景帧率能被1000整除
	 * 避免异步问题 , 
	 * 并可增加运行效率
	 */
	public class TimerToEnterFrame 
	{
		private static var funList:Array;
		private static var EFTimer:Timer = new Timer(1000/30);
		private static var isUpDateEvt:Boolean;
		
		// 开始
		public static function init(fps:int=30,isUpEvt:Boolean=false):void
		{
			funList = [];
			EFTimer = new Timer(1000/fps);
			EFTimer.addEventListener(TimerEvent.TIMER, update);
			isUpDateEvt = isUpEvt;
		}
		
		public static function start():void
		{
			EFTimer.start();
		}
		
		// 停止
		public static function stop():void
		{
			EFTimer.stop();
		}
		
		// 刷新
		public static function update(e:TimerEvent=null):void 
		{
			if(isUpDateEvt) e.updateAfterEvent();
			var len:int = funList==null?0:funList.length;
			for ( var i:int=0; i<len; i++){
				funList[i].func.apply(null ,funList[i].arg);
				if(len>funList.length){
					i--;
					len = funList.length;
					continue;
				}
			}
		}
		
		public static function addFunc(fun:Function,args:Array=null,fName:String=null):void
		{
			if(hasFun(fun,args,fName)){
				trace("此timer已经存在了，不能添加");
				return;
			}
			var o:Object = {func:fun,arg:args,name:fName};
			funList.push(o);
			if(!EFTimer.running) start();
		}
		
		public static function delFunc(fun:Function,args:Array=null,fName:String=null):void
		{
			if(!hasFun(fun,args,fName)) return;
			for (var i:int=0; i<funList.length; i++){
				if((fName!=null && funList[i].name==fName) || (funList[i].func==fun && compareArr(funList[i].arg,args))){
					funList.splice(i,1);
					break;
				}
			}
			if(!funList.length) stop();
		}
		
		public static function getFunc(fun:Function,args:Array=null,fName:String=null):Object
		{
			var resObj:Object;
			for (var i:int=0; i<funList.length; i++){
				if((fName!=null && funList[i].name==fName) || (funList[i].func==fun && compareArr(funList[i].arg,args))){
					resObj = funList[i];
					break;
				}
			}
			return resObj;
		}
		
		public static function hasFun(fun:Function,args:Array=null,fName:String=null):Boolean
		{
			if(funList==null) return false;
			if(funList.length && getFunc(fun,args,fName)!=null) return true;
			else return false;
		}
		
		public static function compareArr(arr1:Array,arr2:Array):Boolean
		{
			if(arr1==null || arr2==null) return false;
			if(arr1.length != arr2.length) return false;
			
			var isSame:Boolean = true;
			for(var i:int=0;i<arr1.length;i++)
				if(arr1[i]!=arr2[i]){
					isSame = false;
					break;
				}
			
			return isSame;
		}
		
		public static function destroy():void
		{
			stop();
			if(EFTimer.hasEventListener(TimerEvent.TIMER))
				EFTimer.removeEventListener(TimerEvent.TIMER, update);
			
			while(!funList.length){
				funList.shift();
				funList[0] = null;
			}
			
			EFTimer = null;
			funList = null;
		}
		
	}
	
}