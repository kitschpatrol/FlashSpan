package com.kitschpatrol.flashspan {
	public class Settings extends Object {
		// A collection of settings. These can be set manually or are loaded from an INI file
		public var screenNumber:uint = 1;
		public var screenWidth:uint = 640;
		public var screenHeight:uint = 640;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;		
		public var totalWidth:uint = 640;
		public var totalHeight:uint = 480;
		public var scaleFactor:Number = 1;
		
		public function Settings() {
			// Constructor
		}
	}
}