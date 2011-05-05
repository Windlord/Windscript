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
const cScript_Is_Awesome= "true";			// This is the most important line!
const cScript_Main	= "Scripts/Windscript/Main.nut";
const ircCol		= "\x0003";			// Equavalent to ctrl+k in mIRC (Colour Brace)
const ircCol2		= "\x0003\x0003";		// Two ircCols
const ircBold		= "\x0002";			// Equivalent to ctrl+b in mIRC (Boldness Brace)

cInit_Ticks		<- GetTickCount();		// System ticks when server was started

// Function called when script is loaded.
function onScriptLoad ()
{
	print ( "\r       \n- Loading Windscript Loader" );

	dofile ( cScript_Dir + "Settings.nut" );
	dofile ( cScript_Dir + "Debug.nut" );
	dofile ( cScript_Dir + "Misc.nut" );

	AttemptLoad ( "IRC.nut" );
	debug ( "Loaded Windscript Loader" );

	LoadScript ( "Windscript" );

	InitialiseBots();
}

function AttemptLoad ( script )
{
	print ( "Loading "+ script );
	try { dofile ( cScript_LoaderDir + script ); } catch ( ex )
	if ( ex )
	{
		print ( "\r["+script+":ERROR]\t "+ ex );
		print ( "Failed to load "+ script );
	}
}

// Function called when script is unloaded.
function onScriptUnload ()
{
	print ( "\r       \n- Unloading Windscript Loader" );
	BotTimeoutChecker.Delete();
	UnloadBots();
	debug ( "Unloaded Windscript Loader" );
}

// This dummy timer bit is necessary so that the server does not crash.
// The server crashes because the server will try to return a boolean to the script
// where CallFunc was called from. Of course, that script will have been unloaded by then.
function ReloadScript ()
	NewTimer( "ReloadScriptDo", 0, 1 );
function ReloadScriptDo ()
{
	UnloadScript( "Windscript" );
	LoadScript( "Windscript" );
}

function GetInitTicks ()
	return cInit_Ticks;
