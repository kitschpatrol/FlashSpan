package {
	import flash.display.Sprite;
	
	public class Ball extends Sprite {
		
		public var vx:Number;
		public var vy:Number;	
		
		public function Ball(color:uint) {
			super();
			this.graphics.beginFill(color);
			this.graphics.drawEllipse(0, 0, 20, 20);
			this.graphics.endFill();
		}
	}
}