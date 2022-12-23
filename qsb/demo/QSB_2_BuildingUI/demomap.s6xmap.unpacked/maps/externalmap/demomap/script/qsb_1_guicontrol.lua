--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleGuiControl = {
    Properties = {
        Name = "ModuleGuiControl",
        Version = "4.0.0 (ALPHA 1.0.0)"
    },

    Global = {},
    Local = {
        HiddenWidgets = {},
        HotkeyDescriptions = {},
    },

    Shared = {};
}

QSB.PlayerNames = {};

-- Global ------------------------------------------------------------------- --

function ModuleGuiControl.Global:OnGameStart()
    QSB.ScriptEvents.BuildingPlaced = API.RegisterScriptEvent("Event_BuildingPlaced");

    API.RegisterScriptCommand("Cmd_UpdateTexturePosition", function(_Category, _Key, _Value)
        g_TexturePositions = g_TexturePositions or {};
        g_TexturePositions[_Category] = g_TexturePositions[_Category] or {};
        g_TexturePositions[_Category][_Key] = _Value;
    end);
end

function ModuleGuiControl.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleGuiControl.Local:OnGameStart()
    QSB.ScriptEvents.BuildingPlaced = API.RegisterScriptEvent("Event_BuildingPlaced");

    self:PostTexturePositionsToGlobal();
    self:OverrideAfterBuildingPlacement();
    self:OverrideMissionGoodCounter();
    self:OverrideUpdateClaimTerritory();
    self:SetupHackRegisterHotkey();
end

function ModuleGuiControl.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:UpdateHiddenWidgets();
    end
end

-- -------------------------------------------------------------------------- --

function ModuleGuiControl.Local:OverrideAfterBuildingPlacement()
    GameCallback_GUI_AfterBuildingPlacement_Orig_EntityEventCore = GameCallback_GUI_AfterBuildingPlacement;
    GameCallback_GUI_AfterBuildingPlacement = function ()
        GameCallback_GUI_AfterBuildingPlacement_Orig_EntityEventCore();

        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        API.StartHiResDelay(0, function()
            local Results = {Logic.GetPlayerEntitiesInArea(GUI.GetPlayerID(), 0, x, y, 50, 16)};
            for i= 2, Results[1] +1 do
                if  Results[i]
                and Results[i] ~= 0
                and Logic.IsBuilding(Results[i]) == 1
                and Logic.IsConstructionComplete(Results[i]) == 0
                then
                    API.BroadcastScriptEventToGlobal("BuildingPlaced", Results[i], Logic.EntityGetPlayer(Results[i]));
                    API.SendScriptEvent(QSB.ScriptEvents.BuildingPlaced, Results[i], Logic.EntityGetPlayer(Results[i]));
                end
            end
        end, x, y);
    end
end

-- -------------------------------------------------------------------------- --

function ModuleGuiControl.Local:PostTexturePositionsToGlobal()
    API.StartJob(function()
        if Logic.GetTime() > 1 then
            for k, v in pairs(g_TexturePositions) do
                for kk, vv in pairs(v) do
                    API.SendScriptCommand(
                        QSB.ScriptCommands.UpdateTexturePosition,
                        GUI.GetPlayerID(),
                        k,
                        kk,
                        vv
                    );
                end
            end
            return true;
        end
    end);
end

-- -------------------------------------------------------------------------- --

function ModuleGuiControl.Local:DisplayInterfaceButton(_Widget, _Hide)
    self.HiddenWidgets[_Widget] = _Hide == true;
    XGUIEng.ShowWidget(_Widget, (_Hide == true and 0) or 1);
end

function ModuleGuiControl.Local:UpdateHiddenWidgets()
    for k, v in pairs(self.HiddenWidgets) do
        XGUIEng.ShowWidget(k, 0);
    end
end

