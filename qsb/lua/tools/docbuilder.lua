local htmlparser = require("htmlparser");

-- -------------------------------------------------------------------------- --

QsbDoc_FileList = {
    {"qsb.lua",                                                     "(0) Basismodul"},
    {"modules/QSB_1_GuiEffects/qsb_1_guieffects.lua",               "(1) Anzeigeeffekte"},
    {"modules/QSB_1_GuiControl/qsb_1_guicontrol.lua",               "(1) Anzeigesteuerung"},
    {"modules/QSB_1_Movement/qsb_1_movement.lua",                   "(1) Bewegung"},
    {"modules/QSB_1_Requester/qsb_1_requester.lua",                 "(1) Dialogfenster"},
    {"modules/QSB_1_Entity/qsb_1_entity.lua",                       "(1) Entitätensteuerung"},
    {"modules/QSB_1_Trade/qsb_1_trade.lua",                         "(1) Handelserweiterung"},
    {"modules/QSB_1_Sound/qsb_1_sound.lua",                         "(1) Sound"},
    {"modules/QSB_2_NPC/qsb_2_npc.lua",                             "(2) Ansprechbare Siedler"},
    {"modules/QSB_2_Promotion/qsb_2_promotion.lua",                 "(2) Aufstiegsbedingungen"},
    {"modules/QSB_2_Quest/qsb_2_quest.lua",                         "(2) Aufträge"},
    {"modules/QSB_2_BuildRestriction/qsb_2_buildrestriction.lua",   "(2) Baubeschränkung"},
    {"modules/QSB_2_BuildingUI/qsb_2_buildingui.lua",               "(2) Gebäudeschalter"},
    {"modules/QSB_2_Objects/qsb_2_objects.lua",                     "(2) Interaktive Objekte"},
    {"modules/QSB_2_Camera/qsb_2_camera.lua",                       "(2) Kamerafunktionen"},
    {"modules/QSB_2_NewBehavior/qsb_2_newbehavior.lua",             "(2) Neue Behavior"},
    {"modules/QSB_2_Selection/qsb_2_selection.lua",                 "(2) Selektion"},
    {"modules/QSB_3_BriefingSystem/qsb_3_briefingsystem.lua",       "(3) Briefing System"},
    {"modules/QSB_3_CutsceneSystem/qsb_3_cutscenesystem.lua",       "(3) Cutscene System"},
    {"modules/QSB_3_DialogSystem/qsb_3_dialogsystem.lua",           "(3) Dialog System"},
    {"modules/QSB_3_TradeRoutes/qsb_3_traderoutes.lua",             "(3) Handelsrouten"},
    {"modules/QSB_3_Lifestock/qsb_3_lifestock.lua",                 "(3) Viehzucht"},
    {"modules/QSB_4_QuestJournal/qsb_4_questjournal.lua",           "(4) Auftragsnotizen"},
    {"modules/QSB_4_IoSites/qsb_4_iosites.lua",                     "(4) Interaktive Baustellen"},
    {"modules/QSB_4_IoMines/qsb_4_iomines.lua",                     "(4) Interaktive Minen"},
    {"modules/QSB_4_IoTreasure/qsb_4_iotreasure.lua",               "(4) Interaktive Schätze"},
};

QsbDoc_Data = {
    Modules = {},
    Parsed = {},
};

-- -------------------------------------------------------------------------- --

function QsbDoc_CreateDocumentationIndex()
    local FileText = QsbDoc_LoadDocumentationIndexTemplate();

    local BundleList = "";
    for i= 1, #QsbDoc_Data.Modules do
        if QsbDoc_Data.Modules[i].Name then
            BundleList = BundleList .. QsbDoc_CreateDocumentationIndexLink(
                QsbDoc_Data.Modules[i].Name,
                QsbDoc_Data.Modules[i].DisplayName
            );
        end
    end

    FileText = FileText:gsub("###PLACEHOLDER_LUA_BUNDLES###", BundleList);
    FileText = FileText:gsub("###PLACEHOLDER_DIRECT_LINK###", QsbDoc_GetDirectLinks());
    FileText = FileText:gsub("###PLACEHOLDER_BUNDLE_LINK###", QsbDoc_GetBundleLinks());

    os.remove("../var/build/doc/index.html");
    local fh = io.open("../var/build/doc/index.html", "w");
    assert(fh, "File not created: index.html");
    fh:write(FileText);
    fh:close();
end

function QsbDoc_GetDirectLinks()
    local Format = '<div id="%s" class="result method"><a href="%s">%s</a><br>%s<span class="docInvisibleContent">%s</span></div>';
    local HTML = "";

    for i= 1, #QsbDoc_Data.Modules, 1 do
        for k, v in pairs(QsbDoc_Data.Modules[i].Data) do
            local Link = "modules/" ..v[1].. ".html#" ..v[2];
            local Name = v[2]:gsub(".lua", "");
            HTML = HTML .. string.format(
                Format,
                v[1].. "." ..Name:lower(),
                Link,
                Name,
                v[3],
                v[4] or ""
            );
        end
    end
    return HTML;
end

function QsbDoc_GetBundleLinks()
    local Format = '<div id="%s" class="result module"><a href="%s">%s</a><br>%s</div>';

    local Bundles = {};
    for k, v in pairs(QsbDoc_Data.Modules) do
        table.insert(
            Bundles,
            string.format(
                Format,
                v.Name,
                "modules/" ..v.Name.. ".html",
                v.Name or "",
                v.Description or ""
            )
        )
    end

    local function sortTable(a, b)
        return a < b;
    end
    table.sort(Bundles, sortTable);
    return table.concat(Bundles);
