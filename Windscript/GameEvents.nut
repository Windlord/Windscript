/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

/* ALL EVENTS ARE IN ALPHABETICAL ORDER */
/* http://liberty-unleashed.co.uk/LUWiki/Squirrel/Server/Events for all events */

function onPickupPickedUp ( player, pickup )
{
	PluginEvent( onPickupPickedUp, player, pickup );
	return 1;
}

function onPickupRespawn ( pickup )
{
	PluginEvent( onPickupRespawn, pickup );
	return 1;
}

function onPlayerAction ( player, text )
{
	Echo( iCol( 7, "* " ) + FindLevel( player, 3 ) + iCol( 7, " " + StripGameCol( text ) ) );
	Message( "* "+ FindLevel( player, 2 ) + player.ColouredName +" "+ text, colYellow );
	PluginEvent( onPlayerAction, player, text );
	return 0;
}

function onPlayerArmourChange ( player, oldarm, newarm )
{
	if ( player.Spawned )
	{
		local user = GetUser( player );
		if ( newarm > oldarm )
			AdminKick( AdminServ, user, "Armour Cheats Detected" );
	}
	PluginEvent( onPlayerArmourChange, player, oldarm, newarm );
	return 1;
}

function onPlayerCashChange ( player, oldcash, newcash )
{
	if ( player.Spawned )
	{
		local user = GetUser( player );
		if ( newcash > oldcash )
			AdminKick( AdminServ, user, "Cash Cheats Detected" );
	}
	PluginEvent( onPlayerCashChange, player, oldcash, newcash );
	return 1;
}

function onPlayerChat ( player, text )
{
	if ( text.len() > 1 && text[ 0 ] == '!' )
	{
		local p = CmdParamsfromText( text.slice( 1 ) );
		text = p.params ? p.cmd +" "+ p.params : p.cmd;
		Echo( FindLevel( player, 3 ) +iCol( 4, ": !" )+ StripGameCol( text ) );
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ LUcolRed +"!"+ LUcolClose + text, colWhite );
		NewTimer( "onCommand", 200, 1, player, p.cmd, StripGameCol( p.params ) );
	}
	else
	{
		Message( FindLevel( player, 2 ) + player.ColouredName +": "+ text, colWhite );
		text = StripGameCol( text );
		Echo( FindLevel( player, 3 ) +iCol( 5, ":" )+ " " + text );
		PluginEvent( onPlayerChat, player, text );
	}
	return 0;
}

