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

function CheckDataSection ( section, keeploaded = false )
{
	if ( !Data.rawin( section ) )
		Data.rawset( section, WindData( section, keeploaded ) );
	return Data.rawget( section );
}

// Table where hashtable data is stored
Data <- {};

class WindData
{
	constructor ( name, keeploaded )
	{
		Name = name;
		fName = cScript_Dir +"Hashes/"+ Name +".hsh";
		LastSaved = time();
		UnsavedNum = 0;
		keepLoaded = keeploaded;
		local findhash = ::FindHashTable( Name );
		if ( findhash ) Hash = findhash;
		else Hash = ::HashTable( Name );
		Load();
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
		Hash.Dec( item, amount );
		local result = Hash.Get( item );
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
		return data ? data : 0;
	}

	function Save ()
	{
		if ( UnsavedNum > 0 )
		{
			local result = Hash.Save( fName );
			if ( !result ) 
			{
				debug( "Error while saving to "+ fName );
				return false;
			}
			debug( "Saved to "+ fName );
			LastSaved = time();
			UnsavedNum = 0;
			return true;
		}
		else return true;
	}

	function Load ()
	{
		local result = Hash.Load( fName );
		if ( result ) debug( "Loaded "+ fName +". Ready." );
		else debug( fName +" will be created on next save." );
		return true;
	}

	function Unload ()
	{
		if ( Save() )
		{
			if ( keepLoaded ) return false;
			Hash.Close();
			debug( "Unloaded" );
			Data.rawdelete( Name );
			return true;
		}
		else debug( "Aborting unload due to save failure" );
	}

	function Check ()
	{
		local dtime = time() - LastSaved;
		if ( UnsavedNum > 0 && ( UnsavedNum > 19 || dtime > 600 ))
			return Save();
		else if ( UnsavedNum == 0 && dtime > 900 )
			return Unload();
	}

	function debug ( msg )
		::debug ( "[HASH:"+ Name +"] "+ msg );

	// Some properties
	Name = null;
	Hash = null;
	keepLoaded = false;
	fName = "";
	LastSaved = 0;
	UnsavedNum = 0;
}

function SyncData ()
{
	foreach ( key, data in Data )
		data.Check();
	return 1;
}

function UnloadData ()
{
	foreach ( key, data in Data )
		data.Unload();
	return 1;
}
