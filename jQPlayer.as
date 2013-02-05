package  {
	
	import flash.display.MovieClip;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flashx.textLayout.formats.Float;
	
	public class jQPlayer extends MovieClip {
		
		private var _stream:NetStream;
		private var _video:Video;
		private var _draw:Draw = new Draw();
		private var _util:Util;
		private var _streamed:Boolean;
		
		private var _interval;
		private var _currentTime;
		private var _duration;
				
		public function jQPlayer() {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			_util = new Util(this.root);
			
			setupStream();
			
			setupVideo();
			//createControls();
			
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			
			addEventListener(Event.ADDED_TO_STAGE, bindEvents);
		}
		
		private function setupStream():void {
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			
			_stream = new NetStream(connection);
			
			_stream.client = {}
			_stream.client.onMetaData = onMetaData;
		}
		
		private function setupVideo():void {
			_video = new Video();
			addChild(_video);
			
			_video.attachNetStream(_stream);
		}
		
		private function onStatus(event:NetStatusEvent):void {
			if (_video.videoWidth > 0 && _video.width != _video.videoWidth) {
				_video.width = _video.videoWidth;
				_video.height = _video.videoHeight;
				
				var x = stage.stageWidth/2 - _video.videoWidth/2;
				var y = stage.stageHeight/2 - _video.videoHeight/2;
				
				if (x > 0) {
					_video.x = x;
				}
				
				if (y > 0) {
					_video.y = y;
				}
			}
		}
		
		function onMetaData(metadata:Object) {
			var duration = metadata.duration;
			_duration = duration;

			
		}
		
		private function playVideo():void {
			if (_streamed) {
				_util.cl("resume video");
				_stream.resume();
			}
			else {
				_util.cl("play video");
				_stream.play(_util.getFlashVar('video'));
				_streamed = true;
			}
			
			ExternalInterface.call("onPlay");
			setTimeChangeEvent();
		}
		
		private function pauseVideo():void {
			cancelTimeChangeEvent();
			_util.cl("pause video");
			_stream.pause();
			
			ExternalInterface.call("onPause");
		}
		
		private function setTimeChangeEvent():void {
			_interval = setInterval(function () {
				_currentTime = _stream.time;
			}, 100);
		}
		
		private function cancelTimeChangeEvent():void {
			clearInterval(_interval);
		}
		
		private function getCurrentTime() {
			return _currentTime;
		}
		
		private function getDuration() {
			_util.cl('duration ' + _duration);
			if (_duration) {
				return _duration;
			}
			
			return 0;
		}
		
		/*private function createControls() {
			var width = 200;
			var height = 24;
			var x = stage.width/2 - width/2;
			var y = stage.height - height;
			var square = _draw.square(width, height, 0, null, 0xFF0000, x, y);
			
			//square.addEventListener(MouseEvent.CLICK, playVideos);
			
			addChild(square);
		}*/
		
		private function bindEvents(ev:Event):void {
			ExternalInterface.marshallExceptions = true;
			ExternalInterface.addCallback("play", playVideo);
			ExternalInterface.addCallback("pause", pauseVideo);
			ExternalInterface.addCallback("currentTime", getCurrentTime);
			ExternalInterface.addCallback("duration", getDuration);
		}
	}
}
