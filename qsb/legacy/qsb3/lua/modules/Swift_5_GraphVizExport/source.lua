--[[
Swift_5_GraphVizExport/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleGraphVizExport = {
    Properties = {
        Name = "ModuleGraphVizExport",
    },

    Global = {},
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleGraphVizExport.Global:OnGameStart()
    QSB.GraphViz:Init();
end

function ModuleGraphVizExport.Global:ExecuteGraphVizExport()
    Framework.WriteToLog("\n\n\n==== GraphViz Export Start ====\n\n\n");
    local DOT = QSB.GraphViz:ConvertQuests();
    ModuleGraphVizExport.Global:WriteLinewiseToLog(DOT);
    Framework.WriteToLog("\n\n\n==== GraphViz Export Ende ====\n\n\n");
    return DOT;
end

function ModuleGraphVizExport.Global:WriteLinewiseToLog(_String)
    local Slices = self:SplitString(_String);
    for i= 1, #Slices, 1 do
        Framework.WriteToLog(Slices[i]);
    end
end

function ModuleGraphVizExport.Global:SplitString(_String)
    local Table = {};
    local s, e = _String:find("\n");
    while e do
        table.insert(Table, _String:sub(1, e-1));
        _String = _String:sub(e+1);
        s, e = _String:find("\n");
    end
    table.insert(Table, _String);
    return Table;
end

-- Local Script ----------------------------------------------------------------

function ModuleGraphVizExport.Local:OnGameStart()
    QSB.GraphViz = nil;
end

-- -------------------------------------------------------------------------- --

QSB.GraphViz = {
    SourceFile = "",
    Quests = {}
}

---
-- Initialisiert den DOT-Parser. 
--
-- @within Internal
-- @local
--
function QSB.GraphViz:Init()
    API = API or {};
    CreateQuest_Orig_ModuleGraphVizExport = API.CreateQuest;
    API.CreateQuest = function(_Data)
        local QuestName, QuestAmount = CreateQuest_Orig_ModuleGraphVizExport(_Data);
        if not QuestName:find("DialogSystemQuest") then
            local Data = QSB.GraphViz:AddQuestDefaults(table.copy(_Data));
            QSB.GraphViz.Quests[#QSB.GraphViz.Quests+1] = Data;
        end
        return QuestName, QuestAmount;
    end
    AddQuest = API.CreateQuest;
end

---
-- Ergänzt die Questdaten um Defaultwerte.
--
-- @param[type=table] _Data Questdaten
-- @return[type=table] Questdaten um Defaults ergänzt
-- @within Internal
-- @local
--
function QSB.GraphViz:AddQuestDefaults(_Data)
    _Data.Sender        = _Data.Sender or 1;
    _Data.Receiver      = _Data.Receiver or 1;
    _Data.Time          = _Data.Time or 0;
    _Data.Visible       = (_Data.Visible == true or _Data.Suggestion ~= nil);
    _Data.EndMessage    = _Data.EndMessage == true or (_Data.Failure ~= nil or _Data.Success ~= nil);
    if _Data.Suggestion then
        _Data.Suggestion = API.Localize(_Data.Suggestion);
    end
    if _Data.Success then
        _Data.Success = API.Localize(_Data.Success);
    end
    if _Data.Failure then
        _Data.Failure = API.Localize(_Data.Failure);
    end
    if _Data.Description then
        _Data.Description = API.Localize(_Data.Description);
    end
    return _Data;
end

---
-- Erzeugt einen Graph aus allen vorhandenen Quests.
--
-- @return[type=string] GraphViz Output
-- @within Internal
-- @local
--
function QSB.GraphViz:ConvertQuests()
    local MapName = Framework.GetCurrentMapName();
    local DOT = "";
    DOT = DOT .. '\ndigraph G { graph [    fontname = "Helvetica-Oblique", fontsize = 30, label = "'..MapName.. '" ] \nnode [ fontname = "Courier-Bold" shape = "box" ] \n';
    for i= 1, #QSB.GraphViz.Quests, 1 do
        for k, v in pairs(QSB.GraphViz:ConvertQuest(QSB.GraphViz.Quests[i])) do 
            DOT = DOT .. "    " .. v .. " \n";
        end
    end
    DOT = DOT .. '} \n';
    return DOT;
end

---
-- Erzeug DOT-Notation zum übergebenen Quest.
--
-- <b>TODO</b>: Diese Methode ist absolut grottiger Code aus tiefster
-- Siedler-6-Urzeit. Das muss unbedingt mal auseinander gezogen und in
-- guter Code Qualität neu geschrieben werden!
--
-- @param[type=table] _Quest Zu visualisierender Quest
-- @return[type=string] GraphViz Output
-- @within Internal
-- @local
--
function QSB.GraphViz:ConvertQuest(_Quest)
    local result = {};
    local ArrowColorTable = {
        Succeed = 'color="#00ff00"',
        Fail = 'color="#ff0000"',
        Interrupt = 'color="#999999"',
        Default = 'color="#0000ff"'
    };
    local function EscapeString( _String )
        return string.match( string.format( "%q", tostring(_String) ), '^"(.*)"$' ) or "nil";
    end
    local function LimitString( _String, _Limit )
        assert( _String );
        assert( _Limit > 3 );
        if string.len( _String ) <= _Limit then
            return _String;
        else
            return string.sub( _String, 1, _Limit - 3 ) .. "...";
        end
    end

    local fontColor = ""
    local BehaviorList = {}
    local bTableCounter = 0    
    for i= 1, #_Quest, 1 do
        local BehaviorName = _Quest[i].Name;
        local ArrowColor = (string.find( BehaviorName, "Succe" ) and ArrowColorTable.Succeed)
                or (string.find( BehaviorName, "Fail" )and ArrowColorTable.Fail)
                or (string.find( BehaviorName, "Interrupt" )and ArrowColorTable.Interrupt)
                or ArrowColorTable.Default;
        local fontColor = (string.find( BehaviorName, "Wait" ) and 'fontcolor="red"') or "";
        local BDependsOn = string.find(BehaviorName, "Goal") ~= nil or string.find(BehaviorName, "Trigger") ~= nil;

        local BehaviorData = _Quest[i].Name .. "(";
        if _Quest[i].Parameter then
            for j= 1, #_Quest[i].Parameter do
                if (j > 1) then
                    BehaviorData = BehaviorData .. ", ";
                end
                local Parameter = "nil";
                if _Quest[i].v12ya_gg56h_al125[j] then
                    Parameter =_Quest[i].v12ya_gg56h_al125[j];
                    if type(Parameter) == "string" then
                        Parameter = "'" ..Parameter.. "'";
                    end
                end
                BehaviorData = BehaviorData .. tostring(Parameter);
                
                if (_Quest[i].Parameter[j][1] == ParameterType.QuestName) then
                    table.insert(
                        result,
                        (BDependsOn and string.format(
                            '%q -> %q [%s]',
                            _Quest[i].v12ya_gg56h_al125[j],
                            _Quest.Name,
                            ArrowColor
                        )) or 
                        string.format(
                            '%q -> %q [%s, arrowhead = "odot", arrowtail = "invempty" style="dashed"]',
                            _Quest.Name,
                            _Quest[i].QuestName,
                            ArrowColor
                        )
                    );
                end
            end
        end
        BehaviorData = BehaviorData .. ")";
        table.insert(BehaviorList, BehaviorData);
    end

    local Desc = EscapeString(LimitString(_Quest.Description or "", 80));
    Desc = (Desc ~= "" and "\\nDescription: '" ..Desc.. "'") or "";
    local Sugg = EscapeString(LimitString(_Quest.Suggestion or "", 80));
    Sugg = (Sugg ~= "" and "\\nSuggestion: '" ..Sugg.. "'") or "";
    local Fail = EscapeString(LimitString(_Quest.Failure or "", 80));
    Fail = (Fail ~= "" and "\\nFailure: '" ..Fail.. "'") or "";
    local Succ = EscapeString(LimitString(_Quest.Success or "", 80));
    Succ = (Succ ~= "" and "\\nSuccess: '" ..Succ.. "'") or "";

    local SenderReceiver = "\\n=== " .._Quest.Sender.."  ->  " .._Quest.Receiver.. " ===";
    table.sort(BehaviorList);
    table.insert(result, string.format(
        '%q [ %s label = "%s%s%s%s%s%s%s\\n\\n%s" %s%s]',
        _Quest.Name,
        fontColor,
        EscapeString(_Quest.Name),
        SenderReceiver,
        Sugg,
        Fail,
        Succ,
        Desc,
        _Quest.Time ~= 0 and ('\\nTime: ' .. _Quest.Time) or '',
        table.concat(BehaviorList, "\\n"),
        _Quest.Time ~= 0 and 'shape="octagon" ' or '',
        not _Quest.Visible and 'style="filled" fillcolor="#dddddd" ' or '' )
    );
    return result;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleGraphVizExport);

