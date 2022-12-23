--[[
Swift_2_InterfaceCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul bietet grundlegende Funktionen zur Steuerung des Interface.
--
-- <h5>Multiplayer</h5>
-- Diese Funktionen müssen in Multiplayer Maps synchron aufgerufen werden.
-- Entweder zu Spielbeginn oder durch Jobs oder durch Events.
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
-- @field UpgradeStarted  Ein Ausbau wurde gestartet. (Parameter: EntityID, PlayerID)
-- @field UpgradeCanceled Ein Ausbau wurde abgebrochen. (Parameter: EntityID, PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Setzt einen Icon aus einer Icon Matrix.
--
-- Es ist möglich, eine benutzerdefinierte Icon Matrix zu verwenden.
-- Dafür müssen die Quellen nach gui_768, gui_920 und gui_1080 in der
-- entsprechenden Größe gepackt werden, da das Spiel für unterschiedliche
-- Auflösungen in verschiedene Verzeichnisse schaut.
-- 
-- Die Dateien müssen in <i>graphics/textures</i> liegen, was auf gleicher
-- Ebene ist, wie <i>maps/externalmap</i>.
-- Jede Map muss einen eigenen eindeutigen Namen für jede Grafik verwenden, da
-- diese Grafiken solange geladen werden, wie die Map im Verzeichnis liegt.
--
-- Es können 3 verschiedene Icon-Größen angegeben werden. Je nach dem welche
-- Größe gefordert wird, wird nach einer anderen Datei gesucht. Es entscheidet
-- der als Name angegebene Präfix.
-- <ul>
-- <li>keine: siehe 64</li>
-- <li>44: [Dateiname].png</li>
-- <li>64: [Dateiname]big.png</li>
-- <li>1200: [Dateiname]verybig.png</li>
-- </ul>
--
-- @param[type=string] _WidgetID Widgetpfad oder ID
-- @param[type=table]  _Coordinates Koordinaten [Format: {x, y, addon}]
-- @param[type=number] _Size (Optional) Größe des Icon
-- @param[type=string] _Name (Optional) Base Name der Icon Matrix
-- @within Anwenderfunktionen
--
-- @usage
-- -- Setzt eine Originalgrafik
-- API.SetIcon(AnyWidgetID, {1, 1, 1});
--
-- -- Setzt eine benutzerdefinierte Grafik
-- API.SetIcon(AnyWidgetID, {8, 5}, nil, "meinetollenicons");
-- -- (Es wird als Datei gesucht: meinetolleniconsbig.png)
--
-- -- Setzt eine benutzerdefinierte Grafik
-- API.SetIcon(AnyWidgetID, {8, 5}, 128, "meinetollenicons");
-- -- (Es wird als Datei gesucht: meinetolleniconsverybig.png)
--
function API.SetIcon(_WidgetID, _Coordinates, _Size, _Name)
    if not GUI then
        return;
    end
    _Coordinates = _Coordinates or {10, 14};
    ModuleInterfaceCore.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name);
end

---
-- Ändert den Beschreibungstext eines Button oder eines Icon.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
-- Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
-- wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
-- immer der englische Text verwendet.
--
-- @param[type=string] _title        Titel des Tooltip
-- @param[type=string] _text         Text des Tooltip
-- @param[type=string] _disabledText Textzusatz wenn inaktiv
-- @within Anwenderfunktionen
--
function API.SetTooltipNormal(_title, _text, _disabledText)
    if not GUI then
        return;
    end
    ModuleInterfaceCore.Local:TextNormal(_title, _text, _disabledText);
end

---
-- Ändert den Beschreibungstext und die Kosten eines Button.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Update-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- @see API.SetTooltipNormal
--
-- @param[type=string]  _title        Titel des Tooltip
-- @param[type=string]  _text         Text des Tooltip
-- @param[type=string]  _disabledText Textzusatz wenn inaktiv
-- @param[type=table]   _costs        Kostentabelle
-- @param[type=boolean] _inSettlement Kosten in Siedlung suchen
-- @within Anwenderfunktionen
--
function API.SetTooltipCosts(_title,_text,_disabledText,_costs,_inSettlement)
    if not GUI then
        return;
    end
    ModuleInterfaceCore.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement);
end

---
-- Gibt den Namen des Territoriums zurück.
--
-- @param[type=number] _TerritoryID ID des Territoriums
-- @return[type=string]  Name des Territorium
-- @within Anwenderfunktionen
--
function API.GetTerritoryName(_TerritoryID)
    local Name = Logic.GetTerritoryName(_TerritoryID);
    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    if MapType == 1 or MapType == 3 then
        return Name;
    end

    local MapName = Framework.GetCurrentMapName();
    local StringTable = "Map_" .. MapName;
    local TerritoryName = string.gsub(Name, " ","");
    TerritoryName = XGUIEng.GetStringTableText(StringTable .. "/Territory_" .. TerritoryName);
    if TerritoryName == "" then
        TerritoryName = Name .. "(key?)";
    end
    return TerritoryName;
end
GetTerritoryName = API.GetTerritoryName;

---
-- Gibt den Namen des Spielers zurück.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=string]  Name des Spielers
-- @within Anwenderfunktionen
--
function API.GetPlayerName(_PlayerID)
    local PlayerName = Logic.GetPlayerName(_PlayerID);
    local name = QSB.PlayerNames[_PlayerID];
    if name ~= nil and name ~= "" then
        PlayerName = name;
    end

    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    local MutliplayerMode = Framework.GetMultiplayerMapMode(Framework.GetCurrentMapName(), MapType);

    if MutliplayerMode > 0 then
        return PlayerName;
    end
    if MapType == 1 or MapType == 3 then
        local PlayerNameTmp, PlayerHeadTmp, PlayerAITmp = Framework.GetPlayerInfo(_PlayerID);
        if PlayerName ~= "" then
            return PlayerName;
        end
        return PlayerNameTmp;
    end
