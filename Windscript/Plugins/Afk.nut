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
	if ( awaydata.Num ) return awaydata.Del();				// If entry exists for this user delete entry
	else return mError( "You are not away", player );
}

function cmdAfk ( player, params, channel )
	return Afk( player, channel ).List();

class Afk
{
	constructor ( player, channel )
	{
		Player = player;
		Channel = channel;

		if ( Player.ID > 1000 )						// If player is an IRC user
		{
			Hash = "AFK_"+ Channel;
			ID = player.Address;					// Set IRC user address as identification string
		}
		else								// If player is ingame player
		{
			Ingame = true;
			Hash = "AFK_InGame";
			ID = ::GetUser( Player ).ID;				// Set ingame user account ID as identification
		}
		Num = ::GetData( Hash, ID );					// Get away data number
		if ( Num )
		{
			Time = ::GetData( Hash, Num + ".Time" );
			Reason = ::GetData( Hash, Num + ".Reason" );
			LastTime = ::GetData( "AFK", ID + ".LastTime" );
		}
		LastTime = LastTime ? LastTime : 0;
	}

	function Save ()							// Update info in hash
	{
		::AddData( "AFK", ID, ::GetTime() );
		::AddData( Hash, ID, Num );
		::AddData( Hash, Num + ".Name", Player.Name );
		::AddData( Hash, Num + ".Time", Time );
		::AddData( Hash, Num + ".Reason", Reason );
		return true;
	}

	function Add ( reason )
	{
		if ( Num ) return Update( reason );				// If away entry exists

		Num = ::IncData( Hash, "Total" );				// Inc total number of away entries
		Time = ::GetTime();						// Set current time as away time
		Reason = reason;						// Set reason
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is away ("+ Reason +")" ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You are away ("+ Reason +")" ), Player, ::colGreen );
		return Save();							// Update data in hash
	}

	function Del ()
	{
		local dur = GetTime() - Time, tot = ::IncData( "AFK", ID + ".TotalTime", dur );
		::DecData( Hash, "Total" )					// Reduce total number of away entries
		::DelData( Hash, ID );						// Remove away data number associated with ID
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), Player, ::colGreen );
		::SendMessage( ::iCol( 3, "You have so far logged a total AFK time of: "+ ::Duration( tot ) ), Player, ::colGreen );
		return true;
	}

	function Update ( reason )
	{
		if ( !Num ) return Add( reason );				// If away entry doesn't exist

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

	function List ()
	{
		local name, time, reason, max = ::GetData( Hash, "Total" ).tointeger(), now = ::GetTime();
		if ( !max ) return ::SendMessage( iCol( 3, "No one is currently away." ), Player, ::colGreen );
		for ( local i = 1; i <= max; i++ )				// For all away data entries in hash
		{
			name = ::GetData( Hash, i + ".Name" );
			reason = ::GetData( Hash, i + ".Reason" );
			time = ::GetData( Hash, i + ".Time" );
			if ( now - time > 86400 )				// If more than a day ago
			{
				local dt = date( time );
				if ( dt.month == date().month )			// If left on current month
					time = " left on the "+ ::GetNth( dt.day );
				else						// If left on another month
					time = " left on "+ ::GetNth( dt.day ) +" "+ ::GetMonth( dt.month );
				time += format( " at %02i:%02i", dt.hour, dt.min );
			}
			else time = " has been away for "+ ::Duration( now - time );
			return ::SendMessage( iCol( 3, iBold( name ) + time + " ("+ reason +")" ), Player, ::colGreen );
		}
	}

	function Msg ( msg, col )
	{
		if ( Ingame || Channel == config.irc_echo_lower )		// If on echo channel or ingame send message to both
			return ::EMessage( msg, col );
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

	Ingame = false;
	Hash = null;
	Player = null;
	ID = null;
	Num = null;
	Channel = null;
	Name = null;
	Time = null;
	Reason = null;
	LastTime = null;
}

{	// Register commands for all IRC channels.
	Plugins.Afk.RegisterCommandAllChannels( "away", cmdAway );
	Plugins.Afk.RegisterCommandAllChannels( "back", cmdBack );
	Plugins.Afk.RegisterCommandAllChannels( "afk", cmdAfk );
}