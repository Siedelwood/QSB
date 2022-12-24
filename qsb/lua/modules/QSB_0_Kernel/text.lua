--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Multilinguale Texte und Platzhalterersetzung in Texten.
-- @set sort=true
-- @local
--

Swift.Text = {
    Languages = {
        {"de", "Deutsch", "en"},
        {"en", "English", "en"},
        {"fr", "Français", "en"},
    },

    Colors = {
        red     = "{@color:255,80,80,255}",
        blue    = "{@color:104,104,232,255}",
        yellow  = "{@color:255,255,80,255}",
        green   = "{@color:80,180,0,255}",
        white   = "{@color:255,255,255,255}",
        black   = "{@color:0,0,0,255}",
        grey    = "{@color:140,140,140,255}",
        azure   = "{@color:0,160,190,255}",
        orange  = "{@color:255,176,30,255}",
        amber   = "{@color:224,197,117,255}",
        violet  = "{@color:180,100,190,255}",
        pink    = "{@color:255,170,200,255}",
        scarlet = "{@color:190,0,0,255}",
        magenta = "{@color:190,0,89,255}",
        olive   = "{@color:74,120,0,255}",
        sky     = "{@color:145,170,210,255}",
        tooltip = "{@color:51,51,120,255}",
        lucid   = "{@color:0,0,0,0}",
        none    = "{@color:none}"
    },

    Placeholders = {
        Names = {},
        EntityTypes = {},
    },
}

QSB.Language = "de";

function Swift.Text:Initalize()
    QSB.ScriptEvents.LanguageSet = Swift.Event:CreateScriptEvent("Event_LanguageSet");
    self:DetectLanguage();
end

function Swift.Text:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Language

function Swift.Text:DetectLanguage()
    local DefaultLanguage = Network.GetDesiredLanguage();
    if DefaultLanguage ~= "de" and DefaultLanguage ~= "fr" then
        DefaultLanguage = "en";
    end
    QSB.Language = DefaultLanguage;
end

function Swift.Text:OnLanguageChanged(_PlayerID, _GUI_PlayerID, _Language)
    self:ChangeSystemLanguage(_PlayerID, _Language, _GUI_PlayerID);
end

function Swift.Text:ChangeSystemLanguage(_PlayerID, _Language, _GUI_PlayerID)
    local OldLanguage = QSB.Language;
    local NewLanguage = _Language;
    if _GUI_PlayerID == nil or _GUI_PlayerID == _PlayerID then
        QSB.Language = _Language;
    end

    Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.LanguageSet, OldLanguage, NewLanguage);
    Logic.ExecuteInLuaLocalState(string.format(
        [[
            local OldLanguage = "%s"
            local NewLanguage = "%s"
            if GUI.GetPlayerID() == %d then
                QSB.Language = NewLanguage
            end
            Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.LanguageSet, OldLanguage, NewLanguage)
        ]],
        OldLanguage,
        NewLanguage,
        _PlayerID
    ));
end

function Swift.Text:Localize(_Text)
    local LocalizedText;
    if type(_Text) == "table" then
        LocalizedText = {};
        if _Text.en == nil and _Text[QSB.Language] == nil then
            for k,v in pairs(_Text) do
                if type(v) == "table" then
                    LocalizedText[k] = self:Localize(v);
                end
            end
        else
            if _Text[QSB.Language] then
                LocalizedText = _Text[QSB.Language];
            else
                for k, v in pairs(self.Languages) do
                    if v[1] == QSB.Language and v[3] ~= nil then
                        LocalizedText = _Text[v[3]];
                        break;
                    end
                end
            end
            if type(LocalizedText) == "table" then
                LocalizedText = "ERROR_NO_TEXT";
            end
        end
    else
        LocalizedText = tostring(_Text);
    end
    return LocalizedText;
end

-- -------------------------------------------------------------------------- --
-- Placeholder

