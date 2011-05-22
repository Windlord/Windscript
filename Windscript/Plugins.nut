/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

Plugins <- {};									// A table to store all Plugin instances into

function LoadPlugins ()
{
	local plugins = split( config.plugins, ", " ), result, count = 0;	// Get config list of plugins (case-sensitive)
	foreach ( name in plugins )
	{
		Plugins.rawset( name, Plugin( name ) );				// Create new plugin instance
		result = Plugins.rawget( name ).Load();				// Load plugin
		if ( result ) count++;
	}
	if ( count )
		debug( "[PLUGIN] Loaded "+ count + ( count > 1 ? " plugins." : " plugin." ) );
}

function FindPlugin ( name )
	return Plugins.rawin( name ) ? Plugins.rawget( name ) : false;		// Look for plugin by name in Plugins table

function PluginCommand ( name, player, params )
{
	foreach ( plugin in Plugins )
	{
		if ( !plugin.Enabled ) continue;				// If plugin disabled, skip plugin
		if ( plugin.Commands.rawin( name ) )				// If command registered for plugin, run associated func
			return plugin.Commands.rawget( name )( player, params );
		else if ( plugin.CommandsAllChannels.rawin( name ) )		// If command registered for all channels for plugin, run associated func
			return plugin.CommandsAllChannels.rawget( name )( player, params, config.irc_echo_lower );
	}
	return false;								// If no associated func found, return false
}

function PluginCommandChannels ( name, user, params, channel )			// Run for non-echo channels
{
	foreach ( plugin in Plugins )
	{
		if ( plugin.Enabled && plugin.CommandsAllChannels.rawin( name ) )
			return plugin.CommandsAllChannels.rawget( name )( user, params, channel );
	}
	return false;
}

function PluginEvent ( event, ... )
{
	vargv.insert( 0, this );						// Insert env object into front of params array
	foreach ( plugin in Plugins )
	{
		if ( plugin.Enabled && plugin.Events.rawin( event ) )		// If plugin enabled and event registered to a func
			plugin.Events.rawget( event ).acall( vargv );		// Call func with all params passed to this func
	}
}

class Plugin
{
	constructor ( name )
	{
		Name = name;
		Enabled = true;
		Commands = {};
		CommandsAllChannels = {};
		Events = {};
	}

	function Load ()
	{
		try { ::dofile ( cScript_Dir +"Plugins/"+ Name +".nut" ); } catch ( ex )
		if ( ex )
		{
			debug ( "Error: "+ ex );
			debug ( "Failed to load.");
			return false;
		}
		return debug ( "Loaded." );
	}

	function Enable ()
	{
		if ( Enabled ) return;
		Enabled = true;
		debug ( "Enabled." );
	}

	function Disable ()
	{
		if ( !Enabled ) return;
		Enabled = false;
		debug ( "Disabled." );
	}

	function RegisterCommand ( command, fn )
		Commands.rawset( command.tolower(), fn );

	function RegisterCommandAllChannels ( command, fn )
		CommandsAllChannels.rawset( command.tolower(), fn );

	function RegisterEvent ( event, fn )
		Events.rawset( event, fn );

	function debug ( msg )
		return ::debug( "[PLUGIN:"+ Name +"] "+ msg );

	Name = "";
	Enabled = true;
	Commands = {};
	CommandsAllChannels = {};
	Events = {};
}