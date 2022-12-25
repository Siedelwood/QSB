--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermoglicht die Bewegung von Entities und Berechnung von Pfaden.
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
-- @field EntityArrived       Ein Entity hat das Ziel erreicht. (Parameter: EntityID, Position, DataIndex)
-- @field EntityStuck         Ein Entity kann das Ziel nicht erreichen. (Parameter: EntityID, Position, DataIndex)
-- @field EntityAtCheckpoint  Ein Entity hat einen Wegpunkt erreicht. (Parameter: EntityID, Position, DataIndex)
-- @field PathFindingFinished Ein Pfad wurde erfolgreich gefunden (Parameter: PathID)
-- @field PathFindingFailed   Ein Pfad konnte nicht ermittelt werden (Parameter: PathID)
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
-- @within Bewegung
--
-- @usage
-- -- Beispiel #1: Normale Bewegung
-- API.MoveEntity("Marcus", "Target");
--
-- @usage
-- -- Beispiel #2: Schiff bewegen
-- API.MoveEntity("Ship", "Harbor", true);
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
-- @within Bewegung
--
-- @usage
-- API.MoveEntityAndLookAt("Marcus", "Target", "Alandra");
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
-- @within Bewegung
--
-- @usage
-- API.MoveEntityToPosition("Marcus", "Target", 1000, 90);
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
-- @within Bewegung
--
-- @usage
-- API.MoveEntityAndExecute("Marcus", "Target", function()
--     Logic.DEBUG_AddNote("Marcus ist angekommen!");
-- end);
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
-- @param                _WaypointList   Liste mit Wegpunkten
-- @param[type=boolean]  _IgnoreBlocking Direkten Weg benutzen
-- @within Bewegung
--
-- @usage
-- API.MoveEntityOnCheckpoints("Marcus", {"WP1", "WP2", "WP3", "Target"});
--
function API.MoveEntityOnCheckpoints(_Entity, _WaypointList, _IgnoreBlocking)
    if not IsExisting(_Entity) then
        error("API.MoveEntityOnCheckpoints: entity '" ..tostring(_Entity).. "' does not exist!");
        return;
    end
    if type(_WaypointList) ~= "table" then
        error("API.MoveEntityOnCheckpoints: target list must be a table!");
        return;
    end
    local Index = ModuleEntityMovement.Global:FillMovingEntityDataForController(
        _Entity, _WaypointList, nil, nil, _IgnoreBlocking
    );
    API.StartHiResJob(function(_Index)
        return ModuleEntityMovement.Global:MoveEntityPathController(_Index);
    end, Index);
    return Index;
end

---
-- Positioniert ein Entity und lässt es einen Ort ansehen.
--
-- @param _Entity Bewegtes Entity (Skriptname oder ID)
-- @param _Target Ziel (Skriptname, ID oder Position)
-- @param _LookAt Angeschaute Position (Skriptname, ID oder Position)
-- @within Bewegung
--
-- @usage
-- API.PlaceEntityAndLookAt("Marcus", "Target", "Alandra");
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
-- @within Bewegung
--
-- @usage
-- API.PlaceEntityAndLookAt("Marcus", "Target", 1000, 90);
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

