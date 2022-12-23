--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht, Entities suchen und auf bestimmte Ereignisse reagieren.
--
-- <h5>Entity Suche</h5>
-- TODO
--
-- <h5>Diebstahleffekte</h5>
-- Die Effekte von Diebstählen können deaktiviert und mittels Event neu
-- geschrieben werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntitySpawned Ein Entity wurde aus einem Spawner erzeugt. (Parameter: EntityID, PlayerID, SpawnerID)
-- @field SettlerAttracted Ein Siedler kommt in die Siedlung. (Parameter: EntityID, PlayerID)
-- @field EntityDestroyed Ein Entity wurde zerstört. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID, PlayerID)
-- @field EntityHurt Ein Entity wurde angegriffen. (Parameter: AttackedEntityID, AttackedPlayerID, AttackingEntityID, AttackingPlayerID)
-- @field EntityKilled Ein Entity wurde getötet. (Parameter: KilledEntityID, KilledPlayerID, KillerEntityID, KillerPlayerID)
-- @field EntityOwnerChanged Ein Entity wechselt den Besitzer. (Parameter: OldIDList, OldPlayer, NewIDList, OldPlayer)
-- @field EntityResourceChanged Resourcen im Entity verändern sich. (Parameter: EntityID, GoodType, OldAmount, NewAmount)
-- @field BuildingConstructed Ein Gebäude wurde fertiggestellt. (Parameter: BuildingID, PlayerID)
-- @field BuildingUpgraded Ein Gebäude wurde aufgewertet. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field BuildingUpgradeCollapsed Eine Ausbaustufe eines Gebäudes wurde zerstört. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field ThiefInfiltratedBuilding Ein Dieb hat ein Gebäude infiltriert. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID)
-- @field ThiefDeliverEarnings Ein Dieb liefert seine Beute ab. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID, GoldAmount)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- -------------------------------------------------------------------------- --
-- Search

---
-- Findet <u>alle</u> Entities.
--
-- @param[type=number]  _PlayerID               (Optional) ID des Besitzers
-- @param[type=boolean] _WithoutDefeatResistant (Optional) Niederlageresistente Entities filtern
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- -- ALLE Entities
-- local Result = API.SearchEntities();
-- -- Alle Entities von Spieler 5.
-- local Result = API.SearchEntities(5);
--
function API.SearchEntities(_PlayerID, _WithoutDefeatResistant)
    if _WithoutDefeatResistant == nil then
        _WithoutDefeatResistant = false;
    end
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _WithoutDefeatResistant then
            if (Logic.IsBuilding(_ID) or Logic.IsWall(_ID)) and Logic.IsConstructionComplete(_ID) == 0 then
                return false;
            end
            local Type = Logic.GetEntityType(_ID);
            local TypeName = Logic.GetEntityType(Type);
            if TypeName and (string.find(TypeName, "^S_") or string.find(TypeName, "^XD_")) then
                return false;
            end
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities des Typs in einem Gebiet.
--
-- @param[type=number] _Area     Größe des Suchgebiet
-- @param              _Position Mittelpunkt (EntityID, Skriptname oder Table)
-- @param[type=number] _Type     Typ des Entity
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInArea(5000, "Busches", Entities.R_HerbBush);
--
function API.SearchEntitiesOfTypeInArea(_Area, _Position, _Type, _PlayerID)
    return API.SearchEntitiesInArea(_Area, _Position, _PlayerID, _Type, nil);
end

---
-- Findet alle Entities der Kategorie in einem Gebiet.
--
-- @param[type=number] _Area     Größe des Suchgebiet
-- @param              _Position Mittelpunkt (EntityID, Skriptname oder Table)
-- @param[type=number] _Category Category des Entity
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInArea(5000, "City", EntityCategories.CityBuilding, 2);
--
function API.SearchEntitiesOfCategoryInArea(_Area, _Position, _Category, _PlayerID)
    return API.SearchEntitiesInArea(_Area, _Position, _PlayerID, nil, _Category);
end

