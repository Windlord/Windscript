/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

config.irc_echo = config.irc_echo.tolower();
CTCP_VERSION_REPLY	<- "\x0001VERSION "+ iBold( iCol( 2, "Windscript Version "+ cScript_Version ) ) +"\x0001";
CTCP_FINGER_REPLY	<- "\x0001FINGER "+ iBold( iCol( 4, "Watch it!" ) ) +"\x0001";

// This function is called onScriptLoad to start up all bots needed
function InitialiseBots ()
{
	local botslist = split( config.irc_botnames, ", " );					// Get an array of bot names from config
	foreach ( idx, bot in botslist )										// For each of the bots in config,
	{
		if ( bot && bot != "" )
			NewTimer( "CreateBot", 2000 * ( idx + 1 ), 1, bot );			// Initiate staggered execs of CreateBot functions for each bot
	}
}

// This function is called onScriptUnload to disconnect all bots
function UnloadBots ()
{
	foreach ( bot in IRCBots )
	{
		if ( bot ) RemoveBot ( bot, true );
	}
}

// The following array stores the instances of EchoBot
IRCBots <- {};

// This function loops through the array, "IRCBots" for empty slots and creates a new EchoBot instance. (ie. creates an IRC bot)
function CreateBot ( name )
{
	local lname = name.tolower();
	if ( IRCBots.rawin( lname ) ) return false;
	else return IRCBots.rawset( lname, EchoBot( name ) );
}

function RemoveBot ( bot, ... )
{
	local unloading = vargv.len() > 0 ? true : false;
	local name = bot.lName;										// Cache bot's name and id for the print below

	bot.CheckLogin.Delete();
	bot.Quit( "Windscript Version "+ cScript_Version );			// In case the bot is still connected, send QUIT message
	if ( bot.Socket ) bot.Socket.Delete;						// Delete socket instance
	bot.Debug( "REMOVE", "Removing bot from slot "+ bot.ID );
	IRCBots.rawdelete( name );									// Remove bot data from IRCBots

	if ( !unloading )
		foreach ( a in IRCChannels ) UpdateAvailBots( a );		// Update pool of available bots per channel
}

function RecoverBot ( bot )
{
	bot.Debug( "RECOVER", "Recovering dead bot" );
	deadbot = bot.Name, deadbotid = bot.ID;
	RemoveBot( bot );
	NewTimer( "CreateBot", 2000 * ( deadbotid + 1 ), 1, deadbot );
}

// This is the Echo Script's equivalent to "FindPlayer"
// It loops through the table, "IRCBots" and identifies which bot instance the socket is being used by
function FindBot ( socket )
{
	foreach ( bot in IRCBots )
		if ( bot.Socket.ID == socket.ID ) return bot;			// If socket ids match return bot instance
	return false;												// If bot not found, return false
}

// Find a bot from a partial name (partname) and send raw string (raw)
// Example: FindBotDo( "moo", "PRIVMSG Windlord: You're Awesome" );
//          would find a bot which has "moo" in its name and make it pm
//          Windlord with "You're Awesome"
function FindBotDo ( partname, raw )
{
	partname = partname.tolower();
	foreach ( lname, bot in IRCBots )
		if ( lname.find( partname ) != null )
			bot.Send( raw );
}

// This is a class for the IRC Echobot
class EchoBot
{
	// Everything inside the constructor() {} bit is executed when an EchoBot instance is created.
	// An EchoBot instance is created by doing something like;
	//			SomeVariable <- EchoBot( botname );
	constructor ( name )
	{
		Name		= name;
		ID			= ::IRCBots.len();
		lName		= name.tolower();
		Channels	= {};									// List of channels which the bot is on
		Init		= ::GetTickCount();						// Record when bot was created
		Debug( "CREATED", "Bot created in slot "+ ID );
		Socket		= ::NewSocket( "onIRCData" );				// This creates a new socket connection
		Socket.SetLostConnFunc( onIRCDisconnected );		// This sets a function for the socket to call when disconnected
		Socket.SetNewConnFunc( onIRCConnected );			// This sets a function for the connected socket to call
		Socket.Connect( ::config.irc_server,
						::config.irc_port );					// This connects the socket to the IRC server
		CheckLogin	= ::NewTimer( "CheckBotLogin", 7000, 1, lName );
		LastPing	= Init;
		NickServ	= false;
		Used		= 1;

		if ( ID == 0 ) ::MainBot <- this;
	}

