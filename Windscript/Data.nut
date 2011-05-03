/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function IncData ( section, item, inc = 1 )
	return CheckDataSection( section ).Inc( item, inc );

function DecData ( section, item, dec = 1 )
	return CheckDataSection( section ).Dec( item, dec );

function GetData ( section, item )
	return CheckDataSection( section ).Get( item );

function DelData ( section, item )
	return CheckDataSection( section ).Del( item );

function AddData ( section, item, data )
	return CheckDataSection( section ).Add( item, data );

function CheckDataSection ( section )
{
	if ( !Data_Chunks.rawin( section ) )
		Data_Chunks.rawset( section, WindData( section ) );
	return Data_Chunks.rawget( section );
}

// Table where hashtable data is stored
Data_Chunks <- {};

class WindData
{
	constructor ( name )
	{
		Name = name;
		fName = cScript_Dir +"Hashes/"+ Name +".hsh";
		LastSaved = ::GameTimerTicks;
		GetHash();
	}

	function GetHash ()
	{
		local findhash = ::FindHashTable( Name );
		if ( typeof( findhash ) == "HashTable" )
		{
			Hash = findhash;
			debug( "Found Hash Table. Loading." );
			Load();
		}
		else if ( findhash ) debug( "Oh noes, FindHashTable is being a woman and spitting out strings" );
		else
		{
			Hash = ::HashTable( Name );
			Load();
		}
	}

	function Add ( item, data )
	{
		local result = Hash.Add( item.tostring(), data );
		if ( result == false )
		{
			GetHash();
			result = Hash.Add( item.tostring(), data );
		}
		Changed();
		return result ? data : false;
	}

	function Del ( item )
	{
		local result = Hash.Del( item.tostring() );
		if ( result == false )
		{
			GetHash();
			result = Hash.Del( item.tostring() );
		}
		Changed();
		return result;
	}

	function Inc ( item, amount )
	{
		item = item.tostring();
		local result = Hash.Inc( item, amount );
		if ( result == false )
		{
			GetHash();
			result = Hash.Inc( item, amount );
		}
		Changed();
		return result != null ? Hash.Get( item ) : false;
	}

	function Dec ( item, amount )
	{
		item = item.tostring();
		Hash.Dec( item, amount );
		local result = Hash.Get( item );
		if ( result == false )
		{
			GetHash();
			result = Hash.Get( item );
		}
		if ( result.tointeger() < 0 )
		{
			Hash.Add( item, 0 );
			return 0;
		}
		Changed();
		return result;
	}

	function Changed ()
	{
		UnsavedNum++;
		Check();
		return 1;
	}

	function Get ( item )
	{
		item = item.tostring();
		local data = Hash.Get( item );
		if ( data == false )
		{
			GetHash();
			data = Hash.Get( item )
		}
		return data ? data : 0;
	}

	function Save ()
	{
		if ( UnsavedNum )
		{
			local result = Hash.Save( fName );
			if ( !result ) 
			{
				debug( "Error while saving to "+ fName );
				return false;
			}
			debug( "Saved to "+ fName );
			LastSaved = ::GameTimerTicks;
			UnsavedNum = 0;
			return true;
		}
		else return false;
	}

	function Load ()
	{
		local result = Hash.Load( fName );
		if ( !result )
		{
			debug( "Hash file does not exist: "+ fName );
			debug( "File will be made on next save." );
		}
		else debug( "Loaded "+ fName +". Ready." );
		LastSaved = ::GameTimerTicks;
		return true;
	}

	function Unload ()
	{
		if ( Save() )
		{
			Hash.Close();
			debug( "Unloaded" );
			Data_Chunks.rawdelete( Name );
			return true;
		}
		else debug( "Aborting unload due to save failure" );
	}

	function Check ()
	{
		local dtime = ::GameTimerTicks - LastSaved;
		if ( UnsavedNum > 0 && ( UnsavedNum > 19 || dtime > 600000 ))
			return Save();
		else if ( UnsavedNum == 0 && dtime > 900000 )
			return Unload();
	}

	function debug ( msg )
		::debug ( "[HASH:"+ Name +"] "+ msg );

	// Some properties
	Name = null;
	Hash = null;
	fName = "";
	LastSaved = 0;
	UnsavedNum = 0;
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
