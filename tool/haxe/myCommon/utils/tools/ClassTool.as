package utils.tools
{
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * 类工具
	 */
	public class ClassTool extends Object
	{
		/**
		 * 通过参数和类名实例化对象
		 * @param className
		 * @param params
		 */
		public static function createForName(className:String, params:Array) : Object
		{
			var cls:* = getDefinitionByName(className) as Class;
			return createNewInstance(cls, params);
		}// end function
		
		/**
		 * 通过类和参数实例化对象
		 * @param type
		 * @param params
		 */
		public static function createNewInstance(type:Class, params:Array) : Object
		{
			switch(params.length)
			{
				case 0:
				{
					return new type;
				}
				case 1:
				{
					return new type(params[0]);
				}
				case 2:
				{
					return new type(params[0], params[1]);
				}
				case 3:
				{
					return new type(params[0], params[1], params[2]);
				}
				case 4:
				{
					return new type(params[0], params[1], params[2], params[3]);
				}
				case 5:
				{
					return new type(params[0], params[1], params[2], params[3], params[4]);
				}
				case 6:
				{
					return new type(params[0], params[1], params[2], params[3], params[4], params[5]);
				}
				case 7:
				{
					return new type(params[0], params[1], params[2], params[3], params[4], params[5], params[6]);
				}
				case 8:
				{
					return new type(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7]);
				}
				default:
				{
					throw new Error("不支持此参数数量构造 " + params.length);
					break;
				}
			}
		}
		
		/**
		 * 通过类返回简单类名
		 * @param type
		 */
		public static function getSimpleName(type:Class) : String
		{
			var sName:* = getQualifiedClassName(type).replace("::", ".");
			return sName.substring((sName.lastIndexOf(".") + 1));
		}
		
		/**
		 * 当前域中是否有此对象
		 * @param domain
		 * @param instance
		 */
		public static function containsDefinition(domain:ApplicationDomain, instance:Object) : Boolean
		{
			var cls:Class = null;
			var qName:* = getQualifiedClassName(instance);
			if (domain.hasDefinition(qName))
			{
				cls = domain.getDefinition(qName) as Class;
				if (instance is cls)
				{
					return true;
				}
			}
			return false;
		}
	}
}
