package asSkinStyle.draw;

import asSkinStyle.i.IDrawBase;
import asSkinStyle.i.IRectDraw;

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 测试时用于画测试点和测试线的
 * @author Pelephone
 */	
class DrawTool
{
	// 画点,用一个圆来表示
	static public function drawPt(px:Int,py:Int,sp:Sprite):Void
	{
		sp.graphicsclear();
		sp.graphicslineStyle(null,0xFF0000);
		sp.graphicsdrawCircle(px,py,3);
	}
	
	// 通过两点画一条直接
	static public function drawLine(p1:Point,p2:Point,sp:Sprite):Void
	{
		sp.graphicsclear();
		sp.graphicslineStyle(null,0xFF0000);
		sp.graphicsmoveTo(p1.x,p1.y);
		sp.graphicslineTo(p2.x,p2.y);
	}
	
	// 未写完
	static public function draw(tarDisp:DisplayObject,drawPan:Sprite):Void
	{
		var gr:Graphics = drawPan.graphics;
		gr.beginFill(0x000000,0.3);
		gr.drawRect(100,100,100,100);
		gr.drawRect(150,150,10,10);
		gr.endFill();
	}
	
	/**
	 * 功能按钮亮，其它地方透明黑(新手教程常用)
	 * @param disps
	 */
	static public function blackFilterLay(parent:Sprite,disps:Array<DisplayObject>):Void
	{
		var padding:Int = 5;
		var ndisp:Sprite = new Sprite();
		var gr:Graphics = ndisp.graphics;
		gr.beginFill(0x000000,0.3);
		gr.drawRect(0,0,parent.stage.stageWidth,parent.stage.stageHeight);
		gr.lineStyle(2,0xFF0000);
		for (disp in disps) 
		{
			gr.drawRect((disp.x-padding),(disp.y-padding),(disp.width+padding*2),(disp.height-padding*2));
		}
		gr.endFill();
		parent.addChild(ndisp);
	}
	
	/**
	 * 绘制矩形
	 * @param drawInfo 矩形数据
	 * @param graphics 图形 
	 */
	public static function drawRect(graphics:Graphics,drawInfo:IRectDraw):Void
	{
//			graphics.clear();
		if(drawInfo.bgAlpha)
		{
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2>=0)
			{
				var matr:Matrix = new Matrix();
				matr.createGradientBox(drawInfo.width, drawInfo.height, drawInfo.bgRotaion);
				graphics.beginGradientFill(GradientType.LINEAR,[drawInfo.bgColor,drawInfo.bgColor2],
					[drawInfo.bgAlpha,drawInfo.bgAlpha],[0x00, 0xFF],matr);
			}
			
			var isSameBorder:Boolean = (drawInfo.borderTop == drawInfo.borderBottom && drawInfo.borderBottom == drawInfo.borderLeft
				&& drawInfo.borderLeft == drawInfo.borderRight && drawInfo.borderTopColor == drawInfo.borderBottomColor
				&& drawInfo.borderBottomColor == drawInfo.borderLeftColor && drawInfo.borderLeftColor == drawInfo.borderRightColor);
			
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2<0)
			{
				graphics.beginFill(drawInfo.bgColor,drawInfo.bgAlpha);
				graphics.lineStyle(0,0,0);
				
				if(drawInfo.ellipse<=0)
					graphics.drawRect(0,0,drawInfo.width,drawInfo.height);
				else
					graphics.drawRoundRect(0,0,drawInfo.width,drawInfo.height,drawInfo.ellipse,drawInfo.ellipse);
				graphics.endFill();
			}
			
			if(drawInfo.inBgColor>=0)
			{
				graphics.beginFill(drawInfo.inBgColor,drawInfo.bgAlpha);
				var pw:Int = drawInfo.width - drawInfo.paddingLeft - drawInfo.paddingRight;
				var ph:Int = drawInfo.height - drawInfo.paddingTop - drawInfo.paddingBottom;
				graphics.lineStyle(0,0,0);
				if(drawInfo.inEllipse<=0)
					graphics.drawRect(drawInfo.paddingLeft,drawInfo.paddingTop,pw,ph);
				else
					graphics.drawRoundRect(drawInfo.paddingLeft,drawInfo.paddingTop,pw,ph
						,drawInfo.inEllipse,drawInfo.inEllipse);
				graphics.endFill();
			}
			
			if(isSameBorder)
			{
				if(drawInfo.border>0 && drawInfo.borderColor>0)
				{
					graphics.lineStyle(drawInfo.border,drawInfo.borderColor,1);
					if(drawInfo.ellipse<=0)
						graphics.drawRect(0,0,drawInfo.width,drawInfo.height);
					else
						graphics.drawRoundRect(0,0,drawInfo.width,drawInfo.height,drawInfo.ellipse,drawInfo.ellipse);
				}
			}
			else
			{
				var linAlpha:Int;
				if(drawInfo.borderTop)
				{
					linAlpha = (drawInfo.borderTopColor>0)?1:0;
					graphics.moveTo(0,0);
					graphics.lineStyle(drawInfo.borderTop,drawInfo.borderTopColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),0);
				}
				if(drawInfo.borderLeft)
				{
					linAlpha = (drawInfo.borderLeftColor>0)?1:0;
					graphics.moveTo(0,0);
					graphics.lineStyle(drawInfo.borderLeft,drawInfo.borderLeftColor,linAlpha);
					graphics.lineTo(0,(drawInfo.height));
				}
				if(drawInfo.borderRight)
				{
					linAlpha = (drawInfo.borderRightColor>0)?1:0;
					graphics.moveTo((0+drawInfo.width),0);
					graphics.lineStyle(drawInfo.borderRight,drawInfo.borderRightColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),(0+drawInfo.height));
				}
				if(drawInfo.borderBottom)
				{
					linAlpha = (drawInfo.borderBottomColor>0)?1:0;
					graphics.moveTo(0,(0+drawInfo.height));
					graphics.lineStyle(drawInfo.borderBottom,drawInfo.borderBottomColor,linAlpha);
					graphics.lineTo((0+drawInfo.width),(0+drawInfo.height));
				}
			}
		}
	}
	
	/**
	 * 画圆
	 */
	public static function drawCircle(graphics:Graphics,drawInfo:IDrawBase):Void
	{
//			graphics.clear();
		if(drawInfo.bgAlpha)
		{
			graphics.beginFill(drawInfo.bgColor,drawInfo.bgAlpha);
			
			if(drawInfo.bgColor>=0 && drawInfo.bgColor2>=0)
			{
				var matr:Matrix = new Matrix();
				matr.createGradientBox(drawInfo.width, drawInfo.height, drawInfo.bgRotaion);
				graphics.beginGradientFill(GradientType.LINEAR,[drawInfo.bgColor,drawInfo.bgColor2],
					[drawInfo.bgAlpha,drawInfo.bgAlpha],[0x00, 0xFF],matr);
			}
			
			if(drawInfo.borderColor>0)
				graphics.lineStyle(drawInfo.border,drawInfo.borderColor,1);
			else
				graphics.lineStyle(0,0,0);
			
			if(drawInfo.width==drawInfo.height)
				graphics.drawCircle(drawInfo.width*0.5,drawInfo.height*0.5,drawInfo.width*0.5);
			else
				graphics.drawEllipse(drawInfo.width*0.5,drawInfo.height*0.5,drawInfo.width,drawInfo.height);
			
			graphics.endFill();
		}
	}
}