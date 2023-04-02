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

