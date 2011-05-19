/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

config.rawset( "irc_echo_lower", config.irc_echo.tolower() );

// Array of IRCUser objects for storing info in this script.
IRCUsers <- {};
class IRCUser
{
	constructor ( name, address )
	{
		Name = name;
		lName = name.tolower();
		Address = address;
	}

	function Level ( channel = null )
	{
		if ( !channel ) channel = ::FindIRCChannel( config.irc_echo );
		if ( !channel || !channel.Users.rawin( Name ) ) return false;
		return channel.Users.rawget( Name );
	}

	function IsOn ( channeln )
	{
		local chan = ::FindIRCChannel( channeln );
		if ( !chan ) return false;
		if ( Level( chan ) ) return true;
		return false;
	}

	function _typeof()
		return "IRCUser";

	Name = "";
	lName = "";
	Address = "";
}

// This function is called from Windscript_Loader/IRC.nut to update local information about IRC users.
// This is the best method I know of since LU's implementation of Squirrel is limited and thus allows
// for only one thread to run at a time. (ie. I can't CallFunc back to a script which I CallFunc-ed)
function UpdateIRCUser ( name, address )
{
	//print( "Updating IRCUser "+ name );
	if ( IRCUsers.rawin( name ) )
	{
		local user = IRCUsers.rawget( name );
		user.Address = address;
	}
	else IRCUsers.rawset( name, IRCUser( name, address ) );
}

function UpdateIRCUserNickname ( old, new )
{
	local newuser = IRCUser( new, IRCUsers.rawget( old ).Address );
	IRCUsers.rawset( new, newuser );
	IRCUsers.rawdelete( old );
	foreach ( chan in IRCChannels )
	{
		if ( chan.Users.rawin( old ) )
		{
			chan.Users.rawset( new, chan.Users.rawget( old ) );
			chan.Users.rawdelete( old );
		}
	}
}

function RemoveIRCUser ( name, cname = null )
{
	local chan = FindIRCChannel( cname );
	if ( chan ) chan.Users.rawdelete( name );
	else
	{
		foreach ( chan in IRCChannels )
			if ( chan.Users.rawin( name ) )
				chan.Users.rawdelete( name );
	}
}

function FindIRCUser ( name )
{
	foreach ( uname, user in IRCUsers )
	{
		if ( uname.find( name ) != null ) return user;
	}
	return null;
}

function FindIRCUserbyAddress ( address )
{
	foreach ( user in IRCUsers )
		if ( user.Address == address ) return user;
	return false;
}

IRCChannels <- {};
class IRCChannel
{
	constructor ( name )
	{
		Name = name;
		lName = name.tolower();
		Users = {};
	}

	function _tostring ()
		return Name;

	Name = "";
	lName = "";
	Users = {};
}

function UpdateIRCChannel ( cname, uname, level )
{
	//print( "Updating IRCChannel "+cname );
	if ( !IRCChannels.rawin( cname ) )
		IRCChannels.rawset( cname, IRCChannel( cname ) );
	IRCChannels.rawget( cname ).Users.rawset( uname, level );
}

function FindIRCChannel ( name )
{
	if ( IRCChannels.rawin( name ) )
		return IRCChannels.rawget( name );
	foreach ( cname, chan in IRCChannels )
		if ( name == cname || name == chan.lName ) return chan;
	return null;
}


// This event is called when a user sends a personal message to the bots
function onIRCMessage ( user, text )
{
	local user = FindIRCUser( user );
	if ( text[ 0 ] == '!' )
	{
		local p = CmdParamsfromText( text.slice( 1 ) );
		if ( p.cmd > "" ) onCommand ( user, p.cmd, p.params );
	}
	else
	{
		EMessage( iCol( 4, iBold( "PM from "+ user.Name +": " ) ) + text);
		PluginEvent( onIRCMessage, user, text );
	}
}

function onIRCMessage_Desc ( user, text )
	PluginEvent( onIRCMessage_Desc, FindIRCUser( user ), text );

// This event is called when a user sends a message to a channel bot ID 0 is on.
function onIRCChat ( channel, user, text )
{
	local user = FindIRCUser( user );
	local prefix = text[ 0 ];						// This gets the ASCII code for the prefix
	if ( channel.tolower() == config.irc_echo_lower )
	{
		if ( prefix == '!' )						// Check if prefix is '!'
		{
			local p = CmdParamsfromText( text.slice( 1 ) );
			if ( p.cmd > "" ) onCommand ( user, p.cmd, p.params );
		}
		else if ( prefix == '.' && text.len() > 1 )			// Check if prefix is '.' and text exists after .
		{
			local next = text[ 1 ];
			if ( next != '_' && next != '.' && next != '/' )	// Don't process if ./ ._ ..
			{
				local text = text.slice( 1 ), leveln = FindLevel( user, 3 );
				if ( next == ' ' ) text = text.slice( 1 );	// If there's a space, slice it
				EMessage( leveln + iCol( 6, ": " ) + text, colWhite );
			}
		}
		else PluginEvent( onIRCChat, user, channel, text );
	}
	else									// Commands which can be used outside of echo channel
	{
		if ( prefix == '!' )
		{
			local p = CmdParamsfromText( text.slice( 1 ) );
			if ( p.cmd > "" ) PluginCommandChannels( p.cmd, user, p.params, channel );
		}
		else PluginEvent( onIRCChat, user, channel, text );
	}
}

function onIRCChat_Desc ( channel, user, text )
	PluginEvent( onIRCChat_Desc, FindIRCUser( user ), text );
