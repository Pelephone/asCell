package anim;
import bitmapEngine.IMovieClip;
import haxe.Timer;
import timerUtils.StaticEnterFrame;

/**
 * 基本动画组件
 * @author Pelephone
 */
class AnimBase implements IMovieClip
{

	public function new() 
	{
		scriptMap = new Map < Int, Void->Void > ();
	}
	
	function draw()
	{
	}
	
	function onEnterFrame() 
	{
		var curTime:Float = Timer.stamp();
		var goFrame:Int = Std.int(frameRate * (curTime-playTime));
		
		var toFrame:Int = Std.int(Math.abs(repeatEnd - repeatStart) + 1);
		var repeatTime:Int = Std.int(goFrame / toFrame);

		if (scriptMap.exists(_currentFrame))
		scriptMap.get(_currentFrame)();
		
		var tFrame:Int = Std.int(goFrame % toFrame);
		if (repeatCount == 0)
		{
			currentFrame = repeatStart + tFrame;
		}
		else
		{
			if ((repeatCount - repeatTime) <= 0)
			{
				repeatCount = 0;
				currentFrame = repeatEnd;
				if (repeatComplete != null)
				repeatComplete();
				stop();
			}
			else
			{
				currentFrame = repeatStart + tFrame;
			}
		}
	}
	
	/* INTERFACE bitmapEngine.IMovieClip */
	
	public function play():Void 
	{
		playTime = Timer.stamp();
		repeatCount = 0;
		repeatStart = 1;
		repeatEnd =  totalFrames;
		StaticEnterFrame.addFrameListener(onEnterFrame);
	}
	
	public function stop():Void 
	{
		if (repeatComplete != null)
		repeatComplete = null;
		repeatCount = 0;
		StaticEnterFrame.removeFrameListener(onEnterFrame);
	}
	
	public function gotoAndPlay(frame:Int):Void 
	{
		repeatCount = 1;
		repeatEnd = _totalFrames;
		currentFrame = frame;
		play();
	}
	
	public function gotoAndStop(frame:Int):Void 
	{
		currentFrame = frame;
		stop();
	}
	
	// 播放开始时间
	var playTime:Float;
	
	var repeatStart:Int = 0;
	var repeatEnd:Int = 0;
	var repeatCount:Int = 0;
	// 循环播放结束时执行函数
	var repeatComplete:Void->Void = null;
	
	public function repeatPlay(startFrame:Int = 0, endFrame:Int = 0, repeat:Int = 0, complete:Void->Void=null):Void 
	{
		if (startFrame < 1)
		startFrame = 1;
		if (endFrame < 1)
		endFrame = _totalFrames;
		
		repeatStart = startFrame;
		repeatEnd = endFrame;
		repeatCount = repeat;
		
		currentFrame = startFrame;
		playTime = Timer.stamp();
		repeatComplete = complete;
		StaticEnterFrame.addFrameListener(onEnterFrame);
	}
	
	public function prevFrame():Void 
	{
		currentFrame = _currentFrame - 1;
		stop();
	}
	
	public function nextFrame():Void 
	{
		currentFrame = _currentFrame + 1;
		stop();
	}
	
	var scriptMap:Map < Int, Void->Void > ;
	
	public function addFrameScript(frame:Int, frameFunc:Void -> Void = null):Void 
	{
		scriptMap.set(frame, frameFunc);
	}
	
	public function removeFrameScript(frame:Int):Void 
	{
		scriptMap.remove(frame);
	}
	
	/**
	 * 当前帧 （从1开始）
	 */
	public var currentFrame(get,set):Int;
	var _currentFrame:Int = 0;
	
	function get_currentFrame():Int
	{
		return _currentFrame;
	}
	
	function set_currentFrame(value:Int):Int
	{
		if (value < 1)
		value = 1;
		else if (value > _totalFrames)
		value = _totalFrames;
		
		if (_currentFrame == value)
		return _currentFrame;
		
		_currentFrame = value;
		draw();
		return _currentFrame;
	}
	
	/**
	 * 此mc的帧率(每秒播放N帧)
	 */
	public var frameRate(get,set):Int;
	var _frameRate:Int = 60;
	
	function get_frameRate():Int
	{
		return _frameRate;
	}
	
	function set_frameRate(value:Int):Int
	{
		if (_frameRate == value)
		return _frameRate;
		_frameRate = value;
		return _frameRate;
	}
	
	/**
	 * 最大帧数
	 */
	public var totalFrames(get,set):Int;
	var _totalFrames:Int = 1;
	
	function get_totalFrames():Int
	{
		return _totalFrames;
	}
	
	function set_totalFrames(value:Int):Int
	{
		if (value < 1)
		value = 1;
		if (_totalFrames == value)
		return _totalFrames;
		_totalFrames = value;
		if (_currentFrame > _totalFrames)
		currentFrame = _totalFrames;
		
		stop();
		return _totalFrames;
	}
	
	public function dispose()
	{
		for (itm in scriptMap.keys()) 
		{
			scriptMap.remove(itm);
		}
	}
}