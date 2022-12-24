--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleBuildingButtons = {
    Properties = {
        Name = "ModuleBuildingButtons",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {},
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
    },

    Shared = {};
}

-- Global ------------------------------------------------------------------- --

function ModuleBuildingButtons.Global:OnGameStart()
    QSB.ScriptEvents.UpgradeCanceled = API.RegisterScriptEvent("Event_UpgradeCanceled");
    QSB.ScriptEvents.UpgradeStarted = API.RegisterScriptEvent("Event_UpgradeStarted");
    QSB.ScriptEvents.FestivalStarted = API.RegisterScriptEvent("Event_FestivalStarted");
    QSB.ScriptEvents.SermonStarted = API.RegisterScriptEvent("Event_SermonStarted");
    QSB.ScriptEvents.TheatrePlayStarted = API.RegisterScriptEvent("Event_TheatrePlayStarted");

    -- Building upgrade started event
    API.RegisterScriptCommand("Cmd_StartBuildingUpgrade", function(_BuildingID, _PlayerID)
        if Logic.IsBuildingBeingUpgraded(_BuildingID) then
            ModuleBuildingButtons.Global:SendStartBuildingUpgradeEvent(_BuildingID, _PlayerID);
        end
    end);
    -- Building upgrade canceled event
    API.RegisterScriptCommand("Cmd_CancelBuildingUpgrade", function(_BuildingID, _PlayerID)
        if not Logic.IsBuildingBeingUpgraded(_BuildingID) then
            ModuleBuildingButtons.Global:SendCancelBuildingUpgradeEvent(_BuildingID, _PlayerID);
        end
    end);
    -- Theatre play started event
    API.RegisterScriptCommand("Cmd_StartTheatrePlay", function(_BuildingID, _PlayerID)
        if Logic.GetTheatrePlayProgress(_BuildingID) ~= 0 then
            ModuleBuildingButtons.Global:SendTheatrePlayEvent(_BuildingID, _PlayerID);
        end
    end);
    -- Festival started event
    API.RegisterScriptCommand("Cmd_StartRegularFestival", function(_PlayerID)
        if Logic.IsFestivalActive(_PlayerID) == true then
            ModuleBuildingButtons.Global:SendStartRegularFestivalEvent(_PlayerID);
        end
    end);
    -- Sermon started event
    API.RegisterScriptCommand("Cmd_StartSermon", function(_PlayerID)
        if Logic.IsSermonActive(_PlayerID) == true then
            ModuleBuildingButtons.Global:SendStartSermonEvent(_PlayerID);
        end
    end);
end

function ModuleBuildingButtons.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleBuildingButtons.Global:SendStartBuildingUpgradeEvent(_BuildingID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.UpgradeStarted, _BuildingID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.UpgradeStarted, %d, %d)]],
        _BuildingID,
        _PlayerID
    ));
end

function ModuleBuildingButtons.Global:SendCancelBuildingUpgradeEvent(_BuildingID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.UpgradeCanceled, _BuildingID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.UpgradeCanceled, %d, %d)]],
        _BuildingID,
        _PlayerID
    ));
end

function ModuleBuildingButtons.Global:SendTheatrePlayEvent(_BuildingID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.TheatrePlayStarted, _BuildingID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TheatrePlayStarted, %d, %d)]],
        _BuildingID,
        _PlayerID
    ));
end

function ModuleBuildingButtons.Global:SendStartRegularFestivalEvent(_PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.FestivalStarted, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.FestivalStarted, %d)]],
        _PlayerID
    ));
end

function ModuleBuildingButtons.Global:SendStartSermonEvent(_PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.SermonStarted, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.SermonStarted, %d)]],
        _PlayerID
    ));
end

-- Local -------------------------------------------------------------------- --

