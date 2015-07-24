package utils.tools;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.errors.Error;
import flash.geom.Point;
import flash.text.TextField;

/**
 * 控制容器相关的工具函数
 * @author Pelephone
 */	
class DisplayTool
{
	/**
	 * 返回指定类型的孩子
	 * @param node		被寻找的父节点
	 * @param tClass	子类孩子的过滤, 如果为 null, 则返回第一个孩子
	 */
	static public function findChild(node:DisplayObjectContainer, tClass:Class<DisplayObject> = null):DisplayObject
	{
		if (tClass == null)
		tClass = DisplayObject;
		
		//for (var i:int = 0; i < node.numChildren; i++) {
		for (i in 0...node.numChildren) {
			var disp:DisplayObject = node.getChildAt(i);
			if (Std.is (disp, tClass))
			{
				return disp;
			}
			//if(disp is tClass) return disp;
		}
		return null;
	}
	
	/**
	 * 安全移除某显示对象
	 * @param disp
	 * @return 
	 */		
	public static function SafeRemoveChild(disp:DisplayObject) : DisplayObject
	{
		if (disp != null && disp.parent != null)
		disp.parent.removeChild(disp);
		return disp;
	}
	
	/**
	 * 通过名字移除子项
	 */
	public static function removeByName(dspc:DisplayObjectContainer,childName:String):Void
	{
		if (dspc == null)
		return;
		var dsp:DisplayObject = dspc.getChildByName(childName);
		if (dsp == null)
		return;
		dspc.removeChild(dsp);
	}
	
	/**
	 * 使disp里面的所有子对象按一定规则排序
	 * @param disp		要排序的容器
	 * @param swapArg	跟椐这些参数排序(一定要是disp子对象里面有的属性),如 y
	 * @param parameters	排序方式,升幂,降幂..等 如:Array.NUMERIC
	 
	public static function swapDepthChild(disp:DisplayObjectContainer,swapArg:Array<String>,options=0)
	{
		var arr:Array<DisplayObject> = childToArr(disp);
		arr.sortOn(swapArg, options);
		for (i in 0...arr.length)
			disp.setChildIndex(cast arr[i], i);
	}*/
	
	// 判断是否子窗口, 返回 0=相等, >0=是父子关系, -1=非父子关系
	static public function isChild(parent:DisplayObjectContainer, child:DisplayObject):Int
	{
		if (child == null || parent == null)
		return -1;
		var deep:Int = 0;
		while(child != parent){
			child = child.parent;
			if (child == null)
			return -1;
			deep ++;
		}
		return deep;
	}
	
	// 搜索指定类型的父窗口, deep=包含自己(=0)开始的向上搜索的层数
	static public function findParent(child:DisplayObject, pType:Class<DisplayObject>, deep:Int = -1):DisplayObject
	{
		if (Std.is(child , pType))
		return child;
		if(deep < 0) deep = 2147483647;
		if (deep-->0 && child.parent != null)
		return findParent(child.parent, pType, deep);
		return null;
	}
	
	//搜索容器里文本內容有search字符的文本
	static public function searchTextField(parent:DisplayObjectContainer, search:String):TextField
	{
		var count:Int = 0;
		if (parent != null)
		{
			//for(var i:int=0; i<parent.numChildren; i++){
			for(i in 0...parent.numChildren){
				var tf:TextField = cast parent.getChildAt(i);
				if (tf != null && tf.text.indexOf( search ) >= 0)
				return tf;
			}
		}
		return null;
	}
	
	/**
	 * 清除容器里面的所有显示对象
	 * @param s
	 */
	static public function clearDisp(s:DisplayObjectContainer):Void
	{
		while (s.numChildren > 0)
			s.removeChildAt(0);
	}
	
