![Windscript](http://img.windlord.net/windscript.png)

# NOTE: Windscript is still in development. Use at own risk!!!

# Contents

1. What is Windscript?
2. Mutual Agreement
3. Script Installation
4. Some extra information
5. Support
6. Credits
7. Frequently Asked Questions


## 1. What is Windscript?

Windscript is a collection of tools which forms a solid base for any server
scripter to work on for quick game-mode production for the GTA3 Multipleyer
Modification, Liberty Unleashed (<http://liberty-unleashed.co.uk/>). Windscript comes with several advanced features.
The main ones are listed here:

* Safe and automatic syncing of data between memory and HDD which minimises usage of resources by keeping track of changes.
* Persistent IRC echo connections which never die unless your network does.
* Useful administration tools such as IPInfo and E-Mail sending.
* Plugin support which allows one to build on Windscript without editing of the original scripts.
* Seamless reloading of main script without reloading IRC echo connections.
* Unique and simple configuration file which allows for custom config storage.

Windscript was developed slowly for a period of up to two years and is a culmination
of many of the author's experiences with scripting for GTA:MP modifications.


## 2. Mutual Agreement

Although this script package is not directly including any sort of license,
the mutual agreement which I wish all users of Windscript to abide by is as
follows:-

1. Windscript is provided as-is and comes with no warranty. There is no minimum	service period and updates for Windscript may be stopped at any time.
2. No one shall re-use Windscript for commercial purposes
3. Any modifications to Windscript must abide to the rules of the environment in which the script package is being used. (LU itself and the server where Windscript is running)
4. Windscript should never be used with evil intent such as purposely discomforting others or attacking others. (Spamming, bullying)
5. When using Windscript or a script based off Windscript, you will always provide the appropriate credits for the script writer. (See 6. Credits)
6. You shall not demand for new features or fixes, nor will you attack the author but will courteously approach and request for changes to be made, or actions taken.


## 3. Script Installaion

If you have not already,

[![Liberty Unleashed](http://lu.windlord.net/luclient.png)](http://lu.windlord.net/luclient.png)

1. [Download] the latest copy of Windscript.
2. Move the folders into the `Scripts` folder.
3. Add `<script folder="Windscript_Loader"/>` to `LU/content.xml` and `VU/content.xml`.
4. Copy `CONFIG_DEFAULT.txt` over to `Scripts/Windscript/CONFIG.txt` and edit accordingly.

*Note: It is recommended that you run Windscript alone as a server-side script.*


## 4. Some extra information

Windscript is not for the faint hearted or the newly born. The scripts
written in this package can be very complicated. The structure of the scripts
is unusual and therefore I would not advise the scripting novice to try out
Windscript. I shall not be offering to coach you on scripting and will not be
very happy if asked to teach you in person. If you feel that Windscript is too
complicated or difficult to use and edit, take a look at Force's Beginner Script
(FBS) first and get used to using the various squirrel language features. To
aid the more experienced scripters however, I have tried to provide as much
comments as possible inside of my scripts. Please do not ignore them.


## 5. Support

There are a few ways you can obtain help for Windscript

1.  Windscript Github Pages (Files, README, Wiki) - <https://github.com/Windlord/Windscript>
2.  Liberty Unleashed Forums - <http://forum.liberty-unleashed.co.uk/>
3.  Liberty Unleashed Wiki - <http://liberty-unleashed.co.uk/LUWiki>
4.  LUnet IRC Network - irc://irc.liberty-unleashed.co.uk/Windlord
5.  GTAnet IRC Network - irc://irc.gtanet.com/Windlord
6.  E-mail - <windlord@windlord.net> *refrain from contacting unless urgent*


## 6. Credits

Every single line of script written in this script package has been written by:

### Windlord (<windlord@windlord.net>)

I would like to thank the following people for their valuable help:

* ozzie - Introducing me to the idea of seamless script-reloading
* Juppi - Providing support for usage of embedded functions
* Force - Providing FBS, an excellent starter script for me to refer to.


## 7. Frequently Asked Questions

### 1. Why do you have two folders?
This is to allow for the seamless reloading. Only Windscript_Loader is loaded to
when your LU server starts. After Windscript_Loader is loaded, Windscript is
loaded, then the IRC bots created. This allows for one to UnloadScript and LoadScript
Windscript from Windscript_Loader.

### 2. My bots are not joining the echo channel.
Your bots will only join the channels once it has logged in.
If you don't see the bots joining, uncomment the raw output line
from the function, onIRCData( socket, raw ) in Echo.nut to identify the problem.

Once you have found out why the bots are not logging in, use
"irc echobot_name irc_raw_command" in the console to control the
bot directly and solve your issue.


[Download]:	https://github.com/Windlord/Windscript/zipball/master	"Windscript Source"
