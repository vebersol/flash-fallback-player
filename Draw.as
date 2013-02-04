package  {
	
	import flash.display.Sprite;
	
	public class Draw {
		
		public function Draw() {
		}
		
		public function square(width, height, line, lineColor, fill, x, y) {
			var square:Sprite = new Sprite();
			
			if (line > 0) {
				square.graphics.lineStyle(line, lineColor);
			}
			square.graphics.beginFill(fill);
			square.graphics.drawRect(0,0,width, height);
			square.graphics.endFill();
			square.x = x;
			square.y = y;
			
			return square;
		}
	}
	
}