	/**
	 * 对齐2个控件的位置
	 * @param ref		参考位置
	 * @param disp		改变的位置
	 * @param align		对齐方式 "T" 顶对齐,"B" 底对齐,"L" 左对齐,"R" 右对齐,"C" 水平居中对齐,"M"垂直居中
	 * 					"S" 拉伸，使disp的长宽和ref相同
	 */
	static public function alignRect(ref:DisplayObject, disp:DisplayObject,align:String="T"):Void
	{
		//左对齐
		if(align.indexOf("T")>=0){
			if(disp.parent == ref) disp.y = 0;
			else disp.y = ref.y;
		}
		//底对齐
		if(align.indexOf("B")>=0){
			if(disp.parent == ref) disp.y = ref.height - disp.height;
			else disp.y = ref.y + ref.height - disp.height;
		}
		//左对齐
		if(align.indexOf("L")>=0){
			if(disp.parent == ref) disp.x = 0;
			else disp.x = ref.x;
		}
		//右对齐
		if(align.indexOf("R")>=0){
			if(disp.parent == ref) disp.x = ref.width - disp.width;
			else disp.x = ref.x + ref.width - disp.width;
		}
		//水平居中
		if(align.indexOf("C")>=0){
			if(disp.parent == ref) disp.x = ref.width/2 - disp.width/2;
			else disp.x = ref.x + ref.width/2 - disp.width/2;
		}
		//垂直居中
		if(align.indexOf("M")>=0){
			if(disp.parent == ref) disp.y = ref.height/2 - disp.height/2;
			else disp.y = ref.y + ref.height/2 - disp.height/2;
		}
		//拉伸，使disp的宽和ref相同
		if(align.indexOf("W")>=0){
			disp.width = ref.width;
		}
		//拉伸，使disp的长和ref相同
		if(align.indexOf("H")>=0){
			disp.height = ref.height;
		}
	}
	
	/**
	 * 替换 newObj 成为 existObj, 并按它的位置对齐, 然后把 existObj 变为 newObj 的孩子, 并使名字相同
	 */
	static public function replaceDP(newObj:DisplayObjectContainer, existObj:DisplayObject)
	{
		
		existObj.parent.addChild(newObj);
		existObj.parent.swapChildren(newObj, existObj);
		
		var x:Int = Std.int(existObj.x);
		var y:Int = Std.int(existObj.y);
		var w:Int = Std.int(existObj.width);
		var h:Int = Std.int(existObj.height);
		
		newObj.addChild(existObj);
		existObj.x = 0;
		existObj.y = 0;
		
		newObj.x = x;
		newObj.y = y;
		newObj.width = w;
		newObj.height = h;
		newObj.name = existObj.name;
	}
	
	/**
	 * 设置所有孩子的属性值
	 * @param parent		父窗口
	 * @param propName		属性名
	 * @param propValue		属性值
	 * @param childType		孩子类型, 用来过滤, 默认为 null 表示 不过滤
	 * @param exclude		要排除的孩子列表
	 */
	static public function setChildrenProperty(parent:DisplayObjectContainer, propName:String, propValue,
	childType:Class<DisplayObject> = null)
	{
		
		// 孩子类型
		if(childType == null) childType = DisplayObject;
		
		// 遍历每个孩子
		var num:Int = parent.numChildren;
		//for(var index:int=0; index<num; index++){
		for (index in 0...num)
		{
			// 类型过滤
			var child:DisplayObject = parent.getChildAt(index);
			if(! Std.is(child , childType) ) continue;
			
			// 排除列表
			//if(exclude.indexOf(child) >= 0) continue;
			
			// 设置孩子的属性
			Reflect.setField(child, propName, propValue);
			//child[propName] = propValue;
		}
	}
	
	/**
	 * 返回最大的孩子
	 */
	static public function maxChild(backmc:DisplayObjectContainer):DisplayObject
	{
		var maxChild:DisplayObject = findChild(backmc, InteractiveObject);
		if (maxChild.width == backmc.width && maxChild.height == backmc.height)
		return maxChild;
		return backmc;
	}
	
	/**
	 * 得到本地鼠标坐标
	 */
	static public function getLocalMousePoint(disp:DisplayObject):Point{
		trace("getLocalMousePoint for test");
		var x:Int = 0;
		var y:Int = 0;
		if (disp != null && disp.stage != null)
		{
			x = Std.int(disp.stage.mouseX);
			y = Std.int(disp.stage.mouseY);
		}
		return disp.globalToLocal( new Point(x, y) );
	}
	
	/**
	 * 获取A对象相对B中的坐标(如果把A.addChild到B，而且显示位置完全不变，则用此方向进行转换)
	 * @return 
	 */
	public static function getTarLocalPoint(tarDsp:DisplayObject,tarParent:DisplayObject):Point
	{
		var gpt:Point = tarDsp.localToGlobal(new Point(0,0));
		return tarParent.globalToLocal(gpt);
	}
	
