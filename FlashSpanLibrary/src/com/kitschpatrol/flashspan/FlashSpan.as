package com.kitschpatrol.flashspan
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.DatagramSocket;
	
	public class FlashSpan extends EventDispatcher
	{
		public function FlashSpan(target:IEventDispatcher=null)
		{
			super(target);
			trace("flash span constructed");
		}
	}
}