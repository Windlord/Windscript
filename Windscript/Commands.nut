/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function cmdRegister ( player, params )
{
	if ( !params ) return mFormat ( "/register <Password>", player );
	if ( !GetUser( player ).SetPassword( params ) )
		return mError ( "Your nickname is already registered.", player );
}

function cmdLogin ( player, params )
{
	local user = GetUser( player )
	if ( user.LoggedIn ) return mError ( "You are already logged in.", player );
	if ( !params ) return mFormat ( "/login <Password>", player );

	local success = user.Login( params );
	switch ( success )
	{
		case 1:
			return true;
		case 0:
			return mError ( "Your Nickname is not registered.", player );
		case -1:
			return mError ( "Invalid Password", player );
	}
}

function cmdChangePass ( player, params )
{
	local user = GetUser( player );
	if ( !user.Pass ) return mError ( "Please register first using /register", player );
	if ( !param ) return mError ( );
}

function cmdSay ( player, params )
{
	if ( !params ) return mError ( "No text to send.", player );
	return EMessage ( FindLevel( player, 3 ) + iCol( 6, ": " ) + params, colWhite );
}

function cmdMe ( player, params )
{
	if ( params )
		return EMessage ( iCol( 7, "* "+ FindLevel( player, 2 ) + player.Name + " " + params ), colYellow );
	else
		return mError ( "No text to send.", player );
}

function cmdKill ( player )
{
	local user = GetUser( player );
	user.SuicideCount++;
	player.Health = 0;
}

function cmdPos ( plr )
	EMessage( plr.Name +" - "+ plr.Pos.x +" "+ plr.Pos.y +" "+ plr.Pos.z +" "+ plr.Angle );

function cmdUptime ( player )
{
	local svr = ( GameTimerTicks - cInit_Ticks ) / 1000;
	local tot_uptime = GetData( "Misc", "TotalUptime" );
	tot_uptime = tot_uptime ? tot_uptime : 0;
	tot_uptime += time() - UptimeLastUpdated;
	SendMessage( iCol( 2, "Server Uptime: " ) + iCol( 6, Duration( svr ) ), player );
	if ( tot_uptime ) SendMessage( iCol( 2, "Total Uptime: " ) + iCol( 6, Duration( tot_uptime ) ), player );
	return 1;
}

function cmdCreateBot ( player, param )
{
	if ( CheckLevel( player, "createbot" ) )
	{
		if ( param.len() > 1 )
		{
			param = split( param, " " )[ 0 ];
			Echo( iCol( 5, "* Creating a bot with the name of \""+ param +"\"" ) );
			CallFunc2( "CreateBot", param );
			return 1;
		}
		else mFormat( "!createBot <Bot Name>", player );
	}
}

function cmdIRCDo ( player, params )
{
	if ( CheckLevel( player, "ircdo" ) )
	{
		local p = split( params, " " );
		if ( p.len() > 1 )
			CallFunc2( "FindBotDo", p[ 0 ], JoinArray( p.slice( 1 ), " " ) );
		else mFormat( "!IRCDo <Bot Name> <Raw IRC Command>", player );
	}
}

function cmdRaw ( player, params )
{
	if ( CheckLevel( player, "raw" ) )
	{
		if ( params )
		{
			local result, exec = compilestring( "return "+ params );
			try { result = exec(); } catch ( err )
			if ( err )
			{
				mError( err, player );
				return;
			}
			SendMessage( iBold( iCol( 4, "RAW :: " ) ) + result, player, colRed );
		}
		else mFormat( "!raw <Squirrel Code>", player );
	}
}

function cmdReload ( player )
{
	if ( CheckLevel( player, "reload" ) )
	{
		local dur = GameTimerTicks - cInit_Ticks;
		if ( dur > 60000 )
		{
			EMessage( iCol( 4, "* Reloading Windscript..." ), colRed );
			CallFunc2( "ReloadScript" );
		}
		else mError( "Wait "+ Duration( ( 60000 - dur ) / 1000 ) +" more to use this command.", player );
	}
	return 1;
}

