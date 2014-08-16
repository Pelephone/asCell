package asSkinStyle.data;

import flash.display.DisplayObject;

/**
 * 组合模式的组件
 * @author Pelephone
 * @website http://cnblogs.com/pelephone
 */
class StyleComposite
{
	private var _name:String;
	var parentNode:StyleComposite;
	private var _styleVars:Dynamic;
	
	public var _children:Array<StyleComposite>;
	// 子项名称与所在_children位置index的映射,用于通过名字查找返回组件
	private var _childrenNameHm:Map<String,Int>;
	
	public function new(sNodeName:String,cssVars:Dynamic=null)
	{
		_styleVars = cssVars;
		setName(sNodeName);
		this._children = [];
		this._childrenNameHm = new Map<String,Int>();
	}
	
	public function add(c:StyleComposite):Void
	{
		c.parentNode = this;
		_children.push(c);
		_childrenNameHm.set(c.getName(), (_children.length - 1));
	}
	
	public function remove(c:StyleComposite):Void
	{
		if (c === this) {
			// 移出所有子节点
			for (i in i..._children.length) {
				safeRemove(_children[i]); // 移出子节点
			}
			this._children = new Vector.<StyleComposite>(); // 移出子项的引用
			this.removeParentRef(); // 断开父类的引用
			this._childrenNameHm = {};
		} else {
			for (j in j..._children.length) {
				if (_children[j] == c) {
					safeRemove(_children[j]); // 移出子节点
					_children.splice(j, 1); // 移出引用
				}
			}
		}
	}
	
	/**
	 * 移除父节点
	 */
	private function removeParentRef():Void { 
		this.parentNode = null;
	}
	
	/**
	 * 更新子项绑定的位置
	 * @param value
	 * @param newName
	 
	private function upDateChildName(oldName:String,newName:String):Void
	{
		var reId:Int = int(_childrenNameHm[oldName]);
		delete _childrenNameHm[oldName];
		_childrenNameHm[newName] = reId;
	}*/
	
	/**
	 * 安全移除
	 * @param c
	 */
	public function safeRemove(c:StyleComposite):Void
	{
		if (c.getComposite()) {
			c.remove(c);
		} else {
			c.removeParentRef();
		}
	}
	
	///////////////////////////////////////
	// get/set
	//////////////////////////////////////
	
	/**
	 * 获取此节点的子项
	 * @return 
	 
	public function getChildren():Array
	{
		return _children;
	}*/
	
	/**
	 * 返回子项数量
	 * @return 
	 */
	public function numChildren():Int
	{
		return _children.length;
	}
	
	/**
	 * 获取节点下面的所有的子项
	 * @return 
	 
	public function getAllChildren():Array
	{
		var resObj:Array = [this];
		for each (var itr:CssComposite in _children) 
		{
			resObj.concat(itr.getAllChildren());
		}
		
		return null;
	}*/
	
	/**
	 * 通过组合子项生成结构同此组合一样的显示容器
	 * @return 
	 */
	public function makeDisps():DisplayObject
	{
		return null;
	}
	
	/**
	 * 获取第n个子项
	 * @param n
	 * @return 
	 */
	public function getChildByIndex(n:Int):StyleComposite
	{
		if ((n >= 0) && (n < _children.length)) {
			return _children[n];
		} else {
			return null;
		}
	}
	
	/**
	 * 通过名字获取组件
	 * @param n
	 * @return 
	 */
	public function getChildByName(n:String):StyleComposite
	{
/*			for each (var childCpe:StyleComposite in _children) 
		{
			if(childCpe.getName()==n) return childCpe;
		}
		return null;*/
//			if(!_childrenNameHm[n]) return null;
		if (!_childrenNameHm.exists(n))
		return null;
		else
		return getChildByIndex(_childrenNameHm.get(n));
	}
	
	/**
	 * 获取父节点
	 * @return 
	 */
	public function getParent():StyleComposite
	{
		return this.parentNode;
	}
	
	/**
	 * 设置父节点
	 * @param compositeNode
	 */
	public function setParent(compositeNode:StyleComposite):Void
	{
		this.parentNode = compositeNode;
	}
	
	/**
	 * 获取组件
	 * @return 
	 */
	public function getComposite():StyleComposite
	{ 
		return null;
	}
	
	/**
	 * 设置组件名
	 * @param value
	 */
	public function setName(value:String):Void
	{
//			if(parentNode)
//			{
//				parentNode.upDateChildName(getName(),value);
//			}
		_name = value;
	}
	
	/**
	 * 获取组件名
	 * @return 
	 */
	public function getName():String
	{
		return _name;
	}
	
	/**
	 * 组件扩展对象
	 * @return 
	 */
	public function getStyleVars():Dynamic
	{
		return _styleVars;
	}
	
	/**
	 * @param value
	 */
	public function setStyleVars(value:Dynamic):Void
	{
		_styleVars = value;
	}
}