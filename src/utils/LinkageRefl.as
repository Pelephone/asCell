package utils
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	
	/**
	 * 反射生成导出对象
	 * Pelephone
	 */
	public class LinkageRefl
	{
		public function LinkageRefl()
		{
			if(instance)
				throw new Error(this + " is singleton class and allready exists!");
			
			instance = this;
		}
		
		/**
		 * 单例
		 */
		private static var instance:LinkageRefl;
		/**
		 * 获取单例
		 */
		public static function getInstance():LinkageRefl
		{
			if(!instance)
				instance = new LinkageRefl();
			
			return instance;
		}
		
		/**
		 * 从对象池中获取缓存对象
		 * @param className
		 * @return 
		 */
		protected function getFromPool(className:String):*
		{
			return null;
		}
		
		/**
		 * 根据给定的字符串获取相关类Class
		 * @param fullClassName 类名(反射名)
		 * @param applicationDomain 域
		 * @return
		 */
		public static function getClass(fullClassName:String, applicationDomain:ApplicationDomain = null):Class
		{
			if (applicationDomain == null)
			{
				applicationDomain = ApplicationDomain.currentDomain;
			}
			var assetClass:Class;
			try
			{
				assetClass = applicationDomain.getDefinition(fullClassName) as Class;
			}
			catch (e:*)
			{
				
			}
			return assetClass;
		}
		
		/**
		 * 判断域中是否有反射类
		 * @param fullClassName 类名(反射名)
		 * @param applicationDomain 域
		 */
		public static function hasClass(fullClassNum:String, applicationDomain:ApplicationDomain = null):Boolean
		{
			if (applicationDomain == null)
			{
				applicationDomain = ApplicationDomain.currentDomain;
			}
			return applicationDomain.hasDefinition(fullClassNum);
		}
		
		/**
		 * 通过类名从域反射出类
		 * @param className
		 * @return 
		 */
		public static function cls(className:String):Class
		{
			return getClass(className);
		}
		
		/**
		 * 通过类名生成显示对象
		 * @param className
		 * @return 
		 */
		public static function disp(className:String):DisplayObject
		{
			var ncls:Class = cls(className);
			var res:DisplayObject = getInstance().getFromPool(className);
			if(res) return res;
			return new ncls() as DisplayObject;
		}
		
		/**
		 * 通过类名生成Sprite对象
		 * @param className
		 * @return 
		 */
		public static function sp(className:String):Sprite
		{
			var sp:Sprite = disp(className) as Sprite;
			return sp || new Sprite();
		}
		
		/**
		 * 通过类名生成SimpleButton对象
		 * @param className
		 * @return 
		 */
		public static function sb(className:String):SimpleButton
		{
			var sb:SimpleButton = disp(className) as SimpleButton;
			return sb || new SimpleButton();
		}
		
		/**
		 * 通过类名生成MovieClip对象
		 * @param className
		 * @return 
		 */
		public static function mc(className:String):MovieClip
		{
			var mc:MovieClip = disp(className) as MovieClip;
			return mc || new MovieClip();
		}
		
		/**
		 * 通过类名生成Shape对象
		 * @param className
		 * @return 
		 */
		public static function shape(className:String):Shape
		{
			var mc:Shape = disp(className) as Shape;
			return mc || new Shape();
		}
	}
}