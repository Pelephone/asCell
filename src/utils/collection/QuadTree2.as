package utils.collection
{
	import flash.geom.Rectangle;
	
	/**
	 * 2D平面四叉树 ，主要用于渲染动态地表和建筑
	 * @author Pelephone
	 */
	public class QuadTree2
	{
		// 上下左右四叉节点
		public var topLeft:QuadTree2;
		public var topRight:QuadTree2;
		public var bottomLeft:QuadTree2;
		public var bottomRight:QuadTree2;
		
		/**
		 * 树对应的矩形
		 */
		public var rect:Rectangle;
		/**
		 * 树的深度
		 */
		public var _depth:int;
		/**
		 * 最大深度
		 */
		public var _maxDepth:int
		
		public var _hw:int;
		public var _hh:int;
		public var _midX:int;
		public var _midY:int;
		
		
		public var children:Array = [];
		
		/**
		 * 
		 * @param p_rect
		 * @param p_maxDepth
		 * @param currentDepth
		 */
		public function QuadTree2(p_rect:Rectangle,p_maxDepth:int = 3,currentDepth:int = 0):void
		{
			this._depth = currentDepth;
			this._maxDepth = p_maxDepth;
			this.rect = p_rect;
			// 右移1表示1/2倍
			// num/2 == num>>1;
			this._hw = this.rect.width >> 1;
			this._hh = this.rect.height >> 1;
			this._midX = rect.x + _hw	
			this._midY = rect.y + _hh
		}
		
		public function preorder(Node:QuadTree2,Process:Function):void
		{
			Process(Node)
			if(Node.topLeft)preorder(Node.topLeft,Process)
			if(Node.topRight)preorder(Node.topRight,Process)
			if(Node.bottomLeft)preorder(Node.bottomLeft,Process)
			if(Node.bottomRight)preorder(Node.bottomRight,Process)
		}
		
		
		// obj {x:,y:,width:,height:}
		public function retrieve(obj:*):Array
		{
			var r:Array = []
			if(!this.topLeft)
			{
				r.push.apply(r,this.children)
				return r
			}
			
			//如果所取区块比本身区域还大，那么它所有子树的children都取出
			if( obj.x <= rect.x && obj.y<= rect.y && obj.x+obj.width>=rect.right && obj.y+obj.height >= rect.bottom)
			{
				r.push.apply(r,this.children)
				
				r.push.apply(r,this.topLeft.retrieve(obj))
				r.push.apply(r,this.topRight.retrieve(obj))
				r.push.apply(r,this.bottomLeft.retrieve(obj))
				r.push.apply(r,this.bottomRight.retrieve(obj))				   
				
				return r;
			} 
			
			//否则就只取对应的区域子树
			var objRight:Number = obj.x+obj.width
			var objBottom:Number = obj.y+obj.height
			
			// 完全在分区里 
			if((obj.x>rect.x) && (objRight< this._midX))
			{				
				if( obj.y > rect.y && objBottom <this._midY)
				{
					r.push.apply(r,this.topLeft.retrieve(obj))
					return r;
				}
				if(obj.y >this._midY && objBottom < this.rect.bottom)
				{
					r.push.apply(r,this.bottomLeft.retrieve(obj))
					return r;
				}
			}
			if(obj.x > _midX && objRight < rect.right)
			{
				if(obj.y>rect.y && objBottom < _midY)
				{
					r.push.apply(r,this.topRight.retrieve(obj))
					return r
				}
				if(obj.y > _midY && objBottom < rect.bottom)
				{
					r.push.apply(r,this.bottomRight.retrieve(obj))
					return r
				}
			}
			
			//只要有部分在分区里，也放到对应分区里，但注意可以重复放			
			
			//上边
			if(objBottom > rect.y && obj.y< _midY)
			{
				
				if(obj.x < _midX &&   objRight > rect.x  )
				{
					r.push.apply(r,this.topLeft.retrieve(obj));
				}
				if( obj.x < rect.right && objRight > _midX  )
				{
					r.push.apply(r,this.topRight.retrieve(obj));
				}
			}
			// 下边
			if(objBottom > _midY && obj.y < rect.bottom)
			{
				if(obj.x < _midX && objRight >rect.x)
				{
					r.push.apply(r,this.bottomLeft.retrieve(obj));
				}
				
				if(obj.x < rect.right && objRight >_midX)
				{
					r.push.apply(r,this.bottomRight.retrieve(obj));
				}
			}
			return r;
			
		}
		
		/**
		 * 将显示对象插入对应的树节点
		 * @param obj {x:,y:,width:,height:}
		 */
		public function insert(obj:* ):void
		{
			if(obj is Array)
			{
				for each(var i:* in obj)
				{
					insert(i)
				}
				return
			}
			
			// 如果不能切分或者obj比整个区域还大，就放到children里
			if(this._depth >= this._maxDepth ||( obj.x <= rect.x && obj.y<= rect.y && obj.x+obj.width>=rect.right && obj.y+obj.height >= rect.bottom))
			{
				
				this.children.push(obj)
				return;
			}
			
			if(!this.topLeft)
			{
				var d:int = this._depth + 1;
				this.topLeft = new QuadTree2(new Rectangle(this.rect.x,this.rect.y,this._hw,this._hh),this._maxDepth,d);
				this.topRight = new QuadTree2( new Rectangle(this.rect.x+this._hw,this.rect.y,this._hw,this._hh ),this._maxDepth,d);
				this.bottomLeft =new QuadTree2( new Rectangle(this.rect.x ,this.rect.y+this._hh,this._hw,this._hh),this._maxDepth,d);
				this.bottomRight= new QuadTree2( new Rectangle(this.rect.x+this._hw,this.rect.y+this._hh,this._hw,this._hh),this._maxDepth,d);		
			}
			
			var objRight:Number = obj.x+obj.width
			var objBottom:Number = obj.y+obj.height
			
			// 可以完全放到分区里就递归放到对应分区里
			if((obj.x>rect.x) && (objRight< this._midX))
			{				
				if(obj.y > rect.y && objBottom <this._midY)
				{
					this.topLeft.insert(obj);
					return;
				}
				if(obj.y >this._midY && objBottom < this.rect.bottom)
				{
					this.bottomLeft.insert(obj)
					return;
				}
			}
			if(obj.x > _midX && objRight < rect.right)
			{
				if(obj.y>rect.y && objBottom < _midY)
				{
					this.topRight.insert(obj)
					return
				}
				if(obj.y > _midY && objBottom < rect.bottom)
				{
					this.bottomRight.insert(obj)
					return
				}
			}
			
			//只要有部分在分区里，也放到对应分区里，但注意可以重复放			
			
			//上边
			if(objBottom > rect.y && obj.y< _midY)
			{
				
				if(obj.x < _midX &&   objRight > rect.x  )
				{
					this.topLeft.insert(obj);
				}
				if( obj.x < rect.right && objRight > _midX  )
				{
					this.topRight.insert(obj);
				}
			}
			// 下边
			if(objBottom > _midY && obj.y < rect.bottom)
			{
				if(obj.x < _midX && objRight >rect.x)
				{
					this.bottomLeft.insert(obj);
				}
				
				if(obj.x < rect.right && objRight >_midX)
				{
					this.bottomRight.insert(obj);
				}
			}
			
		}
		
		public function clear():void
		{
			this.children  = [];
			this.topLeft = this.topRight = this.bottomLeft = this.bottomRight = null;
		}
		
		public function toString():String
		{
			var s:String = "[QuadTreeNode> "
			var l:int = this.children.length
			s = s + ((l>1)? (l+" children"): (l+" child"));
			return s;
		}
		
		/**
		 *   节点按 <左上，右上，左下，右下>输出
		 */
		public function dump():String
		{
			var s:String = "";
			this.preorder(this, function(node:QuadTree2):void
			{
				var d:int = node._depth;
				for (var i:int = 0; i < d; i++)
				{
					if (i == d - 1)
						s += "+---";
					else
						s += "|    ";
				}
				s += node + "\n";
			});
			return s;
		}
	}
}