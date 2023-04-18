--[[
Swift_4_LifestockBreeding/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleLifestockBreeding = {
    Properties = {
        Name = "ModuleLifestockBreeding",
    },

    Global = {
        AnimalChildren = {},
        PastureRegister = {},

        Cattle = {
            RequiredAmount = 2,
            QuantityBoost = 9,
            AreaSize = 4500,
            GrothTimer = 15,
            FeedingTimer = 25,
            BreedingTimer = 150,
            BabySize = 0.45,
            UseCalves = true,

            Breeding = true,
            MoneyCost = 300,
        },
        Sheep = {
            RequiredAmount = 2,
            QuantityBoost = 9,
            AreaSize = 4500,
            GrothTimer = 15,
            FeedingTimer = 30,
            BreedingTimer = 120,
            BabySize = 0.45,
            UseCalves = true,

            Breeding = true,
            MoneyCost = 450,
        },
    },
    Local = {
        Cattle = {
            Breeding = true,
            MoneyCost = 300,
        },
        Sheep = {
            Breeding = true,
            MoneyCost = 450,
        },
    },
    Shared = {
        Text = {
            BreedingActive = {
                Title = {
                    de = "Zucht aktiv",
                    en = "Breeding active",
                    fr = "Élevage actif",
                },
                Text = {
                    de = "- Klicken um Zucht zu stoppen",
                    en = "- Click to stop breeding",
                    fr = "- Cliquez pour arrêter l'élevage",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                    fr = "L'élevage est bloqué!",
                },
            },
            BreedingInactive = {
                Title = {
                    de = "Zucht gestoppt",
                    en = "Breeding stopped",
                    fr = "Élevage stoppé",
                },
                Text = {
                    de = "- Klicken um Zucht zu starten {cr}- Benötigt Platz {cr}- Benötigt Getreide",
                    en = "- Click to allow breeding {cr}- Requires space {cr}- Requires grain",
                    fr = "- Cliquez pour démarrer l'élevage {cr}- Nécessite de l'espace {cr}- Nécessite des céréales",
                },
                Disabled = {
                    de = "Zucht ist gesperrt!",
                    en = "Breeding is locked!",
                    fr = "L'élevage est bloqué!",
                },
            },
        },
    }
}

-- Global ------------------------------------------------------------------- --

function ModuleLifestockBreeding.Global:OnGameStart()
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Global.Cattle.MoneyCost;

    QSB.ScriptEvents.AnimalBreed = API.RegisterScriptEvent("Event_AnimalBreed");

    for i= 1, 8 do
        self.PastureRegister[i] = {};
    end

    API.StartJob(function()
        ModuleLifestockBreeding.Global:AnimalBreedController();
    end);
    API.StartJob(function()
        ModuleLifestockBreeding.Global:AnimalGrouthController();
    end);
end

function ModuleLifestockBreeding.Global:OnEvent(_ID, _Event, ...)
end

function ModuleLifestockBreeding.Global:SpawnCattle(_X, _Y, _PlayerID, _Shrink)
    local ID = Logic.CreateEntity(Entities.A_X_Cow01, _X, _Y, 0, _PlayerID);
    if _Shrink == true then
        API.SetFloat(ID, QSB.ScriptingValue.Size, self.Cattle.BabySize);
        table.insert(self.AnimalChildren, {ID, self.Cattle.GrothTimer});
    end
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d)]],
        ID
    ));
end

function ModuleLifestockBreeding.Global:SpawnSheep(_X, _Y, _PlayerID, _Shrink)
    local Type = Entities.A_X_Sheep01;
    if not Framework.IsNetworkGame() then
        Type = Entities["A_X_Sheep0" ..math.random(1, 2)];
    end
    local ID = Logic.CreateEntity(Type, _X, _Y, 0, _PlayerID);
    if _Shrink == true then
        API.SetFloat(ID, QSB.ScriptingValue.Size, self.Sheep.BabySize);
        table.insert(self.AnimalChildren, {ID, self.Sheep.GrothTimer});
    end
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d)]],
        ID
    ));
end

function ModuleLifestockBreeding.Global:CalculateCattleBreedingTimer(_Animals)
    if self.Cattle.RequiredAmount <= _Animals then
        local Time = self.Cattle.BreedingTimer - (_Animals * self.Cattle.QuantityBoost);
        return (Time < 30 and 30) or Time;
    end
    return -1;
