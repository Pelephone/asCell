package asSkinStyle.data;

/**
 * 皮肤样式组合
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class SkinStyle extends StyleComposite
{
	
	/**
	 * 构造皮肤样式
	 * @param idName		表示唯一的id名，也应对显示对象的name属性
	 * @param classTag		类样式,用于生成对应的显示对象
	 * @param cssVars		样式属性，用于设置生成的显示对象属性
	 */
	public function new(idName:String,clazzTag:String=null, cssVars:Object=null)
	{
		super(idName, cssVars);
		_classTag = clazzTag;
	}

	public var classTag(get,set):String;
	var _classTag:String;
	/**
	 * 类样式,用于生成对应的显示对象
	 */
	function get_classTag():String
	{
		return _classTag;
	}

	/**
	 * @private
	 */
	function set_classTag(value:String):void
	{
		_classTag = value;
	}
}