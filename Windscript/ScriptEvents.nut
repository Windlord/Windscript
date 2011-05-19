/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

function onUserJoin ( user )
{
	user.Joins++;
	user.JoinTime = time();
	user.LoggedIn = 0;
	user.Spree = 0;

	if ( user.LastIP == user.Player.IP )					// If current IP equals last used IP
		user.Login( "", true );
	if ( user.Registered && !user.LoggedIn )
		AdminPM( "This nickname is registered. Please login using /login.", user );

	UpdateIPInfo( user );
	PluginEvent( onUserJoin, user );
	return 1;
}

function onUserPart ( user, reason )
{
	if ( user.JoinTime )
	{
		user.Uptime = time() - user.JoinTime;
		user.JoinTime = 0;
	}

	PluginEvent( onUserPart, user, reason );
	return 1;
}

function onUserRegister ( user, num )
{
	AdminPM( "You have successfully registered!", user );
	AdminPM( "Do you know that you are the "+ ToThousands( GetNth( num ) ) +" registered user?", user );
	Echo( iCol( 2, ":: "+ user.Name +" has registered an account" ) );
	PluginEvent( onUserRegister, user );
	return 1;
}

function onUserChangePass ( user )
{
	AdminPM( "Your password has been successfully changed.", user );
	PluginEvent( onUserChangePass, user );
	return 1;
}

function onUserLogin ( user, autologin = false )
{
	if ( autologin )
	{
		AdminPM( "Auto-logged in successfully", user );
		Echo( iCol( 6, ":: "+ user.Player +" has auto-logged in" ) );
	}
	else
	{
		AdminPM( "Logged in successfully", user );
		Echo( iCol( 6, ":: "+ user.Player +" has logged in" ) );
	}
	if ( user.LastLogin )
		AdminPM( "Last Logged in "+ TimeDiff( user.LastLogin ), user );
	user.LastLogin = time();
	user.LastIP = user.Player.IP;
	PluginEvent( onUserLogin, user );
	return 1;
}

function onUserDeath ( user, reason )
{
	user.Death++;

	PluginEvent( onUserDeath, user, reason );
	return 1;
}

function onUserKill ( user, killed, weapon, bodypart )
{
	kuser.Kills++;
	user.Death++;
	local lostbp = kuser.Inc( "LostBodypart"+ bodypart );
	local killedby = kuser.Inc( "KilledBy"+ weapon );
	local hitbp = user.Inc( "HitBodypart"+ bodypart );
	local killedwith = user.Inc( "KilledWith"+ weapon );

	if ( RandNum( 2 ) == 1 ) AdminPM( "You've been hit in the "+ bodypart +" "+ lostbp +" times!", killed );
	else AdminPM( "You've been killed by a "+ weapon +" for the "+ GetNth( killedby ) +" time!", killed );

	if ( RandNum( 2 ) == 1 ) AdminPM( "Registered "+ killedwith +" kills with your trusty "+ weapon +".", user );
	else AdminPM( "That's the "+ GetNth( hitbp ) +" "+ bodypart +" you've hit so far!", user );

	PluginEvent( onUserKill, user, killed, weapon, bodypart );
	return 1;
}