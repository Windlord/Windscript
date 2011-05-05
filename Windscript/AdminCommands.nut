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
	if ( !params ) return mFormat ( "/ip <player>", player );
	if ( CheckLevel( player, "ip" ) )
	{
		local p = targetparams( player, params );
		local tuser = GetUser( p.target );
		if ( p )
		{
			local ipf = IPInfo( tuser.IP );
			AdminPM( "Information for "+ ipf.IP, player );
			AdminPM( "rDNS: "+ ipf.rDNS, player );
			AdminPM( "Country: "+ ipf.Country, player );
			AdminPM( "City: "+ ipf.City, player );
		}
	}
}

function cmdKick ( player, params )
{
	if ( !params ) return mFormat ( "/kick <player> <reason>", player );
	if ( CheckLevel( player, "kick" ) )
	{
		local p = targetparams( player, params );
		local user = GetUser( player ), kuser = GetUser( p.target );
		if ( p )
		{
			if ( p.params == "" ) return mFormat ( "/kick <player> <reason>", player );
			user.Kicks++;
			kuser.Kicked++;
			KickPlayer( p.target );
			onPlayerPart( p.target, PARTREASON_KICKED, p.params );
		}
	}
}