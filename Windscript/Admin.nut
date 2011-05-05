/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


// This is for when the server is reloaded or if players join too quickly.
function ReloadPlayers ( )
{
	local p = 0, plr, plrs = GetPlayers();
	for ( local i = 0; i < cMax_Players; i++ )
	{
		plr = FindPlayer( i );
		if ( plr )
		{
			onPlayerConnect( plr );
			p++;
		}
		if ( p == plrs ) break;
	}
}

function UnloadPlayers ( )
{
	foreach ( pname, user in OnlineUsers )
		onPlayerPart( user.Player, 0 );
}

function UpdateIPInfo ( user )
{
	if ( user.InGame )
	{
		// Add current IP to user access list
		local name = user.Player.Name, ip = user.Player.IP, ips = user.IPs;
		local result = AddToList( ips ? ips : "", ip );
		if ( result )
			user.IPs = result;

		// Add nickname to IP_Records list
		local names = GetData( "IP_Records", ip );
		names = names ? names : "";
		result = AddToList( names, name );
		if ( result )
		{
			AddData( "IP_Records", ip, result );
			IncData( "UserData", "VisitorIPsCount" );
		}

		// Do the same as above for the Subnet_Records list
		local subnet = GetSubnet( ip )
		names = GetData( "Subnet_Records", subnet );
		names = names ? names : "";
		result = AddToList( names, name );
		if ( result )
			AddData( "Subnet_Records", subnet, result );
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
		userlvl = player.Level;
	}
	else userlvl = user.Level;

	local commandlvl = GetData( "CommandLevels", command );
	if ( userlvl >= commandlvl ) return true;
	else
	{
		mError( "Invalid Command ("+ command.toupper() +")", player );
		return false;
	}
}

UptimeLastUpdated <- 0;
function UpdateUptime()
{
	local inctime = time() - UptimeLastUpdated;
	UptimeLastUpdated = time();
	return IncData( "Misc", "TotalUptime", inctime );
}
