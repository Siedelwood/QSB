--[[
Swift_0_Core/Selfload

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

if not MapEditor and not GUI then
    local MapTypeFolder = "externalmap";
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType ~= 3 then
        MapTypeFolder = "development";
    end

    gvMission = gvMission or {};
    gvMission.ContentPath      = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/";
    gvMission.MusicRootPath    = "music/";
    gvMission.PlaylistRootPath = "config/sound/";

    Logic.ExecuteInLuaLocalState([[
        gvMission = gvMission or {};
        gvMission.GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission");
        gvMission.ContentPath      = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/";
        gvMission.MusicRootPath    = "music/";
        gvMission.PlaylistRootPath = "config/sound/";

        Script.Load(gvMission.ContentPath.. "questsystembehavior.lua");
        API.Install();
        if ModuleKnightTitleRequirements then
            InitKnightTitleTables();
        end
        
        -- Call directly for singleplayer
        if not Framework.IsNetworkGame() then
            Swift:CreateRandomSeed();
            if Mission_LocalOnQsbLoaded then
                Mission_LocalOnQsbLoaded();
            end

        -- Send asynchron command to player in multiplayer
        else
            function Swift_Selfload_ReadyTrigger()
                if table.getn(API.GetDelayedPlayers()) == 0 then
                    Swift:CreateRandomSeed();
                    Swift.Event:DispatchScriptCommand(QSB.ScriptCommands.GlobalQsbLoaded, 0);
                    return true;
                end
            end
            StartSimpleHiResJob("Swift_Selfload_ReadyTrigger")
        end        
    ]]);
    API.Install();
    if ModuleKnightTitleRequirements then
        InitKnightTitleTables();
    end
end

