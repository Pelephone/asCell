package utils.tools;
class ArrayTool
{
	/**
	 * 使数组内的项乱序
	 * @param	arr 待乱序的数组
	 * @param	num 随机次数
	 * @return
	 */ 
	static public function randomSort(arr:Array<Dynamic>, num:Int = 50):Array<Dynamic>
	{
		//for(var i:Int=0;i<num;i++){
		for (i in 0...arr.length)
		{
			var r1:Int = Std.int(Math.random() * arr.length);
			var r2:Int = Std.int(Math.random() * arr.length);
			var tmp:Dynamic = arr[r1];
			arr[r1] = arr[r2];
			arr[r2] = tmp;
		}
		return arr;
	}
	
	/**
	 * 将字段("1,2,3,4")串转换成int数组
	 * @param str 要被拆分的字符
	 * @param splitStr 
	 * @return 
	 */		
	static public function strToArrInt(str:String,splitStr:String=","):Array<Int>
	{
		if(str=="" || str==null) return null;
		var resArr:Array<Int> = [];
		var arr:Array<String> = str.split(splitStr);
		for (i in 0...arr.length)
		{
			resArr.push(Std.parseInt(arr[i]));
		}
		return resArr;
	}
	
	/**
	 * 从数据中随机取出其中一个
	 * @param arr
	 * @return 
	 */
	static public function randomArrOne(arr:Array<Dynamic>):Dynamic
	{
		if (!checkArr(arr))
		return null;
		
		var randInt:Int = Math.round(Math.random()*(arr.length-1));
		return arr[randInt];
	}
	
	/**
	 * 检验数组是否有数据
	 * @param	arr
	 * @return
	 */
	static public function checkArr(arr:Array<Dynamic>):Bool
	{
		return (arr != null && arr.length > 0);
	}
	
	/**
	 * 计算判断索引是否走出数组长度
	 * @param index
	 */
	public static function checkAryIndex(ary:Array<Dynamic>,index:Int=0):Bool
	{
		if(ary == null || index<0)
			return false;
		return (ary.length>index);
	}
	
	/**
	 * 判断两个数组是否每个元素都相等
	 * @param arr1
	 * @param arr2
	 */
	public static function arr1EqArr2(arr1:Array<Dynamic>, arr2:Array<Dynamic>):Bool
	{
		if ((arr1 == null && arr2 == null) || (arr1.length == 0 && arr2.length == 0))
		return true;
		else if (arr1 == null || arr2 == null || arr1.length != arr2.length)
		return false;
		
		for (i in 0...arr1.length)
		{
			if (arr1[i] != arr2[i])
				return false;
		}
		return true;
	}
	
	/**
	 * 移除指定位置的某个元素,并返回
	 * @param arr
	 * @param index
	 * @return 
	 */
	public static function removeByIndex(arr:Array<Dynamic>,index:Int):Dynamic
	{
		return arr.splice(index, 1)[0];
	}
	
	/**
	 * 在数组中删除某个元素, 返回被删除的元素
	 * @param	list
	 * @param	value
	 * @return
	 */ 
	static public function arrayRemove(list:Array<Dynamic>, value:Dynamic):Dynamic
	{
		if (!checkArr(list))
		return null;
		return list.remove(value);
	}
	
	/**
	 * 在数组中搜索元素的位置, 存在此值返回位置，不存在则返回-1
	 * @param	list 被搜索的数组
	 * @param	value 要搜的元素
	 * @return
	 */ 
	static public function indexOf(list:Array<Dynamic>, value:Dynamic):Int
	{
		if (!checkArr(list))
		return -1;
		
		for (i in 0...list.length)
		{
			if (list[i] && list[i] == value)
			return i;
		}
		return -1;
	}
	
	
	/**
	 * 清空数组
	 * @param arr 要清除的容器对象
	 * */
	static public function clearArr(arr:Array<Dynamic>):Void
	{
		if (arr == null)
		return;
		
		while (arr != null && arr.length > 0)
		{
			arr.pop();
		}
	}
	
	/**
	 * 数组排序(冒泡算法), 稳定的
	 * @param list
	 * @param field
	 */		
	static public function array_sort(list:Array<Dynamic>):Void
	{
		// 冒泡排序, 稳定的(as 自带排序是非稳定的), 因为需要保持原来的先后次序, 之前是按时间排序的
		var len:Int = list.length;
		for(i in 0...len)
		{
			for(j in 0...(len-i-1))
			{
				if(list[j] > list[j+1])
				{
					var tmp:Dynamic = list[j];
					list[j] = list[j+1];
					list[j+1] = tmp; 
				}
			}
		}
	}
	
	
	
	/**
	 * 快速排序使用分治法（Divide and conquer）策略来把一个序列（list）分为两个子序列（sub-lists）。  
	 *  步骤为：  
	 * 1. 从数列中挑出一个元素，称为 "基准"（pivot），  
	 * 2. 重新排序数列，所有元素比基准值小的摆放在基准前面，所有元素比基准值大的摆在基准的后面（相同的数可以到任一边）。在这个分割之后，该基准是它的最后位置。这个称为分割（partition）操作。  
	 * 3. 递归地（recursive）把小于基准值元素的子数列和大于基准值元素的子数列排序。  
	 *  递回的最底部情形，是数列的大小是零或一，也就是永远都已经被排序好了。虽然一直递回下去，但是这个演算法总会结束，因为在每次的迭代（iteration）中，它至少会把一个元素摆到它最后的位置去。  
	 */ 		
	public static function quickSort(arr:Array<Dynamic>, low:Int, high:Int):Void
	{
		var i:Int;
		var j:Int;
		var x:Int;
		
		if (low < high) { //这个条件用来结束递归
			
			i = low;
			j = high;
			x = arr[i];
			
			while (i < j) {
				while (i < j && arr[j] > x) {
					j--; //从右向左找第一个小于x的数
				}
				if (i < j) {
					arr[i] = arr[j];
					i++;
				}
				
				while (i < j && arr[i] < x) {
					i++; //从左向右找第一个大于x的数
				}
				
				if (i < j) {
					arr[j] = arr[i];
					j--;
				}
			}
			
			arr[i] = x;
			quickSort(arr, low, i - 1);
			quickSort(arr, i + 1, high);
		}
	}
	
	/**
	 * 通过比率换算出数组里数据,意思是索引位置百分之几的位置
	 * @param arr
	 * @param ratio 0~1之间的数
	 */
	public static function getArrByRadio(arr:Array<Dynamic>, ratio:Float):Dynamic
	{
		if (!checkArr(arr))
		return null;
		
		if (arr.length == 1)
		return arr[0];
		
		var index:Int = Math.floor(ratio*(arr.length-1));
		return arr[index];
	}
}