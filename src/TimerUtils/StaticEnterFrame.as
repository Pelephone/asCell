package TimerUtils
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * 刷新事件 , 
	 * 保证所有处理都在同一帧 , 
	 * 避免异步问题 , 
	 * 并可增加运行效率
	 */
	public class StaticEnterFrame 
	{
		/**
		 * 监听方法映射,主键是函数,值是函数参数组
		 */
		private static var _listenerMap:Dictionary = new Dictionary();
		private static var _shape:Shape = new Shape();
		
		/**
		 * 更新计数,每调用一次update加1
		 */
		public static var updateCount:int = 0;
		
		public static function start():void
		{
			_shape.addEventListener(Event.ENTER_FRAME,update);
		}
		
		/**
		 * 停止所有帧监听
		 */
		public static function stop():void
		{
			_shape.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		/**
		 * 每帧遍历刷新一次
		 * @param e
		 */		
		public static function update(e:Event=null):void 
		{
			var key:*;
			var listener:Function;
			for (key in _listenerMap) 
			{
				listener = key;
				listener.apply(null,_listenerMap[listener]);
			}
			updateCount = updateCount + 1;
		}
		
		/**
		 * 添加帧监听
		 * @param listener
		 * @param args 函数参数
		 */
		public static function addFrameListener(listener:Function,args:Array=null):void
		{
			if(hasFrameListener(listener))
				return;
			if(!args) args = [];
			_listenerMap[listener] = args;
//			start();
		}
		
		/**
		 * 移出帧监听
		 * @param fun
		 */
		public static function removeFrameListener(listener:Function):void
		{
			if(listener == null)
				return;
			_listenerMap[listener] = null;
			delete _listenerMap[listener];
			var key:*;
			for (key in _listenerMap) 
			{
				// 能进得了这里证明监听长度不为1，则不会停止帧
				return;
			}
//			stop();
		}
		
		/**
		 * 判断是否有帧监听
		 * @param fun
		 * @return 
		 */
		public static function hasFrameListener(listener:Function):Boolean
		{
			if(_listenerMap==null) return false;
			else
				return _listenerMap[listener] != null;
		}
		
		/**
		 * 下帧执行的方法,用个数组来存是为了不让同一下帧方法执行两次或多次
		 */
		private static const nextFuncLs:Vector.<Function> = new Vector.<Function>();
		/**
		 * 缓存当前正在处理的函数列
		 */
		private static var curFuncLs:Vector.<Function> = new Vector.<Function>();
		
		/**
		 * 下帧调用某方法(同一方法添加多次，下帧也只会执行一次)<br/>
		 * 此方法可以提示图形解析效率。如数据改变很多次，只会在下帧对视图进行一次解析
		 * @param backFun
		 * @param isSafeCall 是否安全添加,为真的话如果当前帧已有要添方法则不添下帧执行,可防止无限递归；<br/>
		 * 					 如果为假则忽略当帧是否有同样方法，为假时要注意小心无限递归
		 */
		public static function addNextCall(backFun:Function,isSafeCall:Boolean=true):void
		{
			var tid:int = curFuncLs.indexOf(backFun);
			// 过滤当前帧函数是为了防止无限下帧递回
			if(tid>=0 && isSafeCall)
			{
				if(tid<=curFunIndex)
					curFunIndex = curFunIndex - 1;

				// 移至队尾
				curFuncLs.splice(tid,1);
				curFuncLs.push(backFun);
				return;
			}
			
			if(nextFuncLs.indexOf(backFun)>=0)
				return;
			
			if(!nextFuncLs.length)
				_shape.addEventListener(Event.ENTER_FRAME,onNextTransit);
			
			nextFuncLs.push(backFun);
		}
		
		/**
		 * 是否存在下帧执行的方法
		 * @param backFun
		 * @return 
		 */
		public static function hasNextCall(backFun:Function):Boolean
		{
			return nextFuncLs.indexOf(backFun)>=0;
		}
		
		/**
		 * 移出下帧执行函数
		 */
		public static function removeNextCall(backFun:Function):void
		{
			var tid:int = nextFuncLs.indexOf(backFun);
			if(tid<0)
				return;
			
			nextFuncLs.splice(tid,1);
			
			if(!nextFuncLs.length)
				removeFrameListener(backFun);
		}
		
		/**
		 * 当前帧执行到了第N条函数
		 */
		private static var curFunIndex:int;
		
		/**
		 * 调用下帧执行的方法中转
		 */
		private static function onNextTransit(e:Event):void
		{
			curFuncLs = nextFuncLs.splice(0,nextFuncLs.length);
			
			for (curFunIndex = 0; curFunIndex < curFuncLs.length; curFunIndex++) 
			{
				var fun:Function = curFuncLs[curFunIndex] as Function;
				fun.apply(null,[]);
			}
			
			curFuncLs = new <Function>[];
			
			if(nextFuncLs.length == 0)
				_shape.removeEventListener(Event.ENTER_FRAME,onNextTransit);
		}
		
		/**
		 * 销毁移除此对象
		 */
		public static function dipose():void
		{
			_shape = null;
			_listenerMap = null;
		}
	}
}