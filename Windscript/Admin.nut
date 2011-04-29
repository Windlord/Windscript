/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


// NEED TO EDIT AND ADD IN COMMANDLEVEL RETRIEVING!!! //
// Note: This function also checks whether a player is registered
//       if a command's level is set to 2
function CheckLevel ( player, command, ... )
{
	if ( vargv.len() > 0 && player.ID > 1000 )
	{
		mError( "InGame Command ("+ command.toupper() +")", player );
		return false;
	}

	local commandlvl = 4, user = GetUser( player );
	if ( user.Level >= commandlvl ) return true;
	else
	{
		mError( "Invalid Command ("+ command.toupper() +")", player );
		return false;
	}
}


function UpdateUptime()
{
	local inctime = GameTimerTicks - UptimeLastUpdated;
	UptimeLastUpdated <- GameTimerTicks;
	return IncData( "Misc", "TotalUptime", inctime );
}
