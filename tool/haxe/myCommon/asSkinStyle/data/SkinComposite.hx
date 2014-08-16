package asSkinStyle.data;
/**
 * 皮肤组合(此组合是一个vo对象，纯用于表示数据)
 * name:用于生成皮肤的tag标签(查找注册的绑定皮肤生成)
 * idName:节点唯一标识，组件通过此id绑定
 * classStyle:用于查找皮肤基本样式
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class SkinComposite extends StyleComposite
{
	/**
	 * 分隔字符串里样式
	 */
	inline public static var SEPARATOR_STYLE_CLASS:String = ",";
	inline public static var PREFIX_CLASS:String = ".";
	inline public static var PREFIX_ID:String = "#";
	
//		private var _autoCreate:Boolean;
	
	/**
	 * 皮肤组合
	 * @param sNodeName
	 */
	public function new(aTagName:String,aIdName:String,aClassStr:String=null)
	{
		super(aIdName);
		this.tagName = aTagName;
		this.classStyle = aClassStr;
	}
	
	/**
	 * 通过点语法路径返回对象里的子对象。
	 * 如mc.info.txt_name表示的是cpe里面名为mc里面的info里面的txt_name对象
	 * @param cpe		要查找的显示容器
	 * @param pName		点语法名
			
	public function getChildByPointName(pName:String):Composite
	{
		return StyleUtils.getCompositeByPointName(pName,this);
	}*/

	public var tagName(get,set):String;
	var _tagName:String;
	/**
	 * 标签属性名
	 */
	function get_tagName():String
	{
		return _tagName;
	}

	/**
	 * @private
	 */
	function set_tagName(value:String):String
	{
		_tagName = value;
		return _tagName;
	}

	public var classStyle(get,set):String;
	var _classStyle:String;
	/**
	 * 样式字符
	 */
	function get_classStyle():String
	{
		return _classStyle;
	}

	/**
	 * @private
	 */
	function set_classStyle(value:String):String
	{
		_classStyle = value;
		if(value==null)
		{
			styles = null;
			return _classStyle;
		}
		styles = [];
		var arr:Array<String> = _classStyle.split(SEPARATOR_STYLE_CLASS);
		for (var i:int = 0; i < arr.length; i++) 
			arr[i] = PREFIX_CLASS + arr[i];
		
		styles = arr;
		return _classStyle;
	}
	
	
	/**
	 * 样式组，跟椐_classTyle拆分生成
	 */
	public var styles:Array<String>;
	
	public var idName(get):String;
	function get_idName():String 
	{
		return PREFIX_ID + getName();
	}

	/**
	 * 是否自动创建子项
	 
	public function get autoCreate():Boolean
	{
		return _autoCreate;
	}*/

	/**
	 * @private
	 
	public function set autoCreate(value:Boolean):Void
	{
		_autoCreate = value;
	}*/

	
/*		override public function makeDisps():DisplayObject
	{
		var dispClz:Class = null;//SparrowGUI.getIns().getTagClass(nodeName);
		if(dispClz)
			var dp:DisplayObject = new dispClz() as DisplayObject;
		else
			dp = new RectDraw();
		
		if(dp){
			dp.name = getName();
			
			// 通过id.类名获取样式对象
			changeSkin(dp,getName(),styleClass);
			
			// 如果本项是容器对象，则遍历子项addChild到dp
			var dc:DisplayObjectContainer = dp as DisplayObjectContainer;
			if(dc){
				for each (var itr:SkinComposite in getChildren()) 
				{
					var childDP:DisplayObject = dc.getChildByName(itr.getName());
					if(childDP){
						changeSkin(childDP,itr.getName(),itr.styleClass);
						continue;
					}
					childDP = itr.makeDisps();
					if(!childDP) continue;
					(dc as DisplayObjectContainer).addChild(childDP);
				}
			}
		}
		return dp;
	}*/
	
/*		private function changeSkin(dp:DisplayObject,idName:String,styles:Vector.<String>):Void
	{
		if(!styles) return;
		var cssName:String = "#"+idName;
		for each (var sName:String in styles)
		{
			cssName += "," + "."+sName;
		}
		//通过样式设置对象属性
//			SparrowGUI.getIns().setSkinDefaultUI(dp,cssName);
	}*/
}