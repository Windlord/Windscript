/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


function cmdAway ( player, reason, channel )
{
	if ( GetData( "AFK", channel ) ) return;
	return Afk( player, channel ).Add( reason ? reason : "No Reason" );	// Add player to away data with default reason: "No Reason"
}

function cmdBack ( player, params, channel )
{
	if ( GetData( "AFK", channel ) ) return;
	local awaydata = Afk( player, channel );				// Get away data instance
	if ( awaydata.IsAway ) return awaydata.Del( params );			// If entry exists for this user delete entry
	else return mError( "You are not away", player );
}

function cmdAfk ( player, params, channel )
{
	local chan = FindIRCChannel( channel );
	if ( params && typeof( player ) == "IRCUser" && channel != config.irc_echo_lower && player.Level( chan ) > 3 )
	{
		switch ( params.tolower() )
		{
			case "enable":
			case "on":
				if ( GetData( "AFK", channel ) )
				{
					Afk( player, channel ).Msg( iCol( 3, "AFK Commands enabled for this channel" ) );
					return DelData( "AFK", channel );
				}
				else return;
			case "disable":
			case "off":
				if ( !GetData( "AFK", channel ) )
				{
					Afk( player, channel ).Msg( iCol( 3, "AFK Commands disabled for this channel" ) );
					return AddData( "AFK", channel, "Disabled" );
				}
				else return;
		}
	}
	if ( GetData( "AFK", channel ) ) return;
	local found = FindAfk( params, channel );
	if ( found ) return SendMessage( found, player, colGreen );
	if ( !params ) return Afk( player, channel ).Afk();
	else return SendMessage( iBold( iCol( 3, params +" is not away" ) ), player, colGreen );
}

function textAfk ( user, channel, text )
{
	if ( GetData( "AFK", channel ) ) return;
	local found = FindAfk( text, channel );
	if ( found ) return SendMessage( found, user, colGreen );
}

function igtextAfk ( player, text )
	return textAfk( player, config.irc_echo_lower, text );

function FindAfk ( params, channel )
{
	if ( !params ) return;
	local words = split( params.tolower(), " " ), target, user;
	switch( words.len() )
	{
		case 1:
			target = words[ 0 ];
			break;
		case 2:
			if ( words[ 0 ] == "where's" ) target = words[ 1 ];
			break;
		case 3:
			if ( words[ 0 ] + words[ 1 ] == "whereis" ) target = words[ 2 ];
			break;
	}
	if ( !target ) return;
	if ( target[ target.len() - 1 ] == '?' ) target = target.slice( 0, -1 );
	local plr = FindPlayer( target ), list;
	if ( plr && plr.Name.tolower() == target )
	{
		user = GetUser( plr );
		if ( IsinList( GetData( "AFK_InGame", "List" ), user.ID ) )
			return AfkString( "AFK_InGame", user.Name, user.ID );
		else return;
	}
	else
	{
		list = GetData( "AFK_IRC", "List" );
		if ( list )
		{
			foreach ( id in split( list, " " ) )
			{
				user = FindIRCUserbyAddress( id );
				if ( user && user.lName == target )
				{
					if ( !user.IsOn( channel ) ) return;
					return AfkString( "AFK_IRC", user.Name, id );
				}
			}
		}
		if ( channel == config.irc_echo_lower )
		{
			list = GetData( "AFK_InGame", "List" );
			if ( !list ) return;
			foreach ( id in split( list, " " ) )
			{
				user = GetUserFromID( split( id, ":" )[ 0 ].tointeger() );
				if ( !user ) continue;
				return AfkString( "AFK_InGame", user.Name, id );
			}
		}
	}
	return;
}

function AfkString ( hash, name, id )
{
	local atime, reason, msg;
	reason = GetData( hash, id + ".Reason" );
	atime = GetData( hash, id + ".Time" );
	msg = ( name == "You" ? " have" : " has" ) +" left "+ TimeDiff( atime );
	return iCol( 3, iBold( name ) + msg + " ("+ reason +")" );
}


class Afk
{
	constructor ( player, channel )
	{
		Player = player;
		Channel = channel;

		if ( typeof( Player ) == "IRCUser" )				// If player is an IRC user
		{
			Hash = "AFK_IRC";
			ID = player.Address;					// Set IRC user address as identification string
			if ( Channel == config.irc_echo_lower )
				Other = "AFK_InGame";
		}
		else								// If player is ingame player
		{
			local user = ::GetUser( Player );
			Hash = "AFK_InGame";
			Other = "AFK_IRC";
			ID = user.ID +":"+ user.Name;				// Set ingame user account ID as identification
		}

		Time = ::GetData( Hash, ID + ".Time" );
		Reason = ::GetData( Hash, ID + ".Reason" );
		LastTime = ::GetData( "AFK", ID + ".LastTime" );
		LastTime = LastTime ? LastTime : 0;
		List = ::GetData( Hash, "List" );
		List = List ? List : "";
		IsAway = ::IsinList( List, ID );
	}

