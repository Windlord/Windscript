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
	OnlineUsers.rawset( player, User( player ) );
	GetUser( player ).UpdateInfo();
	Echo( iCol( 3, player.Name +" joined the server." ) );
	if ( config.rawin( "server_motd" ) ) AdminPM( config.server_motd, player );
}

function onPlayerPart( player, reason )
{
	Echo( iCol( 3, player.Name +" left the server. \x028"+ GetPartReason( reason ) +"\x029" ) );
	OnlineUsers.rawdelete( player );
}

function onPlayerDeath ( player, reason )
{
	local playern = FindLevel( player, 3 );
	if ( reason == WEP_DROWNED ) EMessage( playern + iCol( 4, " drowned" ), colRed );
	else EMessage( playern + iCol( 4, " died" ), colRed );
}

function onPlayerKill ( killer, player, weapon, bodypart )
{
	weapon = GetWeaponName( weapon );
	bodypart = GetBodyPartName( bodypart );
	local killern = FindLevel( killer, 3 );
	local playern = FindLevel( player, 3 );
	EMessage( killern + iCol( 4, " killed " ) + playern + iCol( 4, " ("+ weapon +" - "+ bodypart +")" ), colRed );
	return 1;
}

function onPlayerAction ( player, text )
{
	Echo( iCol( 7, "* " ) + FindLevel( player, 3 ) + iCol( 7, " " + text ) );
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
		onCommand( player, command, param );
		//NewTimer( "onCommand", 200, 1, player, command, param );
		return 0;
	}
	else
	{
		Echo( FindLevel( player, 3 ) +iCol( 5, ":" )+ " " + text );
		Message( FindLevel( player, 2 ) + player.ColouredName + ": " + text, colWhite );
		return 0;
	}
}


