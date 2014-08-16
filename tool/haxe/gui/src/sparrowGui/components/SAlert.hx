package sparrowGui.components;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import sparrowGUI.components.Component;
import sparrowGui.components.item.SButton;
import sparrowGui.skinStyle.StyleKeys;

/**
 * 警告
 * @author Pelephone
 */
class SAlert extends Component
{
	/**
	 * 按钮默认字
	 */
	inline private static var BTN_DEFAULT_STRING:String = "ok";

	public function new() 
	{
		super();
	}
	
/*	// 遮挡层
	public var translucent:DisplayObject = null;
	// 父容器
	public var parentContainer:DisplayObjectContainer = null;*/
		
	//提示窗文字文本
	private var txtAlert:STextField;
	//动态按钮坐标
	private var posBtn:Point;
	// 背景
	private var bg:DisplayObject;
	
	// 按钮文字
	var btnStrArr:Array<String> = [];
	var btnLs:Array<DisplayObject>;
	var spacing:Int = 10;
	
	override private function buildSetUI() 
	{
		super.buildSetUI();
		
		bg = this.getChildByName("bg");
		txtAlert = cast this.getChildByName("txtLabel");
		
		posBtn = new Point(150, txtAlert.y + txtAlert.height + 20);
		btnLs = [];
	}
	
	var backCall:Int -> Void = null;
	
	/**
	 * 弹出警告窗
	 * @param alertTxt
	 * @param btnStr
	 * @param backFun 此方法是一次性的，窗体关闭后会立刻回收删除
	 */
	public function update(alertTxt:String,btnStr:String="确定",backFun:Int -> Void=null)
	{
		if(btnStr == null || btnStr.length == 0)
			btnStr = BTN_DEFAULT_STRING;

		btnStrArr = btnStr.split("|");
		backCall = backFun;
		
		txtAlert.htmlText = alertTxt;
		updateBtns();
	}
	
	// 创建按钮
	function newBtn(data:Dynamic):DisplayObject
	{
		var itm:SButton = new SButton();
		itm.data = data;
		return itm;
	}
		
	/**
	 * 通过字符数据生成按钮
	 */
	function updateBtns()
	{
		clearBtns();
		var itm:DisplayObject;
		for (i in 0...btnStrArr.length)
		{
			itm = newBtn(btnStrArr[i]);
			itm.name = Std.string(i);
			var lx:Int = Std.int(itm.width * btnStrArr.length * 0.5 + spacing * (btnStrArr.length - 1) * 0.5);
			itm.x = posBtn.x - lx + (itm.width+spacing)*i;
			itm.y = posBtn.y - itm.height;
			itm.addEventListener(MouseEvent.CLICK, onBtnClick);
			btnLs.push(itm);
			addChild(itm);
		}
	}
	
	// 按钮点击
	private function onBtnClick(e:MouseEvent):Void 
	{
		if (backCall == null)
		return;
		var tar:DisplayObject = cast e.currentTarget;
		var id:Int = Std.parseInt(tar.name);
		backCall(id);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	function clearBtns()
	{
		for (itm in btnLs)
		{
			itm.removeEventListener(MouseEvent.CLICK, onBtnClick);
			if (itm.parent != null)
			itm.parent.removeChild(itm);
		}
		btnLs = [];
	}
	
	override private function getSkinId():String 
	{
		return StyleKeys.ALERT;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		backCall = null;
		clearBtns();
	}
}