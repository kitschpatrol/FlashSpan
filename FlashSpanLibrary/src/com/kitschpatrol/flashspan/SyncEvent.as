package com.kitschpatrol.flashspan
{
	import flash.events.Event;
	
	public class SyncEvent extends Event
	{
		public static var staticFrameCount:uint;
		public var frameCount:uint;
		
		public function SyncEvent(type:String,  bubbles:Boolean=false, cancelable:Boolean=false)	{
			SyncEvent.staticFrameCount++;
			frameCount = SyncEvent.staticFrameCount;
			super(type, bubbles, cancelable);
		}
	}
}