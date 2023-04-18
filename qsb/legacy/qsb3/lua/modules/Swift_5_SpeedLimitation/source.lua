--[[
Swift_5_SpeedLimitation/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleSpeedLimitation = {
    Properties = {
        Name = "ModuleSpeedLimitation",
    },

    Global = {},
    Local = {
        SpeedLimit = 1,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleSpeedLimitation.Global:OnGameStart()
end

-- Local Script ----------------------------------------------------------------

function ModuleSpeedLimitation.Local:OnGameStart()
    self:InitForbidSpeedUp();
end

function ModuleSpeedLimitation.Local:SetSpeedLimit(_Limit)
    if Framework.IsNetworkGame() then
        info("ModuleSpeedLimitation: Detect network game. Aborting!");
        return;
    end
    _Limit = (_Limit < 1 and 1) or math.floor(_Limit);
    info("ModuleSpeedLimitation: Setting speed limit to " .._Limit);
    self.SpeedLimit = _Limit;
end

function ModuleSpeedLimitation.Local:ActivateSpeedLimit(_Flag)
    if Framework.IsNetworkGame() then
        info("ModuleSpeedLimitation: Detect network game. Aborting!");
        return;
    end
    self.UseSpeedLimit = _Flag == true;
    if _Flag and Game.GameTimeGetFactor(GUI.GetPlayerID()) > self.SpeedLimit then
        info("ModuleSpeedLimitation: Speed is capped at " ..self.SpeedLimit);
        Game.GameTimeSetFactor(GUI.GetPlayerID(), self.SpeedLimit);
    end
end

function ModuleSpeedLimitation.Local:InitForbidSpeedUp()
    GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function( _Speed )
        GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp( _Speed );
        if ModuleSpeedLimitation.Local.UseSpeedLimit == true then
            info("ModuleSpeedLimitation: Checking speed limit.");
            if _Speed > ModuleSpeedLimitation.Local.SpeedLimit then
                info("ModuleSpeedLimitation: Speed is capped at " ..tostring(_Speed).. ".");
                Game.GameTimeSetFactor(GUI.GetPlayerID(), ModuleSpeedLimitation.Local.SpeedLimit);
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleSpeedLimitation);