	/**
	 * 复制对象属性
	 */
	static public function copyProperties(dst:Dynamic, src:Dynamic, propNameList:String = 'x,y,width,height')
	{
		if (dst==null || !src || propNameList == null || propNameList.length == 0)
		return;
		var arr:Array<String> = propNameList.split( "," );
		for (prop in arr)
		{
			var value = Reflect.field(src, prop);
			Reflect.setField(dst, prop, value);
			//dst[prop] = src[prop];
		}
	}
	
	/**
	 * 将场景某容器里面的所有对象放入新的父级容器
	 * @param tarDisp	被提取子对象的容器
	 * @param newDisp	待放入的新容器
	 * @param isReplace 是否替换场景容器为新显示对象
	 */		
	public static function ChildToNewParent(tarDisp:DisplayObjectContainer,
											newDisp:DisplayObjectContainer,isReplace:Bool=false):DisplayObject
	{
		while (tarDisp.numChildren > 0)
		newDisp.addChild(tarDisp.getChildAt(0));
		if(isReplace) addChildToZW(newDisp,tarDisp,"x,y,name");
		return newDisp;
	}
	
	/**
	 * 将显器里面的所有子项转为数组返回
	 * @param disp
	 * @return 
	 */
	public static function childToArr(disp:DisplayObjectContainer):Array<DisplayObject>
	{
		var arr:Array<DisplayObject> = new Array<DisplayObject>();
		for (i in 0...disp.numChildren) 
		{
			arr.push(disp.getChildAt(i));
		}
		return arr;
	}
	
	/**
	 * 设置按钮中的文字
	 * @param btn		目标按钮
	 * @param text		新的文字, 当为 null 时, 不设置新文本(仅返回原先的文本)
	 * @param isHtml	是否是html文本
	 * @return			返回新的文本内容
	 */
	static public function setSimpleButtonText(btn:DisplayObject, text:String = null, isHtml:Bool = false):String
	{
		//
		var prevText:String = "";
		if(text == null)
		{
			return text;
		}
		
		//
		var list:Array<DisplayObject> = [ Reflect.field(btn,"upState"), Reflect.field(btn,"downState")
		, Reflect.field(btn,"overState"), Reflect.field(btn,"hitTestState"), btn ];
		for (disp in list)
		{
			var tf:TextField = cast disp;
			if(tf == null){
				var cont:DisplayObjectContainer = cast disp;
				if (cont != null)
				tf = cast findChild(cont, TextField);
			}
			if(tf != null){
				if(isHtml){
					tf.htmlText = text;
				}else{
					tf.text = text;
				}
				prevText = tf.text;
			} 
		}
		
		//
		if (text != null && text.length > 0)
		return text;
		else
		return prevText;
	}
	
	/**
	 * 复制出一个新的显示对象
	 * @param src
	 * @return 
	 	
	static public function copy_instance(src:DisplayObject):DisplayObject{
		if(src == null) return null;
		var disp:DisplayObject = (new (src).constructor );
		if(disp is MovieClip){
			(disp as MovieClip).gotoAndStop( (src as MovieClip).currentFrame );
		}
		return disp;
	}*/	
	
	/**
	 * 将新显示容器附上占位的属性后删除占位
	 * @param tarDisp		新显示容器
	 * @param zwDisp		点位容器
	 * @param properties	属性字符，默认是x,y,宽,高
	 */		
	static public function addChildToZW(tarDisp:DisplayObject,zwDisp:DisplayObject,copyProps:String="x,y,width,height")
	{
		copyProperties(tarDisp,zwDisp,copyProps);
		if (tarDisp.scaleX == 0 || tarDisp.scaleY == 0)
		{
			throw new Error("复制属性错误, 该窗口将无法被显示");	// 可能尺寸为0
		}
		
		zwDisp.parent.addChild(tarDisp);
		zwDisp.parent.swapChildren(zwDisp, tarDisp);
		SafeRemoveChild(zwDisp);
	}
	
	/**
	 * 删除指定类型的孩子
	 */
	static public function removeChildrenByType(node:DisplayObjectContainer, tClass:Class<DisplayObject> = null)
	{
		
		if(tClass == null) tClass = DisplayObject;
		var i:Int = 0;
		while(i < node.numChildren)
		{
			var disp:DisplayObject = node.getChildAt(i);
			if (Std.is(disp, tClass))
			node.removeChildAt(i);
			else i++;
		}
	}
	
