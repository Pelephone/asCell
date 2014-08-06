package utils.tools
{
	/**
	 * 时间日期工具
	 * @author Pelephone
	 */
	public class DateTool
	{
		/**
		 * 系统当前时间毫秒数
		 */
		public static function currentTimeMillis():Number
		{
			return (new Date()).getTime();
		}
		
		/**
		 * 将时间戳转换成Date对象
		 */		
		public static function time2Date(time:Number):Date{
			return new Date(time*1000);
		}
		
		/**
		 * 将Date转换成时间戳
		 */	
		public static function date2Time(da:Date):int
		{
			return da.time/1000;
		}
		
		/**
		 * 通过Date格式化时间
		 * @param date		要格式化的Date对像
		 * @param formatStr	格式字符
		 */		
		static public function dateFormat(date:Date,formatStr:String="y-m-d h:i:s"):String
		{
			var myPattern:RegExp = /y/gi;	//匹配所有y字母换成年
			formatStr = formatStr.replace(myPattern,date.getFullYear());
			myPattern = /m/gi;//匹配所有m字母换成月
			formatStr = formatStr.replace(myPattern,(date.getMonth()+1));
			myPattern = /d/gi;//匹配所有d字母换成日
			formatStr = formatStr.replace(myPattern,(date.getDate()));
			myPattern = /h/gi;//匹配所有h字母换成小时
			formatStr = formatStr.replace(myPattern,(date.getHours()));
			myPattern = /i/gi;//匹配所有i字母换成分
			formatStr = formatStr.replace(myPattern,(date.getMinutes()));
			myPattern = /s/gi;//匹配所有s字母换成秒
			formatStr = formatStr.replace(myPattern,(date.getSeconds()));
			myPattern = /t/gi;//匹配所有s字母换成秒
			formatStr = formatStr.replace(myPattern,(date.getTime()/1000));
			return formatStr;
		}
		
		/**
		 * 通过时间戳转换时间格式
		 * @param time 时间戳(单位秒)
		 * @param formatStr
		 */		
		static public function timeFormat(time:int,formatStr:String="y-m-d h:i:s"):String
		{
			return dateFormat((new Date(time*1000)),formatStr);
		}
		
		/**
		 *  格式化剩余的时间  X天 X个月
		 */
		static public function formatLeaveTime(time:uint) : String
		{
			var leaveTime:uint = uint(time);
			var leaveTime_str:String = "";
			var val:int;
			if (leaveTime >= 60*60*24*30) {
				leaveTime_str +=  Math.floor(leaveTime / (60*60*24*30))+"个月";
				if ((leaveTime % (60*60*24*30)) >= 60*60*24) {
					val = Math.floor((leaveTime % (60*60*24*30)) / (60*60*24));
					leaveTime_str += val+"天";
				}
			} else if (leaveTime >= 60*60*24) {
				leaveTime_str += Math.floor(leaveTime / (60*60*24)) + "天";
				if ((leaveTime % (60*60*24)) >= 60*60) {
					val = Math.floor((leaveTime % (60*60*24)) / (60*60));
					leaveTime_str +=  val+"小时";
				}
			} else if (leaveTime >= 60*60) {
				leaveTime_str += Math.floor(leaveTime / (60*60))+"小时";
				if ((leaveTime % (60*60)) >= 60) {
					val = Math.floor((leaveTime % (60*60)) / 60);
					leaveTime_str += val+"分钟";
				}
			} else if (leaveTime >= 60) {
				leaveTime_str += Math.floor(leaveTime / 60)+"分钟";
			} else {
				leaveTime_str += leaveTime+"秒"
			} 
			return leaveTime_str;
		}
		
		/**
		 * 格式化剩余时间
		 * @param time (单位秒)
		 */
		public static function formatLeaveTime2(time:int):String
		{
			var h:uint = time/(60*60);
			var m:uint = (time%(60*60))/60;
			var s:uint = time%(60*60*60);
			var hstr:String = (h<10)?("0"+h):h.toString();
			var mstr:String = (m<10)?("0"+m):m.toString();
			var sstr:String = (s<10)?("0"+s):s.toString();
			return h+":"+m+":"+s;
		}
		
		/**
		 * 将"XXXX-XX-XX XX:XX:XX"形式的日期转化为Data类型。
		 * @param "XXXX-XX-XX XX:XX:XX"形式的字符串
		 * */
		static public function StringToDate(s:String):Date
		{
			if(s==null || s=="") return null;
			
			var Sarr:Array = s.split(" ");
			if(Sarr.length!=2) return null;
			
			var Darr:Array = (Sarr[0] as String).split("-");
			if(Darr.length!=3) return null;
			
			var Tarr:Array = (Sarr[1] as String).split(":");
			if(Tarr.length!=3) return null;
			
			var da:Date = new Date(Darr[0],Darr[1],Darr[2],Tarr[0],Tarr[1],Tarr[2]);
			return da;
		}
		
		/**
		 * 将Data类型转为字符类型
		 * @param d 日期类型
		 * */
		static public function DateToString(d:Date):String
		{
			var y:String 	= d.fullYear.toString();
			var m:String 	= d.month.toString();
			var day:String	= d.day.toString();
			var h:String	= d.hours.toString();
			var mi:String	= d.minutes.toString();
			var se:String	= d.seconds.toString();
			
			var s:String = y+"-"+m+"-"+day+" "+h+":"+mi+":"+se+"";
			
			return s;
		}
	}
}