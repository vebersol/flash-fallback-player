package  {
	
	import flash.display.MovieClip;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.media.Sound;
    	import flash.media.SoundChannel;
    	import flash.media.SoundTransform;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.system.Security;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class jQPlayer extends MovieClip {
		
		private var _jsDispatcher:JSEventDispatcher;
		private var _stream:NetStream;
		private var _video:Video;
		private var _util:Util;
		private var _streamed:Boolean;
		
		private var _interval:uint;
		private var _currentTime:Number;
		private var _currentVolume:Number;
		private var _duration:Number;
		private var _soundTransform:SoundTransform;
		private var _isPaused:Boolean;
				
		public function jQPlayer() {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			_util = new Util(this.root);

			_soundTransform = new SoundTransform(0);
			
			setupStream();
			setupVideo();
			bind();
			
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			stage.addEventListener(Event.RESIZE, resizeListener);
			
			addEventListener(Event.ADDED_TO_STAGE, bindExternalEvents);
		}
		
		private function setupStream():void {
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			
			_stream = new NetStream(connection);
			
			_stream.client = {}
			_stream.client.onMetaData = onMetaData;

			_isPaused = true;
		}
		
		private function setupVideo():void {
			_video = new Video();
			addChild(_video);
			
			_video.attachNetStream(_stream);

			// preload video
			_stream.play(_util.getFlashVar('video'));
			_stream.pause();
		}
		
		private function onStatus(event:NetStatusEvent):void {
			_util.cl(event.info.code);

			if (event.info.code == 'NetStream.Play.Start') {
				resizeVideo();
				_jsDispatcher.dispatch("play");
			}

			if (event.info.code == 'NetStream.Play.Stop') {
				_jsDispatcher.dispatch("end");
				_streamed = false;
			}
			
		}
		
		private function onMetaData(metadata:Object):void {
			var duration:Number = metadata.duration;
			_duration = duration;
		}
		
		private function playVideo():void {
			if (_streamed === true) {
				_util.cl("resume video");
				_stream.resume();
			}
			else {
				_util.cl("play video");
				_stream.play(_util.getFlashVar('video'));
				_streamed = true;
			}

			_isPaused = false;
			ExternalInterface.call('function () { jQuery(document).trigger("flash.play"); }');
		}
		
		private function pauseVideo():void {
			_util.cl("pause video");
			_stream.pause();
			
			_jsDispatcher.dispatch("pause");

			_isPaused = true;
			ExternalInterface.call('function () { jQuery(document).trigger("flash.pause"); }');
		}
				
		private function getCurrentTime():Number {
			return _currentTime;
		}
		
		private function getDuration():Number {
			if (_duration) {
				return _duration;
			}
			
			return 0;
		}

		private function seekTo(time:Number):void {
			_stream.seek(time);
			ExternalInterface.call('function () { jQuery(document).trigger("flash.seeked"); }');
		}
		
		private function bindExternalEvents(ev:Event):void {
			ExternalInterface.marshallExceptions = true;
			ExternalInterface.addCallback("play", playVideo);
			ExternalInterface.addCallback("pause", pauseVideo);
			ExternalInterface.addCallback("currentTime", getCurrentTime);
			ExternalInterface.addCallback("duration", getDuration);
			ExternalInterface.addCallback("seekTo", seekTo);
			ExternalInterface.addCallback("volume", setVolume);
			ExternalInterface.addCallback("getVolume", getVolume);
			ExternalInterface.addCallback("paused", isPaused);
			ExternalInterface.addCallback("resize", resizeVideo);
			ExternalInterface.addCallback("changeVideo", changeVideo);

			_jsDispatcher = new JSEventDispatcher("addPlayerEvent", "removePlayerEvent");

			ExternalInterface.call('function () { jQuery(document).trigger("flash.loaded"); }');
		}

		private function bind():void {
			stage.addEventListener(Event.ENTER_FRAME, frameUpdate);
		}

		private function frameUpdate(ev:Event):void {
			_currentTime = _stream.time;
		}

		public function resizeVideo():void {
			_util.cl('resizeVideo');
			
			_video.width = stage.stageWidth;
			_video.height = stage.stageHeight;
		}

		private function resizeListener(e:Event):void {
			resizeVideo();
		}

		public function setVolume(vol:Number):void {
			_stream.soundTransform = _soundTransform;
			_soundTransform.volume = vol;
			_stream.soundTransform = _soundTransform;
			_currentVolume = vol;
		}

		public function getVolume():Number {
			if (!_currentVolume) {
				_currentVolume = 1;
			}

			return _currentVolume;
		}

		public function isPaused():Boolean {
			return _isPaused;
		}

		public function changeVideo(source:String):void {
			_stream.play(source);
			_stream.pause();

			_currentTime = 0;

			ExternalInterface.call('function () { jQuery(document).trigger("flash.videoChanged"); }');
		}
	}
}