function ModuleGuiControl.Local:OverrideMissionGoodCounter()
    StartMissionGoodOrEntityCounter = function(_Icon, _AmountToReach)
        local IconWidget = "/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon";
        local CounterWidget = "/InGame/Root/Normal/MissionGoodOrEntityCounter";
        if type(_Icon[3]) == "string" or _Icon[3] > 2 then
            ModuleGuiControl.Local:SetIcon(IconWidget, _Icon, 64, _Icon[3]);
        else
            SetIcon(IconWidget, _Icon);
        end
        g_MissionGoodOrEntityCounterAmountToReach = _AmountToReach;
        g_MissionGoodOrEntityCounterIcon = _Icon;
        XGUIEng.ShowWidget(CounterWidget, 1);
    end
end

function ModuleGuiControl.Local:OverrideUpdateClaimTerritory()
    GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_Interface = GUI_Knight.ClaimTerritoryUpdate;
    GUI_Knight.ClaimTerritoryUpdate = function()
        GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_Interface();
        local Key = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory";
        if ModuleGuiControl.Local.HiddenWidgets[Key] == true then
            XGUIEng.ShowWidget(Key, 0);
            return true;
        end
    end
end

function ModuleGuiControl.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID)
    local KnightID = Logic.GetKnightID(_PlayerID);
    local HeadModelName = "H_NPC_Generic_Trader";
    if KnightID ~= 0 then
        local KnightType = Logic.GetEntityType(KnightID);
        local KnightTypeName = Logic.GetEntityTypeName(KnightType);
        HeadModelName = "H" .. string.sub(KnightTypeName, 2, 8) .. "_" .. string.sub(KnightTypeName, 9);

        if not Models["Heads_" .. HeadModelName] then
            HeadModelName = "H_NPC_Generic_Trader";
        end
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

function ModuleGuiControl.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait)
    local PortraitMap = {
        ["U_KnightChivalry"]           = "H_Knight_Chivalry",
        ["U_KnightHealing"]            = "H_Knight_Healing",
        ["U_KnightPlunder"]            = "H_Knight_Plunder",
        ["U_KnightRedPrince"]          = "H_Knight_RedPrince",
        ["U_KnightSabatta"]            = "H_Knight_Sabatt",
        ["U_KnightSong"]               = "H_Knight_Song",
        ["U_KnightTrading"]            = "H_Knight_Trading",
        ["U_KnightWisdom"]             = "H_Knight_Wisdom",
        ["U_NPC_Amma_NE"]              = "H_NPC_Amma",
        ["U_NPC_Castellan_ME"]         = "H_NPC_Castellan_ME",
        ["U_NPC_Castellan_NA"]         = "H_NPC_Castellan_NA",
        ["U_NPC_Castellan_NE"]         = "H_NPC_Castellan_NE",
        ["U_NPC_Castellan_SE"]         = "H_NPC_Castellan_SE",
        ["U_MilitaryBandit_Ranged_ME"] = "H_NPC_Mercenary_ME",
        ["U_MilitaryBandit_Melee_NA"]  = "H_NPC_Mercenary_NA",
        ["U_MilitaryBandit_Melee_NE"]  = "H_NPC_Mercenary_NE",
        ["U_MilitaryBandit_Melee_SE"]  = "H_NPC_Mercenary_SE",
        ["U_NPC_Monk_ME"]              = "H_NPC_Monk_ME",
        ["U_NPC_Monk_NA"]              = "H_NPC_Monk_NA",
        ["U_NPC_Monk_NE"]              = "H_NPC_Monk_NE",
        ["U_NPC_Monk_SE"]              = "H_NPC_Monk_SE",
        ["U_NPC_Villager01_ME"]        = "H_NPC_Villager01_ME",
        ["U_NPC_Villager01_NA"]        = "H_NPC_Villager01_NA",
        ["U_NPC_Villager01_NE"]        = "H_NPC_Villager01_NE",
        ["U_NPC_Villager01_SE"]        = "H_NPC_Villager01_SE",
    }

    if g_GameExtraNo > 0 then
        PortraitMap["U_KnightPraphat"]           = "H_Knight_Praphat";
        PortraitMap["U_KnightSaraya"]            = "H_Knight_Saraya";
        PortraitMap["U_KnightKhana"]             = "H_Knight_Khana";
        PortraitMap["U_MilitaryBandit_Melee_AS"] = "H_NPC_Mercenary_AS";
        PortraitMap["U_NPC_Castellan_AS"]        = "H_NPC_Castellan_AS";
        PortraitMap["U_NPC_Villager_AS"]         = "H_NPC_Villager_AS";
        PortraitMap["U_NPC_Monk_AS"]             = "H_NPC_Monk_AS";
        PortraitMap["U_NPC_Monk_Khana"]          = "H_NPC_Monk_Khana";
    end

    local HeadModelName = "H_NPC_Generic_Trader";
    local EntityID = GetID(_Portrait);
    if EntityID ~= 0 then
        local EntityType = Logic.GetEntityType(EntityID);
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        HeadModelName = PortraitMap[EntityTypeName] or "H_NPC_Generic_Trader";
        if not HeadModelName then
            HeadModelName = "H_NPC_Generic_Trader";
        end
    end
    g_PlayerPortrait[_PlayerID] = HeadModelName;
