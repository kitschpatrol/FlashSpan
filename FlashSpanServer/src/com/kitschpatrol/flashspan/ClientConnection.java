// Eric Mika, 2008
// ermika@gmail.com
// http://kitschpatrol.com

// This software is licensed under the GNU LGPL
// http://www.gnu.org/licenses/lgpl.html

// ClientConnection starts a separate thread which listen to each client

package com.kitschpatrol.flashspan;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class ClientConnection extends Thread
{
	public Socket client = null;
	private BufferedReader in;
	public PrintWriter out;
	public String message = "";
	public boolean keepRunning = true;
	public boolean readyForFrame = false;
	public boolean readyForSync = false;
	private FlashSpanServer mainServer;
	public int clientID = 0;
	public int currentFrame = 0;
	
	public ClientConnection(Socket socket, FlashSpanServer serverReference)
	{
		super("FenestraeServer");
		
		mainServer = serverReference;
		this.client = socket;
		//client.setTcpNoDelay(true);
		
		System.out.println("New client connected from " + client.getInetAddress().getCanonicalHostName());	
	}
	
	 protected void finalize()
	{
		try
		{
			this.client.close();
		}
		catch (IOException e)
		{
			System.out.println("ERROR: Could not close socket");
		}
	}
	 
	@SuppressWarnings("unchecked")
	public void run()
	{
		try
		{
			in = new BufferedReader(new InputStreamReader( client.getInputStream() ) );
			out = new PrintWriter( client.getOutputStream() );
		}
		catch (Exception e)
		{
			e.printStackTrace();
			System.exit(0);
		}
		
		while (keepRunning)
		{	
			// listen for incoming messages
			try
			{
				// read from the socket
				message = in.readLine();
				
				if (message != null)
				{
					mainServer.handleMessage(this);
				}
			}
			catch (Exception e)
			{
				e.printStackTrace();
				continue;
			}
		}	
	}	
}
