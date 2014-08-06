package utils.tools
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	
	/**
	 * 颜色工具
	 */
	public class ColorTool
	{
		// 灰度色调
		static public const matrix_gray:Array = [0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0];
		static public const filter_gray:ColorMatrixFilter = new ColorMatrixFilter(matrix_gray);
		
		// 红色遮罩
		static public const matrix_red:Array = [
			0.5, 0, 0, 0, 127,
			0, 0.5, 0, 0, 0, 
			0, 0, 0.5, 0, 0,
			0, 0, 0, 1, 0];
		static public const filter_red:ColorMatrixFilter = new ColorMatrixFilter(matrix_red);
		
		/**
		 * 添加/删除 滤镜到控件中, 使控件改变色调
		 * @param disp			被添加/删除的目标窗口
		 * @param filter		被添加/删除的滤镜
		 * @param addRemove		true=添加, false=删除
		 */
		static public function applyFilter_colorMatrix(disp:DisplayObject, filter:ColorMatrixFilter, addRemove:Boolean):void{
			if(!disp || !filter) return;			
			var filters:Array = disp.filters;
			
			// remove
//			var index:int = filters.indexOf(filter);
//			if(index >= 0) filters.splice(index, 1);
			for(var i:int=0; i<filters.length; ){
				if(filters[i] is ColorMatrixFilter) filters.splice(i, 1);
				else i++;
			}
			
			// add
			if(addRemove) filters.push( filter );
			
			// assign
			disp.filters = filters; 
		}
		
		/**
		 * 添加/删除 灰色滤镜, 加入灰色滤镜后, 控件显示 黑白 单色而非彩色
		 * @param disp			被添加/删除的目标窗口
		 * @param addRemove		true=添加, false=删除
		 */
		static public function applyFilter_gray(disp:DisplayObject, addRemove:Boolean):void{
			ColorTool.applyFilter_colorMatrix( disp, ColorTool.filter_gray, addRemove );
		}
		
		/**
		 * 设置容器颜色
		 * @param sp 要设置颜色的MC
		 * @param color	要设置的颜色
		 * @param light 亮度默认为0.1
		 */
		static public function setSpColor(sp:DisplayObject,color:uint,light:Number=0.1):void
		{
			sp.filters = [getColorFilter(color,light)];
		}
		
		/**
		 * 获取颜色滤镜
		 * @param color
		 * @param ligtht
		 */		
		static public function getColorFilter(color:uint,ligtht:Number=0.1):ColorMatrixFilter
		{
			var colorTrans:ColorTransform = new ColorTransform();
			colorTrans.color = color;
			var colorArr:Array = [ colorTrans.redOffset/255, ligtht, ligtht, 0, 0,
				ligtht, colorTrans.greenOffset/255, ligtht, 0, 0,
				ligtht, ligtht, colorTrans.blueOffset/255, 0, 0,
				0, 0, 0, 1, 0];
			var colorFilter:ColorMatrixFilter = new ColorMatrixFilter(colorArr);
			return colorFilter;
		}
		
		/**
		 * 添加红色滤镜
		 */
		static public function applyFilter_red(disp:DisplayObject, addRemove:Boolean):void{
			ColorTool.applyFilter_colorMatrix( disp, ColorTool.filter_red, addRemove );
		}
		
		/**
		 * 通过RGB三色色值计算返回十六进制色值
		 * @param rr red channel
		 * @param gg green channel
		 * @param bb blue channel
		 */
		public static function getRGBWith(rr:uint, gg:uint, bb:uint):uint
		{
			var r:uint = rr;
			var g:uint = gg;
			var b:uint = bb;
			if(r > 255){
				r = 255;
			}
			if(g > 255){
				g = 255;
			}
			if(b > 255){
				b = 255;
			}
			var color_n:uint = (r<<16) + (g<<8) +b;
			return color_n;
		}
		
		
		
		
		
		
		
		/**
		 * 颜色叠加
		 * @param param1
		 * @param param2
		 * @param param3
		 */
		public static function interpolateColor(param1:uint, param2:uint, param3:Number) : uint
		{
			var _loc_4:* = 1 - param3;
			var _loc_5:* = param1 >> 24 & 255;
			var _loc_6:* = param1 >> 16 & 255;
			var _loc_7:* = param1 >> 8 & 255;
			var _loc_8:* = param1 & 255;
			var _loc_9:* = param2 >> 24 & 255;
			var _loc_10:* = param2 >> 16 & 255;
			var _loc_11:* = param2 >> 8 & 255;
			var _loc_12:* = param2 & 255;
			var _loc_13:* = _loc_5 * _loc_4 + _loc_9 * param3;
			var _loc_14:* = _loc_6 * _loc_4 + _loc_10 * param3;
			var _loc_15:* = _loc_7 * _loc_4 + _loc_11 * param3;
			var _loc_16:* = _loc_8 * _loc_4 + _loc_12 * param3;
			var _loc_17:* = _loc_13 << 24 | _loc_14 << 16 | _loc_15 << 8 | _loc_16;
			return _loc_13 << 24 | _loc_14 << 16 | _loc_15 << 8 | _loc_16;
		}// end function
		
		/**
		 * 颜色发光
		 * @param param1
		 * @param param2
		 * @return 
		 */
		public static function brightenColor(param1:Number, param2:Number) : Number
		{
			if (isNaN(param2))
			{
				param2 = 0;
			}
			if (param2 > 100)
			{
				param2 = 100;
			}
			if (param2 < 0)
			{
				param2 = 0;
			}
			var _loc_3:* = param2 / 100;
			var _loc_4:* = hexToRgb(param1);
			hexToRgb(param1).r = hexToRgb(param1).r + (255 - _loc_4.r) * _loc_3;
			_loc_4.b = _loc_4.b + (255 - _loc_4.b) * _loc_3;
			_loc_4.g = _loc_4.g + (255 - _loc_4.g) * _loc_3;
			return rgbToHex(Math.round(_loc_4.r), Math.round(_loc_4.g), Math.round(_loc_4.b));
		}// end function
		
		/**
		 * 颜色变暗
		 * @param param1
		 * @param param2
		 */
		public static function darkenColor(param1:Number, param2:Number) : Number
		{
			if (isNaN(param2))
			{
				param2 = 0;
			}
			if (param2 > 100)
			{
				param2 = 100;
			}
			if (param2 < 0)
			{
				param2 = 0;
			}
			var _loc_3:* = 1 - param2 / 100;
			var _loc_4:* = hexToRgb(param1);
			hexToRgb(param1).r = hexToRgb(param1).r * _loc_3;
			_loc_4.b = _loc_4.b * _loc_3;
			_loc_4.g = _loc_4.g * _loc_3;
			return rgbToHex(Math.round(_loc_4.r), Math.round(_loc_4.g), Math.round(_loc_4.b));
		}// end function
		
		public static function rgbToHex(param1:Number, param2:Number, param3:Number) : Number
		{
			return param1 << 16 | param2 << 8 | param3;
		}// end function
		
		/**
		 * 把十六进制色转成RGB颜色
		 * @param param1
		 */
		public static function hexToRgb(param1:Number) : Object
		{
			return {r:(param1 & 16711680) >> 16, g:(param1 & 65280) >> 8, b:param1 & 255};
		}// end function
		
		/**
		 * 颜色发光
		 * @param param1
		 * @return 
		 */
		public static function brightness(param1:Number) : Number
		{
			var _loc_2:* = 0;
			var _loc_3:* = hexToRgb(param1);
			if (_loc_3.r > _loc_2)
			{
				_loc_2 = _loc_3.r;
			}
			if (_loc_3.g > _loc_2)
			{
				_loc_2 = _loc_3.g;
			}
			if (_loc_3.b > _loc_2)
			{
				_loc_2 = _loc_3.b;
			}
			_loc_2 = _loc_2 / 255;
			return _loc_2;
		}// end function
		
		/**
		 * 颜色转换
		 * @param param1
		 * @param param2
		 * @param param3
		 */
		public static function colorTransform(param1:uint = 0, param2:Number = 1, param3:Number = 1) : ColorTransform
		{
			param2 = param2 > 1 ? (1) : (param2 < 0 ? (0) : (param2));
			param3 = param3 > 1 ? (1) : (param3 < 0 ? (0) : (param3));
			var _loc_4:* = (param1 >> 16 & 255) * param2;
			var _loc_5:* = (param1 >> 8 & 255) * param2;
			var _loc_6:* = (param1 & 255) * param2;
			var _loc_7:* = 1 - param2;
			return new ColorTransform(_loc_7, _loc_7, _loc_7, param3, _loc_4, _loc_5, _loc_6, 0);
		}// end function
		
		/**
		 * 减去
		 * @param param1
		 * @param param2
		 */
		public static function subtract(param1:int, param2:int) : int
		{
			var _loc_3:* = toRGB(param1);
			var _loc_4:* = toRGB(param2);
			var _loc_5:* = Math.max(Math.max(_loc_4[0] - (256 - _loc_3[0]), _loc_3[0] - (256 - _loc_4[0])), 0);
			var _loc_6:* = Math.max(Math.max(_loc_4[1] - (256 - _loc_3[1]), _loc_3[1] - (256 - _loc_4[1])), 0);
			var _loc_7:* = Math.max(Math.max(_loc_4[2] - (256 - _loc_3[2]), _loc_3[2] - (256 - _loc_4[2])), 0);
			return _loc_5 << 16 | _loc_6 << 8 | _loc_7;
		}// end function
		
		/**
		 * 叠加
		 * @param param1
		 * @param param2
		 */
		public static function sum(param1:int, param2:int) : int
		{
			var _loc_3:Array = toRGB(param1);
			var _loc_4:Array = toRGB(param2);
			var _loc_5:int = Math.min(_loc_3[0] + _loc_4[0], 255);
			var _loc_6:int = Math.min(_loc_3[1] + _loc_4[1], 255);
			var _loc_7:int = Math.min(_loc_3[2] + _loc_4[2], 255);
			return _loc_5 << 16 | _loc_6 << 8 | _loc_7;
		}// end function
		
		public static function sub(param1:uint, param2:uint) : uint
		{
			var _loc_3:* = toRGB(param1);
			var _loc_4:* = toRGB(param2);
			var _loc_5:* = Math.max(_loc_3[0] - _loc_4[0], 0);
			var _loc_6:* = Math.max(_loc_3[1] - _loc_4[1], 0);
			var _loc_7:* = Math.max(_loc_3[2] - _loc_4[2], 0);
			return _loc_5 << 16 | _loc_6 << 8 | _loc_7;
		}// end function
		
		public static function min(param1:uint, param2:uint) : uint
		{
			var _loc_3:* = toRGB(param1);
			var _loc_4:* = toRGB(param2);
			var _loc_5:* = Math.min(_loc_3[0], _loc_4[0]);
			var _loc_6:* = Math.min(_loc_3[1], _loc_4[1]);
			var _loc_7:* = Math.min(_loc_3[2], _loc_4[2]);
			return _loc_5 << 16 | _loc_6 << 8 | _loc_7;
		}// end function
		
		public static function max(param1:uint, param2:uint) : uint
		{
			var _loc_3:* = toRGB(param1);
			var _loc_4:* = toRGB(param2);
			var _loc_5:* = Math.max(_loc_3[0], _loc_4[0]);
			var _loc_6:* = Math.max(_loc_3[1], _loc_4[1]);
			var _loc_7:* = Math.max(_loc_3[2], _loc_4[2]);
			return _loc_5 << 16 | _loc_6 << 8 | _loc_7;
		}// end function
		
		public static function rgb(param1:uint, param2:uint, param3:uint) : uint
		{
			return param1 << 16 | param2 << 8 | param3;
		}// end function
		
		public static function rgbArray(param1:Array) : uint
		{
			return rgb(param1[0] as uint, param1[1] as uint, param1[2] as uint);
		}// end function
		
		public static function hsv(param1:int, param2:Number, param3:Number) : uint
		{
			return rgb.apply(null, HSVtoRGB(param1, param2, param3));
		}// end function
		
		public static function toRGB(param1:int) : Array
		{
			var _loc_2:* = param1 >> 16 & 255;
			var _loc_3:* = param1 >> 8 & 255;
			var _loc_4:* = param1 & 255;
			return [_loc_2, _loc_3, _loc_4];
		}// end function
		
		/**
		 * hsv转rgb
		 */
		public static function HSVtoRGB(h:Number, s:Number, v:Number) : Array
		{
			var _loc_7:* = NaN;
			var _loc_8:* = NaN;
			var _loc_9:* = NaN;
			var _loc_10:* = NaN;
			var _loc_4:* = 0;
			var _loc_5:* = 0;
			var _loc_6:* = 0;
			if (s < 0)
			{
				s = 0;
			}
			if (s > 1)
			{
				s = 1;
			}
			if (v < 0)
			{
				v = 0;
			}
			if (v > 1)
			{
				v = 1;
			}
			h = h % 360;
			if (h < 0)
			{
				h = h + 360;
			}
			h = h / 60;
			_loc_7 = h >> 0;
			_loc_8 = v * (1 - s);
			_loc_9 = v * (1 - s * (h - _loc_7));
			_loc_10 = v * (1 - s * (1 - h + _loc_7));
			switch(_loc_7)
			{
				case 0:
				{
					_loc_4 = v;
					_loc_5 = _loc_10;
					_loc_6 = _loc_8;
					break;
				}
				case 1:
				{
					_loc_4 = _loc_9;
					_loc_5 = v;
					_loc_6 = _loc_8;
					break;
				}
				case 2:
				{
					_loc_4 = _loc_8;
					_loc_5 = v;
					_loc_6 = _loc_10;
					break;
				}
				case 3:
				{
					_loc_4 = _loc_8;
					_loc_5 = _loc_9;
					_loc_6 = v;
					break;
				}
				case 4:
				{
					_loc_4 = _loc_10;
					_loc_5 = _loc_8;
					_loc_6 = v;
					break;
				}
				case 5:
				{
					_loc_4 = v;
					_loc_5 = _loc_8;
					_loc_6 = _loc_9;
					break;
				}
				default:
				{
					break;
				}
			}
			return [_loc_4 * 255 >> 0, _loc_5 * 255 >> 0, _loc_6 * 255 >> 0];
		}// end function
	}
}