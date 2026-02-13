-- -------------------------------------------------------------------------- --

ModuleShipSalesment = {
    Properties = {
        Name = "ModuleShipSalesment",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Harbors = {},
        LoudTrader = true,
    },
    Local = {},
    Shared = {},
};

QSB.ShipTraderState = {
    Waiting = 1,
    MovingIn = 2,
    Anchored = 3,
    MovingOut = 4,
}

-- Global ------------------------------------------------------------------- --

function ModuleShipSalesment.Global:OnGameStart()
    QSB.ScriptEvents.TradeShipSpawned = API.RegisterScriptEvent("Event_TradeShipSpawned");
    QSB.ScriptEvents.TradeShipArrived = API.RegisterScriptEvent("Event_TradeShipArrived");
    QSB.ScriptEvents.TradeShipLeft = API.RegisterScriptEvent("Event_TradeShipLeft");
    QSB.ScriptEvents.TradeShipDespawned = API.RegisterScriptEvent("Event_TradeShipDespawned");

    API.StartJob(function()
        ModuleShipSalesment.Global:ControlHarbors();
    end);
end

function ModuleShipSalesment.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.TradeShipSpawned then
        self:OnTravelingSalesmanShipSpawned(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.TradeShipArrived then
        self:OnTravelingSalesmanShipArrived(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.TradeShipLeft then
        self:OnTravelingSalesmanShipLeft(arg[1], arg[2], arg[3]);
    end
end

function ModuleShipSalesment.Global:CreateHarbor(_PlayerID, _IsRetro)
    if self.Harbors[_PlayerID] then
        self:DisposeHarbor(_PlayerID);
    end
    self.Harbors[_PlayerID] = {
        IsRetro = _IsRetro == true,
        AddedOffers  = {},
        Routes = {}
    };
end

function ModuleShipSalesment.Global:DisposeHarbor(_PlayerID)
    local StoreHouseID = Logic.GetStoreHouse(_PlayerID)
    for k, v in pairs(self.Harbors[_PlayerID].Routes) do
        self:PurgeTradeRoute(_PlayerID, v.Name);
    end
    if IsExisting(StoreHouseID) then
        Logic.RemoveAllOffers(StoreHouseID);
    end
end

function ModuleShipSalesment.Global:IsRetroHarbor(_PlayerID)
    if self.Harbors[_PlayerID] then
        return self.Harbors[_PlayerID].IsRetro == true;
    end
    return false;
end

function ModuleShipSalesment.Global:IsSendingMessage(_PlayerID)
    if  self.Harbors[_PlayerID]
    and self.Harbors[_PlayerID].Routes[1]
    and self.Harbors[_PlayerID].Routes[1].Message then
        return true;
    end
    return false;
end

function ModuleShipSalesment.Global:CountTradeRoutes(_PlayerID)
    if self.Harbors[_PlayerID] then
        return #self.Harbors[_PlayerID].Routes;
    end
    return false;
end

function ModuleShipSalesment.Global:AddTradeRoute(_PlayerID, _Data)
    if not self.Harbors[_PlayerID] then
        return;
    end
    for i= #self.Harbors[_PlayerID].Routes, 1, -1 do
        if self.Harbors[_PlayerID].Routes[i].Name == _Data.Name then
            return;
        end
    end
    _Data.Interval = _Data.Interval or 300;
    _Data.Duration = _Data.Duration or 120;
    _Data.Timer = _Data.Interval -1;
    _Data.State = QSB.ShipTraderState.Waiting;
    table.insert(self.Harbors[_PlayerID].Routes, _Data);
end

function ModuleShipSalesment.Global:AlterTradeRouteOffers(_PlayerID, _Name, _Offers)
    if not self.Harbors[_PlayerID] then
        return;
    end
    for i= #self.Harbors[_PlayerID].Routes, 1, -1 do
        if self.Harbors[_PlayerID].Routes[i].Name == _Name then
            _Offers.Message = self.Harbors[_PlayerID].Routes[i].Message == true;
            self.Harbors[_PlayerID].Routes[i].Offers = _Offers;
            return;
        end
    end
end

function ModuleShipSalesment.Global:PurgeAllTradeRoutes(_PlayerID)
    if not self.Harbors[_PlayerID] then
        return;
    end
    for i= #self.Harbors[_PlayerID].Routes, 1, -1 do
        local Data = table.remove(self.Harbors[_PlayerID].Routes, i);
        if IsExisting(Data.ShipID) then
            DestroyEntity(Data.ShipID);
        end
        if JobIsRunning(Data.ShipID) then
            EndJob(Data.ShipJob);
        end
    end
end

function ModuleShipSalesment.Global:PurgeTradeRoute(_PlayerID, _Name)
    if not self.Harbors[_PlayerID] then
        return;
    end
    for i= #self.Harbors[_PlayerID].Routes, 1, -1 do
        if self.Harbors[_PlayerID].Routes[i].Name == _Name then
            local Data = table.remove(self.Harbors[_PlayerID].Routes, i);
            if IsExisting(Data.ShipID) then
                DestroyEntity(Data.ShipID);
            end
            if JobIsRunning(Data.ShipID) then
                EndJob(Data.ShipJob);
            end
            break;
        end
    end
end

function ModuleShipSalesment.Global:ShutdownTradeRoute(_PlayerID, _Name)
    if not self.Harbors[_PlayerID] then
        return;
    end
    for i= #self.Harbors[_PlayerID].Routes, 1, -1 do
        if self.Harbors[_PlayerID].Routes[i].Name == _Name then
            return API.StartJob(function (_PlayerID, _Index)
                if self.Harbors[_PlayerID].Routes[_Index].State == QSB.ShipTraderState.Waiting then
                    local Name = self.Harbors[_PlayerID].Routes[_Index].Name;
                    ModuleShipSalesment.Global:PurgeTradeRoute(_PlayerID, Name);
                    return true;
                end
            end, _PlayerID, i);
        end
    end
    return 0;
end

function ModuleShipSalesment.Global:SpawnShip(_PlayerID, _Index)
    local Route = self.Harbors[_PlayerID].Routes[_Index];
    local SpawnPointID = GetID(Route.Path[1]);
    local x, y, z = Logic.EntityGetPos(SpawnPointID);
    local Orientation = Logic.GetEntityOrientation(SpawnPointID);
    local ID = Logic.CreateEntity(Entities.D_X_TradeShip, x, y, Orientation, 0);
    self.Harbors[_PlayerID].Routes[_Index].ShipID = ID;
    self:SendShipSpawnedEvent(_PlayerID, Route, ID);
    Logic.SetSpeedFactor(ID, 3.0);
    return ID;
end

function ModuleShipSalesment.Global:DespawnShip(_PlayerID, _Index)
    local ID = self.Harbors[_PlayerID].Routes[_Index].ShipID;
    local Route = self.Harbors[_PlayerID].Routes[_Index];
    self:SendShipDespawnedEvent(_PlayerID, Route, ID);
    DestroyEntity(ID);
end

function ModuleShipSalesment.Global:MoveShipIn(_PlayerID, _Index)
    local Route = self.Harbors[_PlayerID].Routes[_Index];
    local ID = self.Harbors[_PlayerID].Routes[_Index].ShipID;
    local Waypoints = {};
    for i= 1, #Route.Path do
        table.insert(Waypoints, GetID(Route.Path[i]));
    end
    local Instance = Path:new(ID, Waypoints, nil, nil, nil, nil, true, nil, nil, 300);
    self.Harbors[_PlayerID].Routes[_Index].ShipJob = Instance.Job;
    return ID;
end

function ModuleShipSalesment.Global:MoveShipOut(_PlayerID, _Index)
    local Route = self.Harbors[_PlayerID].Routes[_Index];
    local ID = self.Harbors[_PlayerID].Routes[_Index].ShipID;
    local Waypoints = {};
    for i= 1, #Route.Path do
        table.insert(Waypoints, GetID(Route.Path[i]));
    end
    local Instance = Path:new(ID, table.invert(Waypoints), nil, nil, nil, nil, true, nil, nil, 300);
    self.Harbors[_PlayerID].Routes[_Index].ShipJob = Instance.Job;
    return ID;
end

function ModuleShipSalesment.Global:SendShipSpawnedEvent(_PlayerID, _Route, _ShipID)
    API.SendScriptEvent(QSB.ScriptEvents.TradeShipSpawned, _PlayerID, _Route.Name, _ShipID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipSpawned, %d, "%s", %d)]],
        _PlayerID,
        _Route.Name,
        _ShipID
    ));
