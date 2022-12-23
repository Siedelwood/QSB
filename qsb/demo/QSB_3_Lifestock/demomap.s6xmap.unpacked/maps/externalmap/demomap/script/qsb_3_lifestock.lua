--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleLifestockBreeding = {
    Properties = {
        Name = "ModuleLifestockBreeding",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        AnimalChildren = {},
        PastureRegister = {},

        Cattle = {
            RequiredAmount = 2,
            QuantityBoost = 9,
            AreaSize = 4500,
            GrothTimer = 15,
            FeedingTimer = 20,
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
            BreedingTimer = 210,
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

function ModuleLifestockBreeding.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleLifestockBreeding.Global:SpawnCattle(_X, _Y, _PlayerID, _Shrink)
    local ID = Logic.CreateEntity(Entities.A_X_Cow01, _X, _Y, 0, _PlayerID);
    if _Shrink == true then
        API.SetFloat(ID, QSB.ScriptingValue.Size, self.Cattle.BabySize);
        table.insert(self.AnimalChildren, {ID, self.Cattle.GrothTimer});
    end
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, _PlayerID, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d, %d)]],
        _PlayerID, ID
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
    API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, _PlayerID, ID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.AnimalBreed, %d, %d)]],
        _PlayerID, ID
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

    self:OverrideHouseMenuProductionButton();
    self:InitBuyCattleButton();
    self:InitBuySheepButton();
end

function ModuleLifestockBreeding.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleLifestockBreeding.Local:ToggleBreedingState(_BarrackID)
    local BuildingEntityType = Logic.GetEntityType(_BarrackID);
    if BuildingEntityType == Entities.B_CattlePasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    elseif BuildingEntityType == Entities.B_SheepPasture then
        GUI.SetStoppedState(_BarrackID, not Logic.IsBuildingStopped(_BarrackID));
    end
end

function ModuleLifestockBreeding.Local:OverrideHouseMenuProductionButton()
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
end

function ModuleLifestockBreeding.Local:InitBuyCattleButton()
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
end

function ModuleLifestockBreeding.Local:InitBuySheepButton()
    local Position = {XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart")};
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

Revision:RegisterModule(ModuleLifestockBreeding);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Aufzucht von Schafe und Kühe durch den Spieler.
-- 
-- Verschiedene Kenngrößen können angepasst werden.
--
-- Es wird ein Button an Kuh- und Schafställe angebracht. Damit kann die
-- Zucht individuell angehalten oder fortgesetzt werden. Dieser Button
-- belegt einen der 6 möglichen zusätzlichen Buttons bei den Ställen.
--
-- Wird im Produktionsmenü die Produktion von Kuh- oder Schaffarmen gestoppt,
-- werden jeweils alle Kuh- oder Schafställe ebenfalls gestoppt. Wird die
-- Produktion fortgeführt, wird auch die Zucht fortgeführt.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Ankeigekontrolle</a></li>
-- <li><a href="modules.QSB_2_BuildingUI.QSB_2_BuildingUI.html">(1) Gebäudeschalter</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field AnimalBreed Ein Nutztier wurde erzeugt. (Parameter: PlayerID, EntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erlaube oder verbiete dem Spieler Kühe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- @param[type=boolean] _Flag Kuhzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Es können keine Kühe gezüchtet werden
-- API.UseBreedCattle(false);
--
function API.ActivateCattleBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Sheep.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Sheep.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Sheep];
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Sheep.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Sheep] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Sheep] = " ..Price);
    end
end

---
-- Erlaube oder verbiete dem Spieler Schafe zu züchten.
--
-- Die Zucht wird immer synchron für alle Spieler erlaubt oder verboten.
--
-- @param[type=boolean] _Flag Schafzucht aktiv/inaktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Schafsaufzucht ist erlaubt
-- API.UseBreedSheeps(true);
--
function API.ActivateSheepBreeding(_Flag)
    if GUI then
        return;
    end

    ModuleLifestockBreeding.Global.Cattle.Breeding = _Flag == true;
    Logic.ExecuteInLuaLocalState("ModuleLifestockBreeding.Local.Cattle.Breeding = " ..tostring(_Flag == true));
    if _Flag ~= true then
        local Price = MerchantSystem.BasePricesOrigModuleLifestockBreeding[Goods.G_Cow];
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    else
        local Price = ModuleLifestockBreeding.Global.Cattle.MoneyCost;
        MerchantSystem.BasePrices[Goods.G_Cow] = Price;
        Logic.ExecuteInLuaLocalState("MerchantSystem.BasePrices[Goods.G_Cow] = " ..Price);
    end
end

