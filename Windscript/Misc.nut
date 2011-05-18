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

function CallFunc2 ( funcn, ... )						// This is to use a dummy timer to make CallFunc work properly
{										// This calls the equivalent of NewTimer( "CallFunc", 0, 1, cScript_Whatever, param1, param2 );
	local target = cScript_Type == "Main" ? cScript_Loader : cScript_Main;	// Choose script to call
	local callparams = [ this, "CallFunc", 0, 1, target, funcn ];		// Set params to send
	foreach ( arg in vargv )						// For all optional parameters given
		callparams.append( arg );					// Append to callparams
	NewTimer.acall( callparams );						// Call NewTimer with params from callparams
	return true;
}


// Distance checking functions
function CalcDistance ( v1, v2 )
	return DistanceFunc( v1.x, v1.y, v1.z, v2.x, v2.y, v2.z )

function PlayerDistance ( plr1, plr2 )
{
	if ( typeof( plr1 ) == "Player" ) plr1 = plr1.Pos;			// This allows people to provide Vector vars as args
	if ( typeof( plr2 ) == "Player" ) plr2 = plr2.Pos;
	return DistanceFunc( plr1.x, plr1.y, plr1.z, plr2.x, plr2.y, plr2.z )
}

function DistanceFunc ( x1, y1, z1, x2, y2, z2 )
{
	x1 -= x2; y1 -= y2; z1 -= z2;
	return sqrt( x1 * x1 + y1 * y1 + z1 * z1 );
}

function IsPlayerNear ( plr1, plr2, range )
	return PlayerDistance( plr1, plr2 ) <= range ? true : false;


function CmdParamsfromText ( text )
{
	local cloc = text.find(" "), cmd, params = "";
	if ( cloc == null ) cmd = text.slice( 1 );
	else cmd = text.slice( 1, cloc ).tolower(), params = text.slice( cloc + 1 );
	params = ( params == "" ) ? 0 : params;
	return { cmd = cmd, params = params };
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

// IRC Colours applying functions

function iCol ( col, string ) return ircCol + iColnumToString( col ) + string + ircCol;
function iBold( string ) return ircBold + string + ircBold;
function iColnumToString( colnum )
{
	if (typeof(colnum) == "string") return colnum;
	else return format( "%02i", colnum );
}

// IRC level, symbol etc conversion
function IRCSymltoLevel ( syml )
{
	switch ( syml )
	{
		case '~': return 6;
		case '&': return 5;
		case '@': return 4;
		case '%': return 3;
		case '+': return 2;
		default: return 1;
	}
}

function IRCModetoLevel ( mode )
{
	switch ( mode )
	{
		case 'q': return 6;
		case 'a': return 5;
		case 'o': return 4;
		case 'h': return 3;
		case 'v': return 2;
	}
}

// This function strips the IRC colours off of a string
// Good to use with the IRC echo
function StripIRCCol ( text )
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

// This function strips the LU ingame colour tags: [#XXXXXX][#d] off of any string
function StripGameCol ( text )
{
	local coltrig, output = "";
	foreach ( idx, chr in text )
	{
		switch ( chr )
		{
			case '[':
				if ( text[ idx + 1 ] == '#' )
				{
					coltrig = true;
					break;
				}
			case ']':
				if ( coltrig )
				{
					coltrig = false;
					break;
				}
			default:
				if ( !coltrig ) output += chr.tochar();
		}
	}
	return output;
}

// This function generates random integers depending on the arguments.
// If you supply one argument, it'll return a number between 1 and the provided number
// If you supply two arguments where the 2nd one is larger, it'll provide a number between the two
function RandNum ( start, end = 0 )
{
	if ( !end ) { end = start; start = 1; }
	return start + ( rand() % ( end - start + 1 ) );
}


// This function returns a duration statement from seconds
function Duration ( num )
{
	local days = floor ( num % 604800 / 86400 );
	local hours = floor ( num % 86400 / 3600 );
	local mins = floor ( num % 3600 / 60 );
	local secs = num % 60;
	local weeks = floor ( ( num - days*86400 - hours*3600 - mins*60 - secs ) / 604800 );
	local a = [];
	if ( weeks != 0 ) a.append( weeks + "wks" );
	if ( days != 0 ) a.append( days + "days" );
	if ( hours != 0 ) a.append( hours + "hrs" );
	if ( mins != 0 ) a.append( mins + "mins" );
	if ( secs != 0 ) a.append( secs + "secs" );
	return JoinArray( a, " " );
}

function TimeDiff ( saved )
{
	local dt = date( saved ), now = date(), msg;
	if ( dt.day == now.day )			// If left today
		return Duration( time() - saved ) +" ago";
	if ( dt.month == now.month )			// If left on current month
		msg = "on the "+ GetNth( dt.day );
	else						// If left on another month
		msg = "on "+ GetNth( dt.day ) +" "+ GetMonth( dt.month );
	msg += format( " at %02i:%02i", dt.hour, dt.min );
	return msg;
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
	return format( "%s.%s.*.*", nums[ 0 ], nums[ 1 ] );
}


// This function adds str to strlist if str isn't in strlist
function AddToList ( strlist, str )
{
	if ( !strlist ) return;
	str = str.tostring();
	local items = split( strlist.tostring(), " " );
	foreach ( idx, val in items )
		if ( val == str )
			return strlist;

	items.push( str );							// Push string into list
	return JoinArray( items, " " );						// Return array as string
}

function RemFromList ( strlist, str )
{
	if ( !strlist ) return;
	str = str.tostring();
	local items = split( strlist.tostring(), " " );
	foreach ( idx, val in items )
	{
		if ( val == str )
		{
			items.remove( idx );
			return JoinArray( items, " " );
		}
	}
	return strlist;
}

function IsinList ( strlist, str )
{
	if ( !strlist ) return;
	str = str.tostring();
	strlist = split( strlist.tostring(), " " );
	foreach ( idx, val in strlist )
	{
		if ( val == str )
			return true;
	}
	return false;
}

// This function returns 1st/2nd/3rd/4th from an integer
function GetNth ( num )
{
	local lastdigs = num % 100;
	switch ( lastdigs )
	{
		case 11: return num +"th";					// Catch out 11, 111
		case 12: return num +"th";					// Catch out 12, 112
		case 13: return num +"th";					// Catch out 13, 113
		default:							// Everything else should be normal...
			lastdigs = num % 10;					// Get last digit
			switch ( lastdigs )
			{
				case 1: return num +"st";
				case 2: return num +"nd";
				case 3: return num +"rd";
				default: return num +"th";
			}
	}
}

// This function returns the name of a month
function GetMonth ( num )
{
	switch ( num )
	{
		case 1: return "Jan";
		case 2: return "Feb";
		case 3: return "Mar";
		case 4: return "Apr";
		case 5: return "May";
		case 6: return "Jun";
		case 7: return "Jul";
		case 8: return "Aug";
		case 9: return "Sep";
		case 10: return "Oct";
		case 11: return "Nov";
		case 12: return "Dec";
	}
}