end

function QsbDoc_CreateDocumentationIndexLink(_Name, _Display)
    local fh = io.open("../../templates/index.panel.template.html", "r");
    assert(fh, "File not found: index.panel.template.html");
    fh:seek("set", 0);

    local HTML = fh:read("*all");
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_NAME###", _Display);
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_LINK###", "modules/" .._Name:lower().. ".html");
    return HTML
end

function QsbDoc_LoadDocumentationIndexTemplate()
    local fh = io.open("../../templates/index.template.html", "rb");
    assert(fh, "File not found: index.template.html");
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

-- -------------------------------------------------------------------------- --

function QsbDoc_ReadModules()
    local ModuleList = {};
    for i= 1, #QsbDoc_FileList do
        local File = QsbDoc_FileList[i][1]
            :gsub(".lua", "")
            :gsub("/", ".")
            :lower();

        local Name = QsbDoc_FileList[i][2]

        table.insert(ModuleList, {File, Name});
    end
    for i=1, #ModuleList do
        QsbDoc_ReadModule(ModuleList[i]);
    end
end

function QsbDoc_ReadModule(_Module)
    QsbDoc_Data[_Module[1]] = {};

    local HTML = QsbDoc_ParseHtml(_Module[1]:gsub("\\.lua", ""));
    if HTML then
        local index = #QsbDoc_Data.Modules;

        QsbDoc_Data.Modules[index+1] = {};
        QsbDoc_Data.Modules[index+1].Name = _Module[1];
        QsbDoc_Data.Modules[index+1].DisplayName = _Module[2];
        QsbDoc_Data.Modules[index+1].Description = "";
        QsbDoc_Data.Modules[index+1].HTML = HTML;

        -- Read infos
        local Description = HTML:select("#content > p");
        if #Description > 0 then
            QsbDoc_Data.Modules[index+1].Description = Description[1]:getcontent():gsub("\n", "");
        end
        QsbDoc_Data.Modules[index+1].Data = {};

        local anchors = HTML:select("dt a");
        for i= 1, #anchors, 1 do
            local href = anchors[i]:gettext():gsub('<a name = "', ""):gsub('"></a>', "");
            QsbDoc_Data.Modules[index+1].Data[i] = {_Module[1], href};
        end
        local summary = HTML:select(".summary");
        for i= 1, #summary, 1 do
            QsbDoc_Data.Modules[index+1].Data[i][3] = summary[i]:getcontent():gsub("\n", "");
        end
        local info = HTML:select("dd");
        for i= 1, #info, 1 do
            local Content = info[i]:getcontent():gsub("<", "&#x3C;"):gsub(">", "&#x3E;");
            QsbDoc_Data.Modules[index+1].Data[i][4] = Content;
        end
    end
end

function QsbDoc_ParseHtml(_Module)
    if QsbDoc_Data.Parsed[_Module] then
        return false;
    end
    QsbDoc_Data.Parsed[_Module] = true;

    local Path = "../var/build/doc/modules/" .._Module.. ".html";
    local fh = io.open(Path, "r");
    if not fh then
        print ("Could not parse file: ", Path);
        return false;
    end
    return htmlparser.parse(fh:read("*all"), 999999);
end

-- -------------------------------------------------------------------------- --

function QsbDoc_ReplaceInHtmlFiles()
    local Content = QsbDoc_ReadFile("../var/build/doc/index.html");
    for i= 1, #QsbDoc_Data.Modules do
        local ModuleName = QsbDoc_Data.Modules[i].Name:gsub("\\.lua", "");
        local DisplayName = QsbDoc_Data.Modules[i].DisplayName;
        Content = Content:gsub(ModuleName.. "</a>", DisplayName.. "</a>");
        QsbDoc_ReplaceInHtmlFile(QsbDoc_Data.Modules[i]);
    end
    QsbDoc_WriteFile("../var/build/doc/index.html", Content);
end

function QsbDoc_ReplaceInHtmlFile(_Module)
    local Name = _Module.Name:gsub("\\.lua", "");
    local Path = "../var/build/doc/modules/" ..Name.. ".html";
    local Content = QsbDoc_ReadFile(Path);

    -- Replace names
    for i= 1, #QsbDoc_Data.Modules do
        local ModuleName = QsbDoc_Data.Modules[i].Name:gsub("\\.lua", "");
        local DisplayName = QsbDoc_Data.Modules[i].DisplayName;

        Content = Content:gsub("<strong>" ..ModuleName.. "</strong>", "<strong>" ..DisplayName.. "</strong>");
        Content = Content:gsub("<code>" ..ModuleName.. "</code>", "<code>" ..DisplayName.. "</code>");
        Content = Content:gsub(ModuleName.. "</a></li>", DisplayName.. "</a></li>");
    end
    -- replace file
    QsbDoc_WriteFile(Path, Content);
end

function QsbDoc_WriteFile(_Path, _Content)
    local fh = io.open(_Path, "r");
    if fh ~= nil then
        os.remove(_Path);
        fh:close();
    end
    local fh = io.open(_Path, "w");
    assert(fh, "Output file can not be created!");
    fh:write(_Content);
    fh:close();
end

function QsbDoc_ReadFile(_Path)
    local fh = io.open(_Path, "r");
    if not fh then
        print("file not found: " .._Path);
        return "";
    end
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

-- -------------------------------------------------------------------------- --

QsbDoc_ReadModules();
QsbDoc_CreateDocumentationIndex();
QsbDoc_ReplaceInHtmlFiles();

