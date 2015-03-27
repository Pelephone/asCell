package sparrowGui.components;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import pelephone.manager.StageMgr;
import sparrowGui.components.item.SItem;
import sparrowGui.components.TouchScrollPanel;

/**
 * 动态只显示可见区域子项的滚动列表对象
 * @author Pelephone
 */
class DynamicScrollVIew extends TouchScrollPanel
{
	
	var skin:Sprite;
	//var bg:RectDraw;
	var itemLsDspc:Sprite;
	// 预计算的上下边高度
	public var side:Int = 1280;
	
	public function new() 
	{
		sideRect = new Rectangle(0, 0, 768, side);
		
		skin = new Sprite();
		//addChild(skin);
		
/*		bg = new RectDraw();
		bg.bgAlpha = 0;
		bg.bgColor = 0xFFFFFF;
		skin.addChild(bg);*/
		
		itemLsDspc = new Sprite();
		itemLsDspc.name = "itemLsDspc";
		skin.addChild(itemLsDspc);
		
		stgMgr = StageMgr.getInstance();
		
		super(skin);
		
		//showType = 0;
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		this.removeEventListener(Event.ADDED_TO_STAGE, onShowIconPos);
		this.addEventListener(Event.ADDED_TO_STAGE, onShowIconPos);
	}
	
	var curSelectId:Int = 0;
	
	// 图标上次状态时的指向位置
	var lastCurId:Int = 0;
	
	// 加入舞台的时候计算一次当前图标位置
	private function onShowIconPos(e:Event):Void 
	{
		if (lastCurId == curSelectId)
		return;
		
		var tempItm:SItem = getItemByIndex(curSelectId);
/*		tempItm.update();
		tempItm = getItemByIndex(curSelectId);
		tempItm.update();*/
		
		lastCurId = curSelectId;
		
		var ept:Point = itemLsDspc.globalToLocal(new Point(0, stgMgr.getStageHeight() * 0.6));
		var dy:Float = ept.y - tempItm.y;
		scrollDsp.y = validaToY(scrollDsp.y + dy);
	}
	
	// 是否index越大的子项y轴越大
	var isEndYMoreBig:Bool = true;
	
	var dataLs:Array<Dynamic> = null;
	
	/**
	 * 设置数据列表,生成当前显示到的子项处
	 * @param	value
	 */
	public function setDate(value:Array<Dynamic>,scrollIndex:Int=0)
	{
		if(dataLs != value)
		{
			dataLs = value;
			itemLsDspc.removeChildren();
		}
		
		if(dataLs.length>0)
		{
			var itmFirst:SItem = createAItem(dataLs[0],0);
			var itmLast:SItem = createAItem(dataLs[dataLs.length - 1], (dataLs.length - 1));
			itmLast.parent.removeChild(itmFirst);
			itmLast.parent.removeChild(itmLast);
			isEndYMoreBig = (itmLast.y > itmFirst.y);
		}
		
		curSelectId = scrollIndex;
		
		topMid = scrollIndex;
		bottomMid = scrollIndex;
		freshMission(scrollIndex);
		lastCurId = scrollIndex;

		scrollToItem();
	}
	
