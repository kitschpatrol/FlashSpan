// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// BounceText provides a crude test case for FlashSpan

package com.kitschpatrol.flashspan
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BounceText extends TextField
	{
		public var vx:int = 1;
		public var vy:int = 1;
		
		public function BounceText()
		{
			var format:TextFormat = new TextFormat();
			format.font = "_SANS";
			format.bold = true;
			format.size = 100;
			
			selectable = false;
			defaultTextFormat = format;
			autoSize = TextFieldAutoSize.LEFT;
			textColor = 0xff0000;
			text = "FlashSpan";
		}
	}
}