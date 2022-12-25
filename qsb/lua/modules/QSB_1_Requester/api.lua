--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Stellt verschiedene Dialog- oder Textfenster zur Verfügung.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

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
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,"..
--              " sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              " magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.TextWindow("Überschrift", Text);
--
function API.TextWindow(_Caption, _Content, _PlayerID)
    _PlayerID = _PlayerID or 1;
    _Caption = API.Localize(_Caption);
    _Content = API.Localize(_Content);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.TextWindow("%s", "%s", %d)]],
            _Caption,
            _Content,
            _PlayerID
        ));
        return;
    end
    ModuleRequester.Local:ShowTextWindow {
        PlayerID = _PlayerID,
        Caption  = _Caption,
        Content  = _Content,
    };
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
    return ModuleRequester.Local:OpenDialog(_PlayerID, _Title, _Text, _Action);
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
        _OkCancel = _Action;
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
    return ModuleRequester.Local:OpenRequesterDialog(_PlayerID, _Title, _Text, _Action, _OkCancel);
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
        _List = _Action;
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
    ModuleRequester.Local:OpenSelectionDialog(_PlayerID, _Title, _Text, _Action, _List);
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
    for i= 1, #Swift.Text.Languages do
        table.insert(DisplayedList, Swift.Text.Languages[i][2]);
    end
    local Action = function(_Selected)
        API.BroadcastScriptCommand(
            QSB.ScriptCommands.SetLanguageResult,
            GUI.GetPlayerID(),
            Swift.Text.Languages[_Selected][1]
        );
    end
    local Text = API.Localize(ModuleRequester.Shared.Text.ChooseLanguage);
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
    for k, v in pairs(Swift.Text.Languages) do
        if v[1] == _Shortcut then
            return;
        end
    end
    table.insert(Swift.Text.Languages, {_Shortcut, _Name, _Fallback});
    Logic.ExecuteInLuaLocalState(string.format([[
        table.insert(Swift.Text.Languages, {"%s", "%s", "%s"})
    ]], _Shortcut, _Name, _Fallback));
end

