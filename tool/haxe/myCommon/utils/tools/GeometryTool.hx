package utils.tools;

import flash.geom.Point;

/**
 * 几何工具,里面有一些点、线、面的计算
 * @author Pelephone
 */	
class GeometryTool
{
	/**
	 * 通过点，长度，角度获取某点对于长度的延长线的点
	 * 注:ra是角度不是孤度
	 */
	public static function getExtPot(p:Point,l:Float,ra:Float):Point
	{
		var tt:Point = Point.polar(l,ra);
		tt.offset(p.x, p.y);
		return tt;
	}
	/**
	 * 通过点，长度，角度获取某点对于长度的延长线的点
	 * 注:ra是角度不是孤度
	 */
	public static function getExtPot2(px:Int,py:Int,l:Float,ra:Float):Point
	{
		var curAngle:Float = angleToRadian(ra);
		var py:Float = Math.sin(curAngle) * l + py;
		var px:Float = Math.cos(curAngle) * l + px;
		return new Point(px,py);
	}
	
	/**
	 * 弧度转角度
	 * @param radian
	 */		
	public static function radianToAngle(radian:Float):Float
	{
		return radian * 180 / Math.PI;
	}
	
	/**
	 * 角度转弧度
	 * @param radian
	 */		
	public static function angleToRadian(radian:Float):Float
	{
		return radian*Math.PI/180;
	}
	
	/**
	 * 返回的浮点数的位数
	 */
	inline public static var DEFAULT_DIGIT:Int = 8;
	
	/**
	 * 将角度转换到0~360之间的值
	 * @param ang
	 */		
	public static function angleTo360(anglg:Float):Float
	{
		var res:Float = anglg > 0?anglg % 360:anglg % 360 + 360;
		return res;
	}
	
	/**
	 * 将孤度转换到0~2PI之间的值
	 * @param radian
	 * @return 
	 */
	public static function radianTo2RI(radian:Float):Float
	{
		var res:Float = radian>0?(radian%(Math.PI*2)):(radian%(Math.PI*2)+Math.PI*2);
		return res;
	}
	
	/**
	 * angx角是否在ang1和ang2组成的角(锐角)之间
	 */		
	public static function isInAngle(angx:Float,ang1:Float,ang2:Float):Bool
	{
		var min:Float = Math.min(angleTo360(ang1),angleTo360(ang2));
		var max:Float = Math.max(angleTo360(ang1),angleTo360(ang2));
		angx = angleTo360(angx);
		if((max-min)<180)
			return (angx>min && angx<max)
		else{
			var tt:Float = 360 - max;
			return ((angx + tt) > 0 && (angx + tt) < (min + tt));
		}
	}
	
	/**
	 * 获取两点的距离(勾股定理)
	 * @param sp 起点
	 * @param ep 终点
	 * @return 肯定是正数
	 */
	public static function getPtDistance(sx:Float,sy:Float,ex:Float,ey:Float):Float
	{
		var dx:Float = sx - ex;
		var dy:Float = sy - ey;
		var res:Float = Math.sqrt(dx * dx + dy * dy);
		return res;
	}
	
