/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 version 1.0
	                                 by Windlord	*/

/* The following is Juppi's example for the vcmp server */
function JuppionScriptLoad()
{
	g_Sender <- "windscript@windlord.net";
	g_Rcver <- "juppi@project-apollo.co.uk";
	g_Subject <- "boobies";
	g_Message <- "m00!\nthis seems to work\n\n:_:";

	SendMail();
}

function SendMail()
{
	g_MailSocket <- NewSocket( "ProcessMail" );
	g_MailSocket.SetNewConnFunc( "ConnEstablished" );
	g_MailSocket.SetLostConnFunc( "CloseConnection" );
	g_MailSocket.Connect( "-clip-", 25 );

	g_Timer <- NewTimer( "CloseConnection", 2500, 1 );
}

function ConnEstablished()
{
	g_MailSocket.Send( "HELO localhost\n" );
	g_MailSocket.Send( "MAIL FROM: " + g_Sender + "\n" );
	g_MailSocket.Send( "RCPT TO: " + g_Rcver + "\n" );
	g_MailSocket.Send( "DATA\n" );
	g_MailSocket.Send( "SUBJECT: " + g_Subject + "\n" );
	g_MailSocket.Send( "\n" );
	g_MailSocket.Send( g_Message + "\n" );
	g_MailSocket.Send( ".\n" );
	g_MailSocket.Send( "QUIT\n" );
}

function CloseConnection()
{
	if ( g_MailSocket ) g_MailSocket.Delete();
	g_Timer.Delete();
}

function ProcessMail( sz )
{
}