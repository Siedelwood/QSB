-- -------------------------------------------------------------------------- --

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
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Verhindert den Bau Gebäuden anhand der übergebenen Funktion.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
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
-- @param                _Message  (Optional) Nachricht für Bau gesperrt (String, Table)
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- local MyCustomRestriction = function(_PlayerID, _Type, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyRestrictionID = API.RestrictBuildingCustomFunction(1, MyCustomRestriction);
--
function API.RestrictBuildingCustomFunction(_PlayerID, _Function, _Message)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoConstructCustomFunction", {
        Function = _Function,
        Message = _Message
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden des Typs in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictBuildingTypeInTerritory(1, Entities.B_Bakery, 1);
--
function API.RestrictBuildingTypeInTerritory(_PlayerID, _Type, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoConstructTypeInTerritory", {
        Territory = _Territory,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden des Typs innerhalb des Gebietes.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictBuildingTypeInArea(1, Entities.B_Bakery, "GiveMeMeatInstead", 3000);
--
function API.RestrictBuildingTypeInArea(_PlayerID, _Type, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoConstructTypeInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden der Kategorie in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictBuildingCategoryInTerritory(1, EntityCategories.CityBuilding, 1);
--
function API.RestrictBuildingCategoryInTerritory(_PlayerID, _Category, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoConstructCategoryInTerritory", {
        Territory = _Territory,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Bau von Gebäuden der Kategorie innerhalb des Gebietes.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictBuildingCategoryInArea(1, EntityCategories.OuterRimBuilding, "NoOuterRim", 3000);
--
function API.RestrictBuildingCategoryInArea(_PlayerID, _Category, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoConstructCategoryInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden oder Straßen anhand der übergebenen Funktion.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
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
-- @param                _Message  (Optional) Nachricht für Bau gesperrt (String, Table)
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- local MyCustomRestriction = function(_PlayerID, _IsTrail, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyRestrictionID = API.RestrictRoadCustomFunction(1, MyCustomRestriction);
--
function API.RestrictRoadCustomFunction(_PlayerID, _Function, _Message)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoRoadCustomFunction", {
        Function = _Function,
        Message = _Message,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictTrailInTerritory(1, 1);
--
function API.RestrictTrailInTerritory(_PlayerID, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoTrailInTerritory", {
        Territory = _Territory,
    });
    return ID;
end

---
-- Verhindert den Bau von Pfaden innerhalb des Gebiets.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictTrailInArea(1, "NoMansLand", 3000);
--
function API.RestrictTrailInArea(_PlayerID, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoTrailInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
    });
    return ID;
end

---
-- Verhindert den Bau von Straßen in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictStreetInTerritory(1, 1);
--
function API.RestrictStreetInTerritory(_PlayerID, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoStreetInTerritory", {
        Territory = _Territory,
    });
    return ID;
end

---
-- Verhindert den Bau von Straßen innerhalb des Gebiets.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- MyRestrictionID = API.RestrictStreetInArea(1, "NoMansLand", 3000);
--
function API.RestrictStreetInArea(_PlayerID, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, 0, "NoStreetInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
    });
    return ID;
end

---
-- Löscht eine Baueinschränkung mit der angegebenen ID.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _ID  ID der Einschränkung
-- @within Baubeschränkung
--
-- @usage
-- API.DeleteRestriction(MyRestrictionID);
--
function API.DeleteRestriction(_ID)
    if not GUI then
        return;
    end
    ModuleBuildRestriction.Local:DeleteRestriction(_ID);
end

---
-- Verhindert den Abriss von Gebäuden anhand der übergebenen Funktion.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
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
-- @param                _Message  (Optional) Nachricht für Abriss gesperrt (String, Table)
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- local MyCustomProtection = function(_PlayerID, _BuildingID, _X, _Y)
--    if AnythingIWant then
--        return true;
--    end
-- end
-- MyProtectionID = API.ProtectBuildingCustomFunction(1, MyCustomProtection);
--
function API.ProtectBuildingCustomFunction(_PlayerID, _Function, _Message)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownCustomFunction", {
        Function = _Function,
        Message = _Message,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude des Typs in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- MyProtectionID = API.ProtectBuildingTypeInTerritory(1, Entities.B_Bakery, 1);
--
function API.ProtectBuildingTypeInTerritory(_PlayerID, _Type, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownTypeInTerritory", {
        Territory = _Territory,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude des Typs innerhalb des Gebiets.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Type      Entity-Typ
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- MyProtectionID = API.ProtectBuildingTypeInArea(1, Entities.B_Bakery, "AreaCenter", 3000);
--
function API.ProtectBuildingTypeInArea(_PlayerID, _Type, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownTypeInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Type = _Type,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude in der Kategorie in dem Territorium.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Territory ID oder Name des Territorium
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- MyProtectionID = API.ProtectBuildingCategoryInTerritory(1, EntityCategories.CityBuilding, 1);
--
function API.ProtectBuildingCategoryInTerritory(_PlayerID, _Category, _Territory)
    if not GUI then
        return 0;
    end
    if type(_Territory) == "string" then
        _Territory = GetTerritoryIDByName(_Territory);
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownCategoryInTerritory", {
        Territory = _Territory,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Abriss aller Gebäude in der Kategorie innerhalb des Gebiets.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _PlayerID  ID des Spielers
-- @param[type=number] _Category  Entity-Kategorie
-- @param              _Position  Position oder Skriptname
-- @param[type=number] _Area      Größe des Gebiets
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- MyProtectionID = API.ProtectBuildingCategoryInArea(1, EntityCategories.CityBuilding, "AreaCenter", 3000);
--
function API.ProtectBuildingCategoryInArea(_PlayerID, _Category, _Position, _Area)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownCategoryInArea", {
        Position = API.GetPosition(_Position),
        Area = _Area,
        Category = _Category,
    });
    return ID;
end

---
-- Verhindert den Abriss eines benannten Gebäudes.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=String] _ScriptName Skriptname des Entity
-- @return[type=number] ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- MyProtectionID = API.ProtectNamedBuilding(1, "Denkmalschutz");
--
function API.ProtectNamedBuilding(_PlayerID, _ScriptName)
    if not GUI then
        return 0;
    end
    local ID = ModuleBuildRestriction.Local:InsertProtection(_PlayerID, 0, "NoKnockdownScriptName", {
        ScriptName = _ScriptName,
    });
    return ID;
end

---
-- Löscht einen Abrissschutz mit der angegebenen ID.
--
-- <b>Hinweis:</b> Die Funktion kann nur im lokalen Skript verwendet werden!
--
-- @param[type=number] _ID ID der Protektion
-- @within Abrissbeschränkung
--
-- @usage
-- API.DeleteProtection(MyProtectionID);
--
function API.DeleteProtection(_ID)
    if not GUI then
        return;
    end
    ModuleBuildRestriction.Local:DeleteProtection(_ID);
end

