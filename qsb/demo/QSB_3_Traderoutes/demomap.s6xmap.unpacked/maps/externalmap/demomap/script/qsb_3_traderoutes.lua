--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleShipSalesment = {
    Properties = {
        Name = "ModuleShipSalesment",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        Harbors = {},
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
    end
end

function ModuleShipSalesment.Global:CreateHarbor(_PlayerID)
    if self.Harbors[_PlayerID] then
        self:DisposeHarbor(_PlayerID);
    end
    self.Harbors[_PlayerID] = {
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
        StoreData = ModuleTrade.Global:GetStorehouseInformation(_PlayerID);
        if StoreData.OfferCount >= 4 then
            local LastOffer = table.remove(self.Harbors[_PlayerID].AddedOffers, 1);
            API.RemoveTradeOffer(_PlayerID, LastOffer);
            StoreData = ModuleTrade.Global:GetStorehouseInformation(_PlayerID);
        end
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

Revision:RegisterModule(ModuleShipSalesment);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht einen KI-Spieler als Hafen einzurichten.
--
-- <h5>Was ein Hafen macht</h5>
-- Häfen werden zyklisch von Schiffen über Handelsrouten angesteuert. Ein Hafen
-- kann prinzipiell ungebegrenzt viele Handelsrouten haben. Wenn ein Schiff im
-- Hafen anlegt, werden die Waren den Angeboten hinzugefügt. Ist kein Platz
-- mehr für ein weiteres Angebot, wird das jeweils älteste entfernt.
--
-- Die Angebote in einem Hafen werden nicht erneuert. Wenn alle Einheiten eines
-- Angebotes gekauft wurden, wird das Angebot automatisch entfernt.
--
-- Handelsschiffe einer Handelsroute haben einen Geschwindigkeitsbonus erhalten,
-- damit man bei langen Wegen nicht ewig auf die Ankunft warten muss.
--
-- Sollte ein KI-Spieler, welcher als Hafen eingerichtet ist, vernichtet werden,
-- werden automatisch alle aktiven Routen gelöscht. Schiffe, welche sich auf
-- dem Weg vom oder zum Hafen befinden, verschwinden ebenfalls.
--
-- <h5>Was ein Hafen NICHT macht</h5>
-- Die Einrichtung eines KI-Spielers als Hafen bringt keine automatischen
-- Änderungen des Diplomatiestatus mit sich. Des weiteren wird keine Nachricht
-- versendet, wenn ein Schiff im Hafen anlegt oder diesen wieder verlässt. Bei
-- vielen Handelsrouten würde sonst der Spieler in Nachrichten ersticken.
-- 
-- <p><b>Vorausgesetzte Module:</b></p>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_Trade.QSB_1_Trade.html">(1) Handelserweiterung</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field TradeShipSpawned   Ein Schiff wurde erzeugt (Parameter: _PlayerID, _RouteName, _ShipID)
-- @field TradeShipArrived   Ein Schiff hat den Hafen erreicht (Parameter: _PlayerID, _RouteName, _ShipID)
-- @field TradeShipLeft      Ein Schiff hat den Hafen verlassen (Parameter: _PlayerID, _RouteName, _ShipID)
-- @field TradeShipDespawned Ein Schiff wurde gelöscht (Parameter: _PlayerID, _RouteName, _ShipID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Fügt einen Schiffshändler im Lagerhaus des Spielers hinzu.
--
-- Optional kann eine Liste von Handelsrouten übergeben werden.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=table] ...        Liste an Handelsrouten
-- @see API.AddTradeRoute
--
-- @usage
-- API.InitHarbor(2);
--
function API.InitHarbor(_PlayerID, ...)
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.InitHarbor: player " .._PlayerID.. " is dead! :(");
        return;
    end
    ModuleShipSalesment.Global:CreateHarbor(_PlayerID);
    for i= 1, #arg do
        API.AddTradeRoute(_PlayerID, arg[i]);
    end
end

---
-- Entfernt den Schiffshändler vom Lagerhaus des Spielers.
--
-- <b>Hinweis</b>: Die Routen werden sofort gelöscht. Schiffe, die sich mitten
-- in ihrem Zyklus befinden, werden ebenfalls gelöscht und alle aktiven Angebote
-- im Lagerhaus des KI-Spielers werden sofort entfernt. Nutze dies, wenn z.B.
-- der KI-Spieler feindlich wird.
--
-- @param[type=number] _PlayerID ID des Spielers
--
-- @usage
-- API.DisposeHarbor(2);
--
function API.DisposeHarbor(_PlayerID)
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.AddTradeRoute: player " .._PlayerID.. " is dead! :(");
        return;
    end
    ModuleShipSalesment.Global:DisposeHarbor(_PlayerID);
end

---
-- Fügt eine Handelsroute zu einem Hafen hinzu.
--
-- Für jede Handelsroute eines Hafens erscheint ein Handelsschiff, das den Hafen
-- zyklisch mit neuen Waren versorgt.
--
-- Eine Handelsroute hat folgende Felder:
-- <table border="1">
-- <tr>
-- <td><b>Feld</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>string</td>
-- <td>Name der Handelsroute (Muss für die Partei eindeutig sein)</td>
-- </tr>
-- <tr>
-- <td>Path</td>
-- <td>table</td>
-- <td>Liste der Wegpunkte des Handelsschiffs (mindestens 2)</td>
-- </tr>
-- <tr>
-- <td>Offers</td>
-- <td>table</td>
-- <td>Liste mit Angeboten (Format: {_Angebot, _Menge})</td>
-- </tr>
-- <tr>
-- <td>Amount</td>
-- <td>number</td>
-- <td>(Optional) Menge an ausgewählten Angeboten.</td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>number</td>
-- <td>(Option) Verweildauer im Hafen in Sekunden</td>
-- </tr>
-- <tr>
-- <td>Interval</td>
-- <td>number</td>
-- <td>(Optional) Zeit bis zur Widerkehr in Sekunden</td>
-- </tr>
-- <tr>
-- <td></td>
-- <td></td>
-- <td></td>
-- </tr>
-- </table>
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=table]  _Route    Daten der Handelsroute
-- @see API.InitHarbor
-- @see API.ChangeTradeRouteGoods
-- @see API.RemoveTradeRoute
--
-- @usage
-- API.AddTradeRoute(
--     2,
--     {
--         Name       = "Route3",
--         -- Wegpunkte - Der letzte sollte beim Hafen sein ;)
--         Path       = {"Spawn3", "Arrived3"},
--         -- Schiff kommt alle 10 Minuten
--         Interval   = 10*60,
--         -- Schiff bleibt 2 Minunten im Hafen
--         Duration   = 2*60,
--         -- Menge pro Anfahrt
--         Amount     = 2,
--         -- Liste an Angeboten
--         Offers     = {
--             {"G_Wool", 5},
--             {"U_CatapultCart", 1},
--             {"G_Beer", 2},
--             {"G_Herb", 5},
--             {"U_Entertainer_NA_StiltWalker", 1},
--         }
--     }
-- );
--
function API.AddTradeRoute(_PlayerID, _Route)
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.AddTradeRoute: player " .._PlayerID.. " is dead! :(");
        return;
    end
    if type(_Route) ~= "table" then
        error("API.AddTradeRoute: _Route must be a table!");
        return;
    end
    if not _Route.Name then
        error("API.AddTradeRoute: trade route needs a name!");
        return;
    end
    if not _Route.Path or #_Route.Path < 2 then
        error("API.AddTradeRoute: path of route " .._Route.Name.. " is invalid!");
        return;
    end
    if not _Route.Offers or #_Route.Offers < 1 then
        error("API.AddTradeRoute: route " .._Route.Name.. " has to few offers!");
        return;
    end
    _Route.Amount = _Route.Amount or ((#_Route.Offers > 4 and 4) or #_Route.Offers);
    if _Route.Amount < 1 or _Route.Amount > 4 then
        error("API.AddTradeRoute: offer amount of route " .._Route.Name.. " is invalid!");
        return;
    end
    if _Route.Amount > #_Route.Offers then
        error("API.AddTradeRoute: route " .._Route.Name.. " has not enough offers!");
        return;
    end
    for i= 1, #_Route.Offers, 1 do
        if Goods[_Route.Offers[i][1]] == nil and Entities[_Route.Offers[i][1]] == nil then
            error("API.AddTradeRoute: Offers[" ..i.. "][1] is invalid good type!");
            return;
        end
        if type(_Route.Offers[i][2]) ~= "number" or _Route.Offers[i][2] < 1 then
            error("API.AddTradeRoute: Offers[" ..i.. "][2] amount must be at least 1!");
            return;
        end
    end
    ModuleShipSalesment.Global:AddTradeRoute(_PlayerID, _Route);
end

---
-- Andert das Warenangebot einer Handelsroute.
--
-- Es können nur bestehende Handelsrouten geändert werden. Die Änderung wird
-- erst im nächsten Zyklus wirksam.
--
-- @param[type=number] _PlayerID    ID des Spielers
-- @param[type=string] _RouteName   Daten der Handelsroute
-- @param[type=table]  _RouteOffers Daten der Handelsroute
-- @see API.InitHarbor
-- @see API.RemoveTradeRoute
-- @see API.AddTradeRoute
--
-- @usage
-- API.ChangeTradeRouteGoods(
--     2,
--     "Route3",
--     {{"G_Wool", 3},
--      {"U_CatapultCart", 5},
--      {"G_Beer", 2},
--      {"G_Herb", 3},
--      {"U_Entertainer_NA_StiltWalker", 1}}
-- );
--
function API.ChangeTradeRouteGoods(_PlayerID, _RouteName, _RouteOffers)
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.ChangeTradeRouteGoods: player " .._PlayerID.. " is dead! :(");
        return;
    end
    if type(_RouteOffers) ~= "table" and #_RouteOffers < 1 then
        error("API.ChangeTradeRouteGoods: _RouteOffers must be a table with entries!");
        return;
    end
    for i= 1, #_RouteOffers, 1 do
        if Goods[_RouteOffers[i][1]] == nil and Entities[_RouteOffers[i][1]] == nil then
            error("API.ChangeTradeRouteGoods: Offers[" ..i.. "][1] is invalid good type!");
            return;
        end
        if type(_RouteOffers[i][2]) ~= "number" or _RouteOffers[i][2] < 1 then
            error("API.ChangeTradeRouteGoods: Offers[" ..i.. "][2] amount must be at least 1!");
            return;
        end
    end
    ModuleShipSalesment.Global:AlterTradeRouteOffers(_PlayerID, _RouteName, _RouteOffers);
end

---
-- Löscht eine Handelsroute, wenn ihr Zyklus beendet ist.
--
-- Der Befehl erzeugt einen Job, welcher auf das Ende des Zyklus wartet und
-- erst dann die Route löscht. Über die ID kann der Job abgebrochen werden.
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=string] _RouteName Name der Route
-- @return[type=number] Job ID
-- @see API.InitHarbor
-- @see API.AddTradeRoute
-- @see API.ChangeTradeRouteGoods
--
-- @usage
-- API.RemoveTradeRoute(2, "Route1");
--
function API.RemoveTradeRoute(_PlayerID, _RouteName)
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.RemoveTradeRoute: player " .._PlayerID.. " is dead! :(");
        return 0;
    end
    return ModuleShipSalesment.Global:ShutdownTradeRoute(_PlayerID, _RouteName);
end

