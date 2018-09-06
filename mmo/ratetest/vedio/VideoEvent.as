package mmo.ratetest.vedio
{
	import flash.events.Event;
	
	public class VideoEvent extends Event
	{
		private var _duration:Number;
		private var _params:Object;
		public static const EVENT_DURATION:String = "EVENT_DURATION";
		public static const EVENT_PREOGRESS:String = "EVENT_PREOGRESS";
		public function VideoEvent(type:String, duration:Number = 0, params:Object = null)
		{
			this._duration = duration;
			this._params = params;
			super(type);
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		public function get params():Object
		{
			return _params;
		}
	}
}