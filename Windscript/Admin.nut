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
function CheckLevel ( player, command, ingame = false )
{
	local userlvl;
	if ( player.ID > 1000 )
	{
		if ( ingame )
		{
			mError( "InGame Command ("+ command.toupper() +")", player );
			return false;
		}
		userlvl = player.Level;
	}
	else userlvl = GetUser( player ).Level;

	local commandlvl = 4;
	if ( userlvl >= commandlvl ) return true;
	else
	{
		mError( "Invalid Command ("+ command.toupper() +")", player );
		return false;
	}
}


function UpdateUptime()
{
	local inctime = GameTimerTicks / 1000 - UptimeLastUpdated;
	UptimeLastUpdated <- GameTimerTicks / 1000;
	return IncData( "Misc", "TotalUptime", inctime );
}