end
GetPlayerName_OrigName = GetPlayerName;
GetPlayerName = API.GetPlayerName;

---
-- Wechselt die Spieler ID des menschlichen Spielers.
--
-- Die neue ID muss einen Primärritter haben.
--
-- <h5>Multiplayer</h5>
-- Nicht für Multiplayer geeignet.
--
-- @param[type=number] _OldPlayerID Alte ID des menschlichen Spielers
-- @param[type=number] _NewPlayerID Neue ID des menschlichen Spielers
-- @param[type=string] _NewStatisticsName Name in der Statistik
-- @within Anwenderfunktionen
--
function API.SetControllingPlayer(_OldPlayerID, _NewPlayerID, _NewStatisticsName)
    if Framework.IsNetworkGame() then
        return;
    end
    ModuleInterfaceCore.Global:SetControllingPlayer(_OldPlayerID, _NewPlayerID, _NewStatisticsName);
end

---
-- Gibt dem Spieler einen neuen Namen.
--
-- @param[type=number] _playerID ID des Spielers
-- @param[type=string] _name Name des Spielers
-- @within Anwenderfunktionen
--
function API.SetPlayerName(_playerID,_name)
    assert(type(_playerID) == "number");
    assert(type(_name) == "string");
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[
                GUI_MissionStatistic.PlayerNames[%d] = "%s"
                QSB.PlayerNames[%d] = "%s"
            ]],
            _playerID,
            _name,
            _playerID,
            _name
        ));
    end
    QSB.PlayerNames[_playerID] = _name;
end
SetPlayerName = API.SetPlayerName;

---
-- Setzt eine andere Spielerfarbe.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Color Spielerfarbe
-- @param[type=number] _Logo Logo (optional)
-- @param[type=number] _Pattern Pattern (optional)
-- @within Anwenderfunktionen
--
function API.SetPlayerColor(_PlayerID, _Color, _Logo, _Pattern)
    if GUI then
        return;
    end
    g_ColorIndex["ExtraColor1"] = g_ColorIndex["ExtraColor1"] or 16;
    g_ColorIndex["ExtraColor2"] = g_ColorIndex["ExtraColor2"] or 17;

    local Col     = (type(_Color) == "string" and g_ColorIndex[_Color]) or _Color;
    local Logo    = _Logo or -1;
    local Pattern = _Pattern or -1;

    Logic.PlayerSetPlayerColor(_PlayerID, Col, Logo, Pattern);
    Logic.ExecuteInLuaLocalState([[
        Display.UpdatePlayerColors()
        GUI.RebuildMinimapTerrain()
        GUI.RebuildMinimapTerritory()
    ]]);
end