	Name		= null;									// This stores the name of the bot
	lName		= null;
	ID			= null;
	Socket		= null;									// This stores the instance pointer for the socket created for the bot
	Channels	= null;									// This stores the channel names which the bot is on
	NickServ	= null;									// This is a check to see if the bot has been through NickServ
	Init		= null;									// This stores the tick count when the bot was created (Can be used in bot uptime checking)
	CheckLogin	= null;
	Used		= null;
	LastPing	= null;

	function IsOn( channel )
	{
		foreach ( chan in Channels )
			if ( chan == channel ) return true;
		return false;
	}
	function Login		() { Send( "PRIVMSG NickServ identify "+ config.irc_password ); }
	function Join		( channel, ... ) {
		local key = vargv.len() > 0 ? vargv[ 0 ] : "";
		local lchannel = channel.tolower();
		if ( !IRCChannels.rawin( lchannel ) ) IRCChannels.rawset( lchannel, IRCChannel( channel, key ) );
		Send( "JOIN "+ channel +" "+ key );
	}
	function Send		( message ) { Socket.Send( message +"\r\n" ); }
	function Part		( channel, ... ) { Send( "PART "+ channel + JoinArray( vargv, " " ) ); }
	function Quit		( message ) { Send( "QUIT :"+ message ); }
	function Msg		( target, message ) { Send( "PRIVMSG " + target + " :" + message ); }						// For sending messages to channel/user
	function Adminmsg	( target, message ) { Send( "PRIVMSG %" + target + ":" + message ); }						// For sending messages to all halfops on a channel
	function Notice		( target, message ) { Send( "NOTICE " + target + " :" + message ); }						// For sending notices to channel/user
	function Me			( target, message ) { Send( "PRIVMSG " + target + " :\x0001ACTION "+ message +"\x0001" ); }	// For sending /me text
	function Rejoin		( channel ) { Part( channel ); Join( channel, FindChannel( channel ).Key ); }
	function Autojoin	() {
		local channels = split( config.irc_channels, ", " ), info, key;
		foreach ( chanstr in channels )
		{
			info = split( chanstr, ":" );
			key = info.len() > 1 ? info[ 1 ] : "";
			Join ( info[ 0 ], key );
		}
	}
	function Debug ( item, msg )
		debug( "[IRC:"+ Name +":"+ item +"] "+ msg );
}
function SendMessageToIRC ( botname, message ) { FindBot( botname ).Send( message ); }

IRCChannels <- {};
class IRCChannel
{
	constructor ( channel, ... )
	{
		Name	= channel;
		lName	= channel.tolower();
		Key		= vargv.len() > 0 ? vargv[ 0 ] : "";
		Users	= 0;
		Bots	= [];
	}
	ID			= null;
	Name		= null;
	lName		= null;
	Key			= null;
	Users		= null;
	Userlist	= null;
	Bots		= [];
}

function FindChannel ( channame )
{
	local n = channame.tolower();
	return IRCChannels.rawin( n ) ? IRCChannels.rawget( n ) : false;
}

function AddUpdateChannel ( channame )
{
	local chan = FindChannel( channame );
	if ( chan ) chan.Name = channame;
	else
	{
		local lname = channame.tolower();
		IRCChannels.rawset( lname, IRCChannel( channame ) );
		chan = IRCChannels.rawget( lname );
	}
	return chan;
}

IRCUsers <- {};
class IRCUser
{
	constructor( nickname, address )
	{
		ID			= 1001 + ::IRCUsers.len();
		Name		= nickname;
		Address		= address;
		Level		= 1;
	}

	ID				= null;
	Name			= null;
	Address			= null;
	Level			= null;
}

function GetIRCUserID ( name ) { return FindUser( name ).ID; }
function GetIRCUserName ( ID ) { return IRCUsers[ ID - 1001 ].Name; }
function GetIRCUserAddress ( ID ) { return IRCUsers[ ID - 1001 ].Address; }
function GetIRCUserLevel ( ID ) { return IRCUsers[ ID - 1001 ].Level; }

// This function updates user info or adds a new user's information
// every time a user's name and address is parsed.
function AddUpdateUser ( name, address )
{
	local user = IRCUsers.rawin( name ) ? IRCUsers.rawget( name ) : false;
	if ( user ) user.Address = address;
	else
	{
		IRCUsers.rawset( name, IRCUser( name, address ) );
		user = IRCUsers.rawget( name );
	}
	UpdateUsers2( user );
	return user;
}

