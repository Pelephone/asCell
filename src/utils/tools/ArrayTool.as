package utils.tools
{
	public class ArrayTool
	{
		// 使数组内的项乱序
		static public function randomSort(arr:Array,num:int=50):Array
		{
			for(var i:int=0;i<num;i++){
				var r1:int=Math.random()*arr.length,r2:int=Math.random()*arr.length,tmp:Object;
				tmp = arr[r1];
				arr[r1] = arr[r2];
				arr[r2] = tmp;
			}
			return arr;
		}
		
		//将{xx:yy,xx:yy}这样形式的数组转换为数组
		static public function strToArrObj(str:String):Array
		{
			if(str=="" || str==null) return null;
			var resArr:Array = new Array;
			var arr:Array = str.split(",");
			for(var i:int=0;i<arr.length;i++){
				var arr2:Array = arr[i].split(":");
				resArr.push({id:arr2[0],num:arr2[1]});
			}
			return resArr;
		}
		
		/**
		 * 将字段("1,2,3,4")串转换成int数组
		 * @param str
		 * @return 
		 */		
		static public function strToArrInt(str:String):Array
		{
			if(str=="" || str==null) return null;
			var resArr:Array = new Array;
			var arr:Array = str.split(",");
			for(var i:int=0;i<arr.length;i++){
				resArr.push(int(arr[i]));
			}
			return resArr;
		}
		
		/**
		 * 从数据中随机取出其中一个
		 * @param arr
		 * @return 
		 */
		static public function randomArrOne(arr:Array):*
		{
			if(!checkArr(arr)) return null;
			var randInt:int = Math.round(Math.random()*(arr.length-1));
			return arr[randInt];
		}
		
		static public function checkArr(arr:Array):Boolean
		{
			return (arr && arr.length);
		}
		
		/**
		 * 计算判断索引是否走出数组长度
		 * @param index
		 */
		public static function checkAryIndex(ary:Array,index:int=0):Boolean
		{
			if(!ary || index<0)
				return false;
			return (ary.length>index);
		}
		
		/**
		 * 将对象转数据
		 * @param obj
		 * @return 
		 */
		public static function toArray(obj:Object):Array {
			if (!obj) 
			{
				return [];
			} 
			else if (obj is Array)
			{
				return obj as Array;
			} 
			else if (obj is Vector.<*>) {
				var array:Array = new Array(obj.length);
				for (var i:int = 0; i < obj.length; i++) {
					array[i] = obj[i];
				}
				return array;
			} else {
				return [obj];
			}
		} 
		
		// 在hash中搜索指定元素
		static public function hashSearchArr(hash:Object, key:String, value:Object):Object{
			for each(var obj:Object in hash){
				if(obj[key] == value) return obj;
			}
			return null;
		}
		
		/**
		 * 判断两个数组是否每个元素都相等
		 * @param arr1
		 * @param arr2
		 */
		public static function arr1EqArr2(arr1:Array,arr2:Array):Boolean
		{
			if((!arr1 && !arr2) || (!arr1.length && !arr2.length))
				return true;
			else if(!arr1 || !arr2 || arr1.length != arr2.length)
				return false;
			
			for (var i:int = 0; i < arr1.length; i++) 
			{
				if(arr1[i] != arr2[i])
					return false;
			}
			return true;
		}
		
		/**
		 *  从数组里找属性为propName,值等于values参数其中一项的项数组
		 * 如果arr=[{name:1},{name:2},{name:3}]; arr2 = findArr(arr,"name",[2,3]) arr2为[{name:2},{name:3}]
		 * arr2 = findArr(arr,"name",2) 结果为{name:2}
		 */
		static public function findArr(arr:Array,propName:String,values:Object):*
		{
			if((values is Number) || (values is String) || !resArr.length){
				for each(var o:Object in arr){
					if(o[propName]==values) return o;
				}
				return null;
			}
			var resArr:Array = [];
			for each(o in arr){
				if(values.indexOf(o[propName])>=0) resArr.push(o);
			}
			return resArr;
		}
		
		// 统计该字段的数量
		static public function arrayCount(arr:Array, fid:String):int{
			var count:int = 0;
			for each(var obj:Object in arr){
				count += int( obj[fid] );
			}
			return count;
		}
		
		// 在数组中过滤元素, 查找符合条件的元素, 组合成新的数组
		static public function arrayFilter(list:Array, key_name:String, key_value:Object):Array{
			if(!list) return null;
			var arr:Array = new Array;
			for each(var obj:Object in list){
				if(obj[key_name]==key_value) arr.push( obj );
			}
			return arr;
		}
		
		// 在数组中差早某个元素, 并修改值, 返回是否成功修改了
		static public function arrayModify(list:Array, key_name:String, key_value:Object, key_name_set:String, key_value_set:Object):Boolean{
			if(!list) return false;
			var ele:Object = list[ indexOf(list, key_name, key_value) ];
			if(!ele) return false;
			ele[key_name_set] = key_value_set;
			return true;
		}
		
		/**
		 * 移除指定位置的某个元素,并返回
		 * @param arr
		 * @param index
		 * @return 
		 */
		public static function removeByIndex(arr:Array,index:int):*
		{
			return arr.splice(index, 1)[0];
		}
		
		// 在数组中删除某个元素, 返回被删除的元素
		static public function arrayRemove(list:Array, key_name:String, key_value:Object):Object{
			var index:int = indexOf(list, key_name, key_value);
			if(index < 0) return null;
			return list.splice(index, 1)[0]; 
		}
		
		// 在数组中搜索元素的位置, 属性名为 key_name, 属性值为 key_value
		static public function indexOf(list:Array, key_name:String, key_value:Object):int{
			if(!list) return -1;
			for(var i:int=0; i<list.length; i++){
				if(list[i] && list[i][key_name] == key_value) return i;
			}
			return -1;
		}
		
		// 选择数组中元素的某个字段, 组成新的数组 
		static public function arrayFiled(arr:Array, fid:String):Array{
			var ret:Array = [];
			for each(var obj:Object in arr){
				ret.push( obj[fid] );
			}
			return ret;
		}
		
		/**
		 * 清空数组
		 * @param arr 要清除的容器对象
		 * */
		static public function clearArr(arr:Array):void
		{
			if(arr==null) return;
			while(arr && arr.length){
				arr[0] = null;
				arr.shift();
			}
		}
		
		/**
		 * 将数组里面的所有元素转为整数
		 * @param arr
		 * @return arr
		 */		
		static public function arrToInt(arr:Array):Array
		{
			if(!arr) return null;
			for(var i:int=0;i<arr.length;i++)
				arr[i] = int(arr[i]);
			
			return arr;
		}
		
		/**
		 * 将字符通过splitStr分成数组，并将数组里面的所有元素转为整数
		 * @param str		要分数组的字符
		 * @param splitStr	字符与splitStr分开
		 * @return arr
		 */		
		static public function splitAndToInt(str:String,splitStr:String=","):Array
		{
			return arrToInt(str.split(splitStr));
		}
		
		/**
		 * 将字符通过splitStr分成数组，并将数组里面的所有元素转为整数
		 * @param str		要分数组的字符
		 * @param splitStr	字符与splitStr分开
		 * @return arr
		 */		
		static public function splitAndToInt2(str:String,splitStr:String=","):Vector.<int>
		{
			var res:Vector.<int> = new <int>[];
			if(!str)
				return res;
			var arr:Array = str.split(splitStr);
			for each (var itm:String in arr) 
			{
				res.push(itm);
			}
			return res;
		}
		
		/**
		 * 数组排序(冒泡算法), 稳定的
		 * @param list
		 * @param field
		 */		
		static public function array_sort(list:Array, field:String):void{
			
			// 冒泡排序, 稳定的(as 自带排序是非稳定的), 因为需要保持原来的先后次序, 之前是按时间排序的
			var len:int = list.length;
			for(var i:int=0; i<len; i++)
			{
				for(var j:int=0; j<len-i-1; j++)
				{
					if(list[j][field] > list[j+1][field])
					{
						var tmp:Object = list[j];
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
		public static function quickSort(arr:Array,low:int,high:int):void {
			var i:int;
			var j:int;
			var x:int;
			
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
		 * 消除数组里面相同,重复的元素
		 * @param arr
		 */		
		static public function clearSameArr(arr:Array):Array
		{
			for(var i:int=0;i<arr.length;i++){
				for(var j:int=(i+1);j<arr.length;j++){
					if(arr[i]==arr[j]){
						arr.splice(j,1);
						j--;
					}
				}
			}
			return arr;
		}
		
		/**
		 * 合并多个数组
		 * @param arrList
		 * @return 
		 */		
		static public function array_merge(...arrList):Array{
			var ret:Array = new Array;
			for each(var arr:Array in arrList){
				for each(var obj:Object in arr){
					ret.push( obj ); 
				}
			}
			return ret;
		}
		
		/**
		 * 合并多个数组, 并避免重复
		 * @param arrList
		 * @return 
		 */		
		static public function array_merge_no_repeat(...arrList):Array{
			var ret:Array = new Array;
			for each(var arr:Array in arrList){
				for each(var obj:Object in arr){
					if(ret.indexOf( obj ) < 0) ret.push( obj );
				}
			}
			return ret;
		}
		
		/**
		 * 移除数组里面项值==i的项
		 * @param i
		 * @return 移除后的数组
		 */		
		static public function removeItem(o:Object,arr:Array):Array
		{
			var tid:int = arr.indexOf(o);
			if(tid>=0)
				arr.splice(tid,1);
			return arr;
		}
		
		/**
		 * 判断两数组是否数据完全相同
		 * @return 
		 */		
		static public function isDataEq(arr1:Array,arr2:Array):Boolean
		{
			if(arr1.length!=arr2.length) return false;
			for(var i:int=0;i<arr1.length;i++){
				if(arr1[i] != arr2[i]) return false;
			}
			return true;
		}
		
		/**
		 * 通过比率换算出数组里数据<br/>
		 * @param arr
		 * @param ratio 0~1之间的数
		 */
		public static function getArrByRadio(arr:Array,ratio:Number):*
		{
			if(!arr || !arr.length) return null;
			if(arr.length==1) return arr[0];
			var index:int = Math.floor(ratio*(arr.length-1));
			return arr[index];
		}
	}
}