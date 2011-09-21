package {
	import com.bit101.components.*;
	import com.demonsters.debugger.MonsterDebugger;
	import com.kitschpatrol.flashspan.FlashSpan;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;

		
	
	public class FlashSpanExample extends Sprite {

		private var flashSpan:FlashSpan;		
		
		public function FlashSpanExample() {
			// catch command line args
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);						
		}
		
		private function onInvoke(e:InvokeEvent):void {
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Command line args: " + e.arguments);
			
			// assume in incoming arg is a screen ID override
			// useful for testing on a single machine,
			// in production the automatic ID from IP is probably better
			
			if  (e.arguments.length > 0) {
				var screenID:int = e.arguments[0];
				flashSpan = new FlashSpan(screenID);	
			}
			else {
				flashSpan = new FlashSpan();
			}
			
			var testButton:PushButton = new PushButton(this, 5, 5, "Broadcast Ping", onBroadcastPing);
		}
		
		private function onBroadcastPing(e:Event):void {
			flashSpan.broadcastPing();
		}
	}
}