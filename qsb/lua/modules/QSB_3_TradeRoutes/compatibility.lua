
---
-- Erstellt einen fahrender Händler mit zufälligen Angeboten.
--
-- Soll immer das selbe angeboten werden, darf es nur genauso viele Angebote
-- geben, wie als Maximum gesetzt wird.
--
-- Es kann mehr als einen fahrender Händler auf der Map geben.
--
-- <h5>Angebote</h5>
-- Es können Waren, Soldaten oder Entertainer angeboten werden. Aus allen
-- definierten Angeboten werden zufällig Angebote in der angegebenen Mange
-- ausgesucht und gesetzt.
--
-- <h5>Routen</h5>
-- Um die Route anzugeben, wird ein Name eingegeben. Es werden alle fortlaufend
-- nummerierte Punkte mit diesem Namen gesucht. Alternativ kann auch eine
-- Liste von Punkten angegeben werden. Es muss mindestens 2 Punkte geben.
--
-- <b>Alias</b>: TravelingSalesmanActivate
--
-- <b>QSB:</b> API.InitHarbor(_PlayerID, ...)
--
-- @param[type=table]  _Description Definition des Händlers
-- @within QSB_3_TradeRoutes
--
-- @usage local TraderDescription = {
--     PlayerID   = 2,       -- Partei des Hafen
--     Path       = "SH2WP", -- Pfad (auch als Table einzelner Punkte möglich)
--     Duration   = 150,     -- Ankerzeit in Sekunden (Standard: 360)
--     Interval   = 3,       -- Monate zwischen zwei Anfarten (Standard: 2)
--     OfferCount = 4,       -- Anzahl Angebote (1 bis 4) (Standard: 4)
--     NoIce      = true,    -- Schiff kommt nicht im Winter (Standard: false)
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
function API.TravelingSalesmanCreate(_TraderDescription)
    if GUI then
        return;
    end
    _TraderDescription.Name = "TravelingSalesman" .. _TraderDescription.PlayerID
    _TraderDescription.Interval = _TraderDescription.Interval * 60
    _TraderDescription.Amount = _TraderDescription.OfferCount
    API.InitHarbor (_TraderDescription.PlayerID, _TraderDescription)
end
TravelingSalesmanCreate = API.TravelingSalesmanCreate;