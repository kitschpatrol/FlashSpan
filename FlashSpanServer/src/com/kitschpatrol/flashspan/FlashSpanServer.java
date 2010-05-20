// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the Creative Commons GNU GPL
// http://creativecommons.org/licenses/GPL/2.0/

// FlashSpan is designed to span Flash content accross multiple computers / monitors / projectors
// It was originally written for the Newsworthy project at the Hyde Park Art Center
// A version of the project remains online: http://newsworthychicago.com

// FlashSpanServer tracks how many frames each client has rendered, and then echos these
// counts back to the clients. The clients then figures out if it's running slower or faster
// than the other clients, and adjusts its rendering rate accordingly

// This occasional sync approach isn't as ideal, and can result in some stuttering
// but Flash's rendering system has made a per-frame approach nigh impossible (for now)

// Known bug: If a client quits without disconnecting, the server loops to death
// so make sure the process gets killed

// Edit setting.ini to change the number of screens or the port

package com.kitschpatrol.flashspan;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

public class FlashSpanServer
{
	public ServerSocket server;
	private BufferedReader in;
	public static ArrayList<com.kitschpatrol.flashspan.ClientConnection> clientList  = new ArrayList<com.kitschpatrol.flashspan.ClientConnection>(); //holds active connections
  private int readyClientCount = 0;
	private int connectedClientCount = 0;
	private int frameSyncCount = 0;
	private String settingsFile = "settings.ini";
	
	// set from settingsFile, these are just defaults
	private int totalClientCount = 2;
	private int port = 58228;
	
	//message types
	public final static char READY = 'r'; // client is ready for the next frame
	public final static char HANDSHAKE = 'h';
	public final static char DISCONNECT = 'd';
	public final static char CLIENT_CLOSED = (char)65535; // ugly
	public final static char FRAME_SYNC = 's';
	
  // Frame Sync
  private int frameSyncInterval = 250; // 1/4 second... still looking for ideal
  private Timer frameSyncTimer;
  public FrameSyncTask frameSyncTask = new FrameSyncTask();
	
	// fire up the server
	public void start()
	{
		setSettings();
		create();
		run();
	}
	
	// load the settings from the ini file, should parse dynamically
	// static order for now, rather sloppy and disaster prone
	// just pass from the command line or batch file, instead?
	private void setSettings()
	{
		try
		{
			System.out.println("Loading settings from " + settingsFile);
			
			FileReader input = new FileReader(settingsFile);
			BufferedReader bufRead = new BufferedReader(input);
					
			String line;
			String [] splitLine = null;
			
			line = bufRead.readLine();
			splitLine = line.split("=");
			port = Integer.valueOf(splitLine[1]);
			
			line = bufRead.readLine();
			splitLine = line.split("=");		  
			totalClientCount = Integer.valueOf(splitLine[1]);
			
			 bufRead.close();
		}
		catch (ArrayIndexOutOfBoundsException e)
		{   
			System.out.println("Can't find the file\n");			
		}
		catch (IOException e)
		{
			// generic error
		  e.printStackTrace();
		}
	}
	
	// open the port
	private void create()
	{
		System.out.println("Opening " + totalClientCount + " screen FlashSpan server on port " + port);
		
		try
		{
			server = new ServerSocket(port);
		}
		catch (Exception e)
		{
			System.out.println("ERROR: Trouble opening server on port " + port);
			e.printStackTrace();
			System.exit(-1);
		}
	}
	
	// start listening for connections to the port
	public void run()
	{
		// listen for connections
		while (true)
		{
			System.out.println("Listening for connections...");

			try
			{
				//create a client and add it to the list
				clientList.add(new ClientConnection(server.accept(), this));
				
				// start up the client
				clientList.get(clientList.size() - 1).start();
			}
			catch (Exception e)
			{
				System.out.println("ERROR: Client connection failed");
				e.printStackTrace();
				System.exit(0);
			}
		}
	}
	
	// shutdown the server
	protected void finalize()
	{	 
		try
		{
			in.close();
			server.close();    
		}
		catch (IOException e) 
		{
			e.printStackTrace();
			System.exit(-1);
		}
	}
	
