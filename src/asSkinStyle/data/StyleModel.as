package asSkinStyle.data
{

	/**
	 * 样式数据管理
	 * @author Pelephone
	 */
	public class StyleModel
	{
		public function StyleModel()
		{
		}
		
		//---------------------------------------------------
		// 注册引用变量
		//---------------------------------------------------
		
		/**
		 * 注册对象别名 {String,Object}
		 */
		private var objMap:Object = {};
		
		/**
		 * 注册引用变量对象
		 * @param tagName
		 * @param target
		 */
		public function registerObject(tagName:String, target:Object):void
		{
			objMap[tagName] = target;
		}
		
		/**
		 * 获取注册在这上面的对象
		 * @param tarName
		 * @return 
		 */
		public function getTagObject(tarName:String):Object
		{
			if(!objMap.hasOwnProperty(tarName))
				return null;
			return objMap[tarName];
		}
		
		//---------------------------------------------------
		// 注册类型别名
		//---------------------------------------------------
		
		/**
		 * 注册类别名	{String,Class}
		 */
		private var classMap:Object = {};
		
		/**
		 * 注册类别名,供反射样式时用
		 * @param tagName
		 * @param target
		 */
		public function registerClass(tagName:String, target:Class):void
		{
			classMap[tagName] = target;
		}
		
		/**
		 * 获取注册在这上面的对象
		 * @param tarName
		 * @return 
		 */
		public function getClass(tarName:String):Class
		{
			if(!classMap.hasOwnProperty(tarName))
				return null;
			return classMap[tarName] as Class;
		}
		
		//---------------------------------------------------
		// 样式数据映射
		//---------------------------------------------------
		
		/**
		 * 用于创建显示对象的样式属性 {String,StyleVars}
		 */
		private var builderMap:Object = {};
		
		/**
		 * 设置创建样式映射
		 * @param vars
		 */
		public function setBuildVars(vars:StyleVars):void
		{
			builderMap[vars.path] = vars;
		}
		
		/**
		 * 通过id路径获取创建样式变量
		 * @param idPath
		 * @return 
		 */
		public function getBuildVars(idPath:String):StyleVars
		{
			return builderMap[StyleTag.ROOT + StyleTag.JOIN_STR + idPath] as StyleVars;
		}
		
		/**
		 * 用于设置的属性的样式映射
		 */
		private var styleMap:Object = {};
		
		/**
		 * 设置样式变量映射  {String,StyleVars}
		 * @param vars
		 */
		public function setStyleVars(vars:StyleVars):void
		{
			styleMap[vars.path] = vars;
		}
		
		/**
		 * 通过id路径获取样式变量
		 * @param idPath
		 * @return 
		 */
		public function getStyleVars(idPath:String):StyleVars
		{
			return styleMap[StyleTag.ROOT + StyleTag.JOIN_STR + idPath] as StyleVars;
		}
		
		/**
		 * 获取根
		 * @return 
		 */
		public function getRootVars():StyleVars
		{
			return styleMap[StyleTag.ROOT];
		}
	}
}