-- -------------------------------------------------------------------------- --

ModuleLifestockBreeding = {
    Properties = {
        Name = "ModuleLifestockBreeding",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        PlayerData = {},
        CattleBasePrice = 300,
        CattleGrainCost = 10,
        CattleGrainUpkeep = 1,
        CattleFeedingTimer = 0,
        SheepBasePrice = 300,
        SheepGrainCost = 10,
        SheepGrainUpkeep = 1,
        SheepFeedingTimer = 0,
    },
    Local = {
        PlayerData = {},
        BuyLock = false,
        CattleBasePrice = 300,
        CattleGrainCost = 10,
        CattleGrainUpkeep = 1,
        CattleFeedingTimer = 0,
        SheepBasePrice = 300,
        SheepGrainCost = 10,
        SheepGrainUpkeep = 1,
        SheepFeedingTimer = 0,

        Text = {
            CattleTitle = "",
            CattleDescription = "",
            CattleDisabled = "",
            SheepTitle = "",
            SheepDescription = "",
            SheepDisabled = "",
        },
    },
}

-- Global ------------------------------------------------------------------- --

function ModuleLifestockBreeding.Global:OnGameStart()
    -- Create Events
    QSB.ScriptEvents.BreedAnimalClicked = API.RegisterScriptEvent("Event_BreedAnimalClicked");
    QSB.ScriptEvents.CattleBought = API.RegisterScriptEvent("Event_CattleBought");
    QSB.ScriptEvents.SheepBought = API.RegisterScriptEvent("Event_SheepBought");

    -- Change base prices
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];
    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Global.Cattle.MoneyCost;

    for PlayerID = 1, 8 do
        self.PlayerData[PlayerID] {
            CattleActive = true,
            SheepActive = true,
        };
    end

    API.StartJob(function()
        ModuleLifestockBreeding.Global:ControlFeeding();
    end);
end

function ModuleLifestockBreeding.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.BreedAnimalClicked then
        --- @diagnostic disable-next-line: param-type-mismatch
        ModuleLifestockBreeding.Global:BuyAnimal(arg[1], arg[2], arg[3]);
    end
end

function ModuleLifestockBreeding.Global:BuyAnimal(_Index, _PlayerID, _BuildingID)
    local AnimalType = (_Index == "Cattle" and Entities.A_X_Cow01) or Entities.A_X_Sheep01;
    if self.PlayerData[_PlayerID] and self.PlayerData[_PlayerID][_Index.. "Active"] == false then
        return;
    end
    local GrainCost = self[_Index.. "GrainCost"];
    if GetPlayerResources(Goods.G_Grain, _PlayerID) < GrainCost then
        return;
    end
    local x,y = Logic.GetBuildingApproachPosition(_BuildingID);
    local EntityID = Logic.CreateEntity(AnimalType, x, y, 0, _PlayerID);
    AddGood(Goods.G_Grain, (-1) * GrainCost, _PlayerID);

    API.SendScriptEvent(QSB.ScriptEvents[_Index.. "Bought"], _PlayerID, EntityID, _BuildingID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(%d, %d, %d, %d)]],
        QSB.ScriptEvents[_Index.. "Bought"], _PlayerID, EntityID, _BuildingID
    ));
end

