/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package bitmapEngine
{
	import TimerUtils.ExpireTimer;
	
	import asCachePool.interfaces.IRecycle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	/**
	 * movieClip转位图(多帧控制)
	 * (注，此对象是bitmap对象，无鼠标事件)
	 * @author Pelephone
	 */
	public class MCBitmap extends Bitmap implements IMovieClip,IRecycle
	{
		public function MCBitmap(mc:MovieClip=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
			
//			_convertClip = newConverClip(mc);
//			_convertClip.isOffset = false;
//			_expireTimer = actExpireTimer();
			
			_frameFunMap = {};
			_labelMap = {};
			
			if(!mc) return;
			resetMCValue();
		}
		
		/**
		protected var _convertClip:BitmapConvert;
		
		
		 * 位图转换器
		 
		public function get convertClip():BitmapConvert
		{
			return _convertClip;
		}*/
		
		/**
		 * 新建转换组件
		 * @param source
		 * @return 
		 
		protected function newConverClip(source:MovieClip):BitmapConvert
		{
			return new BitmapConvert(this,source);
		}*/
		
		//----------------------------------------------------
		// 播放相关
		//----------------------------------------------------
		
		/**
		 * mc转换完成是否立刻播放
		 */
		public var autoPlay:Boolean = true;
		
		/**
		 * 帧数对应函数<int||String,Function>,即播放至某帧执行的方法
		 */	
		private var _frameFunMap:Object;
		
		/**
		 * 用来映射帧标签
		 */
		private var _labelMap:Object;
		
		/**
		 * 开始时间,play()开始的时候计数
		 */
		private var playStartTime:int;
		/**
		 * 开始帧,play()开始时的currentFrame
		 */
		protected var playStartFrame:int;
		
		// 循环播放
		private var repeatCount:int;
		private var repeatEnd:int;
		private var repeatStart:int;
		
		/**
		 * 播放
		 */
		public function play():void
		{
			if(totalFrames<2)
			{
				stop();
				return;
			}
			if(!running)
			{
				BmpRenderMgr.getInstance().addRender(doRender,frameRate);
			}
			
			playStartFrame = currentFrame;
			playStartTime = getTimer();
		}
		
		/**
		 * 暂停
		 */
		public function stop():void
		{
			repeatCount = 0;
			repeatEnd = totalFrames;
			repeatStart = 1;
			BmpRenderMgr.getInstance().removeRender(doRender);
		}
		
		/**
		 * 从某帧开始播放
		 * @param frame
		 */
		public function gotoAndPlay(frame:Object):void
		{
			currentFrame = getFrame(frame);
			play();
		}
		
		/**
		 * 跳转到某帧停止播放
		 * @param frame
		 */
		public function gotoAndStop(frame:Object):void
		{
			currentFrame = getFrame(frame);
			stop();
		}
		
		/**
		 * 循环播放
		 * @param startFrame 开始帧
		 * @param endFrame 结束帧
		 * @param repeat 循环次数，0表示无限循环
		 */
		public function repeatPlay(startFrame:Object=null,endFrame:Object=null,repeat:int=0):void
		{
			repeatCount = repeat;
			repeatStart = getFrame(startFrame);
			repeatEnd = getFrame(endFrame);
			gotoAndPlay(startFrame);
		}
		
		/**
		 * 渲染
		 * @param args
		 */
		public function doRender(args:Object=null):void
		{
//			convertClip.render(args);
			
			if(playStartFrame<repeatStart)
				playStartFrame = repeatStart;
			
			var totFme:int = repeatEnd - repeatStart + 1;
			
			// 每帧用时
//			var frmTime:Number = 1000/frameRate;
			// 经过时间停在帧
			var mFrm:int = (getTimer() - playStartTime)*frameRate*0.001 + playStartFrame;
			
			currentFrame = mFrm%totFme + repeatStart;
			
//			trace(playStartFrame,totFme,currentFrame);
		}
		
		/**
		 * 转换所有帧
		 
		 public function renderAllFrame():void
		 {
		 var tmpFrame:int = _currentFrame;
		 for (var i:int = 0; i <= totalFrames; i++) 
		 {
		 _currentFrame = i;
		 rendering();
		 }
		 _currentFrame = tmpFrame;
		 }*/
		
		/**
		 * 通过帧或者帧标签返回合法的帧数
		 * @param frame 帧或帧标签
		 */
		public function getFrame(frame:Object):int
		{
			if(frame is String && _labelMap.hasOwnProperty(frame))
				return int(_labelMap[frame]);
			
			var frameInt:int = int(frame);
			if(frameInt>totalFrames) return totalFrames;
			else if(frameInt<1) return 1;
			else return frameInt;
		}
		
		/**
		 * 停在上一帧
		 */
		public function prevFrame():void
		{
			_currentFrame = getFrame(currentFrame-1);
		}
		
		/**
		 * 停在下一帧
		 */
		public function nextFrame():void
		{
			currentFrame = getFrame(currentFrame+1);
		}
		
		protected var _currentFrame:int = 0;
		
		/**
		 * @private
		 */
		public function set currentFrame(value:int):void 
		{
			if(_currentFrame == value)
				return;
			_currentFrame = value;
			
			if(value > totalFrames)
				value = totalFrames;
			else if(value < 1)
				value = 1;
			
			_currentFrame = value;
			commitBmtInfo();
			
			var frameFunc:Function = _frameFunMap[_currentFrame] as Function;
			if(frameFunc!=null)
				frameFunc.apply(null,[]);
//			stop();
		}
		
		/**
		 * 当前帧,从1开始
		 * @return 
		 */
		public function get currentFrame():int 
		{
			return _currentFrame;
		}
		
		///////////////////////////////
		// 事件相关
		//////////////////////////////
		
		/**
		 * 给某帧添加方法，当对象播放到此帧时则执行方法,不用的时候记住要移除
		 * @param frame 帧，或者帧标签
		 * @param frameFunc 函数
		 */
		public function addFrameScript(frame:Object,frameFunc:Function=null):void
		{
			var frameInt:int = getFrame(frame);
			_frameFunMap[frameInt] = frameFunc;
		}
		
		/**
		 *  移除某帧上的方法函数
		 */
		public function removeFrameScript(frame:Object):void
		{
			var frameInt:int = getFrame(frame);
			_frameFunMap[frameInt] = null;
			delete _frameFunMap[frameInt];
		}
		
		private var _frameRate:int = 30;
		
		/**
		 * 帧率,每秒渲染的帧数 (同stage的frameRate)
		 */
		public function get frameRate():int
		{
			return _frameRate;
		}
		
		/**
		 * @private
		 */
		public function set frameRate(value:int):void
		{
			if(_frameRate == value)
				return;
			
			_frameRate = value;
			if(!running)
				return;
			var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			bmpMgr.removeRender(doRender);
			bmpMgr.addRender(doRender,frameRate);
		}
		
		/**
		 * 是否正在播放
		 * @return 
		 */
		public function get running():Boolean 
		{
			return BmpRenderMgr.getInstance().hasRender(doRender);
		}
		
		protected var _currentBmtInfo:BmpRenderInfo;
		
		/**
		 * 当前帧数据
		 * @return 
		 
		public function get currentBmpInfo():BmpRenderInfo 
		{
			return _currentBmtInfo;
		}*/

		/**
		 * 当前帧渲染信息
		 
		public function set currentBmtInfo(value:BmpRenderInfo):void
		{
			if(value == _currentBmtInfo)
				return;
			
			_currentBmtInfo = value;
		}*/
		
		/**
		 * 从缓存获取渲染信息
		 */
		protected function getBmpFrame():BmpRenderInfo
		{
			return BmpRenderMgr.getInstance().getNewCache(_sourceKey,currentFrame,_source);
		}
		
		/**
		 * 刷新当前帧信息
		 */
		protected function commitBmtInfo():void
		{
			var value:BmpRenderInfo = getBmpFrame();
			if(value == null)
				return;
			if(_currentBmtInfo == value && bitmapData == value.getFrameBitmapData(_currentFrame))
				return;
			
			// 把旧的数据丢入回收管理
			if(_currentBmtInfo != value && _currentBmtInfo)
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			if(_currentBmtInfo)
				_lastKey = _currentBmtInfo.key;
			
			_currentBmtInfo = value;
			
			if(value == null)
			{
				bitmapData = null;
				removeExpireEvt();
			}
			
			var bmpd:BitmapData = value.getFrameBitmapData(currentFrame);
			
			if(bmpd == null)
			{
				value.addEventListener(Event.COMPLETE,onBmpdComplete);
				actExpireTimer();
				return;
			}
			
			onBmpdComplete();
		}
		
		/**
		 * 上帧显示的位图键
		 */
		private var _lastKey:String;
		
		/**
		 * 数据渲染完成
		 */
		private function onBmpdComplete(e:Event=null):void
		{
			var bmpd:BitmapData = _currentBmtInfo.getFrameBitmapData(_currentFrame);
			if(!_currentBmtInfo || !bmpd)
				return;
			
			_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			if(_lastKey != _currentBmtInfo.key)
			{
				if(_lastKey)
				{
					var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
					bmpMgr.dropCache(_lastKey);
					_lastKey = null;
				}
				_currentBmtInfo.useCount = _currentBmtInfo.useCount + 1;
			}
			
			bitmapData = _currentBmtInfo.getFrameBitmapData(currentFrame);
			if(bitmapData)
				transform.matrix = _currentBmtInfo.getFrameMaxtrix(_currentFrame);
			actExpireTimer();
		}
		
		/**
		 * 当前帧标签
		 * @return 
		 
		public function get currentLabel():String
		{
			if(_currentBmtInfo)
				return _currentBmtInfo.name;
			else
				return null;
		}*/
		
		/**
		 * 最大帧数
		 * @return 
		 */
		public function get totalFrames():int
		{
			if(!source || !(source is MovieClip))
				return 1;
			return (source as MovieClip).totalFrames;
		}
		
		private var _source:DisplayObject;
		
		private var _sourceKey:String;
		
		public function set source(value:DisplayObject):void
		{
			if(value == _source)
				return;
			
			_source = value;
			_sourceKey = getQualifiedClassName(value);
			x = 0;
			y = 0;
			resetMCValue();
		}
		
		private function resetMCValue():void
		{
			if(!source || !(source is MovieClip))
			{
//				doRender();
				_currentFrame = 0;
				commitBmtInfo();
				return;
			}
			_labelMap = {};
			var mc:MovieClip = (source as MovieClip);
			for each (var fl:FrameLabel in mc.currentLabels) 
			{
				_labelMap[fl.name] = fl.frame;
			}
			
			repeatStart = 1;
			repeatEnd = totalFrames;
			
			// 为了提高性能，mc用完最好就停掉
			mc.stop();
			
			// 立马渲染一次
			doRender(frameRate);
			
			if(autoPlay)
				play();
			else
				stop();
		}
		
		/**
		 * 源mc
		 */
		public function get source():DisplayObject
		{
			return _source;
		}
		//----------------------------------------------------
		// 位图过期管理 (位图数据移出舞台一段时间会调用过期函数)
		//----------------------------------------------------
		
		private var _expireTimer:ExpireTimer;
		
		/**
		 * 过期管理
		 */
		public function get expireTimer():ExpireTimer
		{
			return _expireTimer;
		}
		
		/**
		 * 激活过期管理器
		 */
		protected function actExpireTimer():ExpireTimer
		{
			if(etr)
			{
				if(!etr.hasAct)
				{
					etr.active(this);
					etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
					etr.addEventListener(ExpireTimer.RESET,onReset);
				}
				return etr;
			}
			var etr:ExpireTimer = new ExpireTimer(this,2*60*1000);
			etr.addEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			etr.addEventListener(ExpireTimer.RESET,onReset);
			return etr;
		}
		
		/**
		 * 移除过期事件
		 */
		private function removeExpireEvt():void
		{
			if(_currentBmtInfo)
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
			
			expireTimer.removeEventListener(ExpireTimer.RESET,onReset);
			expireTimer.removeEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			expireTimer.dispose();
		}
		
		/**
		 * 重置
		 * @param e
		 */
		protected function onReset(e:Event=null):void
		{
			doRender();
		}
		
		public function clearBitmapData():void
		{
			bitmapData = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set bitmapData(value:BitmapData):void
		{
			if(_currentBmtInfo && value == null && value != bitmapData)
			{
				_currentBmtInfo.removeEventListener(Event.COMPLETE,onBmpdComplete);
				var bmpMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
				bmpMgr.dropCache(_currentBmtInfo.key);
			}
			super.bitmapData = value;
		}
		
		/**
		 * 当前显示的位图资源过期回收
		 * @param e
		 */
		protected function onExpired(e:Event=null):void
		{
			bitmapData = null;
			_currentBmtInfo = null;
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			stop();
			
			onExpired();
			source = null;
			
			if(expireTimer)
			{
				expireTimer.removeEventListener(ExpireTimer.RESET,onReset);
				expireTimer.removeEventListener(ExpireTimer.EXPIRED_RECYLE,onExpired);
			}
			_frameFunMap = {};
			_labelMap = {};
		}
	}
}