--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ArmyPath = {
    Current = 1,
    Waypoints = {},
};

function ArmyPath:New(...)
    local Path = table.copy(self);
    Path:Set(...);
    return Path;
end

function ArmyPath:GetCurrent()
    return self.Waypoints[self.Current];
end

function ArmyPath:Set(...)
    self:Reset();
    self.Waypoints = {};
    for i= 1, #arg do
        table.insert(self.Waypoints, arg[i]);
    end
end

function ArmyPath:Next()
    self.Current = self.Current +1;
end

function ArmyPath:Reset()
    self.Current = 1;
end

