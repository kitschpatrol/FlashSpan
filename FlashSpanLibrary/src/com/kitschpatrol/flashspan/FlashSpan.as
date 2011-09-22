package com.kitschpatrol.flashspan
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.Sprite;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	
	public class FlashSpan extends EventDispatcher {
		public var settings:Settings;
		
		// regular packets should be
		// (one character header)(body)
		
		// certified packet format, gets a confirmation that the packet was received
		// (certifed header)(packet header)(body),(certified packets sent count)
		
		// certified response format
		// (certified response header)(certified packets sent count)		
		
		// Events, where to put
		public static const SYNC_EVENT:String = "syncEvent";
		
		// Todo move into connection class?
		private var udpSocket:DatagramSocket = new DatagramSocket();
		private var packetsInWaiting:Vector.<CertifiedPacket> = new Vector.<CertifiedPacket>(0);		
		
		private var connectionCheckTimer:Timer; // not used
		
		// server stuff
		private var isServer:Boolean = false;
		private var isSyncing:Boolean = false;
		private var syncTimer:Timer;
		
		// Message types
		public static const CERTIFIED_HEADER:String = 'c';
		public static const CERTIFIED_RESPONSE_HEADER:String = 'r';
		public static const PING_HEADER:String = 'p';
		
		public static const START_HEADER:String = 's';
		public static const STOP_HEADER:String = 't';
		public static const SYNC_HEADER:String = 'y';		
		
		public var frameCount:uint = 0;
		
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
				settings.setMyID(getIDfromIP());
			}
			else {
				MonsterDebugger.trace(this, "Setting screen ID from constructor");				
				settings.setMyID(screenID);
			}
			
			// for now, screen 0 is always server			
			isServer = (settings.thisScreen.id == 0);
			
			// Close the socket if it's already open
			if (udpSocket.bound) {
				MonsterDebugger.trace(this, 'Closing existing port');
				udpSocket.close();
				udpSocket = new DatagramSocket();				
			}
			
			MonsterDebugger.trace(this, "Binding to: " + settings.thisScreen.ip + ":" + settings.thisScreen.port);			
			
			udpSocket.bind(settings.thisScreen.port, settings.thisScreen.ip);
			udpSocket.addEventListener(DatagramSocketDataEvent.DATA, onDataReceived);
			udpSocket.receive();
			
			MonsterDebugger.trace(this, "Bound to: " + udpSocket.localAddress + ":" + udpSocket.localPort);
			
			// Check for existing servers
				
			// Start checking for who is connected
			// not needed?
