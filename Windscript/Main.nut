/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

// Set constants for details used in all dofile-ed scripts
const cScript_Dir	= "Scripts/Windscript/";
const cScript_LoaderDir	= "Scripts/Windscript_Loader/";
const cScript_Author	= "Windlord";
const cScript_Version	= "1.0";
const cScript_Is_Awesome= "true";		// This is the most important line!
const cScript_Type	= "Main";
const cScript_Main	= "Scripts/Windscript/Main.nut";
const cScript_Loader	= "Scripts/Windscript_Loader/Loader.nut";
const ircCol		= "\x0003";		// Equavalent to ctrl+k in mIRC (Colour Brace)
const ircCol2		= "\x0003\x0003";	// Two ircCols
const ircBold		= "\x0002";		// Equivalent to ctrl+b in mIRC (Boldness Brace)

// Set global variable to store some details
cInit_Ticks	<- 0;
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
LUcolYellow	<- "[#ffff00]";
LUcolClose	<- "[#d]";

DEBUG <- true;
function debug ( msg )
{
	if ( DEBUG ) return CallFunc2( "debug", msg );
	else print( msg );
}

// Function called when script is loaded.
function onScriptLoad ()
{
	Load_Errors <- 0;
	print ( "\r       \n- Loading Windscript Version "+ cScript_Version );

	// Load necessary modules
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
	AttemptLoad ( "AdminCommands.nut" );	// Load AdminCommands.nut which handles admin commands
	AttemptLoad ( "CommandsList.nut" );	// Load CommandsList.nut which contains the list of commands
	AttemptLoad ( "GameEvents.nut" );	// Load GameEvents.nut which handles all in-game events
	AttemptLoad ( "ScriptEvents.nut" );	// Load ScriptEvents.nut which handles events triggered by Windscript
	AttemptLoad ( "Plugins.nut" );		// Load Plugins.nut which deals with load/unloading plugins

	print ( "\r- Completed Loading All Scripts.\n" );

	// Report encountered number of errors so one can check the console
	if ( Load_Errors )
	{
		print	( Load_Errors +" Error(s) Encountered.\n" );
		mErrorG ( Load_Errors +" Error(s) Encountered." );
	}

	NewTimer( "AfterScriptLoad", 1000, 1 );
}

function AfterScriptLoad()
{
	cInit_Ticks = CallFunc( cScript_Loader, "GetInitTicks" );
	UptimeLastUpdated = time();
	LoadPlugins();
	EMessage (  iCol( 4, "* Windscript Loaded." ), colRed );
	debug ( "Loaded Windscript Version "+ cScript_Version );
	GameTimer = NewTimer( "Background", 500, 0 );
	NewTimer( "ReloadPlayers", 1000, 1 );
}

function AttemptLoad ( script )
{
	print ( "Loading "+ script );
	try { dofile ( cScript_Dir + script ); } catch ( ex )
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
	DEBUG = false;								// CallFunc fails onScriptUnload for some reason
	print ( "\r       \n- Unloading Windscript Version "+ cScript_Version );
	UnloadPlayers();
	UnloadData();
	if ( GameTimer ) GameTimer.Delete();
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
