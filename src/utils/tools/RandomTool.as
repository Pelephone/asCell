package utils.tools
{
	/**
	 * 随机工具
	 * @author Pelephone
	 */
	public final class RandomTool
	{
		/**
		 * 获取一个随机的布尔值
		 */
		public static function get boolean():Boolean{
			return Math.random() < .5;
		}
		
		/**
		 * 获取一个正负波动值
		 */
		public static function get wave():int{
			return boolean ? 1 : -1;
		}
		
		/**
		 * 获取一个随机的范围整数值
		 */
		public static function integer(value:Number):int{
			return Math.floor(number(value));
		}
		
		/**
		 * 获取一个随机的范围Number值
		 */
		public static function number(value:Number):Number{
			return Math.random() * value;
		}
		
		/**
		 * 返回两值之间的随机数
		 */
		static public function randRange(min:Number, max:Number):Number
		{
			var randomNum:Number = Math.floor(Math.random() * (max - min + 1)) + min;
			return randomNum;
		}
		
		/**
		 * 在一个范围内获取一个随机值，返回结果范围：num1 >= num > num2
		 */
		public static function range(value1:Number,value2:Number,isInt:Boolean = true):Number{
			var value:Number = number(value2 - value1) + value1;
			if(isInt) value = Math.floor(value);
			return value;
		}
		
		/**
		 * 在多个范围获取随机值
		 */
		public static function ranges(...args):Number{
			var isInt:Boolean = args[args.length - 1] is Boolean ? args.pop() : true;
			var value:Number = randomRange(args);
			if(!isInt) value += Math.random();
			return value;
		}
		
		/**
		 * 获取一个随机字符，默认随机范围为数字+大小写字母，也可以指定范围，格式：a-z,A-H,5-9
		 */
		public static function string(restrict:String = "0-9,A-Z,a-z"):String{
			return String.fromCharCode(randomRange(explain(restrict)));
		}
		
		/**
		 * 生成指定位数的随机字符串
		 */
		public static function bit(value:int,restrict:String = "0-9,A-Z,a-z"):String{
			var result:String = "";
			for(var i:int = 0; i < value; i ++) result += string(restrict);
			return result;
		}
		
		/**
		 * 获取一个随机的颜色值
		 */
		public static function color(red:String = "0-255",green:String = "0-255",blue:String = "0-255"):uint{
			return Number("0x" + transform(randomRange(explain(red,false))) +
								 transform(randomRange(explain(green,false))) +
								 transform(randomRange(explain(blue,false))));
		}
		
		/**
		 * 将10进制的RGB色转换为2位的16进制
		 */
		private static function transform(value:uint):String{
			var result:String = value.toString(16);
			if(result.length != 2) result = "0" + result;
			return result;
		}
		
		/**
		 * 字符串解析
		 */
		private static function explain(restrict:String,isCodeAt:Boolean = true):Array{
			var result:Array = new Array;
			var restrictList:Array = restrict.split(",");
			var length:uint = restrictList.length;
			for(var i:int = 0; i < length; i ++){
				var list:Array = restrictList[i].split("-");
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
		}
		
		/**
		 * 获取随机范围
		 */
		private static function randomRange(restrictList:Array):Number{
			var list:Array = new Array;
			var length:int = restrictList.length;
			if(length % 2 != 0 || length == 0) throw new Error("参数错误！无法获取指定范围！");
			//将所有可能出现的随机数存入数组，然后进行随机
			for(var i:int = 0; i < length / 2; i ++){
				var begin:int = restrictList[i * 2];
				var end:int = restrictList[i * 2 + 1];
				if(begin > end){
					var value:Number = begin;
					begin = end;
					end = value;
				}
				for(begin; begin < end; begin ++) list.push(begin);
			}
			var result:Number = list[integer(list.length)];
			list = null;
			return result;
		}

		/**
		 * 随机数组里面的其中一个
		 */
		public static function randAry(arr:Array):Object
		{
			if(!arr.length)
				return null;
			return arr[Math.floor(Math.random()*arr.length)];
		}
		
		/**
		 * 随机vector数组里面的其中一个
		 */
		public static function randVector(ary:Object):Object
		{
			if(!ary.length)
				return null;
			return ary[Math.floor(Math.random()*ary.length)];
		}
		
		//---------------------------------------------------
		// 正态分布随机
		//---------------------------------------------------
		
		private static const c0:Number = 2.515517;
		private static const c1:Number = 0.802853;
		private static const c2:Number = 0.010328;
		private static const d1:Number = 1.432788;
		private static const d2:Number = 0.189269;
		private static const d3:Number = 0.001308;
		/**
		 * 正态分布的随机数.a控制波形的顶点,b控制波形的扁度
		 * @param a		如a是0即,随机出0的机率会大到-1,1,-2,2,然后递减
		 * @param b		如b是2即,随机出>-2和<2之间的数字机率最大(注意这里的b是方差，等于标准差的平方)
		 * @return 
		 */		
		public static function nextGaussian(a:Number, b:Number):Number
		{
			var f:Number = 0;
			var w:Number;
			var r:Number = Math.random();
			if (r <= 0.5) w = r;
			else w = 1 - r;
			if ((r - 0.5) > 0) f = 1;
			else if ((r - 0.5) < 0) f = -1;
			var y:Number = Math.sqrt((-2) * Math.log(w));
			var x:Number = f * (y - (c0 + c1 * y + c2 * y * y) / (1 + d1 * y + d2 * y * y + d3 * y * y * y));
			var z:Number = a + x * Math.sqrt(b);
			return (z);
		}
		
		/**
		 * 正态分布算法2,此算法是筛子的概念,ydx.掷筛子12次
		 * @param a
		 * @param b
		 * @return 
		 */
		public static function nextGaussian1(a:Number, b:Number):Number
		{
			var temp:Number = 12;
			var x:Number = 0;
			for (var i:int = 0; i < temp; i++)
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
		public static function nextGaussian2(a:Number, b:Number):Number
		{
			var r1:Number = Math.random();
			var r2:Number = Math.random();
			var u:Number = Math.sqrt((-2) * Math.log(r1)) * Math.cos(2 * Math.PI * r2);
			var z:Number = a + u * Math.sqrt(b); return (z);
		}
		
		/**
		 * 随机数组，使数组乱序
		 * @param myArray
		 * @return 
		 */
		public static function randomizeArray(myArray:Array):Array
		{
			myArray.sort(function():int{return Math.random()-0.5; });
			return myArray;
		}
	}
}