package utils.astart
{
	public interface IAstarNode
	{
		/**
		 * 行
		 * @return 
		 */
		function get row():int;
		function set row(value:int):void;
		/**
		 * 列
		 * @return 
		 */
		function get col():int;
		function set col(value:int):void;
		
		/**
		 * 是否可走
		 * @return 
		 */
		function get walkable():Boolean;
		function set walkable(value:Boolean):void;
	}
}