function Swift.Text:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{n:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{n:");
            Replacement = self.Placeholders.Names[Placeholder];
            _Text = Before .. self:Localize(Replacement or ("n:" ..tostring(Placeholder).. ": not found")) .. After;
        elseif _Text:find("{t:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{t:");
            Replacement = self.Placeholders.EntityTypes[Placeholder];
            _Text = Before .. self:Localize(Replacement or ("n:" ..tostring(Placeholder).. ": not found")) .. After;
        elseif _Text:find("{v:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{v:");
            Replacement = self:ReplaceValuePlaceholder(Placeholder);
            _Text = Before .. self:Localize(Replacement or ("v:" ..tostring(Placeholder).. ": not found")) .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

function Swift.Text:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

function Swift.Text:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(self.Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

function Swift.Text:ReplaceValuePlaceholder(_Text)
    local Ref = _G;
    local Slice = string.slice(_Text, "%.");
    for i= 1, #Slice do
        local KeyOrIndex = Slice[i];
        local Index = tonumber(KeyOrIndex);
        if Index ~= nil then
            KeyOrIndex = Index;
        end
        if not Ref[KeyOrIndex] then
            return nil;
        end
        Ref = Ref[KeyOrIndex];
    end
    return Ref;
end

-- Slices a string of commands into multiple strings by resolving %% and % as
-- command delimiters.
-- * && separates entries from another and makes them different inputs
-- * & copys parameters for all commands chained with it
--
-- Example:
-- foo & bar 1 2 3 && muh 4
--
-- Result:
-- foo 1 2 3
-- bar 1 2 3
-- muh 4
function Swift.Text:CommandTokenizer(_Input)
    local Commands = {};
    if _Input == nil then
        return Commands;
    end
    local DAmberCommands = {_Input};
    local AmberCommands = {};

    -- parse && delimiter
    local s, e = string.find(_Input, "%s+&&%s+");
    if s then
        DAmberCommands = {};
        while (s) do
            local tmp = string.sub(_Input, 1, s-1);
            table.insert(DAmberCommands, tmp);
            _Input = string.sub(_Input, e+1);
            s, e = string.find(_Input, "%s+&&%s+");
        end
        if string.len(_Input) > 0 then 
            table.insert(DAmberCommands, _Input);
        end
    end

    -- parse & delimiter
    for i= 1, #DAmberCommands, 1 do
        local s, e = string.find(DAmberCommands[i], "%s+&%s+");
        if s then
            local LastCommand = "";
            while (s) do
                local tmp = string.sub(DAmberCommands[i], 1, s-1);
                table.insert(AmberCommands, LastCommand .. tmp);
                if string.find(tmp, " ") then
                    LastCommand = string.sub(tmp, 1, string.find(tmp, " ")-1) .. " ";
                end
                DAmberCommands[i] = string.sub(DAmberCommands[i], e+1);
                s, e = string.find(DAmberCommands[i], "%s+&%s+");
            end
            if string.len(DAmberCommands[i]) > 0 then 
                table.insert(AmberCommands, LastCommand .. DAmberCommands[i]);
            end
        else
            table.insert(AmberCommands, DAmberCommands[i]);
        end
    end

    -- parse spaces
    for i= 1, #AmberCommands, 1 do
        local CommandLine = {};
        local s, e = string.find(AmberCommands[i], "%s+");
        if s then
            while (s) do
                local tmp = string.sub(AmberCommands[i], 1, s-1);
                table.insert(CommandLine, tmp);
                AmberCommands[i] = string.sub(AmberCommands[i], e+1);
                s, e = string.find(AmberCommands[i], "%s+");
            end
            table.insert(CommandLine, AmberCommands[i]);
        else
            table.insert(CommandLine, AmberCommands[i]);
        end
        table.insert(Commands, CommandLine);
    end

    return Commands;
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben.
-- Bei einem Table mit einem passenden Sprach-Key (de, en, fr, ...) wird die
-- entsprechende Sprache zurückgegeben. Sollte ein Nested Table übergeben
-- werden, werden alle Texte innerhalb des Tables rekursiv übersetzt als Table
-- zurückgegeben. Alle anderen Werte sind nicht in der Rückgabe enthalten.
--
-- @param[type=table] _Text Table mit Übersetzungen
-- @return Übersetzten Text oder Table mit Texten
-- @within Text
--
-- @usage
-- -- Beispiel #1: Table lokalisieren
-- local Text = API.Localize({de = "Deutsch", en = "English"});
-- -- Rückgabe: "Deutsch"
--
-- @usage
-- -- Beispiel #2: Mehrstufige (Nested) Tables
-- -- (Nested Tables sind in dem Fall mit Vorsicht zu genießen!)
-- API.Localize{{de = "Deutsch", en = "English"}, {{1,2,3,4, de = "A", en = "B"}}}
-- -- Rückgabe: {"Deutsch", {"A"}}
--
function API.Localize(_Text)
    return Swift.Text:Localize(_Text);
end

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
-- 
-- <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
-- <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text Anzeigetext
-- @within Text
--
-- @usage
-- API.Note("Das ist eine flüchtige Information!");
--
function API.Note(_Text)
    _Text = Swift.Text:ConvertPlaceholders(Swift.Text:Localize(_Text));
    if not GUI then
        Logic.DEBUG_AddNote(_Text);
        return;
    end
    GUI.AddNote(_Text);
end

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
-- 
-- <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
-- <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text Anzeigetext
-- @within Text
--
-- @usage
-- API.StaticNote("Das ist eine dauerhafte Information!");
--
function API.StaticNote(_Text)
    _Text = Swift.Text:ConvertPlaceholders(Swift.Text:Localize(_Text));
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddStaticNote("%s")]],
            _Text
        ));
        return;
    end
    GUI.AddStaticNote(_Text);
