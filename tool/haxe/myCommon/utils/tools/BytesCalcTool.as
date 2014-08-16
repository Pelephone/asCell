/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES 
*/
package utils.tools
{
	
	/**
	 * 位运算工具
	 * @author Pelephone
	 */
	public class BytesCalcTool
	{
		public function BytesCalcTool()
		{
		}
		
		/**
		 * 判断val第index个二进制位是否是1
		 * @param _val
		 * @param _index
		 * @return 
		 */
		public static function hasAttribute(val:int, index:int):Boolean
		{
			return (val & (1 << index)) != 0;
		}
		
		/**
		 * 将布尔数组转成二进制的整型形式
		 * @param arr
		 */
		public static function arrToBytes(arr:Vector.<Boolean>):int
		{
			// 属性整数
			var result:int = 0;
			for (var i:int = 0; i < arr.length; i++)
			{
				var value:int = int(arr[i]);
				if(value!=0) value = 1;
				result = result | (value << i);
			}
			return result;
		}
		
		/**
		 * 将二进制整型还原成数组
		 * @param byteInt
		 * @return 
		 */
		public static function byteToArr(byteInt:int):Vector.<Boolean>
		{
			var res:Vector.<Boolean> = new Vector.<Boolean>();
			var str:String = byteInt.toString(2);
			for (var i:int = 0; i < str.length; i++) 
			{
				res.push(Boolean(str[i]));
			}
			return res;
		}
	}
}