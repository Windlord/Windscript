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
	UpdateIPInfo( user );
	user.Joins++;
	user.JoinTime = time();
	user.LoggedIn = 0;
	user.Spree = 0;
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
	AdminPM( "You have successfully registered!", user.Player );
	AdminPM( "Do you know that you are the "+ ToThousands( GetNth( num ) ) +" registered user?", user.Player );
	Echo( iCol( 2, ":: "+ user.Name +" has registered an account" ) );
	PluginEvent( onUserRegister, user );
	return 1;
}

function onUserChangePass ( user )
{
	AdminPM( "Your password has been successfully changed.", user.Player );
	PluginEvent( onUserChangePass, user );
	return 1;
}

function onUserLogin ( user, lastlogin )
{
	AdminPM( "Logged in successfully", user.Player );
	if ( lastlogin )
		AdminPM( "Last Logged in "+ Duration( ( time() - lastlogin ) ) +" ago.", user.Player );
	Echo( iCol( 6, ":: "+ user.Player.Name +" has logged in" ) );
	PluginEvent( onUserLogin, user, lastlogin );
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

	if ( RandNum( 2 ) == 1 ) AdminPM( "You've been hit in the "+ bodypart +" "+ lostbp +" times!", killed.Player );
	else AdminPM( "You've been killed by a "+ weapon +" for the "+ GetNth( killedby ) +" time!", killed.Player );

	if ( RandNum( 2 ) == 1 ) AdminPM( "Registered "+ killedwith +" kills with your trusty "+ weapon +".", user.Player );
	else AdminPM( "That's the "+ GetNth( hitbp ) +" "+ bodypart +" you've hit so far!", user.Player );

	PluginEvent( onUserKill, user, killed, weapon, bodypart );
	return 1;
}