	/**
	 * 返回指定类型的孩子
	 * @param node		被寻找的父节点
	 * @param tClass	子类孩子的过滤, 如果为 null, 则返回所有孩子
	 * @return			返回孩子列表, 失败为 null
	 */
	static public function findChildren(node:DisplayObjectContainer, tClass:Class<DisplayObject> = null):Array<DisplayObject>
	{
		var arr:Array<DisplayObject> = new Array<DisplayObject>();
		if(tClass == null) tClass = DisplayObject;
		for(i in 0...node.numChildren){
			var disp:DisplayObject = node.getChildAt(i);
			if (Std.is(disp , tClass))
			arr.push(disp);
		}
		return (arr.length>0)? arr: null;
	}
	
	/**
	 * 把 target 移动到前面, 使其在父容器中的位置, 为最后一个孩子
	 */
	static public function moveFront(target:DisplayObject)
	{
		if (target == null || target.parent == null)
		return;
		target.parent.setChildIndex(target, target.parent.numChildren-1);
	}
	
	/** 
	 * 禁止某个控件的鼠标消息
	 */
	static public function disableMouseEvent(parent:DisplayObjectContainer, nameList:Array<String>):Void
	{
		for (name in nameList){
			var disp:DisplayObject = parent.getChildByName(name);
			if (Std.is(disp , InteractiveObject))
			(cast disp).mouseEnabled = false;
			if (Std.is(disp , DisplayObjectContainer))
			(cast disp).mouseChildren = false;
		}
	}
	
	/**
	 * 让显示容器闪烁
	 * @param disp 要闪的容器
	 * @param timer 闪烁时间
	 * @param backCall 闪烁完之后返回函数
	 * @param frame 每隔frame帧闪一次,尽量是2的倍数
	 
	static public function flicker(disp:DisplayObject,timer:Int=1000,backCall:Function=null,frame:Int=4):Void
	{
		var startTime:Int = getTimer();
		var currFrame:Int, tAlpha:Number = disp.alpha;
		
		disp.removeEventListener(Event.ENTER_FRAME,flash);
		disp.addEventListener(Event.ENTER_FRAME,flash);
		function flash(e:Event):Void
		{
			if(!disp || !disp.stage) return;
			currFrame = Math.round((getTimer() - startTime)*disp.stage.frameRate/1000);
			if(currFrame%frame==0) disp.alpha = tAlpha;
			else if(currFrame%frame==int(frame/2)) disp.alpha = 0.2;
			
			if((getTimer() - startTime)>timer)
			{
				disp.alpha = tAlpha;
				disp.removeEventListener(Event.ENTER_FRAME,flash);
				if(backCall!=null) backCall();
			}
		}
	}*/
	
	/**
	 * 容器disp里面的所有元素根据y轴改变深度
	 * @param disp
	 * @param otherAttr 其它用于排序的属性参数
	 */
	static public function changeDepthYInDisp(disp:DisplayObjectContainer,orderf:DisplayObject->DisplayObject->Int=null):Void
	{
		if(disp == null)
			return;
		var tempArr:Array<DisplayObject> = [];
		var tmc:DisplayObject;
		
		if (orderf == null)
		orderf = orderY;
		
		for(i in 0...disp.numChildren)
		{
			tempArr.push(disp.getChildAt(i));
		}
		tempArr.sort(orderf);
/*			tmc = disp.getChildAt(i);
			var otr:Object = tmc.hasOwnProperty(otherAttr)?tmc[otherAttr]:null;
			tempArr.push({mc:tmc,mcy:tmc.y,mcName:tmc.name,other:otr});
		}
		tempArr.sortOn(["mcy","mcName","other"], Array.NUMERIC);*/
		for (i in 0...tempArr.length)
			disp.setChildIndex(tempArr[i], i);
	}
	
	/**
	 * 显示对象跟据Y抽排序
	 * @param	a
	 * @param	b
	 * @return
	 */
	static function orderY(a:DisplayObject, b:DisplayObject):Int
	{
		if (a.y<b.y) {
			return -1;
		} else if (a.y>b.y) {
			return 1;
		} else {
			if (a.name > b.name)
				return -1;
			else
				return 1;
		}
	}
	