end

function ModuleLifestockBreeding.Global:CalculateSheepBreedingTimer(_Animals)
    if self.Sheep.RequiredAmount <= _Animals then
        local Time = self.Sheep.BreedingTimer - (_Animals * self.Sheep.QuantityBoost);
        return (Time < 30 and 30) or Time;
    end
    return -1;
end

function ModuleLifestockBreeding.Global:IsCattleNeeded(_PastureID, _PlayerID)
    if self:GetCattlePastureDelta(_PlayerID) < 1 then
        local x,y,z = Logic.EntityGetPos(_PastureID);
        local n1, ID1 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.A_X_Cow01, x, y, 900, 16);
        return n1 < 5;
    end
    return false;
end

function ModuleLifestockBreeding.Global:IsSheepNeeded(_PastureID, _PlayerID)
    if self:GetSheepPastureDelta(_PlayerID) < 1 then
        local x,y,z = Logic.EntityGetPos(_PastureID);
        local n1, ID1 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.A_X_Sheep01, x, y, 900, 16);
        local n2, ID2 = Logic.GetPlayerEntitiesInArea(_PlayerID, Entities.A_X_Sheep02, x, y, 900, 16);
        return n1+n2 < 5;
    end
    return false;
end

function ModuleLifestockBreeding.Global:GetCattlePastureDelta(_PlayerID)
    local AmountOfCattle = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CattlePasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_CattlePasture);
    return #AmountOfCattle / (AmountOfPasture * 5);
end

function ModuleLifestockBreeding.Global:GetSheepPastureDelta(_PlayerID)
    local AmountOfSheep = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.SheepPasture)};
    local AmountOfPasture = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.B_SheepPasture);
    return #AmountOfSheep / (AmountOfPasture * 5);
end

function ModuleLifestockBreeding.Global:CountCattleNearby(_Pasture)
    local PastureID = GetID(_Pasture)
    local PlayerID  = Logic.EntityGetPlayer(PastureID);
    local x, y, z   = Logic.EntityGetPos(PastureID);
    local AreaSize  = self.Cattle.AreaSize;
    local Cattle    = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Cow01, x, y, AreaSize, 16)};
    table.remove(Cattle, 1);
    return #Cattle;
end

function ModuleLifestockBreeding.Global:CountSheepsNearby(_Pasture)
    local PastureID = GetID(_Pasture)
    local PlayerID  = Logic.EntityGetPlayer(PastureID);
    local x, y, z   = Logic.EntityGetPos(PastureID);
    local AreaSize  = self.Sheep.AreaSize;
    local Sheeps1   = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep01, x, y, AreaSize, 16)};
    local Sheeps2   = {Logic.GetPlayerEntitiesInArea(PlayerID, Entities.A_X_Sheep02, x, y, AreaSize, 16)};
    table.remove(Sheeps1, 1);
    table.remove(Sheeps2, 1);
    return #Sheeps1 + #Sheeps2;
end

function ModuleLifestockBreeding.Global:AnimalGrouthController()
    for k, v in pairs(self.AnimalChildren) do
        if not IsExisting(v[1]) then
            self.AnimalChildren[k] = nil;
        else
            self.AnimalChildren[k][2] = v[2] -1;
            if v[2] < 0 then
                local IsCow = Logic.GetEntityType(v[1]) == Entities.A_X_Cow01;
                local GrothTimer = (IsCow and self.Cattle.GrothTimer) or self.Sheep.GrothTimer;
                self.AnimalChildren[k][2] = GrothTimer;
                local Scale = API.GetFloat(v[1], QSB.ScriptingValue.Size);
                API.SetFloat(v[1], QSB.ScriptingValue.Size, math.min(1, Scale + 0.05))
                if Scale + 0.05 >= 1 then
                    self.AnimalChildren[k] = nil;
                end
            end
        end
    end
end

