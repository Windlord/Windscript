/*
 *	 __       __)
 *	(, )  |  /  ,       /)             ,
 *	   | /| /    __   _(/  _   _  __    __  _/_
 *	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
 *	   /  |                          .-/
 *	_______________________________ (_/ ________
 *	                                 by Windlord	*/

function onPlayerCommand ( player, command, params )
{
	// The following commands are put under this signal while all other commands are
	// forwarded to the function "onCommand". This is so that the usage of these commands
	// are not echoed or used with !commands.
	if ( command == "register" ) return cmdRegister( player, params );
	else if ( command == "login" 	) return cmdLogin	( player, params );
	else
	{
		if ( params ) Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command +" "+ params );
		else Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command );
		return onCommand( player, command, params );		// Forward commands
	}
}


function onCommand ( player, command, params )
{
	local a = "";
	foreach( val in command )					// For each character in the variable command
		if ( val != '!' && val != '/' ) a += val.tochar();	// Only write char if value isn't "!" or "/"
	command = (a == "") ? null : a;					// This strips command of "!" and "/"
									// Note that this bit of code also makes it impossible for command names with "!" or "/" in them to work.

	params = ( params == "" ) ? null : params;
	switch ( command )
	{
		case "say": return cmdSay ( player, params );
		case "me": return cmdMe ( player, params );
		case "kill": return cmdKill ( player );
		case "pos": return cmdPos ( player );
		case "uptime": return cmdUptime ( player );
		case "createbot": return cmdCreateBot( player, params );
		case "ircdo": return cmdIRCDo ( player, params );
		case "raw": return cmdRaw ( player, params );
		case "reload": return cmdReload ( player );
		case "away": return cmdAway ( player, params );
		case "back": return cmdBack ( player );
		case "afk": return cmdAfk ( player, params );
		//else if ( command == "wep" ) player.SetWeapon( GetWeaponIDFromName( params ) );
		//else if ( command == "goto" ) player.Pos = FindPlayer( params ).Pos;
		//else if ( command == "spawn" ) CreateVehicle( GetVehicleIDFromName( IsNum( params ) ? params.tointeger() : params ), player.Pos, 0 );
		default: return mError( "Invalid Command ("+ command.toupper() +")", player );
	}
}
