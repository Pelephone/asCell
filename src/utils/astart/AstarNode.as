package utils.astart
{
	/**
	 * 节点，地图vo可继承此对象
	 * 即roadVO->Node
	 * @author Pelephone
	 */	
	public class AstarNode implements IAstarNode
	{
		public var costMultiplier:Number = 1.0;		//这么值用于表示不同地形影响估价,1.0表示不影响，2表示经过后估价*2
		public var index:int;
		public var f:Number;
		public var g:Number;
		public var h:Number;
		public var step:int;		// 频数距离，即此节点离开始点的步数
		public var parent:AstarNode;
		//f表示路径评分、g表示当前移动耗费、h表示当前估计移动耗费
		//公式：f = g + h，表示路径评分的算法
		//ng值表示以父标记为主标记的g值
		//nh值表示当前估计移动耗费
		
		private var _walkable:Boolean = true;
		
		public function AstarNode(id:int)
		{
			index = id;
		}
		
		// 通过index计算此节点在第几行
		public function get row():int
		{
			return int(index/AStarHexagon.numCols);
		}
		
		public function set col(value:int):void
		{
		}
		
		public function set row(value:int):void
		{
		}
		
		
		// 通过index计算此节点在第几列
		public function get col():int
		{
			return index%AStarHexagon.numCols;
		}
		
		public function get walkable():Boolean
		{
			return _walkable;
		}
		
		// 此节点是否能通过
		public function set walkable(value:Boolean):void
		{
			_walkable = value;
		}
	}
}