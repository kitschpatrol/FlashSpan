// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the Creative Commons GNU GPL
// http://creativecommons.org/licenses/GPL/2.0/

// ServerConnection handles communication with the Java screen sync server

package com.kitschpatrol.flashspan
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	public class ServerConnection  extends EventDispatcher
	{
		private var host:String;
		private var port:int;
		private var socket:Socket;
		public var clientID:int; // fed from server
		 
		// some constants to type outgoing messages
		// these must match their siblings on the server
		private static const READY:String = "r";
		public static const HANDSHAKE:String = "h";
		private static const DISCONNECT:String = "d";
		private static const FRAME_SYNC_UPDATE:String = "y"; //incoming frame sync
		public static const FRAME_SYNC_REQUEST:String = "s"; //message to send frame sync, make function for this
		
		// for external message access
		public var currentMessage:String = "";
		
		// incoing message events for external access
		public static const HANDSHAKE_RETURNED_EVENT:String = "HANDSHAKE_RETURNED_EVENT";
		public static const CONNECTED:String = "CONNECTED";
		public static const READY_TO_START:String = "READY_TO_START";
		public static const FRAME_SYNC_REQUEST_RECEIVED:String = "FRAME_SYNC_REQUEST_RECEIVED";
		public static const FRAME_SYNC_UPDATE_RECEIVED:String = "FRAME_SYNC_UPDATE_RECEIVED";

		public function ServerConnection()
		{
			// construction handled in connect...
		}
		
		public function connect(_host:String, _port:int):void
		{
			host = _host;
			port = _port;
			
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, socketConnect);
			socket.addEventListener(Event.CLOSE, socketClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socketError );
				
			try 
			{
				socket.connect(host, port);
			}
			catch (e:Error) 
			{
				trace("Could not connect to " + host + " on port " + port);
			}
		}
		
		private function socketConnect(e:Event):void
		{
			// handle connection connected
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			
			// tk mark time for correction
			this.dispatchEvent(new Event(CONNECTED));
		}
		
		private function socketData(e:ProgressEvent):void
		{
			// reads from the socket
			receiveMessage(socket.readUTFBytes(socket.bytesAvailable));
		}
		
		private function socketClose(e:Event):void
		{
			// handle connection closed
			trace("\n Disconnected");
		}
		
		private function socketError(e:IOErrorEvent):void
		{
			// handle connection error
			trace("Socket Error");
		}
				
		private function sendMessage(message:String):void
		{
			// pushes a message to the sync server
			// need both line endings for cross-platform functionality
			message += "\r\n";
			
			if (socket && socket.connected)
			{
				socket.writeUTFBytes(message);
				socket.flush();
			}
		}
		
		public function handshake():void
		{
			sendMessage(HANDSHAKE);
		}
		
		public function ready():void
		{
			sendMessage(READY);
		}
		
		public function disconnect(e:MouseEvent):void
		{
			sendMessage(DISCONNECT);
		}
		
		public function sendFrame(_currentFrame:int):void
		{
			sendMessage(FRAME_SYNC_REQUEST + ";" + _currentFrame);
		}
		
		private function receiveMessage(message:String):void
		{
			// routes incoming messages
			
			// CASE would be cleaner here, but if statements are a bit faster
			if (message == READY)
			{
				this.dispatchEvent(new Event(READY_TO_START));
			}
			else if (message.charAt(0) == HANDSHAKE)
			{
				// move the message to a static var
				currentMessage = message;
				
				// grab our client ID from the handshake
				clientID = parseInt(message.split(";")[1]);
				
				trace("Handshake returned, Client ID: " + clientID);
				
				// send the event
				this.dispatchEvent(new Event(HANDSHAKE_RETURNED_EVENT));
			}
			else if (message.charAt(0) == FRAME_SYNC_REQUEST)
			{
				// ping back the server with current frame
				// tk why not ditch the event and do this directly?	
				currentMessage = message;
				this.dispatchEvent(new Event(FRAME_SYNC_REQUEST_RECEIVED));
			}
			else if (message.charAt(0) == FRAME_SYNC_UPDATE)
			{
				// actually sync the frames
				currentMessage = message;
				this.dispatchEvent(new Event(FRAME_SYNC_UPDATE_RECEIVED));				
			}
			else
			{
				// unknown message
				trace("Mystery Message: " + message + "\n");
			}
		}
	}
}