function ModuleBuildingButtons.Local:OnGameStart()
    QSB.ScriptEvents.UpgradeCanceled = API.RegisterScriptEvent("Event_UpgradeCanceled");
    QSB.ScriptEvents.UpgradeStarted = API.RegisterScriptEvent("Event_UpgradeStarted");
    QSB.ScriptEvents.FestivalStarted = API.RegisterScriptEvent("Event_FestivalStarted");
    QSB.ScriptEvents.SermonStarted = API.RegisterScriptEvent("Event_SermonStarted");
    QSB.ScriptEvents.TheatrePlayStarted = API.RegisterScriptEvent("Event_TheatrePlayStarted");

    self:InitBackupPositions();
    self:OverrideOnSelectionChanged();
    self:OverrideBuyAmmunitionCart();
    self:OverrideBuyBattalion();
    self:OverrideBuySiegeEngineCart();
    self:OverridePlaceField();
    self:OverrideStartFestival();
    self:OverrideStartTheatrePlay();
    self:OverrideUpgradeTurret();
    self:OverrideUpgradeBuilding();
    self:OverrideStartSermon();
end

function ModuleBuildingButtons.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleBuildingButtons.Local:OverrideOnSelectionChanged()
    GameCallback_GUI_SelectionChanged_Orig_Interface = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function(_Source)
        GameCallback_GUI_SelectionChanged_Orig_Interface(_Source);
        ModuleBuildingButtons.Local:UnbindButtons();
        ModuleBuildingButtons.Local:BindButtons(GUI.GetSelectedEntity());
    end
end

