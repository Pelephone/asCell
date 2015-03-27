package timerUtils;
	
import flash.events.Event;
import flash.Lib;

/**
 * 刷新事件 , 
 * 保证所有处理都在同一帧 , 
 * 避免异步问题 , 
 * 并可增加运行效率
 */
class StaticEnterFrame 
{
	/**
	 * 监听方法映射,主键是函数,值是函数参数组
	 */
	static var _listenerLs:Array<Void->Void> = [];
	
	/**
	 * 更新计数,每调用一次update加1
	 */
	public static var updateCount:Int = 0;
	
	//static var hsTimer:Timer;
	
	public static var gameFps:Int = 24;
	
	public static var runing:Bool = false;
	
	/**
	 * 开始执行帧动画
	 * @param	fps 每秒帧数
	 */
	public static function start(fps:Int=30):Void
	{
		if (gameFps == fps && runing)
			return;
		
		gameFps = fps;
		stop();
		
		//hsTimer = new Timer(Std.int(1000/fps));
		//hsTimer.run = update;
		runing = true;
		
		
		Lib.current.removeEventListener(Event.ENTER_FRAME,update);
		Lib.current.addEventListener(Event.ENTER_FRAME,update);
		
	}
	
	/**
	 * 停止所有帧监听
	 */
	public static function stop():Void
	{
		if (!runing)
		return;
		//if (hsTimer != null)
		//hsTimer.stop();
		runing = false;
		
		Lib.current.removeEventListener(Event.ENTER_FRAME,update);
	}
	
	/**
	 * 每帧遍历刷新一次
	 * @param e
	 */		
	private static function update(e:Event=null):Void 
	{
		for (fun in _listenerLs) 
		{
			fun();
		}
		
		#if debugMode
			if (_listenerLs.length > 999)
			trace("StaticEnterFrame.update()");
		#end
		updateCount = updateCount + 1;
	}
	
	/**
	 * 添加帧监听
	 * @param listener
	 * @param args 函数参数
	 */
	public static function addFrameListener(listener:Void->Void):Void
	{
		if(hasFrameListener(listener))
			return;
			
		_listenerLs.push(listener);
		
		start(gameFps);
	}
	
	/**
	 * 移出帧监听
	 * @param fun
	 */
	public static function removeFrameListener(listener:Void->Void):Void
	{
		if(listener == null)
		return;
		
		var tid:Int = indexOf(_listenerLs, listener);
		if (tid >= 0)
		_listenerLs.splice(tid, 1);
				
		//_listenerLs.remove(listener);
		
		if(_listenerLs.length == 0)
		stop();
	}
	
	/**
	 * 判断是否有帧监听
	 * @param fun
	 * @return 
	 */
	public static function hasFrameListener(listener:Void->Void):Bool
	{
		if (listener == null)
		return false;

		return indexOf(_listenerLs,listener)>=0;
	}
	
	
	
	/**
	 * 在数组中搜索元素的位置, 存在此值返回位置，不存在则返回-1
	 * @param	list 被搜索的数组
	 * @param	value 要搜的元素
	 * @return
	 */ 
	static public function indexOf(list:Array<Void->Void>, value:Void->Void):Int
	{
		if (!checkArr(list))
		return -1;
		
		for (i in 0...list.length)
		{
			if (Reflect.compareMethods(list[i], value))
			return i;
			//if (list[i] && list[i] == value)
			//return i;
		}
		return -1;
	}
	
	//----------------------------------
	// 延迟一帧播放
	//----------------------------------
	
	/**
	 * 检验数组是否有数据
	 * @param	arr
	 * @return
	 */
	static public function checkArr(arr:Array<Void->Void>):Bool
	{
		return (arr != null && arr.length > 0);
	}
	
	/**
	 * 下帧执行的方法,用个数组来存是为了不让同一下帧方法执行两次或多次
	 */
	static var nextFuncLs:Array<Void->Void> = new Array<Void->Void>();
	/**
	 * 缓存当前正在处理的函数列
	 */
	static var curFuncLs:Array<Void->Void> = new Array<Void->Void>();
	
	/**
	 * 下帧调用某方法(同一方法添加多次，下帧也只会执行一次)<br/>
	 * 此方法可以提示图形解析效率。如数据改变很多次，只会在下帧对视图进行一次解析
	 * @param backFun
	 * @param isSafeCall 是否安全添加,为真的话如果当前帧已有要添方法则不添下帧执行,可防止无限递归；<br/>
	 * 					 如果为假则忽略当帧是否有同样方法，为假时要注意小心无限递归
	 */
	public static function addNextCall(backFun:Void->Void,isSafeCall:Bool=true):Void
	{
		var tid:Int = indexOf(curFuncLs,backFun);
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
		
		if(indexOf(nextFuncLs,backFun)>=0)
			return;
		
		if (nextFuncLs.length == 0)
		addFrameListener(onNextTransit);
		
		nextFuncLs.push(backFun);
	}
	
	/**
	 * 是否存在下帧执行的方法
	 * @param backFun
	 * @return 
	 */
	public static function hasNextCall(backFun:Void->Void):Bool
	{
		return indexOf(nextFuncLs,backFun)>=0;
	}
	
	/**
	 * 移出下帧执行函数
	 */
	public static function removeNextCall(backFun:Void->Void):Void
	{
		var tid:Int = indexOf(nextFuncLs,backFun);
		if(tid<0)
			return;
		
		nextFuncLs.splice(tid,1);
		
		if(nextFuncLs.length == 0)
			removeFrameListener(backFun);
	}
	
	/**
	 * 当前帧执行到了第N条函数
	 */
	private static var curFunIndex:Int;
	
	/**
	 * 调用下帧执行的方法中转
	 */
	private static function onNextTransit():Void
	{
		curFuncLs = nextFuncLs.splice(0,nextFuncLs.length);
		
		for (curFunIndex in 0...curFuncLs.length) 
		{
			curFuncLs[curFunIndex]();
		}
		
		curFuncLs = [];
		
		if (nextFuncLs.length == 0)
		removeFrameListener(onNextTransit);
	}
	
	//----------------------------------
	// 延迟执行方法
	//----------------------------------
	
	/**
	 * 延迟固定时间执行某方向
	 */
	public static function delayCall(call:Void->Void,delay:Float):Void
	{
		
	}
	
	
	/**
	 * 销毁移除此对象
	 */
	public static function dipose():Void
	{
		_listenerLs = null;
		//if(hsTimer != null)
		//{
			//hsTimer.stop();
			//hsTimer = null;
		//}
		stop();
	}
}