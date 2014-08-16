package utils.astart
{
	/**
	 * 四边形的A*寻路算法
	 * %算出列,/算出行
	 * @author Pelephone
	 */	
	public class AStar4
	{
		//////// 方向
		public static const DIRECT_UP:int = 1;		//方向上
		public static const DIRECT_RIGHT:int = 0;		//方向右
		public static const DIRECT_DOWN:int = 2;		//方向下
		public static const DIRECT_LEFT:int = 3;		//方向左
		//
		
		public static var numCols:int = 12;	//列数地图节点是用index表示行列所以用colNum
		public static var numRows:int = 8;	//行数
		
		private static const straightCost:int = 1;	//左右两边的步数值
		private static var heuristic:Function = diagonal;
		
		public function AStar4()
		{
		}
		
		/**
		 * 通过地图数组查找最短路径
		 * @param roads
		 * @param startId
		 * @param endId
		 * @param excluded		排除数组，里面是节点astartNode
		 * @return 
		 */		
		public static function findPath(roads:Vector.<AstarNode>,startId:int,endId:int
										,excluded:Array=null):Vector.<AstarNode>
		{
			var startNode:AstarNode = roads[startId] as AstarNode;
			var endNode:AstarNode = roads[endId] as AstarNode;
			
			var openArr:Array = new Array();
			var closedArr:Array = new Array();
			
			startNode.g = 0;
			startNode.h = heuristic(startNode,endNode);
			startNode.f = startNode.g + startNode.h;
			
			var node:AstarNode = startNode;
			while(node != endNode)
			{
				var nodeIndex:int = node.row * numCols + node.col;
				var roundArr:Vector.<int> = getNodeRound(nodeIndex);
//				var roundArr:Vector.<int> = getNodeRound(node.index);
				for each(var id:int in roundArr){
					//测试点与上一点进行比对
					var test:AstarNode = roads[id] as AstarNode;
					// 测试点不是上点，测试点不能通过
					var isExclued:Boolean = (excluded && excluded.indexOf(test)>=0);
					if(test == node || !test.walkable || !test || isExclued)
					{
						continue;
					}
					// 直接成本
					var cost:Number = straightCost;
					var g:Number = node.g + cost * test.costMultiplier;
					var h:Number = heuristic(test,endNode);
					var f:Number = g + h;
					// 是否在打或者关闭数组内
					if(openArr.indexOf(roads[id])>=0 || closedArr.indexOf(roads[id])>=0)
					{
						if(test.f > f)
						{
							test.f = f;
							test.g = g;
							test.h = h;
							test.parent = node;
						}
					}
					else
					{
						test.f = f;
						test.g = g;
						test.h = h;
						test.parent = node;
						openArr.push(test);
					}
				}
				
				closedArr.push(node);
				if(openArr.length == 0)
				{
					trace("no path found");
					return null;
				}
				openArr.sortOn("f", Array.NUMERIC);
				
				
				node = openArr.shift() as AstarNode;
			}
			
			var path:Vector.<AstarNode> = new Vector.<AstarNode>();
			node = endNode;
			path.push(node);
			while(node != startNode)
			{
				node = node.parent;
				path.unshift(node);
			}
			return path;
		}
		
		/**
		 * 获取某点一定步数范围内能移动的数组节点
		 * @param roads		路径的一唯数组	
		 * @param index		节点
		 * @param step		步数
		 * @param excluded		排除点<astartNode>
		 */		
		public static function getRoundRoads(roads:Vector.<AstarNode>,index:int,step:int,excluded:Array=null):Array
		{
			if(step<0) return [];
			var tArr:Array = [roads[index]],preInd:int=0,i:int,pot:int=0;
			while(--step>=0){
				preInd = tArr.length-1;
				for(i=pot;i<(preInd+1);i++){
					for each(var id:int in getNodeRound(tArr[i].index)){
						var node:AstarNode = roads[id] as AstarNode;
						var isExclued:Boolean = (excluded && excluded.indexOf(node)>=0);
						if(!node.walkable || tArr.indexOf(node)>=0 || isExclued) continue;
						tArr.push(node);
					}
				}
				pot = preInd;
			}
			
			return tArr;
		}
		
		/**
		 * 获取某点左右两边的数组
		 * @param cuId	角色踩着的点
		 * @param len	左右范围
		 * @return 
		 */		
		static public function getRLArr(roads:Vector.<AstarNode>,cuId:int,len:int):Array
		{
			var arr:Array = [];
			for(var i:int=(-1*len);i<=len;i++){
				var o:int = (cuId+i);
				var node:AstarNode = roads[o] as AstarNode;
				if(!node.walkable || !isSameLine(o,cuId)) continue;
				arr.push(node);
			}
			return arr;
		}
		
		/**
		 * 获取某点某方向直线上的节点数组<AstarNode>
		 * @param roads		
		 * @param direct		方向,是数字,数字分别表示前上,前,前下,后上,后,后下
		 * @param startId		始点
		 * @param area			长度
		 * @param isRight		面向
		 * @param excluded		排除点
		 * @return
		 */		
		static public function getDirectLine(roads:Vector.<AstarNode>,direct:int,startId:int,area:int,
											 toward:int=0,excluded:Array=null):Array
		{
			if(area<0) return [];
			var arr:Array = [roads[startId]];
			while(area){
				var nextNode:AstarNode;
				switch(direct){
					case DIRECT_UP:
						nextNode = getUpDirect(roads,startId);
						break;
					case DIRECT_DOWN:
						nextNode = getDownDirect(roads,startId)
						break;
					case DIRECT_RIGHT:
						nextNode = (toward==1)?getRightDirect(roads,startId):getLeftDirect(roads,startId);
						break;
					case DIRECT_LEFT:
						nextNode = (toward!=1)?getLeftDirect(roads,startId):getRightDirect(roads,startId);
						break;
				}
				if(!nextNode) break;
				var isExclued:Boolean = (excluded && excluded.indexOf(nextNode)>=0);
				if(nextNode.walkable || isExclued){
					arr.push(nextNode);
				}
				
				startId = nextNode.row * numCols + nextNode.col;
//				startId = nextNode.index;
				area--;
			}
			
			return arr;
		}
		
		// 获取某点四周的点的index
		private static function getNodeRound(index:int):Vector.<int>
		{
			var arr:Vector.<int> = new Vector.<int>();
			var col:int = index%numCols;
			var row:int = int(index/numCols);
			if(col>0) arr.push(index-1);					//左
			if(col<(numCols-1)) arr.push((index+1));		//右
			if(row>0) arr.push(index-numCols);			//上
			if(row<(numRows-1)) arr.push(index+numCols);	//下
			return arr;
		}
		
		//判断周围某点是否超出合法,合法则加入数组
		static private function isRoundArea(rid:int,cid:int):Boolean
		{
			if(Math.abs(rid%numCols-cid%numCols)>3) return false;
			if(rid>=(numCols*numRows) || rid<0) return false;
			return true;
		}
		
		//判断两点是否在同一行
		static private function isSameLine(rid:int,cid:int):Boolean
		{
			if(int(rid/numCols)!=int(cid/numCols)) return false;
			if(rid>=(numCols*numRows) || rid<0) return false;
			return true;
		}
		
		////////////////////////////////
		// 以下是启发函数
		/**
		 * 用两点距离写的启发函数
		 
		 private static function p1fHeuristic(node:AstarNode,endNode:AstarNode):Number
		 {
		 return Point.distance(RoadShap.getPt(node.index),RoadShap.getPt(endNode.index))/20 * straightCost;
		 } */
		
		/**
		 * 曼哈顿何启发函数
		 */	
		private static function manhattan(node:AstarNode,endNode:AstarNode):Number
		{
			return Math.abs(node.col - endNode.col) * straightCost + Math.abs(node.row + endNode.row) * straightCost;
		}
		
		/**
		 * 欧几里得几何启发函数
		 */		
		private static function euclidian(node:AstarNode,endNode:AstarNode):Number
		{
			var tmp:Number = !(node.row%2)?(straightCost/2):0;
			var tmp2:Number = !(endNode.row%2)?(straightCost/2):0;
			var dx:Number = Math.abs(node.col - endNode.col + tmp + tmp2);
			var dy:Number = Math.abs(node.row - endNode.row);
			return Math.sqrt(dx * dx + dy * dy) * straightCost;
		}
		
		/**
		 * 对角启发函数
		 */	
		private static function diagonal(node:AstarNode,endNode:AstarNode):Number
		{
			var tmp:Number = !(node.row%2)?(straightCost/2):0;
			var tmp2:Number = !(endNode.row%2)?(straightCost/2):0;
			var dx:Number = Math.abs(node.col - endNode.col + tmp + tmp2);
			var dy:Number = Math.abs(node.row - endNode.row);
			var diag:Number = Math.min(dx, dy);
			var straight:Number = dx + dy;
			return straightCost * diag + straightCost * (straight - 2 * diag);
		}
		
		
		
		///////////////////////////////////////////////
		// 六方向的方位
		
		// 获取某点前上方节点
		static private function getUpDirect(roads:Vector.<AstarNode>,startId:int):AstarNode
		{
			var nextId:int = startId-numCols;
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点下方节点
		static private function getDownDirect(roads:Vector.<AstarNode>,startId:int):AstarNode
		{
			var nextId:int = startId+numCols;
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点右方节点
		static private function getRightDirect(roads:Vector.<AstarNode>,startId:int):AstarNode
		{
			var nextId:int = startId+1;
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点左方节点
		static private function getLeftDirect(roads:Vector.<AstarNode>,startId:int):AstarNode
		{
			var nextId:int = startId-1;
			return getNextNode(roads,startId,nextId);
		}
		
		// 判断获取下一节点是否合法，不合法返回空
		static private function getNextNode(roads:Vector.<AstarNode>,startId:int,nextId:int):AstarNode
		{
			if(!isRoundArea(startId,nextId)) return null;
			else return roads[nextId] as AstarNode;
		}
	}
}