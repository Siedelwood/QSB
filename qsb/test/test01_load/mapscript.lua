-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
-- ||||                          GLOBALES SKRIPT                         |||| --
-- ||||                    --------------------------                    |||| --
-- ||||                            Testmap 01                            |||| --
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
    local Path = "E:/Repositories/revision/qsb/lua/var/build/modules/";
    return {
        Path.. "qsb_1_entity/qsb_1_entity.lua",
        Path.. "qsb_1_guicontrol/qsb_1_guicontrol.lua",
        Path.. "qsb_1_guieffects/qsb_1_guieffects.lua",
        Path.. "qsb_1_movement/qsb_1_movement.lua",
        Path.. "qsb_1_requester/qsb_1_requester.lua",
        Path.. "qsb_1_sound/qsb_1_sound.lua",
        Path.. "qsb_1_trade/qsb_1_trade.lua",
        Path.. "qsb_2_buildingui/qsb_2_buildingui.lua",
        Path.. "qsb_2_buildrestriction/qsb_2_buildrestriction.lua",
        Path.. "qsb_2_camera/qsb_2_camera.lua",
        Path.. "qsb_2_newbehavior/qsb_2_newbehavior.lua",
        Path.. "qsb_2_npc/qsb_2_npc.lua",
        Path.. "qsb_2_objects/qsb_2_objects.lua",
        Path.. "qsb_2_promotion/qsb_2_promotion.lua",
        Path.. "qsb_2_quest/qsb_2_quest.lua",
        Path.. "qsb_2_selection/qsb_2_selection.lua",
        Path.. "qsb_3_armysystem/qsb_3_armysystem.lua",
        Path.. "qsb_3_briefingsystem/qsb_3_briefingsystem.lua",
        Path.. "qsb_3_cutscenesystem/qsb_3_cutscenesystem.lua",
        Path.. "qsb_3_dialogsystem/qsb_3_dialogsystem.lua",
        Path.. "qsb_3_lifestock/qsb_3_lifestock.lua",
        Path.. "qsb_3_traderoutes/qsb_3_traderoutes.lua",
        Path.. "qsb_4_questjournal/qsb_4_questjournal.lua",
        Path.. "qsb_4_iomines/qsb_4_iomines.lua",
        Path.. "qsb_4_iosite/qsb_4_iosite.lua",
        Path.. "qsb_4_iotreasure/qsb_4_iotreasure.lua",
    };
end

-- -------------------------------------------------------------------------- --
-- Diese Funktion wird nach Spielstart aufgerufen.
--
function Mission_OnQsbLoaded()
    -- Testmodus aktivieren
    -- (Auskommentieren, wenn nicht benötigt)
    API.ActivateDebugMode(true, false, true, true);

    -- Assistenten Quests starten
    -- (Auskommentieren, wenn nicht benötigt)
    -- CreateQuests();

    OverrideEventGameCallback();
end

-- > CreateTestQuest()
function CreateTestQuest()
    API.CreateQuest {
        Name = "TestQuest",
        Suggestion = "Schreib mal was...",

        Goal_NoChange(),
        Trigger_Time(5)
    }

    API.ShowJournalForQuest("TestQuest", true);
    API.AllowNotesForQuest("TestQuest", true);

    local Entry1 = API.CreateJournalEntry("Das ist Eintrag #1.");
    local Entry2 = API.CreateJournalEntry("Das ist Eintrag #2.");
    local Entry3 = API.CreateJournalEntry("Das ist Eintrag #3.");
    local Entry4 = API.CreateJournalEntry("Das ist Eintrag #4.");

    API.AddJournalEntryToQuest(Entry1, "TestQuest");
    API.AddJournalEntryToQuest(Entry2, "TestQuest");
    API.AddJournalEntryToQuest(Entry3, "TestQuest");
    API.AddJournalEntryToQuest(Entry4, "TestQuest");

    API.HighlightJournalEntry(Entry1, true);
    API.HighlightJournalEntry(Entry4, true);
end

-- -------------------------------------------------------------------------- --

function OverrideEventGameCallback()
    GameCallback_QSB_OnEventReceived = function(_ID, ...)
        if _ID == QSB.ScriptEvents.SaveGameLoaded then
            Logic.DEBUG_AddNote("Save game loaded!");
        end
        if _ID == QSB.ScriptEvents.EscapePressed then
            Logic.DEBUG_AddNote("Escape pressed by player " ..arg[1]);
        end
        if _ID == QSB.ScriptEvents.ImageScreenHidden then
            Logic.DEBUG_AddNote("Image screen gone");
        end
        if _ID == QSB.ScriptEvents.SermonStarted then
            Logic.DEBUG_AddNote("Sermon started");
        end
        if _ID == QSB.ScriptEvents.FestivalStarted then
            Logic.DEBUG_AddNote("Festival started");
        end
        if _ID == QSB.ScriptEvents.LoadscreenClosed then
            Logic.DEBUG_AddNote("Loadscreen closed (global)");
        end
    end
end

function TestTypewriter()
    local EventName = API.StartTypewriter {
        PlayerID = 1,
        Text     = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
                   "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
                   "magna aliquyam erat, sed diam voluptua. At vero eos et"..
                   " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
                   " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
                   " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
                   " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
                   " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
                   " et accusam et justo duo dolores et ea rebum. Stet clita"..
                   " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
                   " dolor sit amet.",
        Callback = function(_Data)
            -- Hier kann was passieren
        end
    };
end

