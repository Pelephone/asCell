package utils.tools;
/**
 * 随机工具
 * @author Pelephone
 */
class RandomTool
{
	/**
	 * 获取一个随机的布尔值
	 */
	public static function getBool():Bool{
		return Math.random() < .5;
	}
	
	/**
	 * 获取一个正负波动值
	 */
	public static function getWave():Int{
		return getBool() ? 1 : -1;
	}
	
	/**
	 * 获取一个随机的范围整数值
	 */
	public static function integer(value:Float):Int{
		return Math.floor(number(value));
	}
	
	/**
	 * 获取一个随机的范围Number值
	 */
	public static function number(value:Float):Float{
		return Math.random() * value;
	}
	
	/**
	 * 返回两值之间的随机数
	 */
	static public function randRange(min:Float, max:Float):Float
	{
		var randomNum:Float = Math.floor(Math.random() * (max - min + 1)) + min;
		return randomNum;
	}
	
	/**
	 * 在一个范围内获取一个随机值，返回结果范围：num1 >= num > num2
	 */
	public static function range(value1:Float,value2:Float,isInt:Bool = true):Float{
		var value:Float = number(value2 - value1) + value1;
		if(isInt) value = Math.floor(value);
		return value;
	}
	
	/**
	 * 获取一个随机字符，默认随机范围为数字+大小写字母，也可以指定范围，格式：a-z,A-H,5-9
	 
	public static function string(restrict:String = "0-9,A-Z,a-z"):String{
		return String.fromCharCode(randomRange(explain(restrict)));
	}*/
	
	/**
	 * 生成指定位数的随机字符串
	 
	public static function bit(value:Int,restrict:String = "0-9,A-Z,a-z"):String{
		var result:String = "";
		for(var i:Int = 0; i < value; i ++) result += string(restrict);
		return result;
	}*/
	
	/**
	 * 获取一个随机的颜色值
	 
	public static function color(red:String = "0-255", green:String = "0-255", blue:String = "0-255"):Int
	{
		return Number("0x" + transform(randomRange(explain(red,false))) +
							 transform(randomRange(explain(green,false))) +
							 transform(randomRange(explain(blue,false))));
	}*/
	
	/**
	 * 将10进制的RGB色转换为2位的16进制
	 */
	private static function transform(value:Int):String{
		var result:String = Std.string(16);
		if(result.length != 2) result = "0" + result;
		return result;
	}
	
	/**
	 * 字符串解析
	 
	private static function explain(restrict:String, isCodeAt:Bool = true):Array<Dynamic>
	{
		var result:Array<Dynamic> = [];
		var restrictList:Array<Dynamic> = restrict.split(",");
		var length:Int = restrictList.length;
		//for(var i:Int = 0; i < length; i ++){
		for (i in 0...length)
		{
			var list:Array<Dynamic> = restrictList[i].split("-");
			if(list.length == 2){
				var begin:String = list[0];
				var end:String = list[1];
				if(isCodeAt){
					begin = begin.charCodeAt().toString();
					end = end.charCodeAt().toString();
				}
				//此处如果不加1，将不会随机ar[1]所表示字符，因此需要加上1，随机范围才是对的
				result.push(Number(begin),Number(end) + 1);
			}else if(list.length == 1){
				var value:String = list[0];
				if(isCodeAt) value = value.charCodeAt().toString();
				//如果范围是1-2，那么整型随机必定是1，因此拿出第一个参数后，把范围定在参数+1，则就是让该参数参加随机
				result.push(Number(value),Number(value) + 1);
			}
			list = null;
		}
		restrictList = null;
		return result;
	}*/
	
