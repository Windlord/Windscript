/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


function CallFunc2 ( func, ... )				// This is to use a dummy timer to make CallFunc work properly
{
	local exec = "NewTimer( \"CallFunc\", 0, 1, cScript_Loader, \"" + func + "\"", output;

	foreach ( param in vargv )				// For each optional param...
	{
		if ( typeof param == "string" )			// If string
		{
			output = "";				// Initiate empty output string
			foreach ( chr in param )		// For each character in param
			{
				if (chr == 34) output += "\\\"";// Output \" if "
				else output += chr.tochar();	// Output the char otherwise
			}
			param = "\""+ output +"\"";		// Put \" around the string
		}
		exec += ", " + param;				// Add param to execstring
	}
	exec += " );"						// Close function

	local runthis = compilestring( exec );			// Compile exec
	local result = runthis();				// run!
	return true;
}


// Messaging functions
function Echo ( message )					// Sends a message to the echo channel
	return SendToEcho( config.irc_echo, "msg", message );

function EMessage ( message, col = colWhite )			// Sends a message both to the server and the echo channel
{								// Format: EMessage ( message, Colour() );
	Message( StripIRCCol( message ), col );
	return SendToEcho( config.irc_echo, "msg", StripGameCol( message ) );
}

function SendMessage ( message, target, col = colWhite )	// Sends a pm ingame if player is ingame. Sends a notice if IRC user.
{								// Format: SendMessage( message, player/user, Colour() );
	if ( target.ID > 1000 ) return SendToEcho( target.Name, "notice", StripGameCol( message ) );
	else return MessagePlayer( StripIRCCol( message ), target, col );
}

function AdminMessage ( message )
	return EMessage( iCol( 2, ":: "+ message ), colBlue );

function AdminPM ( message, target )
	return SendMessage( iCol( 2, ":: "+ message ), target, colBlue );

function SendToEcho ( channel, type, message )
	return CallFunc2( "BotMessage", channel, type, message );


// Error message functions
function mError ( message, player )
	return SendMessage ( iBold( iCol( 4, "Error" ) + iCol( 3, " :: " ) ) + iCol( 4, message ), player, colRed );

function mFormat ( message, player )
	return SendMessage ( iBold( iCol( 3, "Format" ) + iCol( 4, " :: " ) ) + iCol( 3, message ), player, colGreen );

function mErrorG ( message )
	return EMessage ( iBold( iCol( 4, "Error" ) + iCol( 3, " :: " ) ) + iCol( 4, message ), colRed );


// Arrays to store IRC level names and symbols for quicker referencing
// - Level 1: Unregistered
// - Level 2: [Registered] Player
// - Level 3: [Server] Moderator
// - Level 4: [Server] Admin[istrator]
// - Level 5: [Server] Manager
// - Level 6: [Server] Owner
IRC_LEVELNAME <- ["Unregistered", "Player", "Moderator", "Admin", "Manager", "Owner"];
IRC_LEVELSYML <- ["", "+", "%", "@", "&", "~"];
IRC_LEVELCOLO <- ["05", "06", "07", "02", "03", "04" ];

// If the optional second argument is 0, it will return the level number as an int
// If it is 1, it will return the name of the level of the player
// If it is 2, it will return the IRC level prefix (ie. + % @ & ~ )
// If it is 3, it will return the IRC colours with the level prefix and name
function FindLevel ( player, type = 1 )
{
	local ilevel;
	if ( player.ID > 1000 ) ilevel = player.Level;
	else ilevel = GetUser( player ).Level;
	switch ( type )
	{
		case 1:
			return IRC_LEVELNAME[ ilevel - 1 ];
		case 2:
			return IRC_LEVELSYML[ ilevel - 1 ];
		case 3:
			return iCol( IRC_LEVELCOLO[ ilevel - 1 ], IRC_LEVELSYML[ ilevel - 1 ] + player.Name );
		default:
			return ilevel;
	}
	return 1;
}


// This is a custom FindPlayer which also searches through IRC users.
// This function also recognises id inputs and processes them.
function FindPlayer2 ( text )
{
	if ( IsNum( text ) || typeof( text ) == "integer" )
	{
		id = text.tointeger();
		if ( id < cMax_Players )
			return Players.rawget( id.tostring() );
		else if ( id > 1000 )
			return IRCUser2( CallFunc( cScript_Loader, GetIRCUserName, id ) );
	}
	else
	{
		local plr = FindPlayer( text );
		return plr ? plr : FindIRCUser( text );
	}
}

function GetPartReason ( reasonid )
{
	switch ( reasonid )
	{
		case PARTREASON_TIMEOUT:
			return "Lost Connection";
		case PARTREASON_DISCONNECTED:
			return "Quit";
		case PARTREASON_KICKED:
			return "Kicked";
		case PARTREASON_BANNED:
			return "Banned";
	}
}
