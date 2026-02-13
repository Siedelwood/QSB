
---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf es nur genauso viele Angebote
-- geben, wie als Maximum gesetzt wird.
--
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <b>Alias</b>: TravelingSalesmanActivate
--
-- @param[type=table]  _Description Definition des Händlers
-- @within QSB_3_TradeRoutes
--
-- @usage local TraderDescription = {
--     PlayerID   = 2,                   -- Partei des Hafen
--     Path       = {"SH2WP1","SH2WP2"}, -- Pfad zum Hafen
--     Duration   = 150,                 -- Ankerzeit in Sekunden (Standard: 360)
--     Interval   = 3,                   -- Monate zwischen zwei Anfarten (Standard: 2)
--     Amount     = 4,                   -- Anzahl Angebote (1 bis 4) (Standard: 4)
--     Message    = true,                -- Händler teilt Status des Schiffs mit
--     Offers = { 
--         -- Angebot, Menge
--         {"G_Gems", 5},
--         {"G_Iron", 5},
--         {"G_Beer", 2},
--         {"G_Stone", 5},
--         {"G_Sheep", 1},
--         {"G_Cheese", 2},
--         {"G_Milk", 5},
--         {"G_Grain", 5},
--         {"G_Broom", 2},
--         {"U_CatapultCart", 1},
--         {"U_MilitarySword", 3},
--         {"U_MilitaryBow", 3}
--     },
-- };
-- API.TravelingSalesmanCreate(TraderDescription);
--
function API.TravelingSalesmanCreate(_Data)
    if GUI then
        return;
    end
    if type(_Data) ~= "table" then
        error("API.TravelingSalesmanCreate: _Data must be a table!");
        return;
    end
    local PlayerID = _Data.PlayerID;
    _Data.PlayerID = nil;
    _Data.Duration = _Data.Duration or (6 * 60);
    _Data.Interval = (_Data.Interval or 2) * 60;
    _Data.Amount = _Data.Amount or 4;
    _Data.Message = _Data.Message == true;

    if type(_Data.Path) ~= "table" then
        error("API.TravelingSalesmanCreate: _Data.Path is not valid!");
        return;
    end
    if Logic.GetStoreHouse(PlayerID) == 0 then
        error("API.TravelingSalesmanCreate: Player " ..PlayerID.. " is dead! :(");
        return;
    end
    ModuleShipSalesment.Global:CreateHarbor(PlayerID, true);
    _Data.Name = "Player" ..PlayerID.. "_Route";
    API.AddTradeRoute(PlayerID, _Data);
    ModuleShipSalesment.Global:OnTravelingSalesmanInitalized(PlayerID);
end
TravelingSalesmanCreate = API.TravelingSalesmanCreate;

---
-- Entfernt den fahrenden Händler vom Lagerhaus des Spielers.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
-- @usage
-- API.TravelingSalesmanDelete(2);
--
function API.TravelingSalesmanDelete(_PlayerID)
    if not ModuleShipSalesment.Global:IsRetroHarbor(_PlayerID) then
        error("API.TravelingSalesmanDelete: Not a traveling salesman!")
        return;
    end
    if Logic.GetStoreHouse(_PlayerID) == 0 then
        error("API.TravelingSalesmanDelete: player " .._PlayerID.. " is dead! :(");
        return;
    end
    ModuleShipSalesment.Global:DisposeHarbor(_PlayerID);
end

---
-- Andert das Warenangebot eines fliegenden Händlers.
--
-- @param[type=number] _PlayerID    ID des Spielers
-- @param[type=table]  _RouteOffers Daten der Handelsroute
-- @within Anwenderfunktionen
--
-- @usage
-- API.ChangeTravelingSalesmanGoods(
--     2,
--     {{"G_Wool", 3},
--      {"U_CatapultCart", 5},
--      {"G_Beer", 2},
--      {"G_Herb", 3},
--      {"U_Entertainer_NA_StiltWalker", 1}}
-- );
--
function API.ChangeTravelingSalesmanGoods(_PlayerID, _RouteOffers)
    if not ModuleShipSalesment.Global:IsRetroHarbor(_PlayerID) then
        error("API.ChangeTravelingSalesmanGoods: Not a traveling salesman!")
        return;
    end
    API.ChangeTradeRouteGoods(_PlayerID, "Player" .._PlayerID.. "_Route", _RouteOffers);
end

