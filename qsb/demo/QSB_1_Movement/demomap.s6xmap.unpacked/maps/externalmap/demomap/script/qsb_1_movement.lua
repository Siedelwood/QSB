--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleEntityMovement = {
    Properties = {
        Name = "ModuleEntityMovement",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        PathMovingEntities = {},
    };
    Local = {},

    Shared = {},
};

-- -------------------------------------------------------------------------- --
-- Global Script

function ModuleEntityMovement.Global:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");
    QSB.ScriptEvents.PathFindingFinished = API.RegisterScriptEvent("Event_PathFindingFinished");
    QSB.ScriptEvents.PathFindingFailed = API.RegisterScriptEvent("Event_PathFindingFailed");

    API.StartHiResJob(function()
        ModuleEntityMovement.Global.PathFinder:Controller();
    end);
end

function ModuleEntityMovement.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleEntityMovement.Global:FillMovingEntityDataForController(_Entity, _Path, _LookAt, _Action, _IgnoreBlocking)
    -- FIXME: Should we check that the entity isn't already processed?
    local Index = #self.PathMovingEntities +1;
    self.PathMovingEntities[Index] = {
        Entity = GetID(_Entity),
        IgnoreBlocking = _IgnoreBlocking == true,
        LookAt = _LookAt,
        Callback = _Action,
        Index = 0
    };
    for i= 1, #_Path do
        table.insert(self.PathMovingEntities[Index], _Path[i]);
    end
    return Index;
end

function ModuleEntityMovement.Global:MoveEntityPathController(_Index)
    local Data = self.PathMovingEntities[_Index];

    local CanMove = true;
    if not IsExisting(Data.Entity) then
        CanMove = false;
    end

    if CanMove and Logic.IsEntityMoving(Data.Entity) == false then
        -- Arrived at waypoint
        if Data.Index > 0 then
            API.SendScriptEvent(QSB.ScriptEvents.EntityAtCheckpoint, Data.Entity, Data[Data.Index], _Index);
            local Target = tostring(Data[Data.Index]);
            if type(Data[Data.Index]) == "table" then
                Target = table.tostring(Data[Data.Index]);
            end
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.EntityAtCheckpoint, %d, %s, %d)]],
                Data.Entity, Target, _Index
            ));
        end
        self.PathMovingEntities[_Index].Index = Data.Index +1;

        -- Check entity arrived
        if #Data < Data.Index then
            if  Logic.IsSettler(Data.Entity) == 1
            and Logic.GetEntityType(Data.Entity) ~= Entities.D_X_TradeShip then
                Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_IDLE);
                if Data.LookAt then
                    API.LookAt(Data.Entity, Data.LookAt);
                end
                if Data.Callback then
                    Data:Callback();
                end
            end
            -- The event is send when the task is fully completed. That means
            -- look at and callback must be executed first!
            API.SendScriptEvent(QSB.ScriptEvents.EntityArrived, Data.Entity, Data[#Data], _Index);
            local Target = tostring(Data[#Data]);
            if type(Data[#Data]) == "table" then
                Target = table.tostring(Data[#Data]);
            end
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.EntityArrived, %d, %s, %d)]],
                Data.Entity, Target, _Index
            ));
            return true;
        end

        -- Check reachablility
        local x1,y1,z1 = Logic.EntityGetPos(Data.Entity);
        local x2,y2,z2;
        if type(Data[Data.Index]) == "table" then
            x2 = Data[Data.Index].X;
            y2 = Data[Data.Index].Y;
        else
            x2,y2,z2 = Logic.EntityGetPos(GetID(Data[Data.Index]));
        end
        local PlayerID = Logic.EntityGetPlayer(Data.Entity);
        local SectorType = Logic.GetEntityPlayerSectorType(Data.Entity);
        local Sector1 = Logic.GetPlayerSectorID(PlayerID, SectorType, x1, y1);
        local Sector2 = Logic.GetPlayerSectorID(PlayerID, SectorType, x2, y2);
        if Sector1 ~= Sector2 then
            if Logic.IsSettler(Data.Entity) == 1 then
                Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_IDLE);
            end
            CanMove = false;
        end

        -- Move entity
        if CanMove then
            if Data.IgnoreBlocking then
                if  Logic.IsSettler(Data.Entity) == 1
                and Logic.GetEntityType(Data.Entity) ~= Entities.D_X_TradeShip then
                    Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_WALK);
                end
                Logic.MoveEntity(Data.Entity, x2, y2);
            else
                Logic.MoveSettler(Data.Entity, x2, y2);
            end
        end
    end

    -- Send movement failed event
    if not CanMove then
        API.SendScriptEvent(QSB.ScriptEvents.EntityStuck, Data.Entity, Data[Data.Index], _Index);
        local Target = tostring(Data[Data.Index]);
        if type(Data[Data.Index]) == "table" then
            Target = table.tostring(Data[Data.Index]);
        end
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.EntityStuck, %d, %s, %d)]],
            Data.Entity, Target, _Index
        ));
        return true;
    end
