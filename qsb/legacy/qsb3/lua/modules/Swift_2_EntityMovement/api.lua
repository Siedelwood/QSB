--[[
Swift_2_EntityMovement/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ein Modul für die Bewegung von Entities.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) JobsCore</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntityArrived       Ein Entity hat das Ziel erreicht. (Parameter: EntityID, Position, DataIndex)
-- @field EntityStuck         Ein Entity kann das Ziel nicht erreichen. (Parameter: EntityID, Position, DataIndex)
-- @field EntityAtCheckpoint  Ein Entity hat einen Wegpunkt erreicht. (Parameter: EntityID, Position, DataIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Bewegt ein Entity zum Zielpunkt.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param               _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param               _Target         Ziel (Skriptname, ID oder Position)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntity(_Entity, _Target, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntity: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.MoveEntity: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.MoveEntity: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, nil, nil, _IgnoreBlocking
    );
    -- FIXME: This would create jobs that are only be paused at the end!
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity zum Zielpunkt und lässt es das Ziel anschauen.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param               _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param               _Target         Ziel (Skriptname, ID oder Position)
-- @param               _LookAt         Angeschaute Position (Skriptname, ID oder Position)
-- @param[type=boolean] _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndLookAt(_Entity, _Target, _LookAt, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntityAndLookAt: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.MoveEntityAndLookAt: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.MoveEntityAndLookAt: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, _LookAt, nil, _IgnoreBlocking
    );
    -- FIXME: This would create jobs that are only be paused at the end!
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity relativ zu einer Position.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Target         Ziel (Skriptname, ID oder Position)
-- @param[type=number]  _Distance        Entfernung zum Ziel
-- @param[type=number]  _Angle           Winkel zum Ziel
-- @within Anwenderfunktionen
--
function API.MoveEntityToPosition(_Entity, _Target, _Distance, _Angle, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntityToPosition: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.MoveEntityToPosition: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.MoveEntityToPosition: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    local Target = API.GetCirclePosition(_Target, _Distance, _Angle);
    if not API.IsValidPosition(Target) then
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {Target}, nil, nil, _IgnoreBlocking
    );
    -- FIXME: This would create jobs that are only be paused at the end!
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity zum Zielpunkt und führt die Funktion aus.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Target         Ziel (Skriptname, ID oder Position)
-- @param[type=function] _Action         Funktion wenn Entity ankommt
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityAndExecute(_Entity, _Target, _Action, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntityAndExecute: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.MoveEntityAndExecute: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.MoveEntityAndExecute: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, {_Target}, nil, _Action, _IgnoreBlocking
    );
    -- FIXME: This would create jobs that are only be paused at the end!
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Bewegt ein Entity über den angegebenen Pfad.
--
-- Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
-- Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.
--
-- Jedes Mal wenn das Entity einen Wegpunkt erreicht hat, wird das Event
-- QSB.ScriptEvents.EntityAtCheckpoint geworfen.
--
-- Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
-- wird das Event QSB.ScriptEvents.EntityArrived geworfen.
--
-- @param                _Entity         Bewegtes Entity (Skriptname oder ID)
-- @param                _Targets        Liste mit Wegpunkten
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Anwenderfunktionen
--
function API.MoveEntityOnCheckpoints(_Entity, _Targets, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntityOnCheckpoints: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Targets) ~= "table" then
        error("API.MoveEntityOnCheckpoints: target list must be a table!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, _Targets, nil, nil, _IgnoreBlocking
    );
    -- FIXME: This would create jobs that are only be paused at the end!
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

-- Even though this is no movement at all...

---
-- Positioniert ein Entity und lässt es einen Ort ansehen.
--
-- @param _Entity Bewegtes Entity (Skriptname oder ID)
-- @param _Target Ziel (Skriptname, ID oder Position)
-- @param _LookAt Angeschaute Position (Skriptname, ID oder Position)
-- @within Anwenderfunktionen
--
function API.PlaceEntityAndLookAt(_Entity, _Target, _LookAt)
    if not IsExisting(_Entity) then
        error("API.PlaceEntityAndLookAt: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.PlaceEntityAndLookAt: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.PlaceEntityAndLookAt: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    API.SetPosition(_Entity, _Target);
    API.LookAt(_Entity, _LookAt);
end

---
-- Positioniert ein Entity relativ zu einer Position.
--
-- @param               _Entity  Bewegtes Entity (Skriptname oder ID)
-- @param               _Target  Ziel (Skriptname, ID oder Position)
-- @param[type=number] _Distance Entfernung zum Ziel
-- @param[type=number] _Angle    Winkel zum Ziel
-- @within Anwenderfunktionen
--
function API.PlaceEntityToPosition(_Entity, _Target, _Distance, _Angle)
    if not IsExisting(_Entity) then
        error("API.PlaceEntityToPosition: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_Target) == "table" then
        if not API.IsValidPosition(_Target) then
            error("API.PlaceEntityToPosition: position '" ..tostring(_Target).. "' is invaid!");
            return;
        end
    else
        if not IsExisting(_Target) then
            error("API.PlaceEntityToPosition: entity '" ..tostring(_Target).. "' does not exist!");
            return;
        end
    end
    local Target = API.GetCirclePosition(_Target, _Distance, _Angle);
    if not API.IsValidPosition(Target) then
        return;
    end
    API.SetPosition(_Entity, Target);
end

