package asSkinStyle.data
{
	import flash.display.DisplayObject;

	/**
	 * 组合模式的组件
	 * @author Pelephone
	 * @website http://cnblogs.com/pelephone
	 */
	public class StyleComposite
	{
		private var _name:String;
		internal var parentNode:StyleComposite = null;
		private var _styleVars:Object;
		
		protected var _children:Vector.<StyleComposite>;
		// 子项名称与所在_children位置index的映射,用于通过名字查找返回组件
		private var _childrenNameHm:Object;
		
		public function StyleComposite(sNodeName:String,cssVars:Object=null)
		{
			_styleVars = cssVars;
			setName(sNodeName);
			this._children = new Vector.<StyleComposite>();
			this._childrenNameHm = {};
		}
		
		public function add(c:StyleComposite):void
		{
			c.parentNode = this;
			_children.push(c);
			_childrenNameHm[c.getName()] = _children.length - 1;
		}
		
		public function remove(c:StyleComposite):void
		{
			if (c === this) {
				// 移出所有子节点
				for (var i:int = 0; i < _children.length; i++) {
					safeRemove(_children[i]); // 移出子节点
				}
				this._children = new Vector.<StyleComposite>(); // 移出子项的引用
				this.removeParentRef(); // 断开父类的引用
				this._childrenNameHm = {};
			} else {
				for (var j:int = 0; j < _children.length; j++) {
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
		private function removeParentRef():void { 
			this.parentNode = null;
		}
		
		/**
		 * 更新子项绑定的位置
		 * @param value
		 * @param newName
		 
		private function upDateChildName(oldName:String,newName:String):void
		{
			var reId:int = int(_childrenNameHm[oldName]);
			delete _childrenNameHm[oldName];
			_childrenNameHm[newName] = reId;
		}*/
		
		/**
		 * 安全移除
		 * @param c
		 */
		public function safeRemove(c:StyleComposite):void
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
		public function numChildren():int
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
		public function getChildByIndex(n:int):StyleComposite
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
			if(!_childrenNameHm.hasOwnProperty(n)) return null;
			return getChildByIndex(int(_childrenNameHm[n]));
		}
		
		/**
		 * 获取父节点
		 * @return 
		 */
		public function getParent():StyleComposite {
			return this.parentNode;
		}
		
		/**
		 * 设置父节点
		 * @param compositeNode
		 */
		internal function setParent(compositeNode:StyleComposite):void {
			this.parentNode = compositeNode;
		}
		
		/**
		 * 获取组件
		 * @return 
		 */
		internal function getComposite():StyleComposite { 
			return null;
		}
		
		/**
		 * 设置组件名
		 * @param value
		 */
		public function setName(value:String):void
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
		public function getStyleVars():Object
		{
			return _styleVars;
		}
		
		/**
		 * @param value
		 */
		public function setStyleVars(value:Object):void
		{
			_styleVars = value;
		}
	}
}