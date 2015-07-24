package sparrowGui;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import haxe.Timer;

/**
 * 通用处理方法
 * @author Pelephone
 */
class SparrowUtil
{

	/**
	 * 清除容器里面的所有显示对象
	 * @param s
	 */		
	static public function clearDisp(s:DisplayObjectContainer):Void
	{
		while (s != null && s.numChildren > 0)
		s.removeChildAt(0);
	}
	
	
	/**
	 * 在数组中搜索元素的位置, 存在此值返回位置，不存在则返回-1
	 * @param	list 被搜索的数组
	 * @param	value 要搜的元素
	 * @return
	 */ 
	static public function indexOf(list:Array<Dynamic>, value:Dynamic):Int
	{
		if (list == null || list.length <= 0)
		return -1;
		
		for (i in 0...list.length)
		{
			if (list[i] == value)
			return i;
		}
		return -1;
	}
	
	/**
	 * 下帧执行的方法,用个数组来存是为了不让同一下帧方法执行两次或多次
	 */
	static var nextFuncLs:Array<Void->Void> = new Array<Void->Void>();
	/**
	 * 缓存当前正在处理的函数列
	 */
	static var curFuncLs:Array < Void->Void > = new Array < Void->Void > ();
	
	/**
	 * 下帧调用某方法(同一方法添加多次，下帧也只会执行一次)<br/>
	 * 此方法可以提示图形解析效率。如数据改变很多次，只会在下帧对视图进行一次解析
	 * @param backFun
	 * @param isSafeCall 是否安全添加,为真的话如果当前帧已有要添方法则不添下帧执行,可防止无限递归；<br/>
	 * 					 如果为假则忽略当帧是否有同样方法，为假时要注意小心无限递归
	 * @return 返回false表示当前帧已经执行过了此方法
	 */
	public static function addNextCall(backFun:Void->Void,isSafeCall:Bool=true):Bool
	{
		if(isSafeCall)
		{
			var tid:Int = indexOf(curFuncLs,backFun);
			// 过滤当前帧函数是为了防止无限下帧递回
			if (tid >= 0)
			{
				if (tid <= curFunIndex)
				curFunIndex = curFunIndex - 1;
				
				// 移至队尾
				curFuncLs.splice(tid,1);
				curFuncLs.push(backFun);
				return false;
			}
		}
		
		var tid:Int = indexOf(nextFuncLs, backFun);
		if (tid >= 0)
		{
			// 移至队尾
			//nextFuncLs.splice(tid,1);
			//nextFuncLs.push(backFun);
			return true;
		}
		
		if (nextFuncLs.length == 0)
		runNext();
		
		nextFuncLs.push(backFun);
		return true;
	}
	
	/**
	 * 删除下帧执行
	 */
	public static function removeNextCall(backFun:Void->Void):Void
	{
		var tid:Int = indexOf(nextFuncLs, backFun);
		if (tid >= 0)
		nextFuncLs.splice(tid, 1);
	}
	
	static var runCount:Int = 0;
	//static var shap:Sprite = new Sprite();
	static var timer:Timer;
	static function runNext()
	{
		//shap.addEventListener(Event.ENTER_FRAME, onNextTransit);
		if (timer == null)
		{
			timer = new Timer(30);
			timer.run = onNextTransit;
			runCount = 0;
		}
		//timer = Timer.measure(onNextTransit);
			//timer = Timer.delay(onNextTransit, 30);
	}
	
	/**
	 * 当前帧执行到了第N条函数
	 */
	private static var curFunIndex:Int = 0;
	
