--[[
Swift_MOD_MapLoader/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Verwaltung von zusammenhängenden versteckten Maps als eine
-- Art Kampagne.
--
-- Die einzelnen Teile der Kampagne müssen nicht von Anfang an dem Loader
-- bekannt gemacht werden. Der Spieler kann nach und nach weitere Teile
-- herunterladen und sie werden automatisch hinzugefügt.
--
-- Eine Map muss eine Konfigurationsdatei "maploader.lua" enthalten. So eine
-- Konfiguration kann wie folgt aussehen:
-- <pre>LocalMapData = {
--    MapCode = "Bockwurst",          -- Codewort, das im Profil stehen muss
--    Splashscreen = true,            -- Splashscreen anzeigen (splashscreen.png)
--    LoaderVersion = 1,              -- Benötigte Version des Loader
--    PossibleKnights = {             -- Auswählbare Helden
--        "U_KnightTrading",
--        "U_KnightHealing",
--        "U_KnightChivalry",
--        "U_KnightWisdom",
--        "U_KnightPlunder",
--        "U_KnightSong",
--        "U_KnightSabatta",
--        "U_KnightRedPrince",
--    },
--    RequiredMaps = {                -- Benötigte Maps (max. 5)
--        "twa01_swm_examplemap1",
--        "twa02_swm_examplemap2",
--    },
--};</pre>
-- Nicht benötigte Angaben können weggelassen werden.
--
-- @set sort=true
--

function API.Campaign_Initalize()
	if not GUI then
        Logic.ExecuteInLuaLocalState("API.Campaign_Initalize()");
		return;
	end
	ModMapLoader.Local:Initalize();
end

function API.Campaign_StartMapSelection()
	if not GUI then
        Logic.ExecuteInLuaLocalState("API.Campaign_StartMapSelection()");
		return;
	end
	API.StartHiResJob(function()
		if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
			ModMapLoader.Local:OverrideEndscreenDialog();
			OpenCustomGameDialog();
			return true;
		end
	end);
end

