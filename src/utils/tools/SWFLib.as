package utils.tools
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	
	/**
	 * 封装了对 swf 文件的访问方式, 可以通过 SWFLib 类来获取/建立 swf 文件中的 元件
	 * @author Pelephone
	 */
	public class SWFLib{
		
		// swf 载入信息
		private var m_info:LoaderInfo;
		
		/**
		 * 构造 swf 文档对象
		 * @param info		Loader.contentLoaderInfo 对象
		 */
		public function SWFLib(info:LoaderInfo):void{
			m_info = info;
		}
		
		// 判断是否包含定义
		public function hasDefinition(name:String):Boolean{
			return m_info && m_info.applicationDomain.hasDefinition( name );
		}
		
		/**
		 * 从 swf 库中查找指定的类定义
		 * 
		 * @param name			- swf 库中导出的元件的类名
		 * @return				- 类对象
		 */
		public function cls(name:String):Class{
			if(!m_info ||!m_info.applicationDomain.hasDefinition(name)){
				throw new Error("无法在swf文件中找到类定义, 请检查该文件"+name);
				return null;
			}
			return m_info.applicationDomain.getDefinition( name ) as Class;
		}
		
		/**
		 根据元件名建立一个 DisplayObject
		 
		 @param name			swf文件库中导出的元件类名
		 @return				返回 DisplayObject 实例
		 */
		public function disp(name:String):DisplayObject{
			
			// 得到类型 tClass
			var tClass:Class = cls(name) as Class;
			if(tClass == null) return null;
			
			// 建立实例 disp
			var inst:DisplayObject = new tClass() as DisplayObject;
			if(inst is MovieClip) (inst as MovieClip).gotoAndStop(1);
			return inst;
		}
		
		// 保持兼容性
		public function getDisplayObjectByName(name:String):DisplayObject{
			return disp(name);
		}
		
		// 建立 mc 实例
		public function mc(name:String):MovieClip{
			return disp(name) as MovieClip;
		}
		
		// 建立 SimpleButton 实例
		public function sb(name:String):SimpleButton{
			return disp(name) as SimpleButton;
		}
	}
}