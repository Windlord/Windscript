/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


function cmdAway ( player, reason, channel )
	return Afk( player, channel ).Add( reason ? reason : "No Reason" );

function cmdBack ( player, dummyparams, channel )
{
	local awaydata = Afk( player, channel );
	if ( awaydata.Num ) return awaydata.Del();
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

		if ( Player.ID > 1000 )
		{
			Hash = "AFK_"+ Channel;
			ID = player.Address;
		}
		else
		{
			Ingame = true;
			Hash = "AFK_InGame";
			ID = ::GetUser( Player ).ID;
		}
		Num = ::GetData( Hash, ID );
		Time = ::GetData( Hash, Num + ".Time" );
		Reason = ::GetData( Hash, Num + ".Reason" );
		LastTime = ::GetData( "AFK", ID + ".LastTime" );
		LastTime = LastTime ? LastTime : 0;
	}

	function Save ()
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
		if ( Time ) return Update( reason );

		Num = ::IncData( Hash, "Total" );
		Time = ::GetTime();
		Reason = reason;
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is away ("+ Reason +")" ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You are away ("+ Reason +")" ), Player, ::colGreen );
		return Save();
	}

	function Del ()
	{
		local dur = GetTime() - Time, tot = ::IncData( "AFK", ID + ".TotalTime", dur );
		::DecData( Hash, "Total" )
		::DelData( Hash, ID );
		if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), ::colGreen );
		else ::SendMessage( ::iCol( 3, "You returned from \""+ Reason +"\" after "+ ::Duration( dur ) ), Player, ::colGreen );
		::SendMessage( ::iCol( 3, "You have so far logged a total AFK time of: "+ ::Duration( tot ) ), Player, ::colGreen );
		return true;
	}

	function Update ( reason )
	{
		if ( !Time ) return Add( reason );

		if ( Reason == reason )
		{
			local dur = ( GetTime() - Time );
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ), ::colGreen );
			else ::SendMessage( ::iCol( 3, "You are still away for \""+ Reason +"\" ("+ ::Duration( dur ) +")" ), Player, ::colGreen );
			return true;
		}
		else
		{
			::IncData( "AFK", ID + ".TotalTime", GetTime() - Time );
			Time = ::GetTime();
			Reason = reason;
			if ( !SpamCheck() ) Msg( ::iCol( 3, ::iBold( Player.Name ) +" is now away ("+ Reason +")" ), ::colGreen );
			else ::SendMessage( ::iCol( 3, "You are now away ("+ Reason +")" ), Player, ::colGreen );
			return Save();
		}
	}

	function List ()
	{
		local name, time, reason, max = ::GetData( Hash, "Total" ).tointeger(), now = ::GetTime();
		if ( !max ) return ::SendMessage( iCol( 3, "No one is currently away." ), Player, ::colGreen );
		for ( local i = 1; i <= max; i++ )
		{
			name = ::GetData( Hash, i + ".Name" );
			reason = ::GetData( Hash, i + ".Reason" );
			time = ::GetData( Hash, i + ".Time" );
			if ( now - time > 86400 )
			{
				local dt = date( time );
				if ( dt.month == date().month ) time = " left on the "+ ::GetNth( dt.day );
				else time = " left on "+ ::GetNth( dt.day ) +" "+ ::GetMonth( dt.month );
				time += format( " at %02i:%02i", dt.hour, dt.min );
			}
			else time = " has been away for "+ ::Duration( now - time );
			return ::SendMessage( iCol( 3, iBold( name ) + time + " ("+ reason +")" ), Player, ::colGreen );
		}
	}

	function Msg ( msg, col )
	{
		if ( Ingame || Channel == config.irc_echo_lower ) return ::EMessage( msg, col );
		else
		{
			::CallFunc2( "BotMessage", Channel, "msg", msg );
			return true;
		}
	}

	function SpamCheck ()
	{
		local now = ::GetTime(), dt = now - LastTime;
		if ( dt < 15 ) return true;
		else
		{
			::AddData( "AFK", ID + ".LastTime", now );
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

{
	Plugins.Afk.RegisterCommandAllChannels( "away", cmdAway );
	Plugins.Afk.RegisterCommandAllChannels( "back", cmdBack );
	Plugins.Afk.RegisterCommandAllChannels( "afk", cmdAfk );
}