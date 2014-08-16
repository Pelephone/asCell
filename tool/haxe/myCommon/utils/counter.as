package utils
{
	/**
	 * 计算类
	 * @author Pelephone
	 */
	public final class counter 
	{		
		//将数值比例转为百分比,num是小值,totNum是大值.
		static public function to100(num:int,totNum:int):int {
			if (num > totNum) return 0;
			return int(num * 100 / totNum);			
		}
		
		//
		static public function limit(val:int, min:int, max:int):int{
			return (val<min? min: val>max? max: val);
		}
		
		/** 用于取整数的位数，如2345，的第2位(十位)为4（从右向左）
		 * @param num 要取的数字
		 * @param pos 要取的开始位置
		 * @param len 长度
		 */
		static public function InterceptNum(num:int,pos:int=1,len:int=1):int
		{
			var tt:int=num%(Math.pow(10,pos));
			var res:int = int(tt/(Math.pow(10,(pos-len))));
			return res;
		}
	}	
}