function UpdateUsers2 ( user )
{
	CallFunc( cScript_Main, "UpdateUsers", user.ID, user.Name, user.Address, user.Level );
}

function FindUser ( name )
	return IRCUsers.rawin( name ) ? IRCUsers.rawget( name ) : false;

function IsUserBot ( name )
{
	name = name.tolower();
	return IRCBots.rawin( name ) ? IRCBots.rawget( name ) : false;
}

// This function is triggered when the sockets connect to the IRC server
function onIRCConnected ( socket )
{
	local bot = FindBot( socket );						// This process is the equivalent to FindPlayer()
	bot.Send( "USER " + bot.Name + " windlord.net windlord.net Windscript " + cScript_Version + " Echo-Bot" );
	bot.Send( "NICK " + bot.Name );
	bot.Send( "MODE " + bot.Name + " +B" );
}

function onIRCDisconnected ( socket )
{
	local bot = FindBot( socket );						// This process is the equivalent to FindPlayer()
	RemoveBot( bot );
}

// This function is triggered when the sockets receive data from the IRC server
function onIRCData ( socket, raw )
{
	local bot = FindBot( socket );							// This process is the equivalent to FindPlayer()
	local raw = split( raw, "\r\n" );						// This process splits multiple line strings the IRC server sends out
															// This occurs when the server tries to send more than one line.
															// In such a case, the different lines are sent in one line, delimited with \r\n, aka a crlf
	bot.LastPing = GetTickCount();							// This records the last time the bot was pinged. The value is used in CheckBotTimeout()
															// Strictly speaking receiving data isn't pinging but this serves its purpose.

	local ntemp, nick, address, words;
	foreach ( rawline in raw )								// This loops through the raw string to make sure all IRC lines are processed
	{
		//bot.Debug( "RAW", rawline );						// Uncomment this line to see all raw output from the server

		rawline = split( rawline, " " );
		words = rawline.len();
		ntemp	= split( rawline[ 0 ], "!:");				// A user is identified as :Nickname!Username@Address
		if ( ntemp.len() > 1 )								// Make sure the format has both ! and : and two elements
		{
			nick = ntemp[ 0 ];
			address = ntemp[ 1 ];
			AddUpdateUser( nick, address );
		}

		if ( words > 1 )
		{
			if ( rawline[ 1 ] == "001" )															// Bot has connected to the network.
			{
				bot.Debug( "CONNECTED", "Connected to "+ rawline[ 6 ] );
				bot.Login();																		// Proceed to logging into the network.
			}

			else if ( rawline[ 0 ] == "ERROR" )
			{
				bot.Debug( "ERROR", JoinArray( rawline.slice( 1 ), " " ).slice( 1 ) );
				if ( JoinArray( rawline.slice( 1, 3 ), " " ) == ":Closing Link:" )					// For some reason the bot is losing its connection
				{
					if ( JoinArray( rawline.slice( 4 ), " " ) == "\x0028Ping timeout\x0029" )		// If it's a ping timeout,
						RecoverBot ( bot );
					else
						RemoveBot ( bot );
				}
			}
			else if ( rawline[ 0 ] == "PING" ) { bot.Send( "PONG " + rawline[ 1 ] ); }				// Reply to server PING events to keep bot alive



			else if ( rawline[ 1 ] == "433" )				// If there is a nickname clash
			{
				bot.Name = bot.Name + "_";					// Append '_' to current name
				onIRCConnected( socket );					// Try re-identifying with server
			}

			else if ( rawline[ 1 ] == "KICK" )
			{
				if ( rawline[ 3 ] == bot.Name )					// Update the list of channels the bot is in
				{											// The data is stored as "#Chan1 #Chan2 #Chan3"
					local chan = AddUpdateChannel( rawline[ 2 ] );
					bot.Channels.rawdelete( chan.Name );
					bot.Join( chan.Name, chan.Key );
					UpdateAvailBots( chan );
				}
			}

			else if	( rawline[ 1 ] == "PRIVMSG" )
			{
				rawline[ 3 ] = rawline[ 3 ].slice( 1 );
				local target = rawline[ 2 ], text = JoinArray( rawline.slice( 3 ), " " );
				if ( rawline[ 3 ][ 0 ] == 1 )
				{
					if ( rawline[ 3 ] == "\x0001ACTION" )
					{
						if ( bot.ID == 0 )
						{
							text = text.slice( 8, -1 );
							if ( target[ 0 ] == 35 && !IsUserBot( target ) ) CallFunc( cScript_Main, "onIRCChat_Desc", target, nick, text );
							else CallFunc( cScript_Main, "onIRCMessage_Desc", nick, text );
						}
					}
					else if	( rawline[ 3 ] == "\x0001VERSION\x0001"	) bot.Notice( nick, CTCP_VERSION_REPLY );
					else if ( rawline[ 3 ] == "\x0001PING"			) bot.Notice( nick, "\x0001PING "+ rawline[ 4 ] );
					else if ( rawline[ 3 ] == "\x0001FINGER\x0001"	) bot.Notice( nick, CTCP_FINGER_REPLY );
				}
				else if ( bot.ID == 0 )
				{
					if ( target[ 0 ] == 35 && !IsUserBot( target ) ) CallFunc( cScript_Main, "onIRCChat", target, nick, text );
					else CallFunc( cScript_Main, "onIRCMessage", nick, text );
				}
			}

			else if	( rawline[ 1 ] == "NOTICE" )
			{
				rawline[ 3 ] = rawline[ 3 ].slice( 1 );
				local target = rawline[ 2 ], text = JoinArray( rawline.slice( 3 ), " " );

				if ( nick == "NickServ" ) DealWithNickServ( bot, text );	// The notice was sent by NickServ!
			}

			else if ( nick == bot.Name )
			{
				if ( rawline[ 1 ] == "JOIN" )
				{
					local chan = AddUpdateChannel( rawline[ 2 ].slice( 1 ) );
					if ( !bot.Channels.rawin( chan.Name ) ) bot.Channels.rawset( chan.Name, chan );
					bot.Send( "MODE "+ chan.Name );
					bot.Debug( "JOIN", chan.Name );
					UpdateAvailBots( chan );
				}
				else if ( rawline[ 1 ] == "PART" )
				{
					local chan = AddUpdateChannel( rawline[ 2 ] );
					bot.Channels.rawdelete( chan.Name );
					bot.Debug( "PART", chan.Name );
					UpdateAvailBots( chan );
				}
			}

			if ( bot.ID == 0 )
			{
				if ( rawline[ 1 ] == "353" && rawline[ 4 ].tolower() == config.irc_echo )			// If a NAMES event is received to botID 0 on the echo,
				{
					rawline[ 5 ] = rawline[ 5 ].slice( 1 );
					ProcessNAMES( rawline[ 4 ], rawline.slice( 5 ) );								// Process the output (Update user levels)
				}

				else if ( rawline[ 1 ] == "MODE" && rawline[ 2 ].tolower() == config.irc_echo )		// If a MODE event is received to botID 0 on the echo,
					ProcessModes( rawline.slice( 3 ) );												// Process the output (Update user levels)
			}

			else if ( words > 2 )
			{
				if ( rawline[ 2 ] == bot.Name )
				{
					if ( rawline[ 1 ] == "324" && rawline.len() > 5 )									// If channel mode has something after the +modes bit
						FindChannel( rawline[ 3 ] ).Key = rawline[ 5 ];									// Assume it is channel key and store

					else if ( rawline[ 1 ] == "401" && rawline[ 3 ] == "NickServ" )
						bot.Autojoin();

					else if ( rawline[ 1 ] == "INVITE" )
						bot.Join( rawline[ 3 ].slice( 1 ) );

				}
			}
		}
	}
}

