package asSkinStyle.data;

/**
 * 单个css样式存放数据(此组合是一个vo对象，纯用于表示数据)
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class CssStyle extends StyleComposite
{
	/**
	 * 引用分隔符
	 
	public static const SEPARTOR_REFERENCE:String = "#";*/
	/**
	 * 引用属性
	 */
	public static const ATTR_REFERENCE:String = "reference";
	/**
	 * className前缀字符
	 
	protected static const CLASS_PREFIX:String = ".";*/
	
	// 带分隔符语法的名字
//		private var _ptName:String;
	// 样式vo对象
	/**
	 * 引用名
	 
	private var _refName:String;*/
	
	/**
	 * 通过点语法名和皮肤变量对象构造组件
	 * @param idName		点语法的名
	 * @param cssObj	单个css样式变量数据
	 */
	public function new(idName:String,cssVars:Object=null)
	{
/*			var tid:int = pName.indexOf(SEPARTOR_REFERENCE);
		var idName:String;
		if(tid<0)
			idName = pName;
		else
		{
			idName = pName.substring(0,tid);
			_refName = pName.substring(tid+1);
		}*/
		
		super(idName,cssVars);
	}
	
	/**
	 * 获取引用样式名
	 * @return 
	 */
	public function getRefName():String
	{
		var obj:Object = getStyleVars();
		if(obj && obj.hasOwnProperty(ATTR_REFERENCE))
			return obj[ATTR_REFERENCE];
		return null;
	}
	
	/**
	 * 通过名字获取组件
	 * @param n
	 * @return 
	 
	override public function getChildByName(n:String):StyleComposite
	{
		var tid:int = n.indexOf(SEPARTOR_REFERENCE);
		var idName:String;
		if(tid<0)
			idName = n;
		else
			idName = n.substring(0,tid);
		
		return super.getChildByName(idName);
	}*/
	
	/**
	 * 获取标签名，前缀不是#和.的名字
	 * @return 
	 
	override public function getName():String
	{
		var firstStr:String = _ptName.charAt();
		if(firstStr==ID_PREFIX || firstStr==CLASS_PREFIX)
			return null;
		else
			return _ptName;
	}*/
	
	/**
	 * 返回id名
	 * @return 
	 
	public function getIdName():String
	{
		var firstStr:String = getName().charAt();
		if(firstStr && firstStr==ID_PREFIX)
			return getName().substr(1);
		else return null;
	}*/
	
	/**
	 * 返回class名
	 * @return 
	 
	public function getClassName():String
	{
		var firstStr:String = getName().charAt();
		if(firstStr && firstStr==CLASS_PREFIX)
			return getName().substr(1);
		else return null;
	}*/
	
/*		override public function makeDisps():DisplayObject
	{
		var dispClz:Class = getStyleVars()[UIMgr.CLAZZ] as Class;
		if(dispClz)
			var dc:DisplayObject = new dispClz() as DisplayObject;
		else
			dc = new RectDraw();
		
		if(dc){
			dc.name = getName();
			UIUtils.setObjByVars(dc,getStyleVars());
			
			// 如果本项是容器对象，则遍历子项addChild到dc
			if(dc is DisplayObjectContainer){
				for each (var itr:CssComposite in getChildren()) 
				{
					var childDP:DisplayObject = itr.makeDisps();
					if(!childDP) continue;
					(dc as DisplayObjectContainer).addChild(childDP);
				}
			}
		}
		return dc;
	}*/
	
	/**
	 * 通过点语法路径返回对象里的子对象。
	 * 如mc.info.txt_name表示的是cpe里面名为mc里面的info里面的txt_name对象
	 * @param cpe		要查找的显示容器
	 * @param pName		点语法名
			
	public function getChildByPointName(pName:String):Composite
	{
		var firstStr:String = _ptName.charAt();
		switch(firstStr)
		{
			case ID_PREFIX:
			{
				
				break;
			}
				
			default:
			{
				return getch
			}
		}
	}*/
	
	/**
	 * 获取标签名，前缀不是#和.的名字
	 * @return 
	 
	public function getPtName():String
	{
		var firstStr:String = getName().charAt();
		if(firstStr==ID_PREFIX || firstStr==CLASS_PREFIX)
			return null;
		else
			return getName();
	}*/
}