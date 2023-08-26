-- -------------------------------------------------------------------------- --

---
-- Ermöglicht, die Anzeige von Menüoptionen zu steuern.
--
-- Es können verschiedene Anzeigen ausgetauscht werden.
-- <ul>
-- <li>Spielerfarbe</li>
-- <li>Spielername</li>
-- <li>Spielerportrait</li>
-- <li>Territorienname</li>
-- </ul>
--
-- Es können verschiedene Zugriffsoptionen für den Spieler gesetzt werden.
-- <ul>
-- <li>Minimap anzeigen/deaktivieren</li>
-- <li>Minimap umschalten anzeigen/deaktivieren</li>
-- <li>Diplomatiemenü anzeigen/deaktivieren</li>
-- <li>Produktionsmenü anzeigen/deaktivieren</li>
-- <li>Wettermenü anzeigen/deaktivieren</li>
-- <li>Baumenü anzeigen/deaktivieren</li>
-- <li>Territorium einnehmen anzeigen/deaktivieren</li>
-- <li>Ritterfähigkeit anzeigen/deaktivieren</li>
-- <li>Ritter selektieren anzeigen/deaktivieren</li>
-- <li>Militär selektieren anzeigen/deaktivieren</li>
-- </ul>
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
-- Events, auf die reagiert werden kann.
--
-- @field BuildingPlaced      Ein Gebäude wurde in Auftrag gegeben. (Parameter: EntityID, PlayerID)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

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
-- Gibt dem Spieler einen neuen Namen.
--
-- <b>hinweis</b>: Die Änderung des Spielernamens betrifft sowohl die Anzeige
-- bei den Quests als auch im Diplomatiemenü.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Name Name des Spielers
-- @within Anwenderfunktionen
--
function API.SetPlayerName(_PlayerID, _Name)
    assert(type(_PlayerID) == "number");
    assert(type(_Name) == "string");
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SetPlayerName(%d, "%s")]],
            _PlayerID,
            _Name
        ));
        return;
    end
    GUI_MissionStatistic.PlayerNames[_PlayerID] = _Name
    QSB.PlayerNames[_PlayerID] = _Name;
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
-- <b>Trivia</b>: Diese Funktionalität wird Umgangssprachlich als "Kopf
-- tauschen" oder "Kopf wechseln" bezeichnet.
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
        ModuleGuiControl.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID);
        return;
    end
    if _Portrait ~= nil and IsExisting(_Portrait) then
        ModuleGuiControl.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait);
        return;
    end
    ModuleGuiControl.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait);
end

---
-- Fügt eine Beschreibung zu einem benutzerdefinierten Hotkey hinzu.
--
-- Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.
--
-- <b>Hinweis</b>: Diese Funktionalität selbst muss mit Input.KeyBindDown oder
-- Input.KeyBindUp separat implementiert werden!
--
-- @param[type=string] _Key         Tastenkombination
-- @param[type=string] _Description Beschreibung des Hotkey
-- @return[type=number] Index oder Fehlercode
-- @within Anwenderfunktionen
--
function API.AddShortcutEntry(_Key, _Description)
    if not GUI then
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    for i= 1, #ModuleGuiControl.Local.HotkeyDescriptions do
        if ModuleGuiControl.Local.HotkeyDescriptions[i][1] == _Key then
            return -1;
        end
    end
    local ID = #ModuleGuiControl.Local.HotkeyDescriptions+1;
    table.insert(ModuleGuiControl.Local.HotkeyDescriptions, {ID = ID, _Key, _Description});
    return #ModuleGuiControl.Local.HotkeyDescriptions;
end

---
-- Entfernt eine Beschreibung eines benutzerdefinierten Hotkeys.
--
-- @param[type=number] _ID Index in Table
-- @within Anwenderfunktionen
--
function API.RemoveShortcutEntry(_ID)
    if not GUI then
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    for k, v in pairs(ModuleGuiControl.Local.HotkeyDescriptions) do
        if v.ID == _ID then
            ModuleGuiControl.Local.HotkeyDescriptions[k] = nil;
        end
    end