end

function ModuleGuiControl.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait)
    if not Models["Heads_" .. tostring(_Portrait)] then
        _Portrait = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = _Portrait;
end

function ModuleGuiControl.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
    _Size = _Size or 64;
    _Coordinates[3] = _Coordinates[3] or 0;
    if _Name == nil then
        return SetIcon(_WidgetID, _Coordinates, _Size);
    end
    assert(_Size == 44 or _Size == 64 or _Size == 128);
    if _Size == 44 then
        _Name = _Name.. ".png";
    end
    if _Size == 64 then
        _Name = _Name.. "big.png";
    end
    if _Size == 128 then
        _Name = _Name.. "verybig.png";
    end

    local u0, u1, v0, v1;
    u0 = (_Coordinates[1] - 1) * _Size;
    v0 = (_Coordinates[2] - 1) * _Size;
    u1 = (_Coordinates[1]) * _Size;
    v1 = (_Coordinates[2]) * _Size;
    State = 1;
    if XGUIEng.IsButton(_WidgetID) == 1 then
        State = 7;
    end
    XGUIEng.SetMaterialAlpha(_WidgetID, State, 255);
    XGUIEng.SetMaterialTexture(_WidgetID, State, _Name);
    XGUIEng.SetMaterialUV(_WidgetID, State, u0, v0, u1, v1);
end

function ModuleGuiControl.Local:TooltipNormal(_title, _text, _disabledText)
    if _title and _title:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and _text:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    _disabledText = _disabledText or "";
    if _disabledText and _disabledText:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _disabledText = XGUIEng.GetStringTableText(_disabledText);
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();

    local title = (_title and _title) or "";
    local text = (_text and _text) or "";
    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText;
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. title);
    XGUIEng.SetText(TooltipDescriptionWidget, text .. disabled);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);

    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    local TooltipContainerSizeWidgets = {TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);
end

function ModuleGuiControl.Local:TooltipCosts(_title,_text,_disabledText,_costs,_inSettlement)
    _costs = _costs or {};
    local Costs = {};
    -- This transforms the content of a metatable to a new table so that the
    -- internal script does correctly render the costs.
    for i= 1, 4, 1 do
        Costs[i] = _costs[i];
    end
    if _title and _title:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and _text:find("[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    if _disabledText and _disabledText:find("^[A-Za-z0-9]+/[A-Za-z0-9]+$") then
        _disabledText = XGUIEng.GetStringTableText(_disabledText);
    end

    local TooltipContainerPath = "/InGame/Root/Normal/TooltipBuy";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();

    local title = (_title and _title) or "";
    local text = (_text and _text) or "";
    local disabled = "";
    if XGUIEng.IsButtonDisabled(PositionWidget) == 1 and _disabledText then
        disabled = disabled .. "{cr}{@color:255,32,32,255}" .. _disabledText;
    end

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. title);
    XGUIEng.SetText(TooltipDescriptionWidget, text .. disabled);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);

    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    GUI_Tooltip.SetCosts(TooltipCostsContainer, Costs, _inSettlement);
    local TooltipContainerSizeWidgets = {TooltipContainer, TooltipCostsContainer, TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget, nil, true);
    GUI_Tooltip.OrderTooltip(TooltipContainerSizeWidgets, TooltipFadeInContainer, TooltipCostsContainer, PositionWidget, TooltipBGWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);
