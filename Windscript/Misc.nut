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

// Used for inplace quicksort
function swap_arr_elem ( arr, idx1, idx2 )
{
	local val1 = arr[ idx1 ], val2 = arr[ idx2 ];
	arr[ idx1 ] = val2;
	arr[ idx2 ] = val1;
	return arr;
}

// Quicksort function for Squirrel
function sort ( arr, left = 0, right = 0 )
{
	if ( !right ) right = arr.len() - 1;
	local diff = right - left;
	if ( diff < 1 ) return arr;
	if ( diff == 1 && arr[ left ] <= arr[ right ] ) return arr;

	local pivot = floor( arr.len() / 2 ), pidx = left;
	arr = swap_arr_elem( arr, pivot, right );
	pivot = arr[ right ];
	for ( local i = left; i < right; i++ )
	{
		if ( arr[ i ] <= pivot )
		{
			arr = swap_arr_elem( arr, i, pidx );
			pidx++;
		}
	}
	arr = swap_arr_elem( arr, right, pidx );
	arr = sort( arr, left, pidx - 1 );
	arr = sort( arr, pidx + 1, right );
	return arr;
}