end

---
-- Schreibt eine Nachricht unten in das Nachrichtenfenster. Die Nachricht
-- verschwindet nach einigen Sekunden.
-- 
-- <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
-- <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text  Anzeigetext
-- @param[type=string] _Sound (Optional) Soundeffekt der Nachricht
-- @within Text
--
-- @usage
-- -- Beispiel #1: Einfache Nachricht
-- API.Message("Das ist eine Nachricht!");
--
-- @usage
-- -- Beispiel #2: Nachricht und Ton
-- API.Message("Das ist eine WERTVOLLE Nachricht!", "ui/menu_left_gold_pay");
--
function API.Message(_Text, _Sound)
    _Text = Swift.Text:ConvertPlaceholders(Swift.Text:Localize(_Text));
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.Message("%s", %s)]],
            _Text,
            _Sound
        ));
        return;
    end
    _Text = Swift.Text:ConvertPlaceholders(API.Localize(_Text));
    if _Sound then
        _Sound = _Sound:gsub("/", "\\");
    end
    Message(_Text, _Sound);
end

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Text
--
-- @usage
-- API.ClearNotes();
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState([[API.ClearNotes()]]);
        return;
    end
    GUI.ClearNotes();
end

---
-- Ersetzt alle Platzhalter im Text oder in der Table.
--
-- Mögliche Platzhalter:
-- <ul>
-- <li>{n:xyz} - Ersetzt einen Skriptnamen mit dem zuvor gesetzten Wert.</li>
-- <li>{t:xyz} - Ersetzt einen Typen mit dem zuvor gesetzten Wert.</li>
-- <li>{v:xyz} - Ersetzt mit dem Inhalt der angegebenen Variable. Der Wert muss
-- in der Umgebung vorhanden sein, in der er ersetzt wird.</li>
-- </ul>
--
-- Außerdem werden einige Standardfarben ersetzt.
-- <pre>{COLOR}</pre>
-- Ersetze {COLOR} in deinen Texten mit einer der gelisteten Farben.
--
-- <table border="1">
-- <tr><th><b>Platzhalter</b></th><th><b>Farbe</b></th><th><b>RGBA</b></th></tr>
--
-- <tr><td>red</td>     <td>Rot</td>           <td>255,80,80,255</td></tr>
-- <tr><td>blue</td>    <td>Blau</td>          <td>104,104,232,255</td></tr>
-- <tr><td>yellow</td>  <td>Gelp</td>          <td>255,255,80,255</td></tr>
-- <tr><td>green</td>   <td>Grün</td>          <td>80,180,0,255</td></tr>
-- <tr><td>white</td>   <td>Weiß</td>          <td>255,255,255,255</td></tr>
-- <tr><td>black</td>   <td>Schwarz</td>       <td>0,0,0,255</td></tr>
-- <tr><td>grey</td>    <td>Grau</td>          <td>140,140,140,255</td></tr>
-- <tr><td>azure</td>   <td>Azurblau</td>      <td>255,176,30,255</td></tr>
-- <tr><td>orange</td>  <td>Orange</td>        <td>255,176,30,255</td></tr>
-- <tr><td>amber</td>   <td>Bernstein</td>     <td>224,197,117,255</td></tr>
-- <tr><td>violet</td>  <td>Violett</td>       <td>180,100,190,255</td></tr>
-- <tr><td>pink</td>    <td>Rosa</td>          <td>255,170,200,255</td></tr>
-- <tr><td>scarlet</td> <td>Scharlachrot</td>  <td>190,0,0,255</td></tr>
-- <tr><td>magenta</td> <td>Magenta</td>       <td>190,0,89,255</td></tr>
-- <tr><td>olive</td>   <td>Olivgrün</td>      <td>74,120,0,255</td></tr>
-- <tr><td>sky</td>     <td>Himmelsblau</td>   <td>145,170,210,255</td></tr>
-- <tr><td>tooltip</td> <td>Tooltip-Blau</td>  <td>51,51,120,255</td></tr>
-- <tr><td>lucid</td>   <td>Transparent</td>   <td>0,0,0,0</td></tr>
-- <tr><td>none</td>    <td>Standardfarbe</td> <td>(Abhängig vom Widget)</td></tr>
-- </table>
--
-- @param[type=string] _Message Text
-- @return Ersetzter Text
-- @within Text
--
-- @usage
-- -- Beispiel #1: Vordefinierte Farbe austauschen
-- local Replaced = API.ConvertPlaceholders("{scarlet}Dieser Text ist jetzt rot!");
--
-- @usage
-- -- Beispiel #2: Skriptnamen austauschen
-- local Replaced = API.ConvertPlaceholders("{n:placeholder2} wurde ersetzt!");
--
-- @usage
-- -- Beispiel #3: Typen austauschen
-- local Replaced = API.ConvertPlaceholders("{t:U_KnightHealing} wurde ersetzt!");
--
-- @usage
-- -- Beispiel #4: Variable austauschen
-- local Replaced = API.ConvertPlaceholders("{v:MyVariable.1.MyValue} wurde ersetzt!");
--
function API.ConvertPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = Swift.Text:ConvertPlaceholders(v);
        end
        return API.Localize(_Message);
    elseif type(_Message) == "string" then
        return Swift.Text:ConvertPlaceholders(_Message);
    else
        return _Message;
    end
