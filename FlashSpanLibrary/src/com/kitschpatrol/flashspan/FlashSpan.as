package com.kitschpatrol.flashspan
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import flash.net.DatagramSocket;	
	
	public class FlashSpan extends EventDispatcher {
		public var settings:Settings;
		
		public function FlashSpan(settingsPath:String = "settings.xml") {
			super(null);
			
			// set up debugger
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Flash Span Constructed");
			
			// load the settings
			settings = new Settings();
			settings.load(settingsPath);
			
			// for now, screen 1 is always server
			
			
			
			
			
		}
		


	}
}