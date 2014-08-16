package utils.astart
{
	/**
	 * 六边形A星算法
	 * 节点数组存储方式是一唯存储，通过列数判断行列
	 * @author Pelephone
	 */	
	public class AStarHexagon
	{
		//////// 方向
		public static const DIRECT_2_CLOCK:int = 2;		//2点钟方向
		public static const DIRECT_3_CLOCK:int = 3;		//3点钟方向
		public static const DIRECT_4_CLOCK:int = 4;		//4点钟方向
		public static const DIRECT_8_CLOCK:int = 8;		//8点钟方向
		public static const DIRECT_9_CLOCK:int = 9;		//9点钟方向
		public static const DIRECT_10_CLOCK:int = 10;		//10s点钟方向
		//
		
		public static var numCols:int = 12;	//列数地图节点是用index表示行列所以用colNum
		public static var numRows:int = 8;	//行数
		
		private static const straightCost:int = 1;	//左右两边的步数值
		private static var heuristic:Function = diagonal;
		
		public function AStarHexagon()
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
		public static function findPath(roads:Array,startId:int,endId:int,excluded:Array=null):Array
		{
//			var exarr:Array = [];
//			for each (var i:int in excluded) 
//				exarr.push(roads[i]);
			
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
				var roundArr:Array = getNodeRound(node.index);
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
			
			var path:Array = new Array();
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
		public static function getRoundRoads(roads:Array,index:int,step:int,excluded:Array=null):Array
		{
			if(step<0) return [];
//			var exarr:Array = [];
//			for each (var i:int in excluded) 
//				exarr.push(roads[i]);
				
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
		static public function getRLArr(roads:Array,cuId:int,len:int,excluded:Array=null):Array
		{
			var arr:Array = [];
			for(var i:int=(-1*len);i<=len;i++){
				var o:int = (cuId+i);
				var node:AstarNode = roads[o] as AstarNode;
				var isExclued:Boolean = (excluded && excluded.indexOf(node)>=0);
				if(!node.walkable || !isSameLine(o,cuId) || isExclued) continue;
				arr.push(node);
			}
			return arr;
		}
		/**
		 * 获取某点左右两边的数组
		 * @param cuId	目标点,
		 * @param len	左右范围
		 * @param isRight 目标点的左边为真,反则为假
		 */		
		static public function getLineArr(roads:Array,startId:int,len:int,toward:int=1,excluded:Array=null):Array
		{
			var arr:Array = [];
			for(var i:int=0;i<=len;i++){
				var nextId:int = toward?(startId+i):(startId-i);
				var node:AstarNode = roads[nextId] as AstarNode;
				var isExclued:Boolean = (excluded && excluded.indexOf(node)>=0);
				if(!isSameLine(nextId,startId) || !node.walkable) continue;
				arr.push(node);
			}
			return arr;
		}
		
		/**
		 * 获取某点某方向直线上的节点数组
		 * @param roads		
		 * @param direct		方向,是数字,数字分别表示前上,前,前下,后上,后,后下
		 * @param startId		始点
		 * @param area			长度
		 * @param toward		面向
		 * @param excluded		排除点
		 * @return
		 */		
		static public function getDirectLine(roads:Array,direct:int,startId:int,area:int,
											 toward:int=1,excluded:Array=null):Array
		{
			if(area<0) return [];
			
//			var exarr:Array = [];
//			for each (var i:int in excluded) 
//				exarr.push(roads[i]);
				
			var arr:Array = [roads[startId]];
			while(area){
				var nextNode:AstarNode;
				switch(direct){
					case DIRECT_2_CLOCK:
						nextNode = toward?get2ClockDirect(roads,startId):get10ClockDirect(roads,startId);
						break;
					case DIRECT_3_CLOCK:
						nextNode = toward?get3ClockDirect(roads,startId):get9ClockDirect(roads,startId);
						break;
					case DIRECT_4_CLOCK:
						nextNode = toward?get4ClockDirect(roads,startId):get8ClockDirect(roads,startId);
						break;
					case DIRECT_8_CLOCK:
						nextNode = (!toward)?get4ClockDirect(roads,startId):get8ClockDirect(roads,startId);
						break;
					case DIRECT_9_CLOCK:
						nextNode = (!toward)?get3ClockDirect(roads,startId):get9ClockDirect(roads,startId);
						break;
					case DIRECT_10_CLOCK:
						nextNode = (!toward)?get2ClockDirect(roads,startId):get10ClockDirect(roads,startId);
						break;
				}
				if(!nextNode) break;
				var isExclued:Boolean = (excluded && excluded.indexOf(nextNode)>=0);
				if(nextNode.walkable || isExclued){
					arr.push(nextNode);
				}
				startId = nextNode.index;
				area--;
			}
			
			return arr;
		}
		
		// 获取某点四周的点的index
		private static function getNodeRound(index:int):Array
		{
			var arr:Array = [];
			var col:int = index%numCols;
			var row:int = int(index/numCols);
			var tmp:int;
			if(col>0) arr.push(index-1);
			if(col<(numCols-1)) arr.push((index+1));
			if(row>0){
				arr.push((index-numCols));
				tmp = (index-numCols+((row%2)?1:-1));
				if(isRoundArea(index,tmp)) arr.push(tmp);
			}
			if(row<(numRows-1)){
				arr.push((index+numCols));
				tmp = (index+numCols+((row%2)?1:-1));
				if(isRoundArea(index,tmp)) arr.push(tmp);
			}
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
		
		// 获取某点前上方节点,即2点钟方向
		static private function get2ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (int(startId/numCols)%2)?(startId-numCols+1):(startId-numCols);
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点前方节点,即3点钟方向
		static private function get3ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (startId+1);
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点前下方节点,即4点钟方向
		static private function get4ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (int(startId/numCols)%2)?(startId+numCols+1):(startId+numCols);
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点后上方节点,即8点钟方向
		static private function get8ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (int(startId/numCols)%2)?(startId+numCols):(startId+numCols-1);
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点后方节点,即9点钟方向
		static private function get9ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (startId-1);
			return getNextNode(roads,startId,nextId);
		}
		
		// 获取某点后下方节点,即10点钟方向
		static private function get10ClockDirect(roads:Array,startId:int):AstarNode
		{
			var nextId:int = (int(startId/numCols)%2)?(startId-numCols):(startId-numCols-1);
			return getNextNode(roads,startId,nextId);
		}
		
		// 判断获取下一节点是否合法，不合法返回空
		static private function getNextNode(roads:Array,startId:int,nextId:int):AstarNode
		{
			if(!isRoundArea(startId,nextId)) return null;
			else return roads[nextId] as AstarNode;
		}
		
/*		public static function changef():void
		{
			var arr:Array = [p1fHeuristic,euclidian,diagonal,manhattan];
			var i:int = arr.indexOf(heuristic)+1;
			i = (i>=arr.length)?0:i;
			heuristic = arr[i];
			trace("改变启发函数",i);
		}*/
	}
}