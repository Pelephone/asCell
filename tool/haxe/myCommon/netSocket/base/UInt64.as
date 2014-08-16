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
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package netSocket.base
{

	/**
	 * @author Michael.Huang
	 */
	public final class UInt64 extends Binary64
	{
		public final function set high(value:uint):void
		{
			internalHigh = value
		}

		public final function get high():uint
		{
			return internalHigh
		}

		public function UInt64(low:uint = 0, high:uint = 0)
		{
			super(low, high)
		}

		public function toString(radix:uint = 10):String
		{
			if (radix < 2 || radix > 36)
			{
				throw new ArgumentError
			}
			if (high == 0)
			{
				return low.toString(radix)
			}
			const digitChars:Array = [];
			const copyOfThis:UInt64 = new UInt64(low, high);
			do
			{
				const digit:uint = copyOfThis.div(radix);
				var s:String = digit < 10 ? '0' : 'a';
				digitChars.push(s.charCodeAt() + digit);
			} while (copyOfThis.high != 0)
			return copyOfThis.low.toString(radix) + String.fromCharCode.apply(String, digitChars.reverse())
		}

		public static function parseUInt64(str:String, radix:uint = 0):UInt64
		{
			var i:uint = 0
			if (radix == 0)
			{
				if (str.search(/^0x/) == 0)
				{
					radix = 16
					i = 2
				}
				else
				{
					radix = 10
				}
			}
			if (radix < 2 || radix > 36)
			{
				throw new ArgumentError
			}
			str = str.toLowerCase()
			const result:UInt64 = new UInt64
			for (; i < str.length; i++)
			{
				var digit:uint = str.charCodeAt(i)
				if (digit >= '0'.charCodeAt() && digit <= '9'.charCodeAt())
				{
					digit -= '0'.charCodeAt()
				}
				else if (digit >= 'a'.charCodeAt() && digit <= 'z'.charCodeAt())
				{
					digit -= 'a'.charCodeAt()
				}
				else
				{
					throw new ArgumentError
				}
				if (digit >= radix)
				{
					throw new ArgumentError
				}
				result.mul(radix)
				result.add(digit)
			}
			return result
		}
	}
}
