--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleBuildRestriction = {
    Properties = {
        Name = "ModuleBuildRestriction",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {},
    Local = {
        LastSelectedBuildingType = 0,
        LastSelectedRoadType = 0,
        RestrictionSequence = 0,
        ProtectionSequence = 0,
        ConstructionRestrictions = {},
        ConstructionFeedbackText = nil,
        KnockdownProtection = {},
        KnockdownFeedbackText = nil,
    },
    Shared = {
        Text = {
            NoBuilding = {
                de = "Kann hier nicht gebaut werden!",
                en = "This can not be placed here!",
                fr = "Cela ne peut pas être placé ici!"
            },
            NoBuildingInTerritory = {
                de = "Das kann in diesem Territorium nicht gebaut werden!",
                en = "This can not be placed in this territory!",
                fr = "Cela ne peut pas être construit sur le territoire!"
            },
            NoBuildingInArea = {
                de = "Das kann in diesem Bereich nicht gebaut werden!",
                en = "This can not be placed in this area!",
                fr = "Cela ne peut pas être construit dans ce domaine!"
            },

            NoKnockdown = {
                de = "Das kann nicht abgerissen werden!",
                en = "This building can not be demolished!",
                fr = "Cela ne peut pas être démoli!"
            },
            NoKnockdownInTerritory = {
                de = "Das kann in diesem Territorium nicht abgerissen werden!",
                en = "Demolishing this building is not allowed in this territory!",
                fr = "Cela ne peut pas être démoli dans ce territoire!"
            },
            NoKnockdownInArea = {
                de = "Das kann in diesem Bereich nicht abgerissen werden!",
                en = "Demolishing this building is not allowed in this area!",
                fr = "Cela ne peut pas être démoli dans ce domaine!"
            },

            NoTrailInTerritory = {
                de = "Pfade können in diesem Territorium nicht gebaut werden!",
                en = "The placement of trails is not allowed in this territory!",
                fr = "Les chemins ne peuvent pas être construits sur ce territoire!"
            },
            NoTrailInArea = {
                de = "Pfade können in diesem Bereich nicht gebaut werden!",
                en = "The placement of trails is not allowed in this area!",
                fr = "Les chemins ne peuvent pas être construits dans cette zone!"
            },
            NoStreetInTerritory = {
                de = "Straßen können in diesem Territorium nicht gebaut werden!",
                en = "The placement of streets is not allowed in this territory!",
                fr = "Les routes ne peuvent pas être construites sur ce territoire!"
            },
            NoStreetInArea = {
                de = "Straßen können in diesem Bereich nicht gebaut werden!",
                en = "The placement of streets is not allowed in this area!",
                fr = "Les routes ne peuvent pas être construites dans cette zone!"
            },
        }
    }
}

-- Global ------------------------------------------------------------------- --

function ModuleBuildRestriction.Global:OnGameStart()
end

function ModuleBuildRestriction.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleBuildRestriction.Local:OnGameStart()
    for i= 1, 8 do
        -- All knockdown protections
        self.KnockdownProtection[i] = {
            NoKnockdownCustomFunction = {},
            NoKnockdownCategoryInArea = {},
            NoKnockdownCategoryInTerritory = {},
            NoKnockdownTypeInArea = {},
            NoKnockdownTypeInTerritory = {},
            NoKnockdownScriptName = {},
        };
        -- All construction restrictions
        self.ConstructionRestrictions[i] = {
            NoConstructCustomFunction = {},
            NoConstructCategoryInArea = {},
            NoConstructCategoryInTerritory = {},
            NoConstructTypeInArea = {},
            NoConstructTypeInTerritory = {},
            NoRoadCustomFunction = {},
            NoTrailInArea = {},
            NoTrailInTerritory = {},
            NoStreetInArea = {},
            NoStreetInTerritory = {},
        };
    end
    self:OverrideDeleteEntityStateBuilding();
    self:OverrideBuildButtonClicked();
    self:OverridePlacementUpdate();
end

function ModuleBuildRestriction.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleBuildRestriction.Local:GetNewRestrictionID()
    self.RestrictionSequence = self.RestrictionSequence +1;
    return self.RestrictionSequence;
end

function ModuleBuildRestriction.Local:GetNewProtectionID()
    self.ProtectionSequence = self.ProtectionSequence +1;
    return self.ProtectionSequence;
end

function ModuleBuildRestriction.Local:InsertRestriction(_PlayerID, _ID, _Type, _Data)
    _ID = ((_ID == 0 or _ID == nil) and self:GetNewRestrictionID()) or _ID;
    _Data.ID = _ID;
    if _PlayerID == -1 then
        for i= 1, 8 do
            if self.ConstructionRestrictions[i][_Type] then
                table.insert(self.ConstructionRestrictions[i][_Type], _Data);
            end
        end
    else
        if self.ConstructionRestrictions[_PlayerID] and self.ConstructionRestrictions[_PlayerID][_Type] then
            table.insert(self.ConstructionRestrictions[_PlayerID][_Type], _Data);
        end
    end
    return _ID;
end

function ModuleBuildRestriction.Local:InsertProtection(_PlayerID, _ID, _Type, _Data)
    _ID = ((_ID == 0 or _ID == nil) and self:GetNewProtectionID()) or _ID;
    _Data.ID = _ID;
    if _PlayerID == -1 then
        for i= 1, 8 do
            if self.KnockdownProtection[i][_Type] then
                table.insert(self.KnockdownProtection[i][_Type], _Data);
            end
        end
    else
        if self.KnockdownProtection[_PlayerID] and self.KnockdownProtection[_PlayerID][_Type] then
            table.insert(self.KnockdownProtection[_PlayerID][_Type], _Data);
        end
    end
    return _ID;
end

function ModuleBuildRestriction.Local:DeleteRestriction(_ID)
    for i= 1, 8 do
        for k, v in pairs(self.ConstructionRestrictions[i]) do
            for j= #v, 1, -1 do
                if v[j].ID == _ID then
                    table.remove(self.ConstructionRestrictions[i][k], j);
                end
            end
        end
    end
end

function ModuleBuildRestriction.Local:DeleteProtection(_ID)
    for i= 1, 8 do
        for k, v in pairs(self.KnockdownProtection[i]) do
            for j= #v, 1, -1 do
                if v[j].ID == _ID then
                    table.remove(self.KnockdownProtection[i][k], j);
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleBuildRestriction.Local:OverrideDeleteEntityStateBuilding()
    GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl = GameCallback_GUI_DeleteEntityStateBuilding;
    GameCallback_GUI_DeleteEntityStateBuilding = function(_BuildingID, _State)
        GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl(_BuildingID, _State);
        ModuleBuildRestriction.Local:CheckCanKnockdownBuilding(_BuildingID, _State);
    end
end

function ModuleBuildRestriction.Local:OverrideBuildButtonClicked()
    GUI_Construction.BuildClicked_Orig_ConstructionControl = GUI_Construction.BuildClicked;
    GUI_Construction.BuildClicked = function(_BuildingType)
        ModuleBuildRestriction.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildClicked_Orig_ConstructionControl(_BuildingType);
    end

    GUI_Construction.BuildStreetClicked_Orig_ConstructionControl = GUI_Construction.BuildStreetClicked;
    GUI_Construction.BuildStreetClicked = function(_IsTrail)
        _IsTrail = (_IsTrail ~= nil and _IsTrail) or false;
        ModuleBuildRestriction.Local.LastSelectedRoadType = _IsTrail;
        GUI_Construction.BuildStreetClicked_Orig_ConstructionControl(_IsTrail);
    end

    GUI_Construction.BuildWallClicked_Orig_ConstructionControl = GUI_Construction.BuildWallClicked;
    GUI_Construction.BuildWallClicked = function(_BuildingType)
        if _BuildingType == nil then
            _BuildingType = GetUpgradeCategoryForClimatezone("WallSegment");
        end
        ModuleBuildRestriction.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildWallClicked_Orig_ConstructionControl(_BuildingType);
    end

    GUI_Construction.BuildWallGateClicked_Orig_ConstructionControl = GUI_Construction.BuildWallGateClicked;
    GUI_Construction.BuildWallGateClicked = function(_BuildingType)
        if _BuildingType == nil then
            _BuildingType = GetUpgradeCategoryForClimatezone("WallSegment");
        end
        ModuleBuildRestriction.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildWallGateClicked_Orig_ConstructionControl(_BuildingType);
    end

    GUI_BuildingButtons.PlaceFieldClicked_Orig_ConstructionControl = GUI_BuildingButtons.PlaceFieldClicked;
    GUI_BuildingButtons.PlaceFieldClicked = function()
        local EntityType = Logic.GetEntityType(GUI.GetSelectedEntity());
        ModuleBuildRestriction.Local.LastSelectedBuildingType = EntityType;
        GUI_BuildingButtons.PlaceFieldClicked_Orig_ConstructionControl();
    end
end

function ModuleBuildRestriction.Local:OverridePlacementUpdate()
    GUI_Construction.PlacementUpdate_Orig_ConstructionControl = GUI_Construction.PlacementUpdate;
    GUI_Construction.PlacementUpdate = function()
        ModuleBuildRestriction.Local:CancleConstructionState(GUI.GetPlayerID());
        GUI_Construction.PlacementUpdate_Orig_ConstructionControl();
    end
end

function ModuleBuildRestriction.Local:CancelState(_Message)
    local Text = _Message or ModuleBuildRestriction.Shared.Text.NoBuilding;
    API.Message(API.Localize(Text));
    GUI.CancelState();
end

function ModuleBuildRestriction.Local:CancelKnockdown(_EntityID, _Message)
    local Text = _Message or ModuleBuildRestriction.Shared.Text.NoKnockdown;
    API.Message(API.Localize(Text));
    GUI.CancelBuildingKnockDown(_EntityID);
end

function ModuleBuildRestriction.Local:CancleConstructionState(_PlayerID)
    if not self.ConstructionRestrictions[_PlayerID] then
        return;
    end
    local x,y = GUI.Debug_GetMapPositionUnderMouse();
    local Territory = Logic.GetTerritoryAtPosition(x or 1, y or 1);
    local Text = ModuleBuildRestriction.Shared.Text;

    -- Check placing roads
    if g_Construction.CurrentPlacementType == 1 then
        -- Check custom function
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoRoadCustomFunction) do
            if v.Function and v.Function(_PlayerID, ModuleBuildRestriction.Local.LastSelectedRoadType, x, y) then
                return self:CancelState(v.Message);
            end
        end
        if ModuleBuildRestriction.Local.LastSelectedRoadType then
            -- Check road in area
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoTrailInArea) do
                if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area then
                    return self:CancelState(Text.NoTrailInArea);
                end
            end
            -- Check road in territory
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoTrailInTerritory) do
                if Territory == v.Territory then
                    return self:CancelState(Text.NoTrailInTerritory);
                end
            end
        else
            -- Check street in area
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoStreetInArea) do
                if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area then
                    return self:CancelState(Text.NoStreetInArea);
                end
            end
            -- Check street in territory
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoStreetInTerritory) do
                if Territory == v.Territory then
                    return self:CancelState(Text.NoStreetInTerritory);
                end
            end
        end
    end

    -- Check placing buildings
    if g_Construction.CurrentPlacementType ~= 1 then
        local UpgradeCategory = ModuleBuildRestriction.Local.LastSelectedBuildingType;
        local n, Type = Logic.GetBuildingTypesInUpgradeCategory(UpgradeCategory);
        local CategoryList = ModuleBuildRestriction.Local:GetEntityTypeCategoyList(Type);

        -- Check custom function
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCustomFunction) do
            if v.Function and v.Function(_PlayerID, Type, x, y) then
                return self:CancelState(v.Message);
            end
        end
        -- Check type in area
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructTypeInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and v.Type == Type then
                return self:CancelState(Text.NoBuildingInArea);
            end
        end
        -- Check type in territory
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructTypeInTerritory) do
            if Territory == v.Territory and v.Type == Type then
                return self:CancelState(Text.NoBuildingInTerritory);
            end
        end
        -- Check category in area
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCategoryInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and table.contains(CategoryList, v.Category) then
                return self:CancelState(Text.NoBuildingInArea);
            end
        end
        -- Check category in territory
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCategoryInTerritory) do
            if Territory == v.Territory and table.contains(CategoryList, v.Category) then
                return self:CancelState(Text.NoBuildingInTerritory);
            end
        end
    end
