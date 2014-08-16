package utils.astart
{
	/**
	 * 六边形的A*算法
	 * @author pelephone
	 * 
	 */	
	public class AStar6
	{
		//每列有12个六边形，用于计算行数和列数
		static public var colNum:int = 12;
		static public var roadLen:int = 72
		
		/**
		 * 获得某个六边形，某范围内可移动到的六边形数组
		 * @param rid	六边形的索引
		 * @param area	步数区域
		 * @return 
		 */		
		static public function getAreaArr(rid:int,area:int,balks:Array=null):Array
		{
			var tArr:Array = [rid],preInd:int=0,i:int,pot:int=0;
			while(--area>=0){
				preInd = tArr.length-1;
				for(i=pot;i<(preInd+1);i++){
					for each(var o:int in getRoundArr(tArr[i])){
						if(tArr.indexOf(o)>=0) continue;
						if(balks && balks.indexOf(o)>=0) continue;
						tArr.push(o);
					}
				}
				pot = preInd;
			}
			
			return tArr;
		}
		
		/**
		 * 获得某六边形周围的六边形的数组
		 * @param rid
		 * @return 
		 */		
		static public function getRoundArr(cuId:int):Array
		{
			var resArr:Array = [(cuId+1),(cuId-1)];
			var rid:int,sd:int = (int(cuId/colNum)%2==0)?1:0;
			rid = cuId-colNum-sd;
			resArr.push(rid);
			rid = rid+1;
			resArr.push(rid);
			rid = cuId+colNum-sd;
			resArr.push(rid);
			rid = rid+1;
			resArr.push(rid);
			
			for(rid=0;rid<resArr.length;rid++){
				if(!isRountArea(resArr[rid],cuId)){
					resArr.splice(rid,1);
					rid--;
				}
			}
			return resArr;
		}
		
		//判断周围某点是否超出合法,合法则加入数组
		static private function isRountArea(rid:int,cid:int):Boolean
		{
			if(Math.abs(rid%colNum-cid%colNum)>3) return false;
			if(rid>=roadLen || rid<0) return false;
			return true;
		}
		
		/**
		 * 获取某点左右两边的数组
		 * @param cuId	角色踩着的点
		 * @param len	左右范围
		 * @return 
		 */		
		static public function getRLArr(cuId:int,len:int,balks:Array=null):Array
		{
			var arr:Array = [];
			for(var i:int=(-1*len);i<=len;i++){
				var o:int = (cuId+i);
				if(balks && balks.indexOf(o)>=0) continue;
				if(isSameLine(o,cuId))
					arr.push(o);
			}
			return arr;
		}
		/**
		 * 获取某点左右两边的数组
		 * @param cuId	目标点,
		 * @param len	左右范围
		 * @param isRight 目标点的左边为真,反则为假
		 * @return 
		 */		
		static public function getLineArr(tarId:int,len:int,isRight:Boolean=true):Array
		{
			var arr:Array = [];
			for(var i:int=0;i<=len;i++){
				var nextId:int = isRight?(tarId+i):(tarId-i);
				if(isSameLine(nextId,tarId))
					arr.push(nextId);
			}
			return arr;
		}
		
		//判断两点是否在同一行
		static private function isSameLine(rid:int,cid:int):Boolean
		{
			if(int(rid/colNum)!=int(cid/colNum)) return false;
			if(rid>=roadLen || rid<0) return false;
			return true;
		}
		
		/**
		 * 通过两路标索引得到距离步数
		 * @param ind1		路标索引1
		 * @param ind2		路标索引2
		 * @param totStep	最多判断步数，即两坐标相距的最大步数(加快运算效率)
		 * @return 
		 */		
		static public function getIndexDis(ind1:int,ind2:int,totStep:int=99):int
		{
			var tArr:Array = [ind1],preInd:int=0,i:int,pot:int=0,dis:int=0,arr2:Array;
			if(ind1==ind2) return 0;
			for(var j:int=1;j<=totStep;j++)
			{
				preInd = tArr.length-1;
				for(i=pot;i<(preInd+1);i++){
					arr2 = getRoundArr(tArr[i]);
					for each(var o:int in arr2){
						if(tArr.indexOf(o)<0){
							if(o==ind2) return j;
							tArr.push(o);
						}
					}
				}
				if(preInd==(tArr.length-1)) return -1;
				pot = preInd;
			}
			return -1;
		}
	}
}