---
-- Setzt das Portrait eines Spielers.
--
-- Dabei gibt es 3 verschiedene Varianten:
-- <ul>
-- <li>Wenn _Portrait nicht gesetzt wird, wird das Portrait des Primary
-- Knight genommen.</li>
-- <li>Wenn _Portrait ein existierendes Entity ist, wird anhand des Typs
-- das Portrait bestimmt.</li>
-- <li>Wenn _Portrait der Modellname eines Portrait ist, wird der Wert
-- als Portrait gesetzt.</li>
-- </ul>
--
-- Wenn kein Portrait bestimmt werden kann, wird H_NPC_Generic_Trader verwendet.
--
-- <b>Trivia</b>: Diese Funktionalität wird Umgangssprachlich als "Köpfe
-- tauschen" oder "Köpfe wechseln" bezeichnet.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Portrait Name des Models
-- @within Anwenderfunktionen
--
-- @usage
-- -- Kopf des Primary Knight
-- API.SetPlayerPortrait(2);
-- -- Kopf durch Entity bestimmen
-- API.SetPlayerPortrait(2, "amma");
-- -- Kopf durch Modelname setzen
-- API.SetPlayerPortrait(2, "H_NPC_Monk_AS");
--
function API.SetPlayerPortrait(_PlayerID, _Portrait)
    if not _PlayerID or type(_PlayerID) ~= "number" or (_PlayerID < 1 or _PlayerID > 8) then
        error("API.SetPlayerPortrait: Invalid player ID!");
        return;
    end
    if not GUI then
        local Portrait = (_Portrait ~= nil and "'" .._Portrait.. "'") or "nil";
        Logic.ExecuteInLuaLocalState("API.SetPlayerPortrait(" .._PlayerID.. ", " ..Portrait.. ")")
        return;
    end

    if _Portrait == nil then
        ModuleInterfaceCore.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID);
        return;
    end
    if _Portrait ~= nil and IsExisting(_Portrait) then
        ModuleInterfaceCore.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait);
        return;
    end
    ModuleInterfaceCore.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait);
end

---
-- Fügt eine Beschreibung zu einem selbst gewählten Hotkey hinzu.
--
-- Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.
--
-- @param[type=string] _Key         Tastenkombination
-- @param[type=string] _Description Beschreibung des Hotkey
-- @return[type=number] Index oder Fehlercode
-- @within Anwenderfunktionen
--
function API.AddShortcut(_Key, _Description)
    if not GUI then
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    local ID = #ModuleInterfaceCore.Local.HotkeyDescriptions+1;
    table.insert(ModuleInterfaceCore.Local.HotkeyDescriptions, {ID = ID, _Key, _Description});
    return #ModuleInterfaceCore.Local.HotkeyDescriptions;
end

---
-- Entfernt eine Beschreibung eines selbst gewählten Hotkeys.
--
-- @param[type=number] _ID Index in Table
-- @within Anwenderfunktionen
--
function API.RemoveShortcut(_ID)
    if not GUI then
        return;
    end
    if type(_ID) ~= "number" then
        error("API.RemoveShortcut: _ID must be a number and a valid index!");
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    for k, v in pairs(ModuleInterfaceCore.Local.HotkeyDescriptions) do
        if v.ID == _ID then
            ModuleInterfaceCore.Local.HotkeyDescriptions[k] = nil;
        end
    end
end

---
-- Deaktiviert reguläres Speichern.
--
-- @param[type=boolean] _Flag Speichern deaktivieren
-- @within Anwenderfunktionen
--
function API.DisableRegularSaveGame(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "API.DisableRegularSaveGame(%s)",
            tostring(_Flag == true)
        ));
        return;
    end
    ModuleInterfaceCore.Local.ForbidRegularSave = _Flag == true;
    ModuleInterfaceCore.Local:DisplaySaveButtons();
end

---
-- Deaktiviert das automatische Speichern in der History Edition.
--
-- Das Spiel wird zu keinem Zeitpunkt einen automatischen Spielstand anlegen.
--
-- @param[type=boolean] _Flag Autosave deaktivieren
-- @within Anwenderfunktionen
--
function API.DisableHistoryEditionAutoSave(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "API.DisableHistoryEditionAutoSave(%s)",
            tostring(_Flag == true)
        ));
        return;
    end
    ModuleInterfaceCore.Local.DisableHEAutoSave = _Flag == true;
end

---
-- Graut die Minimap aus oder macht sie wieder verwendbar.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideMinimap(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay",
        _Flag
    );
    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapTerrain",
        _Flag
    );
end

