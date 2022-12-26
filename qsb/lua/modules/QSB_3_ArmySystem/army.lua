--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

TWA.Army = {
    ID = 0,
    PlayerID = 0,
    IsReady = false,
    HomePosition = nil,
    Anchor = nil,
    Path = nil,

    Commands = {};
};

function TWA.Army:New(_PlayerID, _HomePosition)
    local ArmyID = AICore.CreateArmy(_PlayerID);
    local Army = table.copy(self);
    Army.PlayerID = _PlayerID;
    Army.ID = ArmyID;
    Army.HomePosition = _HomePosition;
    return Army;
end

function TWA.Army:Dispose()
    self.State = QSB.ArmyState.Idle;
    AICore.DisbandUnusedArmy(self.PlayerID, self.ID);
end

function TWA.Army:SetReady(_Flag)
    self.IsReady = _Flag == true;
end

-- -------------------------------------------------------------------------- --

function TWA.Army:GetAnchor()
    if self.Anchor then
        return API.GetPosition(self.Anchor);
    end
    return self:GetPosition();
end

function TWA.Army:SetAnchor(_Position)
    self.Anchor = _Position;
end

function TWA.Army:GetPosition()
    local MemberList = AICore.GetArmyMembers(self.PlayerID, self.ID);
    if #MemberList > 0 then
        return API.GetGeometricFocus(unpack(MemberList));
    end
    return API.GetPosition(self.HomePosition);
end

-- -------------------------------------------------------------------------- --

-- TODO: Walk in formation
function TWA.Army:Move(_Position)
    local Position = API.GetPosition(_Position);
    local MemberList = AICore.GetArmyMembers(self.PlayerID, self.ID);
    for i= 1, #MemberList do
        Logic.MoveSettler(MemberList[i], Position.X, Position.Y, -1);
    end
end

function TWA.Army:SetPath(_Path)
    self.Path = _Path;
end

function TWA.Army:AddCommand(_Command, _Looped, _Index)
    if _Index then
        table.insert(self.Commands, _Index, {_Command, _Looped});
        return;
    end
    table.insert(self.Commands, {_Command, _Looped});
end

function TWA.Army:RemoveCommand(_Index)
    if _Index then
        return table.remove(self.Commands, _Index);
    end
    return table.remove(self.Commands, 1);
end

-- -------------------------------------------------------------------------- --

function TWA.Army:IsFighting()
    local MemberList = AICore.GetArmyMembers(self.PlayerID, self.ID);
    for i= 1, #MemberList do
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(MemberList[i])};
        if Soldiers[1] > 0 and Logic.IsFighting(Soldiers[2]) then
            return true;
        end
    end
    return false;
end

function TWA.Army:IsMoving()
    local MemberList = AICore.GetArmyMembers(self.PlayerID, self.ID);
    for i= 1, #MemberList do
        if Logic.IsEntityMoving(MemberList[i]) then
            return true;
        end
    end
    return false;
end

function TWA.Army:IsAlive()
    if not self.IsReady then
        return true;
    end
    local MemberList = AICore.GetArmyMembers(self.PlayerID, self.ID);
    if #MemberList > 0 then
        return true;
    end
    return false;
end

