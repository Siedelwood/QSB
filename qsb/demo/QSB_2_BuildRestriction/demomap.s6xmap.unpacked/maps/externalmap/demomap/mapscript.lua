-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
-- ||||                          GLOBALES SKRIPT                         |||| --
-- ||||                    --------------------------                    |||| --
-- ||||                            QSB Testmap                           |||| --
-- ||||                           totalwarANGEL                          |||| --
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

-- ========================================================================== --

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    -- Mapeditor-Einstellungen werden geladen
    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
    Mission_OnQsbLoaded();
end

function Mission_InitPlayers()
end

function Mission_SetStartingMonth()
    Logic.SetMonthOffset(3);
end

function Mission_InitMerchants()
end

-- ========================================================================== --

-- -------------------------------------------------------------------------- --
-- Diese Funktion läd Skriptdateien bevor die Module initalisiert werden.
-- (der Pfad zur Map steht in der Variable gvMission.ContentPath)
--
-- Beispiel:
-- return {
--    gvMission.ContentPath .. "promotion.lua",
--    gvMission.ContentPath .. "briefings.lua",
--    gvMission.ContentPath .. "quests.lua"
-- };
--
function Mission_LoadFiles()
    local MapPath = "maps/externalmap/demomap/";
    if false then
        MapPath = "E:/Repositories/revision/qsb/demo/QSB_2_BuildRestriction/demomap.s6xmap.unpacked/" ..MapPath;
    end
    return {
        MapPath.. "script/qsb_1_guicontrol.lua",
        MapPath.. "script/qsb_1_requester.lua",
        MapPath.. "script/qsb_2_quest.lua",
        MapPath.. "script/qsb_2_buildrestriction.lua",

        MapPath.. "script/mapscript.lua",
    };
end

-- -------------------------------------------------------------------------- --
-- Diese Funktion wird nach Spielstart aufgerufen.
--
function Mission_OnQsbLoaded()
    API.ActivateDebugMode(true, false, true, true);
    StartScript();
end

