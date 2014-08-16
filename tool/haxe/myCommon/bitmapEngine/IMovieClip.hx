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
package bitmapEngine;
	
/**
 * 动画组件
 * @author Pelephone
 */
interface IMovieClip
{
	/**
	 * 播放
	 */
	function play():Void;
	/**
	 * 暂停
	 */
	function stop():Void;
	/**
	 * 从某帧开始播放
	 * @param frame
	 */
	function gotoAndPlay(frame:Int):Void;
	/**
	 * 跳转到某帧停止播放
	 * @param frame
	 */
	function gotoAndStop(frame:Int):Void;
	/**
	 * 循环播放指定帧
	 * @param startFrame 开始帧,null表示第0帧
	 * @param endFrame 结束帧,null表示最后1帧
	 * @param repeat 循环次数，0表示无限循环
	 */
	function repeatPlay(startFrame:Int=0,endFrame:Int=0,repeat:Int=0,complete:Void->Void=null):Void;
	/**
	 * 通过帧或者帧标签返回合法的帧数
	 * @param frame 帧或帧标签
	 
	function getFrame(frame:Int):Int;*/
	/**
	 * 停在上一帧
	 */
	function prevFrame():Void;
	/**
	 * 停在下一帧
	 */
	function nextFrame():Void;
	
	/**
	 * 给某帧添加方法，当对象播放到此帧时则执行方法,不用的时候记住要移除
	 * @param frame 帧，或者帧标签
	 * @param frameFunc 函数
	 */
	function addFrameScript(frame:Int,frameFunc:Void->Void=null):Void;
	/**
	 *  移除某帧上的方法函数
	 */
	function removeFrameScript(frame:Int):Void;
	/**
	 * 当前帧
	 */
	public var currentFrame(get, set):Int;
	/**
	 * 帧率,每秒渲染的帧数 (同stage的frameRate)
	 */
	public var frameRate(get,set):Int;
	/**
	 * 最大帧数
	 */
	public var totalFrames(get,set):Int;
}