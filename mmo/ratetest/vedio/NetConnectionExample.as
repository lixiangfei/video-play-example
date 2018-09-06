package mmo.ratetest.vedio
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mmo.ratetest.ClickHelper;
	
	/**
	 * 加载视频文件
	 * 1.创建一个NetConnection对象。如果要连接到本地视频文件或者未使用Adobe Flash Media Server 2之类的服务器的视频文件，请将null
	 * 传递给Connect()方法，以从HTTP地址或本地驱动盘上播放视频文件。如果要连接到服务器，请将该参数设置为包含服务器上视频文件的应用程序的URI
	 *   var netConnection:NetConnection = new NetConnection();
	 * 	 netConnect.connect(null);
	 * 2.创建一个用来显示视频的新Video对象，将其添加到舞台显示列表
	 * 	var video:Video = new Video();
	 *  addChild(video);
	 * 3.创建一个NetStream对象，将NetStream对象作为一个传输短笛给构造函数,监听对应事件
	 * 	var netStream:NetStream = new NetStream(netConnection);
	 * 4.使用Video对象的attachNetStream()方法将NetStream对象附加到Video对象
	 * 	video.attachNetStream(netStream);
	 * 5.调用NetStraem对象的play方法，同时将视频文件url作为开始视频播放的参数。一下代码片段是将加载并播放与swf文件位于同一目录下的视频文件video.mp4s
	 * 	netStream.play("video.mp4");
	 * */
	public class NetConnectionExample extends Sprite
	{
		private var videoURL:String = "http://www.helpexamples.com/flash/video/cuepoints.flv";
		private var connection:NetConnection;
		private var stream:NetStream;
		private var video:Video = new Video();
		private var clickHelper:ClickHelper;
		private var appStage:Stage;
		private var bitMapContainer:MovieClip;
		
		private var _totalVideoTime:Number;
		private var _isTotalTimeInit:Boolean = false;
		private var _txtTime:TextField;
		
		private var paused:Boolean = false;
		private var _customClient:CustomClient;
		private var _timer:Timer;
		private var _netConnectSp:Sprite;
		private var _bar:Bar;
		private var _mcProgress:MovieClip;
		private var _bg:MovieClip;
		private var _videoContainer:MovieClip;
		
		public function NetConnectionExample(appStage:Stage)
		{
			this.appStage = appStage;
			_txtTime = new TextField();
			_txtTime.text = "00:00/00:00";
			_txtTime.x = 420;
			_txtTime.y = 440;
			_videoContainer = new MovieClip();
			this.addChild(_videoContainer);
			_netConnectSp = appStage.getChildAt(0) as Sprite;
			_bar = new Bar(_netConnectSp.getChildByName("mcBar") as MovieClip, 0,87);
			_bar.addEventListener(VideoEvent.EVENT_PREOGRESS, onProgress);
			_mcProgress = _netConnectSp.getChildByName("mcProgress") as MovieClip;
			_mcProgress.mouseEnabled = false;
			_mcProgress.mouseChildren = false;
			_bg = _netConnectSp.getChildByName("mcEnterProBg") as MovieClip;
			_bg.addEventListener(MouseEvent.CLICK, onClickProgress);
			trace(_netConnectSp);
			appStage.addChild(_txtTime);
			clickHelper = new ClickHelper(appStage);
			clickHelper.regRegexFunc("btnAction_[0-9]+", onAction);
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);
			bitMapContainer = new MovieClip();
			bitMapContainer.y = 200;
			addChild(bitMapContainer);
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			addChild(bufferContainer);
			bufferContainer.y = 400;
		
		}
		
		
		private function onClickProgress(evt:MouseEvent):void
		{
			var p:Number = (evt.stageX - _bg.x)/_bg.width;
			trace(evt.stageX);
			stream.seek(p*_totalVideoTime);
		}
		
		private function onProgress(evt:VideoEvent):void
		{
			var p:Number = evt.params["p"];
			trace("p"+p);
			if(_isTotalTimeInit)
			{
				var time:Number = p*_totalVideoTime;
				trace("time:"+time);
				stream.seek(time);
			}
		}
		
		
		private function onTimer(evt:TimerEvent):void
		{
			if(_isTotalTimeInit)
			{
				_txtTime.text = stream.time+"/"+_totalVideoTime;
				var p:Number = stream.time/_totalVideoTime;
				_mcProgress.width = p * _bg.width;
				_bar.update(_mcProgress.width);
			}	
		}
		
		private const PLAY:int = 0;
		private const PAUSE:int = 1;
		private const STOP:int = 2;
		private const TOGGLE_PAUSE:int = 3;
		private const FULL_SCREEN:int = 4;
		private const SNAP_SHOOT:int = 5;
		
		/**
		 * note:<b>没有stop方法。为了停止视频流，不许暂停播放并找到视频流的开始位置</b>
		 * note:<b>play方法不会恢复播放，它用于加载视频文件</b>
		 * */
		private function onAction(targetName:String):void
		{
			if(stream == null)
			{
				return;
			}
			var actionId:int = targetName.split("_")[1];
			switch(actionId)
			{
				case PLAY:
					stream.resume(); //恢复播放视频流。如果视频已在播放，则调用此方法不会执行任何操作
					break;
				case PAUSE:
					stream.pause(); //暂停播放视频流。如果视频已经暂停，则调用此方法将不会执行任何操作
					break;
				case STOP:
					stream.pause();
					stream.seek(0);
					break;
				case TOGGLE_PAUSE:
					stream.togglePause(); //暂停或恢复播放流
					break;
				case FULL_SCREEN:
					handleFullScreen();
					break;
				case SNAP_SHOOT:
					handleSnapShoot();
					break;
				case 6:
					handleProgress();
					break;
			}
		}
		
		private function handleProgress():void
		{
			if(!_isTotalTimeInit) return;
			var randomTime:Number = Math.random() * _totalVideoTime;
			stream.seek(randomTime);
		}
		
		private var currentTime:Number = 0;
		/**解决停止之后在播放，当前时间restart问题
		 * 两种方法如下
		 * */
		private function playAgainFromCurrent():void
		{
			//play, resume
			//
			if(paused)
			{
				paused = false;
				stream.resume();
//				stream.play(currentTime);
			}else
			{
				paused = true;
				stream.pause();
				currentTime = stream.time;
			}
		}
		
		/**截取视频*/
		private function handleSnapShoot():void
		{
			var px_size = 1;
			var bmp:Bitmap = pixelate(video, px_size);
			if(bitMapContainer.numChildren > 0)
			{
				bitMapContainer.removeChildAt(0);
			}
			if(bmp){
				bitMapContainer.addChild(bmp);
			}else{
				ExternalInterface.call("console.log","null");
			}
			
		}
		
		
		var bufferContainer : Sprite = new Sprite();
		
		private function pixelate(target:DisplayObject, px_size:uint):Bitmap
		{
			try{
				var index:uint, j:uint  =0;
				var s:uint = px_size;
				var d:DisplayObject = target;
				var w:uint = d.width;
				var h:uint = d.height;
				var bmd_src:BitmapData = new BitmapData(w, h);
				bmd_src.draw(d);
				
			}catch(e:Event){
				ExternalInterface.call("console.log", e.toString())
				
			}
//			bufferContainer.graphics.drawGraphicsData( _videoContainer.graphics.readGraphicsData() );
//			var myBitmapData:BitmapData = new BitmapData(w, h);
//			myBitmapData.draw(bufferContainer);
//			return new Bitmap(myBitmapData);
			
			return new Bitmap(bmd_src); //生成ok,下面生成失败
//			var bmd_final:BitmapData = new BitmapData(w, h);
//			var rect:Rectangle = new Rectangle();
//			rect.width = rect.height = s;
//			for(index = 0; index < w; index += s)
//			{
//				for(j = 0;j < h; j += s)
//				{
//					rect.x = index;
//					rect.y = j;
//					bmd_final.fillRect(rect, bmd_src.getPixel32(x,y));
//				}
//			}
//			bmd_src.dispose();
//			bmd_src = null;
//			return new Bitmap(bmd_final);
		}
		
		private function save():void
		{
//			var bmp:Bitmap = pixelate(video, px_size);
//			
//			var jpg_encoder:JPGEncoder = new JPGEncoder(80); 
//			var jpg_stream:ByteArray = jpg_encoder.encode(bmp.bitmapData);
//			
//			var file:FileReference = new FileReference();
//			file.save(jpg_stream, 'snapshot_'+int(stream.time)+'.jpg'); //点击事件才行
		}
		
		/**
		 * <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" 
    id="fullScreen" width="100%" height="100%" 
    codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab"> 
    ... 
    <param name="allowFullScreen" value="true" /> 
    <embed src="fullScreen.swf" allowFullScreen="true" quality="high" bgcolor="#869ca7" 
        width="100%" height="100%" name="fullScreen" align="middle" 
        play="true" 
        loop="false" 
        quality="high" 
        allowScriptAccess="sameDomain" 
        type="application/x-shockwave-flash" 
        pluginspage="http://www.adobe.com/go/getflashplayer"> 
    </embed> 
    ... 
</object>
 * 1.需要在应用程序的"发布"模板启用全屏模式，然后才能在浏览器中实现Flash Player的全屏模式。
 * 2.在Flash中，选择"文件"->"发布设置",然后在"发布设置"对话框中的"HTML"选项卡上，选择"仅Flash-允许全屏"
		 * */
		private function handleFullScreen():void
		{
			if(stream == null) return;
			var screenRect:Rectangle = new Rectangle(video.x, video.y, video.width, video.height);
			appStage.fullScreenSourceRect = screenRect;
			appStage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		private function netStatusHandler(evt:NetStatusEvent):void
		{
			switch(evt.info.code)
			{
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					trace("streamnot found:" + videoURL);
					break;
				case "NetStream.Play.Start": //视频播放的开始发出信号
					trace("Start [" + stream.time.toFixed(3) + " seconds]"); 
					break;
				case  "NetStream.Play.Stop"://视频播放的结束发出信号
					trace("Stop [" + stream.time.toFixed(3) + " seconds]"); 
					appStage.displayState = StageDisplayState.NORMAL;//如果有全屏，恢复正常
					break;
				default:
				{
					trace("code:"+evt.info.code);
					break;
				}
			}
		}
		
		private function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			trace("securityError");
		}
		
		private function connectStream():void
		{
			if(!_videoContainer.contains(video)) _videoContainer.addChild(video);
			stream = new NetStream(connection);
			stream.checkPolicyFile = true;
			try
			{
				stream.audioSampleAccess = true;
			} 
			catch(error:Error) 
			{
				
			}
//			stream.audioSampleAccess = true;
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_customClient = new CustomClient();
			_customClient.addEventListener(VideoEvent.EVENT_DURATION, handleDuration);
			stream.client = _customClient;//new CustomClient();
			video.attachNetStream(stream);
			
			stream.play(null);//貌似可以解决沙箱冲突2123
			stream.play(videoURL);//从本地磁盘，web服务器或者Flash Media Server播放媒体文件
			
//			stream.publish();//以将视频，音频和数据流发布到Flash Media Server
//			stream.send();//将数据消息发送给所有订阅客户端
//			stream.send();//向实时流添加元数据
//			var byteArray:ByteArray = new ByteArray();
//			stream.appendBytes(byteArray);//将ByteArray数据传入NetStream
			
			//不能通过同一NetStram对象播放和发布流
		}
		
		private function handleDuration(evt:VideoEvent):void
		{
			_totalVideoTime = evt.duration;
			_isTotalTimeInit = true;
		}
		/**返回NetStream.play(url)的url，因为不同格式的地址有规定*/
		private function getID(url:String):String { 
			var parts:Array = url.split("?");
			var ext:String = parts[0].substr(-4);
			parts[0] = parts[0].substr(0, parts[0].length-4);
			if (url.indexOf(':') > -1) {
				return url;
			} else if (ext == '.mp3') {
				return 'mp3:' + parts.join("?");
			} else if (ext == '.mp4' || ext == '.mov' || ext == '.m4v' || ext == '.aac' || ext == '.m4a' || ext == '.f4v') {
				return 'mp4:' + url;
			} else if (ext == '.flv') {
				return parts.join("?");
			} else {
				return url;
			}
		}
	}
}
import flash.events.EventDispatcher;