	private function onAddToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		StageMgr.registerResizeListener(onStageResize);
		scrollToItem();
	}
	
	// 使滚动条滚动到子项位置
	function scrollToItem()
	{
		var tempItm:SItem = getItemByIndex(curSelectId);
		if (tempItm == null)
		return;
		
		calcScrollBound();
		skin.y = -tempItm.y;
	}
	
	function onStageResize()
	{
		//var stgMgr:StageMgr = StageMgr.getInstance();
		//var pt:Point = stgMgr.globalBRtoLocal(this,false);
		//width = pt.x;
		//height = pt.y;
		
		calcCreateUpItem();
		calcCreateDownItem();
	}
	
	function freshMission(freshMid:Int)
	{
		var curMVO:Dynamic = getDataByIndex(freshMid);
		
		var rect:Rectangle = calcSideRect();
		
		// 从当前关卡中向上向下找出在视野范围内的其它关卡用于显示
		var nextMvo:Dynamic = curMVO;
		var cfId:Int = freshMid;
		var tempItm:SItem = createAItem(nextMvo, cfId);
		skin.y = - tempItm.y;
		var nextStep:Int = isEndYMoreBig? -1:1;
		while (nextMvo != null && tempItm.y > rect.y)
		{
			tempItm = createAItem(nextMvo, cfId);
			cfId = cfId + nextStep;
			nextMvo = getDataByIndex(cfId);
		}
		nextMvo = curMVO;
		cfId = freshMid;
		tempItm = createAItem(nextMvo, cfId);
		nextStep = nextStep * -1;
		while (nextMvo != null && tempItm.y < rect.bottom)
		{
			tempItm = createAItem(nextMvo, cfId);
			cfId = cfId + nextStep;
			nextMvo = getDataByIndex(cfId);
		}
		
/*		tempItm = getItemByIndex(topMid);
		rect.y = tempItm.y;
		tempItm = getItemByIndex(bottomMid);
		rect.bottom = tempItm.y;*/
	}
	
	// 当前显示的最上面的关卡
	var topMid:Int = 0;
	// 当前显示的最下面的关卡
	var bottomMid:Int = 0;
	
	/**
	 * 子项类
	 */
	public var itemClass:Class<SItem> = null;
	
	// 创建关卡子项
	function createAItem(data:Dynamic, dataIndex:Int ):SItem
	{
		// 判断是否已经生成过该项,已生成过就不再生成
		if(getItemByIndex(dataIndex) == null)
		{
			var tmpItm:SItem;
			if (itemClass == null)
			tmpItm = new SItem();
			else
			tmpItm = Type.createInstance(itemClass,[]);
			
			tmpItm.name = "item_" + dataIndex;
			tmpItm.setItemIndex(dataIndex);
			tmpItm.data = data;
			itemLsDspc.addChild(tmpItm);
			if (dataIndex > topMid)
			{
				if(isEndYMoreBig)
				bottomMid = dataIndex;
				else
				topMid = dataIndex;
			}
			else if (dataIndex < bottomMid)
			{
				if(isEndYMoreBig)
				topMid = dataIndex;
				else
				bottomMid = dataIndex;
			}
			
			return tmpItm;
		}
		else
		return getItemByIndex(dataIndex);
	}
	
	// 通过索引获取对应的数据
	function getDataByIndex(idx:Int):Dynamic
	{
		if (dataLs == null || dataLs.length <= 0)
		return null;
		if (dataLs.length <= idx)
		return null;
		return dataLs[idx];
	}
	
	var stgMgr:StageMgr;
	
	// 向上遍历生成子项
	function calcCreateUpItem()
	{
		//var nextItm:SItem = cast itemLsDspc.getChildByName("item_" + topMid);
		var nextMvo:Dynamic = getDataByIndex(topMid);
		var cid:Int = topMid;
		
		var oldH:Float = skin.height;
		var reid:Int = topMid;
		var rect:Rectangle = calcSideRect();
		
		var nextNum:Int = isEndYMoreBig? -1:1;
		while (nextMvo != null)
		{
			var itm:SItem = createAItem(nextMvo,cid);
			if (itm.y < rect.y)
			break;
			cid = cid + nextNum;
			nextMvo = getDataByIndex(cid);
		}

		calcShowRect(topMid, reid, oldH, rect);
	}
	
	// 向下遍历生成子项
	function calcCreateDownItem()
	{
		var nextMvo:Dynamic = getDataByIndex(bottomMid);
		var cid:Int = bottomMid;
		
		var oldH:Float = skin.height;
		var reid:Int = bottomMid;
		var rect:Rectangle = calcSideRect();
		
		var nextNum:Int = isEndYMoreBig? 1:-1;
		while (nextMvo != null)
		{
			var itm:SItem = createAItem(nextMvo,cid);
			if (itm.y > rect.bottom)
			break;
			cid = cid + nextNum;
			nextMvo = getDataByIndex(cid);
		}
		
		calcShowRect(reid, bottomMid, oldH, rect);
	}
	
	/**
	 * 通过索引获取子项
	 * @param	index
	 * @return
	 */
	public function getItemByIndex(index:Int):SItem
	{
		return cast itemLsDspc.getChildByName("item_" + index);
	}
	
	// 通过id参数计算显示滚动参数
	function calcShowRect(id1:Int,id2:Int,oldH:Float,rect:Rectangle)
	{
/*		if (id1 != id2)
		{
			bg.width = itemLsDspc.width;
			bg.height = itemLsDspc.height;
		}*/
		
		if (skin.height > oldH)
		calcScrollBound();
	}
	
	var sideRect:Rectangle;
	// 计算当前可视范围转成bg矩形
	function calcSideRect():Rectangle
	{
		var pt:Point = new Point();
		pt.y = screenHeight + side;
		var pt2:Point = new Point();
		pt2.y = this.y - side;
		pt = this.localToGlobal(pt2);
		var tmpPt:Point = itemLsDspc.globalToLocal(pt);
		pt.y = -side;
		pt2.y = this.y + this.height + side;
		pt = this.localToGlobal(pt2);
		var tmpPt2:Point = itemLsDspc.globalToLocal(pt);
		sideRect.y = tmpPt.y;
		sideRect.bottom = tmpPt2.y;
		//sideRect.height = side * 3;
		return sideRect;
	}
	
	/**
	 * 一屏的高度
	 */
	public var screenHeight:Int = 1280;
	
	override private function onEnterFrame(e:Event=null):Void 
	{
		var curY:Float = scrollDsp.y;
		var isSame:Bool = curY == downSPt.y;
		
		super.onEnterFrame(e);
		
		if(!isSame)
		{
			var isUp:Bool = true;
			if(isEndYMoreBig)
			isUp = (curY > downSPt.y);
			else
			isUp = (curY < downSPt.y);
			
			if (isUp)
			calcCreateUpItem();
			else
			calcCreateDownItem();
		}
	}
	
	override private function onMouseWheel(e:MouseEvent):Void 
	{
		super.onMouseWheel(e);
		
		var isUp:Bool = true;
		if(isEndYMoreBig)
		isUp = (e.delta > 0);
		else
		isUp = (e.delta < 0);
		
		if (isUp)
		calcCreateDownItem();
		else
		calcCreateUpItem();
	}
}