function ModuleLifestockBreeding.Global:AnimalBreedController()
    if self.Cattle.Breeding then
        local CattlePasture = Logic.GetEntitiesOfType(Entities.B_CattlePasture);
        for k, v in pairs(CattlePasture) do
            local PlayerID = Logic.EntityGetPlayer(v);
            if not self.PastureRegister[PlayerID][v] then
                self.PastureRegister[PlayerID][v] = {0, 0};
            end
            self:CalculateCattlePastureFeeding(PlayerID, v);
            self:CattlePastureSpawnAnimal(PlayerID, v);
        end
    end

    if self.Sheep.Breeding then
        local SheepPasture = Logic.GetEntitiesOfType(Entities.B_SheepPasture);
        for k, v in pairs(SheepPasture) do
            local PlayerID = Logic.EntityGetPlayer(v);
            if not self.PastureRegister[PlayerID][v] then
                self.PastureRegister[PlayerID][v] = {0, 0};
            end
            self:CalculateSheepPastureFeeding(PlayerID, v);
            self:SheepPastureSpawnAnimal(PlayerID, v);
        end
    end
end

function ModuleLifestockBreeding.Global:CalculateCattlePastureFeeding(_PlayerID, _PastureID)
    if self:IsCattleNeeded(_PastureID, _PlayerID) and Logic.IsBuildingStopped(_PastureID) == false then
        self.PastureRegister[_PlayerID][_PastureID][1] = self.PastureRegister[_PlayerID][_PastureID][1] +1;
        if self.PastureRegister[_PlayerID][_PastureID][1] > 0 then
            self.PastureRegister[_PlayerID][_PastureID][2] = self.PastureRegister[_PlayerID][_PastureID][2] +1;
            if self.PastureRegister[_PlayerID][_PastureID][2] >= self.Cattle.FeedingTimer then
                self.PastureRegister[_PlayerID][_PastureID][2] = 0;
                if GetPlayerResources(Goods.G_Grain, _PlayerID) > 0 then
                    AddGood(Goods.G_Grain, -1, _PlayerID);
                else
                    self.PastureRegister[_PlayerID][_PastureID][1] = math.max(
                        self.PastureRegister[_PlayerID][_PastureID][1] - self.Cattle.FeedingTimer,
                        0
                    );
                end
            end
        else
            self.PastureRegister[_PlayerID][_PastureID][2] = 0;
        end
    end
end

function ModuleLifestockBreeding.Global:CalculateSheepPastureFeeding(_PlayerID, _PastureID)
    if self:IsSheepNeeded(_PastureID, _PlayerID) and Logic.IsBuildingStopped(_PastureID) == false then
        self.PastureRegister[_PlayerID][_PastureID][1] = self.PastureRegister[_PlayerID][_PastureID][1] +1;
        if self.PastureRegister[_PlayerID][_PastureID][1] > 0 then
            self.PastureRegister[_PlayerID][_PastureID][2] = self.PastureRegister[_PlayerID][_PastureID][2] +1;
            if self.PastureRegister[_PlayerID][_PastureID][2] >= self.Sheep.FeedingTimer then
                self.PastureRegister[_PlayerID][_PastureID][2] = 0;
                if GetPlayerResources(Goods.G_Grain, _PlayerID) > 0 then
                    AddGood(Goods.G_Grain, -1, _PlayerID);
                else
                    self.PastureRegister[_PlayerID][_PastureID][1] = math.max(
                        self.PastureRegister[_PlayerID][_PastureID][1] - self.Sheep.FeedingTimer,
                        0
                    );
                end
            end
        else
            self.PastureRegister[_PlayerID][_PastureID][2] = 0;
        end
    end
end

function ModuleLifestockBreeding.Global:CattlePastureSpawnAnimal(_PlayerID, _PastureID)
    local CattleNearby = self:CountCattleNearby(_PastureID);
    local TimeTillNext = self:CalculateCattleBreedingTimer(CattleNearby);
    if TimeTillNext > -1 and self.PastureRegister[_PlayerID][_PastureID][1] >= TimeTillNext then
        if self:IsCattleNeeded(_PastureID, _PlayerID) then
            local x, y = Logic.GetBuildingApproachPosition(_PastureID);
            self:SpawnCattle(x, y, _PlayerID, self.Cattle.UseCalves);
            self.PastureRegister[_PlayerID][_PastureID] = nil;
        end
    end
end

