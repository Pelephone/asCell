package asSkinStyle.data
{
	/**
	 * 皮肤样式组合
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class SkinStyle extends StyleComposite
	{
		private var _classTag:String;
		
		/**
		 * 构造皮肤样式
		 * @param idName		表示唯一的id名，也应对显示对象的name属性
		 * @param classTag		类样式,用于生成对应的显示对象
		 * @param cssVars		样式属性，用于设置生成的显示对象属性
		 */
		public function SkinStyle(idName:String,clazzTag:String=null, cssVars:Object=null)
		{
			super(idName, cssVars);
			_classTag = clazzTag;
		}

		/**
		 * 类样式,用于生成对应的显示对象
		 */
		public function get classTag():String
		{
			return _classTag;
		}

		/**
		 * @private
		 */
		public function set classTag(value:String):void
		{
			_classTag = value;
		}

	}
}