end

function ModuleGuiControl.Local:SetupHackRegisterHotkey()
    function g_KeyBindingsOptions:OnShow()
        if Game ~= nil then
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 1);
        else
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 0);
        end

        if g_KeyBindingsOptions.Descriptions == nil then
            g_KeyBindingsOptions.Descriptions = {};
            DescRegister("MenuInGame");
            DescRegister("MenuDiplomacy");
            DescRegister("MenuProduction");
            DescRegister("MenuPromotion");
            DescRegister("MenuWeather");
            DescRegister("ToggleOutstockInformations");
            DescRegister("JumpMarketplace");
            DescRegister("JumpMinimapEvent");
            DescRegister("BuildingUpgrade");
            DescRegister("BuildLastPlaced");
            DescRegister("BuildStreet");
            DescRegister("BuildTrail");
            DescRegister("KnockDown");
            DescRegister("MilitaryAttack");
            DescRegister("MilitaryStandGround");
            DescRegister("MilitaryGroupAdd");
            DescRegister("MilitaryGroupSelect");
            DescRegister("MilitaryGroupStore");
            DescRegister("MilitaryToggleUnits");
            DescRegister("UnitSelect");
            DescRegister("UnitSelectToggle");
            DescRegister("UnitSelectSameType");
            DescRegister("StartChat");
            DescRegister("StopChat");
            DescRegister("QuickSave");
            DescRegister("QuickLoad");
            DescRegister("TogglePause");
            DescRegister("RotateBuilding");
            DescRegister("ExitGame");
            DescRegister("Screenshot");
            DescRegister("ResetCamera");
            DescRegister("CameraMove");
            DescRegister("CameraMoveMouse");
            DescRegister("CameraZoom");
            DescRegister("CameraZoomMouse");
            DescRegister("CameraRotate");

            for k,v in pairs(ModuleGuiControl.Local.HotkeyDescriptions) do
                if v then
                    v[1] = (type(v[1]) == "table" and API.Localize(v[1])) or v[1];
                    v[2] = (type(v[2]) == "table" and API.Localize(v[2])) or v[2];
                    table.insert(g_KeyBindingsOptions.Descriptions, 1, v);
                end
            end
        end
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ShortcutList);
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ActionList);
        for Index, Desc in ipairs(g_KeyBindingsOptions.Descriptions) do
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ShortcutList, Desc[1]);
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ActionList,   Desc[2]);
        end
    end
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleGuiControl);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Die Anzeige von Menüoptionen steuern.
--
-- Es können verschiedene Anzeigen ausgetauscht werden.
-- <ul>
-- <li>Spielerfrabe</li>
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

QSB.CinematicEvent = {};

CinematicEvent = {
    NotTriggered = 0,
    Active = 1,
    Concluded = 2,
}

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
-- @param[type=number] _playerID ID des Spielers
-- @param[type=string] _name Name des Spielers
-- @within Anwenderfunktionen
--
function API.SetPlayerName(_playerID,_name)
    assert(type(_playerID) == "number");
    assert(type(_name) == "string");
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SetPlayerName(%d, "%s")]],
            _playerID,
            _name
        ));
    end
    GUI_MissionStatistic.PlayerNames[_playerID] = _name
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
-- @local
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
-- @local
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
-- @param[type=string] _title        Titel des Tooltip
-- @param[type=string] _text         Text des Tooltip
-- @param[type=string] _disabledText Textzusatz wenn inaktiv
-- @within Anwenderfunktionen
--
function API.SetTooltipNormal(_title, _text, _disabledText)
    if not GUI then
        return;
    end
    ModuleGuiControl.Local:TooltipNormal(_title, _text, _disabledText);
end

---
-- Ändert den Beschreibungstext und die Kosten eines Button.
--
-- Wichtig ist zu beachten, dass diese Funktion in der Tooltip-Funktion des
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
    ModuleGuiControl.Local:TooltipCosts(_title,_text,_disabledText,_costs,_inSettlement);
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

