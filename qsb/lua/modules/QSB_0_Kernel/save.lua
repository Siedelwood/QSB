--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Speichern und Laden von Spielständen kontrollieren.
-- @set sort=true
-- @local
--

Revision.Save = {
    HistoryEditionQuickSave = false,
    SavingDisabled = false,
    LoadingDisabled = false,
};

function Revision.Save:Initalize()
    self:SetupQuicksaveKeyCallback();
    self:SetupQuicksaveKeyTrigger();
end

function Revision.Save:OnSaveGameLoaded()
    self:SetupQuicksaveKeyTrigger();
    self:UpdateLoadButtons();
    self:UpdateSaveButtons();
end

-- -------------------------------------------------------------------------- --
-- HE Quicksave

function Revision.Save:SetupQuicksaveKeyTrigger()
    if Revision.Environment == QSB.Environment.LOCAL then
        Revision.Job:CreateEventJob(
            Events.LOGIC_EVENT_EVERY_TURN,
            function()
                Input.KeyBindDown(
                    Keys.ModifierControl + Keys.S,
                    "KeyBindings_SaveGame(true)",
                    2,
                    false
                );
                return true;
            end
        );
    end
end

function Revision.Save:SetupQuicksaveKeyCallback()
    if Revision.Environment == QSB.Environment.LOCAL then
        KeyBindings_SaveGame_Orig_Revision = KeyBindings_SaveGame;
        KeyBindings_SaveGame = function(...)
            -- No quicksave if saving disabled
            if Revision.Save.SavingDisabled then
                return;
            end
            -- No quicksave if forced by History Edition
            if not Revision.Save.HistoryEditionQuickSave and not arg[1] then
                return;
            end
            -- Do quicksave
            KeyBindings_SaveGame_Orig_Revision();
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Disable Save

function Revision.Save:DisableSaving(_Flag)
    self.SavingDisabled = _Flag == true;
    if Revision.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Save:DisableSaving(%s)]],
            tostring(_Flag)
        ))
    else
        self:UpdateSaveButtons();
    end
end

function Revision.Save:UpdateSaveButtons()
    if Revision.Environment == QSB.Environment.LOCAL then
        local VisibleFlag = (self.SavingDisabled and 0) or 1;
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", VisibleFlag);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", VisibleFlag);
    end
end

-- -------------------------------------------------------------------------- --
-- Disable Load

function Revision.Save:DisableLoading(_Flag)
    self.LoadingDisabled = _Flag == true;
    if Revision.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Save:DisableLoading(%s)]],
            tostring(_Flag)
        ))
    else
        self:UpdateLoadButtons();
    end
end

function Revision.Save:UpdateLoadButtons()
    if Revision.Environment == QSB.Environment.LOCAL then
        local VisibleFlag = (self.LoadingDisabled and 0) or 1;
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/LoadGame", VisibleFlag);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickLoad", VisibleFlag);
    end
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Deaktiviert das automatische Speichern der History Edition.
-- @param[type=boolean] _Flag Auto-Speichern ist deaktiviert
-- @within Spielstand
--
function API.DisableAutoSave(_Flag)
    if Revision.Environment == QSB.Environment.GLOBAL then
        Revision.Save.HistoryEditionQuickSave = _Flag == true;
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Save.HistoryEditionQuickSave = %s]],
            tostring(_Flag == true)
        ))
    end
end

---
-- Deaktiviert das Speichern des Spiels.
-- @param[type=boolean] _Flag Speichern ist deaktiviert
-- @within Spielstand
--
function API.DisableSaving(_Flag)
    Revision.Save:DisableSaving(_Flag);
end

---
-- Deaktiviert das Laden von Spielständen.
-- @param[type=boolean] _Flag Laden ist deaktiviert
-- @within Spielstand
--
function API.DisableLoading(_Flag)
    Revision.Save:DisableLoading(_Flag);
end

