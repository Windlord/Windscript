/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 version 1.0
	                                 by Windlord	*/

IPInfoQueue <- {};

function GetIPInfo ( ip )
{
	IPInfoQueue.rawset( ip, QueryIPInfo( ip ) );
}

function FindQueryIPInfo ( socket )
{
	foreach ( idx, val in IPInfoQueue )
		if ( val.Socket.ID == socket.ID ) return val;
}

function RemQueryIPInfo ( ip )
{
	local inst = IPInfoQueue.rawget( ip );
	if ( inst.Socket ) inst.Socket.Delete();
	IPInfoQueue.rawdelete( inst.IP );
}

class IPInfo
{
	constructor ( ip )
	{
		IP = ip;
	}

	function Get ( prop )
	{
		local result = ::GetData( "IPInfo_"+ prop, IP );
		if ( !result ) ::GetIPInfo( IP );
		return result ? result : "None";
	}

	function _get ( prop )
	{
		switch ( prop )
		{
			case "rDNS":
			case "Country":
			case "City":
				return Get( prop );
		}
	}

	IP = null;
}

class QueryIPInfo
{
	constructor ( ip )
	{
		IP = ip;
		Socket = ::NewSocket( "onRawIPInfo" );
		Socket.SetNewConnFunc( onIRCInfoConnected );
		Socket.Connect( "www.infobyip.com", 80 );
	}

	function Send ( msg ) Socket.Send( msg + "\r\n" );

	IP = null;
	Socket = null;
}

function onIRCInfoConnected ( socket )
{
	local ipinf = FindQueryIPInfo( socket );
	ipinf.Send( "GET /ip-"+ ipinf.IP +".html HTTP/1.1" );
	ipinf.Send( "Connection: keep-alive" );
	ipinf.Send( "Host: www.infobyip.com" );
	ipinf.Send( "" );
}

function onRawIPInfo ( socket, raw )
{
	local ip = FindQueryIPInfo( socket ).IP;
	raw = split( raw, "</>\r\n" );
	foreach ( idx, bit in raw )
	{
		if ( bit == "IP: "+ ip )
		{
			AddData( "IPInfo_rDNS", ip, raw[ idx + 5 ].slice( 8 ) );
			continue;
		}
		else if ( bit == "Country" )
		{
			AddData( "IPInfo_Country", ip, raw[ idx + 3 ] );
			continue;
		}
		else if ( bit == "City" )
		{
			AddData( "IPInfo_City", ip, raw[ idx + 3 ] );
			NewTimer( "RemQueryIPInfo", 0, 1, ip );
			break;
		}
	}
}
