/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function cmdIP ( player, params )
{
	local p = targetparams( player, params );
	if ( !p ) return mFormat ( "/ip <Player>", player );
	if ( p == -1 ) return;
	if ( CheckLevel( player, "ip" ) )
	{
		local tuser = GetUser( p.target );
		local ipf = IPInfo( tuser.IP );
		AdminPM( "Information for "+ ipf.IP, player );
		AdminPM( "rDNS: "+ ipf.rDNS, player );
		AdminPM( "Country: "+ ipf.Country, player );
		AdminPM( "City: "+ ipf.City, player );
	}
}

function cmdKick ( player, params )
{
	if ( !params ) return mFormat ( "/kick <Player> <Reason>", player );
	if ( CheckLevel( player, "kick" ) )
	{
		local p = targetparams( player, params );
		local user = GetUser( player ), kuser = GetUser( p.target );
		if ( p )
		{
			if ( p.params == "" ) return mFormat ( "/kick <Player> <Reason>", player );
			user.Kicks++;
			kuser.Kicked++;
			KickPlayer( p.target );
			onPlayerPart( p.target, PARTREASON_KICKED, p.params );
		}
	}
}


function cmdSet ( player, params )
{
	if ( CheckLevel( player, "set" ) )
	{
		local p =  CmdParamsfromText( params );
		if ( !p.cmd ) return mFormat( "/set <Option> <Value>", player );
		switch ( p.cmd )
		{
			case "cmdlvl":
				return cmdSetCommandLvl( player, p.params );
		}
		return mError( "The setting, "+ p.cmd.toupper() +" does not exist.", player );
	}
}

function cmdSetCommandLvl ( player, params )
{
	if ( !params ) return mFormat( "/set CmdLvl <Command> <Level 1-6>", player );
	if ( CheckLevel( player, "set commandlvl" ) )
	{
		params = split( params, " " );
		if ( params.len() < 2 ) return mFormat( "/set CmdLvl <Command> <Level 1-6>", player );
		local level = params.pop().tointeger(), cmd = JoinArray( params, " " ).tolower();
		if ( level > 6 || level < 0 ) return mError( "Invalid level specified.", player );
		if ( CommandLevel( cmd ) == level )
			return AdminPM( "Command level for "+ cmd.toupper() +" unchanged from "+ level, player );
		AddData( "CommandLevels", cmd, level );
		return AdminMessage( "Command level for "+ cmd.toupper() +" is now level "+level );
	}
}