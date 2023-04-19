local htmlparser = require("htmlparser");

-- -------------------------------------------------------------------------- --

QsbDoc_FileList = {
{"qsb.lua", "(0) Basismodul"},
{"smodules/qsb_1_entity.lua", "(1) Entitätensteuerung"},
{"smodules/qsb_1_guicontrol.lua", "(1) Anzeigesteuerung"},
{"smodules/qsb_1_guieffects.lua", "(1) Anzeigeeffekte"},
{"smodules/qsb_1_movement.lua", "(1) Bewegung"},
{"smodules/qsb_1_requester.lua", "(1) Dialogfenster"},
{"smodules/qsb_1_sound.lua", "(1) Sound"},
{"smodules/qsb_1_trade.lua", "(1) Handelserweiterung"},
{"smodules/qsb_2_buildrestriction.lua", "(2) Baubeschränkung"},
{"smodules/qsb_2_buildingcost.lua", "(2) Baukostensystem"},
{"smodules/qsb_2_buildingui.lua", "(2) Gebäudeschalter"},
{"smodules/qsb_2_camera.lua", "(2) Kamerafunktionen"},
{"smodules/qsb_2_npc.lua", "(2) Ansprechbare Siedler"},
{"smodules/qsb_2_newbehavior.lua", "(2) Neue Behavior"},
{"smodules/qsb_2_objects.lua", "(2) Interaktive Objekte"},
{"smodules/qsb_2_promotion.lua", "(2) Aufstiegsbedingungen"},
{"smodules/qsb_2_quest.lua", "(2) Aufträge"},
{"smodules/qsb_2_selection.lua", "(2) Selektion"},
{"smodules/qsb_3_briefingsystem.lua", "(3) Briefing System"},
{"smodules/qsb_3_cutscenesystem.lua", "(3) Cutscene System"},
{"smodules/qsb_3_dialogsystem.lua", "(3) Dialog System"},
{"smodules/qsb_3_lifestock.lua", "(3) Viehzucht"},
{"smodules/qsb_3_militarylimit.lua", "(3) Soldatenlimit"},
{"smodules/qsb_3_traderoutes.lua", "(3) Handelsrouten"},
{"smodules/qsb_4_iomines.lua", "(4) Interaktive Minen"},
{"smodules/qsb_4_iosites.lua", "(4) Interaktive Baustellen"},
{"smodules/qsb_4_iotreasure.lua", "(4) Interaktive Schätze"},
{"smodules/qsb_4_questjournal.lua", "(4) Auftragsnotizen"},
{"tqsb_x_acomp.lua", "(X) Kompatibilität"},
{"xaddons/qsb_x_addon_1_singlebuttons.lua", "Addon (1) SingleButtons"},
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

    os.remove("build/doc/index.html");
    local fh = io.open("build/doc/index.html", "w");
    assert(fh, "File not created: index.html");
    fh:write(FileText);
    fh:close();
end

function QsbDoc_GetDirectLinks()
    local Format = [[
        <div id="%s" class="result method">
            <!-- Display text -->
            <a href="%s">%s</a><br>%s%s
            <!-- Full text search target -->
            <span class="docInvisibleContent">%s</span>
        </div>
    ]];
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
                QsbDoc_FormatTagsInHtml(v[5] or ""),
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
            local s, e = info[i]:getcontent():find("<tags>[a-z0-9, -]+</tags>");
            if s and e then
                QsbDoc_Data.Modules[index+1].Data[i][5] = info[i]:getcontent():sub(s, e);
            end
        end
    end
end

function QsbDoc_ParseHtml(_Module)
    if QsbDoc_Data.Parsed[_Module] then
        return false;
    end
    QsbDoc_Data.Parsed[_Module] = true;

    local Path = "build/doc/modules/" .._Module.. ".html";
    local fh = io.open(Path, "r");
    if not fh then
        print ("Could not parse file: ", Path);
        return false;
    end
    return htmlparser.parse(fh:read("*all"), 999999);
end

-- -------------------------------------------------------------------------- --

function QsbDoc_ReplaceInHtmlFiles()
    local Content = QsbDoc_ReadFile("build/doc/index.html");
    for i= 1, #QsbDoc_Data.Modules do
        local ModuleName = QsbDoc_Data.Modules[i].Name:gsub("\\.lua", "");
        local DisplayName = QsbDoc_Data.Modules[i].DisplayName;
        Content = Content:gsub(ModuleName.. "</a>", DisplayName.. "</a>");
        QsbDoc_ReplaceInHtmlFile(QsbDoc_Data.Modules[i]);
    end
    QsbDoc_WriteFile("build/doc/index.html", Content);
end

function QsbDoc_ReplaceInHtmlFile(_Module)
    local Name = _Module.Name:gsub("\\.lua", "");
    local Path = "build/doc/modules/" ..Name.. ".html";
    local Content = QsbDoc_ReadFile(Path);

    -- Replace names
    for i= 1, #QsbDoc_Data.Modules do
        local ModuleName = QsbDoc_Data.Modules[i].Name:gsub("\\.lua", "");
        local DisplayName = QsbDoc_Data.Modules[i].DisplayName;

        Content = Content:gsub("<strong>" ..ModuleName.. "</strong>", "<strong>" ..DisplayName.. "</strong>");
        Content = Content:gsub("<code>" ..ModuleName.. "</code>", "<code>" ..DisplayName.. "</code>");
        Content = Content:gsub(ModuleName.. "</a></li>", DisplayName.. "</a></li>");
        Content = QsbDoc_FormatTagsInHtml(Content);
    end
    -- replace file
    QsbDoc_WriteFile(Path, Content);
end

function QsbDoc_FormatTagsInHtml(_Content)
    local Content = _Content;
    if Content then
        local s, e = Content:find("<tags>[a-z0-9, -]+</tags>");
        while s and e do
            local Before = Content:sub(0, s-1);
            local After = Content:sub(e+1);
            local Inner = Content:sub(s+6, e-7);

            local TagList = "";
            for str in Inner:gmatch("([^,]+)") do
                TagList = TagList .. "<li>" ..str:gsub("%s", "").. "</li>";
            end
            local Tags = string.format("<ul class=\"tags-inline\">%s</ul>", TagList);

            Content = Before .. Tags .. After;
            s, e = Content:find("<tags>[a-z0-9, -]+</tags>");
        end
    end
    return Content;
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

