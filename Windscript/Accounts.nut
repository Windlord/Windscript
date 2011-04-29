/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


OnlineUsers <- {};

function GetUser ( plr )
	return OnlineUsers.rawget( plr );


class User
{
	constructor ( p_plr )
	{
		Player = p_plr;
		local name, input_type = typeof( Player );
		if ( input_type == "Player" )
		{
			name = Player.Name;
			InGame = true;
		}
		else if ( input_type == "string" ) name = Player;

		ID = ::GetData( "User_Name_To_ID", name );
		if ( !ID ) Add( name );
	}

	function Add ( name )
	{
		local next_ID = ::IncData( "UserData", "next_ID" );
		::IncData( "UserData", "TotalUsersCount" );
		ID = ::AddData( "User_Name_To_ID", name, next_ID );
		Name = name;
		Level = 1;
	}

	function UpdateInfo ()
	{
		if ( InGame )
		{
			// Add current IP to user access list
			local ips = IPs;
			if ( ips.find( Player.IP ) != null )
				IPs = ::JoinArray( split( ips, " " ).push( Player.IP ), " " );

			// Add nickname to IP_Records list
			ips = ::GetData( "IP_Records", Player.IP );
			if ( ips.find( Player.Name ) != null )
			{
				::AddData( "IP_Records", Player.IP, ::JoinArray( split( ips, " " ).push( Player.Name ), " " ));
				::IncData( "UserData", "VisitorIPsCount" );
			}

			// Do the same as above for the SubIP_Records list
			ips = ::GetData( "SubIP_Records", Player.IP );
			if ( ips.find( Player.Name ) != null )
				::AddData( "SubIP_Records", Player.IP, ::JoinArray( split( ips, " " ).push( Player.Name ), " " ));

			Joins++;
			LoggedIn = 0;
		}
	}

	function SetPassword ( password )
	{
		local hash_pass = ::SHA1( password );
		if ( !Pass )
		{
			Pass = hash_pass;
			return onUserRegister( this, ::IncData( "UserData", "RegisteredUsersCount" ) );
		}
		else if ( LoggedIn )
		{
			Pass = hash_pass;
			return true;
		}
		else return false;
	}

	function Login ( password )
	{
		if ( Password && ::SHA1( password ) == Password )
		{
			local response = LastLogin;
			LoggedIn = true;
			LastLogin = GetTime();
			::IncData( "UserData", "LoginsCount" );
			return onUserLogin( user, response );
		}
		if ( Password ) return -1;
		return 0;
	}

	function _get ( prop )
	{
		local data = ::GetData( "UserData_"+ prop, ID );
		return data ? data : 0;
	}

	function _set ( prop, value )
		return ::AddData( "UserData_"+ prop, ID, value );

	function _cmp ( other )
	{
		if ( Level > other.Level ) return 1;
		else if ( Level == other.Level ) return 0;
		else return -1;
	}

	function _typeof()
		return "Windscript User";

	Player = null;
	ID = 0;
	InGame = false;
}