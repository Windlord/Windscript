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
	params = ( params == "" ) ? 0 : params;

	// The following commands are put under this signal while all other commands are
	// forwarded to the function "onCommand". This is so that the usage of these commands
	// are not echoed or used with !commands.
	switch ( command )
	{
		case "register": return cmdRegister ( player, params );
		case "login": return cmdLogin ( player, params );
		default:
			if ( params ) Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command +" "+ params );
			else Echo( FindLevel( player, 3 ) + iCol( 3, ": /" ) + command );
			return onCommand( player, command, params );	// Forward commands
	}
}


function onCommand ( player, command, params )
{

	local a = "", inplugins;
	foreach( val in command )					// For each character in the variable command
		if ( val != '!' && val != '/' ) a += val.tochar();	// Only write char if value isn't "!" or "/"
	command = (a == "") ? null : a;					// This strips command of "!" and "/"
									// Note that this bit of code also makes it impossible for command names with "!" or "/" in them to work.
	switch ( command )
	{
		case "suggest": return cmdSuggest( player, params );

		case "say": return cmdSay ( player, params );
		case "me": return cmdMe ( player, params );
		case "kill": return cmdKill ( player );
		case "pos": return cmdPos ( player );
		case "uptime": return cmdUptime ( player );
		case "createbot": return cmdCreateBot( player, params );

		case "ircdo": return cmdIRCDo ( player, params );
		case "raw": return cmdRaw ( player, params );
		case "reload": return cmdReload ( player );
		case "ip": return cmdIP ( player, params );
		case "kick": return cmdKick ( player, params );

		case "help": return cmdHelp ( player, params );
		case "set": return cmdSet ( player, params );

		default:
			inplugins = PluginCommand( command, player, params );
			return inplugins ? inplugins : mError( "Invalid Command ("+ command.toupper() +")", player );
	}
}