end

-- -------------------------------------------------------------------------- --
-- Pathfinder Class

ModuleEntityMovement.Global.PathFinder = {
    NodeDistance = 300;
    StepsPerTurn = 1;

    PathSequence = 0;
    PathList = {};
    ProcessedPaths = {};
}

function ModuleEntityMovement.Global.PathFinder:Insert(_Start, _End, _NodeDistance, _StepsPerTick, _Filter, ...)
    local Start = self:GetClosestPositionOnNodeMap(_Start, _NodeDistance);
    if not Start then
        return 0;
    end
    local End = self:GetClosestPositionOnNodeMap(_End, _NodeDistance);
    if not _End then
        return 0;
    end

    self.PathSequence = self.PathSequence +1;
    self.ProcessedPaths[self.PathSequence] = {
        NodeDistance = _NodeDistance or 300,
        StepsPerTick = _StepsPerTick or 1,
        StartNode = Start,
        TargetNode = End,
        Suspended = false,
        Closed = {},
        ClosedMap = {},
        Open = {},
        OpenMap = {};
        AcceptMethode = _Filter,
        AcceptArgs = arg,
    };

    Start.ID = "ID_"..Start.X.."_"..Start.Y;
    table.insert(self.ProcessedPaths[self.PathSequence].Open, 1, Start);
    self.ProcessedPaths[self.PathSequence].OpenMap[Start.ID] = true;

    return self.PathSequence;
end

function ModuleEntityMovement.Global.PathFinder:Controller()
    for k, v in pairs(self.ProcessedPaths) do
        if v.Suspended == false then
            self:Step(k);
        end
    end
end

function ModuleEntityMovement.Global.PathFinder:SendPathingSucceedEvent(_Index)
    API.SendScriptEvent(QSB.ScriptEvents.PathFindingFinished, _Index);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.PathFindingFinished, %d)]],
        _Index
    ));
end

function ModuleEntityMovement.Global.PathFinder:SendPathingFailedEvent(_Index)
    API.SendScriptEvent(QSB.ScriptEvents.PathFindingFailed, _Index);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.PathFindingFailed, %d)]],
        _Index
    ))
end

function ModuleEntityMovement.Global.PathFinder:SetSuspended(_ID, _Flag)
    if self.ProcessedPaths[_ID] then
        self.ProcessedPaths[_ID].Suspended = _Flag == true;
    end
end

function ModuleEntityMovement.Global.PathFinder:Step(_Index)
    if not self.ProcessedPaths[_Index] then
        self.ProcessedPaths[_Index] = nil;
        self.PathList[_Index] = nil;
        self:SendPathingFailedEvent(_Index);
        return true;
    end
    for i= 1, self.ProcessedPaths[_Index].StepsPerTick, 1 do
        if #self.ProcessedPaths[_Index].Open == 0 then
            self.ProcessedPaths[_Index] = nil;
            self.PathList[_Index] = nil;
            self:SendPathingFailedEvent(_Index);
            return true;
        end
        local removed = table.remove(self.ProcessedPaths[_Index].Open, 1);
        self.ProcessedPaths[_Index].OpenMap[removed.ID] = nil;
        if  removed.X == self.ProcessedPaths[_Index].TargetNode.X
        and removed.Y == self.ProcessedPaths[_Index].TargetNode.Y then
            local LastNode = removed;
            local path = {}
            local prev = LastNode;
            while (prev) do
                table.insert(path, prev);
                local tmp = LastNode.Father;
                LastNode = prev;
                prev = self:GetNodeByID(_Index, tmp);
                if not prev.Father then
                    table.insert(path, prev);
                    break;
                end
            end
            self.PathList[_Index] = ModuleEntityMovement.Global.PathModel:New(path);
            self.ProcessedPaths[_Index] = nil;
            self:SendPathingSucceedEvent(_Index);
            return true;
        else
            self:Expand(_Index, removed);
        end
    end
    return false;
end

