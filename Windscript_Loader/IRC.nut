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
	local botslist = split( config.irc_botnames, ", " );			// Get an array of bot names from config
	foreach ( idx, bot in botslist )					// For each of the bots in config,
	{
		if ( bot && bot != "" )
			NewTimer( "CreateBot", 2000 * ( idx + 1 ), 1, bot );	// Initiate staggered execs of CreateBot functions for each bot
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

function RemoveBot ( bot, unloading = false )
{
	local name = bot.lName;							// Cache bot's name and id for the print below

	bot.CheckLogin.Delete();
	if ( bot.Socket )
	{
		bot.Quit( "Windscript Version "+ cScript_Version );		// In case the bot is still connected, send QUIT message
		bot.Socket.Delete();						// Delete socket instance
	}
	bot.Debug( "REMOVE", "Removing bot from slot "+ bot.ID );
	IRCBots.rawdelete( name );						// Remove bot data from IRCBots

	if ( !unloading )
		foreach ( a in IRCChannels ) UpdateAvailBots( a );		// Update pool of available bots per channel
}

function RecoverBot ( bot )
{
	local deadbot = bot.Name, deadbotid = bot.ID;
	bot.Debug( "RECOVER", "Recovering dead bot" );
	RemoveBot( bot );
	NewTimer( "CreateBot", 2000 * ( deadbotid + 1 ), 1, deadbot );
}

// This is the Echo Script's equivalent to "FindPlayer"
// It loops through the table, "IRCBots" and identifies which bot instance the socket is being used by
function FindBot ( socket )
{
	foreach ( bot in IRCBots )
		if ( bot.Socket.ID == socket.ID ) return bot;			// If socket ids match return bot instance
	return false;								// If bot not found, return false
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
		Name = name;
		ID = ::IRCBots.len();
		lName = name.tolower();
		Channels = {};							// List of channels which the bot is on
		Init = time();							// Record when bot was created
		Debug( "CREATED", "Bot created in slot "+ ID );
		Socket = ::NewSocket( "onIRCData" );				// This creates a new socket connection
		Socket.SetLostConnFunc( onIRCDisconnected );			// This sets a function for the socket to call when disconnected
		Socket.SetNewConnFunc( onIRCConnected );			// This sets a function for the connected socket to call
		Socket.Connect( ::config.irc_server,
				::config.irc_port );				// This connects the socket to the IRC server
		CheckLogin = ::NewTimer( "CheckBotLogin", 7000, 1, lName );
		LastPing = Init;
		NickServ = false;
		SendQueue = [];
		Used = 1;

		if ( ID == 0 ) ::MainBot <- this;
	}

	Name = null;								// This stores the name of the bot
	lName = null;
	ID = null;
	Socket = null;								// This stores the instance pointer for the socket created for the bot
	Channels = null;							// This stores the channel names which the bot is on
	NickServ = null;							// This is a check to see if the bot has been through NickServ
	Init = null;								// This stores the tick count when the bot was created (Can be used in bot uptime checking)
	CheckLogin = null;
	Used = null;
	LastPing = null;
	SendQueue = [];

	function IsOn( channel )
	{
		foreach ( chan in Channels )
			if ( chan == channel ) return true;
		return false;
	}
	function Identify ()
	{
		Send( "USER " + Name + " windlord.net windlord.net Windscript " + cScript_Version + " Echo-Bot" );
		Send( "NICK " + Name );
		Send( "MODE " + Name + " +B" );
		return true;
	}
	function Login		() { return Send( "PRIVMSG NickServ identify "+ config.irc_password ); }
	function Send		( message ) { return AddToQueue( message +"\r\n" ); }
	function AddToQueue	( msg ) { SendQueue.push( msg ); return true; }
	function ProcessQueue	( ) {
		local msg = ::JoinArray( SendQueue, "" )
		if ( msg == "" ) return;
		Socket.Send( msg );
		SendQueue = [];
	}
	function Join		( channel, key = "" ) {
		local lchannel = channel.tolower();
		if ( !IRCChannels.rawin( lchannel ) ) IRCChannels.rawset( lchannel, IRCChannel( channel, key ) );
		return Send( "JOIN "+ channel +" "+ key );
	}
	function Part		( channel, msg = "Good bye" ) { return Send( "PART "+ channel +" "+ msg ); }
	function Quit		( message ) { return Send( "QUIT :"+ message ); }
	function Msg		( target, message ) { return Send( "PRIVMSG " + target + " :" + message ); }		// For sending messages to channel/user
	function Adminmsg	( target, message ) { return Send( "PRIVMSG %" + target + ":" + message ); }		// For sending messages to all halfops on a channel
	function Notice		( target, message ) { return Send( "NOTICE " + target + " :" + message ); }		// For sending notices to channel/user
	function Me		( target, message ) { return Msg( target, "\x0001ACTION "+ message +"\x0001" ); }	// For sending /me text
	function Rejoin		( channel ) { Part( channel ); return Join( channel, FindChannel( channel ).Key ); }
	function Autojoin	() {
		local channels = split( config.irc_channels, ", " ), info, key;
		foreach ( chanstr in channels )
		{
			info = split( chanstr, ":" );
			key = info.len() > 1 ? info[ 1 ] : "";
			Join ( info[ 0 ], key );
		}
		return true;
	}
	function Debug ( item, msg ) { debug( "[IRC:"+ Name +":"+ item +"] "+ msg ); return true; }
}
function SendMessageToIRC ( botname, message ) { return FindBot( botname ).Send( message ); }

