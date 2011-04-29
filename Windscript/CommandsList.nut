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
	if 		( command == "register" ) return cmdRegister( player, params );
	else if ( command == "login" 	) return cmdLogin	( player, params );
	else
	{
		if ( params ) Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command +" "+ params );
		else Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command );
		return onCommand( player, command, params );	// Forward commands
	}
}


function onCommand ( player, command, params )
{
	local a = "";
	foreach( val in command )								// For each character in the variable command
		if ( val != 33 && val != 47 ) a += val.tochar();	// Only write char if value isn't "!" or "/"
	command = (a == "") ? null : a;							// This strips command of "!" and "/"
															// Note that this bit of code also makes it impossible for command names with "!" or "/" in them to work.

	params = ( params == "" ) ? null : params;
	if ( command )
	{
		if 		( command == "say"		) return cmdSay      ( player, params );
		else if	( command == "me"		) return cmdMe       ( player, params );
		else if ( command == "kill"		) return cmdKill     ( player );
		else if ( command == "pos"		) return cmdPos      ( player );
		else if	( command == "uptime"	) return cmdUptime   ( player );
		else if ( command == "createbot") return cmdCreateBot( player, params );
		else if ( command == "ircdo"	) return cmdIRCDo    ( player, params );
		else if ( command == "raw"		) return cmdRaw      ( player, params );
		else if	( command == "reload"	) return cmdReload   ( player );
		else if	( command == "away"		) return cmdAway     ( player, params );
		else if	( command == "back"		) return cmdBack     ( player );
		else if	( command == "afk"		) return cmdAfk      ( player, params );
		else if ( command == "wep"		) player.SetWeapon( GetWeaponIDFromName( params ) );
		else if ( command == "goto"     ) player.Pos = FindPlayer( params ).Pos;
		else if ( command == "spawn"    ) CreateVehicle( GetVehicleIDFromName( IsNum( params ) ? params.tointeger() : params ), player.Pos, 0 );
		else mError( "Invalid Command ("+ command.toupper() +")", player );
	}
}
