/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

// Array of IRCUser2 objects for storing info in this script.
IRCUsers2 <- [];
class IRCUser2
{
	constructor ( id, name, address, level )
	{
		Name	= name;
		ID		= id;
		Address	= address;
		Level	= level;
	}
	Name	= "";
	ID		= 0;
	Address	= "";
	Level	= 0;
}

// This function is called from Windscript_Loader/IRC.nut to update local information about IRC users.
// This is the best method I know of since LU's implementation of Squirrel is limited and thus allows
// for only one thread to run at a time. (ie. I can't CallFunc back to a script which I CallFunc-ed)
function UpdateUsers ( ID, Name, Address, Level )
{
	local aID = ID - 1001;
	if ( IRCUsers2.len() <= aID ) IRCUsers2.resize( aID+1 );
	if ( !IRCUsers2[ aID ] )
		IRCUsers2[ aID ] = IRCUser2( ID, Name, Address, Level );
	else
	{
		IRCUsers2[ aID ].Address = Address;
		IRCUsers2[ aID ].Level = Level;
	}
	local user = IRCUsers2[ aID ];
}

function FindIRCUser ( name )
{
	foreach ( a, user in IRCUsers2 )
	{
		if ( user && user.Name == name ) return user;
	}
	return false;
}

// This event is called when a user sends a personal message to the bots
function onIRCMessage ( user, text )
{
	local user = FindIRCUser( user );
	EMessage( iCol( 4, iBold( "PM from "+ user.Name +": " ) ) + text);
}

function onIRCMessage_Desc ( user, text )
{
	local user = FindIRCUser( user );

}

// This event is called when a user sends a message to a channel bot ID 0 is on.
function onIRCChat ( channel, user, text )
{
	local user = FindIRCUser( user );
	if ( channel.tolower() == config.irc_echo.tolower() )
	{
		local prefix = text[ 0 ];					// This gets the ASCII code for the prefix
		if ( prefix == 33 )						// Check if prefix is '!'
		{
			local a = split( text, " " ), cmd = a[ 0 ].slice( 1 ).tolower();
			local params = JoinArray( a.slice( 1 ), " " );
			if ( cmd ) onCommand ( user, cmd, params );
		}
		else if ( prefix == 46 && text.len() > 1 )			// Check if prefix is '.' and text exists after .
		{
			local next = text[ 1 ];
			if ( next != 95 && next != 46 && next != 47 )		// Don't process if ./ ._ ..
			{
				local text = text.slice( 1 ), leveln = FindLevel( user, 3 );
				if ( next == 32 ) text = text.slice( 1 );		// If there's a space, slice it
				EMessage( leveln + iCol( 6, ": " ) + text, colWhite );
			}
		}
	}
	else									// Afk commands can be used outside of the echo channel
	{
		local a = split( text, " " ), cmd = a[ 0 ].tolower();
		if		( cmd == "!away") cmdAway( user, JoinArray( a.slice( 1 ), " " ), channel );
		else if	( cmd == "!back") cmdBack( user, channel );
		else if	( cmd == "!afk" ) cmdAfk( user, JoinArray( a.slice( 1 ), " " ), channel );

	}
}

function onIRCChat_Desc ( channel, user, text )
{

}