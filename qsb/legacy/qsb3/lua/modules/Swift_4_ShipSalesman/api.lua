--[[
Swift_4_ShipSalesment/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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
-- Änderungen des Diplomatiestatus mehr mit sich, wie zuvor üblich. Des weiteren
-- wird keine automatische Nachricht mehr versendet, wenn ein Schiff im Hafen
-- anlegt oder diesen wieder verlässt. Bei vielen Handelsrouten würde sonst der
-- Spieler in Nachrichten ersticken.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- <li><a href="Swift_1_TradingCore.api.html">(1) TradingCore</a></li>
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

