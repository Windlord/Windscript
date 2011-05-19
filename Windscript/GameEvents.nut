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
	if ( CheckNickname( player ) )
	{
		local user = GetUser( player );
		EMessage( iCol( 3, player.ColouredName +" joined the server." ), colGreen );
		if ( config.rawin( "server_motd" ) ) AdminPM( config.server_motd, player );

		onUserJoin( user );
		PluginEvent( onPlayerConnect, player );
	}
	else
	{
		AdminPM( "Invalid Nickname ("+ player.Name.toupper() +")", player );
		KickPlayer( player );
	}
	return 0;
}

KickReasons <- {};
function onPlayerPart( player, reason, adminreason = "None" )
{
	if ( player.Name in OnlineUsers )
	{
		local reason = GetPartReason( reason );
		switch( reason )
		{
			case "Kicked":
				EMessage( iCol( 3, player.ColouredName +" was kicked from the server. ("+ adminreason +")" ), colGreen );
				break;
			case "Banned":
				EMessage( iCol( 3, player.ColouredName +" was banned from the server. ("+ adminreason +")" ), colGreen );
				break;
			default:
				EMessage( iCol( 3, player.ColouredName +" left the server. ("+ reason +")" ), colGreen );
				break;
		}
		onUserPart( GetUser( player ), reason );
		PluginEvent( onPlayerPart, player, reason );
		OnlineUsers.rawdelete( player.Name );
	}
	return 0;
}

function onPlayerDeath ( player, reason )
{
	local user = GetUser( player ), reason = GetWeaponName( reason );
	local playern = FindLevel( player, 2 ) + player.ColouredName;
	onUserDeath( user, reason );
	if ( reason == "Drowned" ) EMessage( iCol( 4, playern + " drowned" ), colRed );
	else EMessage( iCol( 4, playern + " died" ), colRed );
	PluginEvent( onPlayerDeath, player, reason );
}

function onPlayerKill ( killer, player, weapon, bodypart )
{
	weapon = GetWeaponName( weapon );
	bodypart = GetBodyPartName( bodypart );
	local killern = FindLevel( killer, 2 ) + killer.ColouredName;
	local playern = FindLevel( player, 2 ) + player.ColouredName;
	local kuser = GetUser( killer ), user = GetUser( player );
	onUserKill( kuser, user, weapon, bodypart );
	EMessage( iCol( 4, killern +" killed "+ playern +" ("+ weapon +" - "+ bodypart +")" ), colRed );
	PluginEvent( onPlayerKill, killer, player, weapon, bodypart );
	return 1;
}

function onPlayerAction ( player, text )
{
	Echo( iCol( 7, "* " ) + FindLevel( player, 3 ) + iCol( 7, " " + text ) );
	Message( "* "+ FindLevel( player, 2 ) + player.ColouredName +" "+ text, colYellow );
	PluginEvent( onPlayerAction, player, text );
	return 0;
}

function onPlayerChat ( player, text )
{
	if ( text.len() > 1 && text[ 0 ] == '!' )
	{
		local p = CmdParamsfromText( text.slice( 1 ) );
		text = p.params ? p.cmd +" "+ p.params : p.cmd;
		Echo( FindLevel( player, 3 ) +iCol( 4, ": !" )+ text );
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ LUcolRed +"!"+ LUcolClose + text, colWhite );
		NewTimer( "onCommand", 200, 1, player, p.cmd, p.params );
	}
	else
	{
		Echo( FindLevel( player, 3 ) +iCol( 5, ":" )+ " " + text );
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ text, colWhite );
		PluginEvent( onPlayerChat, player, text );
	}
	return 0;
}


