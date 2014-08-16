package asSkinStyle.data;
import flash.display.DisplayObject;

/**
 * 样式数据管理
 * @author Pelephone
 */
class StyleModel
{
	public function new()
	{
		objMap = new Map<String,Dynamic>();
		classMap = new Map<String,Class<DisplayObject>>();
		builderMap = new Map<String,StyleVars>();
		styleMap = new Map<String,StyleVars>();
	}
	
	//---------------------------------------------------
	// 注册引用变量
	//---------------------------------------------------
	
	/**
	 * 注册对象别名 {String,Object}
	 */
	private var objMap:Map<String,Dynamic>;
	
	/**
	 * 注册引用变量对象
	 * @param tagName
	 * @param target
	 */
	public function registerObject(tagName:String, target:Dynamic):Void
	{
		objMap.set(tagName,target);
	}
	
	/**
	 * 获取注册在这上面的对象
	 * @param tarName
	 * @return 
	 */
	public function getTagObject(tarName:String):Dynamic
	{
		if(!objMap.exists(tarName))
			return null;
		return objMap.get(tarName);
	}
	
	//---------------------------------------------------
	// 注册类型别名
	//---------------------------------------------------
	
	/**
	 * 注册类别名	{String,Class}
	 */
	private var classMap:Map<String,Class<DisplayObject>>;
	
	/**
	 * 注册类别名,供反射样式时用
	 * @param tagName
	 * @param target
	 */
	public function registerClass(tagName:String, target:Class<DisplayObject>):Void
	{
		classMap.set(tagName,target);
	}
	
	/**
	 * 获取注册在这上面的对象
	 * @param tarName
	 * @return 
	 */
	public function getClass(tarName:String):Class<DisplayObject>
	{
		if(!classMap.exists(tarName))
			return null;
		return classMap.get(tarName);
	}
	
	//---------------------------------------------------
	// 样式数据映射
	//---------------------------------------------------
	
	/**
	 * 用于创建显示对象的样式属性 {String,StyleVars}
	 */
	private var builderMap:Map<String,StyleVars>;
	
	/**
	 * 设置创建样式映射
	 * @param vars
	 */
	public function setBuildVars(vars:StyleVars):Void
	{
		builderMap.set(vars.path, vars);
	}
	
	/**
	 * 通过id路径获取创建样式变量
	 * @param idPath
	 * @return 
	 */
	public function getBuildVars(idPath:String):StyleVars
	{
		var key:String = StyleTag.ROOT + StyleTag.JOIN_STR + idPath;
		if (!builderMap.exists(key))
		return null;
		else
		return builderMap.get(key);
	}
	
	/**
	 * 用于设置的属性的样式映射
	 */
	private var styleMap:Map<String,StyleVars>;
	
	/**
	 * 设置样式变量映射  {String,StyleVars}
	 * @param vars
	 */
	public function setStyleVars(vars:StyleVars):Void
	{
		styleMap.set(vars.path, vars);
	}
	
	/**
	 * 通过id路径获取样式变量
	 * @param idPath
	 * @return 
	 */
	public function getStyleVars(idPath:String):StyleVars
	{
		var key:String = StyleTag.ROOT + StyleTag.JOIN_STR + idPath;
		if (!styleMap.exists(key))
		return null;
		else
		return styleMap.get(key);
	}
	
	/**
	 * 获取根
	 * @return 
	 */
	public function getRootVars():StyleVars
	{
		return styleMap.get(StyleTag.ROOT);
	}
}