import mmo.ratetest.vedio.VideoEvent;

/**
 * http://help.adobe.com/zh_CN/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b90204-7d3f.html
 * 元数据以及提示点：当播放器收到特定元数据或到达特定提示点时，可以在应用程序中触发动作。当这些事件发生时，必须将特定回调方法用作事件处理函数。<br>
 * NetStream类指定了在播放期间可发生以下元数据事件。
 * <b>onCuePoint(仅限FLV文件，onImageData,onMetaData,onPlayStatus,onTextData和onXMPData)</b>,必须为这些处理程序编写回调方法，否则flash运行
 * 期间可能会引发错误。<br>
 * <li>1.将NetStream对象的client属性设置为一个Object, client=new Object(); client.onMetaData = function():void{}</li>
 * <li>2.Object-->指定的类去处理，本次例子</li>
 * <li>3.继承NetStream,子类实现需要的回调方法</li>
 * <li>4.扩展NetStream类并使其变为动态类，  public dynamic class DynamicCustomNetStream extends NetStream,动态类，所以没有处理函数也不会报错,Object的赋值方法</li>
 * <li>5.设置为this，this中实现</li>
 * */
class CustomClient extends EventDispatcher
{
//	public function onMetaData(info:Object):void {
//		trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
//		traceObject(info);
//	}
	