---
-- Beginnt die Wegsuche zwischen zwei Punkten.
--
-- Der Pfad wird nicht sofort zurückgegeben. Stattdessen eine ID. Der Pfad wird
-- asynchron gesucht, damit das Spiel nicht einfriert. Wenn die Pfadsuche
-- abgeschlossen wird, werden entsprechende Events ausgelöst.
--
-- <ul>
-- <li><b>QSB.ScriptEvents.PathFindingFinished</b><br/>
-- Ein Pfad zwischen den Punkten wurde gefunden.</li>
-- <li><b>QSB.ScriptEvents.PathFindingFailed</b><br/>
-- Es konnte kein Pfad gefunden werden.</li>
-- </ul>
--
-- Wird der Node Filter weggelassen, wird automatisch eine Funktion erstellt,
-- die alle Positionen ausschließt, die geblockt sind.
--
-- @param                _StartPosition Beginn des Pfad (Position, Skriptname oder ID)
-- @param                _EndPosition   Ende des Pfad (Position, Skriptname oder ID)
-- @param[type=function] _NodeFilter    (Optional) Filterfunktion für Wegpunkte
-- @retun[type=number] ID des Pfad
-- @within Pfadsuche
--
-- @usage
-- -- Beispiel #1: Standard Wegsuche
-- MyPathID = API.StartPathfinding("Start", "End");
--
-- @usage
-- -- Beispiel #2: Wegsuche mit Filter
-- MyPathID = API.StartPathfinding("Start", "End", function(_CurrentNode, _AdjacentNodes)
--     -- Position verwerfen, wenn sie im Blocking ist
--     if Logic.DEBUG_GetSectorAtPosition(_CurrentNode.X, _CurrentNode.Y) == 0 then
--         return false;
--     end
--     -- Position verwerfen, wenn sie auf Territorium 16 liegt
--     if Logic.GetTerritoryAtPosition(_CurrentNode.X, _CurrentNode.Y) == 16 then
--         return false;
--     end
--     -- Position akzeptieren
--     return true;
-- end);
--
function API.StartPathfinding(_StartPosition, _EndPosition, _NodeFilter)
    if type(_StartPosition) ~= "table" then
        _StartPosition = API.GetPosition(_StartPosition);
    end
    if type(_EndPosition) ~= "table" then
        _EndPosition = API.GetPosition(_EndPosition);
    end

    _NodeFilter = _NodeFilter or function(_CurrentNode, _AdjacentNodes)
        if Logic.DEBUG_GetSectorAtPosition(_CurrentNode.X, _CurrentNode.Y) == 0 then
            return false;
        end
        return true;
    end
    if type(_NodeFilter) ~= "function" then
        error("API.StartPathfinding: node filter must be a function!");
        return;
    end
    return ModuleEntityMovement.Global.PathFinder:Insert(
        _EndPosition, _StartPosition, 750, 3, _NodeFilter
    );
end

---
-- Prüft ob ein Pfad mit der ID existiert.
--
-- @param[type=number]  _ID ID des Pfad
-- @retun[type=boolean] Der Pfad existiert
-- @within Pfadsuche
--
-- @usage
-- if API.IsPathExisting(MyPathID) then
--     -- Mach was
-- end
--
function API.IsPathExisting(_ID)
    return ModuleEntityMovement.Global.PathFinder:IsPathExisting(_ID);
end

---
-- Prüft ob ein Pfad mit der ID noch gesucht wird.
--
-- @param[type=number]  _ID ID des Pfad
-- @retun[type=boolean] Der Pfad wird gesucht
-- @within Pfadsuche
--
-- @usage
-- if API.IsPathBeingCalculated(MyPathID) then
--     -- Mach was
-- end
--
function API.IsPathBeingCalculated(_ID)
    return ModuleEntityMovement.Global.PathFinder:IsPathStillCalculated(_ID);
end

---
-- Gibt den Pfad mit der ID als Liste von Entity-IDs zurück.
--
-- @param[type=number]  _ID ID des Pfad
-- @retun[type=table] Liste mit IDs
-- @within Pfadsuche
--
-- @usage
-- WaypointList = API.RetrievePath(MyPathID);
--
function API.RetrievePath(_ID)
    if not API.IsPathExisting(_ID) then
        error("API.StartPathfinding: no path is existing for id " .._ID.. "!");
        return;
    end
    if API.IsPathBeingCalculated(_ID) then
        error("API.StartPathfinding: the path " .._ID.. " is still being calculated!");
        return;
    end
    local Path = ModuleEntityMovement.Global.PathFinder:GetPath(_ID);
    return Path:Reduce(5):Convert();
end

