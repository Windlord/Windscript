/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

// Function to add timestamps to debug messages
function debug ( msg )
{
	// Check if debug is turned on
	if ( config && config.rawin("debug") && !config.debug ) return false;
	else
	{
		// Get date data table
		local dt = date();
		local timestamp = format( "%02i/%02i %02i:%02i:%02i", dt.day, dt.month, dt.hour, dt.min, dt.sec );
		msg = timestamp +" :: "+ msg;

		// Initiate file stream if not already done
		if ( !getroottable().rawin( "DEBUG_STREAM" ) )
			DEBUG_STREAM <- file( cScript_Dir +"debug.log", "a" );

		// Write debug message to file stream
		foreach ( idx, chr in msg )
			DEBUG_STREAM.writen( chr, 'b' );

		// Write newline to make debug.log readable
		debug_newline();

		print( "\r"+ msg );
		return true;
	}
}


function debug_newline ()
{
	DEBUG_STREAM.writen( '\r', 'b' );
	DEBUG_STREAM.writen( '\n', 'b' );
}

{
	debug_newline();
}