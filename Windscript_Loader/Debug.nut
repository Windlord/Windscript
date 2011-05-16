/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

DEBUG_STREAM <- null;
DEBUG_TIME <- null;
DEBUG_STAMP <- "";

// Function to add timestamps to debug messages
function debug ( msg )
{
	// Check if debug is turned on
	if ( config && config.rawin("debug") && !config.debug ) return false;
	else
	{
		local now = time();
		if ( now != DEBUG_TIME )
		{
			// Get date data table
			local dt = date();
			DEBUG_STAMP = format( "%02i/%02i %02i:%02i:%02i", dt.day, dt.month, dt.hour, dt.min, dt.sec );
			DEBUG_TIME = now;
		}
		msg = DEBUG_STAMP +" :: "+ msg;

		// Initiate file stream if not already done
		if ( !DEBUG_STREAM )
		{
			DEBUG_STREAM = file( cScript_Dir +"debug.log", "a" );
			DEBUG_STREAM.writen( '\r', 'b' );
			DEBUG_STREAM.writen( '\n', 'b' );
		}

		// Write debug message to file stream
		foreach ( idx, chr in msg )
			DEBUG_STREAM.writen( chr, 'b' );

		// Write newline to make debug.log readable
		DEBUG_STREAM.writen( '\r', 'b' );
		DEBUG_STREAM.writen( '\n', 'b' );

		print( "\r"+ msg );
		return true;
	}
}