end

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
    ModuleGuiControl.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name);
end

---
-- Ändert den Beschreibungstext eines Button oder eines Icon.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- Die Funktion kann auch mit deutsch/english lokalisierten Tabellen als
-- Text gefüttert werden. In diesem Fall wird der deutsche Text genommen,
-- wenn es sich um eine deutsche Spielversion handelt. Andernfalls wird
-- immer der englische Text verwendet.
--
-- @param[type=string] _Title        Titel des Tooltip
-- @param[type=string] _Text         Text des Tooltip
-- @param[type=string] _DisabledText Textzusatz wenn inaktiv
-- @within Anwenderfunktionen
--
function API.SetTooltipNormal(_Title, _Text, _DisabledText)
    if not GUI then
        return;
    end
    ModuleGuiControl.Local:TooltipNormal(API.Localize(_Title), API.Localize(_Text), API.Localize(_DisabledText));
end

---
-- Ändert den Beschreibungstext und die Kosten eines Button.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
-- Button oder Icon ausgeführt werden muss.
--
-- @see API.SetTooltipNormal
--
-- @param[type=string]  _Title        Titel des Tooltip
-- @param[type=string]  _Text         Text des Tooltip
-- @param[type=string]  _DisabledText Textzusatz wenn inaktiv
-- @param[type=table]   _Costs        Kostentabelle
-- @param[type=boolean] _InSettlement Kosten in Siedlung suchen
-- @within Anwenderfunktionen
--
function API.SetTooltipCosts(_Title, _Text, _DisabledText, _Costs, _InSettlement)
    if not GUI then
        return;
    end
    ModuleGuiControl.Local:TooltipCosts(API.Localize(_Title), API.Localize(_Text), API.Localize(_DisabledText), _Costs, _InSettlement);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay",_Flag);
    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapTerrain",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/MinimapButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/DiplomacyMenuButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/ProductionMenuButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/WeatherMenuButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbilityProgress",_Flag);
    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButtonProgress",_Flag);
    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton",_Flag);
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

    ModuleGuiControl.Local:DisplayInterfaceButton("/InGame/Root/Normal/AlignBottomRight/BuildMenu", _Flag);
end

---
-- Setzt die Spielgeschwindigkeit auf Stufe 1 fest oder gibt sie wieder frei.
--
-- <b>Hinweis</b>: Die Geschwindigkeitsbeschränkung wirkt sich ebenfalls auf
-- Cheats aus. Es ist generell nicht mehr möglich, das Spiel zu beschleunigen,
-- wenn die "Speedbremse" aktiv ist.
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Geschwindigkeit auf Stufe 1 festsetzen
-- API.SpeedLimitActivate(true);
-- -- Geschwindigkeit freigeben
-- API.SpeedLimitActivate(false);
--
function API.SpeedLimitActivate(_Flag)
    if GUI or Framework.IsNetworkGame() then
        return;
    end
    return Logic.ExecuteInLuaLocalState("ModuleGuiControl.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end

---
-- Diese Funktion setzt die maximale Spielgeschwindigkeit bis zu der das Spiel
-- beschleunigt werden kann.
--
-- @param[type=number] _Limit Obergrenze für Spielgeschwindigkeit
-- @within Anwenderfunktionen
-- @see API.SpeedLimitActivate
--
-- @usage -- Legt die Speedbremse auf Stufe 1 fest.
-- API.SetSpeedLimit(1)
-- -- Legt die Speedbremse auf Stufe 2 fest.
-- API.SetSpeedLimit(2)
--
function API.SetSpeedLimit(_Limit)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.SetSpeedLimit(" ..tostring(_Limit).. ")");
        return;
    end
    return ModuleGuiControl.Local:SetSpeedLimit(_Limit);
end
SetSpeedLimit = API.SetSpeedLimit

