package utils.collection
{
	import flash.utils.Dictionary;
	
	public class Map{
		
		private var _keys:Array = null;
		private var props:Dictionary = null;
		
		public function Map(){
			this.clear();
		}
		public function clear():void{
			this.props = new Dictionary();
			this._keys = new Array();
		}
		public function containsKey(key:*):Boolean{
			return this.props[key] != null;
		}
		public function containsValue(value:*):Boolean{
			var result:Boolean = false;
			var len:uint = this.size();
			if(len > 0){
				for(var i:uint = 0 ; i < len ; i++){
					if(this.props[this._keys[i]] == value) return true;
				}
			}
			return result;
		}
		public function get(key:*):*{
			return this.props[key];
		}
		public function put(key:*,value:*):*{
			var result:* = null;
			if(this.containsKey(key)){
				result = this.get(key);
				this.props[key] = value;
			}else{
				this.props[key] = value;
				this._keys.push(key);
			}
			return result;
		}
		public function remove(key:*):*{
			var result:* = null;
			if(this.containsKey(key)){
				delete this.props[key];
				var index:int = this._keys.indexOf(key);
				if(index > -1){
					this._keys.splice(index,1);
				}
			}
			return result;
		}
		public function putAll(map:Map):void{
			this.clear();
			var len:uint = map.size();
			if(len > 0){
				var arr:Array = map.keys();
				for(var i:uint=0;i<len;i++){
					this.put(arr[i],map.get(arr[i]));
				}
			}
		}
		public function size():uint{
			return this._keys.length;
		}
		public function isEmpty():Boolean{
			return this.size() < 1;
		}
		public function values():Array{
			var result:Array = new Array();
			var len:uint = this.size();
			if(len > 0){
				for(var i:uint = 0;i<len;i++){
					result.push(this.props[this._keys[i]]);
				}
			}
			return result;
		}
		public function keys():Array{
			return this._keys;
		}
		
		public function toString():String{
			var out:String = "";
			for(var i:uint=0;i<this.size();i++){
				out += this._keys[i] + ":"+this.get(this._keys[i]) + "\n";
			}
			return out;
		}
	}
}