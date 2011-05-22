/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


AdminServ <- User( config.server_adminbot );
AdminServ.Level = 6;

// This function is for use in kicking players
function AdminKick ( admin, user, reason = "No Reason" )
{
	if ( admin == user ) return mError( "You are trying to kick yourself.", admin );
	admin.Kicks++;
	user.Kicked++;
	AdminPM ( "You have been kicked by "+ admin + " for \""+ reason +"\".", user );
	AdminPM ( "If you believe this is unfair, please appeal at "+ config.server_url, user );
	onPlayerPart( user.Player, PARTREASON_KICKED, reason );
	KickPlayer( user.Player );
}

// This function is to check whether the nickname of a player is valid.
function CheckNickname ( player )
{
	local lname = player.Name.tolower();					// Make lower to match case-insensitively
	if ( lname.len() < 2 ) return null;					// If name is 1 char, invalid

	foreach ( val in IRC_LEVELNAME )					// If user's name is the same as level names
		if ( val.tolower() == lname ) return null;			// there's a slight confusion

	if ( lname == config.server_adminbot.tolower() ) return null;

	if ( "invalid_names" in config )					// If explicitly set in config
	{
		local invalid_names = split( config.invalid_names, ", " );
		foreach ( name in invalid_names )
			if ( name.tolower() == lname ) return null;
	}
	return true;								// Otherwise, return true
}

// This is for when the server is reloaded or if players join too quickly.
function ReloadPlayers ( )
{
	local p = 0, plr, plrs = GetPlayers();
	for ( local i = 0; i < cMax_Players; i++ )
	{
		plr = FindPlayer( i );
		if ( plr )
		{
			debug( "Re-adding player "+ plr.Name );
			onPlayerConnect( plr );
			p++;
		}
		if ( p == plrs ) break;
	}
}

function UnloadPlayers ( )
{
	foreach ( pname, user in OnlineUsers )
		onPlayerPart( user.Player, PARTREASON_DISCONNECTED );
}

function UpdateIPInfo ( user )
{
	if ( user.InGame )
	{
		// Add current IP to user access list
		local name = user.Name, ip = user.Player.IP;
		user.IP = ip;

		// Add nickname to IP_Records list
		local names = GetData( "IP_Records", ip ), result;
		names = names ? names : "";
		result = AddToList( names, name );
		if ( result != names )
		{
			AddData( "IP_Records", ip, result );
			IncData( "UserData", "TotalVisitorIPs" );
			if ( names == "" ) GetIPInfo( ip );
		}

		// Do the same as above for the Subnet_Records list
		local subnet = GetSubnet( ip )
		names = GetData( "Subnet_Records", subnet );
		names = names ? names : "";
		result = AddToList( names, name );
		if ( result != names ) AddData( "Subnet_Records", subnet, result );
	}
}

// Note: This function also checks whether a player is registered if a command's level is set to 1
function CheckLevel ( player, command, ingame = false )
{
	local user = GetUser( player ), userlvl;
	if ( typeof( player ) == "IRCUser" )
	{
		if ( ingame )
		{
			mError( "InGame Command ("+ command.toupper() +")", player );
			return false;
		}
		userlvl = player.Level();
	}
	else userlvl = user.Level;

	local commandlvl = CommandLevel( command );
	if ( userlvl >= commandlvl ) return true;
	else
	{
		mError( "Invalid Command ("+ command.toupper() +")", player );
		return false;
	}
}

function CommandLevel ( command )
	return GetData( "CommandLevels", command );

UptimeLastUpdated <- 0;
function UpdateUptime()
{
	local inctime = time() - UptimeLastUpdated;
	UptimeLastUpdated = time();
	return IncData( "Misc", "TotalUptime", inctime );
}
