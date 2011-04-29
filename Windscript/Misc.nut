/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

/*	This script file is especially important when using Windscript.
	This is because the functions included in this file are used in
	nearly every other script file as if they are internal functions. */

function CallFunc2 ( func, ... )				// This is to use a dummy timer to make CallFunc work properly
{
	local exec = "NewTimer( \"CallFunc\", 0, 1, cScript_Loader, \"" + func + "\"";

	foreach ( param in vargv )					// For each optional param...
	{
		if ( typeof param == "string" )			// If string
		{
			local output = "";					// Initiate empty output string
			foreach ( chr in param )			// For each character in param
			{
				if (chr == 34) output += "\\\"";// Output \" if "
				else output += chr.tochar();	// Output the char otherwise
			}
			param = "\""+ output +"\"";			// Put \" around the string
		}
		exec += ", " + param;					// Add param to execstring
	}
	exec += " );"								// Close function

	local runthis = compilestring( exec );		// Compile exec
	runthis();									// run!
}

// Messaging functions
function Echo ( message )						// Sends a message to the echo channel
	SendToEcho( config.irc_echo, "msg", message );

function EMessage ( message, ... )				// Sends a message both to the server and the echo channel
{												// Format: EMessage ( message, Colour() );
	SendToEcho( config.irc_echo, "msg", message );
	Message( StripCol( message ), vargv.len() > 0 ? vargv[ 0 ] : colWhite );
}

function SendMessage ( message, target, ... )	// Sends a pm ingame if player is ingame. Sends a notice if IRC user.
{												// Format: SendMessage( message, player/user, Colour() );
	if ( target.ID > 1000 ) SendToEcho( target.Name, "notice", message );
	else MessagePlayer( StripCol( message ), target, vargv.len() > 0 ? vargv[ 0 ] : colWhite );
}

function AdminMessage ( message )
	EMessage( iCol( 2, ":: "+ message ), colBlue );

function AdminPM ( message, target )
	SendMessage( iCol( 2, ":: "+ message ), target, colBlue );

function SendToEcho ( channel, type, message )
	CallFunc2( "BotMessage", channel, type, message );


// Error message functions
function mError ( message, player )
	SendMessage ( iBold( iCol( 4, "Error" ) + iCol( 3, " :: " ) ) + iCol( 4, message ), player, colRed );

function mFormat ( message, player )
	SendMessage ( iBold( iCol( 3, "Format" ) + iCol( 4, " :: " ) ) + iCol( 3, message ), player, colGreen );

function mErrorG ( message )
	EMessage ( iBold( iCol( 4, "Error" ) + iCol( 3, " :: " ) ) + iCol( 4, message ), colRed );


// Distance checking functions
function CalcDistance ( vector1, vector2 )
	return DistanceFunc( vector1.x, vector1.y, vector1.z, vector2.x, vector2.y, vector2.z )

function CalcDistance ( x1, y1, z1, x2, y2, z2 )
	return DistanceFunc( x1, y1, z1, x2, y2, z2 );

function PlayerDistance ( player1, player2 )
	return DistanceFunc( player1.Pos.x, player1.Pos.y, player1.Pos.z, player2.Pos.x, player2.Pos.y, player2.Pos.z )

function PlayerDistance ( player, xcoord, ycoord, zcoord )
	return DistanceFunc( player.Pos.x, player.Pos.y, player.Pos.z, xcoord, ycoord, zcoord )

function DistanceFunc ( x1, y1, z1, x2, y2, z2 )
{
	x1 -= x2; y1 -= y2; z1 -= z2;
	return sqrt( x1 * x1 + y1 * y1 + z1 * z1 );
}

function IsPlayerNear ( player, range, xcoord, ycoord, zcoord )
	return PlayerDistance( player, xcoord, ycoord, zcoord ) <= range ? true : false;

function IsPlayerNear ( player1, player2, range )
	return PlayerDistance( player1, player2 ) <= range ? true : false;

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

// NEED TO ADD IN PLAYERLEVEL RETRIEVING!!!! //
// If the optional second argument is 0, it will return the level number as an int
// If it is 1, it will return the name of the level of the player
// If it is 2, it will return the IRC level prefix (ie. + % @ & ~ )
// If it is 3, it will return the IRC colours with the level prefix and name
function FindLevel ( player, ... )
{
	local type = vargv.len() > 0 ? vargv[ 0 ] : 0, ilevel;
	if ( player.ID > 1000 ) ilevel = player.Level;
	else {
		ilevel = 4;
	}
	switch ( type )
	{
		case 1:
			return IRC_LEVELNAME[ ilevel - 1 ];
			break;
		case 2:
			return IRC_LEVELSYML[ ilevel - 1 ];
			break;
		case 3:
			return iCol( IRC_LEVELCOLO[ ilevel - 1 ], IRC_LEVELSYML[ ilevel - 1 ] + player.Name );
			break;
		default:
			return ilevel;
			break;
	}
	return 1;
}