function ModuleEntityMovement.Global.PathFinder:Expand(_Index, _Node)
    local x = _Node.X;
    local y = _Node.Y;

    -- Regular nodes
    local FatherNodeID = _Node.ID;
    local SuccessorNodes = {};
    local Distance = self.ProcessedPaths[_Index].NodeDistance;
    for i= x-Distance, x+Distance, Distance do
        for j= y-Distance, y+Distance, Distance do
            if not (i == x and j == y) then
                if  not self.ProcessedPaths[_Index].OpenMap["ID_"..i.."_"..j] 
                and not self.ProcessedPaths[_Index].ClosedMap["ID_"..i.."_"..j] then
                    -- Insert node
                    table.insert(SuccessorNodes, {
                        ID = "ID_"..i.."_"..j,
                        X = i,
                        Y = j,
                        Father = FatherNodeID,
                        Distance1 = API.GetDistance(_Node, self.ProcessedPaths[_Index].TargetNode),
                        Distance2 = API.GetDistance(self.ProcessedPaths[_Index].StartNode, _Node)
                    });
                end
            end
        end
    end

    -- Check successor nodes and put into open list
    self:AcceptSuccessors(_Index, SuccessorNodes);
    -- Sort open list
    self:SortOpenList(_Index);
    -- Insert current node to closed list
    table.insert(self.ProcessedPaths[_Index].Closed, _Node);
    self.ProcessedPaths[_Index].OpenMap[_Node.ID] = true;
end

function ModuleEntityMovement.Global.PathFinder:AcceptSuccessors(_Index, _SuccessorList)
    local SuccessorList = {};
    for k,v in pairs(_SuccessorList) do
        if not self.ProcessedPaths[_Index].ClosedMap["ID_"..v.X.."_"..v.Y] then
            if not self.ProcessedPaths[_Index].OpenMap["ID_"..v.X.."_"..v.Y] then
                table.insert(SuccessorList, v);
            end
        end
    end
    for k,v in pairs(SuccessorList) do
        local useNode = true;
        if self.ProcessedPaths[_Index].AcceptMethode then
            useNode = useNode and self.ProcessedPaths[_Index].AcceptMethode(
                v, SuccessorList, unpack(self.ProcessedPaths[_Index].AcceptArgs)
            );
        end
        if useNode then
            table.insert(self.ProcessedPaths[_Index].Open, v);
            self.ProcessedPaths[_Index].OpenMap[v.ID] = true;
            -- Make visible (debug only)
            -- Logic.CreateEntity(Entities.XD_CoordinateEntity, v.X, v.Y, 0, 0);
        end
    end
end

function ModuleEntityMovement.Global.PathFinder:SortOpenList(_Index)
    local comp = function(v,w)
        return v.Distance1 < w.Distance1 and v.Distance2 < w.Distance2;
    end
    table.sort(self.ProcessedPaths[_Index].Open, comp);
end

function ModuleEntityMovement.Global.PathFinder:GetClosestPositionOnNodeMap(_Position, _NodeDistance)
    if type(_Position) ~= "table" then
        _Position = API.GetPosition(_Position);
    end
    local Distance = _NodeDistance;
    local X = math.floor(_Position.X + 0.5);
    local XMod = (X % Distance);
    local bx = (XMod > Distance/2 and (X + (Distance - XMod))) or X - XMod;
    local Y = math.floor(_Position.Y + 0.5);
    local YMod = (Y % Distance);
    local by = (YMod > Distance/2 and (Y + (Distance - YMod))) or Y - YMod;
    return {X= bx, Y= by};
end

function ModuleEntityMovement.Global.PathFinder:GetNodeByID(_Index, _ID)
    local node;
    for i=1, #self.ProcessedPaths[_Index].Closed do
        if self.ProcessedPaths[_Index].Closed[i].ID == _ID then
            node = self.ProcessedPaths[_Index].Closed[i];
        end
    end
    return node;
end

function ModuleEntityMovement.Global.PathFinder:IsPathExisting(_ID)
    return self.PathList[_ID] ~= nil;
end

function ModuleEntityMovement.Global.PathFinder:IsPathStillCalculated(_ID)
    return self.ProcessedPaths[_ID] ~= nil;
end

function ModuleEntityMovement.Global.PathFinder:GetPath(_ID)
    if self:IsPathExisting(_ID) then
        return table.copy(self.PathList[_ID]);
    end
end

-- -------------------------------------------------------------------------- --
-- Path Model Class

ModuleEntityMovement.Global.PathModel = {
    Nodes = {};
};

