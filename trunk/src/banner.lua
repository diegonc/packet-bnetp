--[[ packet-bnetp.lua build on %time%

packet-bnetp is a Wireshark plugin written in Lua for dissecting the Battle.net® protocol. 
Homepage: http://code.google.com/p/packet-bnetp/
Download: http://code.google.com/p/packet-bnetp/downloads/list
Latest version from SVN: http://packet-bnetp.googlecode.com/svn/trunk/src/packet-bnetp.lua

How to install?
1. Install Wireshark. If during setup Lua appears as a plugin, enable it. 
2. Download packet-bnetp and unpack it to wireshark installation directory. If you want, you may place it anywhere else provided you give the full path to dofile in the next step. 
3. Open init.lua located at Wireshark installation directory and replace 

-- Lua is disabled by default, comment out the following line to enable Lua support.
disable_lua = true; do return end;

with 

-- Lua is disabled by default, comment out the following line to enable Lua support.
-- disable_lua = true; do return end;

Then insert 

dofile("packet-bnetp.lua")

at the end of the file.
--------------------------------------------------------------------------------]]

