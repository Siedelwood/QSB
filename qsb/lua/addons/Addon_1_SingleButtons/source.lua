-- -------------------------------------------------------------------------- --

Addon_SingleButtons = {
    Properties = {
        Name = "Addon_SingleButtons",
        Version = "1.0.0",
    },

    Global = {
        Data = {},
    },

    Local = {
        Data = {
            Button = {
                SingleStop = nil,
                SingleReserve = nil,
                SingleKnockDown = nil,
            },
            DowngradeCosts = 0,
        },
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_SingleButtons.Global:OnGameStart()
end

-- Local -------------------------------------------------------------------- --

function Addon_SingleButtons.Local:OnGameStart()
end

function Addon_SingleButtons.Local:AddSingleStopButton()
    if self.Data.Button.SingleStop then
        return
    end
    self.Data.Button.SingleStop = API.AddBuildingButton(
        function(_WidgetID, _EntityID)
            local IsStopped = Logic.IsBuildingStopped(_EntityID)
            GUI.SetStoppedState(_EntityID, not IsStopped)
        end,
        function(_WidgetID, _EntityID)
            local Title = "Produktion anhalten"
            local Text = "- Gebäude produziert keine Waren {cr}- Siedler verbrauchen keine Güter {cr}- Bedürfnisse müssen nicht erfüllt werden"
            if Logic.IsBuildingStopped(_EntityID) then
                Title = "Produktion fortführen";
                Text = "- Gebäude produziert Waren {cr}- Siedler verbrauchen Güter {cr}- Bedürfnisse müssen erfüllt werden"
            end
            API.SetTooltipCosts(Title, Text)
        end,
        function(_WidgetID, _EntityID)
            if Logic.IsEntityInCategory(_EntityID, EntityCategories.OuterRimBuilding) == 0
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.CityBuilding) == 0
            or Logic.IsConstructionComplete(_EntityID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0)
            else
                XGUIEng.ShowWidget(_WidgetID, 1)
            end
            if Logic.IsBuildingBeingUpgraded(_EntityID)
            or Logic.IsBuildingBeingKnockedDown(_EntityID)
            or Logic.IsBurning(_EntityID) then
                XGUIEng.DisableButton(_WidgetID, 1)
            else
                XGUIEng.DisableButton(_WidgetID, 0)
            end
            SetIcon(_WidgetID, {4, 13})
            if Logic.IsBuildingStopped(_EntityID) then
                SetIcon(_WidgetID, {4, 12})
            end
        end
    )
end

function Addon_SingleButtons.Local:DropSingleStopButton()
    if self.Data.Button.SingleStop then
        API.DropBuildingButton(self.Data.Button.SingleStop)
        self.Data.Button.SingleStop = nil
    end
end

function Addon_SingleButtons.Local:AddSingleReserveButton()
    if self.Data.Button.SingleReserve then
        return
    end
    self.Data.Button.SingleReserve = API.AddBuildingButton(
        function(_WidgetID, _EntityID)
        end,
        function(WidgetID, EntityID)
        end,
        function(_WidgetID, _EntityID)
        end
    )
end

function Addon_SingleButtons.Local:DropSingleReserveButton()
    if self.Data.Button.SingleReserve then
        API.DropBuildingButton(self.Data.Button.SingleReserve)
        self.Data.Button.SingleReserve = nil
    end
end

function Addon_SingleButtons.Local:AddSingleDowngradeButton()
    if self.Data.Button.SingleKnockDown then
        return
    end
    self.Data.Button.SingleKnockDown = API.AddBuildingButton(
        -- TODO: refactor in a way that the Button cannot be clicked when the downgradecosts are too high
        function(_WidgetID, _BuildingID)
            local CastleID = Logic.GetHeadquarters(GUI.GetPlayerID())
            if Logic.GetAmountOnOutStockByGoodType(CastleID, Goods.G_Gold) >= self.Data.DowngradeCosts then
                GUI.RemoveGoodFromStock(CastleID, Goods.G_Gold, self.Data.DowngradeCosts)
                local Health = Logic.GetEntityHealth(_BuildingID)
                local MaxHealth = Logic.GetEntityMaxHealth(_BuildingID)
                GUI.SendScriptCommand("Logic.HurtEntity(".._BuildingID..", ("..Health.." - ("..MaxHealth.."/2)))")
                Sound.FXPlay2DSound("ui\\menu_click")
                GUI.DeselectEntity(_BuildingID)
            else
                API.Message("Nicht genug Gold!")
            end
        end,
        function(_WidgetID, _BuildingID)
            API.SetTooltipCosts("Rückbau", "- Baut das Gebäude um eine Stufe zurück!", "Momentan nicht möglich", {Goods.G_Gold, self.Data.DowngradeCosts})
        end,
        function(_WidgetID, _BuildingID)
            local ID01 = Logic.IsEntityInCategory(_BuildingID, EntityCategories.CityBuilding)
            local ID02 = Logic.IsEntityInCategory(_BuildingID, EntityCategories.OuterRimBuilding)
            local ID03 = Logic.CanCancelUpgradeBuilding(_BuildingID)
            local ID05 = Logic.CanCancelKnockDownBuilding(_BuildingID)
            local ID06 = Logic.IsConstructionComplete(_BuildingID)
            local ID07 = Logic.IsBurning(_BuildingID) 
            local ID08 = Logic.IsBuildingUpgradable(_BuildingID, true)
            if (ID06 == 1) and (ID05 == false) and (ID03 == false) and (ID02 == 1 or ID01 == 1) and (ID07 == false and ID08 == false) then
                XGUIEng.ShowWidget(_WidgetID, 1)
                SetIcon(_WidgetID, {3, 15})
            else
                XGUIEng.ShowWidget(_WidgetID, 0)
            end
        end
    );
end

function Addon_SingleButtons.Local:DropSingleDowngradeButton()
    if self.Data.Button.SingleKnockDown then
        API.DropBuildingButton(self.Data.Button.SingleKnockDown)
        self.Data.Button.SingleKnockDown = nil
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_SingleButtons)