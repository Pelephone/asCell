package astar
{
	/**
	 * 二叉堆（数据结构）<br>
	 * 由平衡树构成，父节点永远是子节点的最小值<br>
	 * 当一个父节点被移走，子节点的最小值取代父节点<br>
	 * 这个数据结构的好处在于，当在一个庞大的数组中，要取最小值时，不需要去遍历
	 * @author Pelephone
	 */
	public class BinaryHeap
	{
		public var ls:Array = [];
		
		/**
		 * 比较元素大小的函数
		 */
		private var justMinFun:Function = function(x:Object, y:Object):Boolean
		{
			return x < y;
		};

		public function BinaryHeap(justMinFun:Function = null)
		{
			ls[0] = -1;
			if (justMinFun != null)
				this.justMinFun = justMinFun;
		}

		/**
		 * 添加新数据
		 * @param value
		 */
		public function push(value:Object):void
		{
			update(ls.length,value);
		}
		
		/**
		 * 修改指定索引项设新值
		 * @param index
		 * @param value
		 */
		private function update(index:int,value:Object):void
		{
			ls[index] = value;
			var tmpIndex:int = index >> 1;
			// 向上冒泡
			while (index > 1 && justMinFun(ls[index], ls[tmpIndex]))
			{
				var temp:Object = ls[index];
				ls[index] = ls[tmpIndex];
				ls[tmpIndex] = temp;
				index = tmpIndex;
				tmpIndex = index >> 1; // tmpIndex = index * 0.5;
			}
		}

		/**
		 * 取出开启列表中第一个元素,即最小的元素
		 * @return 
		 */
		public function shift():Object
		{
			var min:Object = ls[1];
			ls[1] = ls[ls.length - 1];
			ls.pop();
			var p:int = 1;
			var l:int = ls.length;
			var sp1:int = p << 1; // var sp1:int = p * 2;
			var sp2:int = sp1 + 1;
			while (sp1 < l){
				if (sp2 < l){
					var minp:int = justMinFun(ls[sp2], ls[sp1]) ? sp2 : sp1;
				} else {
					minp = sp1;
				}
				if (justMinFun(ls[minp], ls[p])){
					var temp:Object = ls[p];
					ls[p] = ls[minp];
					ls[minp] = temp;
					p = minp;
					sp1 = p << 1; // sp1 = p * 2;
					sp2 = sp1 + 1;
				} else {
					break;
				}
			}
			return min;
		}
		
		/**
		 * 长度
		 * @return 
		 */
		public function get length():int 
		{
			return ls.length - 1;
		}
	}
}