/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


OnlineUsers <- {};								// Store all online player instances and their
										// associated user instances into a table
function GetUser ( plr )
{										// Get user instance from table with player instance
	local name = plr.Name;
	if ( OnlineUsers.rawin( name ) ) return OnlineUsers.rawget( name );	// Get user instance from table with player instance
	else									// If entry in table does not exist
	{
		OnlineUsers.rawset( name, User( plr ) );			// Create User() entry
		return OnlineUsers.rawget( name );
	}
}


class User
{
	constructor ( p_plr )
	{
		Player = p_plr;							// Set Player/IRCUser instance
		local name, input_type = typeof( Player );
		if ( input_type == "Player" )					// If p_plr is a Player instance
		{
			name = Player.Name;
			InGame = true;						// It's a player ingame
		}
		else if ( input_type == "string" ) name = Player;		// If it's a string, keep InGame false

		ID = ::GetData( "User_Name_To_ID", name );			// Get account ID for this user
		sID = ID.tostring();
		if ( !ID ) Add( name );						// If no account entry, create entry
	}

	function Add ( name )
	{
		local next_ID = ::IncData( "UserData", "next_ID" );		// Get next avail account ID (and inc for next use)
		::IncData( "UserData", "TotalUsersCount" );			// Increase total user count
		ID = ::AddData( "User_Name_To_ID", name, next_ID );		// Add new data for this user name
		sID = ID.tostring();
		Name = name;
		Level = 0;							// Set default user level
	}

	function UpdateInfo ()
	{
		if ( InGame )
		{
			// Add current IP to user access list
			local result = ::AddToList( IPs ? IPs : "", Player.IP );
			if ( result )
				IPs = result;
			::print( IPs );

			// Add nickname to IP_Records list
			local names = ::GetData( "IP_Records", Player.IP );
			names = names ? names : "";
			result = ::AddToList( names, Player.Name );
			if ( result )
			{
				::print( ::AddData( "IP_Records", Player.IP, result ) );
				::print( ::IncData( "UserData", "VisitorIPsCount" ) );
			}

			// Do the same as above for the SubIP_Records list
			local subnet = ::GetSubnet( Player.IP )
			names = ::GetData( "SubIP_Records", subnet );
			names = names ? names : "";
			result = ::AddToList( names, Player.Name );
			::print( result );
			if ( result )
				::print( ::AddData( "SubIP_Records", subnet, result ) );

			Joins++;
			LoggedIn = 0;
		}
	}

	function SetPassword ( password )
	{
		local hash_pass = ::SHA1( password );
		if ( !Pass )							// If not registered
		{
			Pass = hash_pass;					// Set password hash
			Level = 1;						// Set registered user level
			return onUserRegister( this, ::IncData( "UserData", "RegisteredUsersCount" ) );
		}
		else if ( LoggedIn )						// If registered and logged in
		{
			Pass = hash_pass;					// Set new password hash
			return onUserChangePass( this );
		}
		else return false;						// Not registered and not logged in
	}

	function Login ( password )
	{
		if ( Pass && ::SHA1( password ) == Pass )			// If password hashes match and user registered
		{
			local response = LastLogin;
			LoggedIn = true;
			LastLogin = GetTime();					// Update lastlogin time
			::IncData( "UserData", "LoginsCount" );			// Increase login count
			return onUserLogin( user, response );
		}
		if ( Pass ) return -1;						// If registered but pass mismatch
		return 0;							// Not registered
	}

	function _get ( prop )							// For all non-declared properties
	{
		local data = ::GetData( "UserData_"+ prop, sID );		// Get data from hash
		return data ? data : 0;						// Return data
	}

	function _set ( prop, value )						// For all non-declared properties
		return ::AddData( "UserData_"+ prop, sID, value );		// Set data

	function _cmp ( other )							// This allows comparing of users in the following way:
	{									//	if ( user1 > user2 )
		if ( Level > other.Level ) return 1;				// possible with user.Level as the comparing factor
		else if ( Level == other.Level ) return 0;
		else return -1;
	}

	function _typeof()
		return "Windscript User";

	Player = null;
	ID = 0;
	sID = "0";
	InGame = false;
}