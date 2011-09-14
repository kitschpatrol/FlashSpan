// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// Simple text label, basically stores formatting, needs cleanup

package com.kitschpatrol.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	public class SimpleLabel extends TextField
	{
		public function SimpleLabel(_labelText:String)
		{
			var labelText:String = _labelText;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "_sans";
			textFormat.size = 10;
			textFormat.bold = true;
			
			defaultTextFormat = textFormat;
			text = labelText;
			selectable = false;
			autoSize = TextFieldAutoSize.LEFT;
			multiline = false;
			textColor = 0x000000;	
		}
	}
}