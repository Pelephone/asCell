package utils
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class HitTest
	{
		private static var colorTran1:ColorTransform = new ColorTransform( 1, 1, 1, 1, 255, -255, -255, 255 );
		private static var colorTran2:ColorTransform = new ColorTransform( 1, 1, 1, 1, 255, 255, 255, 255 );
		
		/**
		 * 两不规则图形是否碰撞
		 * @param target1
		 * @param target2
		 * @param accurracy
		 */		
		public static function complexHitTestObject( target1:DisplayObject, target2:DisplayObject,  accurracy:Number = 1 ):Boolean
		{
			var rect:Rectangle = complexIntersectionRectangle( target1, target2, accurracy );
			if(!rect) return false;
			return rect.width != 0;
		}
		
		/**
		 * 两规则图形相交的矩形
		 * @param target1
		 * @param target2
		 */		
		public static function intersectionRectangle( target1:DisplayObject, target2:DisplayObject ):Rectangle
		{
			// If either of the items don't have a reference to stage, then they are not in a display list
			// or if a simple hitTestObject is false, they cannot be intersecting.
			if( !target1.root || !target2.root || !target1.hitTestObject( target2 ) ) return null;
			
			// Get the bounds of each DisplayObject.
			var rect1:Rectangle = target1.getBounds( target1.root );
			var rect2:Rectangle = target2.getBounds( target2.root );
			
			// Determine test area boundaries.
			var rect:Rectangle = new Rectangle();
			rect.x 		= Math.max( rect1.x, rect2.x );
			rect.y		= Math.max( rect1.y, rect2.y );
			rect.width 	= Math.min( ( rect1.x + rect1.width ) - rect.x, ( rect2.x + rect2.width ) - rect.x );
			rect.height = Math.min( ( rect1.y + rect1.height ) - rect.y, ( rect2.y + rect2.height ) - rect.y );
			
			return rect;
		}
		
		/**
		 * 两不规则图形相交的矩形
		 * @param target1
		 * @param target2
		 * @param accurracy	精准度
		 */		
		public static function complexIntersectionRectangle( target1:DisplayObject, target2:DisplayObject, accurracy:Number = 1 ):Rectangle
		{			
			if( accurracy <= 0 )throw new Error( "ArgumentError: Error #5001: Invalid value for accurracy", 5001 );
			
			// If a simple hitTestObject is false, they cannot be intersecting.
			if( !target1.hitTestObject( target2 ) ) return null;
			
			var rect1:Rectangle = intersectionRectangle( target1, target2 );
			// If their boundaries are no interesecting, they cannot be intersecting.
			if(!rect1 || rect1.width * accurracy < 1 || rect1.height * accurracy < 1 ) return null;
			
			var bitmapData:BitmapData = new BitmapData( rect1.width * accurracy, rect1.height * accurracy, false, 0x000000 );	
			
			// Draw the first target.
			bitmapData.draw( target1, HitTest.getDrawMatrix( target1, rect1, accurracy ), colorTran1 );
			// Overlay the second target.
			bitmapData.draw( target2, HitTest.getDrawMatrix( target2, rect1, accurracy ), colorTran2, BlendMode.DIFFERENCE );
			
			// Find the intersection.
			var rect:Rectangle = bitmapData.getColorBoundsRect( 0xFFFFFFFF,0xFF00FFFF );
			
			bitmapData.dispose();
			
			// Alter width and positions to compensate for accurracy
			if( accurracy != 1 )
			{
				rect.x /= accurracy;
				rect.y /= accurracy;
				rect.width /= accurracy;
				rect.height /= accurracy;
			}
			
			rect.x += rect1.x;
			rect.y += rect1.y;
			
			return rect;
		}
		
		protected static function getDrawMatrix( target:DisplayObject, hitRectangle:Rectangle, accurracy:Number ):Matrix
		{
			var localToGlobal:Point;
			var matrix:Matrix;
			
			var rootConcatenatedMatrix:Matrix = target.root.transform.concatenatedMatrix;
			
			localToGlobal = target.localToGlobal( new Point( ) );
			matrix = target.transform.concatenatedMatrix;
			matrix.tx = localToGlobal.x - hitRectangle.x;
			matrix.ty = localToGlobal.y - hitRectangle.y;
			
			matrix.a = matrix.a / rootConcatenatedMatrix.a;
			matrix.d = matrix.d / rootConcatenatedMatrix.d;
			if( accurracy != 1 ) matrix.scale( accurracy, accurracy );
			
			return matrix;
		}
		
		/**
		 * 通过图形里的参考点判断两图形是否碰撞,参考点越多越精准
		 * 确保容器内有hitPt(*)命名的空剪辑才能对比
		 * 原理是容器里边缘的所有参考点是否与另外图形碰撞。
		 * @return 
		 */		
		public function hitTestInPts(disp1:DisplayObjectContainer,disp2:DisplayObjectContainer,ptName:String="hitPt"):Boolean
		{
			if(!disp1.hitTestObject(disp2)) return false;
			for(var i:int=0;i<disp2.numChildren;i++){
				var o:DisplayObjectContainer = disp2.getChildAt(i) as DisplayObjectContainer;
				if(!o) continue;
				var po:Point = o.localToGlobal(new Point());
				if(disp1.hitTestPoint(po.x,po.y,true)) return true;
			}
			for(i=0;i<disp1.numChildren;i++){
				o = disp1.getChildAt(i) as DisplayObjectContainer;
				if(!o) continue;
				po = o.localToGlobal(new Point());
				if(disp2.hitTestPoint(po.x,po.y,true)) return true;
			}
			return false;
		}
	}
}