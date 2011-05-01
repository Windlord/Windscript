/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

Plugins <- {};

function LoadPlugins ()
{
	local plugins = split( config.plugins, ", " );
	foreach ( name in plugins )
	{
		Plugins.rawset( name, Plugin( name ) );
		Plugins.rawget( name ).Load();
	}
}

function FindPlugin ( name )
	return Plugins.rawin( name ) ? Plugins.rawget( name ) : false;

function PluginCommand ( name, player, params )
{
	foreach ( plugin in Plugins )
	{
		if ( plugin.Commands.rawin( name ) )
			return plugin.Commands.rawget( name )( player, params );
	}
	return false;
}

function PluginEvent ( event, ... )
{
	vargv.insert( 0, this );
	foreach ( plugin in Plugins )
	{
		if ( plugin.Events.rawin( event ) )
			plugin.Events.rawget( name ).acall( vargv );
	}
}

class Plugin
{
	constructor ( name )
		Name = name;

	function Load ()
	{
		debug ( "Loading plugin..." );
		try { ::dofile ( cScript_Dir +"Plugins/"+ Name +".nut" ); } catch ( ex )
		if ( ex )
		{
			debug ( "Error: "+ ex );
			debug ( "Failed to load plugin.");
			return false;
		}
		debug ( "Loaded plugin." );
	}

	function RegisterCommand ( command, fn )
		Commands.rawset( command.tolower(), fn );

	function RegisterEvent ( event, fn )
		Events.rawset( event, fn );

	function debug ( msg )
		return ::debug( "[PLUGIN:"+ Name +"] "+ msg );

	Name = "";
	Commands = {};
	Events = {};
}