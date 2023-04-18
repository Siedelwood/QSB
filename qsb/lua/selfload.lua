-- -------------------------------------------------------------------------- --

if not MapEditor and not GUI then
    local MapTypeFolder = "externalmap";
    local MapType, Campaign = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType ~= 3 then
        MapTypeFolder = "development";
    end

    gvMission = gvMission or {};
    gvMission.ContentPath      = "maps/" ..MapTypeFolder.. "/" ..Framework.GetCurrentMapName() .. "/";
    gvMission.MusicRootPath    = gvMission.ContentPath.. "music/";
    gvMission.PlaylistRootPath = "config/sound/";

    Logic.ExecuteInLuaLocalState([[
        gvMission = gvMission or {};
        gvMission.GlobalVariables = Logic.CreateReferenceToTableInGlobaLuaState("gvMission");
        gvMission.ContentPath      = "maps/]] ..MapTypeFolder.. [[/" ..Framework.GetCurrentMapName() .. "/";
        gvMission.MusicRootPath    = gvMission.ContentPath.. "music/";
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

