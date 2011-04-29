/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


function ParseConfig ()
{
	local raw = split( config_file.Stream, "\r\n" );			// Split string chunk into lines
	local lines = raw.len(), line, linelen, li, chr, key, data, strtrig, is_str;
	for ( local i = 0; i < lines ; i++ )					// Iterate through lines
	{
		line = raw[ i ]; linelen = line.len();
		key = ""; data = ""; strtrig = false; is_str = false;
		for ( li = 0; li < linelen; li++ )				// Iterate through characters in line
		{
			chr = line[ li ];
			if ( chr == '\t' || chr == ' ' )
			{
				if ( li == 0 ) break;				// Ignore line if starts with whitespace
				if ( key == "" ) key = line.slice( 0, li );	// If first whitespace since start of line, must be end of key
				else if ( strtrig && key > "" ) data += chr.tochar();
			}							// Keeps whitespace for strings enclosed in ""
			else if ( chr == '"' )					// Enclosing strings in " is optional
			{
				if ( key > "" )
				{
					is_str = true;				// data enclosed in "" is definitely a string
					strtrig = !strtrig;
				}
			}
			else if ( chr == '#' )
			{
				if ( !strtrig ) break;				// Ignore as comment if not part of string
				else if ( key > "" ) data += chr.tochar();	// If part of string, include as data
			}
			else if ( key > "" ) data += chr.tochar();		// Include everything else as data
		}

		if (key > "" && data > "")					// If both key and data values exist
		{
			switch ( data )
			{
				case "true":
				case "True":
					data = true;				// Boolean true detection
					break;
				case "false":
				case "False":
					data = false;				// Boolean false detection
					break;
				default:					// By default deal as string unless number
					if ( !is_str && IsNum(data) ) data = data.tointeger();
					break;
			}
			config.rawset( key, data );				// Set key in the table 'config'
		}
	}
}

// This class deals with writing to files
// When a class is created, the file is either created with read access or write access.
// With read access the second param is 'r' and the file is created if not existing.
// With write access the second param is 'w' and the file needs to exist.
class FileIO
{
	constructor ( filen, type )
	{
		switch ( type )
		{
			case 'w':
				File = file ( cScript_Dir + filen, "r+" );	// Open filestream with read/write access
				break;
			case 'r':
				File = file ( cScript_Dir + filen, "a+" );	// Open filestream with read/append access
				break;
		}
		local i, c, s = "", l = File.len();
		for ( i = 0; i < l; i++ )
		{
			if ( File.eos() ) break;				// End loop if pointer has reached the end of the file
			c = File.readn( 'b' );					// Read an integer at the pointer's position
			s += c.tochar();					// Convert integer to character and append to string
		}
		Stream = s;
	}
	File = null;
	Stream = null;

	function Write ()							// This function writes the edited Stream to file
	{									// This does NOT append to file and does not have any params
		File.seek( 0 );							// Set pointer to start of file
		File.flush();							// Remove all data
		local i, z = Stream.len(), c;
		for ( i = 0; i < z; i++ )
		{
			c = Stream[ i ];
			File.writen( c, 'b' );					// Write to file char by char
		}
	}
	function Append ()
	{
		File.seek( File.len() );
		local i, z = Stream.len(), c;
		for ( i = 0; i < z; i++ )
		{
			c = Stream[ i ];
			File.writen( c, 'b' );
		}
	}
}

{
	config_file <- FileIO( "CONFIG.txt", 'w' );
	config <- {};
	ParseConfig();
}