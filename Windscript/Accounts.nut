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
	if ( typeof ( plr ) == "IRCUser" ) return plr;				// If IRC user, return user.

	local name = plr.Name;
	if ( OnlineUsers.rawin( name ) ) return OnlineUsers.rawget( name );	// Get user instance from table with player instance
	else									// If entry in table does not exist
	{
		local user = User( plr );
		OnlineUsers.rawset( name, user );
		return OnlineUsers.rawget( name );
	}
}


function FindUserIDfromName ( name )
{
	local id = GetData( "User_Name_To_ID", name );
	if ( id != 0 ) return id;

	local uname, max = GetData( "UserData", "TotalUsersCount" );
	for ( local i = 1; i <= max; i++ )
	{
		uname = GetData( "UserData_Name", i.tostring() );
		if ( !uname ) continue;
		if ( uname.tolower().find( name ) != null ) return i;
	}
	return null;
}

class User
{
	constructor ( p_plr )
	{
		Player = p_plr;							// Set Player instance
		Error = false;
		local name, input_type = typeof( Player );
		if ( input_type == "Player" )					// If p_plr is a Player instance
		{
			name = Player.Name;
			InGame = true;						// It's a player ingame
		}
		else if ( input_type == "string" )				// If it's a string (nickname), keep InGame false
		{
			name = Player;
			InGame = false;
		}

		name = name.tolower();						// Use lowercase name to avoid two same nicknames being registered
		ID = ::GetData( "User_Name_To_ID", name );			// Get account ID for this user
		if ( ID == 0 )
		{
			if ( !InGame )
			{
				ID = ::FindUserIDfromName( name );
				if ( ID == null ) Error = true;
			}
			else Add( name, ::IncData( "UserData", "TotalUsersCount" ) );
		}
		if ( !Error ) sID = ID.tostring();
	}

	function Add ( name, nID )
	{
		ID = ::AddData( "User_Name_To_ID", name, nID );			// Add new data for this user name
		sID = ID.tostring();
		Name = Player.Name;
		Level = 1;							// Set default user level for unregistered users
	}

	function SetPassword ( password )
	{
		local hash_pass = ::SHA1( password );
		if ( !Registered )						// If not registered
		{
			Pass = hash_pass;					// Set password hash
			Level = 2;						// Set registered user level
			LoggedIn = 1;						// Set as being logged in
			return ::onUserRegister( this, ::IncData( "UserData", "RegisteredUsersCount" ) );
		}
		else if ( LoggedIn )						// If registered and logged in
		{
			Pass = hash_pass;					// Set new password hash
			return ::onUserChangePass( this );
		}
		else return false;						// Not registered and not logged in
	}

	function Login ( password )
	{
		if ( Registered && ::SHA1( password ) == Pass )			// If password hashes match and user registered
		{
			local response = LastLogin;
			LoggedIn = 1;
			LastLogin = ::time();					// Update lastlogin time
			::IncData( "UserData", "LoginsCount" );			// Increase login count
			return ::onUserLogin( this, response );
		}
		if ( Pass ) return -1;						// If registered but pass mismatch
		return 0;							// Not registered
	}

	function Inc ( prop )
	{
		if ( Error ) return null;
		switch ( prop )
		{
			default: return ::IncData( "UserData_"+ prop, sID );
		}
	}

	function Dec ( prop )
	{
		if ( Error ) return null;
		switch ( prop )
		{
			default: return ::DecData( "UserData_"+ prop, sID );
		}
	}

	function Get ( prop )
	{
		if ( Error ) return null;
		switch ( prop )
		{
			case "Registered": return Pass ? true : false;		// Return true if pass exists
			case "Level": return LoggedIn ? ::GetData( "UserData_Level", sID ) : 1;	// If logged in, return correct level, else 1
			case "IP": return ::split( IPs, " " ).pop();
			default: return ::GetData( "UserData_"+ prop, sID );
		}
	}

	function Set ( prop, value )
	{
		if ( Error ) return null;
		switch ( prop )
		{
			default: return ::AddData( "UserData_"+ prop, sID, value );
		}
	}

	function _get ( prop )							// For all non-declared properties
		return Get( prop );						// Get data

	function _set ( prop, value )						// For all non-declared properties
		return Set( prop, value );					// Set data

	function _cmp ( other )							// This allows comparing of users in the following way:
	{									//	if ( user1 > user2 )
		if ( Level > other.Level ) return 1;				// possible with user.Level as the comparing factor
		else if ( Level == other.Level ) return 0;
		else return -1;
	}

	function _typeof()
		return "Windscript User";

	Player = null;
	Error = false;
	ID = 0;
	sID = "0";
	InGame = false;
}