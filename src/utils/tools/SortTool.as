package utils.tools
{
	/**
	 * 排序工具
	 * @author Pelephone
	 */	
	public class SortTool
	{
		/**
		 * 普通的冒泡排序
		 * @param arr
		 */
		public static function bubbleSort(arr:Array):void
		{
			var len:int = arr.length;
			for (var i:int = 0; i < len; i++)
			{
				for (var j:int = i + 1; j < len; j++)
				{
					if (arr[i] < arr[j])
					{
						var t:* = arr[i];
						arr[i] = arr[j];
						arr[j] = t;
					}
				}
			}
		}
		
		/**
		 * 冒泡排序优化
		 * @param arr
		 */
		public static function bubblesSortPlus(arr:Array):void
		{
			var end:int = arr.length -1;
			while (end > 0)
			{
				var k:int = 0;
				for (var i:int = 0; i < end; i++)
				{
					if (arr[i] < arr[i + 1])
					{
						var t:* = arr[i];
						arr[i] = arr[i + 1];
						arr[i + 1] = t;
						k = i;
					}
				}
				end = k;
			}
		}
		
		/**
		 * 插入排序
		 * @param arr
		 */
		public static function insertionSortArr(arr:Array):void
		{
			var i:int = 1;
			var n:int = arr.length;
			
			for(i=1;i<n;i++) {
				var temp:Number = arr[i];
				var j:int = i - 1;
				
				while((j>=0) && (arr[j] > temp)) {
					arr[j+1] = arr[j];  
					j--;
				}
				
				arr[j+1] = temp;
			}
		}
		
		/**
		 快速排序使用分治法（Divide and conquer）策略来把一个序列（list）分为两个子序列（sub-lists）。  
		 (快速排序的效率比Array.onSort还高)
		 步骤为：  
		 
		 1. 从数列中挑出一个元素，称为 "基准"（pivot），  
		 2. 重新排序数列，所有元素比基准值小的摆放在基准前面，所有元素比基准值大的摆在基准的后面（相同的数可以到任一边）。在这个分割之后，该基准是它的最后位置。这个称为分割（partition）操作。  
		 3. 递归地（recursive）把小于基准值元素的子数列和大于基准值元素的子数列排序。  
		 
		 递回的最底部情形，是数列的大小是零或一，也就是永远都已经被排序好了。虽然一直递回下去，但是这个演算法总会结束，因为在每次的迭代（iteration）中，它至少会把一个元素摆到它最后的位置去。  
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
		 选择排序是这样实现的：  
		 1.首先在未排序序列中找到最小元素，存放到排序序列的起始位置  
		 2.然后，再从剩余未排序元素中继续寻找最小元素，然后放到排序序列末尾。  
		 3.以此类推，直到所有元素均排序完毕。  
		 */  
		public static function selectionSort(result:Array):Array {
			var i:int = 0;
			var j:int = 0;
			var n:int = result.length;
			
			for (i = 0; i < n - 1; i++) {
				var min:int = i;
				for (j = i+1; j < n; j++) {
					if (result[j] < result[min]) {
						min = j;
					}
				}
				/* swap data[i] and data[min] */  
				var temp:Number = result[i];
				result[i] = result[min];
				result[min] = temp;
			}
			
			return result;
		}  
		
		/**
		 鸡尾酒排序，也就是定向冒泡排序, 鸡尾酒搅拌排序, 搅拌排序 (也可以视作选择排序的一种变形), 涟漪排序, 来回排序 or 快乐小时排序,
		 是冒泡排序的一种变形。此算法与冒泡排序的不同处在于排序时是以双向在序列中进行排序。  
		 */     
		public static function cocktailSortArr(result:Array):Array {
			var i:int = 0;
			var n:int = result.length;
			var top:int = n - 1;
			var bottom:int = 0;
			var swapped:Boolean = true; 
			
			while(swapped) { // if no elements have been swapped, then the list is sorted
				swapped = false; 
				var temp:Number;
				for(i = bottom; i < top;i++) {
					if(result[i] > result[i + 1]) {  // test whether the two elements are in the correct order
						temp = result[i];// let the two elements change places
						result[i] = result[i + 1];
						result[i + 1] = temp;
						swapped = true;
					}
				}
				// decreases top the because the element with the largest value in the unsorted
				// part of the list is now on the position top 
				top = top - 1; 
				for(i = top; i > bottom;i--) {
					if(result[i] < result[i - 1]) {
						temp = result[i];
						result[i] = result[i - 1];
						result[i - 1] = temp;
						swapped = true;
					}
				}
				// increases bottom because the element with the smallest value in the unsorted 
				// part of the list is now on the position bottom 
				bottom = bottom + 1;  
			}
			
			return result;
		}
	}
}