--[[
Swift_2_InterfaceCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.InterfaceCore = {};

ModuleInterfaceCore = {
    Properties = {
        Name = "ModuleInterfaceCore",
    },

    Global = {
        HumanKnightType = 0,
        HumanPlayerID = 1,
    },
    Local = {
        BuildingButtons = {
            BindingCounter = 0,
            Bindings = {},
            Configuration = {
                ["BuyAmmunitionCart"] = {
                    TypeExclusion = "^B_.*StoreHouse",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["BuyBattallion"] = {
                    TypeExclusion = "^B_[CB]a[sr][tr][la][ec]",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["PlaceField"] = {
                    TypeExclusion = "^B_.*[BFH][aei][erv][kme]",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["StartFestival"] = {
                    TypeExclusion = "^B_Marketplace",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["StartTheatrePlay"] = {
                    TypeExclusion = "^B_Theatre",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["UpgradeTurret"] = {
                    TypeExclusion = "^B_WallTurret",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["BuyBatteringRamCart"] = {
                    TypeExclusion = "^B_SiegeEngineWorkshop",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["BuyCatapultCart"] = {
                    TypeExclusion = "^B_SiegeEngineWorkshop",
                    OriginalPosition = nil,
                    Bind = nil,
                },
                ["BuySiegeTowerCart"] = {
                    TypeExclusion = "^B_SiegeEngineWorkshop",
                    OriginalPosition = nil,
                    Bind = nil,
                },
            },
        },
        HiddenWidgets = {},
        HotkeyDescriptions = {},
        ForbidRegularSave = false,
        DisableHEAutoSave = false,
        HumanKnightType = 0,
        HumanPlayerID = 1,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

QSB.PlayerNames = {};

-- Global ------------------------------------------------------------------- --

function ModuleInterfaceCore.Global:OnGameStart()
    QSB.ScriptEvents.UpgradeCanceled = API.RegisterScriptEvent("Event_UpgradeCanceled");
    QSB.ScriptEvents.UpgradeStarted = API.RegisterScriptEvent("Event_UpgradeStarted");

    API.RegisterScriptCommand("Cmd_StartBuildingUpgrade", SCP.InterfaceCore.StartBuildingUpgrade);
    API.RegisterScriptCommand("Cmd_CancelBuildingUpgrade", SCP.InterfaceCore.CancelBuildingUpgrade);

    self.HumanKnightType = Logic.GetEntityType(Logic.GetKnightID(QSB.HumanPlayerID));
    self.HumanPlayerID = QSB.HumanPlayerID;

    StartSimpleJobEx(function()
        if Logic.GetTime() > 1 then
            ModuleInterfaceCore.Global:OverridePlayerLost();
            return true;
        end
    end);
end

function ModuleInterfaceCore.Global:SendStartBuildingUpgradeEvent(_BuildingID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.UpgradeStarted, _BuildingID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(%d, %d, %d)]],
        QSB.ScriptEvents.UpgradeStarted,
        _BuildingID,
        _PlayerID
    ));
end

function ModuleInterfaceCore.Global:SendCancelBuildingUpgradeEvent(_BuildingID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.UpgradeCanceled, _BuildingID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(%d, %d, %d)]],
        QSB.ScriptEvents.UpgradeCanceled,
        _BuildingID,
        _PlayerID
    ));
end

function ModuleInterfaceCore.Global:OverridePlayerLost()
    GameCallback_PlayerLost = function(_PlayerID)
        if _PlayerID == QSB.HumanPlayerID then
            if not Framework.IsNetworkGame() then
                QuestTemplate:TerminateEventsAndStuff()
                if MissionCallback_Player1Lost then
                    MissionCallback_Player1Lost()
                end
            end
        end
    end
end

function ModuleInterfaceCore.Global:SetControllingPlayer(_OldPlayerID, _NewPlayerID, _NewStatisticsName)
    assert(type(_OldPlayerID) == "number");
    assert(type(_NewPlayerID) == "number");
    _NewStatisticsName = _NewStatisticsName or "";
    local EntityID = Logic.GetKnightID(_NewPlayerID);
    local EntityType = Logic.GetEntityType(EntityID);

    Logic.PlayerSetIsHumanFlag(_OldPlayerID, 0);
    Logic.PlayerSetIsHumanFlag(_NewPlayerID, 1);
    Logic.PlayerSetGameStateToPlaying(_NewPlayerID);

    self.HumanKnightType = EntityType;
    self.HumanPlayerID = _NewPlayerID;
    QSB.HumanPlayerID = _NewPlayerID;

    Logic.ExecuteInLuaLocalState([[
        GUI.ClearSelection()
        GUI.SetControlledPlayer(]].._NewPlayerID..[[)
        
        local KnightID = Logic.GetKnightID(]].._NewPlayerID..[[)
        ModuleInterfaceCore.Local.HumanPlayerID = ]].._NewPlayerID..[[
        QSB.HumanPlayerID = ]].._NewPlayerID..[[;

        for k,v in pairs(Buffs) do
            GUI_Buffs.UpdateBuffsInInterface(]].._NewPlayerID..[[, v)
            GUI.ResetMiniMap()
        end

        if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
            local Portrait = GetKnightActor(]]..EntityType..[[)
            local KnightType = Logic.GetEntityType(KnightID)
            ModuleInterfaceCore.Local.HumanKnightType = KnightType;
            g_PlayerPortrait[GUI.GetPlayerID()] = Portrait
            LocalSetKnightPicture()
        end

        local NewName = "]].._NewStatisticsName..[["
        if NewName ~= "" then
            GUI_MissionStatistic.PlayerNames[GUI.GetPlayerID()] = NewName
        end
        HideOtherMenus()

        function GUI_Knight.GetTitleNameByTitleID(_KnightType, _TitleIndex)
            local KeyName = "Title_" .. GetNameOfKeyInTable(KnightTitles, _TitleIndex) .. "_" .. KnightGender[]]..EntityType..[[]
            local String = XGUIEng.GetStringTableText("UI_ObjectNames/" .. KeyName)
            if String == nil or String == "" then
                String = "Knight not in Gender Table? (localscript.lua)"
            end
            return String
        end
    ]]);

    self.HumanPlayerChangedOnce = true;
end

-- Local -------------------------------------------------------------------- --

function ModuleInterfaceCore.Local:OnGameStart()
    QSB.ScriptEvents.UpgradeCanceled = API.RegisterScriptEvent("Event_UpgradeCanceled");
    QSB.ScriptEvents.UpgradeStarted = API.RegisterScriptEvent("Event_UpgradeStarted");

    self.HumanKnightType = Logic.GetEntityType(Logic.GetKnightID(QSB.HumanPlayerID));
    self.HumanPlayerID = QSB.HumanPlayerID;

    self:InitBackupPositions();
    self:OverrideOnSelectionChanged();
    self:OverrideMissionGoodCounter();
    self:OverrideUpdateClaimTerritory();
    self:SetupHackRegisterHotkey();
    self:OverrideBuyAmmunitionCart();
    self:OverrideBuyBattalion();
    self:OverrideBuySiegeEngineCart();
    self:OverridePlaceField();
    self:OverrideStartFestival();
    self:OverrideStartTheatrePlay();
    self:OverrideUpgradeTurret();
    self:OverrideUpgradeBuilding();

    -- Schnellspeichern generell verbieten
    API.AddBlockQuicksaveCondition(function()
        return ModuleInterfaceCore.Local.ForbidRegularSave == true;
    end);
    -- HE Quicksave verbieten
    API.AddBlockQuicksaveCondition(function(...)
        return not arg[1] and ModuleInterfaceCore.Local.DisableHEAutoSave == true;
    end);
end

function ModuleInterfaceCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:UpdateHiddenWidgets();
        self:DisplaySaveButtons();
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInterfaceCore.Local:OverrideUpgradeBuilding()
    GUI_BuildingButtons.UpgradeClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local EntityID = GUI.GetSelectedEntity();
        if Logic.CanCancelUpgradeBuilding(EntityID) then
            Sound.FXPlay2DSound("ui\\menu_click");
            GUI.CancelBuildingUpgrade(EntityID);
            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/BuildingButtons", 1);
            API.BroadcastScriptCommand(QSB.ScriptCommands.CancelBuildingUpgrade, EntityID, GUI.GetPlayerID());
            return;
        end
        local Costs = GUI_BuildingButtons.GetUpgradeCosts();
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
        if CanBuyBoolean == true then
            Sound.FXPlay2DSound("ui\\menu_click");
            GUI.UpgradeBuilding(EntityID, nil);
            StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightWisdom);
            if WidgetID ~= 0 then
                SaveButtonPressed(WidgetID);
            end
            API.BroadcastScriptCommand(QSB.ScriptCommands.StartBuildingUpgrade, EntityID, GUI.GetPlayerID());
        else
            Message(CanNotBuyString);
        end
    end
end

function ModuleInterfaceCore.Local:OverrideOnSelectionChanged()
    GameCallback_GUI_SelectionChanged_Orig_InterfaceCore = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_InterfaceCore(_Source);
        ModuleInterfaceCore.Local:UnbindButtons();
        ModuleInterfaceCore.Local:BindButtons(GUI.GetSelectedEntity());
    end
end

function ModuleInterfaceCore.Local:OverrideBuyAmmunitionCart()
    GUI_BuildingButtons.BuyAmmunitionCartClicked_Orig_InterfaceCore = GUI_BuildingButtons.BuyAmmunitionCartClicked;
    GUI_BuildingButtons.BuyAmmunitionCartClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.BuyAmmunitionCartClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyAmmunitionCartUpdate_Orig_InterfaceCore = GUI_BuildingButtons.BuyAmmunitionCartUpdate;
    GUI_BuildingButtons.BuyAmmunitionCartUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {10, 4});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.BuyAmmunitionCartUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverrideBuyBattalion()
    GUI_BuildingButtons.BuyBattalionClicked_Orig_InterfaceCore = GUI_BuildingButtons.BuyBattalionClicked;
    GUI_BuildingButtons.BuyBattalionClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.BuyBattalionClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyBattalionMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.BuyBattalionMouseOver;
    GUI_BuildingButtons.BuyBattalionMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName] then
            Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuyBattalionMouseOver_Orig_InterfaceCore();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyBattalionUpdate_Orig_InterfaceCore = GUI_BuildingButtons.BuyBattalionUpdate;
    GUI_BuildingButtons.BuyBattalionUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.BuyBattalionUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverridePlaceField()
    GUI_BuildingButtons.PlaceFieldClicked_Orig_InterfaceCore = GUI_BuildingButtons.PlaceFieldClicked;
    GUI_BuildingButtons.PlaceFieldClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.PlaceFieldClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.PlaceFieldMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.PlaceFieldMouseOver;
    GUI_BuildingButtons.PlaceFieldMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.PlaceFieldMouseOver_Orig_InterfaceCore();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.PlaceFieldUpdate_Orig_InterfaceCore = GUI_BuildingButtons.PlaceFieldUpdate;
    GUI_BuildingButtons.PlaceFieldUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.PlaceFieldUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverrideStartFestival()
    GUI_BuildingButtons.StartFestivalClicked_Orig_InterfaceCore = GUI_BuildingButtons.StartFestivalClicked;
    GUI_BuildingButtons.StartFestivalClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartFestivalClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartFestivalMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.StartFestivalMouseOver;
    GUI_BuildingButtons.StartFestivalMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartFestivalMouseOver_Orig_InterfaceCore();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartFestivalUpdate_Orig_InterfaceCore = GUI_BuildingButtons.StartFestivalUpdate;
    GUI_BuildingButtons.StartFestivalUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {4, 15});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.StartFestivalUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverrideStartTheatrePlay()
    GUI_BuildingButtons.StartTheatrePlayClicked_Orig_InterfaceCore = GUI_BuildingButtons.StartTheatrePlayClicked;
    GUI_BuildingButtons.StartTheatrePlayClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartTheatrePlayClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartTheatrePlayMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.StartTheatrePlayMouseOver;
    GUI_BuildingButtons.StartTheatrePlayMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartTheatrePlayMouseOver_Orig_InterfaceCore();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartTheatrePlayUpdate_Orig_InterfaceCore = GUI_BuildingButtons.StartTheatrePlayUpdate;
    GUI_BuildingButtons.StartTheatrePlayUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {16, 2});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.StartTheatrePlayUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverrideUpgradeTurret()
    GUI_BuildingButtons.UpgradeTurretClicked_Orig_InterfaceCore = GUI_BuildingButtons.UpgradeTurretClicked;
    GUI_BuildingButtons.UpgradeTurretClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.UpgradeTurretClicked_Orig_InterfaceCore();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.UpgradeTurretMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.UpgradeTurretMouseOver;
    GUI_BuildingButtons.UpgradeTurretMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.UpgradeTurretMouseOver_Orig_InterfaceCore();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.UpgradeTurretUpdate_Orig_InterfaceCore = GUI_BuildingButtons.UpgradeTurretUpdate;
    GUI_BuildingButtons.UpgradeTurretUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.UpgradeTurretUpdate_Orig_InterfaceCore();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleInterfaceCore.Local:OverrideBuySiegeEngineCart()
    GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_InterfaceCore = GUI_BuildingButtons.BuySiegeEngineCartClicked;
    GUI_BuildingButtons.BuySiegeEngineCartClicked = function(_EntityType)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_InterfaceCore(_EntityType);
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuySiegeEngineCartMouseOver_Orig_InterfaceCore = GUI_BuildingButtons.BuySiegeEngineCartMouseOver;
    GUI_BuildingButtons.BuySiegeEngineCartMouseOver = function(_EntityType, _Right)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuySiegeEngineCartMouseOver_Orig_InterfaceCore(_EntityType, _Right);
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuySiegeEngineCartUpdate_Orig_InterfaceCore = GUI_BuildingButtons.BuySiegeEngineCartUpdate;
    GUI_BuildingButtons.BuySiegeEngineCartUpdate = function(_EntityType)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleInterfaceCore.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            if WidgetName == "BuyBatteringRamCart" then
                SetIcon(WidgetID, {9, 2});
            elseif WidgetName == "BuySiegeTowerCart" then
                SetIcon(WidgetID, {9, 3});
            elseif WidgetName == "BuyCatapultCart" then
                SetIcon(WidgetID, {9, 1});
            end
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.BuySiegeEngineCartUpdate_Orig_InterfaceCore(_EntityType);
        end
        Button.Update(WidgetID, EntityID);
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInterfaceCore.Local:InitBackupPositions()
    for k, v in pairs(self.BuildingButtons.Configuration) do
        local x, y = XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/" ..k);
        self.BuildingButtons.Configuration[k].OriginalPosition = {x, y};
    end