	/**
	 * 判断mc里面是否有标签名为frame的帧
	 * @param mc
	 * @param frame
	 * @return 
	 */
	#if flash
	static public function getFrameByLabel(mc:MovieClip,frame:String):FrameLabel
	{
		for (o in mc.currentLabels)
		{
			if(o.name==frame){
				return o;
			}
		}
		return null;
	}
	#end
	
	/**
	 * mc播放到标签名为str的帧，执行fun函数
	 * @param mc
	 * @param frame
	 * @param fun	为null时相当于删除帧上的函数
	 
	static public function addFrameScript(mc:MovieClip, frame, fun = null)
	{
		if (typeof(frame) == "number")
		{
			mc.addFrameScript(int(frame), fun);
		}
		else if(typeof(frame)=="string")
		{
			var fLabel:FrameLabel = getFrameByLabel(mc,String(frame));
			if(!fLabel) return;
			mc.addFrameScript(fLabel.frame,fun);
		}
	}*/	
	
	/**
	 * mc的labels帧数组里面包含有str字符则给把帧解析到函数fun里
	 * @param str
	 * @param fun
	 	
	public static function addScriptArr(mc:MovieClip, str:String, fun:Function = null)
	{
		for (s in mc.currentLabels)
		{
			if(s.indexOf(str)>=0)
				DisplayTool.addFrameScript(mc,s,fun);
		}
	}*/	
	
	/**
	 * 按行列二维排列容器里的项,先从左到右，再从上到下排
	 * (colWidth设为负数可以从右向左排,rowHeight为负数则从下向上排)
	 * @param disp
	 * @param perColNum		每列有x项,如果为0则一排,横排
	 * @param spacing		每个项之间的间隔
	 * @param colWidth		每列的列宽,如果为0则按item的宽度自动排列,即列宽==项宽
	 * @param rowHeight		每列的列高度,如果为0则按item的高度自动向下排列,即行高==项高
	 */
	public static function sortContainer(disp:DisplayObjectContainer,perColNum:Int=1, spacing:Int = 0,colWidth:Int=0
											,rowHeight:Int = 0)
	{
		if(perColNum<1) perColNum = 1;
		var tmpY:Int=0,tmpX:Int=0;
		var lineHeight:Int = 0;	//其中一行子项高度最高的项高
		for(i in 0...disp.numChildren)
		{
			var dp:DisplayObject = disp.getChildAt(i);
			if (i > 0 && (i % perColNum) == 0 && perColNum != 0)
			{
				tmpY = tmpY + spacing + (rowHeight>0?rowHeight:lineHeight);
				tmpX = 0;
				lineHeight = Std.int(dp.height);
			}
			dp.x = tmpX;
			tmpX = Std.int(tmpX + (colWidth > 0?colWidth:dp.width) + spacing);
			dp.y = tmpY;
			if(dp.height>lineHeight)
				lineHeight = Std.int(dp.height);
		}
	}
	
	/**
	 * 根据比率排列容器里的显示对象
	 * @param disp	要排列的对象
	 * @param width	排列后的总宽度
	 * @param odds	比率所有子项值加起来=1
	 */
	public static function sortDisplayByOdds(disp:DisplayObjectContainer, width:Int, odds:Array<Float>, isWidth:Bool = false)
	{
		var tmpx:Int=0;
		for (i in 0...disp.numChildren)
		{
			var dp:DisplayObject = disp.getChildAt(i);
			if(isWidth) dp.width = Math.round(odds[i]*width);
			dp.x = tmpx;
			tmpx += Math.round(odds[i]*width);
		}
	}
	