IRCChannels <- {};
class IRCChannel
{
	constructor ( channel, key = "" )
	{
		Name = channel;
		lName = channel.tolower();
		Key = key;
		Users = {};
		Bots = [];
	}

	function _tostring ()
		return Name;

	Name = null;
	lName = null;
	Key = null;
	Users = null;
	Bots = [];
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

function UpdateMainScriptIRCChannel ( channel, user, level )
	CallFunc2( "UpdateIRCChannel", channel.Name, user.Name, level );

function PushIRCData ()
{
	foreach ( chan in IRCChannels )
	{
		foreach ( user, level in chan.Users )
			CallFunc2( "UpdateIRCChannel", chan.Name, user.Name, level );
	}
	foreach ( user in IRCUsers )
		CallFunc2( "UpdateIRCUser", user.Name, user.Address );
}

IRCUsers <- {};
class IRCUser
{
	constructor( nickname, address )
	{
		Name = nickname;
		Address = address;
	}

	function Level ( channel, newlevel = 0 )
	{
		if ( !channel.Users.rawin( this ) ) channel.Users.rawset( this, 1 );
		if ( !newlevel ) return channel.Users.rawget( this );
		else channel.Users.rawset( this, newlevel );
		::UpdateMainScriptIRCChannel( channel, this, newlevel );
		return true;
	}

	function _tostring ()
		return Name;

