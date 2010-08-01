-- Begin valuemaps.lua
-- Common value descriptions
local Descs = {
	-- Boolean values
	YesNo = {
		[1] = "Yes",
		[0] = "No",
	},
	
	ClientTag = {
		["DSHR"] = "Diablo 1 Shareware",
		["DRTL"] = "Diablo 1 (Retail)",
		["SSHR"] = "Starcraft Shareware",
		["STAR"] = "Starcraft",
		["SEXP"] = "Starcraft: Broodwar",
		["JSTR"] = "Starcraft Japanese",
		["W2BN"] = "Warcraft II Battle.Net Edition",
		["D2DV"] = "Diablo 2",
		["D2XP"] = "Diablo 2: Lord Of Destruction",
		["WAR3"] = "Warcraft III (Reign Of Chaos)",
		["W3XP"] = "Warcraft III: The Frozen Throne",
	},
	
	PlatformID = {
		["IX86"] = "Windows (Intel x86)",
		["PMAC"] = "Macintosh",
		["XMAC"] = "Macintosh OS X",
	},

	GameStatus = {
		[0x00] = "OK",
		[0x01] = "Game doesn't exist",
		[0x02] = "Incorrect password",
		[0x03] = "Game full",
		[0x04] = "Game already started",
		[0x06] = "Too many server requests",
	},
	
	-- International Locale ID (LCID)
	-- http://support.microsoft.com/kb/221435
	LocaleID = {
		[11276] = "French (Cameroon)",
		[1025] = "Arabic (Saudi Arabia)",
		[1026] = "Bulgarian",
		[1027] = "Catalan",
		[1028] = "Chinese (Taiwan)",
		[1029] = "Czech",
		[1030] = "Danish",
		[1031] = "German (Germany)",
		[1032] = "Greek",
		[1033] = "English (United States)",
		[1034] = "Spanish (Traditional Sort)",
		[1035] = "Finnish",
		[1036] = "French (France)",
		[1037] = "Hebrew",
		[1038] = "Hungarian",
		[1039] = "Icelandic",
		[1040] = "Italian (Italy)",
		[1041] = "Japanese",
		[1042] = "Korean",
		[1043] = "Dutch (Netherlands)",
		[1044] = "Norwegian (Bokmal)",
		[1045] = "Polish",
		[1046] = "Portuguese (Brazil)",
		[1047] = "Rhaeto-Romanic",
		[1048] = "Romanian",
		[1049] = "Russian",
		[1050] = "Croatian",
		[1051] = "Slovak",
		[1052] = "Albanian",
		[1053] = "Swedish",
		[1054] = "Thai",
		[1055] = "Turkish",
		[1056] = "Urdu",
		[1057] = "Indonesian",
		[1058] = "Ukrainian",
		[1059] = "Belarusian",
		[1060] = "Slovenian",
		[1061] = "Estonian",
		[1062] = "Latvian",
		[1063] = "Lithuanian",
		[1064] = "Tajik",
		[1065] = "Farsi",
		[1066] = "Vietnamese",
		[1070] = "Sorbian",
		[1067] = "Armenian",
		[1068] = "Azeri (Latin)",
		[1069] = "Basque",
		[1071] = "FYRO Macedonian",
		[1072] = "Sesotho",
		[1072] = "Sutu",
		[1073] = "Tsonga",
		[1074] = "Tswana",
		[1075] = "Venda",
		[1076] = "Xhosa",
		[1077] = "Zulu",
		[1078] = "Afrikaans",
		[1079] = "Georgian",
		[1080] = "Faroese",
		[1081] = "Hindi",
		[1082] = "Maltese",
		[1083] = "Sami Lappish",
		[1084] = "Gaelic Scotland",
		[1085] = "Yiddish",
		[1086] = "Malay (Malaysia)",
		[1087] = "Kazakh",
		[1088] = "Kyrgyz (Cyrillic)",
		[1089] = "Swahili",
		[1090] = "Turkmen",
		[1091] = "Uzbek (Latin)",
		[1092] = "Tatar",
		[1093] = "Bengali (India)",
		[1094] = "Punjabi",
		[1095] = "Gujarati",
		[1096] = "Oriya",
		[1097] = "Tamil",
		[1098] = "Telugu",
		[1099] = "Kannada",
		[1100] = "Malayalam",
		[1101] = "Assamese",
		[1102] = "Marathi",
		[1103] = "Sanskrit",
		[1104] = "Mongolian (Cyrillic)",
		[1105] = "Tibetan",
		[1106] = "Welsh",
		[1107] = "Khmer",
		[1108] = "Lao",
		[1109] = "Burmese",
		[1110] = "Galician",
		[1111] = "Konkani",
		[1112] = "Manipuri",
		[1113] = "Sindhi",
		[1114] = "Syriac",
		[1115] = "Sinhalese (Sri Lanka)",
		[1118] = "Amharic (Ethiopia)",
		[1120] = "Kashmiri",
		[1121] = "Nepali",
		[1122] = "Frisian (Netherlands)",
		[1124] = "Filipino",
		[1125] = "Divehi",
		[1126] = "Edo",
		[1136] = "Igbo (Nigeria)",
		[1140] = "Guarani (Paraguay)",
		[1142] = "Latin",
		[1143] = "Somali",
		[1153] = "Maori (New Zealand)",
		[1279] = "HID (Human Interface Device)",
		[2049] = "Arabic (Iraq)",
		[2052] = "Chinese (PRC)",
		[2055] = "German (Switzerland)",
		[2057] = "English (United Kingdom)",
		[2058] = "Spanish (Mexico)",
		[2060] = "French (Belgium)",
		[2064] = "Italian (Switzerland)",
		[2067] = "Dutch (Belgium)",
		[2068] = "Norwegian (Nynorsk)",
		[2070] = "Portuguese (Portugal)",
		[2072] = "Romanian (Moldova)",
		[2073] = "Russian (Moldova)",
		[2074] = "Serbian (Latin)",
		[2077] = "Swedish (Finland)",
		[2092] = "Azeri (Cyrillic)",
		[2108] = "Gaelic Ireland",
		[2110] = "Malay (Brunei Darussalam)",
		[2115] = "Uzbek (Cyrillic)",
		[2117] = "Bengali (Bangladesh)",
		[2128] = "Mongolian (Mongolia)",
		[3073] = "Arabic (Egypt)",
		[3076] = "Chinese (Hong Kong S.A.R.)",
		[3079] = "German (Austria)",
		[3081] = "English (Australia)",
		[3082] = "Spanish (International Sort)",
		[3084] = "French (Canada)",
		[3098] = "Serbian (Cyrillic)",
		[4097] = "Arabic (Libya)",
		[4100] = "Chinese (Singapore)",
		[4103] = "German (Luxembourg)",
		[4105] = "English (Canada)",
		[4106] = "Spanish (Guatemala)",
		[4108] = "French (Switzerland)",
		[4122] = "Croatian (Bosnia/Herzegovina)",
		[5121] = "Arabic (Algeria)",
		[5124] = "Chinese (Macau S.A.R.)",
		[5127] = "German (Liechtenstein)",
		[5129] = "English (New Zealand)",
		[5130] = "Spanish (Costa Rica)",
		[5132] = "French (Luxembourg)",
		[5146] = "Bosnian (Bosnia/Herzegovina)",
		[6145] = "Arabic (Morocco)",
		[6153] = "English (Ireland)",
		[6154] = "Spanish (Panama)",
		[6156] = "French (Monaco)",
		[7169] = "Arabic (Tunisia)",
		[7177] = "English (South Africa)",
		[7178] = "Spanish (Dominican Republic)",
		[7180] = "French (West Indies)",
		[8193] = "Arabic (Oman)",
		[8201] = "English (Jamaica)",
		[8202] = "Spanish (Venezuela)",
		[9217] = "Arabic (Yemen)",
		[9225] = "English (Caribbean)",
		[9226] = "Spanish (Colombia)",
		[9228] = "French (Congo, DRC)",
		[10241] = "Arabic (Syria)",
		[10249] = "English (Belize)",
		[10250] = "Spanish (Peru)",
		[10252] = "French (Senegal)",
		[11265] = "Arabic (Jordan)",
		[11273] = "English (Trinidad)",
		[11274] = "Spanish (Argentina)",
		[12289] = "Arabic (Lebanon)",
		[12297] = "English (Zimbabwe)",
		[12298] = "Spanish (Ecuador)",
		[12300] = "French (Cote d'Ivoire)",
		[13313] = "Arabic (Kuwait)",
		[13321] = "English (Philippines)",
		[13322] = "Spanish (Chile)",
		[13324] = "French (Mali)",
		[14337] = "Arabic (U.A.E.)",
		[14346] = "Spanish (Uruguay)",
		[14348] = "French (Morocco)",
		[15361] = "Arabic (Bahrain)",
		[15370] = "Spanish (Paraguay)",
		[16385] = "Arabic (Qatar)",
		[16393] = "English (India)",
		[16394] = "Spanish (Bolivia)",
		[17418] = "Spanish (El Salvador)",
		[18442] = "Spanish (Honduras)",
		[19466] = "Spanish (Nicaragua)",
		[20490] = "Spanish (Puerto Rico)",
	},
	
	-- TODO: what's the name of these codes?
	LangId = {
		['enUS'] = 'English (US)',
		['enGB'] = 'English (UK)',
		['frFR'] = 'French',
		['deDE'] = 'German',
		['esES'] = 'Spanish',
		['itIT'] = 'Italian',
		['csCZ'] = 'Czech',
		['ruRU'] = 'Russian',
		['plPL'] = 'Polish',
		['ptBR'] = 'Portuguese (Brazilian)',
		['ptPT'] = 'Portuguese (Portugal)',
		['tkTK'] = 'Turkish',
		['jaJA'] = 'Japanese',
		['koKR'] = 'Korean',
		['zhTW'] = 'Chinese (Traditional)',
		['zhCN'] = 'Chinese (Simplified)',
		['thTH'] = 'Thai',
	},
	
	TimeZoneBias = {
		[-720] = "UTC +12",
		[-690] = "UTC +11.5",
		[-660] = "UTC +11",
		[-630] = "UTC +10.5",
		[-600] = "UTC +10",
		[-570] = "UTC +9.5",
		[-540] = "UTC +9",
		[-510] = "UTC +8.5",
		[-480] = "UTC +8",
		[-450] = "UTC +7.5",
		[-420] = "UTC +7",
		[-390] = "UTC +6.5",
		[-360] = "UTC +6",
		[-330] = "UTC +5.5",
		[-300] = "UTC +5",
		[-270] = "UTC +4.5",
		[-240] = "UTC +4",
		[-210] = "UTC +3.5",
		[-180] = "UTC +3",
		[-150] = "UTC +2.5",
		[-120] = "UTC +2",
		[-90]  = "UTC +1.5",
		[-60]  = "UTC +1",
		[-30]  = "UTC +0.5",
		[0]    = "UTC +0",
		[30]   = "UTC -0.5",
		[60]   = "UTC -1",
		[90]   = "UTC -1.5",
		[120]  = "UTC -2",
		[150]  = "UTC -2.5",
		[180]  = "UTC -3",
		[210]  = "UTC -3.5",
		[240]  = "UTC -4",
		[270]  = "UTC -4.5",
		[300]  = "UTC -5",
		[330]  = "UTC -5.5",
		[360]  = "UTC -6",
		[390]  = "UTC -6.5",
		[420]  = "UTC -7",
		[450]  = "UTC -7.5",
		[480]  = "UTC -8",
		[510]  = "UTC -8.5",
		[540]  = "UTC -9",
		[570]  = "UTC -9.5",
		[600]  = "UTC -10",
		[630]  = "UTC -10.5",
		[660]  = "UTC -11",
		[690]  = "UTC -11.5",
		[720]  = "UTC -12",
	},

	ClanRank = {
		[0x00] = "Initiate that has been in the clan for less than one week (Peon)",
		[0x01] = "Initiate that has been in the clan for over one week (Peon)",
		[0x02] = "Member (Grunt)",
		[0x03] = "Officer (Shaman)",
		[0x04] = "Leader (Chieftain)",
	},
	
	WarcraftGeneralSubcommandId = {
		[0x00] = "WID_GAMESEARCH",
		[0x01] = "",
		[0x02] = "WID_MAPLIST: Request ladder map listing",
		[0x03] = "WID_CANCELSEARCH: Cancel ladder game search",
		[0x04] = "WID_USERRECORD: User stats request",
		[0x05] = "",
		[0x06] = "",
		[0x07] = "WID_TOURNAMENT",
		[0x08] = "WID_CLANRECORD: Clan stats request",
		[0x09] = "WID_ICONLIST: Icon list request",
		[0x0A] = "WID_SETICON: Change icon",
	},
	
	WarcraftGeneralRequestType = {
		["URL"] = "URL",
		["MAP"] = "MAP",
		["TYPE"] = "TYPE",
		["DESC"] = "DESC",
		["LADR"] = "LADR",
	},
	
	--[[doc
	source: pvpgn \bnetd\account_wrap.c

	// Ramdom - Nothing, Grean Dragon Whelp, Azure Dragon (Blue Dragon), Red Dragon, Deathwing, Nothing
	// Humans - Peasant, Footman, Knight, Archmage, Medivh, Nothing
	// Orcs - Peon, Grunt, Tauren, Far Seer, Thrall, Nothing
	// Undead - Acolyle, Ghoul, Abomination, Lich, Tichondrius, Nothing
	// Night Elves - Wisp, Archer, Druid of the Claw, Priestess of the Moon, Furion Stormrage, Nothing
	// Demons - Nothing, ???(wich unit is nfgn), Infernal, Doom Guard, Pit Lord/Manaroth, Archimonde
	// ADDED TFT ICON BY DJP 07/16/2003 
	static char * profile_code[12][6] = {
	    {NULL  , "ngrd", "nadr", "nrdr", "nbwm", NULL  },
	    {"hpea", "hfoo", "hkni", "Hamg", "nmed", NULL  },
	    {"opeo", "ogru", "otau", "Ofar", "Othr", NULL  },
	    {"uaco", "ugho", "uabo", "Ulic", "Utic", NULL  },
	    {"ewsp", "earc", "edoc", "Emoo", "Efur", NULL  },
	    {NULL  , "nfng", "ninf", "nbal", "Nplh", "Uwar"}, /* not used by RoC */
	    {NULL  , "nmyr", "nnsw", "nhyc", "Hvsh", "Eevm"},
	    {"hpea", "hrif", "hsor", "hspt", "Hblm", "Hjai"},
	    {"opeo", "ohun", "oshm", "ospw", "Oshd", "Orex"},
	    {"uaco", "ucry", "uban", "uobs", "Ucrl", "Usyl"},
	    {"ewsp", "esen", "edot", "edry", "Ekee", "Ewrd"},
	    {NULL  , "nfgu", "ninf", "nbal", "Nplh", "Uwar"}
	};
		
	http://harpywar.com/?a=articles&b=2&c=1&d=28&lang=ru
	http://www.edgeofnowhere.cc/viewtopic.php?p=3818312
	--]]

	W3IconNames = {
		-- Random
		--NULL
		["ngrd"] = "Green Dragon Whelp",
		["nadr"] = "Azure Dragon (Blue Dragon)",
		["nrdr"] = "Red Dragon",
		["nbwm"] = "Deathwing",
		--NULL

		-- Humans
		["hpea"] = "Peasant",
		["hfoo"] = "Footman",
		["hkni"] = "Knight",
		["Hamg"] = "Archmage",
		["nmed"] = "Medivh",
		--NULL

		-- Orcs
		["opeo"] = "Peon",
		["ogru"] = "Grunt",
		["otau"] = "Tauren",
		["Ofar"] = "Far Seer",
		["Othr"] = "Thrall",
		--NULL

		-- Undead
		["uaco"] = "Acolyle",
		["ugho"] = "Ghoul",
		["uabo"] = "Abomination",
		["Ulic"] = "Lich",
		["Utic"] = "Tichondrius",
		--NULL

		-- Night Elves
		["ewsp"] = "Wisp",
		["earc"] = "Archer",
		["edoc"] = "Druid of the Claw",
		["Emoo"] = "Priestess of the Moon",
		["Efur"] = "Furion Stormrage",
		--NULL

		-- Demons
		--NULL
		["nfng"] = "dunno",
		["ninf"] = "Infernal",
		["nbal"] = "Doom Guard",
		["Nplh"] = "Pit Lord/Manaroth",
		["Uwar"] = "Archimonde",
		--/* not used by RoC */

		-- Random
		--NULL
		["nmyr"] = "Naga Myrmidon",
		["nnsw"] = "Naga Siren",
		["nhyc"] = "Dragon Turtle",
		["Hvsh"] = "Lady Vashj",
		["Eevm"] = "Illidan (Morphed 2)",
		
		-- Humans
		["hpea"] = "Peasant",
		["hrif"] = "Rifleman",
		["hsor"] = "Sorceress",
		["hspt"] = "Spellbreaker",
		["Hblm"] = "Blood Mage",
		["Hjai"] = "Jaina",

		-- Orcs
		["opeo"] = "Peon",
		["ohun"] = "Troll Headhunter",
		["oshm"] = "Shaman",
		["ospw"] = "Spirit Walker",
		["Oshd"] = "Shadow Hunter",
		["Orex"] = "Rexxar",

		-- Undead
		["uaco"] = "Acolyle",
		["ucry"] = "Crypt Fiend",
		["uban"] = "Banshee",
		["uobs"] = "Destroyer",
		["Ucrl"] = "Crypt Lord",
		["Usyl"] = "Sylvanas",

		-- Night Elves
		["ewsp"] = "Wisp",
		["esen"] = "Huntress",
		["edot"] = "Druid of the Talon",
		["edry"] = "Dryad",
		["Ekee"] = "Keeper of the Grove",
		["Ewrd"] = "Maiev",

		-- Tournament
		--NULL
		["nfgu"] = "Felguard",
		["ninf"] = "Infernal",
		["nbal"] = "Doomguard",
		["Nplh"] = "Pit Lord",
		["Uwar"] = "Archimonde",
	},
	
	W3Icon = {
		[""] = "Default icon",
		["W3H1"] = "",
		
		["W3O1"] = "",
		
		["W3N1"] = "",
		
		["W3U1"] = "",
		
		["W3R1"] = "",
		
		["W3D1"] = "",
		
	},

	W3Races = {
		[0x00] = "Random",
		[0x01] = "Humans",
		[0x02] = "Orcs",
		[0x03] = "Undead",
		[0x04] = "Night Elves",
		[0x05] = "Tournament",
	},
	
	W3LadderType = {
		['SOLO'] = 'SOLO', 
		['TEAM'] = 'TEAM',
		['FFA '] = 'FFA',
	},
	
	W3TeamType = {
		['2VS2'] = '2VS2',
		['3VS3'] = '3VS3',
		['4VS4'] = '4VS4',
	},
	
	-- Friend online status
	OnlineStatus = {
		[0x00] = "Offline",
		[0x01] = "Not in chat",
		[0x02] = "In chat",
		[0x03] = "In a public game",
		[0x04] = "In a private game, and you are not that person's friend",
		[0x05] = "In a private game, and you are that person's friend",
	},
	
}