// NEED TO EDIT AND ADD IN COMMANDLEVEL RETRIEVING!!! //
// Note: This function also checks whether a player is registered
//       if a command's level is set to 2
function CheckLevel ( player, command, ... )
{
	if ( vargv.len() > 0 && player.ID > 1000 )
	{
		mError( "InGame Command ("+ command.toupper() +")", player );
		return false;
	}
	else if ( FindLevel( player ) >= 4 ) return true;
	else
	{
		mError( "Invalid Command ("+ command.toupper() +")", player );
		return false;
	}
}


// This function joins all elements in a 'target' array
// where the elements are delimited with a 'delimit' string
function JoinArray ( array, delimit )
{
	local a, z = array.len(), output = "";
	if ( z > 0 )
	{
		if ( z > 1 )
		{
			for ( a = 1; a < z; a++ )
				output += delimit + array[ a ];
			return array[ 0 ] + output;
		}
		else return array[ 0 ];
	}
	else return output;
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

// IRC Colours applying functions

function iCol ( col, string ) return ircCol + iColnumToString( col ) + string + ircCol;
function iBold( string ) return ircBold + string + ircBold;
function iColnumToString( colnum )
{
	if (typeof(colnum) == "string") return colnum;
	else return format( "%02i", colnum );
}

// This function strips the IRC colours off of a string
// Good to use with the IRC echo
function StripCol ( text )
{
	local a, z = text.len(), l;
	local coltrig = false, comtrig = false, num = 0, output = "";
	for ( a = 0; a < z; a++ )
	{
		l = text[ a ];
		if ( l == 3 ) { coltrig = !coltrig; num = 0; comtrig = false; }
		else if ( coltrig && num < 2 && l < 58 && 47 < l ) { num++; }
		else if ( coltrig && !comtrig && l == 44 ) { comtrig = true; num = 0; }
		else { num = 2; comtrig = false; output += l.tochar(); }
	}
	return output;
}


// This function generates random integers depending on the arguments.
// If you supply one argument, it'll return a number between 1 and the provided number
// If you supply two arguments where the 2nd one is larger, it'll provide a number between the two
function RandNum ( start, ... )
{
	local end;
	if ( vargv.len() > 0 ) end = vargv[ 0 ];
	else { end = start; start = 1; }
	return start + ( rand() % ( end - start + 1 ) );
}


// This function returns a duration statement from ticks (ms)
function Duration ( ticks )
{
	ticks		= floor ( ticks / 1000 );
	local days	= floor ( ticks % 604800 / 86400 );
	local hours	= floor ( ticks % 86400 / 3600 );
	local mins	= floor ( ticks % 3600 / 60 );
	local secs	= ticks % 60;
	local weeks	= floor ( ( ticks - days*86400 - hours*3600 - mins*60 - secs ) / 604800 );
	local a = [];
	if ( weeks	!= 0 ) a.append( weeks + "wks" );
	if ( days	!= 0 ) a.append( days + "days" );
	if ( hours	!= 0 ) a.append( hours + "hrs" );
	if ( mins	!= 0 ) a.append( mins + "mins" );
	if ( secs	!= 0 ) a.append( secs + "secs" );
	return JoinArray( a, " " );
}

// This function adds commas every 3 digits for outputs like 12,345,678
function ToThousands ( num )
{
	num = num.tostring();
	local decimalpos = num.find(".");
	local last = decimalpos ? decimalpos - 1 : num.len();
	local chk = last % 3;
	local decimaltrig = false;
	local output = "";

	foreach ( idx, digit in num )
	{
		output += digit.tochar();
		if ( digit == 44 ) decimaltrig = true;
		if ( !decimaltrig && idx < last && idx % 3 == chk ) output += ",";
	}
	return output;
}

// This function returns the subnet from an ip string
function GetSubnet ( ip )
{
	local nums = split( ip, "." );
	nums[2] = "*";
	nums[3] = "*";
	return JoinArray( nums, "." );
}

// This function returns 1st/2nd/3rd/4th from an integer
function GetNth ( num )
{
	local lastdig = num % 10, suffix;
	switch ( lastdig )
	{
		case 1:
			suffix = "st";
			break;
		case 2:
			suffix = "nd";
			break;
		case 3:
			suffix = "rd";
			break;
		default:
			suffix = "th";
			break;
	}
	return num.tostring() + suffix;
}