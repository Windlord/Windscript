/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 by Windlord	*/


// This initiates a timer which runs the Background function every half a second.
// A single timer is used in this script to increase efficiency and performance.
// The main reason a single timer is used is because having multiple timers will stress the server.

// The reason the code is messy is because I deemed this to be the more efficient way of doing things
// I could have easily calculated modulii (%) repeatedly but dividing repeatedly is more efficient.

function StartBackground()
{
	GameTimer <- NewTimer ( "Background", 500, 0 );
	ReloadPlayers();
}
local GameTimerNum = 0.0;

GameTimerTicks <- GetTickCount();


function Background ()
{
	// Every time this function is called, the number in GameTimerNum is increased.
	// This is done so that we can know how much time has passed.
	GameTimerNum++;
	GameTimerTicks = GetTickCount();

	// The following is an interesting part of Windscript.
	// We check if GameTimerNum is divisible by 2. If it is divisible by 2, a second has passed.
	// This means that the following chunk of code will be processed every second.
	// EXECUTED: EVERY 1 SECOND.
	local tempcalc = GameTimerNum / 2;
	if ( IsDivided( tempcalc ) )
	{
		BackgroundOneSecond();

		// EXECUTED: EVERY 2 SECONDS.
		tempcalc = tempcalc / 2;
		if ( IsDivided( tempcalc ) )
		{
			BackgroundTwoSeconds();

			// EXECUTED: EVERY 10 SECONDS.
			tempcalc = tempcalc / 5;
			if ( IsDivided( tempcalc ) )
			{
				BackgroundTenSeconds();

				// EXECUTED: EVERY 20 SECONDS.
				tempcalc = tempcalc / 2;
				if ( IsDivided( tempcalc ) )
				{
					BackgroundTwentySeconds();

					// EXECUTED: EVERY 30 SECONDS.
					if ( IsDivided( tempcalc / 2 ) )
					{
						BackgroundThirtySeconds();
					}

					// EXECUTED: EVERY MINUTE.
					tempcalc = tempcalc / 3;
					if ( IsDivided( tempcalc ) )
					{
						BackgroundOneMinute();

						// EXECUTED: EVERY 5 MINUTES.
						tempcalc = tempcalc / 5;
						if ( IsDivided( tempcalc ) )
						{
							BackgroundFiveMinutes();
						}
					}
				}
			}
		}
	}
}


function IsDivided ( num )
	return ( num == num.tointeger() ) ? true : false;


// EXECUTED: EVERY 1 SECONDS.
function BackgroundOneSecond ()
{
	PluginEvent( BackgroundOneSecond );
}

// EXECUTED: EVERY 2 SECONDS.
function BackgroundTwoSeconds ()
{
	PluginEvent( BackgroundTwoSeconds );
}

// EXECUTED: EVERY 10 SECONDS.
function BackgroundTenSeconds ()
{
	PluginEvent( BackgroundTenSeconds );
}

// EXECUTED: EVERY 20 SECONDS.
function BackgroundTwentySeconds ()
{
	PluginEvent( BackgroundTwentySeconds );
}

function BackgroundThirtySeconds ()
{
	SyncData();
	PluginEvent( BackgroundThirtySeconds );
}

// EXECUTED: EVERY 1 MINUTE.
function BackgroundOneMinute ()
{
	PluginEvent( BackgroundOneMinute );
}

// EXECUTED: EVERY 5 MINUTES.
function BackgroundFiveMinutes ()
{
	UpdateUptime();
	PluginEvent( BackgroundFiveMinutes );
}