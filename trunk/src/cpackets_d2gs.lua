-- Begin cpackets_d2gs.lua
--[[doc
    Message ID:    0x01

    Message Name:  D2GS_WALKTOLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Walk to a specified (X,Y) map coordinate.

    Related:       [0x03] D2GS_RUNTOLOCATION (C->S)

]]
[D2GS_WALKTOLOCATION] = { -- 0x01
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x02

    Message Name:  D2GS_WALKTOENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Makes your character walk to the Entity specified in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x04] D2GS_RUNTOENTITY (C->S)

]]
[D2GS_WALKTOENTITY] = { -- 0x02
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x03

    Message Name:  D2GS_RUNTOLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Run to a specified (X,Y) map coordinate.

    Related:       [0x01] D2GS_WALKTOLOCATION (C->S)

]]
[D2GS_RUNTOLOCATION] = { -- 0x03
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x04

    Message Name:  D2GS_RUNTOENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Makes your character run to the Entity specified in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x02] D2GS_WALKTOENTITY (C->S)

]]
[D2GS_RUNTOENTITY] = { -- 0x04
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x05

    Message Name:  D2GS_LEFTSKILLONLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses Left skill on specified (X,Y) map coordinate.

    Related:       [0x08] D2GS_LEFTSKILLONLOCATIONEX (C->S)

]]
[D2GS_LEFTSKILLONLOCATION] = { -- 0x05
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x06

    Message Name:  D2GS_LEFTSKILLONENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specefied in Entity ID.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITY] = { -- 0x06
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x07

    Message Name:  D2GS_LEFTSKILLONENTITYEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

    Remarks:       Uses your left skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   Entity types
                   ---------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX] = { -- 0x07
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x08

    Message Name:  D2GS_LEFTSKILLONLOCATIONEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses Left skill on specified (X,Y) map coordinate.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x05] D2GS_LEFTSKILLONLOCATION (C->S)

]]
[D2GS_LEFTSKILLONLOCATIONEX] = { -- 0x08
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x09

    Message Name:  D2GS_LEFTSKILLONENTITYEX2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specified in Entity ID.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x0A] D2GS_LEFTSKILLONENTITYEX3 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX2] = { -- 0x09
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0A

    Message Name:  D2GS_LEFTSKILLONENTITYEX3

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) *Entity Type
                   (DWORD) Entity ID

                   *Entity Types
                   -------------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your left skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Refer to the D2GS Entity Types document for more information.

    Related:       [0x06] D2GS_LEFTSKILLONENTITY (C->S),
                   [0x07] D2GS_LEFTSKILLONENTITYEX (C->S),
                   [0x09] D2GS_LEFTSKILLONENTITYEX2 (C->S)

]]
[D2GS_LEFTSKILLONENTITYEX3] = { -- 0x0A
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0C

    Message Name:  D2GS_RIGHTSKILLONLOCATION

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses the currently selected skill at the specified location.

                   This packet is sent when the location is first clicked with the mouse.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0F] D2GS_RIGHTSKILLONLOCATIONEX (C->S)

]]
[D2GS_RIGHTSKILLONLOCATION] = { -- 0x0C
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x0D

    Message Name:  D2GS_RIGHTSKILLONENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID

                   Refer to the D2GS Entity Types document for more information about
                   Entities

    Related:       [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S)

]]
[D2GS_RIGHTSKILLONENTITY] = { -- 0x0D
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0E

    Message Name:  D2GS_RIGHTSKILLONENTITYEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S),
                   [0x11] D2GS_RIGHTSKILLONENTITYEX3 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX] = { -- 0x0E
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x0F

    Message Name:  D2GS_RIGHTSKILLONLOCATIONEX

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) X coordinate
                   (WORD) Y coordinate

    Remarks:       Uses the currently selected skill at the specified location.

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0C] D2GS_RIGHTSKILLONLOCATION (C->S)

]]
[D2GS_RIGHTSKILLONLOCATIONEX] = { -- 0x0F
	uint16("X coordinate"),
	uint16("Y coordinate"),
},
--[[doc
    Message ID:    0x10

    Message Name:  D2GS_RIGHTSKILLONENTITYEX2

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill repeatedly on the Entity specefied in Entity ID.
                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x11] D2GS_RIGHTSKILLONENTITYEX3 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX2] = { -- 0x10
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x11

    Message Name:  D2GS_RIGHTSKILLONENTITYEX3

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity Types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Uses your right skill on the Entity specefied in Entity ID, while
                   holding the hotkey for standing still(shift).

                   This packet is sent repeatedly when the mouse button is held down
                   after the initial packet has been sent.

    Related:       [0x0D] D2GS_RIGHTSKILLONENTITY (C->S),
                   [0x10] D2GS_RIGHTSKILLONENTITYEX2 (C->S)

]]
[D2GS_RIGHTSKILLONENTITYEX3] = { -- 0x11
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x13

    Message Name:  D2GS_INTERACTWITHENTITY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Interacts with the specified Entity.
                   For players and npc's, it will send a request to interact.
                   The interaction depends on the type of the unit or object.
                   For others it will trigger the object, for example using a shrine,
                   looting a corpse you have permission to loot, or opening and closing a
                   door.

                   This packet is always followed by other's that relate to the type of
                   interaction.

]]
[D2GS_INTERACTWITHENTITY] = { -- 0x13
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x14

    Message Name:  D2GS_OVERHEADMESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Unknown - 0x00, 0x00
                   (STRING) Message
                   (BYTE) Unused - 0x00
                   (WORD) Unknown - 0x00, 0x00

    Remarks:       This message is used when you'd like to put a message above a
                   character's head as used in the client as "![message]".

                   Restrictions: Total size of packet cannot be greater than 275 bytes.
                   Message cannot be greater than 255 bytes.

                   Please note: This message's official name is not known, and has been
                   invented.

                   Extra Info: The status of this information is: Public Colors can be
                   created by adding hex FF 63 and a character 30 to 3C.

                   Example:
                   To make red, use FF 63 31.

]]
[D2GS_OVERHEADMESSAGE] = { -- 0x14
	uint16("Unknown (0)"),
	stringz("Message"),
	uint8("Unused (0)"),
	uint16("Unknown (0)"),
},
--[[doc
    Message ID:    0x15

    Message Name:  D2GS_CHATMESSAGE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Message Type
                   (BYTE) Unknown
                   (STRING) Message
                   (BYTE) Unknown
                   *(WORD) Unknown - Only if normal chat
                   **(STRING) Player to whisper to - Only if whispering
                   **(BYTE) Unknown - Only if whispering

    Remarks:       Sends a chat message in the game.

                   Possible Message Types:
                   0x01 - Send to all
                   0x02 - Whisper

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_CHATMESSAGE] = { -- 0x15
	uint8("Message Type"),
	uint8("Unknown"),
	stringz("Message"),
	uint8("Unknown"),
	uint16("Unknown - Only if normal chat"),
	stringz("Player to whisper to - Only if whispering"),
	uint8("Unknown - Only if whispering"),
},
--[[doc
    Message ID:    0x16

    Message Name:  D2GS_PICKUPITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Unit Type
                   (DWORD) Unit ID
                   (DWORD) Action ID

    Remarks:       Pick up a ground item to cursor buffer/inventory.

                   Possible action IDs:
                   0x00 - Move item to inventory
                   0x01 - Move item to cursor buffer

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x13] D2GS_INTERACTWITHENTITY (C->S)

]]
[D2GS_PICKUPITEM] = { -- 0x16
	uint32("Unit Type"),
	uint32("Unit ID"),
	uint32("Action ID"),
},
--[[doc
    Message ID:    0x17

    Message Name:  D2GS_DROPITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Drops the item in the player's cursor buffer to the ground.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_DROPITEM] = { -- 0x17
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x18

    Message Name:  D2GS_ITEMTOBUFFER

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) X coordinate
                   (DWORD) Y coordinate
                   (DWORD) Buffer Type

                   Possible Buffer Types:
                   0x00 - Character's inventory (backpack)
                   0x01 - NPC and other Trade Windows
                   0x02 - Trade window
                   0x03 - Horadric Cube
                   0x04 - Stash

    Remarks:       Moves item from the player's cursor buffer to an inventory space.

                   Please note: This message's official name is not known, and has been
                   invented.

                   Inventory coordinates:
                   (0,0) - Top left
                   (9,3) - Bottom right

]]
[D2GS_ITEMTOBUFFER] = { -- 0x18
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
	uint32("Buffer Type"),
},
--[[doc
    Message ID:    0x19

    Message Name:  D2GS_PICKUPBUFFERITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Pickup an item from the possible buffers below, moving it to the
                   cursor buffer.

                   Possible Buffers:
                   0 - Inventory
                   1 - NPC Trade & Other player's Trade Window?
                   2 - Trade Screen
                   3 - Horadric Cube
                   4 - Stash

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_PICKUPBUFFERITEM] = { -- 0x19
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x1A

    Message Name:  D2GS_ITEMTOBODY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Body Location

    Remarks:       Moves item from player's cursor buffer to body location. Body
                   locations are identified by the line number in the data file
                   bodylocs.txt.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

                   These values have been recorded for mercenary body locations, but
                   aren't confirmed: (Note, each location ID is prefixed with 0x61)
                   Example: 1A 64 00 00 00 61 02 00 00 (Move item 0x64 to Mercenary
                   Right-hand weapon)

                   0x01 - Mercenary Helm
                   0x02 - Mercenary Right-hand Weapon
                   0x03 - Mercenary Armor
                   0x04 - Mercenary Left-hand Weapon

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_ITEMTOBODY] = { -- 0x1A
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1B

    Message Name:  D2GS_SWAP2HANDEDITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   *(DWORD) Body Location

                   *0x04 is left hand
                   *0x05 is right hand

    Remarks:       Moves item from body location to player's cursor buffer.

                   Body locations are the same as in D2GS_ITEMTOBODY

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1A] D2GS_ITEMTOBODY (C->S)

]]
[D2GS_SWAP2HANDEDITEM] = { -- 0x1B
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1C

    Message Name:  D2GS_PICKUPBODYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Body Location

    Remarks:       Pickup an item from a Body Location to you're cursor buffer.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

]]
[D2GS_PICKUPBODYITEM] = { -- 0x1C
	uint16("Body Location"),
},
--[[doc
    Message ID:    0x1D

    Message Name:  D2GS_SWITCHBODYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Body Location

    Remarks:       Swaps item in player's cursor buffer with item in the body location.

                   Possible Body Locations:
                   0x01 - Helm
                   0x02 - Amulet
                   0x03 - Armor
                   0x04 - Left-hand weapon
                   0x05 - Right-hand weapon
                   0x06 - Left-hand ring
                   0x07 - Right-hand ring
                   0x08 - Belt
                   0x09 - Boots
                   0x0A - Gloves

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1A] D2GS_ITEMTOBODY (C->S)

]]
[D2GS_SWITCHBODYITEM] = { -- 0x1D
	uint32("Item ID"),
	uint32("Body Location"),
},
--[[doc
    Message ID:    0x1F

    Message Name:  D2GS_SWITCHINVENTORYITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Item to place in inventory (cursor buffer)
                   (DWORD) Item ID - Item to be replaced
                   (DWORD) X coordinate for replace
                   (DWORD) Y coordinate for replace

    Remarks:       Swaps the item in the player's cursor buffer with one in the player's
                   inventory. Please note:
                   This message's official name is not known, and has been invented.

]]
[D2GS_SWITCHINVENTORYITEM] = { -- 0x1F
	uint32("Item ID - Item to place in inventory"),
	uint32("Item ID - Item to be replaced"),
	uint32("X coordinate for replace"),
	uint32("Y coordinate for replace"),
},
--[[doc
    Message ID:    0x20

    Message Name:  D2GS_USEITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) X coordinate
                   (DWORD) Y coordinate

    Remarks:       Uses the specified item (such as a potion, town portal scroll, etc.).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_USEITEM] = { -- 0x20
	uint32("Item ID"),
	uint32("X coordinate"),
	uint32("Y coordinate"),
},
--[[doc
    Message ID:    0x21

    Message Name:  D2GS_STACKITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Stack item
                   (DWORD) Item ID - Target item

    Remarks:       Stacks one item such as a key onto another item.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_STACKITEM] = { -- 0x21
	uint32("Item ID - Stack item"),
	uint32("Item ID - Target item"),
},
--[[doc
    Message ID:      0x22

    Message Name:    D2GS_REMOVESTACKITEM

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Item ID

    Remarks:         Removes an item from the stack Please note: This message's official
                     name is not known, and has been invented. The contents of this packet
                     may be incomplete or incorrect, and your comments and contributions
                     are requested.

]]
[D2GS_REMOVESTACKITEM] = { -- 0x22
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x23

    Message Name:  D2GS_ITEMTOBELT

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Belt Location

    Remarks:       Moves an item into the player's belt.

                   Extra Info: The status of this information is: Public Belt locations
                   start at 0x00 and go from right to left, starting at the lowest row
                   and moving across, then going up one row. For example, location 0x03
                   would be at the bottom right hand corner and location 0x0C would be at
                   the top left corner in a 4-slot belt. This can be calculated as
                   (row*4+column).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_ITEMTOBELT] = { -- 0x23
	uint32("Item ID"),
	uint32("Belt Location"),
},
--[[doc
    Message ID:    0x24

    Message Name:  D2GS_REMOVEBELTITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID

    Remarks:       Moves the specified item from the belt to the player's cursor buffer.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_REMOVEBELTITEM] = { -- 0x24
	uint32("Item ID"),
},
--[[doc
    Message ID:    0x25

    Message Name:  D2GS_SWITCHBELTITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Cursor buffer
                   (DWORD) Item ID - Item to be replaced

    Remarks:       Replaces item in belt with item in player's cursor buffer.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SWITCHBELTITEM] = { -- 0x25
	uint32("Item ID - Cursor buffer"),
	uint32("Item ID - Item to be replaced"),
},
--[[doc
    Message ID:      0x26

    Message Name:    D2GS_USEBELTITEM

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Item ID
                     (DWORD) Unknown - Possibly unused
                     (DWORD) Unknown - Possibly unused

    Remarks:         Uses the specified item in the player's belt.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_USEBELTITEM] = { -- 0x26
	uint32("Item ID"),
	uint32("Unknown - Possibly unused"),
	uint32("Unknown - Possibly unused"),
},
--[[doc
    Message ID:    0x28

    Message Name:  D2GS_INSERTSOCKETITEM

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Item to place in socket
                   (DWORD) Item ID - Socketed item

    Remarks:       Inserts the specified item into a socketed item.

]]
[D2GS_INSERTSOCKETITEM] = { -- 0x28
	uint32("Item ID - Item to place in socket"),
	uint32("Item ID - Socketed item"),
},
--[[doc
    Message ID:    0x29

    Message Name:  D2GS_SCROLLTOTOME

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID - Scroll
                   (DWORD) Item ID - Tome

    Remarks:       Places a scroll into a tome of scrolls.

                   Note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SCROLLTOTOME] = { -- 0x29
	uint32("Item ID - Scroll"),
	uint32("Item ID - Tome"),
},
--[[doc
    Message ID:    0x2A

    Message Name:  D2GS_ITEMTOCUBE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Item ID
                   (DWORD) Cube ID

    Remarks:       Moves item from player's cursor buffer into Horadric cube.

]]
[D2GS_ITEMTOCUBE] = { -- 0x2A
	uint32("Item ID"),
	uint32("Cube ID"),
},
--[[doc
    Message ID:      0x2D

    Message Name:    D2GS_UNSELECTOBJ

    Message Status:  DEFUNCT

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          blank

    Remarks:         Unselects the selected object. Please note: This message's official
                     name is not known, and has been invented. The contents of this packet
                     may be incomplete or incorrect, and your comments and contributions
                     are requested.

]]
[D2GS_UNSELECTOBJ] = { -- 0x2D
},
--[[doc
    Message ID:    0x2F

    Message Name:  D2GS_NPCINIT

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) Entity ID

                   Entity types
                   --------
                   00 - Players
                   01 - Monsters, NPCs, and Mercenaries
                   02 - Stash, Waypoint, Chests, Portals, others.
                   03 - Missiles
                   04 - Items
                   05 - Entrances

    Remarks:       Initiate an NPC sesstion, sent following:
                   C->S 0x13
                   It indicates that you are now interacting with an NPC, and a dialog
                   window is opened.

                   This is prior to any choices being made to talk or trade etc.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x32] D2GS_NPCBUY (C->S), [0x30] D2GS_NPCCANCEL (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCINIT] = { -- 0x2F
	uint32("Entity Type"),
	uint32("Entity ID"),
},
--[[doc
    Message ID:    0x30

    Message Name:  D2GS_NPCCANCEL

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Entity Type
                   (DWORD) NPC ID

    Remarks:       Stops interacting with an NPC

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x32] D2GS_NPCBUY (C->S), [0x2F] D2GS_NPCINIT (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCCANCEL] = { -- 0x30
	uint32("Entity Type"),
	uint32("NPC ID"),
},
--[[doc
    Message ID:    0x32

    Message Name:  D2GS_NPCBUY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) NPC ID - Unconfirmed
                   (DWORD) Item ID - Unconfirmed
                   (DWORD) Buffer Type - Unconfirmed
                   (DWORD) Cost

    Remarks:       Buys an item from a Non Player Character.

                   Possible Buffer Types:
                   0x00 - Regular (ordinary item)
                   0x02 - Gambled

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x2F] D2GS_NPCINIT (C->S), [0x30] D2GS_NPCCANCEL (C->S),
                   [0x33] D2GS_NPCSELL (C->S), [0x38] D2GS_NPCTRADE (C->S)

]]
[D2GS_NPCBUY] = { -- 0x32
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer Type - Unconfirmed"),
	uint32("Cost"),
},
--[[doc
    Message ID:    0x33

    Message Name:  D2GS_NPCSELL

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) NPC ID - Unconfirmed
                   (DWORD) Item ID - Unconfirmed
                   (DWORD) Buffer ID - Unconfirmed - Possible value 0x04
                   (DWORD) Cost

    Remarks:       Sell an item to a Non Player Character.

                   The Buffer ID refers to the windows in the NPC trade screen, depending
                   on what you are selling the Buffer ID will match the item type.
                   After selling the item it will appear in the given Buffer ID.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_NPCSELL] = { -- 0x33
	uint32("NPC ID - Unconfirmed"),
	uint32("Item ID - Unconfirmed"),
	uint32("Buffer ID - Unconfirmed - Possible value 0x04"),
	uint32("Cost"),
},
--[[doc
    Message ID:      0x38

    Message Name:    D2GS_NPCTRADE

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Trade Type - Unconfirmed
                     (DWORD) NPC ID - Unconfirmed
                     (DWORD) Unknown - Unconfirmed - Possible value 0x00

    Remarks:         This packet's use is currently unconfirmed.

                     Possible Trade Types:
                     0x01 - Trade
                     0x02 - Gamble

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_NPCTRADE] = { -- 0x38
	uint32("Trade Type - Unconfirmed"),
	uint32("NPC ID - Unconfirmed"),
	uint32("Unknown - Unconfirmed - Possible value 0x00"),
},
--[[doc
    Message ID:    0x3F

    Message Name:  D2GS_CHARACTERPHRASE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Phrase ID

    Remarks:       All phrases sent to the server will be heard by all players in your
                   vicinity.

                   Phrase IDs: (Note: The deciding of which of the two phrases are used
                   is random)
                   [0x19] "Help!" / "Help me!"
                   [0x1A] "Follow me!" / "Come on!"
                   [0x1B] "This is yours." / "This is for you."
                   [0x1C] "Thanks!" / "Thank you."
                   [0x1D] "Uh, oops." / "Forgive me."
                   [0x1E] "Bye!" / "Good Bye!"
                   [0x1F] "Die!" / "Time to die!"
                   [0x20] "Run!" / "Run away!" Please note: This message's official name
                   is not known, and has been invented.

]]
[D2GS_CHARACTERPHRASE] = { -- 0x3F
	uint16("Phrase ID"),
},
--[[doc
    Message ID:      0x49

    Message Name:    D2GS_WAYPOINT

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) Waypoint ID
                     (BYTE) Unknown - Appears to be random
                     (WORD) Unknown - 0x00
                     (BYTE) Level number
                     (WORD) Unknown - 0x00

    Remarks:         Requests to go to a waypoint if it was already activated.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_WAYPOINT] = { -- 0x49
	uint8("Waypoint ID"),
	uint8("Unknown - Appears to be random"),
	uint16("Unknown - 0x00"),
	uint8("Level number"),
	uint16("Unknown - 0x00"),
},
--[[doc
    Message ID:    0x4F

    Message Name:  D2GS_TRADE

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Request ID
                   (WORD) Gold Amount

    Remarks:       This message should be used for manipulating the trading window, the
                   Horadric Cube item window, and the Stash window.

                   Possible Request ID's:
                   [0x02] Cancel trade request
                   [0x03] Accept trade request
                   [0x04] Press Accept button (accept)
                   [0x07] Press Accept button (unaccept) - This should be sent when
                   placing items in the trade window as well.
                   [0x08] Refresh window (See below for examples on usage)
                   [0x12] Close stash window
                   [0x13] Move gold (stash to inventory)
                   [0x14] Move gold (inventory to stash)
                   [0x17] Close Horadric Cube window

                   Examples of using Refresh ID:
                   Item has been picked up to mouse cursor buffer.
                   Item has been placed in the trade screen.
                   Accepted or closed a trade window.
                   Manual unclick of Accept button.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_TRADE] = { -- 0x4F
	uint32("Request ID"),
	uint16("Gold Amount"),
},
--[[doc
    Message ID:    0x50

    Message Name:  D2GS_DROPGOLD

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) PlayerID
                   (DWORD) GoldAmount

    Remarks:       Drops a pile of gold to the ground.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_DROPGOLD] = { -- 0x50
	uint32("PlayerID"),
	uint32("GoldAmount"),
},
--[[doc
    Message ID:    0x5E

    Message Name:  D2GS_PARTY

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (WORD) Action ID
                   (DWORD) Player ID

    Remarks:       Possible Action IDs:

                   0x06 - Invite player to party with you
                   0x07 - Cancel invite to player
                   0x08 - Accept invite from player
                   0x09 - Leave party

]]
[D2GS_PARTY] = { -- 0x5E
	uint16("Action ID"),
	uint32("Player ID"),
},
--[[doc
    Message ID:      0x61

    Message Name:    D2GS_POTIONTOMERCENARY

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (WORD) Unknown - 0x00

    Remarks:         Takes the potion your cursor holds and gives it to the mercenary.
                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_POTIONTOMERCENARY] = { -- 0x61
	uint16("Unknown - 0x00"),
},
--[[doc
    Message ID:      0x68

    Message Name:    D2GS_GAMELOGON

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) D2GS Server Hash
                     (WORD) D2GS Server Token
                     (BYTE) Character ID
                     (DWORD) Version byte (Currently 0x0B)
                     (DWORD) Unknown - Suggested Const (0xED5DCC50)
                     (DWORD) Unknown - Suggested Const (0x91A519B6)
                     (BYTE) Unknown - Suggested (0x00)
                     (STRING) Character name
                     (VOID) *See user-comment below

    Remarks:         Possible Character IDs:
                     0x00 - Amazon
                     0x01 - Sorceress
                     0x02 - Necromancer
                     0x03 - Paladin
                     0x04 - Barbarian
                     0x05 - Druid
                     0x06 - Assassin

                     The "Character name" field is a buffer of 15 characters with a
                     null-terminator. This string should always be filled with 15
                     characters (plus terminator), padded with 0's for unused bytes.

                     Note: If the character ID does not match the type of character you're
                     attempting to logon with, and the character is nealy created (with 0
                     play time), then that character will automatically be changed or
                     "morphed" into the character ID sent.
                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_GAMELOGON] = { -- 0x68
	uint32("D2GS Server Hash"),
	uint16("D2GS Server Token"),
	uint8("Character ID"),
	uint32("Version byte"),
	uint32("Unknown - Suggested Const"),
	uint32("Unknown - Suggested Const"),
	uint8("Unknown - Suggested"),
	stringz("Character name"),
	bytes("See user-comment below"),
},
--[[doc
    Message ID:      0x6A

    Message Name:    D2GS_ENTERGAMEENVIRONMENT

    Message Status:  RAW, NEW PACKET

    Direction:       Client -> Server (Sent)

    Used By:         Diablo II, Diablo

    Format:          blank

    Remarks:         This byte should be sent in order to start receiving in-game messages
                     and to interact with the world itself.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_ENTERGAMEENVIRONMENT] = { -- 0x6A
},
--[[doc
    Message ID:    0x6D

    Message Name:  D2GS_PING

    Direction:     Client -> Server (Sent)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Tick Count
                   (DWORD) Null
                   (DWORD) Null

    Remarks:       This packet should be sent every five to seven seconds to avoid
                   timeout.

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_PING] = { -- 0x6D
	uint32("Tick Count"),
	uint32("Null"),
	uint32("Null"),
},
-- End cpackets_d2gs.lua