	/**
	 * 获取随机范围
	 
	private static function randomRange(restrictList:Array):Float{
		var list:Array = new Array;
		var length:Int = restrictList.length;
		if(length % 2 != 0 || length == 0) throw new Error("参数错误！无法获取指定范围！");
		//将所有可能出现的随机数存入数组，然后进行随机
		for(var i:Int = 0; i < length / 2; i ++){
			var begin:Int = restrictList[i * 2];
			var end:Int = restrictList[i * 2 + 1];
			if(begin > end){
				var value:Float = begin;
				begin = end;
				end = value;
			}
			for(begin; begin < end; begin ++) list.push(begin);
		}
		var result:Float = list[integer(list.length)];
		list = null;
		return result;
	}*/

	/**
	 * 从数组中随机一个对象
	 */
	public static function randomArray<T>(ary:Array<T>):T
	{
		if (ary == null || ary.length == 0)
		return null;
		if (ary.length == 1)
		return ary[0];
		var tid:Int = Math.floor(Math.random() * ary.length);
		return ary[tid];
	}
	
	//---------------------------------------------------
	// 正态分布随机
	//---------------------------------------------------
	
	private static var c0:Float = 2.515517;
	private static var c1:Float = 0.802853;
	private static var c2:Float = 0.010328;
	private static var d1:Float = 1.432788;
	private static var d2:Float = 0.189269;
	private static var d3:Float = 0.001308;
	/**
	 * 正态分布的随机数.a控制波形的顶点,b控制波形的扁度
	 * @param a		如a是0即,随机出0的机率会大到-1,1,-2,2,然后递减
	 * @param b		如b是2即,随机出>-2和<2之间的数字机率最大(注意这里的b是方差，等于标准差的平方)
	 * @return 
	 */		
	public static function nextGaussian(a:Float, b:Float):Float
	{
		var f:Float = 0;
		var w:Float;
		var r:Float = Math.random();
		if (r <= 0.5) w = r;
		else w = 1 - r;
		if ((r - 0.5) > 0) f = 1;
		else if ((r - 0.5) < 0) f = -1;
		var y:Float = Math.sqrt((-2) * Math.log(w));
		var x:Float = f * (y - (c0 + c1 * y + c2 * y * y) / (1 + d1 * y + d2 * y * y + d3 * y * y * y));
		var z:Float = a + x * Math.sqrt(b);
		return (z);
	}
	
	/**
	 * 正态分布算法2,此算法是筛子的概念,ydx.掷筛子12次
	 * @param a
	 * @param b
	 * @return 
	 */
	public static function nextGaussian1(a:Float, b:Float):Float
	{
		var temp:Int = 12;
		var x:Float = 0;
		//for (var i:Int = 0; i < temp; i++)
		for (i in 0...temp)
			x = x + (Math.random());
		x = (x - temp / 2) / (Math.sqrt(temp / 12));
		x = a + x * Math.sqrt(b); return x;
	}
	/**
	 * 正态分布算法3,此算法用了两个随机数
	 * @param a
	 * @param b
	 * @return 
	 */
	public static function nextGaussian2(a:Float, b:Float):Float
	{
		var r1:Float = Math.random();
		var r2:Float = Math.random();
		var u:Float = Math.sqrt((-2) * Math.log(r1)) * Math.cos(2 * Math.PI * r2);
		var z:Float = a + u * Math.sqrt(b); return (z);
	}
	
	/**
	 * 随机数组，使数组乱序
	 * @param myArray
	 * @return 
	 */
	public static function randomizeArray(myArray:Array<Dynamic>,randomCount:Int=0):Array<Dynamic>
	{
		if (myArray.length <= 1)
		return myArray;
		if (randomCount == 0)
		randomCount = myArray.length;
		for (i in 0...randomCount)
		{
			var r1:Dynamic = Math.floor(Math.random() * myArray.length);
			var r2:Dynamic = Math.floor(Math.random() * myArray.length);
			var tmp:Int = myArray[r1];
			myArray[r1] = myArray[r2];
			myArray[r2] = tmp;
		}
		return myArray;
/*		myArray.sort(function(a:Dynamic, b:Dynamic):Int {
			return Math.round(Math.random() - 0.5);
			});
		return myArray;*/
	}
}