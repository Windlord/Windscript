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
	return 1;
}

function onUserLogin ( user, lastlogin )
{
	AdminPM( "Logged in successfully", player );
	if ( lastlogin )
		AdminPM( "Last Logged in "+ Duration( ( GetTime() - lastlogin ) * 1000 ) +" ago.", player );
	return 1;
}