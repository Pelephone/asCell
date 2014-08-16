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
package utils
{
	
	/**
	 * 移动对象参数
	 * @author Pelephone
	 */
	public class TweenVars
	{
		/**
		 * 开始时间点
		 */
		public var startTime:int;
		
		/**
		 * 用时(毫秒)
		 */
		public var duration:int;
		
		/**
		 * 动画进度率
		 */
		public var ratio:Number;
		
		/**
		 * 开始X坐标
		 */
		public var startX:int;
		
		/**
		 * 开始Y坐标
		 */
		public var startY:int;
		
		/**
		 * 结束x坐标
		 */
		public var endX:int;
		
		/**
		 * 结束y坐标
		 */
		public var endY:int;
		
		/**
		 * 目标对象
		 */
		public var target:Object;
		
		/**
		 * 更新时执行方法
		 */
		public var onUpdate:Function;
		
		/**
		 * 执行参数
		 */
		public var onUpdateParams:Array = [];
		
		/**
		 * 完成
		 */
		public var onComplete:Function;
		
		/**
		 * 完成时参数
		 */
		public var onCompleteParams:Array = [];
		
		/**
		 * 方向
		 
		public var direct:Number;*/
		
		/**
		 * 每秒移动的像素
		 
		public var step:int;*/
		
		/**
		 * 每帧x轴偏移量
		 
		public var offsetX:Number = 0;*/
		
		/**
		 * 每帧y轴偏移量
		 
		public var offsetY:Number = 0;*/
		
		/**
		 * 其它参数
		 */
		public var params:Object;
		
		/**
		 * 缓动动画
		 */
		public var ease:Function;
		
		/**
		 * 移出时的时间标记
		 */
		public var stopTime:int;
		
		/**
		 * 缓动带参
		 
		public var easeParams:Array = [];*/
		
		/**
		 * 是否已销毁不能再使用
		 
		public var isDispose:Boolean = false;*/
		
		/**
		 * 完成执行方法
		 
		public var onComplete:Function;*/
		
		/**
		 * 完成执行参数
		 
		public var onCompleteParams:Array = [];*/
		/**
		 * 经过时间(毫秒)，如果此值>0，则经过一定时间移动会停止
		 
		public var durtaion:int = -1;*/
	}
}