---
-- Versteckt den Umschaltknopf der Minimap oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideToggleMinimap(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideToggleMinimap(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/MinimapButton",
        _Flag
    );
end

---
-- Versteckt den Button des Diplomatiemenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideDiplomacyMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideDiplomacyMenu(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/DiplomacyMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button des Produktionsmenü oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideProductionMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideProductionMenu(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/ProductionMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button des Wettermenüs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideWeatherMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideWeatherMenu(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/WeatherMenuButton",
        _Flag
    );
end

---
-- Versteckt den Button zum Territorienkauf oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideBuyTerritory(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideBuyTerritory(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory",
        _Flag
    );
end

---
-- Versteckt den Button der Heldenfähigkeit oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideKnightAbility(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideKnightAbility(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbilityProgress",
        _Flag
    );
    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility",
        _Flag
    );
end

---
-- Versteckt den Button zur Heldenselektion oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideKnightButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideKnightButton(" ..tostring(_Flag).. ")");
        Logic.SetEntitySelectableFlag("..KnightID..", (_Flag and 0) or 1);
        return;
    end

    local KnightID = Logic.GetKnightID(GUI.GetPlayerID());
    if _Flag then
        GUI.DeselectEntity(KnightID);
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButtonProgress",
        _Flag
    );
    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton",
        _Flag
    );
end

---
-- Versteckt den Button zur Selektion des Militärs oder blendet ihn ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideSelectionButton(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideSelectionButton(" ..tostring(_Flag).. ")");
        return;
    end
    API.HideKnightButton(_Flag);
    GUI.ClearSelection();

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton",
        _Flag
    );
end

---
-- Versteckt das Baumenü oder blendet es ein.
--
-- <p><b>Hinweis:</b> Diese Änderung bleibt auch nach dem Laden eines Spielstandes
-- aktiv und muss explizit zurückgenommen werden!</p>
--
-- @param[type=boolean] _Flag Widget versteckt
-- @within Anwenderfunktionen
--
function API.HideBuildMenu(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.HideBuildMenu(" ..tostring(_Flag).. ")");
        return;
    end

    ModuleInterfaceCore.Local:DisplayInterfaceButton(
        "/InGame/Root/Normal/AlignBottomRight/BuildMenu",
        _Flag
    );
end

---
-- Fügt einen allgemeinen Gebäudeschalter an der Position hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion.
--
-- Die Position wird lokal zur linken oberen Ecke des Fensters angegeben.
--
-- @param[type=number]   _X       X-Position des Button
-- @param[type=number]   _Y       Y-Position des Button
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
--
-- @usage
-- SpecialButtonID = API.AddBuildingButton(
--     -- Position (X, Y)
--     230, 180,
--     -- Aktion
--     function(_WidgetID, _BuildingID)
--         GUI.AddNote("Hier passiert etwas!");
--     end,
--     -- Tooltip
--     function(_WidgetID, _BuildingID)
--         -- Es MUSS ein Kostentooltip verwendet werden.
--         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
--     end,
--     -- Update
--     function(_WidgetID, _BuildingID)
--         -- Ausblenden, wenn noch in Bau
--         if Logic.IsConstructionComplete(_BuildingID) == 0 then
--             XGUIEng.ShowWidget(_WidgetID, 0);
--             return;
--         end
--         -- Deaktivieren, wenn ausgebaut wird.
--         if Logic.IsBuildingBeingUpgraded(_BuildingID) then
--             XGUIEng.DisableButton(_WidgetID, 1);
--         end
--         SetIcon(_WidgetID, {1, 1});
--     end
-- );
--
function API.AddBuildingButtonAtPosition(_X, _Y, _Action, _Tooltip, _Update)
    return ModuleInterfaceCore.Local:AddButtonBinding(0, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen allgemeinen Gebäudeschalter hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion.
--
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
--
-- @usage
-- SpecialButtonID = API.AddBuildingButton(
--     -- Aktion
--     function(_WidgetID, _BuildingID)
--         GUI.AddNote("Hier passiert etwas!");
--     end,
--     -- Tooltip
--     function(_WidgetID, _BuildingID)
--         -- Es MUSS ein Kostentooltip verwendet werden.
--         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
--     end,
--     -- Update
--     function(_WidgetID, _BuildingID)
--         -- Ausblenden, wenn noch in Bau
--         if Logic.IsConstructionComplete(_BuildingID) == 0 then
--             XGUIEng.ShowWidget(_WidgetID, 0);
--             return;
--         end
--         -- Deaktivieren, wenn ausgebaut wird.
--         if Logic.IsBuildingBeingUpgraded(_BuildingID) then
--             XGUIEng.DisableButton(_WidgetID, 1);
--         end
--         SetIcon(_WidgetID, {1, 1});
--     end
-- );
--
function API.AddBuildingButton(_Action, _Tooltip, _Update)
    return API.AddBuildingButtonAtPosition(nil, nil, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für den Entity-Typ hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Wenn ein Typ einen
-- Button zugewiesen bekommt, werden alle mit API.AddBuildingButton gesetzten
-- Buttons für den Typ ignoriert.
--
-- @param[type=number]   _Type    Typ des Gebäudes
-- @param[type=number]   _X       X-Position des Button
-- @param[type=number]   _Y       Y-Position des Button
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByTypeAtPosition(_Type, _X, _Y, _Action, _Tooltip, _Update)
    return ModuleInterfaceCore.Local:AddButtonBinding(_Type, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für den Entity-Typ hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Wenn ein Typ einen
-- Button zugewiesen bekommt, werden alle mit API.AddBuildingButton gesetzten
-- Buttons für den Typ ignoriert.
--
-- @param[type=number]   _Type    Typ des Gebäudes
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByType(_Type, _Action, _Tooltip, _Update)
    return API.AddBuildingButtonByTypeAtPosition(_Type, nil, nil, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für das Entity hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Wenn ein Entity
-- einen Button zugewiesen bekommt, werden alle mit API.AddBuildingButton oder
-- API.AddBuildingButtonByType gesetzten Buttons für das Entity ignoriert.
--
-- @param[type=function] _ScriptName Scriptname des Entity
-- @param[type=number]   _X          X-Position des Button
-- @param[type=number]   _Y          Y-Position des Button
-- @param[type=function] _Action     Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip    Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update     Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByEntityAtPosition(_ScriptName, _X, _Y, _Action, _Tooltip, _Update)
    return ModuleInterfaceCore.Local:AddButtonBinding(_ScriptName, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für das Entity hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Wenn ein Entity
-- einen Button zugewiesen bekommt, werden alle mit API.AddBuildingButton oder
-- API.AddBuildingButtonByType gesetzten Buttons für das Entity ignoriert.
--
-- @param[type=function] _ScriptName Scriptname des Entity
-- @param[type=function] _Action     Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip    Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update     Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByEntity(_ScriptName, _Action, _Tooltip, _Update)
    return API.AddBuildingButtonByEntityAtPosition(_ScriptName, nil, nil, _Action, _Tooltip, _Update);
end

---
-- Entfernt einen allgemeinen Gebäudeschalter.
--
-- @param[type=number] _ID ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButton(SpecialButtonID);
--
function API.DropBuildingButton(_ID)
    return ModuleInterfaceCore.Local:RemoveButtonBinding(0, _ID);
end

---
-- Entfernt einen Gebäudeschalter vom Gebäudetypen.
--
-- @param[type=number] _Type Typ des Gebäudes
-- @param[type=number] _ID   ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButtonFromType(Entities.B_Bakery, SpecialButtonID);
--
function API.DropBuildingButtonFromType(_Type, _ID)
    return ModuleInterfaceCore.Local:RemoveButtonBinding(_Type, _ID);
end

---
-- Entfernt einen Gebäudeschalter vom benannten Gebäude.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=number] _ID         ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButtonFromEntity("Bakery", SpecialButtonID);
--
function API.DropBuildingButtonFromEntity(_ScriptName, _ID)
    return ModuleInterfaceCore.Local:RemoveButtonBinding(_ScriptName, _ID);
end

-- Local callbacks

function SCP.InterfaceCore.StartBuildingUpgrade(_BuildingID, _PlayerID)
    if Logic.IsBuildingBeingUpgraded(_BuildingID) then
        ModuleInterfaceCore.Global:SendStartBuildingUpgradeEvent(_BuildingID, _PlayerID);
    end
end

function SCP.InterfaceCore.CancelBuildingUpgrade(_BuildingID, _PlayerID)
    if not Logic.IsBuildingBeingUpgraded(_BuildingID) then
        ModuleInterfaceCore.Global:SendCancelBuildingUpgradeEvent(_BuildingID, _PlayerID);
    end
end

