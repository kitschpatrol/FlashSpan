// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// Basic input box with a label, needs cleanup

package com.kitschpatrol.ui
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class LabeledInput extends Sprite
	{
		private var label:String;
		private var inputWidth:Number;
		private var textColor:Number = 0x000000;
		public var inputField:TextField;
		private var labelField:TextField;
		
		public function LabeledInput(_label:String, _inputWidth:Number)
		{
			label = _label;
			inputWidth = _inputWidth;

			//note that the sprite's origin centers on the left edge of the input box

			//define text format
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "_sans";
			textFormat.size = 10;
			
			labelField = new TextField();
			labelField.defaultTextFormat = textFormat;
			labelField.text = label + " ";
			labelField.selectable = false;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.multiline = false;
			labelField.textColor = textColor;
			labelField.x = -labelField.width;
			addChild(labelField);
				
			//define the input
			inputField = new TextField();
			inputField.defaultTextFormat = textFormat;
			inputField.width = inputWidth;
			inputField.height = labelField.height;
			inputField.type = TextFieldType.INPUT;
			inputField.border = true;
			inputField.borderColor = 0x000000;
			inputField.background = true;
			inputField.backgroundColor = 0xffffff;
			inputField.multiline = false;
			inputField.textColor = textColor;
			addChild(inputField);
		}
		
		public function disable():void
		{
			inputField.borderColor = 0xc9c9c9;
			labelField.textColor = 0xc9c9c9;
			inputField.textColor = 0xc9c9c9;
			inputField.mouseEnabled = false;
		}
	}
}