function onPlayerConnect( player )
{
	if ( CheckNickname( player ) )
	{
		local user = GetUser( player );
		EMessage( iCol( 3, player.ColouredName +" joined the server." ), colGreen );
		AdminPM( config.server_motd, player );

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

function onPlayerDeath ( player, reason )
{
	local user = GetUser( player ), reason = GetWeaponName( reason );
	local playern = FindLevel( player, 2 ) + player.ColouredName;
	onUserDeath( user, reason );
	if ( reason == "Drowned" ) EMessage( iCol( 4, playern + " drowned" ), colRed );
	else EMessage( iCol( 4, playern + " died" ), colRed );
	PluginEvent( onPlayerDeath, player, reason );
}

function onPlayerEnterCheckpoint ( player, cp )
{
	PluginEvent( onPlayerEnterCheckpoint, player, cp );
	return 1;
}

function onPlayerEnterSphere ( player, sphere )
{
	PluginEvent( onPlayerEnterSphere, player, sphere );
	return 1;
}

function onPlayerEnteredVehicle ( player, vehicle, seat )
{
	PluginEvent( onPlayerEnteredVehicle, player, vehicle, seat );
	return 1;
}

function onPlayerEnteringVehicle ( player, vehicle, door )
{
	PluginEvent( onPlayerEnteringVehicle, player, vehicle, door );
	return 1;
}

function onPlayerExitCheckpoint ( player, cp )
{
	PluginEvent( onPlayerExitCheckpoint, player, cp );
	return 1;
}

function onPlayerExitSphere ( player, sphere )
{
	PluginEvent( onPlayerExitSphere, player, sphere );
	return 1;
}

function onPlayerExitedVehicle ( player, vehicle )
{
	PluginEvent( onPlayerExitedVehicle, player, vehicle );
	return 1;
}

function onPlayerExitingVehicle ( player, vehicle )
{
	PluginEvent( onPlayerExitingVehicle, player, vehicle );
	return 1;
}

function onPlayerFailedVehicleEntry ( player, vehicle, seat )
{
	PluginEvent( onPlayerFailedVehicleEntry, player, vehicle, seat );
	return 1;
}

function onPlayerFall ( player, oldhp, newhp )
{
	PluginEvent( onPlayerFall, player, oldhp, newhp );
	return 1;
}

function onPlayerHealthChange ( player, oldhp, newhp )
{
	if ( player.Spawned )
	{
		local user = GetUser( player );
		if ( newhp > oldhp )
			AdminKick( AdminServ, user, "Health Cheats Detected" );
	}
	PluginEvent( onPlayerHealthChange, player, oldhp, newhp );
	return 1;
}

function onPlayerIslandChange ( player, old, new )
{
	PluginEvent( onPlayerIslandChange, player, old, new );
	return 1;
}

function onPlayerJoin ( player )
{
	PluginEvent( onPlayerJoin, player );
	return 1;
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

KickReasons <- {};
function onPlayerPart( player, reason, adminreason = "None" )
{
	local user = GetUser( player );
	if ( user )
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
		onUserPart( user, reason );
		PluginEvent( onPlayerPart, player, reason );
		OnlineUsers.rawdelete( player.Name );
	}
	return 0;
}

function onPlayerScoreChange ( player, old, new )
{
	PluginEvent( onPlayerScoreChange, player, old, new );
	return 1;
}

function onPlayerSkinChange ( player, old, new )
{
	PluginEvent( onPlayerSkinChange, player, old, new );
	return 1;
}

function onPlayerSpawn ( player, spawnclass )
{
	PluginEvent( onPlayerSpawn, player, spawnclass );
	return 1;
}

function onPlayerTeamChange ( player, old, new )
{
	PluginEvent( onPlayerTeamChange, player, old, new );
	return 1;
}

function onPlayerUpdate ( player )
{
	PluginEvent( onPlayerUpdate, player );
	return 1;
}

function onPlayerUseDetonator ( player )
{
	PluginEvent( onPlayerUseDetonator, player );
	return 1;
}

function onPlayerVirtualWorldChange ( player, old, new )
{
	PluginEvent( onPlayerVirtualWorldChange, player, old, new );
	return 1;
}

function onPlayerWeaponChange ( player, oldwep, newwep )
{
	PluginEvent( onPlayerWeaponChange, player, oldwep, newwep );
	return 1;
}

function onSSVBridgeUpdate ( closing )
{
	PluginEvent( onSSVBridgeUpdate, closing );
	return 1;
}

function onTimeChange ( hour, min )
{
	PluginEvent( onTimeChange, hour, min );
	return 1;
}

function onVehicleHealthChange ( vehicle, oldhp, newhp )
{
	PluginEvent( onVehicleHealthChange, vehicle, oldhp, newhp );
	return 1;
}

function onVehicleRespawn ( vehicle )
{
	PluginEvent( onVehicleRespawn, vehicle );
	return 1;
}

function onVehicleUpdate ( vehicle, player )
{
	PluginEvent( onVehicleUpdate, vehicle, player );
	return 1;
}

function onVehicleWrecked ( vehicle )
{
	PluginEvent( onVehicleWrecked, vehicle );
	return 1;
}

function onWeatherChange ( old, new )
{
	PluginEvent( onWeatherChange, old, new );
	return 1;
}
