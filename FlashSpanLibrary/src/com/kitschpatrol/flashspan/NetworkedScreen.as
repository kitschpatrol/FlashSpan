package com.kitschpatrol.flashspan
{
	public class NetworkedScreen extends Object
	{
		public var id:int;
		public var ip:String;
		public var port:int;
		
		// Simple structure for remote computer info.
		public function NetworkedScreen(_id:int, _ip:String, _port:int) {
			super();
			id = _id;
			ip = _ip;
			port = _port;
		}
	}
}