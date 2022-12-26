--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

TWA.ArmyCommand = {};

-- -------------------------------------------------------------------------- --
-- Command Idle
-- The army is doing nothing.

function TWA.ArmyCommand.Idle(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command Walk
-- The army is walking on its waypoints to the target.

function TWA.ArmyCommand.Walk(_Army)
    if _Army.Path then
        local Waypoint = _Army.Path:GetCurrent();
        if not Waypoint then
            _Army.Path:Reset();
            return true;
        end

        if API.GetDistance(Waypoint, _Army:GetAnchor()) <= 1000 then
            _Army.Path:Next();
        else
            if not _Army:IsMoving() then
                _Army:Move(Waypoint);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Command Defend
-- The army stopps and is defending against enemies.

function TWA.ArmyCommand.Defend(_Army)
    local Position = _Army:GetAnchor();
    local Targets = {Logic.GetPlayerEntitiesInArea(
        _Army.PlayerID,
        Entities.U_MilitaryLeader,
        Position.X, Position.X,
        2500,
        1
    )};

    if Targets[1] > 0 then
        if not _Army:IsFighting() then
            local x, y, z = Logic.EntityGetPos(Targets[2]);
            for i= 1, #_Army.Troops do
                Logic.GroupAttackMove(_Army.Troops[i], x, y,-1);
            end
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command Raid
-- The army tries to inflict as many damage as possible at its location.

function TWA.ArmyCommand.Raid(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command Claim
-- The army tries to conquer the territory by taking the outpost.

function TWA.ArmyCommand.Claim(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command DestroyOutpost
-- The army tries to destroy all buildings on the claimed territory.

function TWA.ArmyCommand.DestroyOutpost(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command DestroyCity
-- The army tries to destroy the storehouse at the territory.

function TWA.ArmyCommand.DestroyCity(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command AttackWall
-- The army uses war machines to attack the closest walls.

function TWA.ArmyCommand.AttackWall(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command AttackCatapult
-- The army uses catapults to attack wall catapults.

function TWA.ArmyCommand.AttackCatapult(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command Errect
-- The army is assembling the war machines.

function TWA.ArmyCommand.Errect(_Army)
    return true;
end

-- -------------------------------------------------------------------------- --
-- Command Disassemble
-- The army is disassembling the war machines.

function TWA.ArmyCommand.Disassemble(_Army)

end

