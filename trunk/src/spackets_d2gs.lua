-- Begin spackets_d2gs.lua
--[[doc
    Message ID:    0x10

    Message Name:  D2GS_CHARTOOBJ

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Unknown
                   (DWORD) Player ID
                   (BYTE) Movement Type
                   (BYTE) Destination Type
                   *(DWORD) Object ID
                   *(WORD) X Coordinate
                   *(WORD) Y Coordinate

    Remarks:       A character moves to an object within your view range.

                   * - These are what the player is moving to.

                   Possible values for Destination Type:
                   0x00 - Another player
                   0x01 - NPC or Monster
                   0x02 - Object such as Stash, Waypoint, or a Town Portal
                   0x04 - Item
                   0x05 - Doorway
                   Possible value for Movement Type:

                   0x18 - Run
                   0x00 - Walk Please note: This message's official name is not known,
                   and has been invented.

]]
[D2GS_CHARTOOBJ] = { -- 0x10
	uint8("Unknown"),
	uint32("Player ID"),
	uint8("Movement Type"),
	uint8("Destination Type"),
	uint32("Object ID"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
},
--[[doc
    Message ID:    0x19

    Message Name:  D2GS_SMALLGOLDPICKUP

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Amount

    Remarks:       Sent when you pick up a BYTE (255) of gold(254 or less).

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SMALLGOLDPICKUP] = { -- 0x19
	uint8("Amount"),
},
--[[doc
    Message ID:    0x1D

    Message Name:  D2GS_SETBYTEATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute
                   (BYTE) Amount

    Remarks:       Sets the current (base) amount of the specified attribute.

                   Note: Since these are only base amounts, items that give
                   increase/decrease the attribute should be added/subtracted to/from the
                   base value sent in the message.

                   Possible Attributes:

                   0x00 - Strength
                   0x01 - Energy
                   0x02 - Dexterity
                   0x03 - Vitality
                   0x04 - Stat remaining
                   0x05 - Skill remaining
                   0x0C - Level
                   0x0D - Experience
                   0x0E - Gold on Person
                   0x0F - Gold in Stash
                   0x10 - Defense
                   0x11 - Max Attack Damage
                   0x12 - Min Attack Damage
                   0x13 - Attack Rating
                   0x15 - Min Attack Damage
                   0x16 - Max Attack Damage
                   0x19 - Damage
                   0x1f - Defense
                   0x27 - Fire Resistance
                   0x28 - +Max Fire Resistance
                   0x29 - Cold Resistance
                   0x2A - +Max Cold Resistance
                   0x2B - Lightning Resistance
                   0x2C - +Max Lightning Resistance
                   0x2D - Poison Resistance
                   0x2E - +Max poison Resistance
                   0x31 - Add Fire Damage
                   0x33 - Add Lightning damage
                   0x35 - Add Damage for Weapon/Items probably (one of these may be cold
                   damage)
                   0x37 - Add Damage for Weapon/Items probably (one of these may be cold
                   damage)
                   0x3A - Add Poison Damage
                   0x4C - Add Max Health for Weapon/Items probably
                   0x4D - Add Max Mana for Weapons/Items probably
                   0xA2 - Add Max Stamina for Weapons/Items probably
                   0xA3 - Add Max Stamina for Weapons/Items probably
                   0xAB - Add to Defense

                   Please note: This message's official name is not known, and has been
                   invented.

]]
[D2GS_SETBYTEATTR] = { -- 0x1D
	uint8("Attribute"),
	uint8("Amount"),
},
--[[doc
    Message ID:    0x1E

    Message Name:  D2GS_SETWORDATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute
                   (WORD) Amount

    Remarks:       Sets the current (base) amount of the specified attribute.

                   Note: Since these are only base amounts, items that give
                   increase/decrease the attribute should be added/subtracted to/from the
                   base value sent in the message.

                   For attributes, see D2GS_SETBYTEATTR.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1D] D2GS_SETBYTEATTR (S->C), [0x1E] D2GS_SETWORDATTR (S->C)

]]
[D2GS_SETWORDATTR] = { -- 0x1E
	uint8("Attribute"),
	uint16("Amount"),
},
--[[doc
    Message ID:    0x1F

    Message Name:  D2GS_SETDWORDATTR

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Attribute - D2GS_SETWORDATTR
                   (DWORD) Amount

    Remarks:       Updates an attribute and sets it to the value sent, 4 bytes max.

                   Please note: This message's official name is not known, and has been
                   invented.

    Related:       [0x1E] D2GS_SETWORDATTR (S->C)

]]
[D2GS_SETDWORDATTR] = { -- 0x1F
	uint8("Attribute - D2GS_SETWORDATTR"),
	uint32("Amount"),
},
--[[doc
    Message ID:      0x51

    Message Name:    D2GS_WORLDOBJECT

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) Object Type - Any information appreciated
                     (DWORD) Object ID
                     (WORD) Object unique code
                     (WORD) X Coordinate
                     (WORD) Y Coordinate
                     (BYTE) State *
                     (BYTE) Interaction Condition

    Remarks:         Server-assigned coordinate, object ID, and state/interaction
                     properties.

                     States:
                     0x00 - Object's state can be changed. (Confirm?)
                     0x02 - Object's state cannot be changed with (0x13) interaction.
                     (Confirm?)

                     Interaction Conditions:
                     0x00 - General object. E.G.: Stash, chests, etc.
                     0x01 - Refresh shrine
                     0x02 - Health shrine
                     0x05 - Chest will catch fire (upon interaction)
                     0x08 - Monster contained within chest (sarcophagus)
                     0x0D - Mana recharge shrine
                     0x0E - Stamina shrine
                     0x0F - Experience shrine
                     0x13 - Fire shrine
                     0x80 - Chest is locked (State will be 0)

                     *If this value is 0, expect no packet 0x0E (status) to follow, if 2,
                     then there will be.

                     Please note: This message's official name is not known, and has been
                     invented.

]]
[D2GS_WORLDOBJECT] = { -- 0x51
	uint8("Object Type - Any information appreciated"),
	uint32("Object ID"),
	uint16("Object unique code"),
	uint16("X Coordinate"),
	uint16("Y Coordinate"),
	uint8("State"),
	uint8("Interaction Condition"),
},
--[[doc
    Message ID:      0x5C

    Message Name:    D2GS_(COMP)STARTGAME

    Message Status:  RAW, NEW PACKET

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          Blank

    Remarks:         This packet is part of the logon sequence, not to be confused with the
                     other 0x5C.
                     This packet is originally received compressed, so the message ID will
                     correspond with [Protocol Headers] D2GS compressed format.
                     This message is received with the 'OK' that you can go ahead and enter
                     the gaming environment.

                     Please note: This message's official name is not known, and has been
                     invented.

    Related:         [0x6A] D2GS_ENTERGAMEENVIRONMENT (C->S)

]]
[D2GS_COMPSTARTGAME] = { -- 0x5C
},
--[[doc
    Message ID:    0x77

    Message Name:  D2GS_TRADEACTION

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (BYTE) Request Type

    Remarks:       A character is trading with you.

                   Possible Request Type values:
                   0x01 - Player requests trade initiation
                   0x05 - Player presses 'Accept'
                   0x06 - 'Accept' button disabled for both players
                   0x09 - Out of inventory space
                   0x0C - Player cancels trade
                   0x0D - You accepted the trade agreement
                   0x0E - Your 'Accept' button is disabled
                   0x0F - 'Accept' buttons re-enabled Please note: This message's
                   official name is not known, and has been invented.

]]
[D2GS_TRADEACTION] = { -- 0x77
	uint8("Request Type"),
},
--[[doc
    Message ID:      0x7A

    Message Name:    D2GS_LOGONRESPONSE

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (DWORD) Unknown - Possible acceptance/request ID

    Remarks:         This message is originally received compressed, so the message ID will
                     correspond with D2GS compressed format.

                     This message is received if your logon is accepted by the D2GS.

                     Please note: This message's official name is not known, and has been
                     invented.

    Related:         [0x68] D2GS_GAMELOGON (C->S)

]]
[D2GS_LOGONRESPONSE] = { -- 0x7A
	uint32("Unknown - Possible acceptance/request ID"),
},
--[[doc
    Message ID:      0x89

    Message Name:    D2GS_UNIQUEEVENTS

    Message Status:  MORE RESEARCH NEEDED

    Direction:       Server -> Client (Received)

    Used By:         Diablo II, Diablo

    Format:          (BYTE) EventId // see below,

                     Events known so far:
                     00 = Killed all the monsters in the den.
                     01 = Tristram portal opening for the first time.
                     03 = Staff being put into the oriface in act2
                     06 = Ammy being poped in clawviper temple.
                     07 = Summoner area? death or when the tome is clicked unsure which.
                     08 = Duriel just died
                     0b = Meph just died.
                     0c = The last seal in cs was hit diablo is now released.
                     0d = Diablo was killed or is dead.

    Remarks:         I'm sure there are many others by looking at the gaps here.

                     Note1: Unsure what to name this any suggestions will be taken into
                     account.
                     Note2: This seems to relate to various events that relate directly or
                     indirectly to key quest states//events.

]]
[D2GS_UNIQUEEVENTS] = { -- 0x89
	uint8("EventId // see below,"),
},
--[[doc
    Message ID:    0xAF

    Message Name:  D2GS_STARTLOGON

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        blank*

    Remarks:       Permission to initiate Game Server Logon.

                   * - Although this packet is blank, the data received will still be
                   compressed. Meaning the actual message size will be two bytes in
                   length. (See [Sizes & Types]) Please note: This message's official
                   name is not known, and has been invented.

]]
[D2GS_STARTLOGON] = { -- 0xAF
},
--[[doc
    Message ID:    0x01

    Message Name:  MCP_STARTUP

    Direction:     Server -> Client (Received)

    Used By:       Diablo II, Diablo

    Format:        (DWORD) Result

    Remarks:       Contains the return value from MCP Startup.

                   Known return values:
                   0x02, 0x0A-0x0D: Realm Unavailable: No Battle.net connection
                   detected.

                   0x7E: CDKey banned from realm play.

                   0x7F: Temporary IP ban \"Your connection has been temporarily
                   restricted from this realm. Please try to log in at another
                   time.\"

                   Else: Success.

    Related:       [0x01] MCP_STARTUP (C->S)

]]
-- End spackets_d2gs.lua