function ModuleBuildingButtons.Local:OverrideBuyAmmunitionCart()
    GUI_BuildingButtons.BuyAmmunitionCartClicked_Orig_Interface = GUI_BuildingButtons.BuyAmmunitionCartClicked;
    GUI_BuildingButtons.BuyAmmunitionCartClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.BuyAmmunitionCartClicked_Orig_Interface();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyAmmunitionCartUpdate_Orig_Interface = GUI_BuildingButtons.BuyAmmunitionCartUpdate;
    GUI_BuildingButtons.BuyAmmunitionCartUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {10, 4});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.BuyAmmunitionCartUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideBuyBattalion()
    GUI_BuildingButtons.BuyBattalionClicked_Orig_Interface = GUI_BuildingButtons.BuyBattalionClicked;
    GUI_BuildingButtons.BuyBattalionClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.BuyBattalionClicked_Orig_Interface();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyBattalionMouseOver_Orig_Interface = GUI_BuildingButtons.BuyBattalionMouseOver;
    GUI_BuildingButtons.BuyBattalionMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName] then
            Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuyBattalionMouseOver_Orig_Interface();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuyBattalionUpdate_Orig_Interface = GUI_BuildingButtons.BuyBattalionUpdate;
    GUI_BuildingButtons.BuyBattalionUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.BuyBattalionUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverridePlaceField()
    GUI_BuildingButtons.PlaceFieldClicked_Orig_Interface = GUI_BuildingButtons.PlaceFieldClicked;
    GUI_BuildingButtons.PlaceFieldClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.PlaceFieldClicked_Orig_Interface();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.PlaceFieldMouseOver_Orig_Interface = GUI_BuildingButtons.PlaceFieldMouseOver;
    GUI_BuildingButtons.PlaceFieldMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.PlaceFieldMouseOver_Orig_Interface();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.PlaceFieldUpdate_Orig_Interface = GUI_BuildingButtons.PlaceFieldUpdate;
    GUI_BuildingButtons.PlaceFieldUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.PlaceFieldUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideStartFestival()
    GUI_BuildingButtons.StartFestivalClicked = function(_FestivalIndex)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            local PlayerID = GUI.GetPlayerID();
            local Costs = {Logic.GetFestivalCost(PlayerID, _FestivalIndex)};
            local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
            if EntityID ~= Logic.GetMarketplace(PlayerID) then
                return;
            end
            if CanBuyBoolean == true then
                Sound.FXPlay2DSound("ui\\menu_click");
                GUI.StartFestival(PlayerID, _FestivalIndex);
                StartEventMusic(MusicSystem.EventFestivalMusic, PlayerID);
                StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightSong);
                GUI.AddBuff(Buffs.Buff_Festival);
                API.BroadcastScriptCommand(QSB.ScriptCommands.StartRegularFestival, PlayerID);
            else
                Message(CanNotBuyString);
            end
            return;
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartFestivalMouseOver_Orig_Interface = GUI_BuildingButtons.StartFestivalMouseOver;
    GUI_BuildingButtons.StartFestivalMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartFestivalMouseOver_Orig_Interface();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartFestivalUpdate_Orig_Interface = GUI_BuildingButtons.StartFestivalUpdate;
    GUI_BuildingButtons.StartFestivalUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {4, 15});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.StartFestivalUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideStartTheatrePlay()
    GUI_BuildingButtons.StartTheatrePlayClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            local PlayerID = GUI.GetPlayerID();
            local GoodType = Logic.GetGoodTypeOnOutStockByIndex(EntityID, 0);
            local Amount = Logic.GetMaxAmountOnStock(EntityID);
            local Costs = {GoodType, Amount};
            local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs);
            if Logic.CanStartTheatrePlay(EntityID) == true then
                Sound.FXPlay2DSound("ui\\menu_click");
                GUI.StartTheatrePlay(EntityID);
                API.BroadcastScriptCommand(QSB.ScriptCommands.StartTheatrePlay, PlayerID);
            elseif CanBuyBoolean == false then
                Message(CanNotBuyString);
            end
            return;
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartTheatrePlayMouseOver_Orig_Interface = GUI_BuildingButtons.StartTheatrePlayMouseOver;
    GUI_BuildingButtons.StartTheatrePlayMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.StartTheatrePlayMouseOver_Orig_Interface();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.StartTheatrePlayUpdate_Orig_Interface = GUI_BuildingButtons.StartTheatrePlayUpdate;
    GUI_BuildingButtons.StartTheatrePlayUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            SetIcon(WidgetID, {16, 2});
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.StartTheatrePlayUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideUpgradeTurret()
    GUI_BuildingButtons.UpgradeTurretClicked_Orig_Interface = GUI_BuildingButtons.UpgradeTurretClicked;
    GUI_BuildingButtons.UpgradeTurretClicked = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.UpgradeTurretClicked_Orig_Interface();
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.UpgradeTurretMouseOver_Orig_Interface = GUI_BuildingButtons.UpgradeTurretMouseOver;
    GUI_BuildingButtons.UpgradeTurretMouseOver = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            return GUI_BuildingButtons.UpgradeTurretMouseOver_Orig_Interface();
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.UpgradeTurretUpdate_Orig_Interface = GUI_BuildingButtons.UpgradeTurretUpdate;
    GUI_BuildingButtons.UpgradeTurretUpdate = function()
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        if not Button then
            XGUIEng.ShowWidget(WidgetID, 1);
            XGUIEng.DisableButton(WidgetID, 0);
            return GUI_BuildingButtons.UpgradeTurretUpdate_Orig_Interface();
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideBuySiegeEngineCart()
    GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Interface = GUI_BuildingButtons.BuySiegeEngineCartClicked;
    GUI_BuildingButtons.BuySiegeEngineCartClicked = function(_EntityType)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuySiegeEngineCartClicked_Orig_Interface(_EntityType);
        end
        Button.Action(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuySiegeEngineCartMouseOver_Orig_Interface = GUI_BuildingButtons.BuySiegeEngineCartMouseOver;
    GUI_BuildingButtons.BuySiegeEngineCartMouseOver = function(_EntityType, _Right)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
        end
        if not Button then
            return GUI_BuildingButtons.BuySiegeEngineCartMouseOver_Orig_Interface(_EntityType, _Right);
        end
        Button.Tooltip(WidgetID, EntityID);
    end

    GUI_BuildingButtons.BuySiegeEngineCartUpdate_Orig_Interface = GUI_BuildingButtons.BuySiegeEngineCartUpdate;
    GUI_BuildingButtons.BuySiegeEngineCartUpdate = function(_EntityType)
        local WidgetID = XGUIEng.GetCurrentWidgetID();
        local WidgetName = XGUIEng.GetWidgetNameByID(WidgetID);
        local EntityID = GUI.GetSelectedEntity();
        local Button;
        if WidgetName == "BuyCatapultCart"
        or WidgetName == "BuySiegeTowerCart"
        or WidgetName == "BuyBatteringRamCart" then
            Button = ModuleBuildingButtons.Local.BuildingButtons.Configuration[WidgetName].Bind;
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
            return GUI_BuildingButtons.BuySiegeEngineCartUpdate_Orig_Interface(_EntityType);
        end
        Button.Update(WidgetID, EntityID);
    end
end

function ModuleBuildingButtons.Local:OverrideUpgradeBuilding()
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

function ModuleBuildingButtons.Local:OverrideStartSermon()
    function GUI_BuildingButtons.StartSermonClicked()
        local PlayerID = GUI.GetPlayerID();
        if Logic.CanSermonBeActivated(PlayerID) then
            GUI.ActivateSermon(PlayerID);
            StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightHealing);
            GUI.AddBuff(Buffs.Buff_Sermon);
            local CathedralID = Logic.GetCathedral(PlayerID);
            local x, y = Logic.GetEntityPosition(CathedralID);
            local z = 0;
            Sound.FXPlay3DSound("buildings\\building_start_sermon", x, y, z);
            API.BroadcastScriptCommand(QSB.ScriptCommands.StartSermon, GUI.GetPlayerID());
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleBuildingButtons.Local:InitBackupPositions()
    for k, v in pairs(self.BuildingButtons.Configuration) do
        local x, y = XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/" ..k);
        self.BuildingButtons.Configuration[k].OriginalPosition = {x, y};
    end