function ModuleLifestockBreeding.Global:SheepPastureSpawnAnimal(_PlayerID, _PastureID)
    local SheepNearby = self:CountSheepsNearby(_PastureID);
    local TimeTillNext = self:CalculateSheepBreedingTimer(SheepNearby);
    if TimeTillNext > -1 and self.PastureRegister[_PlayerID][_PastureID][1] >= TimeTillNext then
        if self:IsSheepNeeded(_PastureID, _PlayerID) then
            local x, y = Logic.GetBuildingApproachPosition(_PastureID);
            self:SpawnSheep(x, y, _PlayerID, self.Sheep.UseCalves);
            self.PastureRegister[_PlayerID][_PastureID] = nil;
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleLifestockBreeding.Local:OnGameStart()
    MerchantSystem.BasePricesOrigModuleLifestockBreeding                = {};
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep] = MerchantSystem.BasePrices[Goods.G_Sheep];
    MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow]   = MerchantSystem.BasePrices[Goods.G_Cow];

    MerchantSystem.BasePrices[Goods.G_Sheep] = ModuleLifestockBreeding.Local.Sheep.MoneyCost;
    MerchantSystem.BasePrices[Goods.G_Cow]   = ModuleLifestockBreeding.Local.Cattle.MoneyCost;

    QSB.ScriptEvents.AnimalBreed = API.RegisterScriptEvent("Event_AnimalBreed");

    self:InitBuyLifestockButton();
end

function ModuleLifestockBreeding.Local:ToggleBreedingState(_BarrackID)
    local BuildingEntityType = Logic.GetEntityType(_BarrackID);
    if BuildingEntityType == Entities.B_CattlePasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    elseif BuildingEntityType == Entities.B_SheepPasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    end
end

function ModuleLifestockBreeding.Local:InitBuyLifestockButton()
    HouseMenuStopProductionClicked_Orig_Stockbreeding = HouseMenuStopProductionClicked;
    HouseMenuStopProductionClicked = function()
        HouseMenuStopProductionClicked_Orig_Stockbreeding();
        local WidgetName = HouseMenu.Widget.CurrentBuilding;
        local EntityType = Entities[WidgetName];
        local PlayerID = GUI.GetPlayerID();
        local Bool = HouseMenu.StopProductionBool;

        if EntityType == Entities.B_CattleFarm then
            local Buildings = GetPlayerEntities(PlayerID, Entities.B_CattlePasture);
            for i=1, #Buildings, 1 do
                GUI.SetStoppedState(Buildings[i], Bool);
            end
        elseif EntityType == Entities.B_SheepFarm then
            local Buildings = GetPlayerEntities(PlayerID, Entities.B_SheepPasture);
            for i=1, #Buildings, 1 do
                GUI.SetStoppedState(Buildings[i], Bool);
            end
        end
    end

    local Position = {XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart")};
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_CattlePasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:ToggleBreedingState(_EntityID);
        end,
        function(_WidgetID, _EntityID)
            local Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingActive);
            if Logic.IsBuildingStopped(_EntityID) then
                Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingInactive);
            end
            API.SetTooltipCosts(Description.Title, Description.Text, Description.Disabled, {Goods.G_Grain, 1}, false);
        end,
        function(_WidgetID, _EntityID)
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(_EntityID) then
                Icon = {4, 12};
            end
            SetIcon(_WidgetID, Icon);
            local DisableState = (ModuleLifestockBreeding.Local.Cattle.Breeding and 0) or 1;
            XGUIEng.DisableButton(_WidgetID, DisableState);
        end
    );
    API.AddBuildingButtonByTypeAtPosition(
        Entities.B_SheepPasture,
        Position[1], Position[2],
        function(_WidgetID, _EntityID)
            ModuleLifestockBreeding.Local:ToggleBreedingState(_EntityID);
        end,
        function(_WidgetID, _EntityID)
            local Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingActive);
            if Logic.IsBuildingStopped(_EntityID) then
                Description = API.Localize(ModuleLifestockBreeding.Shared.Text.BreedingInactive);
            end
            API.SetTooltipCosts(Description.Title, Description.Text, Description.Disabled, {Goods.G_Grain, 1}, false);
        end,
        function(_WidgetID, _EntityID)
            local Icon = {4, 13};
            if Logic.IsBuildingStopped(_EntityID) then
                Icon = {4, 12};
            end
            SetIcon(_WidgetID, Icon);
            local DisableState = (ModuleLifestockBreeding.Local.Sheep.Breeding and 0) or 1;
            XGUIEng.DisableButton(_WidgetID, DisableState);
        end
    );
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleLifestockBreeding);

