/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


// Define difference in hours
RealTime_TZ <- 0;

// Lock time changes so that the script can manually change time.
SetTimeLock( true );

function SyncRealTime ()
{
	local now = date( time() + RealTime_TZ * 3600 );
	if ( GetMinute() != now.min || GetHour() != now.hour )
	{
		SetTime( now.hour, now.min );
	}
}

Plugins.RealTime.RegisterEvent( BackgroundOneSecond, SyncRealTime );