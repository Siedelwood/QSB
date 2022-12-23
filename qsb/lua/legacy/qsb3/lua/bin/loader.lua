BinLoader_BasePath = nil;
BinLoader_CoreFiles = {
    "Swift_0_Core/swift.lua",
    "Swift_0_Core/luabase.lua",
    "Swift_0_Core/api.lua",
    "Swift_0_Core/debug.lua",
    "Swift_0_Core/event.lua",
    "Swift_0_Core/behavior.lua",
    "Swift_0_Core/bugfixes.lua",
}
BinLoader_ModuleFiles = {
    "Swift_1_DisplayCore/source.lua",
    "Swift_1_DisplayCore/api.lua",
    "Swift_1_EntityEventCore/source.lua",
    "Swift_1_EntityEventCore/api.lua",
    "Swift_1_InputOutputCore/source.lua",
    "Swift_1_InputOutputCore/api.lua",
    "Swift_1_InputOutputCore/behavior.lua",
    "Swift_1_InterfaceCore/source.lua",
    "Swift_1_InterfaceCore/api.lua",
    "Swift_1_JobsCore/source.lua",
    "Swift_1_JobsCore/api.lua",
    "Swift_1_ScriptingValueCore/source.lua",
    "Swift_1_ScriptingValueCore/api.lua",
    "Swift_1_SoundCore/source.lua",
    "Swift_1_SoundCore/api.lua",
    "Swift_1_TradingCore/source.lua",
    "Swift_1_TradingCore/api.lua",
    "Swift_2_CastleStore/source.lua",
    "Swift_2_CastleStore/api.lua",
    "Swift_2_EntityMovement/source.lua",
    "Swift_2_EntityMovement/api.lua",
    "Swift_2_KnightTitleRequirements/source.lua",
    "Swift_2_KnightTitleRequirements/api.lua",
    "Swift_2_KnightTitleRequirements/requirements.lua",
    "Swift_2_NpcInteraction/source.lua",
    "Swift_2_NpcInteraction/api.lua",
    "Swift_2_NpcInteraction/behavior.lua",
    "Swift_2_ObjectInteraction/source.lua",
    "Swift_2_ObjectInteraction/api.lua",
    "Swift_2_ObjectInteraction/behavior.lua",
    "Swift_2_Quests/source.lua",
    "Swift_2_Quests/api.lua",
    "Swift_2_Typewriter/source.lua",
    "Swift_2_Typewriter/api.lua",
    "Swift_3_BehaviorCollection/source.lua",
    "Swift_3_BehaviorCollection/api.lua",
    "Swift_3_BehaviorCollection/behavior.lua",
    "Swift_3_BriefingSystem/source.lua",
    "Swift_3_BriefingSystem/api.lua",
    "Swift_3_BriefingSystem/behavior.lua",
    "Swift_3_CutsceneSystem/source.lua",
    "Swift_3_CutsceneSystem/api.lua",
    "Swift_3_CutsceneSystem/behavior.lua",
    "Swift_3_DialogSystem/source.lua",
    "Swift_3_DialogSystem/api.lua",
    "Swift_3_DialogSystem/behavior.lua",
    "Swift_3_WeatherManipulation/source.lua",
    "Swift_3_WeatherManipulation/api.lua",
    "Swift_4_ConstructionAndKnockdown/source.lua",
    "Swift_4_ConstructionAndKnockdown/api.lua",
    "Swift_4_LifestockBreeding/source.lua",
    "Swift_4_LifestockBreeding/api.lua",
    "Swift_4_QuestJournal/source.lua",
    "Swift_4_QuestJournal/api.lua",
    "Swift_4_QuestJournal/behavior.lua",
    "Swift_4_Selection/source.lua",
    "Swift_4_Selection/api.lua",
    "Swift_4_ShipSalesman/source.lua",
    "Swift_4_ShipSalesman/api.lua",
    "Swift_5_ExtendedCamera/source.lua",
    "Swift_5_ExtendedCamera/api.lua",
    "Swift_5_GraphVizExport/source.lua",
    "Swift_5_GraphVizExport/api.lua",
    "Swift_5_InteractiveChests/source.lua",
    "Swift_5_InteractiveChests/api.lua",
    "Swift_5_InteractiveMines/source.lua",
    "Swift_5_InteractiveMines/api.lua",
    "Swift_5_InteractiveSites/source.lua",
    "Swift_5_InteractiveSites/api.lua",
    "Swift_5_Minimap/source.lua",
    "Swift_5_Minimap/api.lua",
    "Swift_5_Minimap/behavior.lua",
    "Swift_5_SpeedLimitation/source.lua",
    "Swift_5_SpeedLimitation/api.lua",
}

function BinLoader_SetBasePath(_Path)
    BinLoader_BasePath = _Path;
end

function BinLoader_LoadFiles()
    if BinLoader_BasePath == nil then
        BinLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
    end
    for i= 1, #BinLoader_CoreFiles do
        Script.Load(BinLoader_BasePath.. "lua/modules/" ..BinLoader_CoreFiles[i]);
    end
    for i= 1, #BinLoader_ModuleFiles, 1 do
        Script.Load(BinLoader_BasePath.. "lua/modules/" ..BinLoader_ModuleFiles[i]);
    end

    Script.Load(BinLoader_BasePath.. "lua/modules/Swift_0_Core/selfload.lua");
end

