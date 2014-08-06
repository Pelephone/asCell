package utils
{
	import TimerUtils.StaticEnterFrame;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class TweenUtil
	{
		public function TweenUtil()
		{
		}
		
		/**
		 * 缓动发光
		 * {glowFilter:{color:0xffffcc, alpha:0, blurX:0, blurY:0}}
		 * @param disp		使其发光的对象
		 * @param duration	用时，以毫秒为单位
		 * @param color		发光的颜色
		 * @param alpha		发光的alpha
		 * @param blur		发光的宽度
		 * @param strength	发光的强度
		 */		
		public static function tweenGlow(disp:DisplayObject,duration:int=300,color:uint=0x000000,alpha:Number=0,blur:Number=6,strength:Number=2,callBack:Function=null):void
		{
			var initGlow:GlowFilter = CmmFun.getDispFiters(disp,GlowFilter) as GlowFilter;
			var timer:int=getTimer(),arr:Array;
			if(!initGlow){
				initGlow = new GlowFilter(color,0,0,0,0);
				disp.filters = [initGlow];
			}
			
			StaticEnterFrame.addFrameListener(glowStep);
			function glowStep():void
			{
				var odd:Number=(getTimer() - timer)/duration;
				var glow:GlowFilter = new GlowFilter(color);
				if(odd>1) odd = 1;
				
				if(alpha>=0) glow.alpha = initGlow.alpha + (alpha - initGlow.alpha)*odd;
				else glow.alpha = initGlow.alpha;
				
				if(blur>=0) glow.blurX = glow.blurY = initGlow.blurX + (blur - initGlow.blurX)*odd;
				else glow.blurX = glow.blurY = initGlow.blurX;
				
				if(strength>=0) glow.strength = initGlow.strength + (strength - initGlow.strength)*odd;
				else glow.strength = initGlow.strength;
				
				disp.filters = [glow];
				
				if(odd>=1){
					glow = new GlowFilter(color,alpha,blur,blur,strength);
					disp.filters = [glow];
					StaticEnterFrame.removeFrameListener(glowStep);
					if(callBack!=null) callBack();
				}
			}
		}
		
		/**  通过静态的timerTOEnterFrame缓动到目标点
		 * @param SR 要移动一精灵
		 * @param EndPoint 结束位置，即移动到的点
		 * @param tName 给此缓动命名，防止冲突
		 * @param easing 缓动系数在0-1之间，系数越大，移动越快
		 * @param endCall 缓动结束后运行的函数*/
		public static function tweenMoveToPosi(disp:DisplayObject,endPot:Point,easing:Number=0.5,endCall:Function=null):void
		{
			StaticEnterFrame.addFrameListener(moveSP,[disp,endPot]);
			function moveSP(s:DisplayObject,ep:Point):void
			{
				s.x += (ep.x - s.x) * easing; 
				s.y += (ep.y - s.y) * easing;
				if(Point.distance(new Point(s.x,s.y),ep) <= 1)
				{
					s.x = ep.x;
					s.y = ep.y;
					StaticEnterFrame.removeFrameListener(moveSP);
					if(endCall!=null) endCall();
				}
			}
		}

		/**  通过静态的StaticEnterFrame无缓动到目标点
		 * @param SR 要移动一精灵
		 * @param EndPoint 结束位置，即移动到的点
		 * @param step 每秒移动的像素
		 * @param easing 缓动系数在0-1之间，系数越大，移动越快
		 * @param endCall 缓动结束后运行的函数
		public static function moveToPosi(dsp:DisplayObject,endPot:Point,step:Number=2,endCall:Function=null):void
		{
			var startPt:Point = new Point(dsp.x,dsp.y);
			var dist:Number = Point.distance(startPt,endPot);
			var useTime:int = dist*1000/step;
			var angle:Number = getRadianByPot(startPt,endPot);
			moveByDirect(dsp,angle,step);
			FrameTimer.delayCall(useTime,moveEnd);
			
			function moveEnd():void
			{
				stopMove(dsp);
				dsp.x = endPot.x;
				dsp.y = endPot.y;
				if(endCall!=null)
					endCall.apply(null,[]);
			}
		}*/
		
		/**
		 * 通过两点算出弧度(0~2*PI)<br/>
		 * @param sp
		 * @param ep
		 */		
		private static function getRadianByPot(sp:Point,ep:Point):Number
		{
			var radian:Number = Math.atan2(ep.y-sp.y,ep.x-sp.x);
			radian = (radian>0)?(radian%(Math.PI*2)):(radian%(Math.PI*2)+Math.PI*2);
			return radian;
		}
		
		//---------------------------------------------------
		// x,y移动
		//---------------------------------------------------
		
		/**
		 * 当前正在移动的对象
		 */
		private static var movingMap:Dictionary = new Dictionary();
		
		/**
		 * 通过移动对象获取对应的缓动
		 * @param target
		 * @return 
		 
		public static function getTweenVar(target:Object):TweenVars 
		{
			return movingMap[target] as TweenVars;
		}*/
		
		/**
		 * 使目标移动到某点
		 * @param target 待移动的对象
		 * @param duration 用时(毫秒)
		 * @param px 目标x像素坐标点
		 * @param py 目标y像素坐标点
		 * @return 
		 */
		public static function moveTo(target:Object,duration:int,px:int,py:int):TweenVars
		{
			var varProp:TweenVars = movingMap[target];
			if(!varProp)
				varProp = newTweenVars();
			
			varProp.duration = duration;
			varProp.endX = px;
			varProp.endY = py;
			varProp.ease = setTarByVar;
			
			return moveByVars(target,varProp);
		}
		
		/**
		 * TweenVars对象池管理
		 */
		private static var cachePool:Vector.<TweenVars> = new Vector.<TweenVars>();
		
		/**
		 * 创建一个缓动变量
		 * @return 
		 */
		private static function newTweenVars():TweenVars
		{
			if(cachePool.length)
				return cachePool.shift();
			return new TweenVars();
		}
		
		/**
		 * 通过参数移动对象
		 * @param target
		 * @param varProp
		 */
		private static function moveByVars(target:Object,varProp:TweenVars):TweenVars
		{
			if(!varProp)
				return varProp;
			varProp.target = target;
			varProp.startX = target.x;
			varProp.startY = target.y;
			varProp.startTime = getTimer();
			movingMap[target] = varProp;
			StaticEnterFrame.addFrameListener(onEnterMove);
			return varProp;
		}
		
		/**
		 * 通过对象停止移动
		 * @param target
		 * @param stopTime 停止时间,相对于开始的时间. 如果此数小于0表示当前时间
		 */
		public static function stopMove(target:Object,stopTime:int=-1):void
		{
			var tpo:TweenVars = movingMap[target];
			if(!tpo)
				return;
			var curTime:int = getTimer();
			if(stopTime<0)
				stopTime = curTime;
			else
				stopTime = tpo.startTime + stopTime;
			
			delete movingMap[target];
			tpo.ease(tpo,stopTime);
			if(tpo.onComplete != null)
				tpo.onComplete.apply(null,tpo.onCompleteParams);
			tpo.target = null;
			tpo.onUpdate = null;
			tpo.onUpdateParams = null;
			tpo.onComplete = null;
			tpo.onCompleteParams = null;
			tpo.params = null;
			tpo.ease = null;
			tpo.stopTime = curTime;
			cachePool.push(tpo);
		}
		
		/**
		 * 表里的对象逐帧移动计算
		 */
		private static function onEnterMove():void
		{
			var curTime:int = getTimer();
			var tarNum:int = 0;
			var removeLs:Vector.<TweenVars> = new Vector.<TweenVars>();
			for each (var itm:TweenVars in movingMap) 
			{
				itm.ease(itm,curTime);
//				setTarByVar(itm,curTime);
				if(itm.onUpdate != null)
					itm.onUpdate.apply(null,itm.onUpdateParams);
				if(itm.ratio >= 1)
					removeLs.push(itm);
				tarNum = tarNum + 1;
			}
			// 用另外一个循环来移除是为了不影响movingMap的遍历
			for each (itm in removeLs) 
			{
				stopMove(itm.target);
			}
			
			// 1分钟对池资源过期
			var exipTime:int = 1000*60;
			while(cachePool.length)
			{
				itm = cachePool[length - 1];
				if(itm.stopTime < (curTime - exipTime))
					cachePool.pop();
				else
					break;
			}
			
			if(tarNum == 0 && cachePool.length == 0)
				StaticEnterFrame.removeFrameListener(onEnterMove);
		}
		
		/**
		 * 均速设置位置变量
		 * @param itm
		 * @param curTime
		 */
		private static function setTarByVar(itm:TweenVars,curTime:int):void
		{
			var disTime:int = curTime - itm.startTime;
			var dx:int = itm.endX - itm.startX;
			var dy:int = itm.endY - itm.startY;
			itm.ratio = disTime / itm.duration;
			if(itm.ratio > 1)
				itm.ratio = 1;
			itm.target.x = itm.startX + dx * itm.ratio;
			itm.target.y = itm.startY + dy * itm.ratio;
		}
		
		/**
		 * 通过缓动变量设置对象位置
		 * @param itm
		 * @param curTime
		 
		private static function setTarByVar(itm:TweenVars,curTime:int):void
		{
			var disTime:int = curTime - itm.startTime;
			
			if(itm.offsetX <= 0)
				itm.offsetX = itm.step * 0.001 * Math.cos(itm.direct);
			if(itm.offsetY <= 0)
				itm.offsetY = itm.step * 0.001 * Math.sin(itm.direct);
			
			itm.target.x = itm.startX + disTime * itm.offsetX;
			itm.target.y = itm.startY + disTime * itm.offsetY;
//			var dist:int = disTime * itm.step * 0.001;
//			itm.target.x = itm.startX + dist * Math.cos(itm.direct);
//			itm.target.y = itm.startY + dist * Math.sin(itm.direct);
		}*/
		
		/**
		 * 摩擦力减速运动
		 * @param target 移动对象
		 * @param duration
		 * @param velocity0
		 * @param friction
		 
		public static function accTween(target:DisplayObject,duration:Number,angle:Number
										,velocity0:Number,acc:Number):TweenVars
		{
			var tpo:TweenVars = movingMap[target];
			if(!tpo)
				tpo = newTweenVars();
			
			tpo.target = target;
			tpo.startX = target.x;
			tpo.startY = target.y;
			tpo.direct = angle;
			tpo.ease = accEase;
			tpo.startTime = getTimer();
			tpo.params = [duration,velocity0,acc];
			moveByVars(target,tpo);
			
			return tpo;
		}*/
		
		/**
		 * 加速度缓动
		 * 加速度公式 s=v0*t + 1/2*a*t^2,(vt-v0)/t=a
		 
		private static function accEase(itm:TweenVars,curTime:int):void
		{
			var dur:Number = itm.params[0];
			var t:Number = (curTime - itm.startTime)*0.001;
			if(t>dur)
				t = dur;
			var v0:Number = itm.params[1];
			var acc:Number = itm.params[2];
			var s:Number = v0*t + 1/2*acc*t*t;
			itm.target.x = int(itm.startX + s * Math.cos(itm.direct));
			itm.target.y = int(itm.startY + s * Math.sin(itm.direct));
			
			if(t != dur)
				return;
			TweenUtil.stopMove(itm.target);
		}*/
	}
}