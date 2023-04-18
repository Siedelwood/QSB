--[[
Swift_5_Minimap/Behavior

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Fügt Behavior zur Steuerung von Minimap-Markierungen hinzu.
--
-- @set sort=true
--

QSB.MarkerNamesToID = {};

-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Markierung auf der Minikarte.
--
-- @param[type=string] _MarkerName  Eindeutiger Name der Markierung
-- @param[type=string] _MarkerType  Typ der Markierung
-- @param[type=string] _MarkerColor Farbe der Markierung
-- @param[type=string] _Position    Position auf der Welt
-- @within Reprisal
--
function Reprisal_CreateMapMarker(...)
    return B_Reprisal_CreateMapMarker:new(...);
end

B_Reprisal_CreateMapMarker = {
    Name = "Reprisal_CreateMapMarker",
    Description = {
        en = "Reprisal: Creates an marker on the minimap.",
        de = "Vergeltung: Erzeugt eine Markierung auf der Minikarte.",
        fr = "Rétribution : crée un marqueur sur la mini-carte.",
    },
    Parameter = {
        { ParameterType.Default,    en = "Marker Name",  de = "Name Markierung",        fr = "Nom du marqueur" },
        { ParameterType.Custom,     en = "Marker Type",  de = "Typ der Markierung",     fr = "Type de marqueur" },
        { ParameterType.Custom,     en = "Marker Color", de = "Farbe der Markierung",   fr = "Couleur du marqueur" },
        { ParameterType.ScriptName, en = "Position",     de = "Position",               fr = "Position" },
    },
}

function B_Reprisal_CreateMapMarker:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_CreateMapMarker:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.MarkerName = _Parameter;
    elseif (_Index == 1) then
        self.MarkerType = _Parameter;
    elseif (_Index == 2) then
        self.MarkerColor = _Parameter;
    elseif (_Index == 3) then
        self.TargetName = _Parameter;
    end
end

function B_Reprisal_CreateMapMarker:GetCustomData(_Index)
    if _Index == 1 then
        return {"Signal", "Marker", "Pulse"};
    elseif _Index == 2 then
        local Data = {};
        for k, v in pairs(MarkerColor) do
            table.insert(Data, k);
        end
        return Data;
    end
end

function B_Reprisal_CreateMapMarker:CustomFunction(_Quest)
    local ID;
    if self.MarkerType == "Signal" then
        ID = API.CreateMinimapSignal(_Quest.ReceivingPlayer, MarkerColor[self.MarkerColor], self.TargetName);
    elseif self.MarkerType == "Signal" then
        ID = API.CreateMinimapMarker(_Quest.ReceivingPlayer, MarkerColor[self.MarkerColor], self.TargetName);
    elseif self.MarkerType == "Signal" then
        ID = API.CreateMinimapPulse(_Quest.ReceivingPlayer, MarkerColor[self.MarkerColor], self.TargetName);
    end
    QSB.MarkerNamesToID[self.MarkerName] = ID;
end

function B_Reprisal_CreateMapMarker:Debug(_Quest)
    if self.MarkerName == nil or self.MarkerName == "" then
        error(_Quest.Identifier.. ": " ..self.Name .. ": marker name can not be empty.");
        return true;
    end
    if QSB.MarkerNamesToID[self.MarkerName] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": marker name '" ..self.MarkerName.. "' is already in use.");
        return true;
    end
    if not IsExisting(self.TargetName) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": target '" ..tostring(self.TargetName).. "' is dead. ;(");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_CreateMapMarker);

-- -------------------------------------------------------------------------- --

---
-- Erstellt eine Markierung auf der Minikarte.
--
-- @param[type=string] _MarkerName  Eindeutiger Name der Markierung
-- @param[type=string] _MarkerType  Typ der Markierung
-- @param[type=string] _MarkerColor Farbe der Markierung
-- @param[type=string] _Position    Position auf der Welt
-- @within Reward
--
function Reward_CreateMapMarker(...)
    return B_Reward_CreateMapMarker:new(...);
end

B_Reward_CreateMapMarker = Swift.LuaBase:CopyTable(B_Reprisal_CreateMapMarker);
B_Reward_CreateMapMarker.Name = "Reward_CreateMapMarker";
B_Reward_CreateMapMarker.Description.en = "Reward: Creates an marker on the minimap.";
B_Reward_CreateMapMarker.Description.de = "Lohn: Erzeugt eine Markierung auf der Minikarte.";
B_Reward_CreateMapMarker.Description.fr = "Récompense: crée un marqueur sur la mini-carte.";
B_Reward_CreateMapMarker.GetReprisalTable = nil;

B_Reward_CreateMapMarker.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_CreateMapMarker);

-- -------------------------------------------------------------------------- --

---
-- Entfernt eine Markierung von der Minikarte.
--
-- Wird eine Markierung gelöscht, wir der Name wieder freigegeben.
--
-- @param[type=string] _MarkerName Name der Markierung
-- @within Reprisal
--
function Reprisal_DestroyMapMarker(...)
    return B_Reprisal_DestroyMapMarker:new(...);
end

B_Reprisal_DestroyMapMarker = {
    Name = "Reprisal_DestroyMapMarker",
    Description = {
        en = "Reprisal: Removes an marker from the minimap.",
        de = "Vergeltung: Entfernt eine Markierung von der Minikarte.",
        fr = "Rétribution: enlève un marqueur de la mini-carte.",
    },
    Parameter = {
        { ParameterType.Default,    en = "Marker Name",  de = "Name Markierung", fr = "Nom du marqueur" },
    },
}

function B_Reprisal_DestroyMapMarker:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_DestroyMapMarker:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.MarkerName = _Parameter;
    end
end

function B_Reprisal_DestroyMapMarker:CustomFunction(_Quest)
    local ID = QSB.MarkerNamesToID[self.MarkerName];
    API.DestroyMinimapSignal(ID);
    QSB.MarkerNamesToID[self.MarkerName] = nil;
end

function B_Reprisal_DestroyMapMarker:Debug(_Quest)
    if self.MarkerName == nil or self.MarkerName == "" then
        error(_Quest.Identifier.. ": " ..self.Name .. ": marker name can not be empty.");
        return true;
    end
    if not QSB.MarkerNamesToID[self.MarkerName] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": marker name '" ..self.MarkerName.. "' is not registered.");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_DestroyMapMarker);

-- -------------------------------------------------------------------------- --

---
-- Entfernt eine Markierung von der Minikarte.
--
-- Wird eine Markierung gelöscht, wir der Name wieder freigegeben.
--
-- @param[type=string] _MarkerName Name der Markierung
-- @within Reward
--
function Reward_DestroyMapMarker(...)
    return B_Reward_DestroyMapMarker:new(...);
end

B_Reward_DestroyMapMarker = Swift.LuaBase:CopyTable(B_Reprisal_DestroyMapMarker);
B_Reward_DestroyMapMarker.Name = "Reward_DestroyMapMarker";
B_Reward_DestroyMapMarker.Description.en = "Reward: Creates an marker on the minimap.";
B_Reward_DestroyMapMarker.Description.de = "Lohn: Erzeugt eine Markierung auf der Minikarte.";
B_Reward_DestroyMapMarker.Description.fr = "Récompense: enlève un marqueur de la mini-carte.";
B_Reward_DestroyMapMarker.GetReprisalTable = nil;

B_Reward_DestroyMapMarker.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_DestroyMapMarker);

