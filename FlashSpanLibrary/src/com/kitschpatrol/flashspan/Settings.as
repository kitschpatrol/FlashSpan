package com.kitschpatrol.flashspan {
	
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	public class Settings extends Object {
		// A collection of settings. These can be set manually or are loaded from an INI file
		public static const SERVER_AUTO:String = "auto";
		public static const SERVER_YES:String ="yes";
		public static const SERVER_NO:String = "no";
		
		public var screenID:uint = 1;
		public var screenWidth:uint = 640;
		public var screenHeight:uint = 640;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;		
		public var totalWidth:uint = 640;
		public var totalHeight:uint = 480;
		public var scaleFactor:Number = 1;
		public var isServer:String = SERVER_AUTO;
		public var networkMap:Vector.<NetworkedScreen>;
		
		public function Settings() {
			// Constructor
		}
		
		public function load(filePath:String):void {
			// load text file
			var file:File = File.applicationDirectory.resolvePath(filePath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			var fileContents:String = fileStream.readUTFBytes(fileStream.bytesAvailable); // Read the contens of the 
			fileStream.close(); // Clean up and close the file stream			
			
			// parse the xml
			var xml:XML = new XML(fileContents);	
			
			// local settings
			for each (var setting:XML in xml.thisScreen.children()) {
				var key:String = setting.localName();
				var value:Object = setting.valueOf();
				
				if (this.hasOwnProperty(key)) {
					this[key] = value;
				}
			}
			
			// network settings
			networkMap = new Vector.<NetworkedScreen>(xml.networkMap.children().length);
			
			for each (var screen:XML in xml.networkMap.children()) {
				networkMap[screen.id] = new NetworkedScreen(screen.id, screen.ip, screen.port);
			}			

			
			MonsterDebugger.trace(this, this);
		}		
	}
}