--[[
Swift_5_SpeedLimitation/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erlaubt die maximale Beschleunigung des Spiels zu steuern.
--
-- @within Modulbeschreibung
-- @set sort=true
--

---
-- Setzt die Spielgeschwindigkeit auf Stufe 1 fest oder gibt sie wieder frei.
--
-- <b>Hinweis</b>: Die Geschwindigkeitsbeschränkung wirkt sich ebenfalls auf
-- Cheats aus. Es ist generell nicht mehr möglich, das Spiel zu beschleunigen,
-- wenn die "Speedbremse" aktiv ist.
--
-- @param[type=boolean] _Flag Speedbremse ist aktiv
-- @within Anwenderfunktionen
--
-- @usage
-- -- Geschwindigkeit auf Stufe 1 festsetzen
-- API.SpeedLimitActivate(true);
-- -- Geschwindigkeit freigeben
-- API.SpeedLimitActivate(false);
--
function API.SpeedLimitActivate(_Flag)
    if GUI or Framework.IsNetworkGame() then
        return;
    end
    return Logic.ExecuteInLuaLocalState("ModuleSpeedLimitation.Local:ActivateSpeedLimit(" ..tostring(_Flag).. ")");
end

