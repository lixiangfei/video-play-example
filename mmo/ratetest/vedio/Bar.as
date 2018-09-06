package mmo.ratetest.vedio
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	public class Bar extends Sprite
	{
		private var _res:MovieClip;
		private var _startX:Number;
		private var _maxX:Number;
		private var _appStage:Stage;
		private var _preX:Number;
		
		public function Bar(res:MovieClip, startX:Number, maxX:Number)
		{
			this._res = res;
			_appStage = res.stage;
			this._startX = startX;
			this._preX = startX;
			this._maxX = maxX;
			initListeners();
		}
		
		public function update(x:Number):void
		{
			_res.x = x;
			_preX = x;
		}
		
		private function initListeners():void
		{
			_res.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			_res.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void
		{
			_appStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		}
		private function onMouseUpHandler(evt:MouseEvent):void
		{
			_appStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		}
		
		private function onMouseMoveHandler(evt:MouseEvent):void
		{
			var delta:Number = evt.stageX - _preX;
			_res.x += delta;
			if(_res.x < _startX) _res.x = _startX;
			if(_res.x > _maxX) _res.x = _maxX;
			_preX = _res.x;
			var p:Number = (_preX - _startX)/_maxX;
			dispatchEvent(new VideoEvent(VideoEvent.EVENT_PREOGRESS, 0, {"p":p}));
		}
	}
}