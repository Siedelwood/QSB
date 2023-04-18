--[[
Swift_2_CastleStore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul stellt ein Burglager zur Verfügung, das sich ähnlich wie das
-- normale Lager verhält.
-- 
-- Das Burglager ist von der Ausbaustufe der Burg abhängig. Je weiter die Burg
-- ausgebaut wird, desto höher ist das Limit. Eine Ware wird dann im Burglager
-- eingelagert, wenn das eingestellte Limit der Ware im Lagerhaus erreicht wird.
--
-- Der Spieler kann das allgemeine Verhalten des Lagers für alle Waren wählen
-- und zusätzlich für einzelne Waren andere Verhalten bestimmen. Waren können
-- eingelagert und ausgelagert werden. Eingelagerte Waren können zusätzlich
-- gesperrt werden. Eine gesperrte Ware wird nicht wieder ausgelagert, auch
-- wenn Platz im Lager frei wird.
--
-- Muss ein Spieler einen Tribut aus dem Lagerhaus begleichen, eine bestimmte
-- Menge an Waren erreichen oder die Kosten zur Aktivierung eines interaktien
-- Objektes bezahlen, werden die Güter im Burglager automatisch mit einbezogen,
-- wenn sie nicht gesperrt wurden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erstellt ein Burglager für den angegebenen Spieler.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=table] Burglager-Instanz
-- @within Anwenderfunktionen
-- @usage
-- API.CastleStoreCreate(1);
--
function API.CastleStoreCreate(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreCreate: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    return QSB.CastleStore:New(_PlayerID);
end

---
-- Zerstört das Burglager des angegebenen Spielers.
--
-- Alle Waren im Burglager werden dabei unwiederuflich gelöscht!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
-- @usage
-- API.CastleStoreDestroy(1)
--
function API.CastleStoreDestroy(_PlayerID)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreDestroy: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        Store:Dispose();
    end
end

---
-- Fügt dem Burglager des Spielers eine Menga an Waren hinzu.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good Typ der Ware
-- @param[type=number] _Amount Menge der Ware
-- @within Anwenderfunktionen
-- @usage
-- API.CastleStoreAddGood(1, Goods.G_Wood, 50);
--
function API.CastleStoreAddGood(_PlayerID, _Good, _Amount)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreAddGood: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        if GetNameOfKeyInTable(Goods, _Good) == nil then
            error("API.CastleStoreAddGood: _Good (" ..tostring(_Good).. ") is wrong!");
            return;
        end
        if type(_Amount) ~= "number" or _Amount < 1 then
            error("API.CastleStoreAddGood: _Amount (" ..tostring(_Amount).. ") is wrong!");
            return;
        end
        Store:Add(_Good, _Amount);
    end
end

---
-- Entfernt eine Menge von Waren aus dem Burglager des Spielers.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good Typ der Ware
-- @param[type=number] _Amount Menge der Ware
-- @within Anwenderfunktionen
-- @usage
-- API.CastleStoreRemoveGood(1, Goods.G_Iron, 15);
--
function API.CastleStoreRemoveGood(_PlayerID, _Good, _Amount)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreRemoveGood: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        if GetNameOfKeyInTable(Goods, _Good) == nil then
            error("API.CastleStoreRemoveGood: _Good (" ..tostring(_Good).. ") is wrong!");
            return;
        end
        if type(_Amount) ~= "number" or _Amount < 1 then
            error("API.CastleStoreRemoveGood: _Amount (" ..tostring(_Amount).. ") is wrong!");
            return;
        end
        Store:Remove(_Good, _Amount);
    end
end

---
-- Gibt die Menge an Waren des Typs im Burglager des Spielers zurück.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good Typ der Ware
-- @return[type=number] Menge an Waren
-- @within Anwenderfunktionen
-- @usage
-- local Amount = API.CastleStoreCountGood(1, Goods.G_Milk);
--
function API.CastleStoreGetGoodAmount(_PlayerID, _Good)
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreGetGoodAmount: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CastleStoreGetGoodAmount: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if GUI then
        return QSB.CastleStore:GetAmount(_PlayerID, _Good);
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        return Store:GetAmount(_Good);
    end
    return 0;
end

---
-- Gibt die Gesamtmenge aller Waren im Burglager zurück.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Menge an Waren
-- @within Anwenderfunktionen
-- @usage
-- local Amount = API.CastleStoreTotalAmount(1);
--
function API.CastleStoreGetTotalAmount(_PlayerID)
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreGetTotalAmount: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    if GUI then
        return QSB.CastleStore:GetTotalAmount(_PlayerID);
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        return Store:GetTotalAmount();
    end
    return 0;
end

---
-- Gibt die maximale Kapazität des Burglagers zurück.
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Große des Lagers
-- @within Anwenderfunktionen
-- @usage
-- local Size = API.CastleStoreGetSize(1);
--
function API.CastleStoreGetSize(_PlayerID)
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreGetSize: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    if GUI then
        return QSB.CastleStore:GetLimit(_PlayerID);
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        return Store:GetLimit();
    end
    return 0;
end

---
-- Setzt die Basiskapazität des Burglagers.
--
-- Die Basiskapazität ist das Limit der ersten Stufe der Burg. Mit jedem
-- Ausbau wird dieser Wert verdoppelt.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Capacity Basisgröße des Lagers
-- @within Anwenderfunktionen
-- @usage
-- -- -> [150, 300, 600, 1200]
-- API.CastleStoreSetBaseCapacity(1, 150);
--
function API.CastleStoreSetBaseCapacity(_PlayerID, _Capacity)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreSetBaseCapacity: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    if type(_Capacity) ~= "number" or _Capacity < 1 then
        error("API.CastleStoreSetBaseCapacity: _Capacity (" ..tostring(_Capacity).. ") is wrong!");
        return;
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        Store:SetStorageLimit(_Capacity);
    end
end

---
-- Setzt die Obergrenze ab der ins Burglager ausgelagert wird.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good     Warentyp
-- @param[type=number] _Limit    Obergrenze
-- @within Anwenderfunktionen
-- @usage
-- API.CastleStoreSetOutsourceBoundary(1, Goods.G_Milk, 50);
--
function API.CastleStoreSetOutsourceBoundary(_PlayerID, _Good, _Limit)
    if GUI then
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 1 or _PlayerID > 8 then
        error("API.CastleStoreSetOutsourceBoundary: _PlayerID (" ..tostring(_PlayerID).. ") is wrong!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CastleStoreSetOutsourceBoundary: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Limit) ~= "number" or _Limit < 1 then
        error("API.CastleStoreSetOutsourceBoundary: _Limit (" ..tostring(_Limit).. ") is wrong!");
        return;
    end
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    if Store then
        Store:SetUperLimitInStorehouseForGoodType(_Good, _Limit)
    end
end

-- Local callbacks

function SCP.CastleStore.AcceptAllGoods(_PlayerID)
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    for k, v in pairs(Store.Goods) do
        Store:SetGoodAccepted(k, true);
        Store:SetGoodLocked(k, false);
    end
end

function SCP.CastleStore.LockAllGoods(_PlayerID)
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    for k, v in pairs(Store.Goods) do
        Store:SetGoodAccepted(k, true);
        Store:SetGoodLocked(k, true);
    end
end

function SCP.CastleStore.RefuseAllGoods(_PlayerID)
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    for k, v in pairs(Store.Goods) do
        Store:SetGoodAccepted(k, false);
        Store:SetGoodLocked(k, false);
    end
end

function SCP.CastleStore.ToggleGoodState(_PlayerID, _GoodType)
    local Store = QSB.CastleStore:GetInstance(_PlayerID);
    local Accepted = Store:IsGoodAccepted(_GoodType)
    local Locked   = Store:IsGoodLocked(_GoodType)
    if Accepted and not Locked then
        Store:SetGoodLocked(_GoodType, true);
        Store:SetGoodAccepted(_GoodType, true);
    elseif Accepted and Locked then
        Store:SetGoodLocked(_GoodType, false);
        Store:SetGoodAccepted(_GoodType, false);
    elseif not Accepted and not Locked then
        Store:SetGoodAccepted(_GoodType, true);
    else
        Store:SetGoodLocked(_GoodType, false);
        Store:SetGoodAccepted(_GoodType, true);
    end
end

function SCP.CastleStore.ObjectPayStep1(_PlayerID, _EntityID, _CostType1, _CostAmount1, _CostType2, _CostAmount2)
    ModuleCastleStore.Global:InteractiveObjectPayStep1(_PlayerID, _EntityID, _CostType1, _CostAmount1, _CostType2, _CostAmount2);
end

function SCP.CastleStore.ObjectPayStep3(_PlayerID, _EntityID)
    ModuleCastleStore.Global:InteractiveObjectPayStep3(_PlayerID, _EntityID);
end

