## News

* _March 2015_: The plugin was updated to make it work on newer versions of Wireshark. More testing needs to be done specially in previous versions (to make sure it still works on them)
* _February 2011_: Now the plugin supports W3GS (Warcraft 3 game protocol).

## What is this?

_packet-bnetp_ is a Wireshark plugin written in Lua for dissecting the Battle.net® client-server protocol, which is used by Starcraft, Warcraft 2 Battle.Net edition, Warcraft 3, Diablo 1, Diablo 2, and Warcraft 3 game protocol.

Feel free to give feedback!

## Requirements

_packet-bnetp_ was tested with Wireshark 1.10.5, which is Windows XP compatible. Older versions with Lua 5.1 may work too, newer should work too.

## How to install?

Download [packet-bnetp](https://github.com/diegonc/packet-bnetp/releases).

Place the file `packet-bnetp.lua` in one of the directories in the Lua search path. Wireshark will then load it automatically during startup.

**UNIX**

  * /usr/share/wireshark/plugins/foo.lua (global)
  * $HOME/.wireshark/plugins/foo.lua (user-specific)

**Windows**

  * %PROGRAMFILES%\Wireshark\plugins\%WIRESHARK\_VERSION%\foo.lua (global)
  * %APPDATA%\Wireshark\plugins\foo.lua (user-specific)

## Screenshots
Click on images to enlarge.

[![](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/thumbs/bnetp_0x0f_channel_flags.jpg)](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/bnetp_0x0f_channel_flags.png)
[![](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/thumbs/bnetp_0x0f_user_flags.jpg)](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/bnetp_0x0f_user_flags.png)
[![](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/thumbs/bnetp_0x50.jpg)](https://github.com/diegonc/packet-bnetp/blob/master/screenshots/bnetp_0x50.png)

## Understanding protocol
Here is [the protocol documentation](http://bnetdocs.org/) which was used for creating packet-bnetp.
