--[[
Swift_2_InputOutputCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Modul für die Eingabe durch den Spieler und die Ausgabe von Texten.
--
-- Du kannst vordefinierte Farben in Textausgaben verwenden. Außerdem kannst
-- du für Skriptnamen und Entitytypen Platzhalter zu definieren. Diese
-- Platzhalter können auch lokalisiert werden.
--
-- Du kannst ferner verschiedene Input Dialoge nutzen, um Ausgaben anzuzeigen.
-- Außerdem kannst du vom Spieler Eingaben fordern.
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>clear</td>
-- <td>Entfernt alle Texte aus dem Debug Window. (Nachrichten oben links)</td>
-- </tr>
-- <tr>
-- <td>version</td>
-- <td>Zeigt die Versionsnummer der QSB an.</td>
-- </tr>
-- <tr>
-- <td>&gt;</td>
-- <td>Lua-Befehl in der globalen Umgebung ausführen.</td>
-- </tr>
-- <tr>
-- <td>&gt;&gt;</td>
-- <td>Lua-Befehl in der lokalen Umgebung ausführen.</td>
-- </tr>
-- <tr>
-- <td>&lt;</td>
-- <td>Lua-Datei in die globale Umgebung laden.</td>
-- </tr>
-- <tr>
-- <td>&lt;&lt;</td>
-- <td>Lua-Datei in die lokale Umgebung laden.</td>
-- </tr>
-- </table>
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field ChatOpened Das Chatfenster wird angezeigt (Parameter: PlayerID)
-- @field ChatClosed Die Chateingabe wird bestätigt (Parameter: Text, PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text Anzeigetext
-- @within Anwenderfunktionen
--
-- @usage
-- API.Note("Das ist eine flüchtige Information!");
--
function API.Note(_Text)
    ModuleInputOutputCore.Shared:Note(_Text);
end

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text Anzeigetext
-- @within Anwenderfunktionen
--
-- @usage
-- API.StaticNote("Das ist eine dauerhafte Information!");
--
function API.StaticNote(_Text)
    ModuleInputOutputCore.Shared:StaticNote(_Text);
end

---
-- Schreibt eine Nachricht unten in das Nachrichtenfenster. Die Nachricht
-- verschwindet nach einigen Sekunden.
--
-- <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.
--
-- @param[type=string] _Text Anzeigetext
-- @within Anwenderfunktionen
--
-- @usage
-- API.Message("Das ist eine Nachricht!");
--
function API.Message(_Text)
    ModuleInputOutputCore.Shared:Message(_Text);
end

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
-- @usage
-- API.ClearNotes();
--
function API.ClearNotes()
    ModuleInputOutputCore.Shared:ClearNotes();
end

---
-- Ersetzt alle Platzhalter im Text oder in der Table.
--
-- Mögliche Platzhalter:
-- <ul>
-- <li>{n:xyz} - Ersetzt einen Skriptnamen mit dem zuvor gesetzten Wert.</li>
-- <li>{t:xyz} - Ersetzt einen Typen mit dem zuvor gesetzten Wert.</li>
-- <li>{v:xyz} - Ersetzt mit dem Inhalt der angegebenen Variable. Der Wert muss
-- in der Umgebung vorhanden sein, in der er verwendet wird. Das ist meistens
-- das lokale Skript!</li>
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
-- @within Anwenderfunktionen
--
-- @usage
-- local Placeholder = API.ConvertPlaceholders("{scarlet}Dieser Text ist jetzt rot!");
-- local Placeholder2 = API.ConvertPlaceholders("{n:placeholder2} wurde ersetzt!");
-- local Placeholder3 = API.ConvertPlaceholders("{t:U_KnightHealing} wurde ersetzt!");
-- local Placeholder3 = API.ConvertPlaceholders("{v:MyVariable.1.MyValue} wurde ersetzt!");
--
function API.ConvertPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = ModuleInputOutputCore.Shared:ConvertPlaceholders(v);
        end
        return API.Localize(_Message);
    elseif type(_Message) == "string" then
        return ModuleInputOutputCore.Shared:ConvertPlaceholders(_Message);
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
-- @within Anwenderfunktionen
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
    ModuleInputOutputCore.Shared.Placeholders.Names[_Name] = _Replacement;
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
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddNamePlaceholder("U_KnightHealing", "Arroganze Ziege");
-- API.AddNamePlaceholder("B_Castle_SE", {de = "Festung des Bösen", en = "Fortress of evil"});
--
function API.AddEntityTypePlaceholder(_Type, _Replacement)
    if Entities[_Type] == nil then
        error("API.AddEntityTypePlaceholder: EntityType does not exist!");
        return;
    end
    ModuleInputOutputCore.Shared.Placeholders.EntityTypes[_Type] = _Replacement;
end

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- An die Action wird der Spieler übergeben, der den Dialog bestätigt hat.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param                _Action   Funktionsreferenz
-- @within Anwenderfunktionen
--
-- @usage
-- API.DialogInfoBox("Wichtige Information", "Diese Information ist Spielentscheidend!");
--
function API.DialogInfoBox(_PlayerID, _Title, _Text, _Action)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    return ModuleInputOutputCore.Local:OpenDialog(_PlayerID, _Title, _Text, _Action);
end

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
-- Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
-- Entscheidung getroffen hat, plus die ID des Spielers.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param                _Action   Funktionsreferenz
-- @param[type=boolean]  _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Anwenderfunktionen
--
-- @usage
-- function YesNoAction(_Yes, _PlayerID)
--     if _Yes then GUI.AddNote("Ja wurde gedrückt"); end
-- end
-- API.DialogRequestBox("Frage", "Möchtest du das wirklich tun?", YesNoAction, false);
--
function API.DialogRequestBox(_PlayerID, _Title, _Text, _Action, _OkCancel)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    return ModuleInputOutputCore.Local:OpenRequesterDialog(_PlayerID, _Title, _Text, _Action, _OkCancel);
end

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
-- aus. Anschließend erhält das Callback den Index der selektierten Option und
-- die ID des Spielers, der den Dialog bestätigt hat.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param                _Action Funktionsreferenz
-- @param[type=table]    _List   Liste der Optionen
-- @within Anwenderfunktionen
--
-- @usage
-- function OptionsAction(_Idx, _PlayerID)
--     GUI.AddNote(_Idx.. " wurde ausgewählt!");
-- end
-- local List = {"Option A", "Option B", "Option C"};
-- API.DialogSelectBox("Auswahl", "Wähle etwas aus!", OptionsAction, List);
--
function API.DialogSelectBox(_PlayerID, _Title, _Text, _Action, _List)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    _Text = _Text .. "{cr}";
    ModuleInputOutputCore.Local:OpenSelectionDialog(_PlayerID, _Title, _Text, _Action, _List);
end

---
-- Öffnet den Dialog für die Auswahl der Sprache. Deutsch, Englisch und
-- Französisch sind vorkonfiguriert.
--
-- @param[type=number] _PlayerID (optional) Nur für diesen Spieler anzeigen
-- @within Anwenderfunktionen
--
-- @usage
-- -- Für alle Spieler
-- API.DialogLanguageSelection();
-- -- Nur für Spieler 2 anzeigen
-- API.DialogLanguageSelection(2);
--
function API.DialogLanguageSelection(_PlayerID)
    _PlayerID = _PlayerID or -1
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.DialogLanguageSelection(%d)]],
            _PlayerID
        ));
        return;
    end
    if _PlayerID ~= -1 and GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    local DisplayedList = {};
    for i= 1, #Swift.LanguageRegister do
        table.insert(DisplayedList, Swift.LanguageRegister[i][2]);
    end
    local Action = function(_Selected)
        API.BroadcastScriptCommand(
            QSB.ScriptCommands.SetLanguageResult,
            GUI.GetPlayerID(),
            Swift.LanguageRegister[_Selected][1]
        );
    end
    local Text = API.Localize(ModuleInputOutputCore.Shared.Text.ChooseLanguage);
    API.DialogSelectBox(GUI.GetPlayerID(), Text.Title, Text.Text, Action, DisplayedList);