	Name = null;
	Address = null;
}

// This function updates user info or adds a new user's information
// every time a user's name and address is parsed.
function AddUpdateUser ( name, address )
{
	local user = IRCUsers.rawin( name ) ? IRCUsers.rawget( name ) : false;
	if ( user )
	{
		if ( address != user.Address )
		{
			user.Address = address;
			UpdateMainScriptIRCUser( user );
		}
	}
	else
	{
		IRCUsers.rawset( name, IRCUser( name, address ) );
		user = IRCUsers.rawget( name );
		UpdateMainScriptIRCUser( user );
	}
	return user;
}

function UpdateMainScriptIRCUser ( user )
	CallFunc2( "UpdateIRCUser", user.Name, user.Address );


function FindUser ( name )
	return IRCUsers.rawin( name ) ? IRCUsers.rawget( name ) : false;

function IsUserBot ( name )
{
	name = name.tolower();
	return IRCBots.rawin( name ) ? IRCBots.rawget( name ) : false;
}


// This function is triggered when the sockets connect to the IRC server
function onIRCConnected ( socket )
	FindBot( socket ).Identify();

function onIRCDisconnected ( socket )
{
	local bot = FindBot( socket );					// This process is the equivalent to FindPlayer()
	RemoveBot( bot );
}

// This function is triggered when the sockets receive data from the IRC server
function onIRCData ( socket, raw )
{
	local bot = FindBot( socket );						// This process is the equivalent to FindPlayer()
	local raw = split( raw, "\r\n" );					// This process splits multiple line strings the IRC server sends out
										// This occurs when the server tries to send more than one line.
										// In such a case, the different lines are sent in one line, delimited with \r\n, aka a crlf
	bot.LastPing = time();							// This records the last time the bot was pinged. The value is used in CheckBotTimeout()
										// Strictly speaking receiving data isn't pinging but this serves its purpose.

	local ntemp, nick, address, words;
	foreach ( rawline in raw )						// This loops through the raw string to make sure all IRC lines are processed
	{
		/* UNCOMMENT FOR IRC RAW OUTPUT */
		//bot.Debug( "RAW", rawline );					// Uncomment this line to see all raw output from the server
		/* UNCOMMENT FOR IRC RAW OUTPUT */

		if ( rawline.len() < 2 ) continue;

		rawline = split( rawline, " " );
		words = rawline.len();
		ntemp	= split( rawline[ 0 ], "!:" );				// A user is identified as :Nickname!Username@Address
		if ( ntemp.len() > 1 )						// Make sure the format has both ! and : and two elements
		{
			nick = ntemp[ 0 ];
			address = ntemp[ 1 ];
			AddUpdateUser( nick, address );
		}

		if ( words > 1 ) ProcessRaw( bot, rawline, nick, address )
	}
}

function ProcessRaw ( bot, raw, nick, address )
{
	local words = raw.len();
	if ( raw[ 1 ] == "001" )						// Bot has connected to the network.
	{
		bot.Debug( "CONNECTED", "Connected to "+ raw[ 6 ] );
		bot.Login();							// Proceed to logging into the network.
	}

	else if ( raw[ 0 ] == "ERROR" )
	{
		bot.Debug( "ERROR", JoinArray( raw.slice( 1 ), " " ).slice( 1 ) );
		if ( raw[ 1 ] == ":Closing" && raw[2] == "Link:" )		// For some reason the bot is losing its connection
		{
			if ( raw[ 4 ] == "\x0028Ping" && raw[ 5 ] == "timeout\x0029" )
				RecoverBot ( bot );
			else RemoveBot ( bot );
		}
	}
	else if ( raw[ 0 ] == "PING" ) { bot.Send( "PONG " + raw[ 1 ] ); }	// Reply to server PING events to keep bot alive



	else if ( raw[ 1 ] == "433" )						// If there is a nickname clash
	{
		bot.Name = bot.Name + "_";					// Append '_' to current name
		bot.Identify();							// Try re-identifying with server
	}

	else if ( raw[ 1 ] == "KICK" )
	{
		if ( raw[ 3 ] == bot.Name )					// Update the list of channels the bot is in
		{								// The data is stored as "#Chan1 #Chan2 #Chan3"
			local chan = AddUpdateChannel( raw[ 2 ] );
			bot.Channels.rawdelete( chan.Name );
			bot.Join( chan.Name, chan.Key );
			UpdateAvailBots( chan );
		}
	}

	else if ( raw[ 1 ] == "NICK" )
	{
		local newnick = raw[ 2 ].slice( 1 );
		local newuser = IRCUser( newnick, address );
		IRCUsers.rawset( newnick, newuser );
		IRCUsers.rawdelete( nick );
		foreach ( chan in IRCChannels )
		{
			if ( chan.Users.rawin( nick ) )
			{
				chan.Users.rawset( newnick, chan.Users.rawget( nick ) );
				chan.Users.rawdelete( nick );
			}
		}
		CallFunc2( "UpdateIRCUserNickname", nick, newnick );
	}

	else if	( raw[ 1 ] == "PRIVMSG" )
	{
		raw[ 3 ] = raw[ 3 ].slice( 1 );
		local target = raw[ 2 ], text = JoinArray( raw.slice( 3 ), " " );
		if ( raw[ 3 ][ 0 ] == 1 )
		{
			if ( raw[ 3 ] == "\x0001ACTION" )
			{
				if ( bot.ID == 0 )
				{
					text = text.slice( 8, -1 );
					if ( IsUserBot( nick ) ) return;
					if ( target[ 0 ] == '#' )
						CallFunc2( "onIRCChat_Desc", target, nick, text );
					else CallFunc2( "onIRCMessage_Desc", nick, text );
				}
			}
			else if	( raw[ 3 ] == "\x0001VERSION\x0001" ) bot.Notice( nick, CTCP_VERSION_REPLY );
			else if ( raw[ 3 ] == "\x0001PING" ) bot.Notice( nick, "\x0001PING "+ raw[ 4 ] );
			else if ( raw[ 3 ] == "\x0001FINGER\x0001" ) bot.Notice( nick, CTCP_FINGER_REPLY );
		}
		else if ( bot.ID == 0 )
		{
			if ( IsUserBot( nick ) ) return;
			if ( target[ 0 ] == '#' )
				CallFunc2( "onIRCChat", target, nick, text );
			else CallFunc2( "onIRCMessage", nick, text );
		}
	}

	else if	( raw[ 1 ] == "NOTICE" )
	{
		raw[ 3 ] = raw[ 3 ].slice( 1 );
		local target = raw[ 2 ], text = JoinArray( raw.slice( 3 ), " " );

		if ( nick == "NickServ" ) DealWithNickServ( bot, text );	// The notice was sent by NickServ!
	}

	if ( nick == bot.Name )
	{
		if ( raw[ 1 ] == "JOIN" )
		{
			local chan = AddUpdateChannel( raw[ 2 ].slice( 1 ) );
			if ( !bot.Channels.rawin( chan.Name ) ) bot.Channels.rawset( chan.Name, chan );
			bot.Send( "MODE "+ chan.Name );
			bot.Debug( "JOIN", chan.Name );
			UpdateAvailBots( chan );
			if ( bot.ID == 0 ) bot.Send( "WHO :"+ chan.Name );		// If MainBot send WHO request to retrieve user addresses
		}
		else if ( raw[ 1 ] == "PART" )
		{
			local chan = AddUpdateChannel( raw[ 2 ] );
			bot.Channels.rawdelete( chan.Name );
			bot.Debug( "PART", chan.Name );
			UpdateAvailBots( chan );
		}
	}

	if ( bot.ID == 0 )
	{
		if ( raw[ 1 ] == "353" )						// If a NAMES event is received to botID 0,
		{
			raw[ 5 ] = raw[ 5 ].slice( 1 );
			ProcessNAMES( FindChannel( raw[ 4 ] ), raw.slice( 5 ) );	// Process the output (Update user levels)
		}

		else if ( raw[ 1 ] == "MODE" && words > 4 )				// If a MODE event is received to botID 0,
			ProcessModes( FindChannel( raw[ 2 ] ), raw.slice( 3 ) );	// Process the output (Update user levels)

		else if ( raw[ 1 ] == "311" && words > 7 )				// Response to WHOIS request for user address
			AddUpdateUser( raw[ 3 ], raw[ 4 ] +"@"+ raw[ 5 ] );

		else if ( raw[ 1 ] == "352" && words > 7 )				// Response to WHO request
			AddUpdateUser( raw[ 7 ], raw[ 4 ] +"@"+ raw[ 5 ] );
	}

	if ( words > 2 )
	{
		if ( raw[ 2 ] == bot.Name )
		{
			if ( raw[ 1 ] == "324" && raw.len() > 5 )			// If channel mode has something after the +modes bit
				FindChannel( raw[ 3 ] ).Key = raw[ 5 ];			// Assume it is channel key and store

			else if ( raw[ 1 ] == "401" && raw[ 3 ] == "NickServ" )
				bot.Autojoin();

			else if ( raw[ 1 ] == "INVITE" )
				bot.Join( raw[ 3 ].slice( 1 ) );
		}
	}
}

// This function processes the NAMES request result, which is a list of users with their top levels prefixed
// NAMES are in the following format: ~User1 &User2 @User3 %User4
function ProcessNAMES ( channel, names )
{
	local level, user;
	foreach ( name in names )
	{
		level = IRCSymltoLevel( name[ 0 ] );
		if ( level > 1 ) name = name.slice( 1 );

		user = FindUser( name );
		if ( user ) user.Level( channel, level );					// If user exists, update level
		else AddUpdateUser( name, "None" ).Level( channel, level );			// Create user and add level
	}
}

// This processes usermodes and updates the user levels accordingly
// MODES are in the following format: +ao-hv User1 User2 User3 User4
function ProcessModes ( channel, changes )
{
	local mode, user, level, num = 1;
	foreach ( idx, char in changes[ 0 ] )
	{
		if ( char == '-' || char == '+' )						// Check if char is indicating addition/deletion of mode
		{
			mode = char;
			continue;
		}
		if ( !mode ) continue;
		level = IRCModetoLevel ( char );

		user = FindUser( changes[ num ] );
		if ( level && user )
		{
			if ( mode == '+' && user.Level( channel ) < level ) user.Level( channel, level );
			else if ( mode == '-' && user.Level( channel ) >= level ) MainBot.Send( "NAMES "+ channel );
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
			bot.Autojoin();
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
		if ( config.irc_registerbots )
			NewTimer( "SendMessageToIRC", 60000, 1, bot.Name, "Privmsg Nickserv :Register "+ config.irc_password + " windlord@windlord.net" );
		bot.Autojoin();
	}
}


// This is a function which checks if the bots are still connected.
// This is done by checking when the last strings were received from the server.
BotTimeoutChecker <- NewTimer( "CheckBotTimeout", 30000, 0 );
function CheckBotTimeout ( )
{
	local deadbot, deadbotid, dur;
	foreach ( bot in IRCBots )
	{
		if ( bot )
		{
			dur = time() - bot.LastPing;
			if ( dur > 120 )
				RecoverBot( bot );
			else if ( dur > 100 )
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
	if ( target[ 0 ] == '#' ) botlist = FindChannel( target ) ? FindChannel( target ).Bots : IRCBots;

	if ( botlist )
	{
		foreach ( bot in botlist )
		{
			if ( !max ) { max = bot; min = bot; }
			else
			{
				if ( bot.Used > max.Used ) max = bot;
				else if ( bot.Used < min.Used ) min = bot;
			}
		}
		if ( !min ) return false;
		min.Used = time();

		if ( type.tolower() == "notice" ) min.Notice( target, text );
		else min.Msg( target, text );
		return true;
	}
	return false;
}

// This bit is a timer which runs every 200ms to send out messages stored in the queue.
// This is to allow the bot to get throttled less while still being able to spam.
BotSendMsgTimer <- NewTimer( "ProcessBotMsgQueues", 100, 0 );
function ProcessBotMsgQueues ()
{
	foreach ( bot in IRCBots )
		bot.ProcessQueue();
}
