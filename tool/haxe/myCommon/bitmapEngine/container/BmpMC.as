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
package bitmapEngine.container
{
	import bitmapEngine.bak.BitmapConvert;
	import bitmapEngine.BmpRenderInfo;
	import bitmapEngine.BmpRenderMgr;
	import bitmapEngine.IMovieClip;
	
	import flash.display.Bitmap;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	/**
	 * movieClip转位图(多帧控制)
	 * @author Pelephone
	 */
	public class BmpMC extends Sprite implements IMovieClip
	{
		public function BmpMC(mc:MovieClip=null)
		{
			_bitmap = new Bitmap();
			addChild(_bitmap);
			
			
			_frameFunMap = {};
			_labelMap = {};
			
			if(!mc) return;
			_convertClip = newConverClip(mc);
			resetMCValue();
			
			play();
		}
		
		/**
		 * 待渲染的位图
		 */
		protected var _bitmap:Bitmap;
		
		/**
		 * 新建转换组件
		 * @param source
		 * @return 
		 */
		protected function newConverClip(source:MovieClip):BitmapConvert
		{
			return new BitmapConvert(_bitmap,source);
		}
		
		private var _convertClip:BitmapConvert;
		
		/**
		 * 位图转换器
		 */
		public function get convertClip():BitmapConvert
		{
			return _convertClip;
		}
		
		/**
		 * 当前帧数据
		 * @return 
		 */
		public function get currentBmpInfo():BmpRenderInfo 
		{
			return _convertClip.currentBmtInfo;
		}
		
		//----------------------------------------------------
		// 播放相关
		//----------------------------------------------------
		
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
		private var playStartFrame:int;
		
		// 循环播放
		private var repeatCount:int;
		private var repeatEnd:int;
		private var repeatStart:int;
		
		/**
		 * 播放
		 */
		public function play():void
		{
			if(totalFrames<2){
				stop();
				return;
			}
			if(!running)
				BmpRenderMgr.getInstance().addRender(doRender,frameRate);
			
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
			var frmTime:Number = 1000/frameRate;
			// 经过时间停在帧
			var mFrm:int = (getTimer() - playStartTime)/frmTime + playStartFrame;
			
			currentFrame = mFrm%totFme + repeatStart;
			
//			trace(playStartFrame,totFme,currentFrame);
			
			var frameFunc:Function = _frameFunMap[currentFrame] as Function;
			if(frameFunc!=null)
				frameFunc.apply(null,[]);
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
			if(frame is String)
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
			_convertClip.currentFrame = getFrame(currentFrame-1);
			stop();
		}
		
		/**
		 * 停在下一帧
		 */
		public function nextFrame():void
		{
			currentFrame = getFrame(currentFrame+1);
			stop();
		}
		
		/**
		 * @private
		 */
		public function set currentFrame(value:int):void 
		{
			_convertClip.currentFrame = value;
		}
		
		/**
		 * 当前帧
		 * @return 
		 */
		public function get currentFrame():int 
		{
			return _convertClip.currentFrame;
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
			var renderMgr:BmpRenderMgr = BmpRenderMgr.getInstance();
			renderMgr.removeRender(doRender);
			renderMgr.addRender(doRender,frameRate);
		}
		
		/**
		 * 是否正在播放
		 * @return 
		 */
		public function get running():Boolean 
		{
			return BmpRenderMgr.getInstance().hasRender(doRender);
		}
		
		/**
		 * 当前帧标签
		 * @return 
		 
		public function get currentLabel():String
		{
			return currentBmpInfo.name;
		}*/
		
		public function get totalFrames():int
		{
			if(!source)
				return 1;
			return source.totalFrames;
		}
		
		public function set source(value:MovieClip):void
		{
			if(value == convertClip.source)
				return;
			
			resetMCValue();
			
			convertClip.source = value;
		}
		
		private function resetMCValue():void
		{
			_labelMap = {};
			for each (var fl:FrameLabel in source.currentLabel) 
			{
				_labelMap[fl.name] = fl.frame;
			}
			
			repeatStart = 1;
			repeatEnd = totalFrames;
			
			// 为了提高性能，mc用完最好就停掉
			source.stop();
		}
		
		/**
		 * 源mc
		 */
		public function get source():MovieClip
		{
			return convertClip.source as MovieClip;
		}
		
		/**
		 * 销毁对象
		 */
		public function dispose():void
		{
			stop();
			_frameFunMap = {};
			_labelMap = {};
		}
	}
}