	function Save ()							// Update info in hash
	{
		::AddData( Hash, "List", ::AddToList( List, ID ) );
		::AddData( Hash, ID + ".Time", Time );
		::AddData( Hash, ID + ".Reason", Reason );
		return true;
	}

	function Add ( reason )
	{
		if ( IsAway ) return Update( reason );				// If away entry exists

		Time = ::GetTime();						// Set current time as away time
		Reason = reason;						// Set reason
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is away ("+ Reason +")" ) );
		else PM( ::iCol( 3, "You are away ("+ Reason +")" ), Player );
		return Save();							// Update data in hash
	}

	function Del ( reason )
	{
		local dur = GetTime() - Time, tot = ::IncData( "AFK", ID + ".TotalTime", dur );
		local newlist = ::RemFromList( List, ID );
		reason = reason ? " because of "+ reason : "";
		dur = "\" after "+ ::Duration( dur ) + reason;
		if ( newlist == "" ) ::DelData( Hash, "List" );
		else ::AddData( Hash, "List", newlist );
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" returned from \""+ Reason + dur ) );
		else PM( ::iCol( 3, "You returned from \""+ Reason + dur ), Player );
		PM( ::iCol( 3, "You have so far logged a total AFK time of: "+ ::Duration( tot ) ), Player );
		return true;
	}

	function Update ( reason )
	{
		if ( !IsAway ) return Add( reason );				// If away entry doesn't exist

		if ( Reason == reason )						// If reason hasn't changed,
		{								// do nothing apart from reminding
			local dur = ( GetTime() - Time );
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ) );
			else PM( ::iCol( 3, "You are still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ), Player );
			return true;
		}
		else								// If reason has changed
		{
			::IncData( "AFK", ID + ".TotalTime", GetTime() - Time );
			Time = ::GetTime();					// Update time
			Reason = reason;					// Update reason
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is now away ("+ Reason +")" ) );
			else PM( ::iCol( 3, "You are now away ("+ Reason +")" ), Player );
			return Save();						// Update data in hash
		}
	}

	function Afk ()
	{
		local id, total = 0, result, list;
		foreach ( id in split( List, " " ) )				// For all away data entries in hash
		{
			result = ShowAfks( Hash, id );
			if ( result ) total++;
		}
		if ( Other )
		{
			list = ::GetData( Other, "List" );
			list = list ? list : "";
			if ( list )
			{
				foreach ( id in split( list, " " ) )
				{
					result = ShowAfks( Other, id );
					if ( result ) total++;
				}
			}
		}
		if ( total ) return true;
		return PM( iCol( 3, "No one is currently away." ), Player );
	}

	function ShowAfks ( hash, id )
	{
		if ( hash == "AFK_InGame" )
		{
			local user = GetUserFromID( split( id, ":" )[ 0 ].tointeger() );
			if ( !user ) return;
			local name = id == ID ? "You" : user.Name;
			return PM( ::AfkString( hash, name, id ), Player );
		}
		else
		{
			local user = ::FindIRCUserbyAddress( id );
			if ( user )
			{
				local name = id == ID ? "You" : user.Name;
				if ( !user.IsOn( Channel ) ) return;
				return PM( ::AfkString( hash, name, id ), Player );
			}
		}
	}

	function Msg ( msg )
	{
		if ( Other ) return ::EMessage( msg, colGreen );		// If on echo channel or ingame send message to both
		else								// Otherwise, send message to channel only
		{
			::CallFunc2( "BotMessage", Channel, "msg", msg );
			return true;
		}
	}

	function PM ( msg, plr )
		return ::SendMessage( msg, plr, colGreen );

	function SpamCheck ()
	{
		local now = ::GetTime(), dt = now - LastTime;
		if ( dt < 15 ) return true;					// If less than 15s since last public msg, return true
		else
		{
			::AddData( "AFK", ID + ".LastTime", now );		// Update last public msg time
			return false;
		}
	}

	Other = false;
	Hash = null;
	Player = null;
	ID = null;
	Channel = null;
	Time = null;
	Reason = null;
	LastTime = null;
	List = null;
	IsAway = null;
}

{	// Register commands for all IRC channels.
	Plugins.Afk.RegisterCommandAllChannels( "away", cmdAway );
	Plugins.Afk.RegisterCommandAllChannels( "back", cmdBack );
	Plugins.Afk.RegisterCommandAllChannels( "afk", cmdAfk );
	Plugins.Afk.RegisterEvent( onPlayerChat, igtextAfk );
	Plugins.Afk.RegisterEvent( onIRCChat, textAfk );
}