-- Flag fields
local Fields = {
	-- S> 0xff SID_CHATEVENT
	UserFlags = {
		{sname="Blizzard Representative",     mask=0x00000001, desc=Descs.YesNo},
		{sname="Channel Operator",            mask=0x00000002, desc=Descs.YesNo},
		{sname="Speaker",                     mask=0x00000004, desc=Descs.YesNo},
		{sname="Battle.net Administrator",    mask=0x00000008, desc=Descs.YesNo},
		{sname="No UDP Support",              mask=0x00000010, desc=Descs.YesNo},
		{sname="Squelched",                   mask=0x00000020, desc=Descs.YesNo},
		{sname="Special Guest",               mask=0x00000040, desc=Descs.YesNo},
		{sname="Unknown",                     mask=0x00000080, desc=Descs.YesNo},
		{sname="Beep Enabled (Defunct)",      mask=0x00000100, desc=Descs.YesNo},
		{sname="PGL Player (Defunct)",        mask=0x00000200, desc=Descs.YesNo},
		{sname="PGL Official (Defunct)",      mask=0x00000400, desc=Descs.YesNo},
		{sname="KBK Player (Defunct)",        mask=0x00000800, desc=Descs.YesNo},
		{sname="WCG Official",                mask=0x00001000, desc=Descs.YesNo},
		{sname="KBK Singles (Defunct)",       mask=0x00002000, desc=Descs.YesNo},
		{sname="KBK Player (Defunct)",        mask=0x00002000, desc=Descs.YesNo},
		{sname="KBK Beginner (Defunct)",      mask=0x00010000, desc=Descs.YesNo},
		{sname="White KBK (1 bar) (Defunct)", mask=0x00020000, desc=Descs.YesNo},
		{sname="GF Official",                 mask=0x00100000, desc=Descs.YesNo},
		{sname="GF Player",                   mask=0x00200000, desc=Descs.YesNo},
		{sname="PGL Player",                  mask=0x02000000, desc=Descs.YesNo},
	},
	
	-- S> 0xff SID_CHATEVENT
	ChannelFlags = {
		{sname="Public Channel",              mask=0x00001, desc=Descs.YesNo},
		{sname="Moderated",                   mask=0x00002, desc=Descs.YesNo},
		{sname="Restricted",                  mask=0x00004, desc=Descs.YesNo},
		{sname="Silent",                      mask=0x00008, desc=Descs.YesNo},
		{sname="System",                      mask=0x00010, desc=Descs.YesNo},
		{sname="Product-Specific",            mask=0x00020, desc=Descs.YesNo},
		{sname="Globally Accessible",         mask=0x01000, desc=Descs.YesNo},
		{sname="Redirected",                  mask=0x04000, desc=Descs.YesNo},
		{sname="Chat",                        mask=0x08000, desc=Descs.YesNo},
		{sname="Tech Support",                mask=0x10000, desc=Descs.YesNo},	
	},                               

	-- Place iCCup / etc flags here if you want
	--IccupUserFlags = {
	
	--},
	--UserFlags = IccupUserFlags,
}

