package  {
	
	import flash.display.LoaderInfo;
	import flash.external.ExternalInterface;
	
	public class Util {
		
		private var _rootObject;

		public function Util(rootObject) {
			_rootObject = rootObject;
		}
		
		public function getFlashVar(prop) {
			var paramObj:Object = LoaderInfo(_rootObject.loaderInfo).parameters;
			return paramObj[prop];
		}

	}
	
}