// This function processes the NAMES request result, which is a list of users with their top levels prefixed
function ProcessNAMES ( channel, names )
{
	local level, user;
	foreach ( name in names )
	{
		switch ( name[ 0 ] )
		{
			case 126:
				level = 6;
				break;
			case 38:
				level = 5;
				break;
			case 64:
				level = 4;
				break;
			case 37:
				level = 3;
				break;
			case 43:
				level = 2;
				break;
			default:
				level = 1;
				break;
		}
		if ( level > 1 ) name = name.slice( 1 );

		user = FindUser( name );
		if ( user ) user.Level = level;
		else AddUpdateUser( name, "" ).Level = level;
	}
}

// This processes usermodes and updates the user levels accordingly
function ProcessModes ( changes )
{
	local mode, user, level, num = 1;
	foreach ( idx, char in changes[ 0 ] )
	{
		if ( char == '-' || char == '+' )
		{
			mode = char;
			continue;
		}
		if ( !mode ) continue;
		switch ( char )
		{
			case 113:
				level = 6;
				break;
			case 97:
				level = 5;
				break;
			case 111:
				level = 4;
				break;
			case 104:
				level = 3;
				break;
			case 118:
				level = 2;
				break;
		}

		user = FindUser( changes[ num ] );
		if ( level && user )
		{
			if ( mode == '+' && user.Level < level ) user.Level = level;
			else if ( mode == '-' && user.Level >= level ) IRCBots[ 0 ].Send( "NAMES "+ config.irc_echo );
		}
		num++;
	}
}

