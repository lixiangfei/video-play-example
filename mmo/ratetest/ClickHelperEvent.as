package mmo.ratetest
{
	import flash.events.Event;
	
	public class ClickHelperEvent extends Event
	{
		public static const ON_HIT_REGISTER:String = "onHitRegister";
		private var _targetName:String;
		public function ClickHelperEvent(type:String, targetName:String)
		{
			this._targetName = targetName;
			super(type);
		}
		
		public function get targetName():String
		{
			return _targetName;
		}
		
		override public function clone():Event
		{
			return new ClickHelperEvent(type, _targetName);
		}
		
	}
}