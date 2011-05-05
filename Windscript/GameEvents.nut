/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function onPlayerConnect( player )
{
	local user = GetUser( player );
	UpdateIPInfo( user );

	Echo( iCol( 3, player.Name +" joined the server." ) );
	if ( config.rawin( "server_motd" ) ) AdminPM( config.server_motd, player );

	user.Joins++;
	user.LoggedIn = 0;

	PluginEvent( onPlayerConnect, player );
}


function onPlayerPart( player, reason )
{
	Echo( iCol( 3, player.Name +" left the server. \x028"+ GetPartReason( reason ) +"\x029" ) );
	OnlineUsers.rawdelete( player.Name );
	PluginEvent( onPlayerPart, player, reason );
}

function onPlayerDeath ( player, reason )
{
	local playern = FindLevel( player, 2 ) + player.ColouredName;
	if ( reason == WEP_DROWNED ) EMessage( iCol( 4, playern + " drowned" ), colRed );
	else EMessage( iCol( 4, playern + " died" ), colRed );
	PluginEvent( onPlayerDeath, player, reason );
}

function onPlayerKill ( killer, player, weapon, bodypart )
{
	weapon = GetWeaponName( weapon );
	bodypart = GetBodyPartName( bodypart );
	local killern = FindLevel( killer, 2 ) + killer.ColouredName;
	local playern = FindLevel( player, 2 ) + player.ColouredName;
	EMessage( iCol( 4, killer +" killed "+ playern +" ("+ weapon +" - "+ bodypart +")" ), colRed );
	PluginEvent( onPlayerKill, killer, player, weapon, bodypart );
	return 1;
}

function onPlayerAction ( player, text )
{
	Echo( iCol( 7, "* " ) + FindLevel( player, 3 ) + iCol( 7, " " + text ) );
	PluginEvent( onPlayerAction, player, text );
	return 1;
}

function onPlayerChat ( player, text )
{
	if ( text.len() > 1 && text[0] == '!' )
	{
		local a = split( text, " " );
		local command = a[ 0 ].slice( 1 );
		local param = (a.len() > 1) ? JoinArray( a.slice( 1 ), " " ) : "";
		text = param ? command + " " + param : command;
		Echo( FindLevel( player, 3 ) +iCol( 4, ": !" )+ text );
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ LUcolRed +"!"+ LUcolClose + text, colWhite );
		NewTimer( "onCommand", 200, 1, player, command, param );
		return 0;
	}
	else
	{
		Echo( FindLevel( player, 3 ) +iCol( 5, ":" )+ " " + text );
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ text, colWhite );
		PluginEvent( onPlayerChat, player, text );
		return 0;
	}
}


