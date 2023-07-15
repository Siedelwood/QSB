QsbWriter_KernelFiles = {
    "swift.lua",
    "luabase.lua",
    "api.lua",
    "debug.lua",
    "event.lua",
    "behavior.lua",
    "bugfixes.lua",
    "selfload.lua",
};

QsbWriter_ModuleFiles = {
    ["Swift_1_DisplayCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_EntityEventCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_InputOutputCore"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_1_InterfaceCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_JobsCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_ScriptingValueCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_SoundCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_1_TradingCore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_2_CastleStore"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_2_EntityMovement"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_2_KnightTitleRequirements"] = {
        "source.lua",
        "api.lua",
        "requirements.lua",
    },

    ["Swift_2_NpcInteraction"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_2_ObjectInteraction"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_2_Quests"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_2_Typewriter"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_3_BehaviorCollection"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_3_BriefingSystem"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_3_CutsceneSystem"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_3_DialogSystem"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_3_WeatherManipulation"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_4_ConstructionAndKnockdown"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_4_LifestockBreeding"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_4_QuestJournal"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_4_Selection"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_4_ShipSalesman"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_ExtendedCamera"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_GraphVizExport"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_InteractiveChests"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_InteractiveMines"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_InteractiveSites"] = {
        "source.lua",
        "api.lua",
    },

    ["Swift_5_Minimap"] = {
        "source.lua",
        "api.lua",
        "behavior.lua",
    },

    ["Swift_5_SpeedLimitation"] = {
        "source.lua",
        "api.lua",
    },
};

function QsbWriter_CompileFiles(_Path)
    QsbWriter_CompileKernel(_Path);
    QsbWriter_CompileModules(_Path);
end

function QsbWriter_CompileKernel(_Path)
    local Content = "";
    for i= 1, #QsbWriter_KernelFiles do
        Content = Content .. QsbWriter_ReadFile(_Path.. "/Swift_0_Core", QsbWriter_KernelFiles[i])
    end
    local FileName = _Path.. "/Swift_0_Core/swift_0_core.lua";
    QsbWriter_WriteFile(FileName, Content);
    os.remove("../../var/build/qsb.lua");
    os.rename(FileName, "../../var/build/qsb.lua");
end

function QsbWriter_CompileModules(_Path)
    for k, v in pairs(QsbWriter_ModuleFiles) do
        local Content = "";
        for i= 1, #v do
            Content = Content .. QsbWriter_ReadFile(_Path.. "/" ..k.. "", v[i]);
        end
        local FileName = _Path.. "/" ..k.. "/" ..k:lower().. ".lua";
        local DestName = "../../var/build/" ..k:lower().. ".lua";
        QsbWriter_WriteFile(FileName, Content);
        os.remove(DestName);
        os.rename(FileName, DestName);
    end
end

function QsbWriter_WriteFile(_Path, _Content)
    local fh = io.open(_Path, "r");
    if fh ~= nil then
        os.remove(_Path);
        fh:close();
    end
    print(_Path)
    local fh = io.open(_Path, "w");
    assert(fh, "Output file can not be created!");
    print("write file to " .._Path);
    fh:write(_Content);
    fh:close();
end

function QsbWriter_ReadFile(_Path, _File)
    local fh = io.open(_Path.. "/" .._File, "r");
    if not fh then
        print("file not found: " ..(_Path.. "/" .._File));
        return "";
    end
    print("loading: " ..(_Path.. "/" .._File));
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end


-- Run
QsbWriter_CompileFiles("../modules");

