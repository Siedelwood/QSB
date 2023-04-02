--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Stellt Funktionen für die RTS-Camera bereit.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_1_GuiEffects.QSB_1_GuiEffects.html">(1) Anzeigeeffekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Aktiviert oder deaktiviert den erweiterten Zoom.
--
-- Der maximale Zoom wird erweitert. Dabei entsteht eine fast völlige 
-- Draufsicht. Dies kann nütztlich sein, wenn der Spieler ein größeres 
-- Sichtfeld benötigt.
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
    ModuleCamera.Local.ExtendedZoomAllowed = _Flag == true;
    if _Flag == true then
        ModuleCamera.Local:RegisterExtendedZoomHotkey();
    else
        ModuleCamera.Local:UnregisterExtendedZoomHotkey();
        ModuleCamera.Local:DeactivateExtendedZoom();
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
    return ModuleCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleCamera = {
    Properties = {
        Name = "ModuleCamera",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {},
    Local = {
        ExtendedZoomHotKeyID = 0,
        ExtendedZoomAllowed = true,
    },

    Shared = {
        Text = {
            Shortcut = {
                Hotkey = {
                    de = "STRG + UMSCHALT + K",
                    en = "CTRL + SHIFT + K",
                    fr = "CTRL + SHIFT + K",
                },
                Description = {
                    de = "Alternativen Zoom ein/aus",
                    en = "Alternative zoom on/off",
                    fr = "Zoom alternatif On/Off",
                }
            }
        },
    };
}

-- -------------------------------------------------------------------------- --
-- Global Script

function ModuleCamera.Global:OnGameStart()
end

function ModuleCamera.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --
-- Local Script

function ModuleCamera.Local:OnGameStart()
    self:RegisterExtendedZoomHotkey();
    self:ActivateExtendedZoomHotkey();
end

function ModuleCamera.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        if self.ExtendedZoomActive then
            self:ActivateExtendedZoom();
        end
        self:ActivateExtendedZoomHotkey();
    end
end

function ModuleCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor)
    local pos = GetPosition(_Entity);
    local rotation = (_Rotation or -45);
    local zoomFactor = (_ZoomFactor or 0.5);
    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
    Camera.RTS_SetRotationAngle(rotation);
    Camera.RTS_SetZoomFactor(zoomFactor);
end

-- Utility Functions -------------------------------------------------------- --

function ModuleCamera.Local:RegisterExtendedZoomHotkey()
    self:UnregisterExtendedZoomHotkey();
    if self.ExtendedZoomHotKeyID == 0 then
        self.ExtendedZoomHotKeyID = API.AddShortcutEntry(
            ModuleCamera.Shared.Text.Shortcut.Hotkey,
            ModuleCamera.Shared.Text.Shortcut.Description
        );
    end
end

function ModuleCamera.Local:UnregisterExtendedZoomHotkey()
    if self.ExtendedZoomHotKeyID ~= 0 then
        API.RemoveShortcutEntry(self.ExtendedZoomHotKeyID);
        self.ExtendedZoomHotKeyID = 0;
    end
end

function ModuleCamera.Local:ActivateExtendedZoomHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.K,
        "ModuleCamera.Local:ToggleExtendedZoom()",
        2
    );
end

function ModuleCamera.Local:ToggleExtendedZoom()
    if self.ExtendedZoomAllowed then
        if self.ExtendedZoomActive then
            self:DeactivateExtendedZoom();
        else
            self:ActivateExtendedZoom();
        end
    end
end

function ModuleCamera.Local:ActivateExtendedZoom()
    self.ExtendedZoomActive = true;
    Camera.RTS_SetZoomFactorMax(0.870001);
    Camera.RTS_SetZoomFactor(0.870000);
    Camera.RTS_SetZoomFactorMin(0.099999);
end

function ModuleCamera.Local:DeactivateExtendedZoom()
    self.ExtendedZoomActive = false;
    Camera.RTS_SetZoomFactor(0.500000);
    Camera.RTS_SetZoomFactorMax(0.500001);
    Camera.RTS_SetZoomFactorMin(0.099999);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleCamera);