end

function ModuleBuildingButtons.Local:GetButtonsForOverwrite(_ID, _Amount)
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

function ModuleBuildingButtons.Local:AddButtonBinding(_Type, _X, _Y, _ActionFunction, _TooltipController, _UpdateController)
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

function ModuleBuildingButtons.Local:RemoveButtonBinding(_Type, _ID)
    if not self.BuildingButtons.Bindings[_Type] then
        self.BuildingButtons.Bindings[_Type] = {};
    end
    for i= #self.BuildingButtons.Bindings[_Type], 1, -1 do
        if self.BuildingButtons.Bindings[_Type][i].ID == _ID then
            table.remove(self.BuildingButtons.Bindings[_Type], i);
        end
    end
end

function ModuleBuildingButtons.Local:BindButtons(_ID)
    if _ID == nil or _ID == 0 or (Logic.IsBuilding(_ID) == 0 and not Logic.IsWall(_ID)) then
        return self:UnbindButtons();
    end
    local Name = Logic.GetEntityName(_ID);
    local Type = Logic.GetEntityType(_ID);

    local WidgetsForOverride = self:GetButtonsForOverwrite(_ID, 6);
    local ButtonOverride = {};
    -- Add buttons for named entity
    if self.BuildingButtons.Bindings[Name] and #self.BuildingButtons.Bindings[Name] > 0 then
        for i= 1, #self.BuildingButtons.Bindings[Name] do
            table.insert(ButtonOverride, self.BuildingButtons.Bindings[Name][i]);
        end
    end
    -- Add buttons for named entity
    if self.BuildingButtons.Bindings[Type] and #self.BuildingButtons.Bindings[Type] > 0 then
        for i= 1, #self.BuildingButtons.Bindings[Type] do
            table.insert(ButtonOverride, self.BuildingButtons.Bindings[Type][i]);
        end
    end
    -- Add buttons for named entity
    if self.BuildingButtons.Bindings[0] and #self.BuildingButtons.Bindings[0] > 0 then
        for i= 1, #self.BuildingButtons.Bindings[0] do
            table.insert(ButtonOverride, self.BuildingButtons.Bindings[0][i]);
        end
    end

    -- Place first six buttons (if present)
    for i= 1, #ButtonOverride do
        if i > 6 then
            break;
        end
        local ButtonName = WidgetsForOverride[i];
        self.BuildingButtons.Configuration[ButtonName].Bind = ButtonOverride[i];
        XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/" ..ButtonName, 1);
        XGUIEng.DisableButton("/InGame/Root/Normal/BuildingButtons/" ..ButtonName, 0);
        local X = ButtonOverride[i].Position[1];
        local Y = ButtonOverride[i].Position[2];
        if not X or not Y then
            local AnchorPosition = {12, 296};
            X = AnchorPosition[1] + (64 * (i-1));
            Y = AnchorPosition[2];
        end
        XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/" ..ButtonName, X, Y);
    end
end

function ModuleBuildingButtons.Local:UnbindButtons()
    for k, v in pairs(self.BuildingButtons.Configuration) do
        local Position = self.BuildingButtons.Configuration[k].OriginalPosition;
        if Position then
            XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/" ..k, Position[1], Position[2]);
        end
        self.BuildingButtons.Configuration[k].Bind = nil;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleBuildingButtons);