function ModuleLifestockBreeding.Global:ControlFeedthenControlDecaying()
    for PlayerID = 1, 8 do
        if Logic.PlayerGetIsHumanFlag(PlayerID) then
            -- Cattle
            local CattleTimer = self.CattleFeedingTimer;
            local CattleList = {Logic.GetPlayerEntitiesInCategory(PlayerID, EntityCategories.CattlePasture)};
            if CattleTimer > 0 then
                local FeedingTime = math.max(CattleTimer * (1 - (0.03 * #CattleList)), 15);
                if #CattleList > 0 and Logic.GetTime() % math.floor(FeedingTime) == 0 then
                    local Upkeep = self.CattleGrainUpkeep;
                    local GrainAmount = GetPlayerResources(Goods.G_Grain, PlayerID);
                    if GrainAmount >= Upkeep then
                        AddGood(Goods.G_Grain, (-1) * Upkeep, PlayerID);
                    end
                end
            end
            -- Sheep
            local SheepTimer = self.SheepFeedingTimer;
            local SheepList = {Logic.GetPlayerEntitiesInCategory(PlayerID, EntityCategories.SheepPasture)};
            if SheepTimer > 0 then
                local FeedingTime = math.max(SheepTimer * (1 - (0.03 * #SheepList)), 15);
                if #SheepList > 0 and Logic.GetTime() % math.floor(FeedingTime) == 0 then
                    local Upkeep = self.SheepGrainUpkeep;
                    local GrainAmount = GetPlayerResources(Goods.G_Grain, PlayerID);
                    if GrainAmount >= Upkeep then
                        AddGood(Goods.G_Grain, (-1) * Upkeep, PlayerID);
                    end
                end
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleLifestockBreeding.Local:OnGameStart()
    -- Create Events
    QSB.ScriptEvents.BreedAnimalClicked = API.RegisterScriptEvent("Event_BreedAnimalClicked");
    QSB.ScriptEvents.CattleBought = API.RegisterScriptEvent("Event_CattleBought");
    QSB.ScriptEvents.SheepBought = API.RegisterScriptEvent("Event_SheepBought");

    -- Get texts
    self.Text.CattleTitle = XGUIEng.GetStringTableText("Names/A_X_Cow01");
    self.Text.CattleDescription = XGUIEng.GetStringTableText("UI_ObjectDescription/G_Cow");
    self.Text.CattleDisabled = XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight");
    self.Text.SheepTitle = XGUIEng.GetStringTableText("Names/A_X_Sheep01");
    self.Text.SheepDescription = XGUIEng.GetStringTableText("UI_ObjectDescription/G_Sheep");
    self.Text.SheepDisabled = XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight");

    -- Change base prices
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];
    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Local.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Local.Cattle.MoneyCost;

    for PlayerID = 1, 8 do
        self.PlayerData[PlayerID] {
            CattleActive = true,
            SheepActive = true,
        };
    end

    self:InitBuyCowButton();
    self:InitBuySheepButton();
end

function ModuleLifestockBreeding.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.CattleBought then
        if arg[1] == GUI.GetPlayerID() then
            self.BuyLock = false;
        end
    elseif _ID == QSB.ScriptEvents.SheepBought then
        if arg[1] == GUI.GetPlayerID() then
            self.BuyLock = false;
        end
    end
end

function ModuleLifestockBreeding.Local:BuyAnimalAction(_Index, _WidgetID, _EntityID)
    local GrainCost = self[_Index.. "GrainCost"];
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if GetPlayerResources(Goods.G_Grain, PlayerID) < GrainCost then
        local Text = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");
        Message(Text);
        return;
    end
    -- Prevent click spam
    self.BuyLock = true;
    -- Send Events
    API.SendScriptEventToGlobal(QSB.ScriptEvents.BreedAnimalClicked, _Index, PlayerID, _EntityID);
    API.SendScriptEvent(QSB.ScriptEvents.BreedAnimalClicked, _Index, PlayerID, _EntityID);
end

function ModuleLifestockBreeding.Local:BuyAnimalTooltip(_Index, _WidgetID, _EntityID)
    local Title = self.Text[_Index.. "Title"];
    local Text  = self.Text[_Index.. "Description"];
    local Disabled = "";

    local GrainCost = self[_Index.. "GrainCost"];
    if XGUIEng.IsButtonDisabled(_WidgetID) == 1 then
        Disabled = self.Text[_Index.. "Disabled"];
    end
    API.SetTooltipCosts(Title, Text, Disabled, {Goods.G_Grain, GrainCost}, true);
end

function ModuleLifestockBreeding.Local:BuyAnimalUpdate(_Index, _WidgetID, _EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local PastureType = Logic.GetEntityType(_EntityID);
    local Icon = (_Index == "Cattle" and {3, 16}) or {4, 1};
    local DisabledFlag = 0;

    local PastureList = GetPlayerEntities(PlayerID, PastureType);
    local AnimalList = {Logic.GetPlayerEntitiesInCategory(PlayerID, EntityCategories[_Index.. "Pasture"])};

    if (self.PlayerData[PlayerID] and self.PlayerData[PlayerID][_Index.. "Active"] == false)
    or self.BuyLock or (#PastureList * 5) <= #AnimalList then
        Icon = (_Index == "Cattle" and {4, 2}) or {4, 3};
        DisabledFlag = 1;
    end
    XGUIEng.DisableButton(_WidgetID, DisabledFlag);
    SetIcon(_WidgetID, Icon);
end

function ModuleLifestockBreeding.Local:InitBuyCowButton()
    local Widget = "/InGame/Root/Normal/BuildingButtons/BuyCatapultCart";
    local Position = {XGUIEng.GetWidgetLocalPosition(Widget)};
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_CattlePasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalAction("Cattle", _WidgetID, _EntityID);
        end,
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalTooltip("Cattle", _WidgetID, _EntityID);
        end,
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalUpdate("Cattle", _WidgetID, _EntityID);
        end
    )
end

function ModuleLifestockBreeding.Local:InitBuySheepButton()
    local Widget = "/InGame/Root/Normal/BuildingButtons/BuyCatapultCart";
    local Position = {XGUIEng.GetWidgetLocalPosition(Widget)};
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_SheepPasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalAction("Sheep", _WidgetID, _EntityID);
        end,
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalTooltip("Sheep", _WidgetID, _EntityID);
        end,
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:BuyAnimalUpdate("Sheep", _WidgetID, _EntityID);
        end
    )
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleLifestockBreeding);