end

function ModuleInterfaceCore.Local:GetButtonsForOverwrite(_ID, _Amount)
    local Buttons = {};
    local Type = Logic.GetEntityType(_ID);
    local TypeName = Logic.GetEntityTypeName(Type);
    for k, v in pairs(self.BuildingButtons.Configuration) do
        if #Buttons == _Amount then
            break;
        end
        if not TypeName:find(v.TypeExclusion) then
            table.insert(Buttons, k);
        end
    end
    assert(#Buttons == _Amount);
    table.sort(Buttons);
    return Buttons;
end

function ModuleInterfaceCore.Local:AddButtonBinding(_Type, _X, _Y, _ActionFunction, _TooltipController, _UpdateController)
    if not self.BuildingButtons.Bindings[_Type] then
        self.BuildingButtons.Bindings[_Type] = {};
    end
    if #self.BuildingButtons.Bindings[_Type] < 6 then
        self.BuildingButtons.BindingCounter = self.BuildingButtons.BindingCounter +1;
        table.insert(self.BuildingButtons.Bindings[_Type], {
            ID       = self.BuildingButtons.BindingCounter,
            Position = {_X, _Y},
            Action   = _ActionFunction,
            Tooltip  = _TooltipController,
            Update   = _UpdateController,
        });
        return self.BuildingButtons.BindingCounter;
    end
    return 0;
end

function ModuleInterfaceCore.Local:RemoveButtonBinding(_Type, _ID)
    if not self.BuildingButtons.Bindings[_Type] then
        self.BuildingButtons.Bindings[_Type] = {};
    end
    for i= #self.BuildingButtons.Bindings[_Type], 1, -1 do
        if self.BuildingButtons.Bindings[_Type][i].ID == _ID then
            table.remove(self.BuildingButtons.Bindings[_Type], i);
        end
    end
end

function ModuleInterfaceCore.Local:BindButtons(_ID)
    if _ID == nil or _ID == 0 or (Logic.IsBuilding(_ID) == 0 and not Logic.IsWall(_ID)) then
        return self:UnbindButtons();
    end
    local Name = Logic.GetEntityName(_ID);
    local Type = Logic.GetEntityType(_ID);

    local Key;
    if self.BuildingButtons.Bindings[Name] then
        Key = Name;
    end
    -- TODO: Proper inclusion of categories
    -- The problem is, that en entiry might have more than one category. How
    -- do we decide which category gets the priority?
    if not Key and self.BuildingButtons.Bindings[Type] then
        Key = Type;
    end
    if not Key and self.BuildingButtons.Bindings[0] then
        Key = 0;
    end

    if Key then
        local ButtonNames = self:GetButtonsForOverwrite(_ID, #self.BuildingButtons.Bindings[Key]);
        local DefaultPositionIndex = 0;
        for i= 1, #self.BuildingButtons.Bindings[Key] do
            self.BuildingButtons.Configuration[ButtonNames[i]].Bind = self.BuildingButtons.Bindings[Key][i];
            XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/" ..ButtonNames[i], 1);
            XGUIEng.DisableButton("/InGame/Root/Normal/BuildingButtons/" ..ButtonNames[i], 0);
            local Position = self.BuildingButtons.Bindings[Key][i].Position;
            if not Position[1] or not Position[2] then
                local AnchorPosition = {12, 296};
                Position[1] = AnchorPosition[1] + (64 * DefaultPositionIndex);
                Position[2] = AnchorPosition[2];
                DefaultPositionIndex = DefaultPositionIndex +1;
            end
            XGUIEng.SetWidgetLocalPosition(
                "/InGame/Root/Normal/BuildingButtons/" ..ButtonNames[i],
                Position[1],
                Position[2]
            );
        end
    end
end

function ModuleInterfaceCore.Local:UnbindButtons()
    for k, v in pairs(self.BuildingButtons.Configuration) do
        local Position = self.BuildingButtons.Configuration[k].OriginalPosition;
        if Position then
            XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/" ..k, Position[1], Position[2]);
        end
        self.BuildingButtons.Configuration[k].Bind = nil;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInterfaceCore.Local:DisplaySaveButtons()
    if self.ForbidRegularSave then
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 0);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 0);
    else
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    end
end

