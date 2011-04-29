/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function UpdateUptime()
{
	local inctime = GameTimerTicks - UptimeLastUpdated;
	UptimeLastUpdated <- GameTimerTicks;
	return IncData( "Misc", "TotalUptime", inctime );
}
