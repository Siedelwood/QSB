-- -------------------------------------------------------------------------- --

ModuleGuiControl = {
    Properties = {
        Name = "ModuleGuiControl",
        Version = "3.0.0 (BETA 2.0.0)"
    },

    Global = {},
    Local = {
        HiddenWidgets = {},
        HotkeyDescriptions = {},
        SpeedLimit = 1,
    },

    Shared = {
        Text = {
            Message = {
                NoSpeedUp = {
                    de = "Die Spielgeschwindigkeit kann nicht erhöht werden!",
                    en = "The game speed can not be increased!",
                    fr = "La vitesse du jeu ne peut pas être augmentée!"
                }
            }
        }
    };
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
    self:InitForbidSpeedUp();
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
        if type(_Icon[3]) == "string" or _Icon[3] and _Icon[3] > 2 then
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
    if _title and string.find(_title, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and string.find(_text, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    _disabledText = _disabledText or "";
    if _disabledText and string.find(_disabledText, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
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
    if _title and string.find(_title, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
        _title = XGUIEng.GetStringTableText(_title);
    end
    if _text and string.find(_text, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
        _text = XGUIEng.GetStringTableText(_text);
    end
    if _disabledText and string.find(_disabledText, "^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
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

function ModuleGuiControl.Local:SetSpeedLimit(_Limit)
    if Framework.IsNetworkGame() then
        debug("ModuleGuiControl: Detect network game. Aborting!");
        return;
    end
    _Limit = (_Limit < 1 and 1) or math.floor(_Limit);
    debug("ModuleGuiControl: Setting speed limit to " .._Limit);
    self.SpeedLimit = _Limit;
end

function ModuleGuiControl.Local:ActivateSpeedLimit(_Flag)
    if Framework.IsNetworkGame() then
        debug("ModuleGuiControl: Detect network game. Aborting!");
        return;
    end
    self.UseSpeedLimit = _Flag == true;
    if _Flag and Game.GameTimeGetFactor(GUI.GetPlayerID()) > self.SpeedLimit then
        debug("ModuleGuiControl: Speed is capped at " ..self.SpeedLimit);
        Game.GameTimeSetFactor(GUI.GetPlayerID(), self.SpeedLimit);
        g_GameSpeed = 1;
    end
end

function ModuleGuiControl.Local:InitForbidSpeedUp()
    GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function( _Speed )
        GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp( _Speed );
        if ModuleGuiControl.Local.UseSpeedLimit == true then
            debug("ModuleGuiControl: Checking speed limit.");
            if _Speed > ModuleGuiControl.Local.SpeedLimit then
                debug("ModuleGuiControl: Speed is capped at " ..tostring(_Speed).. ".");
                Game.GameTimeSetFactor(GUI.GetPlayerID(), ModuleGuiControl.Local.SpeedLimit);
                g_GameSpeed = 1;
                API.Message(ModuleGuiControl.Shared.Text.Message.NoSpeedUp);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleGuiControl);