	/**
	 * 调用下帧执行的方法中转
	 */
	private static function onNextTransit():Void
	{
		curFuncLs = nextFuncLs.splice(0, nextFuncLs.length);

		//for (curFunIndex = 0; curFunIndex < curFuncLs.length; curFunIndex++) 
		for (curFunIndex in 0...curFuncLs.length)
		{
			var fun:Void->Void = curFuncLs[curFunIndex];
			fun();
		}
		
		curFuncLs.splice(0, curFuncLs.length);
		runCount = runCount + 1;
		
		if (nextFuncLs.length == 0 && timer != null)
		{
			//shap.removeEventListener(Event.ENTER_FRAME, onNextTransit);
			timer.stop();
			timer = null;
		}
		if (runCount > 1000)
		{
			trace("SparrowUtil.onNextTransit 方法可能有无限递归的bug");
		}
	}
	
	/**
	 * 按行列二维排列容器里的项,先从左到右，再从上到下排.<br/>
	 * 此方法能实现水平，垂直，流水所有这些有规律的布局
	 * 
	 * @param targetGroup 要排列布局的对象组
	 * @param perColNum 每列有x项,如果为0则一排,横排
	 * @param colWidth 每列的列宽,如果为0则按item的宽度自动排列,即列宽==项宽
	 * @param rowHeight 每列的列高度,如果为0则按item的高度自动向下排列,即行高==项高
	 */
	public static function layoutUtil(targetGroup:Array<DisplayObject>, perColNum:Int = 1, spacing:Int = 0, colWidth:Int = 0, rowHeight:Int = 0
		, startx:Float = 0, starty:Int = 0)
	{
		var tmpY:Float = 0;
		var tmpX:Float = 0;
		var i:Int = 0;
		var lineHeight:Float = 0;	//其中一行子项高度最高的项高
		var dw:Float = 0;
		var dh:Float = 0;
		
		for (dp in targetGroup) 
		{
			#if !neko
				dw = dp.width;
				dh = dp.height;
			#else
				if (dp.width != null)
				dw = dp.width;
				else
				dw = 0;
				
				if (dp.height != null)
				dh = dp.height;
				else
				dh = 0;
			#end
			
			if(i>0 && (i%perColNum)==0 && perColNum!=0)
			{
				tmpY = tmpY + spacing + (rowHeight!=0?rowHeight:lineHeight);
				tmpX = 0;
				lineHeight = dp.height;
			}
			if(colWidth>=0)
			dp.x = tmpX + startx;
			
			if (colWidth != 0)
			tmpX = tmpX + colWidth + spacing;
			else
			tmpX = tmpX + dw + spacing;
			
			if(rowHeight>=0)
				dp.y = tmpY + starty;
			if(dp.height>lineHeight)
				lineHeight = dh;
			i++;
		}
	}
	/**
	 * 画箭头 0,1,2,3 表示 上下左右
	 */
	public static function drawArrow(gpc:Graphics, arrowDirct:Int = 0, arrowColor:Int = 0x202020
		,width:Float=7,height:Float=7):Void
	{
		var padding:Int = 0;
		//var linAlpha:Number = (arrowBorder>0)?1:0;
		//graphics.lineStyle(arrowBorder,arrowBorderColor,linAlpha);
		
		if(arrowColor>=0)
		gpc.beginFill(arrowColor);
		
		//指向上
		if(arrowDirct==0)
		{
			gpc.moveTo(width/2,padding);
			gpc.lineTo(padding,(height-padding));
			gpc.lineTo((width-padding),(height-padding));
		}
		//指向下
		else if(arrowDirct==1)
		{
			gpc.moveTo(padding,padding);
			gpc.lineTo((width-padding),padding);
			gpc.lineTo(width/2,(height-padding));
		}
		//指向左
		else if(arrowDirct==2)
		{
			gpc.moveTo(padding,(height/2));
			gpc.lineTo((width-padding),padding);
			gpc.lineTo((width-padding),(height-padding));
		}
		//指向右
		else if(arrowDirct==3)
		{
			gpc.moveTo(padding,padding);
			gpc.lineTo(padding,(height-padding));
			gpc.lineTo((width-padding),height/2);
		}
		
		if(arrowColor>=0)
		gpc.endFill();
	}
}