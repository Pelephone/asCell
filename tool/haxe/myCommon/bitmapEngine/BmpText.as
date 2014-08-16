package bitmapEngine
{
	
	import TimerUtils.ExpireTimer;
	
	import asCachePool.interfaces.IRecycle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;

	/**
	 * 文本转位图工具
	 * 把库中按指定命名规则的导出对象，按text进行排列显示
	 * @author Pelephone
	 */
	public class BmpText extends Sprite implements IRecycle
	{
		public function BmpText()
		{
			super();
		}
		
		/**
		 * 单个数字位图宽
		 */
		public var itemWidth:int;
		
		/**
		 * 单个数字位图高
		 */
		public var itemHeight:int;
		
		/**
		 * 库导出
		 */
		public var linkageVars:String = "num_$1";
		
		/**
		 * 默认域
		 */
		public var appDomain:ApplicationDomain;
		
		private var _text:String;
		
		/**
		 * 显示文本
		 */
		public function set text(value:String):void
		{
			if(_text == value)
				return;
			_text = value;
			updateTxt();
		}
		
		/**
		 * @private
		 */
		public function get text():String 
		{
			return _text;
		}
		
		
		/**
		 * 当前显示的位置数据
		 */
		private var bmpLs:Vector.<Bitmap>;
		
		/**
		 * 更新显示
		 */
		protected function updateTxt():void
		{
			clearBmpTxt();
			if(!_text || !_text.length)
				return;
			
			// 直接从库里面取数据
			if(linkageVars)
			{
				var wordLs:Array = _text.split("");
				var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
				// 导出链接资源不能为空，为空即是bug会报错
				for (var i:int = 0; i < wordLs.length; i++) 
				{
					var witm:String = wordLs[i] as String;
					var clsKey:String = linkageVars.replace("$1",witm);
					var cls:Class = getClass(clsKey);
					if(cls)
					{
						var bmpd:BitmapData = bmpMgr.getAndCreateObj(cls);
						var bmp:Bitmap = new Bitmap(bmpd);
						var iw:int = itemWidth>0?itemWidth:bmpd.width;
						bmp.x = i*iw;
						addChild(bmp);
					}
					bmpLs.push(bmp);
				}
			}
		}
		
		/**
		 * 清除回收当前的位图显示数据
		 */
		protected function clearBmpTxt():void
		{
			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			var item:Bitmap;
			for each (item in bmpLs) 
			{
				bmpMgr.putInPool(item.bitmapData);
				item.bitmapData = null;
			}
			bmpLs = new <Bitmap>[];
		}
		
		/**
		 * 根据给定的字符串获取相关类Class
		 * @param fullClassName 类名(反射名)
		 * @param applicationDomain 域
		 * @return
		 */
		private function getClass(fullClassName:String):Class
		{
			if (appDomain == null)
			{
				appDomain = ApplicationDomain.currentDomain;
			}
			var assetClass:Class;
			try
			{
				assetClass = appDomain.getDefinition(fullClassName) as Class;
			}
			catch (e:*)
			{
				
			}
			return assetClass;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get width():Number
		{
			if(!_text)
				return super.width;
			else
				return _text.length * itemWidth;
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			_text = null;
			clearBmpTxt();
		}
		
		
		/**
		 * 回收计时器
		 */
		private var recyleTimer:ExpireTimer;
		
		/**
		 * 创建回收器,如果不需要回收可以覆盖此方法，或者不调用此方法
		 * @param recyleDelay 移出舞台后延迟X秒后回收
		 */
		public function setRecyleTimer(recyleDelay:int=2*60*1000):ExpireTimer
		{
			if(recyleDelay<0)
			{
				recyleTimer.dispose();
				return recyleTimer;
			}
			if(!recyleTimer)
				recyleTimer = new ExpireTimer(this,recyleDelay);
			
			recyleTimer.recyleDelay = recyleDelay;
			recyleTimer.addEventListener(ExpireTimer.RESET,onReset);
			recyleTimer.addEventListener(ExpireTimer.EXPIRED_RECYLE,onRecyle);
			return recyleTimer;
		}
		
		/**
		 * 回收后，再次被置入场景时调用
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			updateTxt();
		}
		
		/**
		 * 过期回收(此显示对象移出场景一段时间后调用)
		 * @param e
		 */
		protected function onRecyle(e:Event=null):void
		{
			clearBmpTxt();
		}
	}
}