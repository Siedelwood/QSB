--[[
Swift_2_EntitySearch/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.EntitySearch = {};

ModuleEntitySearch = {
    Properties = {
        Name = "ModuleEntitySearch",
    },

    Global = {},
    Local = {},
    Shared = {};
}

-- Global ------------------------------------------------------------------- --

function ModuleEntitySearch.Global:OnGameStart()
end

function ModuleEntitySearch.Global:OnEvent(_ID, _Event, ...)
end

-- Local -------------------------------------------------------------------- --

function ModuleEntitySearch.Local:OnGameStart()
end

function ModuleEntitySearch.Local:OnEvent(_ID, _Event, ...)
end

-- Shared ------------------------------------------------------------------- --

function ModuleEntitySearch.Shared:IterateEntities(...)
    -- Speichert die Predikate für spätere Prüfung.
    local Predicates = {};
    if arg[1] then
        for j= 1, #arg[1] do
            local Predicate = table.remove(arg[1][j], 1);
            table.insert(Predicates, {Predicate, arg[1][j]});
        end
    end

    -- Iteriert über alle Entities und wendet Predikate an.
    local ResultList = {};
    for _, v in pairs(Entities) do
        local AllEntitiesOfType = Logic.GetEntitiesOfType(v);
        for i= 1, #AllEntitiesOfType do
            local Select = true;
            for j= 1, #Predicates do
                if not Predicates[j][1](AllEntitiesOfType[i], unpack(Predicates[j][2])) then
                    Select = false;
                    break;
                end
            end
            if Select then
                table.insert(ResultList, AllEntitiesOfType[i]);
            end
        end
    end
    return ResultList;
end

-- Predicates --------------------------------------------------------------- --

QSB.SearchPredicate = {};

QSB.SearchPredicate.Custom = function(_ID, _Function, ...)
    return _Function(_ID, unpack(arg));
end

QSB.SearchPredicate.OfID = function(_ID, ...)
    for i= 1, #arg do
        if _ID == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.OfPlayer = function(_ID, ...)
    for i= 1, #arg do
        if Logic.EntityGetPlayer(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.OfName = function(_ID, ...)
    for i= 1, #arg do
        if Logic.GetEntityName(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.OfNamePrefix = function(_ID, ...)
    -- FIXME: Bad benchmark!
    local ScriptName = Logic.GetEntityName(_ID);
    for i= 1, #arg do
        if ScriptName and ScriptName ~= "" then
            if ScriptName:find("^" ..arg[i]) ~= nil then
                return true;
            end
        end
    end
    return false;
end

QSB.SearchPredicate.OfNameSuffix = function(_ID, ...)
    -- FIXME: Bad benchmark!
    local ScriptName = Logic.GetEntityName(_ID);
    for i= 1, #arg do
        if ScriptName and ScriptName ~= "" then
            if ScriptName:find(arg[i] .. "$") ~= nil then
                return true;
            end
        end
    end
    return false;
end

QSB.SearchPredicate.OfType = function(_ID, ...)
    for i= 1, #arg do
        if Logic.GetEntityType(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.OfCategory = function(_ID, ...)
    for i= 1, #arg do
        if Logic.IsEntityInCategory(_ID, arg[i]) == 1 then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.InArea = function(_ID, ...)
    -- FIXME: Bad benchmark!
    for i= 1, #arg, 3 do
        if API.GetDistance(_ID, {X= arg[i], Y= arg[i+1]}) <= arg[i+2] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.InTerritory = function(_ID, ...)
    for i= 1, #arg do
        if GetTerritoryUnderEntity(_ID) == arg[i] then
            return true;
        end
    end
    return false;
end

QSB.SearchPredicate.IsBuilding = function(_ID)
    return Logic.IsBuilding(_ID) == 1;
end

QSB.SearchPredicate.IsFinishedBuilding = function(_ID)
    return Logic.IsBuilding(_ID) == 1 and Logic.IsConstructionComplete(_ID) == 1;
end

QSB.SearchPredicate.IsSettler = function(_ID)
    return Logic.IsSettler(_ID) == 1;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntitySearch);

