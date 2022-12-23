--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

--
-- Stellt neue Behavior für NPC.
--

---
-- Der Held muss einen Nichtspielercharakter ansprechen.
--
-- Es wird automatisch ein NPC erzeugt und überwacht, sobald der Quest
-- aktiviert wurde. Ein NPC darf nicht auf geblocktem Gebiet stehen oder
-- seine Enity-ID verändern.
--
-- <b>Hinweis</b>: Jeder Siedler kann zu jedem Zeitpunkt nur <u>einen</u> NPC 
-- haben. Wird ein weiterer NPC zugewiesen, wird der alte überschrieben und
-- der verknüpfte Quest funktioniert nicht mehr!
--
-- @param[type=string] _NpcName  Skriptname des NPC
-- @param[type=string] _HeroName (optional) Skriptname des Helden
-- @within Goal
--
function Goal_NPC(...)
    return B_Goal_NPC:new(...);
end

B_Goal_NPC = {
    Name             = "Goal_NPC",
    Description     = {
        en = "Goal: The hero has to talk to a non-player character.",
        de = "Ziel: Der Held muss einen Nichtspielercharakter ansprechen.",
        fr = "Objectif: le héros doit interpeller un personnage non joueur.",
    },
    Parameter = {
        { ParameterType.ScriptName, en = "NPC",  de = "NPC",  fr = "NPC" },
        { ParameterType.ScriptName, en = "Hero", de = "Held", fr = "Héro" },
    },
}

function B_Goal_NPC:GetGoalTable()
    return {Objective.Distance, -65565, self.Hero, self.NPC, self}
end

function B_Goal_NPC:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.NPC = _Parameter
    elseif (_Index == 1) then
        self.Hero = _Parameter
        if self.Hero == "-" then
            self.Hero = nil
        end
   end
end

function B_Goal_NPC:GetIcon()
    return {14,10}
end

Revision:RegisterBehavior(B_Goal_NPC);

