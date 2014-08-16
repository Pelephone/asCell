package sparrowGui.skinStyle;
import flash.text.Font;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
 * 文本样式
 * @author Pelephone
 */
class TextStyle
{

	function new() 
	{
		init();
		instance = this;
	}
	
	/**
	 * 单例
	 */
	private static var instance:TextStyle;
	/**
	 * 获取单例
	 */
	public static function getInstance():TextStyle
	{
		if(instance == null)
			instance = new TextStyle();
		
		return instance;
	}
	
	function init()
	{
		normalFormat = createTextFormat();
		normalFormat.size = 12;
		normalFormat.color = 0x0000;
		
		centerNormal = createTextFormat();
		centerNormal.align = TextFormatAlign.CENTER;
		centerNormal.color = 0x0000;
	}
	
	
	/**
	 * 普通样式
	 */
	public var normalFormat:TextFormat;
	
	/**
	 * 普通居中
	 */
	public var centerNormal:TextFormat;
	
	/**
	 * 创建字体格式
	 */
	public static function createTextFormat():TextFormat
	{
		#if android
		return new TextFormat(new Font("/system/fonts/DroidSansFallback.ttf").fontName);
		#elseif neko
		return new TextFormat("simsun");
		#else
		return new TextFormat("微软雅黑");
		#end
	}
}