end

function ModuleShipSalesment.Global:SendShipDespawnedEvent(_PlayerID, _Route, _ShipID)
    API.SendScriptEvent(QSB.ScriptEvents.TradeShipDespawned, _PlayerID, _Route.Name, _ShipID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipDespawned, %d, "%s", %d)]],
        _PlayerID,
        _Route.Name,
        _ShipID
    ));
end

function ModuleShipSalesment.Global:SendShipArrivedEvent(_PlayerID, _Route, _ShipID)
    API.SendScriptEvent(QSB.ScriptEvents.TradeShipArrived, _PlayerID, _Route.Name, _ShipID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipArrived, %d, "%s", %d)]],
        _PlayerID,
        _Route.Name,
        _ShipID
    ));
end

function ModuleShipSalesment.Global:SendShipLeftEvent(_PlayerID, _Route, _ShipID)
    API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, _PlayerID, _Route.Name, _ShipID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TradeShipLeft, %d, "%s", %d)]],
        _PlayerID,
        _Route.Name,
        _ShipID
    ));
end

function ModuleShipSalesment.Global:AddTradeOffers(_PlayerID, _Index)
    local Harbor = self.Harbors[_PlayerID];
    local Route = Harbor.Routes[_Index];

    -- select offers
    local Offers = {};
    if Route.Amount == #Route.Offers then
        Offers = table.copy(Route.Offers);
    else
        local Indices = {};
        while (#Indices < Route.Amount) do
            local Index = math.random(1, #Route.Offers);
            if not table.contains(Indices, Index) then
                table.insert(Indices, Index);
            end
        end
        for i= 1, #Indices do
            table.insert(Offers, table.copy(Route.Offers[Indices[i]]));
        end
    end

    -- add selected offers
    local StoreData;
    for i= 1, #Offers do
        -- set offer type
        local IsGoodType = true;
        local IsMilitary = false;
        local OfferType = Goods[Offers[i][1]];
        if not OfferType then
            IsGoodType = false;
            OfferType = Entities[Offers[i][1]];
            if Logic.IsEntityTypeInCategory(Entities[Offers[i][1]], EntityCategories.Military) == 1 then
                IsMilitary = true;
            end
        end
        -- remove oldest offer if needed
        StoreData = API.GetOfferInformation(_PlayerID);
        if  not self:IsRetroHarbor(_PlayerID)
        and StoreData.OfferCount >= 4 then
            local LastOffer = table.remove(self.Harbors[_PlayerID].AddedOffers, 1);
            API.RemoveTradeOffer(_PlayerID, LastOffer);
        end
        StoreData = API.GetOfferInformation(_PlayerID);
        -- add new offer
        API.RemoveTradeOffer(_PlayerID, OfferType);
        if IsGoodType then
            AddOffer(StoreData.Storehouse, Offers[i][2], OfferType, 9999);
        else
            if not IsMilitary then
                AddEntertainerOffer(StoreData.Storehouse, OfferType);
            else
                AddMercenaryOffer(StoreData.Storehouse, Offers[i][2], OfferType, 9999);
            end
        end
        table.insert(self.Harbors[_PlayerID].AddedOffers, OfferType);
        StoreData = ModuleTrade.Global:GetStorehouseInformation(_PlayerID);
    end

    -- update visuals
    Logic.ExecuteInLuaLocalState(string.format(
        [[GameCallback_CloseNPCInteraction(GUI.GetPlayerID(), %d)]],
        StoreData.Storehouse
    ));
end

function ModuleShipSalesment.Global:RemoveTradeOffers(_PlayerID, _Index)
    if self:IsRetroHarbor(_PlayerID) then
        local StoreHouseID = Logic.GetStoreHouse(_PlayerID)
        Logic.RemoveAllOffers(StoreHouseID);
    end
end

function ModuleShipSalesment.Global:ControlHarbors()
    for k,v in pairs(self.Harbors) do
        if Logic.GetStoreHouse(k) == 0 then
            self:DisposeHarbor(k);
        else
            if #v.Routes > 0 then
                -- remove sold out offers
                local StoreData = ModuleTrade.Global:GetStorehouseInformation(k);
                for i= 1, #StoreData[1] do
                    if StoreData[1][i][5] == 0 then
                        ModuleTrade.Global:RemoveTradeOfferByData(StoreData, i);
                        for j= #v.AddedOffers, 1, -1 do
                            if v.AddedOffers[j] == StoreData[1][i][3] then
                                table.remove(self.Harbors[k].AddedOffers, j);
                            end
                        end
                    end
                end

                -- control trade routes
                for i= 1, #v.Routes do
                    if v.Routes[i].State == QSB.ShipTraderState.Waiting then
                        self.Harbors[k].Routes[i].Timer = v.Routes[i].Timer +1;
                        if v.Routes[i].Timer >= v.Routes[i].Interval then
                            self.Harbors[k].Routes[i].State = QSB.ShipTraderState.MovingIn;
                            self.Harbors[k].Routes[i].Timer = 0;
                            self:SpawnShip(k, i);
                            self:MoveShipIn(k, i);
                        end

                    elseif v.Routes[i].State == QSB.ShipTraderState.MovingIn then
                        local AnchorPoint = v.Routes[i].Path[#v.Routes[i].Path];
                        local ShipID = v.Routes[i].ShipID;
                        if IsNear(ShipID, AnchorPoint, 300) then
                            self.Harbors[k].Routes[i].State = QSB.ShipTraderState.Anchored;
                            self:SendShipArrivedEvent(k, v.Routes[i], ShipID);
                            self:AddTradeOffers(k, i);
                        end

                    elseif v.Routes[i].State == QSB.ShipTraderState.Anchored then
                        local ShipID = v.Routes[i].ShipID;
                        self.Harbors[k].Routes[i].Timer = v.Routes[i].Timer +1;
                        if v.Routes[i].Timer >= v.Routes[i].Duration then
                            self.Harbors[k].Routes[i].State = QSB.ShipTraderState.MovingOut;
                            self.Harbors[k].Routes[i].Timer = 0;
                            self:SendShipLeftEvent(k, v.Routes[i], ShipID);
                            self:RemoveTradeOffers(k, i);
                            self:MoveShipOut(k, i);
                        end

                    elseif v.Routes[i].State == QSB.ShipTraderState.MovingOut then
                        local SpawnPoint = v.Routes[i].Path[1];
                        local ShipID = v.Routes[i].ShipID;
                        if IsNear(ShipID, SpawnPoint, 300) then
                            self.Harbors[k].Routes[i].State = QSB.ShipTraderState.Waiting;
                            self:DespawnShip(k, i);
                        end
                    end
                end
            end
        end
    end
end

function ModuleShipSalesment.Global:OnTravelingSalesmanInitalized(_PlayerID)
    if self:IsRetroHarbor(_PlayerID) then
        -- Change diplomacy
        for PlayerID = 1, 8 do
            if _PlayerID ~= PlayerID and Logic.PlayerGetIsHumanFlag(PlayerID) then
                SetDiplomacyState(PlayerID, _PlayerID, 0);
            end
        end
    end
end

function ModuleShipSalesment.Global:OnTravelingSalesmanShipSpawned(_PlayerID, _RouteName, _ShipID)
    if self:IsRetroHarbor(_PlayerID) then
        -- Send "voice" message
        if self:IsSendingMessage(_PlayerID) then
            Logic.ExecuteInLuaLocalState("LocalScriptCallback_QueueVoiceMessage(".. _PlayerID ..", 'TravelingSalesmanSpotted')");
        end
    end
end

function ModuleShipSalesment.Global:OnTravelingSalesmanShipArrived(_PlayerID, _RouteName, _ShipID)
    if self:IsRetroHarbor(_PlayerID) then
        -- Send "voice" message
        if self:IsSendingMessage(_PlayerID) then
            Logic.ExecuteInLuaLocalState("LocalScriptCallback_QueueVoiceMessage(".. _PlayerID ..", 'TravelingSalesman')");
        end
        -- Change diplomacy
        for PlayerID = 1, 8 do
            if _PlayerID ~= PlayerID and Logic.PlayerGetIsHumanFlag(PlayerID) then
                SetDiplomacyState(PlayerID, _PlayerID, 1);
            end
        end
    end
end

function ModuleShipSalesment.Global:OnTravelingSalesmanShipLeft(_PlayerID, _RouteName, _ShipID)
    if self:IsRetroHarbor(_PlayerID) then
        -- Send "voice" message
        if self:IsSendingMessage(_PlayerID) then
            Logic.ExecuteInLuaLocalState("LocalScriptCallback_QueueVoiceMessage(".. _PlayerID ..", 'TravelingSalesman_Failure')");
        end
        -- Change diplomacy
        for PlayerID = 1, 8 do
            if _PlayerID ~= PlayerID and Logic.PlayerGetIsHumanFlag(PlayerID) then
                SetDiplomacyState(PlayerID, _PlayerID, 0);
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleShipSalesment.Local:OnGameStart()
    QSB.ScriptEvents.TradeShipSpawned = API.RegisterScriptEvent("Event_TradeShipSpawned");
    QSB.ScriptEvents.TradeShipArrived = API.RegisterScriptEvent("Event_TradeShipArrived");
    QSB.ScriptEvents.TradeShipLeft = API.RegisterScriptEvent("Event_TradeShipLeft");
    QSB.ScriptEvents.TradeShipDespawned = API.RegisterScriptEvent("Event_TradeShipDespawned");
end

function ModuleShipSalesment.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleShipSalesment);

