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
* WITHOUT WARRANTIES 
*/
package bitmapEngine
{
	
	/**
	 * 动画组件
	 * @author Pelephone
	 */
	public interface IMovieClip
	{
		/**
		 * 播放
		 */
		function play():void;
		/**
		 * 暂停
		 */
		function stop():void;
		/**
		 * 从某帧开始播放
		 * @param frame
		 */
		function gotoAndPlay(frame:Object):void;
		/**
		 * 跳转到某帧停止播放
		 * @param frame
		 */
		function gotoAndStop(frame:Object):void;
		/**
		 * 循环播放指定帧
		 * @param startFrame 开始帧,null表示第0帧
		 * @param endFrame 结束帧,null表示最后1帧
		 * @param repeat 循环次数，0表示无限循环
		 */
		function repeatPlay(startFrame:Object=null,endFrame:Object=null,repeat:int=0):void;
		/**
		 * 通过帧或者帧标签返回合法的帧数
		 * @param frame 帧或帧标签
		 */
		function getFrame(frame:Object):int;
		/**
		 * 停在上一帧
		 */
		function prevFrame():void;
		/**
		 * 停在下一帧
		 */
		function nextFrame():void;
		/**
		 * @private
		 */
		function set currentFrame(value:int):void;
		/**
		 * 当前帧
		 * @return 
		 */
		function get currentFrame():int;
		/**
		 * 给某帧添加方法，当对象播放到此帧时则执行方法,不用的时候记住要移除
		 * @param frame 帧，或者帧标签
		 * @param frameFunc 函数
		 */
		function addFrameScript(frame:Object,frameFunc:Function=null):void;
		/**
		 *  移除某帧上的方法函数
		 */
		function removeFrameScript(frame:Object):void;
		/**
		 * 帧率,每秒渲染的帧数 (同stage的frameRate)
		 */
		function get frameRate():int;
		/**
		 * @private
		 */
		function set frameRate(value:int):void;
		/**
		 * 最大帧数
		 * @return 
		 */
		function get totalFrames():int;
	}
}