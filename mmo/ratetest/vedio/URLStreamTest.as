package mmo.ratetest.vedio
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	/**
	 * URLStream来播放视频
	 * NetConnection采用NetStream播放，学习FLVNetStream的实现
	 * */
	public class URLStreamTest extends Sprite
	{
		private var videoURL:String = "http://www.helpexamples.com/flash/video/cuepoints.flv";
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _urlStream:URLStream;
		private var _video:Video;
		private var _bytes:ByteArray = new ByteArray();
		private var _isSeek:Boolean = false;
		
		public function URLStreamTest()
		{
			if(stage) addToStage();
			else addEventListener(Event.ADDED_TO_STAGE, addToStage);
		}
		
		private function addToStage(evt:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addToStage);
			
			_video = new Video();
			addChild(_video);
			
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_netConnection.connect(null);
		}
		
		private function netStatusHandler(evt:NetStatusEvent):void
		{
			switch(evt.info.code)
			{
				case "NetConnection.Connect.Success":
					trace("NetConnection.Connect.Success");
					_urlStream = new URLStream();
					_urlStream.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
					_urlStream.load(new URLRequest(videoURL));
				break;
			}	
		}
		
		private function onProgress(evt:ProgressEvent):void
		{
			trace("onProgress");
			_urlStream.readBytes(_bytes, _bytes.length);
			if(!_netStream)
			{
				_netStream = new NetStream(_netConnection);
				_netStream.client = {};
				_video.attachNetStream(_netStream);
				_netStream.play(null);
				_netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			}else
			{
				if(!_isSeek)
				{
					trace("SEEK");
					_netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
					_isSeek = true;
				}
			}
//			if(_bytes.length == evt.bytesTotal)
//			{
//				trace("END");
//				_netStream.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
//			}
//			_netStream.appendBytes(_bytes);
//			trace('---');
			if(_bytes.length == evt.bytesTotal) //字节数都下载完成之后，添加字节，播放ok；上面的会报错
			{
				trace("end");
				_netStream.appendBytes(_bytes);
			}
		}
	}
}