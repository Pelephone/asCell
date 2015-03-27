package utils.tools;
/**
 * 时间日期工具
 * @author Pelephone
 */
class DateTool
{
	/**
	 * 系统当前时间毫秒数
	 */
	public static function currentTimeMillis():Float
	{
		return (Date.now()).getTime();
	}
	
	/**
	 * 将时间戳转换成Date对象
	 */		
	public static function time2Date(time:Float):Date {
		return Date.fromTime(time * 1000);
	}
	
	/**
	 * 将Date转换成时间戳
	 */	
	public static function date2Time(da:Date):Int
	{
		return Math.round(da.getTime()/1000);
	}
	
	/**
	 * 通过Date格式化时间
	 * @param date		要格式化的Date对像
	 * @param formatStr	格式字符
	 */		
	static public function dateFormat(date:Date,formatStr:String="y-m-d h:i:s"):String
	{
		var myPattern:String = "y";	//匹配所有y字母换成年
		formatStr = StringTools.replace(formatStr, myPattern, Std.string(date.getFullYear()));
		myPattern = "m";//匹配所有m字母换成月
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getMonth()+1));
		myPattern = "d";//匹配所有d字母换成日
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getDate()));
		myPattern = "h";//匹配所有h字母换成小时
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getHours()));
		myPattern = "i";//匹配所有i字母换成分
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getMinutes()));
		myPattern = "s";//匹配所有s字母换成秒
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getSeconds()));
		myPattern = "t";//匹配所有s字母换成秒
		formatStr = StringTools.replace(formatStr,myPattern,Std.string(date.getTime()/1000));
		return formatStr;
	}
	
	/**
	 * 通过时间戳转换时间格式
	 * @param time 时间戳(单位秒)
	 * @param formatStr
	 */		
	static public function timeFormat(time:Int,formatStr:String="y-m-d h:i:s"):String
	{
		return dateFormat(Date.fromTime(time*1000),formatStr);
	}
	/**
	 * 通过时间戳转换时间格式
	 * @param time 时间戳(单位秒)
	 * @param formatStr
	 * @param zero 不足十位数时是否补0
	 */		
	static public function timeFormat2(time:Int,formatStr:String="h:i:s",zero:Bool=true):String
	{
		var myPattern:String = "h";//匹配所有h字母换成小时
		var tt:Int = Std.int((time / (60 * 60) % 60));
		var fstr:String = null;
		if (tt < 10)
		fstr = "0" + Std.string(tt);
		else
		fstr = Std.string(tt);
		formatStr = StringTools.replace(formatStr, myPattern, fstr);
		tt = Std.int((time / 60) % 60);
		if (tt < 10)
		fstr = "0" + tt;
		else
		fstr = Std.string(tt);
		myPattern = "i";//匹配所有i字母换成分
		formatStr = StringTools.replace(formatStr, myPattern, fstr);
		tt = Std.int(time % 60);
		if (tt < 10)
		fstr = "0" + tt;
		else
		fstr = Std.string(tt);
		myPattern = "s";//匹配所有s字母换成秒
		formatStr = StringTools.replace(formatStr, myPattern, fstr);
		return formatStr;
	}
	
	/**
	 *  格式化剩余的时间  X天 X个月
	 */
	static public function formatLeaveTime(time:Int) : String
	{
		var leaveTime:Int = time;
		var leaveTime_str:String = "";
		var val:Int;
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
			leaveTime_str += leaveTime + "秒";
		} 
		return leaveTime_str;
	}
	
	/**
	 * 格式化剩余时间
	 * @param time (单位秒)
	 */
	public static function formatLeaveTime2(time:Int):String
	{
		var h:Int = Math.round(time/(60*60));
		var m:Int = Math.round((time%(60*60))/60);
		var s:Int = Math.round(time%(60*60*60));
		var hstr:String = (h<10)?("0"+h):Std.string(h);
		var mstr:String = (m<10)?("0"+m):Std.string(m);
		var sstr:String = (s<10)?("0"+s):Std.string(s);
		return h+":"+m+":"+s;
	}
	
	/**
	 * 将Data类型转为字符类型
	 * @param d 日期类型
	 
	static public function DateToString(d:Date):String
	{
		var y:String 	= Std.string(d.fullYear);
		var m:String 	= Std.string(d.month);
		var day:String	= Std.string(d.day);
		var h:String	= Std.string(d.hours);
		var mi:String	= Std.string(d.minutes);
		var se:String	= Std.string(d.seconds);
		
		var s:String = y+"-"+m+"-"+day+" "+h+":"+mi+":"+se+"";
		
		return s;
	}*/
}