	public function onCuePoint(info:Object):void
	{
		trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
	}
	
	private function forward(dat:Object, typ:String):void {
		dat['type'] = typ;
		var out:Object = new Object();
		for (var i:Object in dat) {
			out[i] = dat[i];
		}
		traceObject(out);
	}
	
	function traceObject(obj:Object, indent:uint = 0):void 
	{ 
		var indentString:String = ""; 
		var i:uint; 
		var prop:String; 
		var val:*; 
		for (i = 0; i < indent; i++) 
		{ 
			indentString += "\t"; 
		} 
		for (prop in obj) 
		{ 
			val = obj[prop]; 
			if (typeof(val) == "object") 
			{ 
				trace(indentString + " " + prop + ": [Object]"); 
				traceObject(val, indent + 1); 
			} 
			else 
			{ 
				trace(indentString + " " + prop + ": " + val); 
			} 
		} 
	}
	
	/** Get metadata information from netstream class. **/
	public function onMetaData(obj:Object, ...rest):void {
		if (rest && rest.length > 0) {
			rest.splice(0, 0, obj);
			forward({ arguments: rest }, 'metadata');
		} else {
			forward(obj, 'metadata');
		}
		trace("metadata: duration=" + obj.duration); //获取播放视频的总的时长
		dispatchEvent(new VideoEvent(VideoEvent.EVENT_DURATION, obj.duration));
	}
	
	/** Receive NetStream playback codes. **/
	public function onPlayStatus(... rest):void {
		for each (var dat:Object in rest) {
			if (dat && dat.hasOwnProperty('code')) {
				if (dat.code == "NetStream.Play.Complete") {
					forward(dat, 'complete');
				} else {
					forward(dat, 'playstatus');
				}
			}
		}
	}
}