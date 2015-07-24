package sparrowGui.components;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import sparrowGui.skinStyle.TextStyle;

/**
 * 本项目用的文本，在原来的基础上加一层，方便为本项目所有文本统一的改默认样式
 * @author Pelephone
 */
class STextField extends TextField
{
	public function new()
	{
		super();
		setMouseEnable(false);
		
		width = 180;
		height = 32;
		
		// 下面这两句是调试移位置时用，发布项目要注掉。
		//border = true;
		//borderColor = 0xFF0000;
		
		textColor = 0x000000;
		initTextFormat();
	}
	
	function initTextFormat()
	{
		this.defaultTextFormat = TextStyle.getInstance().normalFormat;
	}
	
	/**
	 * 设置字号
	 * @param	size
	 */
	public function setFontSize(size:Int = 12)
	{
		var tfm:TextFormat = this.defaultTextFormat;
		if (tfm.size == size)
		return;
		tfm.size = size;
		this.defaultTextFormat = tfm;
	}
	
	/**
	 * 考虑到经常会遇到text为空会报错。重写该方法 
	 * @param value
	 */
	@:setter(text)
	#if flash
	private function set_text(value:String)
	#else
	override function set_text(value:String):String
	#end
	{
		if(value == null)
		value = "";
		
		super.text = value;
		// html5的text要在设了INPUT之后再设input才能显示中文
		#if html5
		var reType:Dynamic = type;
		type = TextFieldType.INPUT;
		type = reType;
		#end
		
		#if !flash
		return value;
		#end
	}
	
	
/*	#if html5
	// 判断字符串是否有汉字
	function strHasZN(value:String):Bool
	{
		
		for (i in 0...value.length)
		{
			var c:Int = value.charCodeAt(i);
			if (c > 128)
			return true;
		}
		return false;
	}
	#end*/
	
	/**
	 * 考虑到经常会遇到htmlText为空会报错。重写该方法 
	 * @param value
	 */
	@:setter(htmlText)
	#if flash
	private function set_htmlText(value:String)
	#else
	override function set_htmlText(value:String):String
	#end
	{
		if(value == null)
		value = "";
		super.htmlText = value;
		
		#if !flash
		return value;
		#end
	}
	
	/**
	 * 设置鼠标是否能操作
	 */
	public function setMouseEnable(value:Bool) 
	{
		selectable = value;
		mouseEnabled = value;
		
		#if flash
		mouseWheelEnabled = value;
		#end
	}
}