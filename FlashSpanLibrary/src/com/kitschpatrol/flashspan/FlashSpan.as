package com.kitschpatrol.flashspan
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.DatagramSocket;
	
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;	
	
	import com.demonsters.debugger.MonsterDebugger;
	import flash.display.Sprite;	
	
	public class FlashSpan extends EventDispatcher {
		public var settings:Settings;
		
		public function FlashSpan(target:IEventDispatcher=null) {
			super(target);
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Flash Span Constructed");	
		}
		
		public function loadSettings(filePath:String = "settings.ini"):void {
			// load text file
			var file:File = File.applicationDirectory.resolvePath(filePath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			var fileContents:String = fileStream.readUTFBytes(fileStream.bytesAvailable); // Read the contens of the 
			fileStream.close(); // Clean up and close the file stream			
			
			trace(fileContents);
			
			// parse ini style
		}

	}
}