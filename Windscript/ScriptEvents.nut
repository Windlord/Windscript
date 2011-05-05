/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/

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