// This function is run 7 seconds after the bot is created.
function CheckBotLogin ( botname )
{
	local bot = IRCBots.rawget( botname );
	if ( bot && !bot.NickServ )
	{
		if ( config.irc_registerbots )
		{
			bot.Msg( "NickServ", "Register "+ config.irc_password + " windscript@windlord.net" );	// Register the bot.
			config.irc_registerbots <- false;
		}
		else
		{
			bot.Msg( "NickServ", "Group "+ split( config.irc_botnames, ", " )[ 0 ] +" "+ config.irc_password );
			MainBot.Msg( "HostServ", "Group" );
		}
	}
}


// This is the function which my advanced nickserv-identification system uses!
// The bot will login when asked to, then when confirmed will autojoin all channels.
// If the nickname is not registered, the function CheckBotLogin will either register
// or group it depending on the "irc_registerbots" option set in CONFIG.txt
function DealWithNickServ ( bot, text )
{
	bot.NickServ = true;

	if ( text == "This nickname is registered and protected. If it is your" ) bot.Login();
	else if ( text == "Password accepted - you are now recognized." )
	{
		bot.Debug ( "LOGIN", "Login Successful" );
		bot.Autojoin();
	}
	else if ( text == "Password incorrect." ) bot.Debug( "LOGIN", "Could not login \x0028Incorrect Password\x0029" );
	else if ( text == "You are now in the group of \x0002"+ MainBot.Name +"\x0002." )
	{
		bot.Debug ( "GROUP", "Grouped nickname with "+ MainBot.Name );
		bot.Msg( "HostServ", "On" );
		bot.Autojoin();
	}
	else if ( text == "Nick \x0002"+ MainBot.Name +"\x0002 isn't registered." ) bot.Autojoin();
	else if ( text == "Nickname \x0002"+ bot.Name +"\x0002 registered under your" || text == "Nickname "+ bot.Name +" registered." )
	{
		bot.Debug ( "REGISTER", "Nickname Registered" );
		bot.Autojoin();
	}
	else if ( text =="Your nick isn't registered." )
	{
		NewTimer( "SendMessageToIRC", 60000, 1, bot.name, "Privmsg Nickserv :Register "+ config.irc_password + " windlord@windlord.net" );
		bot.Autojoin();
	}
}


// This is a function which checks if the bots are still connected.
// This is done by checking when the last strings were received from the server.
// This function is run every 10 seconds from Background.nut
BotTimeoutChecker <- NewTimer( "CheckBotTimeout", 20000, 0 );
function CheckBotTimeout ( )
{
	local deadbot, deadbotid, dur;
	foreach ( bot in IRCBots )
	{
		if ( bot )
		{
			dur = GetTickCount() - bot.LastPing;
			if ( dur > 120000 )
				RecoverBot( bot );
			else if ( dur > 100000 )
				bot.Send( "PING :"+ time() );
		}
	}
}

// This is a function which is called whenever a bot joins or parts a channel
// It updates the registered array for available bots for any channel.
function UpdateAvailBots ( chan )
{
	chan.Bots = [];
	foreach ( bot in IRCBots )
	{
		if ( bot && bot.IsOn( chan ) ) chan.Bots.append( bot );
	}
}

// This is a function which either notices or messages an IRC channel or user.
// If you specify a channel as the target, the function will find all available bots on the channel
// and shall use those bots to echo into the channel.
function BotMessage ( target, type, text )
{
	local max, min, botlist = IRCBots;
	if ( target[ 0 ] == '#' )
		botlist = FindChannel( target ) ? FindChannel( target ).Bots : false;

	if ( botlist )
	{
		foreach ( idx, bot in botlist )
		{
			if ( !max ) { max = bot; min = bot; }
			else
			{
				if ( bot.Used > max.Used ) max = bot;
				else if ( bot.Used < min.Used ) min = bot;
			}
		}
		min.Used = GetTickCount();

		if ( type.tolower() == "notice" ) min.Notice( target, text );
		else min.Msg( target, text );
	}
}
