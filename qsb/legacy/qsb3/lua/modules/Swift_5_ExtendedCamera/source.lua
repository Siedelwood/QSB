--[[
Swift_5_ExtendedCamera/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleExtendedCamera = {
    Properties = {
        Name = "ModuleExtendedCamera",
    },

    Global = {},
    Local = {
        ExtendedZoomHotKeyID = 0,
        ExtendedZoomAllowed = true,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Global Script ---------------------------------------------------------------

function ModuleExtendedCamera.Global:OnGameStart()
end

-- Local Script ----------------------------------------------------------------

function ModuleExtendedCamera.Local:OnGameStart()
    self:RegisterExtendedZoomHotkey();
    self:ActivateExtendedZoomHotkey();
end

function ModuleExtendedCamera.Local:OnEvent(_ID, _Event)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        if self.ExtendedZoomActive then
            self:ActivateExtendedZoom();
        end
        self:ActivateExtendedZoomHotkey();
    end
end

function ModuleExtendedCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor)
    local pos = GetPosition(_Entity);
    local rotation = (_Rotation or -45);
    local zoomFactor = (_ZoomFactor or 0.5);
    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
    Camera.RTS_SetRotationAngle(rotation);
    Camera.RTS_SetZoomFactor(zoomFactor);
end

function ModuleExtendedCamera.Local:RegisterExtendedZoomHotkey()
    self:UnregisterExtendedZoomHotkey();
    if self.ExtendedZoomHotKeyID == 0 then
        self.ExtendedZoomHotKeyID = API.AddShortcut(
            {
                de = "STRG + UMSCHALT + K",
                en = "CTRL + SHIFT + K",
                fr = "CTRL + SHIFT + K",
            },
            {
                de = "Alternativen Zoom ein/aus",
                en = "Alternative zoom on/off",
                fr = "Zoom alternatif On/Off",
            }
        );
    end
end

function ModuleExtendedCamera.Local:UnregisterExtendedZoomHotkey()
    if self.ExtendedZoomHotKeyID ~= 0 then
        API.RemoveShortcut(self.ExtendedZoomHotKeyID);
        self.ExtendedZoomHotKeyID = 0;
    end
end

function ModuleExtendedCamera.Local:ActivateExtendedZoomHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.K,
        "ModuleExtendedCamera.Local:ToggleExtendedZoom()",
        2
    );
end

function ModuleExtendedCamera.Local:ToggleExtendedZoom()
    if self.ExtendedZoomAllowed then
        if self.ExtendedZoomActive then
            self:DeactivateExtendedZoom();
        else
            self:ActivateExtendedZoom();
        end
    end
end

function ModuleExtendedCamera.Local:ActivateExtendedZoom()
    self.ExtendedZoomActive = true;
    Camera.RTS_SetZoomFactorMax(0.8701);
    Camera.RTS_SetZoomFactor(0.8700);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

function ModuleExtendedCamera.Local:DeactivateExtendedZoom()
    self.ExtendedZoomActive = false;
    Camera.RTS_SetZoomFactor(0.5000);
    Camera.RTS_SetZoomFactorMax(0.5001);
    Camera.RTS_SetZoomFactorMin(0.0999);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleExtendedCamera);

