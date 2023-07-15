--[[
Swift_4_ConstructionAndKnockdown/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.ConstructionAndKnockdown = {};

ModuleConstructionControl = {
    Properties = {
        Name = "ModuleConstructionControl",
    },

    Global = {
        RestrictionSequence = 0,
        ProtectionSequence = 0,
        ConstructionRestrictions = {},
        KnockdownProtection = {},
    },
    Local = {
        LastSelectedBuildingType = 0,
        LastSelectedRoadType = 0,
        ConstructionRestrictions = {},
        KnockdownProtection = {},
    },
    Shared = {
        Text = {
            CanNotBuild = {
                de = "Kann hier nicht gebaut werden!",
                en = "This can not be placed here!",
                fr = "Cela ne peut pas être placé ici!"
            },
            CanNotDemolish = {
                de = "Das kann nicht abgerissen werden!",
                en = "This can not be knocked down!",
                fr = "Cela ne peut pas être démoli!"
            }
        }
    }
}

-- Global ------------------------------------------------------------------- --

function ModuleConstructionControl.Global:OnGameStart()
    -- TODO: The dependency to the interface core module is fake news. This is
    -- just to justify the position in the load order. Maybe I itegrate this
    -- into the interface module later. For the time being this stays it's
    -- seperate module to not force the user to include something not needed.

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
end

function ModuleConstructionControl.Global:OnEvent(_ID, _Event, ...)
end

function ModuleConstructionControl.Global:GetNewRestrictionID()
    self.RestrictionSequence = self.RestrictionSequence +1;
    return self.RestrictionSequence;
end

function ModuleConstructionControl.Global:GetNewProtectionID()
    self.ProtectionSequence = self.ProtectionSequence +1;
    return self.ProtectionSequence;
end

function ModuleConstructionControl.Global:InsertRestriction(_PlayerID, _ID, _Type, _Data)
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
    self:SyncRestrictions();
    return _ID;
end

function ModuleConstructionControl.Global:InsertProtection(_PlayerID, _ID, _Type, _Data)
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
    self:SyncProtections();
    return _ID;
end

function ModuleConstructionControl.Global:DeleteRestriction(_ID)
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

function ModuleConstructionControl.Global:DeleteProtection(_ID)
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

function ModuleConstructionControl.Global:SyncRestrictions()
    for i= 1, 8 do
        local TableAsString = table.tostring(self.ConstructionRestrictions[i]);
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleConstructionControl.Local.ConstructionRestrictions[%d] = %s]],
            i, TableAsString
        ));
    end
end

function ModuleConstructionControl.Global:SyncProtections()
    for i= 1, 8 do
        local TableAsString = table.tostring(self.KnockdownProtection[i]);
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleConstructionControl.Local.KnockdownProtection[%d] = %s]],
            i, TableAsString
        ));
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleConstructionControl.Local:OnGameStart()
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

function ModuleConstructionControl.Local:OnEvent(_ID, _Event, ...)
end

function ModuleConstructionControl.Local:OverrideDeleteEntityStateBuilding()
    GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl = GameCallback_GUI_DeleteEntityStateBuilding;
    GameCallback_GUI_DeleteEntityStateBuilding = function(_BuildingID, _State)
        GameCallback_GUI_DeleteEntityStateBuilding_Orig_ConstructionControl(_BuildingID, _State);
        ModuleConstructionControl.Local:CheckCanKnockdownBuilding(_BuildingID, _State);
    end
end

function ModuleConstructionControl.Local:OverrideBuildButtonClicked()
    GUI_Construction.BuildClicked_Orig_ConstructionControl = GUI_Construction.BuildClicked;
    function GUI_Construction.BuildClicked(_BuildingType)
        ModuleConstructionControl.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildClicked_Orig_ConstructionControl(_BuildingType);
    end

    GUI_Construction.BuildStreetClicked_Orig_ConstructionControl = GUI_Construction.BuildStreetClicked;
    function GUI_Construction.BuildStreetClicked(_IsTrail)
        _IsTrail = (_IsTrail ~= nil and _IsTrail) or false;
        ModuleConstructionControl.Local.LastSelectedRoadType = _IsTrail;
        GUI_Construction.BuildStreetClicked_Orig_ConstructionControl(_IsTrail);
    end

    GUI_Construction.BuildWallClicked_Orig_ConstructionControl = GUI_Construction.BuildWallClicked;
    function GUI_Construction.BuildWallClicked(_BuildingType)
        if _BuildingType == nil then
            _BuildingType = GetUpgradeCategoryForClimatezone("WallSegment");
        end
        ModuleConstructionControl.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildWallClicked_Orig_ConstructionControl(_BuildingType);
    end

    GUI_Construction.BuildWallGateClicked_Orig_ConstructionControl = GUI_Construction.BuildWallGateClicked;
    function GUI_Construction.BuildWallGateClicked(_BuildingType)
        if _BuildingType == nil then
            _BuildingType = GetUpgradeCategoryForClimatezone("WallSegment");
        end
        ModuleConstructionControl.Local.LastSelectedBuildingType = _BuildingType;
        GUI_Construction.BuildWallGateClicked_Orig_ConstructionControl(_BuildingType);
    end
end

function ModuleConstructionControl.Local:OverridePlacementUpdate()
    GUI_Construction.PlacementUpdate_Orig_ConstructionControl = GUI_Construction.PlacementUpdate;
    function GUI_Construction.PlacementUpdate()
        ModuleConstructionControl.Local:CancleConstructionState(GUI.GetPlayerID());
        GUI_Construction.PlacementUpdate_Orig_ConstructionControl();
    end
