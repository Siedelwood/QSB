-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
-- ||||                          GLOBALES SKRIPT                         |||| --
-- ||||                    --------------------------                    |||| --
-- ||||                           [Kartenname]                           |||| --
-- ||||                             [Author]                             |||| --
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

-- ========================================================================== --

function Mission_FirstMapAction()
    Script.Load("maps/externalmap/" ..Framework.GetCurrentMapName().. "/questsystembehavior.lua");

    if Framework.IsNetworkGame() ~= true then
        Startup_Player();
        Startup_StartGoods();
        Startup_Diplomacy();
    end
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
    return {};
end

-- -------------------------------------------------------------------------- --
-- Diese Funktion wird nach Spielstart aufgerufen.
--
function Mission_MP_OnQsbLoaded()
    -- Testmodus aktivieren
    -- (Auskommentieren, wenn nicht benötigt)
    API.ActivateDebugMode(true, false, true, true);

    -- Standard Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    -- SetupNPCQuests()

    -- Assistenten Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    CreateQuests();
end

-- -------------------------------------------------------------------------- --

