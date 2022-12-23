-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
-- ||||                          LOKALES SKRIPT                          |||| --
-- ||||                    --------------------------                    |||| --
-- ||||                            Testmap 01                            |||| --
-- ||||                           totalwarANGEL                          |||| --
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

-- ========================================================================== --

function Mission_LocalOnMapStart()
end

function Mission_LocalVictory()
end

-- ========================================================================== --

-- -------------------------------------------------------------------------- --
-- Diese Funktion läd Skriptdateien bevor die Module initalisiert werden.
-- (der Pfad zur Map steht in der Variable gvMission.ContentPath)
--
-- Beispiel:
-- return {
--    gvMission.ContentPath .. "promotion.lua",
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
function Mission_LocalOnQsbLoaded()
    OverrideEventGameCallback();
end

-- -------------------------------------------------------------------------- --

function OverrideEventGameCallback()
    GameCallback_QSB_OnEventReceived = function(_ID, ...)
        if _ID == QSB.ScriptEvents.ChatOpened then
            GUI.AddNote("Player " ..arg[1].. " opened the chat!");
        end
        if _ID == QSB.ScriptEvents.ChatClosed then
            GUI.AddNote("Input: " ..arg[1]);
        end
        if _ID == QSB.ScriptEvents.LoadscreenClosed then
            GUI.AddNote("Loadscreen closed (local)");
        end
    end
end
