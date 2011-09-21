package com.kitschpatrol.flashspan
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.Sprite;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;

	
	public class FlashSpan extends EventDispatcher {
		public var settings:Settings;
		
		// Todo move into connection class?
		private var udpSocket:DatagramSocket = new DatagramSocket();
		private var myPort:int;
		private var myIP:String;				
		
		public function FlashSpan(screenID:int = -1, settingsPath:String = "settings.xml") {
			super(null);
			
			// set up debugger
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Flash Span Constructed");

			// load the settings
			settings = new Settings();
			settings.load(settingsPath);		
			
			
			// if screen ID is -1, use the IP identification technique
			if (screenID == -1) {
				MonsterDebugger.trace(this, "Setting screen ID from IP");				
			}
			else {
				MonsterDebugger.trace(this, "Setting screen ID from constructor");				
				settings.setMyID(screenID);
			}
			

			
			
			// for now, screen 1 is always server
			
			// Close the socket if it's already open
			if (udpSocket.bound) {
				MonsterDebugger.trace(this, 'Closing existing port');
				udpSocket.close();
				udpSocket = new DatagramSocket();				
			}
			
			
			
			myPort = settings.thisScreen.port;
			myIP = settings.thisScreen.ip;			
			
			MonsterDebugger.trace(this, "Binding to: " + myIP + ":" + myPort);			
			
			udpSocket.bind(myPort, myIP);
			udpSocket.addEventListener(DatagramSocketDataEvent.DATA, onDataReceived);
			udpSocket.receive();
			
			MonsterDebugger.trace(this, "Bound to: " + udpSocket.localAddress + ":" + udpSocket.localPort);
			
			// Check for existing servers			
		}
		
		
		
		private function onDataReceived(e:DatagramSocketDataEvent):void	{
			//Read the data from the datagram
			MonsterDebugger.trace(this, "Received from " + e.srcAddress + ":" + e.srcPort + "> " +	e.data.readUTFBytes(e.data.bytesAvailable));
			
			// TODO map everything... router table, basically
		}		
		
		
		private function send(machineID:int, message:String):void {
			//Create a message in a ByteArray
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(message);
			
			var targetIP:String = settings.networkMap[machineID].ip;
			var targetPort:int = settings.networkMap[machineID].port;
			
			//Send a datagram to the target
			try	{				
				udpSocket.send(data, 0, 0,targetIP, targetPort); 
			}
			catch (error:Error)	{
				MonsterDebugger.trace(this, error.message);
			}
		}	
		
		

		public function setIDFromIP():void {
			// picks the id from settings that matches my IP
			
			
			
		}
		


	}
}