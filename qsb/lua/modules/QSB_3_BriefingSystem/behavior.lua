--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Fügt Behavior zur Steuerung von Briefings hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reprisal
--
function Reprisal_Briefing(...)
    return B_Reprisal_Briefing:new(...);
end

B_Reprisal_Briefing = {
    Name = "Reprisal_Briefing",
    Description = {
        en = "Reprisal: Calls a function to start an new briefing.",
        de = "Vergeltung: Ruft die Funktion auf und startet das enthaltene Briefing.",
        fr = "Rétribution: Appelle la fonction et démarre le briefing qu'elle contient.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing name",     de = "Name des Briefing",     fr = "Nom du briefing" },
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing", fr = "Fonction avec briefing" },
    },
}

function B_Reprisal_Briefing:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function B_Reprisal_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Briefing:CustomFunction(_Quest)
    _G[self.Function](self.BriefingName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Briefing:Debug(_Quest)
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Reprisal_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reward
--
function Reward_Briefing(...)
    return B_Reward_Briefing:new(...);
end

B_Reward_Briefing = Revision.LuaBase:CopyTable(B_Reprisal_Briefing);
B_Reward_Briefing.Name = "Reward_Briefing";
B_Reward_Briefing.Description.en = "Reward: Calls a function to start an new briefing.";
B_Reward_Briefing.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Briefing.";
B_Reward_Briefing.Description.fr = "Récompense: Appelle la fonction et démarre le briefing qu'elle contient.";
B_Reward_Briefing.GetReprisalTable = nil;

B_Reward_Briefing.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Revision:RegisterBehavior(B_Reward_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Briefing beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Briefing
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Briefing(...)
    return B_Trigger_Briefing:new(...);
end

B_Trigger_Briefing = {
    Name = "Trigger_Briefing",
    Description = {
        en = "Trigger: Checks if an briefing has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob ein Briefing beendet ist und startet dann den Quest.",
        fr = "Déclencheur: Vérifie si un briefing est terminé et lance ensuite la quête.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Briefing name", de = "Name des Briefing", fr = "Nom du briefing" },
        { ParameterType.PlayerID, en = "Player ID",     de = "Player ID",         fr = "Player ID" },
        { ParameterType.Number,   en = "Wait time",     de = "Wartezeit",         fr = "Temps d'attente" },
    },
}

function B_Trigger_Briefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Briefing:CustomFunction(_Quest)
    if API.GetCinematicEvent(self.BriefingName, self.PlayerID) == CinematicEvent.Concluded then
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

function B_Trigger_Briefing:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Trigger_Briefing);

