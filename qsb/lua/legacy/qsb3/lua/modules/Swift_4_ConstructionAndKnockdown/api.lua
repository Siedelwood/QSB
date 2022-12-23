--[[
Swift_4_ConstructionAndKnockdown/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht Abriss und Bau für den Spieler einzuschränken.
-- 
-- <p><b>Hinweis</b>: Jegliche Enschränkungen funktionieren nur für menschlische
-- Spieler. Die KI wird sie alle ignorieren!</p>
-- 
-- <p>Eine Baubeschränkung oder ein Abrissschutz geben eine ID zurück, über die
-- seibiger dann gelöscht werden kann.</p>
--
-- Es gibt zudem eine Hierarchie, nach der die einzelnen Checks durchgeführt
-- werden. Dabei wird nach Art des betroffenen Bereiches und nach Art des
-- betroffenen Subjektes unterschieden.
--
-- Nach Art des Bereiches:
-- <ol>
-- <li>Custom-Funktionen</li>
-- <li>Durch Umkreise definierte Bereiche</li>
-- <li>Durch Territorien definierte Bereiche</li>
-- </ol>
--
-- Nach Art des Gebäudes:
-- <ol>
-- <li>Custom-Funktionen</li>
-- <li>Skriptnamen</li>
-- <li>Entity Types</li>
-- <li>Entity Categories</li>
-- </ol>
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Verhindert den Bau Gebäuden anhand der übergebenen Funktion.
--
-- Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
-- möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
-- allerdings nicht unterstützt.
--
-- Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
-- Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
-- -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als 
-- Parameter übergeben.
--
-- @param[type=number]   _PlayerID ID des Spielers
-- @param[type=function] _Function Funktion im lokalen Skript
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- function MyCustomRestriction = function(_PlayerID, _Type, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyRestriction = API.RestrictBuildingCustomFunction(1, MyCustomRestriction);
--
function API.RestrictBuildingCustomFunction(_PlayerID, _Function)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoConstructCustomFunction", {
        Function = _Function,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden des Typs in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictBuildingTypeInTerritory(1, Entities.B_Bakery, 1);
--
function API.RestrictBuildingTypeInTerritory(_PlayerID, _Type, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoConstructTypeInTerritory", {
        Territory = _Territory,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden des Typs innerhalb des Gebietes.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictBuildingTypeInArea(1, Entities.B_Bakery, "GiveMeMeatInstead", 3000);
--
function API.RestrictBuildingTypeInArea(_PlayerID, _Type, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoConstructTypeInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden der Kategorie in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictBuildingCategoryInTerritory(1, EntityCategories.CityBuilding, 1);
--
function API.RestrictBuildingCategoryInTerritory(_PlayerID, _Category, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoConstructCategoryInTerritory", {
        Territory = _Territory,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden der Kategorie innerhalb des Gebietes.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictBuildingCategoryInArea(1, EntityCategories.OuterRimBuilding, "NoOuterRim", 3000);
--
function API.RestrictBuildingCategoryInArea(_PlayerID, _Category, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoConstructCategoryInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden oder Straßen anhand der übergebenen Funktion.
--
-- Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
-- möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
-- allerdings nicht unterstützt.
--
-- Eine Funktion muss true zurückgeben, wenn der Bau geblockt werden soll.
-- Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
-- -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
-- Parameter übergeben.
--
-- @param[type=number]   _PlayerID ID des Spielers
-- @param[type=function] _Function Funktion im lokalen Skript
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- function MyCustomRestriction = function(_PlayerID, _IsTrail, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyRestriction = API.RestrictRoadCustomFunction(1, MyCustomRestriction);
--
function API.RestrictRoadCustomFunction(_PlayerID, _Function)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoRoadCustomFunction", {
        Function = _Function,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictTrailInTerritory(1, 1);
--
function API.RestrictTrailInTerritory(_PlayerID, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoTrailInTerritory", {
        Territory = _Territory,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden innerhalb des Gebiets.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictTrailInArea(1, "NoMansLand", 3000);
--
function API.RestrictTrailInArea(_PlayerID, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoTrailInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
    });
    return ID;
end

---
-- Verhindert den Bau von Straßen in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictStreetInTerritory(1, 1);
--
function API.RestrictStreetInTerritory(_PlayerID, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoStreetInTerritory", {
        Territory = _Territory,
    });
    return ID;
end

---
-- Verhindert den Bau von Straßen innerhalb des Gebiets.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
--
-- @usage
-- MyRestriction = API.RestrictStreetInArea(1, "NoMansLand", 3000);
--
function API.RestrictStreetInArea(_PlayerID, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoStreetInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
    });
    return ID;
end

---
-- Löscht eine Baueinschränkung mit der angegebenen ID;
-- @param[type=number] _ID  ID der Einschränkung
--
-- @usage
-- API.DeleteRestriction(MyRestriction);
--
function API.DeleteRestriction(_ID)
    if GUI then
        return;
    end
    ModuleConstructionControl.Global:DeleteRestriction(_ID);
    ModuleConstructionControl.Global:SyncRestrictions();
end

---
-- Verhindert den Abriss von Gebäuden anhand der übergebenen Funktion.
--
-- Die angegebene Funktion muss eine Funktion im lokalen Skript sein. Es ist
-- möglich Funktionen innerhalb Tables anzugeben. Die self-Referenz wird
-- allerdings nicht unterstützt.
--
-- Eine Funktion muss true zurückgeben, wenn der Abriss geblockt werden soll.
-- Die gleiche Funktion kann für alle Spieler benutzt werden, wenn als PlayerID
-- -1 angegeben wird. Für welchen Spieler sie ausgeführt wird, wird stets als
-- Parameter übergeben.
--
-- @param[type=number]   _PlayerID ID des Spielers
-- @param[type=function] _Function Funktion im lokalen Skript
-- @return[type=number] ID der Protektion
--
-- @usage
-- function MyCustomProtection = function(_PlayerID, _BuildingID, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyProtection = API.ProtectBuildingCustomFunction(1, MyCustomProtection);
--
function API.ProtectBuildingCustomFunction(_PlayerID, _Function)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownCustomFunction", {
        Function = _Function,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude des Typs in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Protektion
--
-- @usage
-- MyProtection = API.ProtectBuildingTypeInTerritory(1, Entities.B_Bakery, 1);
--
function API.ProtectBuildingTypeInTerritory(_PlayerID, _Type, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownTypeInTerritory", {
        Territory = _Territory,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude des Typs innerhalb des Gebiets.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Protektion
--
-- @usage
-- MyProtection = API.ProtectBuildingTypeInArea(1, Entities.B_Bakery, "AreaCenter", 3000);
--
function API.ProtectBuildingTypeInArea(_PlayerID, _Type, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownTypeInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude in der Kategorie in dem Territorium.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Protektion
--
-- @usage
-- MyProtection = API.ProtectBuildingCategoryInTerritory(1, EntityCategories.CityBuilding, 1);
--
function API.ProtectBuildingCategoryInTerritory(_PlayerID, _Category, _Territory)
    if GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownCategoryInTerritory", {
        Territory = _Territory,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude in der Kategorie innerhalb des Gebiets.
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Protektion
--
-- @usage
-- MyProtection = API.ProtectBuildingCategoryInArea(1, EntityCategories.CityBuilding, "AreaCenter", 3000);
--
function API.ProtectBuildingCategoryInArea(_PlayerID, _Category, _Position, _Area)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownCategoryInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Abriss eines benannten Gebäudes.
-- @param[type=String] _ScriptName Skriptname des Entity
-- @return[type=number] ID der Protektion
--
-- @usage
-- MyProtection = API.ProtectNamedBuilding(1, "Denkmalschutz");
--
function API.ProtectNamedBuilding(_PlayerID, _ScriptName)
    if GUI then
        return 0;
    end
    local ID = ModuleConstructionControl.Global:InsertProtection(_PlayerID, 0, "NoKnockdownScriptName", {
        ScriptName = _ScriptName,
    });
    return ID;
end

---
-- Löscht einen Abrissschutz mit der angegebenen ID.
-- @param[type=number] _ID  ID der Protektion
--
-- @usage
-- API.DeleteProtection(MyProtection);
--
function API.DeleteProtection(_ID)
    if GUI then
        return;
    end
    ModuleConstructionControl.Global:DeleteProtection(_ID);
    ModuleConstructionControl.Global:SyncProtections();
end

