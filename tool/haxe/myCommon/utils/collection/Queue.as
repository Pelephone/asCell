package utils.collection
{
	/**
	 * 队,(先进先出)
	 * @author Pelephone
	 */	
	public class Queue{
		private var arr:Array;
		private var pointer:uint;
		function Queue(){
			this.arr = new Array();
			this.pointer = 0;
		}
		public function element():*{
			if(isEmpty()){
				return null;
			}else{
				if(this.pointer < this.size()){
					return this.arr[this.pointer++];
				}else{
					return null;
				}
			}
		}
		public function peek():*{
			if(isEmpty()){
				return null;
			}else{
				return this.arr[0];
			}
		}
		public function poll():*{
			this.pointer = 0;
			if(isEmpty()){
				return null;
			}else{
				return this.arr.shift();
			}
		}
		public function add(object:*):Boolean{
			this.pointer = 0;
			if(this.contains(object)){
				return false;
			}else{
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