/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

// MAKE SURE YOU READ README.txt BEFORE YOU DO ANYTHING!! //

// Set constants for details used in all dofile-ed scripts
const cScript_Dir	= "Scripts/Windscript/";// Use this to access files in script directory
const cScript_Author	= "Windlord";
const cScript_Version	= "1.0";
const cScript_Is_Awesome= "true";		// This is the most important line!
const cScript_Config	= "./Scripts/Windscript/config.ini";
const cScript_Loader	= "Scripts/Windscript_Loader/Loader.nut";
const ircCol		= "\x0003";		// Equavalent to ctrl+k in mIRC (Colour Brace)
const ircCol2		= "\x0003\x0003";	// Two ircCols
const ircBold		= "\x0002";		// Equivalent to ctrl+b in mIRC (Boldness Brace)

// Set global variable to store some details
cMax_Players	<- GetMaxPlayers();		// Maximum number of players
Load_Errors	<- 0;
colPink		<- Colour( 255, 20, 147 );	// The following are all predefined colours
colBlue		<- Colour( 0, 0, 255 );
colWhite	<- Colour( 255, 255, 255 );
colRed		<- Colour( 255, 0, 0 );
colBlack	<- Colour( 0, 0, 0 );
colYellow	<- Colour( 255, 255, 0 );
colGreen	<- Colour( 0, 255, 0 );
colCyan		<- Colour( 0, 255, 255 );
colMagenta	<- Colour( 255, 0, 255 );

LUcolRed	<- "[#ff0000]";
LUcolBlue	<- "[#0000ff]";
LUcolWhite	<- "[#ffffff]";
LUcolBlack	<- "[#000000]";
LUcolClose	<- "[#d]";

function debug ( msg )
	return CallFunc( cScript_Loader, "debug", msg );

// Function called when script is loaded.
function onScriptLoad ()
{
	Load_Errors <- 0;
	print ( "\r       \n- Loading Windscript Version "+ cScript_Version );

	// Load necessary modules
	LoadModule( "lu_ini" );
	LoadModule( "lu_hashing" );

	// Load component scripts
	// NOTE: The order in which these scripts are loaded matters.
	AttemptLoad ( "Settings.nut" );		// Load Settings.nut which parses CONFIG.ini
	AttemptLoad ( "Misc.nut" );		// Load Misc.nut which contains all miscellaneous functions
	AttemptLoad ( "Utility.nut" );		// Load Utility.nut which contain functions necessary in Windscript/
	AttemptLoad ( "Background.nut" );	// Load Background.nut which handles all background operations
	AttemptLoad ( "Data.nut" );		// Load Data.nut which handles all data processes
	AttemptLoad ( "Echo.nut" );		// Load Echo.nut which handles the IRC echo
	AttemptLoad ( "Accounts.nut" );		// Load Accounts.nut which deals with all accounts data
	AttemptLoad ( "Mail.nut" );		// Load Mail.nut which handles the sending of emails
	AttemptLoad ( "IPInfo.nut" );		// Load IPInfo.nut which retrieves information of IP from a website
	AttemptLoad ( "Admin.nut" );		// Load Admin.nut which deals with administration functions
	AttemptLoad ( "Commands.nut" );		// Load Commands.nut which handles IRC and Player commands
	AttemptLoad ( "CommandsList.nut" );	// Load CommandsList.nut which contains the list of commands
	AttemptLoad ( "GameEvents.nut" );	// Load GameEvents.nut which handles all in-game events
	AttemptLoad ( "Afk.nut" );		// Load Afk.nut which allows AFK logging ingame and on IRC
	AttemptLoad ( "Plugins.nut" );		// Load Plugins.nut which deals with load/unloading plugins

	print ( "\r- Completed Loading All Scripts.\n" );
	NewTimer ( "AfterScriptLoad", 1000, 1 );
}

function AfterScriptLoad ()
{
	cInit_Ticks <- CallFunc( cScript_Loader, "GetInitTicks" );
	UptimeLastUpdated <- cInit_Ticks;
	if ( Load_Errors )
	{
		print	( Load_Errors +" Error(s) Encountered.\n" );
		mErrorG ( Load_Errors +" Error(s) Encountered." );
	}

	NewTimer ( "StartBackground", 1000, 1 );
	EMessage (  iCol( 4, "* Windscript Loaded." ), colRed );
	debug ( "Loaded Windscript Version "+ cScript_Version );
}

function AttemptLoad ( script )
{
	print ( "Loading "+ script	);
	try { dofile ( cScript_Dir + script	); } catch ( ex )
	if ( ex )
	{
		Load_Errors++;
		print ( "\r["+script+":ERROR]\t "+ ex );
		print ( "Failed to load "+ script );
	}
}

function onServerStart ()
{
	print( "\r  __       __)                               " );
	print( "\r (, )  |  /  ,       /)             ,        " );
	print( "\r    | /| /    __   _(/  _   _  __    __  _/_ " );
	print( "\r    |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__ " );
	print( "\r    /  |                          .-/        " );
	print( "\r _______________________________ (_/ ________" );
	print( "\r                                  version "+ cScript_Version );
	print( "\r                                  by "+ cScript_Author +"\n" );
}

function onScriptUnload ()
{
	print ( "\r       \n- Unloading Windscript Version "+ cScript_Version );
	GameTimer.Delete();
	UnloadData();
	debug ( "Unloaded Windscript Version "+ cScript_Version );
}

function onConsoleInput ( cmd, text )
{
	if ( cmd == "help" ) print ( "raw, reload, irc, ircall, createbot, removebot, reload_scripts" );
	else if ( cmd == "exit" ) print ( "Type \"quit\"." );

	// This command compiles any string which you write into the terminal and executes it as a script
	else if ( cmd == "raw" )
	{
		local raw = compilestring( text );
		raw();
	}

	// This command will reload Windscript while keeping the IRC echo online
	else if ( cmd == "reload" )
	{
		debug( "Reloading Windscript..." );
		EMessage( iCol( 4, "* Reloading Windscript..." ), colRed );
		CallFunc2( "ReloadScript" );
	}

	// Format: "irc botname rawcmd"
	// Sends "rawcmd" to the IRC server for botname (botname can be a wildcard)
	// It is a useful tool when you want to send a command which isn't specified in any custom function.
	else if ( cmd == "irc" )
	{
		local a = split( text, " " );
		if ( a.len() < 2 ) print( "FORMAT - \"IRC\" BOT_NAME RAW_COMMAND" );	// This checks if all parameters are present
		else
		{
			local rawcmd = JoinArray( a.slice( 1 ), " " );
			CallFunc2( "FindBotDo", a[ 0 ], rawcmd );
		}
	}

	// Format: "createbot botname"
	// Creates a bot with the name: "botname"
	else if ( cmd == "createbot" )
	{
		if ( text ) CallFunc2( "CreateBot" split( text, " " )[ 0 ] );
	}
}
