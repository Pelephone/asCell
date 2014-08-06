package utils.tools
{
	import flash.geom.Point;
	
	import utils.UVector;

	/**
	 * 几何工具,里面有一些点、线、面的计算
	 * @author Pelephone
	 */	
	public class GeometryTool
	{
		/**
		 * 通过点，长度，角度获取某点对于长度的延长线的点
		 * 注:ra是角度不是孤度
		 */
		public static function getExtPot(p:Point,l:Number,ra:Number):Point
		{
			var tt:Point = Point.polar(l,ra);
			tt.offset(p.x,p.y);
			return tt;
		}
		
		/**
		 * 弧度转角度
		 * @param radian
		 */		
		public static function radianToAngle(radian:Number):Number
		{
			return radian*180/Math.PI;
		}
		
		/**
		 * 角度转弧度
		 * @param radian
		 */		
		public static function angleToRadian(radian:Number):Number
		{
			return radian*Math.PI/180;
		}
		
		/**
		 * 将角度转换到0~360之间的值
		 * @param ang
		 */		
		public static function angleTo360(anglg:Number):Number
		{
			return anglg>0?anglg%360:anglg%360+360;
		}
		
		/**
		 * 将孤度转换到0~2PI之间的值
		 * @param radian
		 * @return 
		 */
		public static function radianTo2RI(radian:Number):Number
		{
			return radian>0?(radian%(Math.PI*2)):(radian%(Math.PI*2)+Math.PI*2);
		}
		
		/**
		 * angx角是否在ang1和ang2组成的角(锐角)之间
		 */		
		public static function isInAngle(angx:Number,ang1:Number,ang2:Number):Boolean
		{
			var min:Number = Math.min(angleTo360(ang1),angleTo360(ang2));
			var max:Number = Math.max(angleTo360(ang1),angleTo360(ang2));
			angx = angleTo360(angx);
			if((max-min)<180)
				return (angx>min && angx<max)
			else{
				var tt:Number = 360-max;
				return ((angx+tt)>0 && (angx+tt)<(min+tt))
			}
		}
		
		/**
		 * 获取两点的距离(勾股定理)
		 * @param sp 起点
		 * @param ep 终点
		 * @return 肯定是正数
		 */
		public static function getPtDistance(sx:Number,sy:Number,ex:Number,ey:Number):Number
		{
			var dx:Number = sx - ex;
			var dy:Number = sy - ey;
			return Math.sqrt(dx * dx + dy * dy)
		}
		
		/**
		 * 通过两点算出弧度(0~2*PI)<br/>
		 * @param sp
		 * @param ep
		 */		
		public static function getRadianByPot(sx:Number,sy:Number,ex:Number,ey:Number):Number
		{
//		* 反正切((Y2-Y1)/(X2-X1)),  这个公式算出一个结果后,再判断点所在的像线.如果X2-X1的结果<0,
//		* 那么就用刚才的结果+180; 如果X2-X1>0,且Y2-Y1>0,那么结果就是刚才用公式算出的结果;
//		* 如果X2-X1>0,且Y2-Y1<0,那么刚才公式算出的结果再+360. 
//			var tRad:Number = Math.atan((ep.y-sp.y)/(ep.x-sp.x));
//			if((ep.x-sp.x)<0) return tRad + Math.PI;
//			else if((ep.x-sp.x)>0 && (ep.y-sp.y)<0) return tRad + 2*Math.PI;
//			else return tRad;
			return radianTo2RI(Math.atan2(ey-sy,ex-sx));
		}
		
		/**
		 * 判断点是否在椭圆里面 x^2/a^2+y^2/b^2=1 (a>0,b>0)
		 * @param px 判断点x坐标
		 * @param py 判断点y坐标
		 * @param ellX 椭圆圆心x坐标
		 * @param ellY 椭圆圆心y坐标
		 * @param a 椭圆长轴 必须>0
		 * @param b 椭圆智轴 必须>0 如果a==b表示是圆
		 */
		public static function isInElliptic(px:Number,py:Number,ellX:Number,ellY:Number,a:Number=5,b:Number=5):Boolean
		{
			var x:Number = px - ellX;
			var y:Number = py - ellY;
			var end:Number = ((x*x)/(a*a) + (y*y)/(b*b));
			return end <= 1;
		}
		
		/**
		 * 判断点是否在矩形内
		 * @return 
		 */
		public static function inInRect(px:Number,py:Number,rectX:Number,rectY:Number,rectWidth:Number=5,rectHeight:Number=5):Boolean
		{
			return (px >= rectX && px <= (rectX + rectWidth) && py >= rectY && py <= (rectY + rectHeight));
		}
		
		/**
		 * 得到两点间连线的斜率 
		 * @param ponit1
		 * @param point2
		 * @return 			两点间连线的斜率 
		 */
		public static function getLineSlope( ponit1:Point, point2:Point ):Number
		{
			return (point2.y - ponit1.y) / (point2.x - ponit1.x); 
		}
		
		/**
		 * 某点的延长线与某直线的交点
		 * @param p1		点1
		 * @param ra		点2延长线方向
		 * @param p3		另一线直线一点
		 * @param p4		另一条直线的另一点
		 * @return 
		 */		
		public static function secExtPtLineNode(p1:Point,ra:Number,p3:Point,p4:Point):Point
		{
			var p2:Point = getExtPot(p1,10,ra);
			return secLineIntersect(p1,p2,p3,p4);
		}
		
		/**
		 * 两向量相交的点
		 * @param p1	点1
		 * @param ra1	点1的方向
		 * @param p2	点2
		 * @param ra2	点2的方向
		 * @return 
		 */		
		public static function vector2Intersect(p1:Point,ra1:Number,p2:Point,ra2:Number):Point
		{
			var v1:UVector =  new UVector(p1.x,p1.y,ra1);
			var v2:UVector =  new UVector(p2.x,p2.y,ra2);
			return UVectorIntersect(v1,v2);
		}
		
		/**
		 * 计算两线段交点
		 * @param p1 线段1的开始点
		 * @param p2 线段1的结束点
		 * @param p3 线段2的开始点
		 * @param p4 线段2的结束点
		 */		
		public static function secLineIntersect(p1:Point,p2:Point,p3:Point,p4:Point):Point
		{
			if(secLineIsIntersect(p1,p2,p3,p4)){
				var v1:UVector =  new UVector(p1.x,p1.y,getRadianByPot(p1.x,p1.y,p2.x,p2.y));
				var v2:UVector =  new UVector(p3.x,p3.y,getRadianByPot(p3.x,p3.y,p4.x,p4.y));
				return UVectorIntersect(v1,v2);
			}else
				return null;
		}
		
		/**
		 * 计算两斜线向量交点;直线向量公式 y=k*x+b;(k!=0)
		 * 原理:两条直线先分别求出公式里的b参数;然后两直线方程计算交点x,y
		 * @param v1
		 * @param v2
		 * @return 
		 */
		public static function UVectorIntersect(v1:UVector,v2:UVector):Point
		{
			var k1:Number = Math.tan(v1.radian);
			var k2:Number = Math.tan(v2.radian);
			if(k1==k2) return null;	//平行线,无交点
			var b1:Number = (v1.y - v1.x*k1);
			var b2:Number = (v2.y - v2.x*k2);
			var px:Number = -1*(b1-b2)/(k1-k2);
			var py:Number = (k1*px + b1);
//			var px:Number = (v2.y - v1.y + k1*v1.x - k2*v2.x)/(k1-k2);
//			var py:Number = ((px - v2.x)==0)?(k1*(px - v1.x) + v1.y):(k2*(px - v2.x) + v2.y);
			return new Point(px,py);
		}
		
		/**
		 * 两线段是否相交
		 * @param p1 线段1的开始点
		 * @param p2 线段1的结束点
		 * @param p3 线段2的开始点
		 * @param p4 线段2的结束点
		 * @return 
		 */		
		public static function secLineIsIntersect(p1:Point,p2:Point,p3:Point,p4:Point):Boolean
		{
			return Math.max(p1.x, p2.x)>=Math.min(p3.x, p4.x)
				&& Math.max(p1.y, p2.y)>=Math.min(p3.y, p4.y)
				&& Math.max(p3.x, p4.x)>=Math.min(p1.x, p2.x)
				&& Math.max(p3.y, p4.y)>=Math.min(p1.y, p2.y)
				&& mult(p3, p2, p1)*mult(p2, p4, p1)>=0
				&& mult(p1, p4, p3)*mult(p4, p2, p3)>=0;
		}
		
		//叉积(用于判断两线段是否相交)
		public static function mult(a:Point,b:Point,c:Point):Number
		{
			return (a.x-c.x)*(b.y-c.y)-(b.x-c.x)*(a.y-c.y);
		}
		
		
		/**
		 * 判断第三点pc是否在pa,pb组成的线的左侧还是右侧
		 * @param pa
		 * @param pb
		 * @param pc
		 * @return >0表示在左侧；＝0表示在线上；<0表示在右侧
		 */		
		public static function potInLR(pa:Point,pb:Point,pc:Point):int
		{
			return (pb.x - pa.x) * (pc.y - pa.y) - (pc.x - pa.x) * (pb.y - pa.y);
		}
		
		/**
		 * 点到直接线的距离
		 * @param p1	线外的点
		 * @param lp1	线的起点
		 * @param lp2	线的终点
		 */
		public static function point2Line(p1:Point, lp1:Point, lp2:Point):Number
		{
			var a:Number, b:Number, c:Number;
			a = lp2.y - lp1.y;
			b = lp1.x - lp2.x;
			c = lp2.x * lp1.y - lp1.x * lp2.y;
			var d:Number = Math.abs(a * p1.x + b * p1.y + c) / Math.sqrt(a * a + b * b);
			return d;
		};
		
		/**
		 * 将0,1，true,false，转换成-1,1;
		 * @param num
		 */		
		public static function c01To1(num:int):int
		{
			return num*2-1;
		}
	}
}