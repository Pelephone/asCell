package asSkinStyle.data;
/**
 * 样式标记标签
 * @author Pelephone
 */
class StyleTag
{
	/**
	 * 根组合的名称
	 */
	public static var ROOT:String = "root";
	/**
	 * 新标签
	 */
	public static var TAG_NEW:String = "new";
	/**
	 * 标点标签
	 */
	public static var BEAN:String = "bean";
	/**
	 * 获取子项标签
	 */
	public static var GET:String = "get";
	/**
	 * 引用节点
	 */
	public static var REFERENCE:String = "reference";
	/**
	 * class属性名,对应注册的Class对象,如果没注册就从反射里找Class
	 */
	public static var CLASS:String = "clzTag";
	/**
	 * 构造标签
	 */
	public static var CONSTRUCT:String = "construct";
	/**
	 * id属性名
	 */
	public static var ID:String = "name";
	/**
	 * 样式路径(点语法)
	 */
	public static var PATH:String = "pathStr";
	/**
	 * 引用注册变量名
	 */
	public static var REFL_REG_VALUE:String = "$";
	/**
	 * 引用标签变量
	 */
	public static var REFL_TAG_VALUE:String = "#";
	
	/**
	 * 连接符号
	 */
	public static var JOIN_STR:String = ".";
}