	public synchronized void handleMessage(ClientConnection clientConnection)
	{
		// print any message for the log
		// System.out.println("RAW MESSAGE: " + clientConnection.message + " AT TIME: " + System.currentTimeMillis());
		
		// extract the message type
		char messageType = clientConnection.message.charAt(0);
		
		// send to the appropriate handler
		if (messageType == READY)
		{
			//set the client, but only if it's not already set
			if(!clientConnection.readyForFrame)
			{
				clientConnection.readyForFrame = true;
				readyClientCount++;
			}
			
			System.out.println(readyClientCount + "/" + totalClientCount + " screens ready to start");
			
			// is everyone ready?
			if(readyClientCount == totalClientCount)
			{			
				// tell everyone to start
				broadcastMessage("r");
				
				// start syncing the frames
				startFrameSyncTimer();
			}
		}
		else if (messageType == FRAME_SYNC)
		{
			// this is now a one-time thing, just for starting up
			
			//set the client, but only if it's not already set
			if(!clientConnection.readyForSync)
			{
				String tempCurrentFrame = clientConnection.message.substring(2);
				
				//extract frame sync message
				clientConnection.currentFrame = Integer.valueOf(tempCurrentFrame);
				
				clientConnection.readyForSync = true;
				frameSyncCount++;
			}
			
			//System.out.println(frameSyncCount + "/" + totalClientCount + " screens ready to sync");
			
			//is everyone ready?
			if(frameSyncCount == totalClientCount)
			{			
				//Ok, Assemble and send the frame sync info
				String frameSyncMessage = "y;";
				
				//reset ready for sync
		    for (int i=0; i < FlashSpanServer.clientList.size(); i++)
		    {
		    	clientList.get(i).readyForSync = false;
		    	// clients need to listen for "y"
		    	frameSyncMessage += clientList.get(i).clientID + ";" + clientList.get(i).currentFrame+ ";";
		    }
				
		    //System.out.println(frameSyncMessage);
		     
		    //send it to everyone	     
				broadcastMessage(frameSyncMessage);
				
				frameSyncCount = 0;
			}
		}
		else if (messageType == HANDSHAKE)
		{
			//set the ID
			clientConnection.clientID = connectedClientCount;
			
			// tk send the server time
			// tk note corrected time
			sendMessage(clientConnection, HANDSHAKE + ";" + clientConnection.clientID);
			System.out.println(clientList.size() + "/" + totalClientCount + " screens connected");
			
			//bump the client count
			connectedClientCount++;
			
			//if everyone's connected, send "all connected message"
			if(connectedClientCount == totalClientCount)
			{
				System.out.println("all screens connected");
			}
		}
		else if ((messageType == DISCONNECT) || (messageType == CLIENT_CLOSED))
		{
			disconnectClient(clientConnection);
		}
		else
		{
			// unknown message...
			System.out.println("Mystery message from client " + clientConnection.clientID + ": " + clientConnection.message);
		}
	}
	
	public synchronized void disconnectClient(ClientConnection clientConnection)
	{
		// kill off the client thread
		System.out.println("Disconnecting Client");
		
		//interrupt the thread
		clientConnection.keepRunning = false;

		//kill the thread
		clientConnection.finalize();
		
		//remove it from the list
		clientList.remove(clientConnection);
	}
	
	//sends message to everyone connected
	public synchronized void broadcastMessage(String message)
	{
		//TELL EVERYONE
     for (int i=0; i < FlashSpanServer.clientList.size(); i++)
     {
    	 sendMessage(clientList.get(i), message);
     }
	}
	
	//sends message to a single client
	public synchronized void sendMessage(ClientConnection clientConnection, String message)
	{
		clientConnection.out.write(message +"\0");
		clientConnection.out.flush();
	}
	
	// set up frame sync timer
	public void startFrameSyncTimer()
	{
		frameSyncTimer = new Timer();
		frameSyncTimer.scheduleAtFixedRate(frameSyncTask, frameSyncInterval, frameSyncInterval);
	}

  class FrameSyncTask extends TimerTask {
    public void run()
    {
      //tell the clients to send their current frame
    	callForFrames();
    }
  }
  
  private void callForFrames()
  {
  	broadcastMessage(FRAME_SYNC + ";");
  }
  
	// entry-point
	public static void main( String[] args )
	{
		try
		{
			FlashSpanServer server = new FlashSpanServer();
			server.start();
		}
		catch ( Exception e )
		{
			e.printStackTrace();
			System.exit( 0 );
		}
	}
}