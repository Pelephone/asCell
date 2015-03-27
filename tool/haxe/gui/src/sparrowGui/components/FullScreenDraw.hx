/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES 
*/
package sparrowGui.components;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import sparrowGui.SparrowUtil;

/**
 * 全屏遮挡,跟据场景变化而改变宽高
 * @author Pelephone
 */
class FullScreenDraw extends Sprite
{
	public function new(bgColor:Int=0x000000)
	{
		super();
		drawColor = bgColor;
		tmpt = new Point();
		skinDraw();
		
		addEventListener(Event.ADDED_TO_STAGE,onSkinInit);
		
		addEventListener(Event.ADDED_TO_STAGE,onToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onToStage);
		
		#if html5
		paddingButtom = -1200;
		#end
	}
	
	function onSkinInit(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onSkinInit);
		onStageResize(e);
	}
	
	/**
	 * 添加到舞台
	 * @param e
	 */
	private function onToStage(e:Event):Void
	{
		switch(e.type)
		{
			case Event.ADDED_TO_STAGE:
			{
				tmpStg = this.stage;
				tmpStg.removeEventListener(Event.RESIZE, onStageResize);
				tmpStg.addEventListener(Event.RESIZE, onStageResize);
				//StageMgr.registerResizeListener(onChangeRect);
				onStageResize();
			}
			case Event.REMOVED_FROM_STAGE:
			{
				tmpStg.removeEventListener(Event.RESIZE, onStageResize);
				//StageMgr.removeResizeListener(onChangeRect);
				tmpStg = null;
			}
		}
	}
	
	// neko平台REMOVED_FROM_STAGE后取不到stage,为兼容不得不用个变量存场景
	var tmpStg:DisplayObject;
	
	var tmpt:Point;
	
	function onStageResize(e:Event=null)
	{
		SparrowUtil.addNextCall(nextResize);
	}
	
	function nextResize()
	{
		if (this.stage == null || this.parent == null)
		return;
		
		var p:DisplayObject = this.parent;
		tmpt.x = p.stage.stageWidth;
		tmpt.y = p.stage.stageHeight;
		var stageWH:Point = p.globalToLocal(tmpt);
		var lr:Point = p.globalToLocal(new Point());
		width = stageWH.x - lr.x - paddingLeft - paddingRight;
		height = stageWH.y - lr.y - paddingTop - paddingButtom;
		x = lr.x + paddingLeft;
		y = lr.y + paddingTop;
	}
	
	
	/**
	 * 左边界宽
	 */
	public var paddingLeft:Int = -50;
	/**
	 * 右边界宽
	 */
	public var paddingRight:Int = -50;
	/**
	 * 上边界宽
	 */
	public var paddingTop:Int = -50;
	/**
	 * 下边界宽
	 */
	public var paddingButtom:Int = -50;
	
	public function setPadding(value:Int):Void 
	{
		paddingTop = value;
		paddingLeft = value;
		paddingButtom = value;
		paddingRight = value;
		onStageResize();
	}
		
	/**
	 * 透明度
	 */
	public var showAlpha:Float = 0.5;
	
	public var drawColor:Int = 0x000000;
	
	public function skinDraw():Void
	{
		var gp:Graphics = graphics;
		gp.clear();
		gp.beginFill(drawColor,1);
		
		gp.drawRect(0,0,10,10);
		gp.endFill();
		alpha = showAlpha;
	}
	
	/**
	 * 跟椐屏幕改变尺寸
	 * @param e
	 
	private function onChangeRect():Void
	{
		if (!this.visible || this.parent == null)
		return;
		var sgm:StageMgr = StageMgr.getInstance();
		var stageWH:Point = sgm.globalBRtoLocal(this); 
		width = stageWH.x - paddingLeft - paddingRight;
		height = stageWH.y - paddingTop - paddingButtom;
		x = paddingLeft;
		y = paddingTop;
	}*/
}