// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// FlashSpan is designed to span Flash content accross multiple computers / monitors / projectors
// It was originally written for the Newsworthy project at the Hyde Park Art Center
// A version of the project remains online: http://newsworthychicago.com

package
{
	import com.kitschpatrol.flashspan.BigScreen;
	import com.kitschpatrol.flashspan.ServerConnection;
	import com.kitschpatrol.ui.LabeledInput;
	import com.kitschpatrol.ui.SimpleButton;
	import com.kitschpatrol.ui.SimpleLabel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	// stage size
	// spanning accross screens of different sizes will require individually compiled swfs
	[SWF(width="400", height="600", backgroundColor="0xc9c9c9", frameRate="40")]
	
	public class FlashSpanClient extends Sprite
	{
		// the total dimensions of all the screens
		private const BIG_WIDTH:int = 800;
		private const BIG_HEIGHT:int = 600;
		
		// local variables store server and offset settings between sessions
		private var localData:SharedObject;
		private var portInput:LabeledInput;
		private var ipInput:LabeledInput;
		private var xInput:LabeledInput;
		private var yInput:LabeledInput;
		
		private var connectButton:SimpleButton;
		private var interfaceLayer:Sprite;
		
		// the BigScreen class replaces the stage
		// for spanned animations
		private var bigScreen:BigScreen;
		private var server:ServerConnection;
		private var currentFrame:int = 0;
		
		// render this many animation frames for any given frame of time
		// in case of a slowdown, this number increases to run
		// multiple animation frames in one frame of time 
		private var framesToRender:int = 1;
				
		public function FlashSpanClient()
		{
			// prep the stage
			stage.align = StageAlign.TOP_LEFT;
			
			
			// grab the local data
			localData = SharedObject.getLocal("userData");
			
			// setup the bigscreen, it will get offset later
			bigScreen = new BigScreen(BIG_WIDTH, BIG_HEIGHT);
			addChild(bigScreen);
			
			// draw the interface
			interfaceLayer = new Sprite();
			drawInterface(interfaceLayer);
			interfaceLayer.x = 10;
			interfaceLayer.y = 10;
			addChild(interfaceLayer);
		}
		
		private function onConnect(e:MouseEvent):void
		{
			trace("Connecting");
			
			// disable the buttons
			connectButton.disable();
			portInput.disable();
			ipInput.disable();
			xInput.disable();
			yInput.disable();
			
			// save server settings to a local shared object
			// AIR would let us keep these in a local .ini or .xml file
			localData.data.port = portInput.inputField.text; 
			localData.data.ip = ipInput.inputField.text;
			localData.data.x = xInput.inputField.text;
			localData.data.y = yInput.inputField.text;
			localData.flush();
			
			// apply offset to bigScreen
			bigScreen.x = -parseInt(xInput.inputField.text);
			bigScreen.y = -parseInt(yInput.inputField.text);
			
			// this talks to the java screen-sync server
			server = new ServerConnection();
			
			//add server listeners
			server.addEventListener(ServerConnection.CONNECTED, onConnected);
			server.addEventListener(ServerConnection.HANDSHAKE_RETURNED_EVENT, onHandshakeReturned);
			
			// connect to the server
			// use "localhost" for the IP if testing on a single computer
			server.connect(localData.data.ip, parseInt(localData.data.port));
		}
		
		private function onConnected(e:Event):void
		{
			trace("Connected");
			
			// send handshake, the server will send a handshake back
			// tk time offset correction code
			server.handshake();
		}
		
		private function onHandshakeReturned(e:Event):void
		{
			// tell the server we're ready to go
			// this could be delayed to load web data or
			// perform other setup functions
			server.ready();
			
			// start listening for frame sync messages from the server
			server.addEventListener(ServerConnection.FRAME_SYNC_REQUEST_RECEIVED, frameSyncRequestReceived);
			server.addEventListener(ServerConnection.FRAME_SYNC_UPDATE_RECEIVED, frameSyncUpdateReceived);
		}

		private function frameSyncRequestReceived(e:Event):void
		{
			// start the ENTER_FRAME loop if it's the first sync request
			// this ensures that all clients start at the same time
			if(currentFrame == 0)
			{
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			// send current frame to the server
			server.sendFrame(currentFrame);
		}
		
		private function frameSyncUpdateReceived(e:Event):void
		{
			// sync data comes in the following format
			// header;clientid;framecount;clientid;framecount...
			// e.g "y;0;442;1;443;"
			
			// split the string
			var frameSyncList:Array = server.currentMessage.split(";");
			
			// clean it up
			frameSyncList.shift();
			frameSyncList.pop();
			
			var frameLag:int = 0;
			var fastestFrame:int = 0;
			var fastestID:int = 0;
			var ourFrame:int = 0; // client's frame count when we sent sync
			
			// see where we are in the rendering race
			for(var i:int = 0; i < frameSyncList.length; i+=2)
			{
				var tempID:int = frameSyncList[i];
				var tempFrame:int = frameSyncList[i+1]
				
				if(tempFrame > fastestFrame)
				{
					fastestFrame = tempFrame;
					fastestID = tempID;
				}
				
				// figure frame lag
				if(server.clientID == tempID)
				{
					ourFrame = tempFrame;
					frameLag = currentFrame - tempFrame;
				}
			}
			
			// if we're not the fastest, figure out how many frames to skip
			if(server.clientID !== fastestID)
			{
				//add the frames to the render job,
				framesToRender += fastestFrame - ourFrame - frameLag;
				
				//make sure it's positive
				if(framesToRender < 1)
				{
					framesToRender = 1;
				}
			}
		}

		// render loop
		private function onEnterFrame(e:Event):void
		{
			// run multiple times if we need to catch up
			while(framesToRender > 0)
			{
				// update any animations in the big screen
				bigScreen.update();
		
				currentFrame++;
				framesToRender--;
			}	
			
			// reset render count now that we've cought up
			framesToRender = 1;
		}
		
		// one-time interface setup
		// should be its own class
		private function drawInterface(targetLayer:Sprite):void
		{
			var fieldOffset:Number = 60;
			var pad:Number = 4;
			
			var headline:SimpleLabel = new SimpleLabel("FlashSpan Setup");
			headline.y = pad;
			headline.x = pad;
			targetLayer.addChild(headline);
			
			portInput = new LabeledInput("Port", 80);
			portInput.y = headline.y + headline.height + pad * 2;
			portInput.x = fieldOffset;
			if(localData.data.port !== undefined) portInput.inputField.text = localData.data.port;			
			targetLayer.addChild(portInput);
			
			ipInput = new LabeledInput("Server IP", 80);
			ipInput.y = portInput.y + portInput.height + pad;
			ipInput.x = fieldOffset;
			if(localData.data.ip !== undefined) ipInput.inputField.text = localData.data.ip;
			targetLayer.addChild(ipInput);
			
			xInput = new LabeledInput("X Position", 80);
			xInput.y = ipInput.y + ipInput.height + pad;
			xInput.x = fieldOffset;
			if(localData.data.x !== undefined) xInput.inputField.text = localData.data.x;
			targetLayer.addChild(xInput);
	
			yInput = new LabeledInput("Y Position", 80);
			yInput.y = xInput.y + xInput.height + pad;
			yInput.x = fieldOffset;
			if(localData.data.y !== undefined) yInput.inputField.text = localData.data.y;
			targetLayer.addChild(yInput);		

			connectButton = new SimpleButton("CONNECT", onConnect, 80, 15);
			connectButton.y = yInput.y + yInput.height + pad * 2;
			connectButton.x = fieldOffset;
			targetLayer.addChild(connectButton);
			
			// fill the background
			targetLayer.graphics.beginFill(0xffffff);
			targetLayer.graphics.drawRect(0, 0, targetLayer.width + pad * 3, targetLayer.height + pad * 3);
			targetLayer.graphics.endFill();
			
			// tk auto fade, console, status, fullscreen, that sort of thing
		}
		
		// utility to print what's in the flash cookie
		private function traceLocalData(local:SharedObject):void
		{
			for each(var item:Object in local.data)
			{
				trace(item);
			}	
		}
	}
}