-- Common condition functions
local Cond
Cond = {
	assert_key = function (state, key)
		if state.packet[key] == nil then
			state:error("The key " .. key .. " is used before being defined.")
			return false
		end
		return true
	end,
	
	always = function() 
		return function() 
			return true 
		end 
	end,
	
	equals = function(key, value)
		return function(self, state)
			Cond.assert_key(state, key)
			return state.packet[key] == value
		end
	end,
	
	nequals = function(key, value)
		return function(self, state)
			Cond.assert_key(state, key)
			return state.packet[key] ~= value
		end
	end,
	
	neg = function(fun, ...)
		local func = fun
		if type(fun) == "string" then
			func = Cond[fun](unpack(arg))
		end
		return function(self, state)
			return not func(self, state)
		end
	end,
	
	inlist = function(key, arr)
		return function(self, state)
			Cond.assert_key(state, key)
			local val = state.packet[key]
			for i, v in ipairs(arr) do
				if v == val then
					return true
				end
			end
			return false
		end
	end,
}

do
	local CheckedTable = {
		tableType = setmetatable({}, {
			__mode = "k",
			__index = function () return "'thing'" end }),
		declaredNames = setmetatable({}, {
			__mode = "k",
			__index = function () return {} end } ), 
	}

	function CheckedTable.__newindex (t, n, v)
		if not CheckedTable.declaredNames[t][n] then
			error("attempt to write to undeclared var: "..n, 2)
		else
			CheckedTable.declaredNames[t][n] = true
			rawset(t, n, v)   -- do the actual set
		end
	end

	function CheckedTable.__index (t, n)
		error("attempt to read undeclared "
			.. CheckedTable.tableType[t]
			.. ": " .. n, 2)
	end

	function CheckedTable.guard (self, t, description)
		for k, _ in pairs(t) do
			self.declaredNames[t][k] = true
		end

		if description then
			self.tableType[t] = description
		end

		setmetatable(t, self)
	end

	CheckedTable:guard(Descs, "value description")
	CheckedTable:guard(Cond, "condition function")
end

-- End valuemaps.lua
