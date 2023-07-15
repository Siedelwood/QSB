local htmlparser = require("htmlparser");
dofile("loader.lua");

BinDocBuilder_Data = {
    Extensions = {".api", ".behavior", ".debug", ".callback", ".requirements", ".sample"},
    Modules = {},
    Parsed = {},
};

function BinDocBuilder_CreateDocumentationIndex()
    local FileText = BinDocBuilder_LoadDocumentationIndexTemplate();

    local BundleList = "";
    for i= 1, #BinDocBuilder_Data.Modules do
        if BinDocBuilder_Data.Modules[i].Name then
            BundleList = BundleList .. BinDocBuilder_CreateDocumentationIndexLink(BinDocBuilder_Data.Modules[i].Name);
        end
    end

    FileText = FileText:gsub("###PLACEHOLDER_LUA_BUNDLES###", BundleList);
    FileText = FileText:gsub("###PLACEHOLDER_DIRECT_LINK###", BinDocBuilder_GetDirectLinks());
    FileText = FileText:gsub("###PLACEHOLDER_BUNDLE_LINK###", BinDocBuilder_GetBundleLinks());

    os.remove("../../doc/html/index.html");
    local fh = io.open("../../doc/html/index.html", "wt");
    assert(fh, "File not created: index.html");
    fh:write(FileText);
    fh:close();
end

function BinDocBuilder_GetDirectLinks()
    local Template = '<div id="%s" class="result method"><a href="%s">%s</a><br>%s<span class="docInvisibleContent">%s</span></div>';
    local HTML = "";

    for i= 1, #BinDocBuilder_Data.Modules, 1 do
        for k, v in pairs(BinDocBuilder_Data.Modules[i].Data) do
            local Link = "modules/" ..v[1].. ".html#" ..v[2];
            local Name = v[2]:gsub(".lua", "");
            HTML = HTML .. string.format(Template, v[1].. "." ..Name:lower(), Link, Name, v[3], v[4] or "");
        end
    end
    return HTML;
end

function BinDocBuilder_GetBundleLinks()
    local Template = '<div id="%s" class="result module"><a href="%s">%s</a><br>%s</div>';

    local Bundles = {};
    for k, v in pairs(BinDocBuilder_Data.Modules) do
        table.insert(
            Bundles, string.format(Template, v.Name, "modules/" ..v.Name.. ".html", v.Name or "", v.Description or "")
        )
    end

    local function sortTable(a, b)
        return a < b;
    end
    table.sort(Bundles, sortTable);
    return table.concat(Bundles);
end

function BinDocBuilder_CreateDocumentationIndexLink(_Name)
    local fh = io.open("../../tpl/index.panel.template.html", "rt");
    assert(fh, "File not found: index.panel.template.html");
    fh:seek("set", 0);

    local HTML = fh:read("*all");
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_NAME###", _Name);
    HTML = HTML:gsub("###PLACEHOLDER_BUNDLE_LINK###", "modules/" .._Name:lower().. ".html");
    return HTML
end

function BinDocBuilder_LoadDocumentationIndexTemplate()
    local fh = io.open("../../tpl/index.template.html", "rb");
    assert(fh, "File not found: index.template.html");
    fh:seek("set", 0);
    local Contents = fh:read("*all");
    fh:close();
    return Contents;
end

function BinDocBuilder_ReadModules()
    local ModuleList = {};
    for i= 1, #BinLoader_CoreFiles do
        ModuleList[#ModuleList+1] = BinLoader_CoreFiles[i]
            :gsub(".lua", "")
            :gsub("/", ".")
            :lower();
    end
    for i= 1, #BinLoader_ModuleFiles do
        ModuleList[#ModuleList+1] = BinLoader_ModuleFiles[i]
            :gsub(".lua", "")
            :gsub("/", ".")
            :lower();
    end

    -- DEBUG print PWD
    -- local OsName = BinDocBuilder_GetOsName();
    -- if OsName:find("Windows") or OsName:find("MINGW") then
    --     os.execute("echo %cd%");
    -- else
    --     os.execute("echo $PWD");
    -- end

    for i=1, #ModuleList do
        BinDocBuilder_ReadModule(ModuleList[i]);
    end

    -- DEBUG print contents
    -- for i=1, #BinDocBuilder_Data.Modules do
    --     print(BinDocBuilder_Data.Modules[i].Name);
    --     print(BinDocBuilder_Data.Modules[i].Description);
    --     for j= 1, #BinDocBuilder_Data.Modules[i].Data do
    --         print(BinDocBuilder_Data.Modules[i].Data[j]);
    --     end
    -- end
end

function BinDocBuilder_ReadModule(_Module)
    BinDocBuilder_Data[_Module] = {};
    for k, v in pairs(BinDocBuilder_Data.Extensions) do
        if (_Module:find(v)) then
            local HTML = BinDocBuilder_ParseHTML(_Module);
            if HTML then
                local index = #BinDocBuilder_Data.Modules;

                BinDocBuilder_Data.Modules[index+1] = {};
                BinDocBuilder_Data.Modules[index+1].Name = _Module;
                BinDocBuilder_Data.Modules[index+1].Description = "";
                local Description = HTML:select("#content > p");
                if #Description > 0 then
                    BinDocBuilder_Data.Modules[index+1].Description = Description[1]:getcontent():gsub("\n", "");
                end
                BinDocBuilder_Data.Modules[index+1].Data = {};

                local anchors = HTML:select("dt a");
                for i= 1, #anchors, 1 do
                    local href = anchors[i]:gettext():gsub('<a name = "', ""):gsub('"></a>', "");
                    BinDocBuilder_Data.Modules[index+1].Data[i] = {_Module, href};
                end
                local summary = HTML:select(".summary");
                for i= 1, #summary, 1 do
                    BinDocBuilder_Data.Modules[index+1].Data[i][3] = summary[i]:getcontent():gsub("\n", "");
                end
                local info = HTML:select("dd");
                for i= 1, #info, 1 do
                    local Content = info[i]:getcontent():gsub("<", "&#x3C;"):gsub(">", "&#x3E;");
                    BinDocBuilder_Data.Modules[index+1].Data[i][4] = Content;
                end
            end
        end
    end
end

function BinDocBuilder_ParseHTML(_Module)
    if BinDocBuilder_Data.Parsed[_Module] then
        return false;
    end
    BinDocBuilder_Data.Parsed[_Module] = true;

    local Path = "../../doc/html/modules/" .._Module.. ".html";
    local fh = io.open(Path, "rt");
    if not fh then
        print ("Could not parse file: ", Path);
        return false;
    end
    return htmlparser.parse(fh:read("*all"), 999999);
end

function BinDocBuilder_GetOsName()
    local raw_os_name;
    local popen_status, popen_result = pcall(io.popen, "")
    if popen_status then
        popen_result:close()
        raw_os_name = io.popen('uname -s','r'):read('*l')
    else
        local env_OS = os.getenv('OS')
        ---@diagnostic disable-next-line: undefined-global
        if env_OS and env_ARCH then
            raw_os_name = env_OS
        end
    end
    return raw_os_name;
end

function BinDocBuilder_GetBuildCommand()
    local docCommand = "cd ../bin && bash.exe ./createdoc";
    local osName = BinDocBuilder_GetOsName();
    if osName and osName:find("Linux") then
        docCommand = "cd ../bin && ./createdoc";
    end
    return docCommand;
end

-- -------------------------------------------------------------------------- --

BinDocBuilder_ReadModules();
BinDocBuilder_CreateDocumentationIndex();

