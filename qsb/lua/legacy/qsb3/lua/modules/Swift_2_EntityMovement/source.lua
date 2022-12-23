--[[
Swift_2_EntityMovement/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleEntityMovement = {
    Properties = {
        Name = "ModuleEntityMovement",
    },

    Global = {
        PathMovingEntities = {},
    };
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- -------------------------------------------------------------------------- --

function ModuleEntityMovement.Global:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");
end

function ModuleEntityMovement.Global:OnEvent(_ID, _Event, ...)
end

function ModuleEntityMovement.Global:FillMovingEntityDataForController(_Entity, _Path, _LookAt, _Action, _IgnoreBlocking)
    -- FIXME: Should we check that the moving entity isn't already involved in
    -- another task or should the user do some thinking on their own?
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

function ModuleEntityMovement.Local:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");
end

function ModuleEntityMovement.Local:OnEvent(_ID, _Name, ...)
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntityMovement);

