package utils.collection
{
	/**
	 * 栈(先进后出)
	 * @author Pelephone
	 */	
	public class Stack{
		private var arr:Array;
		private var pointer:uint;
		
		function Stack(){
			this.arr = new Array();
			this.pointer = 0;
		}
		
		public function element():*{
			if(isEmpty()){
				return null;
			}else{
				if(this.pointer < 0){
					return null;
				}else{
					return this.arr[this.pointer--];
				}
			}
		}
		
		public function peek():*{
			if(isEmpty()){
				return null;
			}else{
				return this.arr[this.arr.length];
			}
		}
		
		public function pop():*{
			if(isEmpty()){
				return null;
			}else{
				this.pointer = (this.size()>1)?this.size() - 2:0;
				return this.arr.pop();
			}
		}
		
		public function add(object:*):Boolean{
			if(this.contains(object)){
				this.pointer = this.size() - 2;
				return false;
			}else{
				this.pointer = this.size() - 1;
				this.arr.push(object);
				return true;
			}
		}
		public function contains(object:*):Boolean{
			for(var i:uint = 0;i<this.size();i++){
				if(this.arr[i] == object){
					return true;
				}
			}
			return false;
		}
		
		public function clear():void{
			this.arr = new Array();
			this.pointer = 0;
		}
		
		public function isEmpty():Boolean{
			return this.size() == 0;
		}
		
		public function size():uint{
			return this.arr.length;
		}
		
		public function toString():String{
			return this.arr.toString();
		}
	}
}