// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// BigScreen essentially provides a canvas larger than the flash stage
// all clients draw the exact same thing to the BigScreen, but each
// client's BigScreen has a unique offset, so as to only render a
// window of the larger animation

package com.kitschpatrol.flashspan
{
	import flash.display.Sprite;

	public class BigScreen extends Sprite
	{
		public var bigWidth:int;
		public var bigHeight:int;
		public var rotationAngle:int;
		
		private var bounceText:BounceText;
				
		public function BigScreen(_bigWidth:int, _bigHeight:int)
		{
			bigWidth = _bigWidth;
			bigHeight = _bigHeight;
			
			// set up a background to grow the sprite
			// to the needed dimensions
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, bigWidth, bigHeight);
			this.graphics.endFill();
			
			// add objects here as usual
			// bouncing text for example's sake
			bounceText = new BounceText();
			addChild(bounceText);
		}
		
		public function update():void
		{
			// update() replaces the ENTER_FRAME event...
			// any frame-by-frame animation needs to run here
			
			// bounce the text...
			if((bounceText.x + bounceText.width > bigWidth) || bounceText.x < 0) bounceText.vx *= -1;
			if((bounceText.y + bounceText.height > bigHeight) || bounceText.y < 0) bounceText.vy *= -1;
			
			bounceText.x += bounceText.vx;
			bounceText.y += bounceText.vy;
		}
	}
}