// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// Basic button, needs cleanup

package com.kitschpatrol.ui
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class SimpleButton extends Sprite
	{
		private var functionReference:Function = new Function();
		public var buttonLabelText:String = new String();
		private var buttonLabel:TextField = new TextField();
		private var buttonLabelFormat:TextFormat = new TextFormat();
		
		private var overTextColor:int;
		private var outTextColor:int;
		
		private var buttonWidth:Number;
		private var buttonHeight:Number;
		private var sticky:Boolean; //stays down after click
		private var stuck:Boolean = false;

		public function SimpleButton(inputButtonLabelText:String, inputFunctionReference:Function, inputButtonWidth:Number = 45, inputButtonHeight:Number = 18, inputSticky:Boolean = false)
		{
			buttonWidth = inputButtonWidth;
			buttonHeight = inputButtonHeight;
			sticky = inputSticky;
			buttonLabelText = inputButtonLabelText;
			functionReference = inputFunctionReference;
			
			drawButton();
		}
		
		private function drawButton():void
		{
			drawUp(null);
			
			outTextColor = 0x000000;
			overTextColor = 0xffffff;

			//define text format
			buttonLabelFormat = new TextFormat();
			buttonLabelFormat.font = "_sans";
			buttonLabelFormat.size = 10;
			buttonLabelFormat.align = TextFormatAlign.CENTER; 
			
			//define the label
			buttonLabel = new TextField();
			buttonLabel.autoSize = TextFieldAutoSize.CENTER;
			buttonLabel.background = false;
			buttonLabel.border = false;
			buttonLabel.textColor = outTextColor;
			buttonLabel.selectable = false;
			buttonLabel.mouseEnabled = false;
			buttonLabel.defaultTextFormat = buttonLabelFormat;
            
			//set starting value
			buttonLabel.text = buttonLabelText;
			
			//add it to the button
      addChild(buttonLabel);
			buttonLabel.y = ((buttonHeight - buttonLabel.height) / 2);
			buttonLabel.x = ((buttonWidth - buttonLabel.width) / 2) - 1;
			
			buttonMode = true;
			useHandCursor = true;
			
			//add function reference
			addEventListener(MouseEvent.CLICK, functionReference);
			addEventListener(MouseEvent.MOUSE_OVER, drawOver);
			addEventListener(MouseEvent.MOUSE_OUT, drawUp);
			
			if(sticky)
			{
				addEventListener(MouseEvent.CLICK, stick);
			}
		}
		
		private function drawUp(e:MouseEvent):void
		{
			// draw the same-color line for pixel-perfect match with submission field
			graphics.clear();
			graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, buttonWidth, buttonHeight);
			graphics.endFill();
			
			buttonLabel.textColor = outTextColor;
		}
		
		private function drawOver(e:MouseEvent):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, buttonWidth, buttonHeight);
			graphics.endFill();
			
			buttonLabel.textColor = overTextColor;			
		}
		
		private function drawDead():void
		{
			graphics.clear();
			graphics.lineStyle(1, 0xc9c9c9, 1, true, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, buttonWidth, buttonHeight);
			graphics.endFill();
			
			buttonLabel.textColor = 0xc9c9c9;		
		}
		
		private function stick(e:MouseEvent):void
		{
			stuck = true;
			drawOver(e);
			removeEventListener(MouseEvent.MOUSE_OVER, drawOver);
			removeEventListener(MouseEvent.MOUSE_OUT, drawUp);
			removeEventListener(MouseEvent.CLICK, stick);
			addEventListener(MouseEvent.CLICK, unStick);
		}
		
		private function unStick(e:MouseEvent):void
		{
			stuck = false;
			drawUp(e);
			addEventListener(MouseEvent.MOUSE_OVER, drawOver);
			addEventListener(MouseEvent.MOUSE_OUT, drawUp);
			addEventListener(MouseEvent.CLICK, stick);
			removeEventListener(MouseEvent.CLICK, unStick);
		}
		
		public function disable():void
		{
			drawDead();
			
			removeEventListener(MouseEvent.CLICK, functionReference);
			removeEventListener(MouseEvent.MOUSE_OVER, drawOver);
			removeEventListener(MouseEvent.MOUSE_OUT, drawUp);
			
			useHandCursor = false;

			if(sticky)
			{
				removeEventListener(MouseEvent.CLICK, stick);
			}
		}
		
		public function reset():void
		{
			unStick(new MouseEvent(MouseEvent.CLICK));
		}
		
		public function stuckDown():void
		{
			stick(new MouseEvent(MouseEvent.CLICK));
		}
	}
}