//			settings.thisScreen.connected = true; // obviosly we're connected
//			connectionCheckTimer = new Timer(500); // check every 500ms?
//			connectionCheckTimer.addEventListener(TimerEvent.TIMER, connectionCheck);
//			connectionCheckTimer.start();
			
			// based on frame rate? 60fps?
			syncTimer = new Timer(10);
			syncTimer.addEventListener(TimerEvent.TIMER, onSyncTimer);
			syncTimer.stop();
		}
		
		
		// heartbeat
		private function connectionCheck(e:TimerEvent):void {
			MonsterDebugger.trace(this, "Pinging for connection");
			MonsterDebugger.trace(this, settings);			
			broadcastPing();
		}
				
		
		private function onSyncTimer(e:TimerEvent):void {
			// broadcast sync
			broadcastMessage(SYNC_HEADER);
			
			// send out event locally
			this.dispatchEvent(new SyncEvent(SYNC_EVENT));
		}
		
		public function start():void {
			if (isServer) {
				frameCount = 0;
				syncTimer.reset();
				syncTimer.start();
			}
			else {
				// send to server
				sendCertified(settings.networkMap[0], START_HEADER);
			}
		}
		
		public function stop():void {
			if (isServer) {
				// Stop broadcasting sync messages
				syncTimer.reset();
				syncTimer.stop();
			}
			else {
				// send to server
				sendCertified(settings.networkMap[0], STOP_HEADER);
			}		
		}			
		
		

		
		private function onDataReceived(e:DatagramSocketDataEvent):void	{
			var incoming:String = e.data.readUTFBytes(e.data.bytesAvailable);
			
			MonsterDebugger.trace(this, "Received from " + e.srcAddress + ":" + e.srcPort + "> " +	incoming);
			
			if (incoming.length > 0) {
				var header:String = incoming.substr(0, 1); // first character
				var body:String = "";
			
				// Handle certified packets, these require a response to the sender. Otherwise they're normal packets.
				if (header == CERTIFIED_HEADER) {
					// extract the actual packet header
					var lastCommaIndex:int = incoming.lastIndexOf(",");	
					header =  incoming.substr(1, 1); // second character
					body = incoming.substring(2, lastCommaIndex);
					var packetID:String = incoming.substr(lastCommaIndex + 1);
					
					// send the response
					send(settings.getScreenByIP(e.srcAddress, e.srcPort), CERTIFIED_RESPONSE_HEADER + packetID);
				}
				else {
					// not a certified packet
					body = incoming.substr(1); // second character onward is the body
				}
			
				//MonsterDebugger.trace(this, "Header: " + header);
				//MonsterDebugger.trace(this, "Body: " + body);
				
				switch (header) {
					case PING_HEADER:
						// nothing to do, pong is sent automatically through certified header
						break;
					
					case CERTIFIED_RESPONSE_HEADER:						
						// Calculate packet time, disarm timer, etc.
						var index:int = findPacketInWaitingIndex(parseInt(body));
						MonsterDebugger.trace(this, "Latency: " + (getTimer() - packetsInWaiting[index].timeSent) + "ms");
						
						// disable the alarm!
						packetsInWaiting[index].disarmTimeout();
						
						// mark respondent as connected
						packetsInWaiting[index].destination.connected = true;
						
						
						// remove the packet in waiting
						packetsInWaiting.splice(index, 1);
						break;
					
					// for server
					case START_HEADER:
						start();
						break;
						
					case STOP_HEADER:
						stop();
						break;
					
					// for broadcast
					case SYNC_HEADER:
						this.dispatchEvent(new SyncEvent(SYNC_EVENT));
						// dispatch event
						// TODO
						break;
						
					default:
						MonsterDebugger.trace(this, "Unknown header.");
						break;
				}
			}
		}
		

		
		protected function onTimeout(packet:CertifiedPacket):void {
			MonsterDebugger.trace(this, "Send timed out!");
			MonsterDebugger.trace(this, packet);
			
			// mark non-respondent as disconnected
			packet.destination.connected = false;			
			
			// remove the packet
			packetsInWaiting.splice(packetsInWaiting.indexOf(packet), 1);
			
			// TODO something else? Try again?
		}
		
		
		
		// Sends a packet		
		private function send(screen:NetworkedScreen, message:String):void {
			//Create a message in a ByteArray
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(message);
			
			//Send a datagram to the target
			try	{				
				udpSocket.send(data, 0, 0, screen.ip, screen.port); 
			}
			catch (error:Error)	{
				MonsterDebugger.trace(this, error.message);
			}
		}
		

		// Basic transmission functions
		
		// Sends a packet and requests a conformation from recipient		
		private function sendCertified(screen:NetworkedScreen, message:String, timeout:int = 500):void {
			// adds a certification wrapper
			var certifiedPacket:CertifiedPacket = new CertifiedPacket(message, screen, timeout, onTimeout);
			packetsInWaiting.push(certifiedPacket);
			send(screen, certifiedPacket.toMessage());
		}
		
		
		// sends a message to everyone except for the sender
		public function broadcastMessage(message:String):void {
			for each (var screen:NetworkedScreen in settings.networkMap) {
				if (screen != settings.thisScreen) {
					send(screen, message);
				}
			}
		}
		
		public function broadcastCertifiedMessage(message:String):void {
			for each (var screen:NetworkedScreen in settings.networkMap) {
				if (screen != settings.thisScreen) {
					sendCertified(screen, message);
				}
			}
		}
		
		// Convenience transmission functions
		
		// Wrapped up for convenience
		// messages are sent with a single bah
		public function ping(screen:NetworkedScreen):void {
			sendCertified(screen, PING_HEADER);
		}
		
		
		public function broadcastPing():void {
			broadcastCertifiedMessage(PING_HEADER);
		}		
		
		
		
		
		
		
		// Utilities...
		private function findPacketInWaitingIndex(packetID:int):int {
			for (var i:int = 0; i < packetsInWaiting.length; i++) {
				if (packetsInWaiting[i].packetID == packetID) return i;
			}
			return -1;
		}	
		

		public function getIDfromIP():int {
			// picks the id from settings that matches my IP
			// untested!
			
			var activeIPs:Array = listActiveIPs();
			
			for (var i:int = 0; i < settings.networkMap.length; i++) {
				if (activeIPs.indexOf(settings.networkMap[i].ip) > -1) {
					return settings.networkMap[i].id;
				}
			}
			
			// call it off if we can't find anything
			throw new Error("Could not find screen ID from machine IP!\n" + 
							"Make sure this computer's static ethernet IP is in one of the <screen> elements in the settings.xml file.\n" +
							"Alternately, set the screen ID manually by  calling settings.setMyID(id:int)\n");
		}
		
		
		public function listActiveIPs():Array {
			var networkInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var ips:Array = [];
			
			for (var i:int = 0; i < networkInterfaces.length; i++) {
				if (networkInterfaces[i].active) {
					// look through ips
					for (var j:int = 0; j < networkInterfaces[i].addresses.length; j++) {
						ips.push(networkInterfaces[i].addresses[j].address);
					}					
				}
			}
			
			return ips;
		}		

	}
}