end

---
-- Fügt eine neue Sprache zur Auswahl hinzu.
--
-- @param[type=string] _Shortcut Kürzel der Sprache (vgl. de, en, ...)
-- @param[type=string] _Name     Anzeigename der Sprache
-- @param[type=string] _Fallback Kürzel der Ausweichsprache
-- @within Anwenderfunktionen
--
-- @usage
-- API.DefineLanguage("sx", "Sächsich", "de")
--
function API.DefineLanguage(_Shortcut, _Name, _Fallback)
    assert(type(_Shortcut) == "string");
    assert(type(_Name) == "string");
    assert(type(_Fallback) == "string");
    for k, v in pairs(Swift.LanguageRegister) do
        if v[1] == _Shortcut then
            return;
        end
    end
    table.insert(Swift.LanguageRegister, {_Shortcut, _Name, _Fallback});
    Logic.ExecuteInLuaLocalState(string.format([[
        table.insert(Swift.LanguageRegister, {"%s", "%s", "%s"})
    ]], _Shortcut, _Name, _Fallback));
end

---
-- Öffnet ein einfaches Textfenster mit dem angegebenen Text.
--
-- Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
-- Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.
--
-- <h5>Multiplayer</h5>
-- Im Multiplayer muss zwingend der Spieler angegeben werden, für den das
-- Fenster angezeigt werden soll.
--
-- @param[type=string] _Caption  Titel des Fenster
-- @param[type=string] _Content  Inhalt des Fenster
-- @param[type=number] _PlayerID Spieler, der das Fenster sieht
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--              "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.SimpleTextWindow("Überschrift", Text);
--
function API.SimpleTextWindow(_Caption, _Content, _PlayerID)
    _PlayerID = _PlayerID or 1;
    _Caption = API.Localize(_Caption);
    _Content = API.Localize(_Content);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SimpleTextWindow("%s", "%s", %d)]],
            _Caption,
            _Content,
            _PlayerID
        ));
        return;
    end
    ModuleInputOutputCore.Local:ShowTextWindow {
        PlayerID = _PlayerID,
        Caption  = _Caption,
        Content  = _Content,
    };
