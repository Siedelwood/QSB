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
    local SHID = Logic.GetStoreHouse(3);
    AddOffer(SHID, 5, Goods.G_Grain);
    AddOffer(SHID, 5, Goods.G_Stone);

    local SHID = Logic.GetStoreHouse(4);
    AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Melee_NA);
    AddMercenaryOffer(SHID, 2, Entities.U_MilitaryBandit_Ranged_NA);

    local SHID = Logic.GetStoreHouse(5);
    AddOffer(SHID, 5, Goods.G_Gems);
    AddOffer(SHID, 5, Goods.G_Salt);
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
        MapPath = "E:/Repositories/revision/qsb/demo/QSB_1_Trade/demomap.s6xmap.unpacked/" ..MapPath;
    end
    return {
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