	/**
	 * 通过两点算出弧度(0~2*PI)<br/>
	 * @param sp
	 * @param ep
	 */		
	public static function getRadianByPot(sx:Float,sy:Float,ex:Float,ey:Float):Float
	{
//		* 反正切((Y2-Y1)/(X2-X1)),  这个公式算出一个结果后,再判断点所在的像线.如果X2-X1的结果<0,
//		* 那么就用刚才的结果+180; 如果X2-X1>0,且Y2-Y1>0,那么结果就是刚才用公式算出的结果;
//		* 如果X2-X1>0,且Y2-Y1<0,那么刚才公式算出的结果再+360. 
//			var tRad:Float = Math.atan((ep.y-sp.y)/(ep.x-sp.x));
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
	public static function isInElliptic(px:Float,py:Float,ellX:Float,ellY:Float,a:Float=5,b:Float=5):Bool
	{
		var x:Float = px - ellX;
		var y:Float = py - ellY;
		var end:Float = ((x*x)/(a*a) + (y*y)/(b*b));
		return end <= 1;
	}
	
	/**
	 * 判断点是否在矩形内
	 * @return 
	 */
	public static function inInRect(px:Float,py:Float,rectX:Float,rectY:Float,rectWidth:Float=5,rectHeight:Float=5):Bool
	{
		return (px >= rectX && px <= (rectX + rectWidth) && py >= rectY && py <= (rectY + rectHeight));
	}
	
	/**
	 * 得到两点间连线的斜率 
	 * @param ponit1
	 * @param point2
	 */
	public static function getLineSlope( x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var res:Float = (y2 - y1) / (x2 - x1); 
		return res;
	}
	
	/**
	 * 通过两点计算其角度
	 * @return 介于负二分之 pi 和正二分之 pi 之间的一个数字
	 */
	public static function getAngleByPt( x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var r:Float = getLineSlope(x1, y1, x2, y2);
		var res:Float = Math.atan(r);
		return res;
	}
	
	/**
	 * 某点的延长线与某直线的交点
	 * @param p1		点1
	 * @param ra		点2延长线方向
	 * @param p3		另一线直线一点
	 * @param p4		另一条直线的另一点
	 * @return 
	 		
	public static function secExtPtLineNode(p1:Point,ra:Float,p3:Point,p4:Point):Point
	{
		var p2:Point = getExtPot(p1,10,ra);
		return secLineIntersect(p1,p2,p3,p4);
	}*/
	
	/**
	 * 两向量相交的点
	 * @param p1	点1
	 * @param ra1	点1的方向
	 * @param p2	点2
	 * @param ra2	点2的方向
	 * @return 
	 	
	public static function vector2Intersect(p1:Point,ra1:Float,p2:Point,ra2:Float):Point
	{
		var v1:UVector =  new UVector(p1.x,p1.y,ra1);
		var v2:UVector =  new UVector(p2.x,p2.y,ra2);
		return UVectorIntersect(v1,v2);
	}*/	
	
	/**
	 * 计算两线段交点
	 * @param p1 线段1的开始点
	 * @param p2 线段1的结束点
	 * @param p3 线段2的开始点
	 * @param p4 线段2的结束点
	 	
	public static function secLineIntersect(p1:Point,p2:Point,p3:Point,p4:Point):Point
	{
		if(secLineIsIntersect(p1,p2,p3,p4)){
			var v1:UVector =  new UVector(p1.x,p1.y,getRadianByPot(p1.x,p1.y,p2.x,p2.y));
			var v2:UVector =  new UVector(p3.x,p3.y,getRadianByPot(p3.x,p3.y,p4.x,p4.y));
			return UVectorIntersect(v1,v2);
		}else
			return null;
	}*/	
	
	/**
	 * 计算两斜线向量交点;直线向量公式 y=k*x+b;(k!=0)
	 * 原理:两条直线先分别求出公式里的b参数;然后两直线方程计算交点x,y
	 * @param v1
	 * @param v2
	 * @return 
	 
	public static function UVectorIntersect(v1:UVector,v2:UVector):Point
	{
		var k1:Float = Math.tan(v1.radian);
		var k2:Float = Math.tan(v2.radian);
		if(k1==k2) return null;	//平行线,无交点
		var b1:Float = (v1.y - v1.x*k1);
		var b2:Float = (v2.y - v2.x*k2);
		var px:Float = -1*(b1-b2)/(k1-k2);
		var py:Float = (k1*px + b1);
//			var px:Float = (v2.y - v1.y + k1*v1.x - k2*v2.x)/(k1-k2);
//			var py:Float = ((px - v2.x)==0)?(k1*(px - v1.x) + v1.y):(k2*(px - v2.x) + v2.y);
		return new Point(px,py);
	}*/
	
	/**
	 * 两线段是否相交
	 * @param p1 线段1的开始点
	 * @param p2 线段1的结束点
	 * @param p3 线段2的开始点
	 * @param p4 线段2的结束点
	 * @return 
	 */		
	public static function secLineIsIntersect(p1:Point,p2:Point,p3:Point,p4:Point):Bool
	{
		return Math.max(p1.x, p2.x)>=Math.min(p3.x, p4.x)
			&& Math.max(p1.y, p2.y)>=Math.min(p3.y, p4.y)
			&& Math.max(p3.x, p4.x)>=Math.min(p1.x, p2.x)
			&& Math.max(p3.y, p4.y)>=Math.min(p1.y, p2.y)
			&& mult(p3, p2, p1)*mult(p2, p4, p1)>=0
			&& mult(p1, p4, p3)*mult(p4, p2, p3)>=0;
	}
	
	//叉积(用于判断两线段是否相交)
	public static function mult(a:Point,b:Point,c:Point):Float
	{
		var res:Float = (a.x-c.x)*(b.y-c.y)-(b.x-c.x)*(a.y-c.y);
		return res;
	}
	
	
	/**
	 * 判断第三点pc是否在pa,pb组成的线的左侧还是右侧
	 * @param pa
	 * @param pb
	 * @param pc
	 * @return >0表示在左侧；＝0表示在线上；<0表示在右侧
	 */		
	public static function potInLR(pa:Point,pb:Point,pc:Point):Float
	{
		var res:Float = (pb.x - pa.x) * (pc.y - pa.y) - (pc.x - pa.x) * (pb.y - pa.y);
		return res;
	}
	
	/**
	 * 点到直接线的距离
	 * @param p1	线外的点
	 * @param lp1	线的起点
	 * @param lp2	线的终点
	 */
	public static function point2Line(p1:Point, lp1:Point, lp2:Point):Float
	{
		var a:Float, b:Float, c:Float;
		a = lp2.y - lp1.y;
		b = lp1.x - lp2.x;
		c = lp2.x * lp1.y - lp1.x * lp2.y;
		var d:Float = Math.abs(a * p1.x + b * p1.y + c) / Math.sqrt(a * a + b * b);
		return d;
	};
	
	/**
	 * 将0,1，true,false，转换成-1,1;
	 * @param num
	 */		
	public static function c01To1(num:Int):Int
	{
		return num*2-1;
	}
	
	/**
	 * 保留小数位
	 * @param index 保留的位数 ，0表示整数
	 */
	public static function floatDecimal(num:Float,index:Int=DEFAULT_DIGIT):Float
	{
		// 防止益出，如果要保留的位数太多，num2会很大，容易益出
		if (index < 4)
		{
			var num2:Float = Math.pow(10, index);
			return Math.round(num * num2) / num2;
		}
		
		var str:String = Std.string(num);
		var tid:Int = str.indexOf(".");
		if (tid < 0)
		return num;
		else
		return Std.parseFloat(str.substring(0, (tid + DEFAULT_DIGIT)));
	}
}