	/**
	 * 按行列二维排列容器里的项,先从左到右，再从上到下排
	 * (colWidth设为负数可以从右向左排,rowHeight为负数则从下向上排)
	 * @param disp
	 * @param perColNum		每列有x项,如果为0则一排,横排
	 * @param spacing		每个项之间的间隔
	 * @param colWidth		每列的列宽,如果为0则按item的宽度自动排列,即列宽==项宽
	 * @param rowHeight		每列的列高度,如果为0则按item的高度自动向下排列,即行高==项高
	 */
	public static function sortDisplays(dispLs:Array<DisplayObject>, perColNum:Int = 1, spacing:Int = 0, colWidth:Int = 0, rowHeight:Int = 0)
	{
		var tmpY:Float = 0;
		var tmpX:Float = 0;
		var i:Int = 0;
		var lineHeight:Float = 0;	//其中一行子项高度最高的项高
		var dw:Float = 0;
		var dh:Float = 0;
		
		for (dp in dispLs) 
		{
			#if neko
				if (dp.width != null)
				dw = dp.width;
				else
				dw = 0;
				
				if (dp.height != null)
				dh = dp.height;
				else
				dh = 0;
			#else
			dw = dp.width;
			dh = dp.height;
			#end
			
			if(i>0 && (i%perColNum)==0 && perColNum!=0)
			{
				tmpY = tmpY + spacing + (rowHeight!=0?rowHeight:lineHeight);
				tmpX = 0;
				lineHeight = dp.height;
			}
			if(colWidth>=0)
			dp.x = tmpX;
			
			if (colWidth != 0)
			tmpX = tmpX + colWidth + spacing;
			else
			tmpX = tmpX + dw + spacing;
			
			if(rowHeight>=0)
				dp.y = tmpY;
			if(dp.height>lineHeight)
				lineHeight = dh;
			i++;
		}
	}
	
	/**
	 * 批量给容器里属性斌arr数组里的值
	 * @param arr		数组数据
	 * @param disp		要斌值的容器
	 * @param prefix	容器里面属性名前缀
	 
	static public function batParseArrTodisp(arr:Array<DisplayObject>, disp:DisplayObject, prefix:String = "txt_arr", isHtml:Bool = false)
	{
		var txt:TextField;
		for (i in 0...arr.length)
		{
			if(!disp.hasOwnProperty(prefix+i))
				continue;
			txt = disp[prefix + i];
			if(txt)
			{
				if(!isHtml) txt.text = String(arr[i]);
				else txt.htmlText = String(arr[i]);
			}
			else if(Std.is(disp[prefix+i] , MovieClip))
			{
				(cast disp[prefix+i]).gotoAndStop(int(arr[i]));
			}
		}
	}*/
	
	/**
	 * 通过点语法路径返回对象里的子对象。
	 * 如mc.info.txt_name表示的是disp里面名为mc里面的info里面的txt_name对象
	 * @param disp		要查找的显示容器
	 * @param pName		点语法名
	 */		
	static public function getChildByPointName(disp:DisplayObject,pName:String):DisplayObject
	{
		var sp:DisplayObject;
		if (pName.indexOf(".") < 0 && Reflect.hasField(disp, pName))
		{
			return Reflect.field(disp,pName);
		}
		else if (pName.indexOf(".") >= 0)
		{
			var arr:Array<String> = pName.split(".");
			sp = disp;
			for (i in 0...arr.length)
			{
				var ttsp:DisplayObject = Reflect.field(sp,arr[i]);
				if (ttsp == null)
				return null;
				
				sp = ttsp;
			}
			return sp;
		}
		return null;
	}
	
	/**
	 * 从显示对象里面获取子项，如果存在就返回，不存在则创建一个加入里面后返回
	 */
	public static function getCreateDsp<T:DisplayObject>(dspc:DisplayObjectContainer,dspcls:Class<T>,dspName:String):T
	{
		var dsp:DisplayObject = dspc.getChildByName(dspName);
		if (dsp == null)
		{
			var res:T = Type.createEmptyInstance(dspcls);
			res.name = dspName;
			dspc.addChild(res);
			return res;
		}
		else
		return cast dsp;
	}
	
	/**
	 * 批量给容器里属性斌data里对应同名的值
	 * @param data		数据对象
	 * @param disp		要斌值的容器
	 
	static public function batParseObjTodisp(data:Object, disp:DisplayObject, isHtml:Bool = false)
	{
		var txt:TextField;
		var desc:XMLList = describeType( data )["variable"];
		// 设置 obj 的每个属性 prop
		for (prop in desc)
		{
			var propName:String = prop.@name;			// 变量名
			var propType:String = prop.@type;			// 变量类型
			if(!disp.hasOwnProperty(propName)) continue;
			if(disp[propName] is TextField){
				txt = (disp[propName] as TextField);
				if(!isHtml) txt.text = String(data[propName]);
				else txt.htmlText = String(data[propName]);
			}else if(disp[propName] is MovieClip){
				(disp[propName] as MovieClip).gotoAndStop(int(data[propName]));
			}
		}
	}*/
}