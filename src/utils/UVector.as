package utils
{
	import flash.geom.Point;
	
	import utils.tools.GeometryTool;
	
	public class UVector extends Point
	{
		//孤度
		public var radian:Number=0;
		function UVector(tx:Number=0,ty:Number=0,ra:Number=0)
		{
			x = tx;
			y = ty;
			radian = ra;
		}
		//角度
		public function get angle():Number
		{
			return GeometryTool.radianToAngle(radian);
		}
	}
}