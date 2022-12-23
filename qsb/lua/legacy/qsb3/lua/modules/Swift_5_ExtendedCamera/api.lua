--[[
Swift_5_ExtendedCamera/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Verwendung des absoluten Zoom Limit.
--
-- Als Konsequenz wird die Entfernung, die maximal herausgezoomt werden kann,
-- erweitert, bis zur fas völligen Draufsicht. Dies kann nütztlich sein, wenn
-- der Spieler ein größeres Sichtfeld benötigt.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert den Hotkey zum Wechsel zwischen normalen und erweiterten Zoom.
--
-- @param[type=boolean] _Flag Erweiterter Zoom gestattet
-- @within Anwenderfunktionen
--
-- @usage
-- -- Erweitere Kamera einschalten
-- API.AllowExtendedZoom(true);
-- -- Erweitere Kamera abschalten
-- API.AllowExtendedZoom(false);
--
function API.AllowExtendedZoom(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.AllowExtendedZoom(%s)]],
            tostring(_Flag)
        ))
        return;
    end
    ModuleExtendedCamera.Local.ExtendedZoomAllowed = _Flag == true;
    if _Flag == true then
        ModuleExtendedCamera.Local:RegisterExtendedZoomHotkey();
    else
        ModuleExtendedCamera.Local:UnregisterExtendedZoomHotkey();
        ModuleExtendedCamera.Local:DeactivateExtendedZoom();
    end
end

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- @param[type=number] _Player Partei
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
-- @usage
-- -- Zentriert die Kamera über den Helden von Spieler 3.
-- API.FocusCameraOnKnight(3, 90, 0.5);
--
function API.FocusCameraOnKnight(_Player, _Rotation, _ZoomFactor)
    API.FocusCameraOnEntity(Logic.GetKnightID(_Player), _Rotation, _ZoomFactor)
end

---
-- Fokusiert die Kamera auf dem Entity.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
-- @usage
-- -- Zentriert die Kamera über dem Entity mit dem Skriptnamen "HansWurst".
-- API.FocusCameraOnKnight("HansWurst", -45, 0.2);
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or ("'" .._Entity.. "'");
        Logic.ExecuteInLuaLocalState("API.FocusCameraOnEntity(" ..Subject.. ", " ..tostring(_Rotation).. ", " ..tostring(_ZoomFactor).. ")");
        return;
    end
    if type(_Rotation) ~= "number" then
        error("API.FocusCameraOnEntity: Rotation is wrong!");
        return;
    end
    if type(_ZoomFactor) ~= "number" then
        error("API.FocusCameraOnEntity: Zoom factor is wrong!");
        return;
    end
    if not IsExisting(_Entity) then
        error("API.FocusCameraOnEntity: Entity " ..tostring(_Entity).." does not exist!");
        return;
    end
    return ModuleExtendedCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end

