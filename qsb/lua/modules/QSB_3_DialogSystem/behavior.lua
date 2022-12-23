--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Fügt Behavior zur Steuerung von Dialogs hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Dialog.
--
-- Jedes Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reprisal
--
function Reprisal_Dialog(...)
    return B_Reprisal_Dialog:new(...);
end

B_Reprisal_Dialog = {
    Name = "Reprisal_Dialog",
    Description = {
        en = "Reprisal: Calls a function to start an new dialog.",
        de = "Vergeltung: Ruft die Funktion auf und startet das enthaltene Dialog.",
        fr = "Rétribution: Appelle la fonction et démarre le dialogue contenu.",
    },
    Parameter = {
        { ParameterType.Default, en = "Dialog name",     de = "Name des Dialog",     fr = "Nom du dialogue" },
        { ParameterType.Default, en = "Dialog function", de = "Funktion mit Dialog", fr = "Fonction du dialogue" },
    },
}

function B_Reprisal_Dialog:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function B_Reprisal_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Dialog:CustomFunction(_Quest)
    _G[self.Function](self.DialogName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Dialog:Debug(_Quest)
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Reprisal_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Dialog.
--
-- Jedes Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reward
--
function Reward_Dialog(...)
    return B_Reward_Dialog:new(...);
end

B_Reward_Dialog = Revision.LuaBase:CopyTable(B_Reprisal_Dialog);
B_Reward_Dialog.Name = "Reward_Dialog";
B_Reward_Dialog.Description.en = "Reward: Calls a function to start an new dialog.";
B_Reward_Dialog.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Dialog.";
B_Reward_Dialog.Description.fr = "Récompense: Appelle la fonction et lance le dialogue qu'elle contient.";
B_Reward_Dialog.GetReprisalTable = nil;

B_Reward_Dialog.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Revision:RegisterBehavior(B_Reward_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Dialog beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Dialog
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Dialog(...)
    return B_Trigger_Dialog:new(...);
end

B_Trigger_Dialog = {
    Name = "Trigger_Dialog",
    Description = {
        en = "Trigger: Checks if an dialog has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob ein Dialog beendet ist und startet dann den Quest.",
        fr = "Déclencheur: Vérifie si un dialogue est terminé et démarre alors la quête.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Dialog name", de = "Name des Dialog", fr = "Nom du dialogue" },
        { ParameterType.PlayerID, en = "Player ID",   de = "Player ID",       fr = "Player ID" },
        { ParameterType.Number,   en = "Wait time",   de = "Wartezeit",       fr = "Temps d'attente" },
    },
}

function B_Trigger_Dialog:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Dialog:CustomFunction(_Quest)
    if API.GetCinematicEvent(self.DialogName, self.PlayerID) == CinematicEvent.Concluded then
        if self.WaitTime and self.WaitTime > 0 then
            self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
            if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                return true;
            end
        else
            return true;
        end
    end
    return false;
end

function B_Trigger_Dialog:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Trigger_Dialog);