---
-- Konfiguriert die Zucht von Kühen.
--
-- Die Konfiguration erfolgt immer synchron für alle Spieler.
--
-- Mögliche Optionen:
-- <table border="1">
-- <tr>
-- <td><b>Option</b></td>
-- <td><b>Datentyp</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>RequiredAmount</td>
-- <td>number</td>
-- <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
-- (Default: 2)</td>
-- </tr>
-- <tr>
-- <td>QuantityBoost</td>
-- <td>number</td>
-- <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
-- (Default: 9)</td>
-- </tr>
-- <tr>
-- <td>AreaSize</td>
-- <td>number</td>
-- <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
-- (Default: 4500)</td>
-- </tr>
-- <tr>
-- <td>UseCalves</td>
-- <td>boolean</td>
-- <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
-- kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
-- </tr>
-- <tr>
-- <td>CalvesSize</td>
-- <td>number</td>
-- <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
-- diese Option ignoriert. (Default: 0.45)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
-- jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
-- Gebäude nicht pausiert ist. (Default: 25)</td>
-- </tr>
-- <tr>
-- <td>BreedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
-- eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
-- zurückgesetzt. (Default: 150)</td>
-- </tr>
-- <tr>
-- <td>GrothTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
-- Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureCattleBreeding{
--     -- Es werden keine Tiere benötigt
--     RequiredAmount = 0,
--     -- Mindestzeit sind 3 Minuten
--     BreedingTimer = 3*60
-- }
--
function API.ConfigureCattleBreeding(_Data)
    if _Data.CalvesSize ~= nil then
        ModuleLifestockBreeding.Global.Cattle.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount ~= nil then
        ModuleLifestockBreeding.Global.Cattle.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost ~= nil then
        ModuleLifestockBreeding.Global.Cattle.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize ~= nil then
        ModuleLifestockBreeding.Global.Cattle.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves ~= nil then
        ModuleLifestockBreeding.Global.Cattle.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.GrothTimer = _Data.GrothTimer;
    end
end

---
-- Konfiguriert die Zucht von Schafen.
--
-- Die Konfiguration erfolgt immer synchron für alle Spieler.
--
-- Mögliche Optionen:
-- <table border="1">
-- <tr>
-- <td><b>Option</b></td>
-- <td><b>Datentyp</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>RequiredAmount</td>
-- <td>number</td>
-- <td>Mindestanzahl an Tieren, die sich im Gebiet befinden müssen.
-- (Default: 2)</td>
-- </tr>
-- <tr>
-- <td>QuantityBoost</td>
-- <td>number</td>
-- <td>Menge an Sekunden, die jedes Tier im Gebiet die Zuchtauer verkürzt.
-- (Default: 9)</td>
-- </tr>
-- <tr>
-- <td>AreaSize</td>
-- <td>number</td>
-- <td>Größe des Gebietes, in dem Tiere für die Zucht vorhanden sein müssen.
-- (Default: 4500)</td>
-- </tr>
-- <tr>
-- <td>UseCalves</td>
-- <td>boolean</td>
-- <td>Gezüchtete Tiere erscheinen zuerst als Kälber und wachsen. Dies ist rein
-- kosmetisch und hat keinen Einfluss auf die Produktion. (Default: true)</td>
-- </tr>
-- <tr>
-- <td>CalvesSize</td>
-- <td>number</td>
-- <td>Bestimmt die initiale Größe der Kälber. Werden Kälber nicht benutzt, wird
-- diese Option ignoriert. (Default: 0.45)</td>
-- </tr>
-- <tr>
-- <td>FeedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Fütterungsperioden. Am Ende
-- jeder Periode wird pro züchtendem Gatter 1 Getreide abgezogen, wenn das
-- Gebäude nicht pausiert ist. (Default: 30)</td>
-- </tr>
-- <tr>
-- <td>BreedingTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden, bis ein neues Tier erscheint. Wenn für
-- eine Fütterung kein Getreide da ist, wird der Zähler zur letzten Fütterung
-- zurückgesetzt. (Default: 120)</td>
-- </tr>
-- <tr>
-- <td>GrothTimer</td>
-- <td>number</td>
-- <td>Bestimmt die Zeit in Sekunden zwischen den Wachstumsschüben eines
-- Kalbs. Jeder Wachstumsschub ist +0.05 Gößenänderung. (Default: 15)</td>
-- </tr>
-- </table>
-- 
-- @param[type=table] _Data Konfiguration der Zucht
-- @within Anwenderfunktionen
--
-- @usage
-- API.ConfigureSheepBreeding{
--     -- Es werden keine Tiere benötigt
--     RequiredAmount = 0,
--     -- Mindestzeit sind 3 Minuten
--     BreedingTimer = 3*60
-- }
--
function API.ConfigureSheepBreeding(_Data)
    if _Data.CalvesSize ~= nil then
        ModuleLifestockBreeding.Global.Sheep.CalvesSize = _Data.CalvesSize;
    end
    if _Data.RequiredAmount ~= nil then
        ModuleLifestockBreeding.Global.Sheep.RequiredAmount = _Data.RequiredAmount;
    end
    if _Data.QuantityBoost ~= nil then
        ModuleLifestockBreeding.Global.Sheep.QuantityBoost = _Data.QuantityBoost;
    end
    if _Data.AreaSize ~= nil then
        ModuleLifestockBreeding.Global.Sheep.AreaSize = _Data.AreaSize;
    end
    if _Data.UseCalves ~= nil then
        ModuleLifestockBreeding.Global.Sheep.UseCalves = _Data.UseCalves;
    end
    if _Data.FeedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Sheep.FeedingTimer = _Data.FeedingTimer;
    end
    if _Data.BreedingTimer ~= nil then
        ModuleLifestockBreeding.Global.Cattle.BreedingTimer = _Data.BreedingTimer;
    end
    if _Data.GrothTimer ~= nil then
        ModuleLifestockBreeding.Global.Sheep.GrothTimer = _Data.GrothTimer;
    end
end