end

---
-- Bereitet die Texteingabe über den Chat Input vor.
--
-- <b>Hinweis</b>: Der Spieler kann den Input nicht mit Esc verlassen. Der Input
-- kann nur durch Enter geschlossen werden. Das bedeutet, dass evtl. ein leerer
-- String übergeben wird. In diesem Fall wurde nichts eingegeben.
-- @within Anwenderfunktionen
--
-- @param[type=number]  _PlayerID   Für diesen Spieler anzeigen
-- @param[type=boolean] _AllowDebug Debug Commands auswerten
-- @usage
-- -- Debug Options werden geblockt
-- API.ShowTextInput(1, false);
-- -- Debug Options werden ausgewertet
-- API.ShowTextInput(1, true);
--
function API.ShowTextInput(_PlayerID, _AllowDebug)
    -- Text input will only be evaluated in the original version of the game
    -- and in Singleplayer History Edition.
    if API.IsHistoryEditionNetworkGame() then
        return;
    end
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.ShowTextInput(%d, %s)]],
            _PlayerID,
            tostring(_AllowDebug == true)
        ))
        return;
    end
    _PlayerID = _PlayerID or GUI.GetPlayerID();
    ModuleInputOutputCore.Local:PrepareInputVariable(_PlayerID);
    ModuleInputOutputCore.Local:ShowInputBox(_PlayerID, _AllowDebug == true);
end

---
-- Deaktiviert die Cheats.
--
-- <b>Hinweis</b>: Die Cheats werden nur für den Spieler deaktiviert. Wenn der
-- Debug Mode die Cheats aktiviert hat, bleiben sie aktiv.
--
-- @usage
-- API.DisableCheats();
--
function API.DisableCheats()
    if not GUI then
        Logic.ExecuteInLuaLocalState([[API.DisableCheats()]]);
        return;
    end
    ModuleInputOutputCore.Local.CheatsDisabled = true;
    ModuleInputOutputCore.Local:OverrideCheats();
end

-- Local callbacks

function SCP.InputOutputCore.SetDecisionResult(_PlayerID, _Yes)
    QSB.DecisionWindowResult = _Yes == true;
end

function SCP.InputOutputCore.SetLanguageResult(_PlayerID, _Language)
    Swift:ChangeSystemLanguage(_PlayerID, _Language);
end

