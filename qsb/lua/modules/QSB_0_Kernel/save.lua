-- -------------------------------------------------------------------------- --

--
-- Speichern und Laden von Spielständen kontrollieren.
-- @set sort=true
-- @local
--

Swift.Save = {
    HistoryEditionQuickSave = false,
    SavingDisabled = false,
    LoadingDisabled = false,
};

function Swift.Save:Initalize()
    self:SetupQuicksaveKeyCallback();
    self:SetupQuicksaveKeyTrigger();
end

function Swift.Save:OnSaveGameLoaded()
    self:SetupQuicksaveKeyTrigger();
    self:UpdateLoadButtons();
    self:UpdateSaveButtons();
end

-- -------------------------------------------------------------------------- --
-- HE Quicksave

function Swift.Save:SetupQuicksaveKeyTrigger()
    if Swift.Environment == QSB.Environment.LOCAL then
        Swift.Job:CreateEventJob(
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

function Swift.Save:SetupQuicksaveKeyCallback()
    if Swift.Environment == QSB.Environment.LOCAL then
        KeyBindings_SaveGame_Orig_Swift = KeyBindings_SaveGame;
        KeyBindings_SaveGame = function(...)
            -- No quicksave if saving disabled
            if Swift.Save.SavingDisabled then
                return;
            end
            -- No quicksave if forced by History Edition
            if not Swift.Save.HistoryEditionQuickSave and not arg[1] then
                return;
            end
            -- Do quicksave
            KeyBindings_SaveGame_Orig_Swift();
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Disable Save

function Swift.Save:DisableSaving(_Flag)
    self.SavingDisabled = _Flag == true;
    if Swift.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.Save:DisableSaving(%s)]],
            tostring(_Flag)
        ))
    else
        self:UpdateSaveButtons();
    end
end

function Swift.Save:UpdateSaveButtons()
    if Swift.Environment == QSB.Environment.LOCAL then
        local VisibleFlag = (self.SavingDisabled and 0) or 1;
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", VisibleFlag);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", VisibleFlag);
    end
end

-- -------------------------------------------------------------------------- --
-- Disable Load

function Swift.Save:DisableLoading(_Flag)
    self.LoadingDisabled = _Flag == true;
    if Swift.Environment == QSB.Environment.GLOBAL then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.Save:DisableLoading(%s)]],
            tostring(_Flag)
        ))
    else
        self:UpdateLoadButtons();
    end
end

function Swift.Save:UpdateLoadButtons()
    if Swift.Environment == QSB.Environment.LOCAL then
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
    if Swift.Environment == QSB.Environment.GLOBAL then
        Swift.Save.HistoryEditionQuickSave = _Flag == true;
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.Save.HistoryEditionQuickSave = %s]],
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
    Swift.Save:DisableSaving(_Flag);
end

---
-- Deaktiviert das Laden von Spielständen.
-- @param[type=boolean] _Flag Laden ist deaktiviert
-- @within Spielstand
--
function API.DisableLoading(_Flag)
    Swift.Save:DisableLoading(_Flag);
end

