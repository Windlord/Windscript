/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function IncData ( section, item, ... )
	return CheckDataSection( section ).Inc( item, vargv.len() > 0 ? vargv[ 0 ] : 1 );

function DecData ( section, item, ... )
	return CheckDataSection( section ).Dec( item, vargv.len() > 0 ? vargv[ 0 ] : 1 );

function GetData ( section, item )
	return CheckDataSection( section ).Get( item );

function DelData ( section, item )
	return CheckDataSection( section ).Del( item );

function AddData ( section, item, data )
	return CheckDataSection( section ).Add( item, data );

function CheckDataSection ( section )
{
	if ( !Data_Chunks.rawin( section ) )
	{
		Data_Chunks.rawset( section, WindData( section ) );
	}
	return Data_Chunks.rawget( section );
}

// Table where hashtable data is stored
Data_Chunks		<- {};

class WindData
{
	constructor ( name )
	{
		local findhash = ::FindHashTable( name );
		Name = name;
		LastSaved = ::GameTimerTicks;
		UnsavedNum = 0;
		if ( findhash ) Hash = findhash;
		else
		{
			Hash = ::HashTable( Name );
			Load();
		}
	}

	function Add ( item, data )
	{
		local result = Hash.Add( item.tostring(), data );
		Changed();
		return result ? data : false;
	}

	function Del ( item )
	{
		local result = Hash.Del( item.tostring() );
		Changed();
		return result;
	}

	function Inc ( item, amount )
	{
		item = item.tostring();
		local result = Hash.Inc( item, amount );
		Changed();
		return result != null ? Hash.Get( item ) : false;
	}

	function Dec ( item, amount )
	{
		item = item.tostring();
		local result = Hash.Dec( item, amount );
		if ( result <= 0 ) Hash.Add( item, 0 );
		Changed();
		return result != null ? Hash.Get( item ) : false;
	}

	function Changed ()
	{
		UnsavedNum++;
		Check();
		return 1;
	}

	function Get ( item )
		return Hash.Get( item.tostring() );

	function Save ()
	{
		if ( UnsavedNum )
		{
			local result = Hash.Save( cScript_Dir +"Hashes/"+ Name +".hsh" );
			if ( result ) debug( "[HASH:"+ Name +"] Saved" );
			else debug( "HASH:"+ Name +"] Error while saving" );
			LastSaved = GameTimerTicks;
			UnsavedNum = 0;
			return 1;
		}
		else return 0;
	}

	function Load ()
	{
		Hash.Load( cScript_Dir +"Hashes/"+ Name +".hsh" );
		debug( "[HASH:"+ Name +"] Loaded" );
		LastSaved = GameTimerTicks;
		UnsavedNum = 0;
		return 1;
	}

	function Unload ()
	{
		Save();
		Hash.Close();
		debug( "[HASH:"+ Name +"] Unloaded" );
		Data_Chunks.rawdelete( Name );
		return 1;
	}

	function Check ()
	{
		local dtime = GameTimerTicks - LastSaved;
		if ( UnsavedNum > 0 && ( UnsavedNum > 19 || dtime > 600000 ))
			return Save();
		else if ( UnsavedNum == 0 && dtime > 900000 )
			return Unload();
	}

	// Some properties
	Name = null;
	Hash = null;
	LastSaved	= 0;
	UnsavedNum	= 0;
}

function SyncData ()
{
	foreach ( key, data in Data_Chunks )
		data.Check();
	return 1;
}

function UnloadData ()
{
	foreach ( key, data in Data_Chunks )
		data.Unload();
	return 1;
}