function ModuleInterfaceCore.Local:DisplayInterfaceButton(_Widget, _Hide)
    self.HiddenWidgets[_Widget] = _Hide == true;
    XGUIEng.ShowWidget(_Widget, (_Hide == true and 0) or 1);
end

function ModuleInterfaceCore.Local:UpdateHiddenWidgets()
    for k, v in pairs(self.HiddenWidgets) do
        XGUIEng.ShowWidget(k, 0);
    end
end

function ModuleInterfaceCore.Local:OverrideMissionGoodCounter()
    StartMissionGoodOrEntityCounter = function(_Icon, _AmountToReach)
        local IconWidget = "/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon";
        local CounterWidget = "/InGame/Root/Normal/MissionGoodOrEntityCounter";
        if type(_Icon[3]) == "string" then
            ModuleInterfaceCore.Local:SetIcon(IconWidget, _Icon, 64, _Icon[3]);
        else
            SetIcon(IconWidget, _Icon);
        end
        g_MissionGoodOrEntityCounterAmountToReach = _AmountToReach;
        g_MissionGoodOrEntityCounterIcon = _Icon;
        XGUIEng.ShowWidget(CounterWidget, 1);
    end
end

function ModuleInterfaceCore.Local:OverrideUpdateClaimTerritory()
    GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceCore = GUI_Knight.ClaimTerritoryUpdate;
    GUI_Knight.ClaimTerritoryUpdate = function()
        GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceCore();
        local Key = "/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory";
        if ModuleInterfaceCore.Local.HiddenWidgets[Key] == true then
            XGUIEng.ShowWidget(Key, 0);
            return true;
        end
    end
end

function ModuleInterfaceCore.Local:SetPlayerPortraitByPrimaryKnight(_PlayerID)
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

function ModuleInterfaceCore.Local:SetPlayerPortraitBySettler(_PlayerID, _Portrait)
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

function ModuleInterfaceCore.Local:SetPlayerPortraitByModelName(_PlayerID, _Portrait)
    if not Models["Heads_" .. tostring(_Portrait)] then
        _Portrait = "H_NPC_Generic_Trader";
    end
    g_PlayerPortrait[_PlayerID] = _Portrait;
end

function ModuleInterfaceCore.Local:SetIcon(_WidgetID, _Coordinates, _Size, _Name)
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

function ModuleInterfaceCore.Local:TextNormal(_title, _text, _disabledText)
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

function ModuleInterfaceCore.Local:TextCosts(_title,_text,_disabledText,_costs,_inSettlement)
    _costs = _costs or {};
    local Costs = {};
    -- This transforms the content of the metatable to a new table so that the
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

function ModuleInterfaceCore.Local:SetupHackRegisterHotkey()
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

            for k,v in pairs(ModuleInterfaceCore.Local.HotkeyDescriptions) do
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

Swift:RegisterModule(ModuleInterfaceCore);