-- Not supposed to be used directly!
function API.SearchEntitiesInArea(_Area, _Position, _PlayerID, _Type, _Category)
    local Position = _Position;
    if type(Position) ~= "table" then
        Position = GetPosition(Position);
    end
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _Type and Logic.GetEntityType(_ID) ~= _Type then
            return false;
        end
        if _Category and Logic.IsEntityInCategory(_ID, _Category) == 0 then
            return false;
        end
        if API.GetDistance(_ID, Position) > _Area then
            return false;
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities des Typs in einem Territorium.
--
-- @param[type=number] _Territory Territorium für die Suche
-- @param[type=number] _Type      Typ des Entity
-- @param[type=number] _PlayerID  (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInTerritory(7, Entities.R_HerbBush);
--
function API.SearchEntitiesOfTypeInTerritory(_Territory, _Type, _PlayerID)
    return API.SearchEntitiesInTerritory(_Territory, _PlayerID, _Type, nil);
end

---
-- Findet alle Entities der Kategorie in einem Territorium.
--
-- @param[type=number] _Territory Territorium für die Suche
-- @param[type=number] _Category  Category des Entity
-- @param[type=number] _PlayerID  (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInTerritory(7, EntityCategories.CityBuilding, 6);
--
function API.SearchEntitiesOfCategoryInTerritory(_Territory, _Category, _PlayerID)
    return API.SearchEntitiesInTerritory(_Territory, _PlayerID, nil, _Category);
end

-- Not supposed to be used directly!
function API.SearchEntitiesInTerritory(_Territory, _PlayerID, _Type, _Category)
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _Type and Logic.GetEntityType(_ID) ~= _Type then
            return false;
        end
        if _Category and Logic.IsEntityInCategory(_ID, _Category) == 0 then
            return false;
        end
        if _Territory and GetTerritoryUnderEntity(_ID) ~= _Territory then
            return false;
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities deren Skriptname das Suchwort enthält.
--
-- @param[type=number] _Pattern Suchwort
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- -- Findet alle Entities, deren Name mit "TreasureChest" beginnt.
-- local Result = API.SearchEntitiesByScriptname("^TreasureChest");
--
function API.SearchEntitiesByScriptname(_Pattern)
    _Filter = _Filter or function(_ID)
        local ScriptName = Logic.GetEntityName(_ID);
        if not string.find(ScriptName, _Pattern) then
            return false;
        end
        return true;
    end
    return ModuleEntity.Shared:IterateOverEntities(_Filter);
end

---
-- Führt eine benutzerdefinierte Suche nach Entities aus.
--
-- <b>Achtung</b>: Die Reihenfolge der Abfragen im Filter hat direkten
-- Einfluss auf die Dauer der Suche. Während Abfragen auf den Besitzer oder
-- den Typ schnell gehen, dauern Gebietssuchen lange! Es ist daher klug, zuerst
-- Kriterien auszuschließen, die schnell bestimmt werden können!
--
-- @param[type=function] _Filter Funktion zur Filterung
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see QSB.SearchPredicate
--
-- @usage
-- -- Es werden alle Kühe und Schafe von Spieler 1 gefunden, die nicht auf den
-- -- Territorien 7 und 15 sind.
-- local Result = API.CommenceEntitySearch(
--     function(_ID)
--         -- Nur Entities von Spieler 1 akzeptieren
--         if Logic.EntityGetPlayer(_ID) == 1 then
--             -- Nur Entities akzeptieren, die Kühe oder Schafe sind.
--             if Logic.IsEntityInCategory(_ID, EntityCategories.CattlePasture) == 1
--             or Logic.IsEntityInCategory(_ID, EntityCategories.SheepPasture) == 1 then
--                 -- Nur Entities akzeptieren, die nicht auf den Territorien 7 und 15 sind.
--                 local Territory = GetTerritoryUnderEntity(_ID);
--                 return Territory ~= 7 and Territory ~= 15;
--             end
--         end
--         return false;
--     end
-- );
--
function API.CommenceEntitySearch(_Filter)
    _Filter = _Filter or function(_ID)
        return true;
    end
    return ModuleEntity.Shared:IterateOverEntities(_Filter);
end

-- Compatibility option
function API.GetEntitiesOfCategoryInTerritory(_PlayerID, _Category, _Territory)
    return API.SearchEntitiesOfCategoryInTerritory(_Territory, _Category, _PlayerID);
end

-- Compatibility option
-- FIXME: Realy needed? Don't they throw the old version in the script anyway?
function API.GetEntitiesOfCategoriesInTerritories(_PlayerID, _Category, _Territory)
    local p = (type(_PlayerID) == "table" and _PlayerID) or {_PlayerID};
    local c = (type(_Category) == "table" and _Category) or {_Category};
    local t = (type(_Territory) == "table" and _Territory) or {_Territory};
    local PlayerEntities = {};
    for i=1, #p, 1 do
        for j=1, #c, 1 do
            for k=1, #t, 1 do
                local Units = API.SearchEntitiesOfCategoryInTerritory(t[k], c[j], p[i]);
                PlayerEntities = Array_Append(PlayerEntities, Units);
            end
        end
    end
    return PlayerEntities;
end

-- -------------------------------------------------------------------------- --
-- Thief

---
-- Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableStorehouseEffect(true);
-- -- Aktivieren
-- API.ThiefDisableStorehouseEffect(false);
--
function API.ThiefDisableStorehouseEffect(_Flag)
    ModuleEntity.Global.DisableThiefStorehouseHeist = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCathedralEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCathedralEffect(false);
--
function API.ThiefDisableCathedralEffect(_Flag)
    ModuleEntity.Global.DisableThiefCathedralSabotage = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.
--
-- <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCisternEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCisternEffect(false);
--
function API.ThiefDisableCisternEffect(_Flag)
    ModuleEntity.Global.DisableThiefCisternSabotage = _Flag == true;
end

