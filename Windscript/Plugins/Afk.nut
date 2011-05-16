/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


function cmdAway ( player, reason, channel )
	return Afk( player, channel ).Add( reason ? reason : "No Reason" );	// Add player to away data with default reason: "No Reason"

function cmdBack ( player, params, channel )
{
	local awaydata = Afk( player, channel );				// Get away data instance
	if ( awaydata.IsAway ) return awaydata.Del( params );			// If entry exists for this user delete entry
	else return mError( "You are not away", player );
}

function cmdAfk ( player, params, channel )
{
	local found = FindAfk( params, channel );
	if ( found ) return SendMessage( found, player, colGreen );
	if ( !params ) return Afk( player, channel ).Afk();
	else return SendMessage( iBold( iCol( 3, params +" is not away" ) ), player, colGreen );
}

function textAfk ( user, channel, text )
{
	local found = FindAfk( text, channel );
	if ( found ) return SendMessage( found, user, colGreen );
}

function igtextAfk ( player, text )
	return textAfk( player, config.irc_echo_lower, text );

function FindAfk ( params, channel )
{
	if ( !params ) return null;
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
	if ( !target ) return null;
	if ( target[ target.len() - 1 ] == '?' ) target = target.slice( 0, -1 );
	local plr = FindPlayer( target ), list;
	if ( plr && plr.Name.tolower() == target )
	{
		user = GetUser( plr );
		if ( IsinList( GetData( "AFK_InGame", "List" ), user.ID ) )
			return AfkString( "AFK_InGame", user.Name, user.ID );
		else return null;
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
			if ( !list ) return null;
			foreach ( id in split( list, " " ) )
			{
				user = GetUserFromID( id );
				if ( !user ) continue;
				return AfkString( "AFK_InGame", user.Name, id );
			}
		}
	}
	return null;
}

function AfkString ( hash, name, id )
{
	local atime, reason, msg, dur, dt;
	reason = GetData( hash, id + ".Reason" );
	atime = GetData( hash, id + ".Time" );
	dur = time() - atime;
	if ( dur > 86400 )					// If more than a day ago
	{
		dt = date( atime );
		if ( dt.month == date().month )			// If left on current month
			msg = " left on the "+ GetNth( dt.day );
		else						// If left on another month
			msg = " left on "+ GetNth( dt.day ) +" "+ GetMonth( dt.month );
		msg += format( " at %02i:%02i", dt.hour, dt.min );
	}
	else
	{
		if ( name == "You" ) msg = " have ";
		else msg = " has ";
		msg += "been away for "+ Duration( dur );
	}
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
			Hash = "AFK_InGame";
			Other = "AFK_IRC";
			ID = ::GetUser( Player ).ID;				// Set ingame user account ID as identification
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
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is away ("+ Reason +")" ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You are away ("+ Reason +")" ), Player, ::colGreen );
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
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" returned from \""+ Reason + dur ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You returned from \""+ Reason + dur ), Player, ::colGreen );
		::SendMessage( ::iCol( 3, "You have so far logged a total AFK time of: "+ ::Duration( tot ) ), Player, ::colGreen );
		return true;
	}

	function Update ( reason )
	{
		if ( !IsAway ) return Add( reason );				// If away entry doesn't exist

		if ( Reason == reason )						// If reason hasn't changed,
		{								// do nothing apart from reminding
			local dur = ( GetTime() - Time );
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ), ::colGreen );
			else ::SendMessage( ::iCol( 3, "You are still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ), Player, ::colGreen );
			return true;
		}
		else								// If reason has changed
		{
			::IncData( "AFK", ID + ".TotalTime", GetTime() - Time );
			Time = ::GetTime();					// Update time
			Reason = reason;					// Update reason
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is now away ("+ Reason +")" ), ::colGreen );
			else ::SendMessage( ::iCol( 3, "You are now away ("+ Reason +")" ), Player, ::colGreen );
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
		return ::SendMessage( iCol( 3, "No one is currently away." ), Player, ::colGreen );
	}

	function ShowAfks ( hash, id )
	{
		if ( hash == "AFK_InGame" )
		{
			local user = GetUserFromID( id );
			if ( !user ) return;
			local name = id == ID ? "You" : user.Name;
			::SendMessage( ::AfkString( hash, name, id ), Player, ::colGreen );
		}
		else
		{
			local user = ::FindIRCUserbyAddress( id );
			if ( user )
			{
				local name = id == ID ? "You" : user.Name;
				if ( !user.IsOn( Channel ) ) return;
				return ::SendMessage( ::AfkString( hash, name, id ), Player, ::colGreen );
			}
		}
	}

	function Msg ( msg, col )
	{
		if ( Other ) return ::EMessage( msg, col );			// If on echo channel or ingame send message to both
		else								// Otherwise, send message to channel only
		{
			::CallFunc2( "BotMessage", Channel, "msg", msg );
			return true;
		}
	}

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