function ModuleEntityMovement.Global.PathModel:New(_Nodes)
    local Instance = table.copy(self);
    Instance.Nodes = _Nodes;
    return Instance;
end

function ModuleEntityMovement.Global.PathModel:FromList(_List)
    local path = ModuleEntityMovement.Global.PathModel:New({});
    local father = nil;

    local Start = _List[1];
    local End   = _List[#_List];

    for i= 1, #_List, 1 do
        local ID = GetID(_List[i]);
        local x,y,z = Logic.EntityGetPos(ID);
        table.insert(path.Nodes, {
            ID        = "ID_" ..ID,
            Marker    = 0,
            Father    = father,
            Visited   = false,
            X         = x,
            Y         = y,
            Distance1 = API.GetDistance(ID, End),
            Distance2 = API.GetDistance(Start, ID),
        });
        father = "ID_" ..ID;
    end
    return path;
end

function ModuleEntityMovement.Global.PathModel:AddNode(_Node)
    local n = #self.Nodes;
    if n > 1 then
        _Node.Father = self.Nodes[n-1].ID;
    else
        _Node.Father = nil;
    end
    table.insert(self.Nodes, _Node);
end

function ModuleEntityMovement.Global.PathModel:Merge(_Other)
    if _Other and #_Other.Nodes > 0 and #self.Nodes > 0 then
        _Other.Nodes[1].Father = self.Nodes[#self.Nodes].ID;
        for i= 1, #_Other.Nodes, 1 do
            table.insert(self.Nodes, _Other.Nodes[i]);
        end
    end
end

function ModuleEntityMovement.Global.PathModel:Reduce(_By)
    local Reduced = table.copy(self);
    local n = #Reduced.Nodes;
    for i= n, 1, -1 do
        if i ~= 1 and i ~= n and i % _By ~= 0 then
            Reduced.Nodes[i+1].Father = Reduced.Nodes[i-1].Father;
            table.remove(Reduced.Nodes, i);
        end
    end
    return Reduced;
end

function ModuleEntityMovement.Global.PathModel:Reset()
    for k,v in pairs(self.Nodes) do
        self.Nodes[k].Visited = false;
    end
end

function ModuleEntityMovement.Global.PathModel:Reverse()
    return ModuleEntityMovement.Global.PathModel:New(table.invert(self.Nodes));
end

function ModuleEntityMovement.Global.PathModel:Next()
    local Node, ID = self:GetCurrentWaypoint();
    if Node then
        self.Nodes[ID].Visited = true;
    end
end

function ModuleEntityMovement.Global.PathModel:GetCurrentWaypoint()
    local lastWP;
    local id = 1;
    repeat
        lastWP = self.Nodes[id];
        id = id +1;
    until ((not self.Nodes[id]) or self.Nodes[id].Visited == false);
    if not self.Nodes[id] then
        id = id -1;
    end
    return lastWP, id;
end

function ModuleEntityMovement.Global.PathModel:Convert()
    if #self.Nodes > 0 then
        local nodes = {};
        for i=1, #self.Nodes do
            local eID = Logic.CreateEntity(
                Entities.XD_ScriptEntity,
                self.Nodes[i].X,
                self.Nodes[i].Y,
                0,
                0
            );
            table.insert(nodes, eID);
        end
        return nodes;
    end
end

function ModuleEntityMovement.Global.PathModel:Show()
    if #self.Nodes > 0 then
        for i=1, #self.Nodes do
            local ID = Logic.CreateEntity(
                Entities.XD_ScriptEntity,
                self.Nodes[i].X,
                self.Nodes[i].Y,
                0,
                0
            );
            Logic.SetModel(ID, Models.Doodads_D_X_Flag);
            Logic.SetVisible(ID, true);
            self.Nodes[i].Marker = ID;
        end
    end
end

function ModuleEntityMovement.Global.PathModel:Hide()
    for k, v in pairs(self.Nodes) do
        DestroyEntity(v.Marker);
        self.Nodes[k].Marker = 0;
    end
end

-- -------------------------------------------------------------------------- --
-- Local Script

function ModuleEntityMovement.Local:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");
    QSB.ScriptEvents.PathFindingFinished = API.RegisterScriptEvent("Event_PathFindingFinished");
    QSB.ScriptEvents.PathFindingFailed = API.RegisterScriptEvent("Event_PathFindingFailed");
end

function ModuleEntityMovement.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleEntityMovement);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ein Modul für die Bewegung von Entities.
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

