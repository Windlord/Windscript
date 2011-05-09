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

function cmdBack ( player, dummyparams, channel )
{
	local awaydata = Afk( player, channel );				// Get away data instance
	if ( awaydata.IsAway ) return awaydata.Del();				// If entry exists for this user delete entry
	else return mError( "You are not away", player );
}

function cmdAfk ( player, params, channel )
	return Afk( player, channel ).Afk();


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
	else msg = " has been away for "+ Duration( dur );
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
			Hash = "AFK_"+ Channel;
			ID = player.Address;					// Set IRC user address as identification string
			if ( Channel == config.irc_echo_lower )
			{
				Other = "AFK_InGame";
				IsEcho = true;
			}
		}
		else								// If player is ingame player
		{
			IsEcho = true;
			Hash = "AFK_InGame";
			Other = "AFK_"+ config.irc_echo_lower;
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

	function Del ()
	{
		local dur = GetTime() - Time, tot = ::IncData( "AFK", ID + ".TotalTime", dur );
		local newlist = ::RemFromList( List, ID );
		if ( newlist == "" ) ::DelData( Hash, "List" );
		else ::AddData( Hash, "List", newlist );
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), Player, ::colGreen );
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
		local id, list = ::GetData( Hash, "List" ), total = 0, result;
		list = list ? list : "";
		foreach ( id in split( list, " " ) )				// For all away data entries in hash
		{
			result = ShowAfks( Hash, id );
			if ( result ) total++;
		}
		if ( IsEcho )
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
		if ( Hash == "AFK_Ingame" )
		{
			if ( !GetUserFromID( id ) ) return;
			::SendMessage( ::AfkString( hash, ::GetData( "UserData_Name", id ), i ), Player, ::colGreen );
		}
		else
		{
			local user = ::FindIRCUserbyAddress( id );
			if ( user )
			{
				if ( !user.IsOn( Channel ) ) return;
				return ::SendMessage( ::AfkString( hash, user.Name, id ), Player, ::colGreen );
			}
		}
	}

	function Msg ( msg, col )
	{
		if ( IsEcho ) return ::EMessage( msg, col );			// If on echo channel or ingame send message to both
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

	IsEcho = false;
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
}