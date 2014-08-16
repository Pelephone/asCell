package utils
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.display.BitmapData;

	/**
	 * 画笔画布
	 * @author Pelephone
	 */
	public class Pen
	{
		private var _gTarget:Graphics;
		private var _bLineStyleSet:Boolean;

		public function Pen(gTarget:Graphics) {
			_gTarget=gTarget;
		}
		public function set target(gTarget:Graphics):void {
			_gTarget=gTarget;
		}
		public function get target():Graphics {
			return _gTarget;
		}

		public function lineStyle(nThickness:Number = 1, nRGB:uint = 0, nAlpha:Number = 1, bPixelHinting:Boolean = false, sScaleMode:String = "normal", sCaps:String = null, 
		
		sJoints:String = null, nMiterLimit:Number = 3):void {
			_gTarget.lineStyle(nThickness, nRGB, nAlpha, bPixelHinting, sScaleMode, sCaps, sJoints, nMiterLimit);
			_bLineStyleSet=true;
		}

		public function lineGradientStyle(sType:String, aColors:Array, aAlphas:Array, aRatios:Array, mtxTransform:Matrix = null, sMethod:String = "pad", sInterpolation:String = 
		
		"rgb", nFocalPoint:Number = 0):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.lineGradientStyle(sType, aColors, aAlphas, aRatios, mtxTransform, sMethod, sInterpolation, nFocalPoint);
		}

		public function beginFill(nRGB:Number, nAlpha:Number = 1):void {
			_gTarget.beginFill(nRGB, nAlpha);
		}

		public function beginGradientFill(sFillType:String, aColors:Array, aAlphas:Array, aRatios:Array, mtxTransform:Matrix = null, sMethod:String = "pad", sInterpolation:String = 
		
		"rgb", nFocalPoint:Number = 0):void {
			_gTarget.beginGradientFill(sFillType, aColors, aAlphas, aRatios, mtxTransform, sMethod, sInterpolation, nFocalPoint);
		}

		public function beginBitmapFill(bmpData:BitmapData, mtxTransform:Matrix = null, bRepeat:Boolean = true, bSmooth:Boolean = false):void {
			_gTarget.beginBitmapFill(bmpData, mtxTransform, bRepeat, bSmooth);
		}

		public function endFill():void {
			_gTarget.endFill();
		}

		public function clear():void {
			_gTarget.clear();
			_bLineStyleSet=false;
		}

		public function moveTo(nX:Number, nY:Number):void {
			_gTarget.moveTo(nX, nY);
		}

		public function lineTo(nX:Number, nY:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.lineTo(nX, nY);
		}

		public function curveTo(nCtrlX:Number, nCtrlY:Number, nAnchorX:Number, nAnchorY:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.curveTo(nCtrlX, nCtrlY, nAnchorX, nAnchorY);
		}

		public function drawLine(nX0:Number, nY0:Number, nX1:Number, nY1:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.moveTo(nX0, nY0);
			_gTarget.lineTo(nX1, nY1);
		}

		public function drawCurve(nX:Number, nY:Number, nCtrlX:Number, nCtrlY:Number, nAnchorX:Number, nAnchorY:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.moveTo(nX, nY);
			_gTarget.curveTo(nCtrlX, nCtrlY, nAnchorX, nAnchorY);
		}

		public function drawRect(nX:Number, nY:Number, nWidth:Number, nHeight:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.drawRect(nX, nY, nWidth, nHeight);
		}

		public function drawRoundRect(nX:Number, nY:Number, nWidth:Number, nHeight:Number, nRadius:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.drawRoundRect(nX, nY, nWidth, nHeight, nRadius);
		}

		public function drawRoundRectComplex(nX:Number, nY:Number, nWidth:Number, nHeight:Number, nA:Number, nB:Number, nC:Number, nD:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.drawRoundRectComplex(nX, nY, nWidth, nHeight, nA, nB, nC, nD);
		}
		//绘制圆
		public function drawCircle(nX:Number, nY:Number, nRadius:Number):void {
			if (! _bLineStyleSet) {
				lineStyle();
			}
			_gTarget.drawCircle(nX, nY, nRadius);
		}
		//绘制扇形
		public function drawSlice(nArc:Number, nRadius:Number, nStartingAngle:Number, nX:Number, nY:Number):void {
			drawArc(nX, nY, nRadius, nArc, nStartingAngle, true);
		}
		/*
		 绘制圆弧或扇形
		 nX，nY：圆心坐标
		 nRadius：半径
		 nArc:  角度
		 nStartingAngle: 起始角（顺时针）
		 bRadialLines：false圆弧，true扇形
		 */
		public function drawArc(nX:Number, nY:Number, nRadius:Number, nArc:Number, nStartingAngle:Number = 0, bRadialLines:Boolean = false):void {
			if (nArc>360) {
				nArc=360;
			}
			nArc=Math.PI/180*nArc;
			var nAngleDelta:Number=nArc/8;
			var nCtrlDist:Number=nRadius/Math.cos(nAngleDelta/2);

			nStartingAngle*=Math.PI/180;

			var nAngle:Number=nStartingAngle;
			var nCtrlX:Number;
			var nCtrlY:Number;
			var nAnchorX:Number;
			var nAnchorY:Number;

			var nStartingX:Number=nX+Math.cos(nStartingAngle)*nRadius;
			var nStartingY:Number=nY+Math.sin(nStartingAngle)*nRadius;

			if (bRadialLines) {
				moveTo(nX, nY);
				lineTo(nStartingX, nStartingY);
			} else {
				moveTo(nStartingX, nStartingY);
			}
			for (var i:Number = 0; i < 8; i++) {
				nAngle+=nAngleDelta;
				nCtrlX = nX + Math.cos(nAngle-(nAngleDelta/2))*(nCtrlDist);
				nCtrlY = nY + Math.sin(nAngle-(nAngleDelta/2))*(nCtrlDist);
				nAnchorX=nX+Math.cos(nAngle)*nRadius;
				nAnchorY=nY+Math.sin(nAngle)*nRadius;
				curveTo(nCtrlX, nCtrlY, nAnchorX, nAnchorY);
			}
			if (bRadialLines) {
				lineTo(nX, nY);
			}
		}
		//绘制椭圆，nX，nY:中心；nRadiusX:横轴；nRadiusY:纵轴
		public function drawEllipse(nX:Number, nY:Number, nRadiusX:Number, nRadiusY:Number):void {

			var nAngleDelta:Number=Math.PI/4;
			var nAngle:Number=0;
			var nCtrlDistX:Number=nRadiusX/Math.cos(nAngleDelta/2);
			var nCtrlDistY:Number=nRadiusY/Math.cos(nAngleDelta/2);
			var nCtrlX:Number;
			var nCtrlY:Number;
			var nAnchorX:Number;
			var nAnchorY:Number;

			moveTo(nX + nRadiusX, nY);

			for (var i:Number = 0; i < 8; i++) {
				nAngle+=nAngleDelta;
				nCtrlX = nX + Math.cos(nAngle-(nAngleDelta/2))*(nCtrlDistX);
				nCtrlY = nY + Math.sin(nAngle-(nAngleDelta/2))*(nCtrlDistY);
				nAnchorX=nX+Math.cos(nAngle)*nRadiusX;
				nAnchorY=nY+Math.sin(nAngle)*nRadiusY;
				this.curveTo(nCtrlX, nCtrlY, nAnchorX, nAnchorY);
			}
		}

		/*
		    绘制三角形ABC
		 nX,nY:角A顶坐标
		 nAB, nAC：AB，AC边长
		 nAngle:角A（度）
		 nRotation:边AC与X轴夹角（逆时针）
		    */
		public function drawTriangle(nX:Number, nY:Number, nAB:Number, nAC:Number, nAngle:Number, nRotation:Number = 0):void {

			nRotation=nRotation*Math.PI/180;

			nAngle=nAngle*Math.PI/180;
			var nBx:Number=Math.cos(nAngle-nRotation)*nAB;
			var nBy:Number=Math.sin(nAngle-nRotation)*nAB;
			var nCx:Number=Math.cos(- nRotation)*nAC;
			var nCy:Number=Math.sin(- nRotation)*nAC;

			var nCentroidX:Number=0;
			var nCentroidY:Number=0;

			drawLine(-nCentroidX + nX, -nCentroidY + nY, nCx - nCentroidX + nX, nCy - nCentroidY + nY);
			lineTo(nBx - nCentroidX + nX, nBy - nCentroidY + nY);
			lineTo(-nCentroidX + nX, -nCentroidY + nY);
		}
		/* 绘制正多边形:
		     nX, nY:中心坐标; nSides:边数; nLength:边长;nRotation:起点角
		 */
		public function drawRegularPolygon(nX:Number, nY:Number, nSides:Number, nLength:Number, nRotation:Number = 0):void {
			var nRadius:Number = (nLength/2)/Math.sin(Math.PI/nSides);//求半径
			drawRegularPolygon2(nX, nY, nSides, nRadius, nRotation);
		}
		/* 绘制正多边形
		     nX, nY:中心坐标; nSides:边数; nRadius:外接圆半径; nRotation:起点角
		 */
		public function drawRegularPolygon2(nX:Number, nY:Number, nSides:Number, nRadius:Number, nRotation:Number = 0):void {

			nRotation=nRotation*Math.PI/180;
			var nAngle:Number = (2 * Math.PI) / nSides;
			var nPx:Number = (Math.cos(nRotation) * nRadius) + nX;
			var nPy:Number = (Math.sin(nRotation) * nRadius) + nY;

			moveTo(nPx, nPy);

			for (var i:Number = 1; i <= nSides; i++) {
				nPx = (Math.cos((nAngle * i) + nRotation) * nRadius) + nX;

				nPy = (Math.sin((nAngle * i) + nRotation) * nRadius) + nY;
				lineTo(nPx, nPy);
			}
		}
		/* 绘制星形
		     nX, nY:中心坐标; nPoints:顶点数; nInnerRadius:半径1; nOuterRadius:半径2; nRotation:起点角
		 */
		public function drawStar(nX:Number, nY:Number, nPoints:Number, nInnerRadius:Number, nOuterRadius:Number, nRotation:Number = 0):void {

			if (nPoints<3) {
				return;
			}

			var nAngleDelta:Number = (Math.PI * 2) / nPoints;
			nRotation = Math.PI * (nRotation - 90) / 180;

			var nAngle:Number=nRotation;
			var nPenX:Number=nX+Math.cos(nAngle+nAngleDelta/2)*nInnerRadius;
			var nPenY:Number=nY+Math.sin(nAngle+nAngleDelta/2)*nInnerRadius;

			moveTo(nPenX, nPenY);
			nAngle+=nAngleDelta;

			for (var i:Number = 0; i < nPoints; i++) {
				nPenX=nX+Math.cos(nAngle)*nOuterRadius;
				nPenY=nY+Math.sin(nAngle)*nOuterRadius;
				lineTo(nPenX, nPenY);
				nPenX=nX+Math.cos(nAngle+nAngleDelta/2)*nInnerRadius;
				nPenY=nY+Math.sin(nAngle+nAngleDelta/2)*nInnerRadius;
				lineTo(nPenX, nPenY);
				nAngle+=nAngleDelta;
			}
		}
	}
}