end

function ModuleBuildRestriction.Local:CheckCanKnockdownBuilding(_BuildingID, _State)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local x,y,z = Logic.EntityGetPos(_BuildingID);
    local ScriptName = Logic.GetEntityName(_BuildingID);
    local Territory = Logic.GetTerritoryAtPosition(x or 1, y or 1);
    local Type = Logic.GetEntityType(_BuildingID);
    local CategoryList = ModuleBuildRestriction.Local:GetEntityTypeCategoyList(Type);

    if Logic.IsConstructionComplete(_BuildingID) == 0 then
        return;
    end
    local Text = ModuleBuildRestriction.Shared.Text;
    if self.KnockdownProtection[PlayerID] then
        -- Check custom function
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCustomFunction) do
            if v.Function and v.Function(PlayerID, _BuildingID, x, y) then
                return self:CancelKnockdown(_BuildingID, v.Message);
            end
        end
        -- Check scriptname
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownScriptName) do
            if ScriptName == v.ScriptName then
                return self:CancelKnockdown(_BuildingID, Text.NoKnockdown);
            end
        end
        -- Check type in area
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownTypeInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and v.Type == Type then
                return self:CancelKnockdown(_BuildingID, Text.NoKnockdownInArea);
            end
        end
        -- Check type in territory
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownTypeInTerritory) do
            if Territory == v.Territory and v.Type == Type then
                return self:CancelKnockdown(_BuildingID, Text.NoKnockdownInTerritory);
            end
        end
        -- Check category in area
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCategoryInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and table.contains(CategoryList, v.Category) then
                return self:CancelKnockdown(_BuildingID, Text.NoKnockdownInArea);
            end
        end
        -- Check category in territory
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCategoryInTerritory) do
            if Territory == v.Territory and table.contains(CategoryList, v.Category) then
                return self:CancelKnockdown(_BuildingID, Text.NoKnockdownInTerritory);
            end
        end
    end
end

-- Helper for getting the categories a type is in.
function ModuleBuildRestriction.Local:GetEntityTypeCategoyList(_Type)
    local CategoryList = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityTypeInCategory(_Type, v) == 1 then
            table.insert(CategoryList, v);
        end
    end
    return CategoryList;
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleBuildRestriction);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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