end

---
-- Fügt einen Platzhalter für den angegebenen Namen hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{n:SOME_NAME}</pre>
-- SOME_NAME muss mit dem Namen ersetzt werden.
--
-- @param[type=string] _Name        Name, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Text
--
-- @usage
-- API.AddNamePlaceholder("Scriptname", "Horst");
-- API.AddNamePlaceholder("Scriptname", {de = "Kuchen", en = "Cake"});
--
function API.AddNamePlaceholder(_Name, _Replacement)
    if type(_Replacement) == "function" or type(_Replacement) == "thread" then
        error("API.AddNamePlaceholder: Only strings, numbers, or tables are allowed!");
        return;
    end
    Swift.Text.Placeholders.Names[_Name] = _Replacement;
end

---
-- Fügt einen Platzhalter für einen Entity-Typ hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{t:ENTITY_TYP}</pre>
-- ENTITY_TYP muss mit einem Entity-Typ ersetzt werden. Der Typ wird ohne
-- Entities. davor geschrieben.
--
-- @param[type=string] _Type        Typname, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Text
--
-- @usage
-- API.AddNamePlaceholder("U_KnightHealing", "Arroganze Ziege");
-- API.AddNamePlaceholder("B_Castle_SE", {de = "Festung des Bösen", en = "Fortress of Evil"});
--
function API.AddEntityTypePlaceholder(_Type, _Replacement)
    if Entities[_Type] == nil then
        error("API.AddEntityTypePlaceholder: EntityType does not exist!");
        return;
    end
    Swift.Text.Placeholders.EntityTypes[_Type] = _Replacement;
end

