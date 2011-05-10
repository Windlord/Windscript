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
	strlist = split( strlist, " " );
	foreach ( idx, val in strlist )
		if ( val == str )
			return strlist;

	strlist.push( str );							// Push string into list
	return JoinArray( strlist, " " );					// Return array as string
}

function RemFromList ( strlist, str )
{
	strlist = split( strlist, " " );
	foreach ( idx, val in strlist )
	{
		if ( val == str )
		{
			strlist.remove( idx );
			return JoinArray( strlist, " " );
		}
	}
	return strlist;
}

function IsinList ( strlist, str )
{
	strlist = split( strlist, " " );
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