end

function ModuleConstructionControl.Local:CancelState()
    API.Message(API.Localize(ModuleConstructionControl.Shared.Text.CanNotBuild));
    GUI.CancelState();
end

function ModuleConstructionControl.Local:CancelKnockdown(_EntityID)
    API.Message(API.Localize(ModuleConstructionControl.Shared.Text.CanNotDemolish));
    GUI.CancelBuildingKnockDown(_EntityID);
end

function ModuleConstructionControl.Local:CancleConstructionState(_PlayerID)
    if not self.ConstructionRestrictions[_PlayerID] then
        return;
    end
    local x,y = GUI.Debug_GetMapPositionUnderMouse();
    local Territory = Logic.GetTerritoryAtPosition(x or 1, y or 1);

    -- Check placing roads
    if g_Construction.CurrentPlacementType == 1 then
        -- Check custom function
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoRoadCustomFunction) do
            local Function = ModuleConstructionControl.Local:FindFunctionInTable(_G, v.Function);
            if Function and Function(_PlayerID, ModuleConstructionControl.Local.LastSelectedRoadType, x, y) then
                return self:CancelState();
            end
        end
        if ModuleConstructionControl.Local.LastSelectedRoadType then
            -- Check road in area
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoTrailInArea) do
                if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area then
                    return self:CancelState();
                end
            end
            -- Check road in territory
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoTrailInTerritory) do
                if Territory == v.Territory then
                    return self:CancelState();
                end
            end
        else
            -- Check street in area
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoStreetInArea) do
                if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area then
                    return self:CancelState();
                end
            end
            -- Check street in territory
            for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoStreetInTerritory) do
                if Territory == v.Territory then
                    return self:CancelState();
                end
            end
        end
    end

    -- Check placing buildings
    if g_Construction.CurrentPlacementType ~= 1 then
        local UpgradeCategory = ModuleConstructionControl.Local.LastSelectedBuildingType;
        local n, Type = Logic.GetBuildingTypesInUpgradeCategory(UpgradeCategory);
        local CategoryList = API.GetEntityTypeCategoyList(Type);

        -- Check custom function
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCustomFunction) do
            local Function = ModuleConstructionControl.Local:FindFunctionInTable(_G, v.Function);
            if Function and Function(_PlayerID, Type, x, y) then
                return self:CancelState();
            end
        end
        -- Check type in area
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructTypeInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and v.Type == Type then
                return self:CancelState();
            end
        end
        -- Check type in territory
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructTypeInTerritory) do
            if Territory == v.Territory and v.Type == Type then
                return self:CancelState();
            end
        end
        -- Check category in area
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCategoryInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and table.contains(CategoryList, v.Category) then
                return self:CancelState();
            end
        end
        -- Check category in territory
        for k, v in pairs(self.ConstructionRestrictions[_PlayerID].NoConstructCategoryInTerritory) do
            if Territory == v.Territory and table.contains(CategoryList, v.Category) then
                return self:CancelState();
            end
        end
    end
end

function ModuleConstructionControl.Local:CheckCanKnockdownBuilding(_BuildingID, _State)
    local PlayerID = Logic.EntityGetPlayer(_BuildingID);
    local x,y,z = Logic.EntityGetPos(_BuildingID);
    local ScriptName = Logic.GetEntityName(_BuildingID);
    local Territory = Logic.GetTerritoryAtPosition(x or 1, y or 1);
    local Type = Logic.GetEntityType(_BuildingID);
    local CategoryList = API.GetEntityTypeCategoyList(Type);

    if Logic.IsConstructionComplete(_BuildingID) == 0 then
        return;
    end
    if self.KnockdownProtection[PlayerID] then
        -- Check custom function
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCustomFunction) do
            local Function = ModuleConstructionControl.Local:FindFunctionInTable(_G, v.Function);
            if Function and Function(PlayerID, _BuildingID, x, y) then
                return self:CancelKnockdown(_BuildingID);
            end
        end
        -- Check scriptname
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownScriptName) do
            if ScriptName == v.ScriptName then
                return self:CancelKnockdown(_BuildingID);
            end
        end
        -- Check type in area
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownTypeInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and v.Type == Type then
                return self:CancelKnockdown(_BuildingID);
            end
        end
        -- Check type in territory
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownTypeInTerritory) do
            if Territory == v.Territory and v.Type == Type then
                return self:CancelKnockdown(_BuildingID);
            end
        end
        -- Check category in area
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCategoryInArea) do
            if API.GetDistance(v.Position, {X= x, Y= y}) <= v.Area and table.contains(CategoryList, v.Category) then
                return self:CancelKnockdown(_BuildingID);
            end
        end
        -- Check category in territory
        for k, v in pairs(self.KnockdownProtection[PlayerID].NoKnockdownCategoryInTerritory) do
            if Territory == v.Territory and table.contains(CategoryList, v.Category) then
                return self:CancelKnockdown(_BuildingID);
            end
        end
    end
end

-- Helper for finding function references when table path was used.
function ModuleConstructionControl.Local:FindFunctionInTable(_Ref, _String)
    if type(_Ref) == "table" and _String ~= nil then
        local Slices = string.slice(_String, "%.");
        for i= 1, #Slices do
            if type(_Ref) == "table" then
                _Ref = _Ref[Slices[i]];
            end
        end
    end
    return _Ref;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleConstructionControl);

