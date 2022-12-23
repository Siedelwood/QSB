-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- # Local Script - <MAPNAME>                                               # --
-- # © <AUTHOR>                                                             # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

function Mission_LocalVictory()
end

function Mission_LoadFiles()
    local Path = "E:/Repositories/revision/qsb/lua/var/build/modules/";
    return {
        Path.. "qsb_1_gui/qsb_1_gui.lua",
        Path.. "qsb_1_movement/qsb_1_movement.lua",
        Path.. "qsb_1_entity/qsb_1_entity.lua",
        Path.. "qsb_1_requester/qsb_1_requester.lua",
        Path.. "qsb_1_sound/qsb_1_sound.lua",
        Path.. "qsb_1_trade/qsb_1_trade.lua",
        Path.. "qsb_2_buildingui/qsb_2_buildingui.lua",
        Path.. "qsb_2_npc/qsb_2_npc.lua",
        Path.. "qsb_2_objects/qsb_2_objects.lua",
        Path.. "qsb_2_promotion/qsb_2_promotion.lua",
        Path.. "qsb_2_quest/qsb_2_quest.lua",
        Path.. "qsb_3_lifestock/qsb_3_lifestock.lua",
        Path.. "qsb_5_weather/qsb_5_weather.lua",
    };
end

function Mission_LocalOnQsbLoaded()
end