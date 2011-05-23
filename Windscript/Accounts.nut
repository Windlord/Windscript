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
	local name, lname;
	if ( typeof ( plr ) == "IRCUser" ) return plr;				// If IRC user, return user.
	if ( type ( plr ) == "string" ) name = plr;
	else name = plr.Name;
	lname = name.tolower();
	if ( OnlineUsers.rawin( lname ) ) return OnlineUsers.rawget( lname );	// Get user instance from table with player instance
	else									// If entry in table does not exist
	{
		OnlineUsers.rawset( lname, User( plr ) );
		return OnlineUsers.rawget( lname );
	}
}

function FindUser ( search )
{
	search = search.tolower();
	local id = GetData( "User_Name_To_ID", search );
	if ( id ) return User( GetData( "UserData_Name",  id.tostring() ) );

	local uname, max = GetData( "UserData", "TotalUsersCount" );
	for ( local i = 1; i <= max; i++ )
	{
		uname = GetData( "UserData_Name", i.tostring() );
		if ( !uname ) continue;
		if ( uname.tolower().find( search ) != null )
			return User( GetData( uname ) );
	}
	return null;
}

// This is to get an ingame user from their account id
function GetUserFromID ( aID )
{
	foreach ( user in OnlineUsers )
		if ( user.ID == aID ) return user;
	return null;
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
		local name, lname, input_type = typeof( Player );
		if ( input_type == "Player" )					// If p_plr is a Player instance
		{
			name = Player.Name;
			InGame = true;						// It's a player ingame
		}
		else if ( input_type == "string" )				// If it's a string (nickname), keep InGame false
		{
			name = Player;
			InGame = false;
			Player = ::FindPlayer( name );
			if ( Player )
			{
				name = Player.Name;
				InGame = true;
			}
		}

		lname = name.tolower();						// Use lowercase name to avoid two same nicknames being registered
		ID = ::GetData( "User_Name_To_ID", lname );			// Get account ID for this user
		if ( ID == 0 )
			Add( name, lname, ::IncData( "UserData", "TotalUsers" ) );
	}

	function Add ( name, lname, nID )
	{
		ID = ::AddData( "User_Name_To_ID", lname, nID );		// Add new data for this user name
		sID = ID.tostring();
		Name = name;
		lName = lname;
		Level = 1;							// Set default user level for unregistered users
	}

	function SetPassword ( password )
	{
		local hash_pass = ::SHA1( password );
		if ( !Registered )						// If not registered
		{
			LoggedIn = 1;						// Set as being logged in
			Pass = hash_pass;					// Set password hash
			Level = 2;						// Set registered user level
			return ::onUserRegister( this, ::IncData( "UserData", "TotalRegisteredUsers" ) );
		}
		else if ( LoggedIn )						// If registered and logged in
		{
			Pass = hash_pass;					// Set new password hash
			return ::onUserChangePass( this );
		}
		else return false;						// Not registered and not logged in
	}

	function Login ( password, autologin = false )
	{
		if ( autologin || ( Registered && ::SHA1( password ) == Pass ) )// If password hashes match and user registered
		{
			LoggedIn = 1;
			::IncData( "UserData", "TotalLogins" );			// Increase login count
			return ::onUserLogin( this, autologin );
		}
		if ( Pass ) return -1;						// If registered but pass mismatch
		return 0;							// Not registered
	}

	function RestoreSettings ()
	{
		Player.Cash = Cash;
	}

	function Inc ( prop, amount = 1 )
	{
		local result = Get( prop ) + amount;
		return Set( result );
	}

	function Dec ( prop, amount = 1 )
	{
		local result = Get( prop ) - amount;
		result = result < 0 ? 0 : result;
		return Set( result );
	}

	function Get ( prop )
	{
		switch ( prop )
		{
			case "Cash":
				Player.Cash = Money;
				return Money;
			case "Registered": return Pass ? true : false;		// Return true if pass exists
			case "Level": return LoggedIn ? ::GetData( "UserData_Level", sID ) : 1;	// If logged in, return correct level, else 1
			case "IP": return ::split( IPs, " " ).pop();
			default: return ::GetData( "UserData_"+ prop, sID );
		}
	}

	function Set ( prop, value )
	{
		switch ( prop )
		{
			case "Name":
			case "lName":
			case "Level":
			case "LoggedIn":
				return ::AddData( "UserData_"+ prop, sID, value );
			case "Cash":
				Player.Cash = value;
				Money = value;
				return value;
			case "IP":
				IPs = ::AddToList( IPs, value );
				return value;
			default:
				if ( LoggedIn || value == 0 ) ::AddData( "UserData_"+ prop, sID, value );
				else return value;
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

	function _tostring ()
		return Name;

	function _typeof()
		return "Windscript User";

	Player = null;
	ID = 0;
	sID = "0";
	InGame = false;
}