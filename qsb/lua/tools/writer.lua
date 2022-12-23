-- Writer
-- This script will build the qsb, the modules and the combined qsb.
-- The script is ment to be used by die build script!
-- Currently it will fail when not run un Windows due to some batch calls
-- executed by lua.

-- List of kernel files
QsbWriter_KernelFiles = {
    "base.lua",
    "lua.lua",
    "logging.lua",
    "event.lua",
    "job.lua",
    "save.lua",
    "chat.lua",
    "text.lua",
    "bugfix.lua",
    "utils.lua",
    "quest.lua",
    "debug.lua",
    "sv.lua",
    "behavior.lua",
    "selfload.lua",
};

-- List of modules and their files
QsbWriter_ModuleFiles = {
    {"QSB_1_Entity", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_GuiControl", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_GuiEffects", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_Requester", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_Movement", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_Sound", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_1_Trade", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_2_BuildRestriction", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_2_BuildingUI", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_2_Camera", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_2_NewBehavior", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_2_NPC", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_2_Objects", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_2_Promotion", {
        "source.lua",
        "api.lua",
        "requirements.lua",
    }},
    {"QSB_2_Quest", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_2_Selection", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_3_BriefingSystem", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_3_CutsceneSystem", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_3_DialogSystem", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_3_Lifestock", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_3_TradeRoutes", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_4_IoMines", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_4_QuestJournal", {
        "source.lua",
        "api.lua",
        "behavior.lua",
    }},
    {"QSB_4_IoSites", {
        "source.lua",
        "api.lua",
    }},
    {"QSB_4_IoTreasure", {
        "source.lua",
        "api.lua",
    }},
};

QsbWriter_Contents = {};

function QsbWriter_CompileFiles(_Path)
    -- Read the files.
    local KernelData = QsbWriter_ReadKernel(_Path);
    local ModuleData = QsbWriter_ReadModules(_Path);

    -- Create the core qsb.
    QsbWriter_CompileKernel(_Path, KernelData);
    -- We must remove selfload from the filed red from the kernel module to
    -- be able to add it at the end of the combined qsb.
    local Selfload = table.remove(KernelData[1][2]);
    -- Create the module files.
    QsbWriter_CompileModules(_Path, ModuleData);
    -- Create the combined qsb.
    QsbWriter_CompileSinglefile(_Path, KernelData, ModuleData, Selfload);
end

function QsbWriter_CompileKernel(_Path, _KernelData)
    local Content = "";
    for i= 1, #_KernelData[1][2] do
        Content = Content .. _KernelData[1][2][i];
    end
    local FilePath = _Path.. "/QSB_0_Kernel/export";
    os.execute("if not exist \"" ..FilePath.. "\" MD \"" ..FilePath.. "\"");
    QsbWriter_WriteFile(FilePath.. "/qsb_0_kernel.lua", Content);
    table.insert(QsbWriter_Contents, Content);
    os.remove("../var/build/qsb.lua");
    os.rename(FilePath.. "/qsb_0_kernel.lua", "../var/build/qsb.lua");
end

function QsbWriter_CompileModules(_Path, _ModuleData)
    for i= 1, #_ModuleData do
        local Content = "";
        for j= 1, #_ModuleData[i][2] do
            Content = Content .. _ModuleData[i][2][j]
        end
        local ModuleName = _ModuleData[i][1];
        local FilePath = _Path.. "/" ..ModuleName.. "/export";
        local DestName = "../var/build/modules/" ..ModuleName;
        os.execute("if not exist \"" ..FilePath.. "\" MD \"" ..FilePath.. "\"");
        os.execute("if not exist \"" ..FilePath.. "/" ..ModuleName.. "\" MD \"" ..FilePath.. "/" ..ModuleName.. "\"");
        QsbWriter_WriteFile(FilePath.. "/" ..ModuleName.. "/"..ModuleName:lower().. ".lua", Content);
        table.insert(QsbWriter_Contents, Content);
        os.remove(DestName);
        os.rename(FilePath.. "/"..ModuleName, DestName);
    end
end

function QsbWriter_CompileSinglefile(_Path, _Kernel, _Modules, _Selfload)
    local Content = "";
    -- Add kernel contents
    for i= 1, #_Kernel[1][2] do
        Content = Content .. _Kernel[1][2][i];
    end
    -- Add module contents
    for i= 1, #_Modules do
        for j= 1, #_Modules[i][2] do
            Content = Content .. _Modules[i][2][j];
        end
    end
    -- Add selfload
    Content = Content .. _Selfload;

    local FileName = _Path.. "/QSB_0_Kernel/export/qsb_idc.lua";
    QsbWriter_WriteFile(FileName, Content);
    os.remove("../var/build/qsb_idc.lua");
    os.rename(FileName, "../var/build/qsb_idc.lua");
end

function QsbWriter_WriteFile(_Path, _Content)
    local fh = io.open(_Path, "r");
    if fh ~= nil then
        os.remove(_Path);
        fh:close();
    end
    local fh = io.open(_Path, "w");
    assert(fh, "Output file can not be created!");
    -- print("write file to " .._Path);
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

function QsbWriter_ReadKernel(_Path)
    local Content = {{"QSB_0_Kernel", {}}};
    for i= 1, #QsbWriter_KernelFiles do
        local Text = QsbWriter_ReadFile(_Path.. "/QSB_0_Kernel", QsbWriter_KernelFiles[i]);
        table.insert(Content[1][2], Text);
    end
    return Content;
end

function QsbWriter_ReadModules(_Path)
    local Content = {};
    for i= 1, #QsbWriter_ModuleFiles do
        table.insert(Content, {QsbWriter_ModuleFiles[i][1], {}});
        for j= 1, #QsbWriter_ModuleFiles[i][2] do
            local Text = QsbWriter_ReadFile(
                _Path.. "/" ..QsbWriter_ModuleFiles[i][1].. "",
                QsbWriter_ModuleFiles[i][2][j]
            );
            table.insert(Content[i][2], Text);
        end
    end
    return Content;
end

-- Run
QsbWriter_CompileFiles("../modules");

