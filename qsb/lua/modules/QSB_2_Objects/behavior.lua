--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

--
-- Stellt neue Behavior für Objekte bereit.
--

---
-- Der Spieler muss bis zu 4 interaktive Objekte benutzen.
--
-- @param[type=string] _Object1 Erstes Objekt
-- @param[type=string] _Object2 (optional) Zweites Objekt
-- @param[type=string] _Object3 (optional) Drittes Objekt
-- @param[type=string] _Object4 (optional) Viertes Objekt
--
-- @within Goal
--
function Goal_ActivateSeveralObjects(...)
    return B_Goal_ActivateSeveralObjects:new(...);
end

B_Goal_ActivateSeveralObjects = {
    Name = "Goal_ActivateSeveralObjects",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
        fr = "Objectif: activer un objet interactif",
    },
    Parameter = {
        { ParameterType.Default, en = "Object name 1", de = "Skriptname 1", fr = "Nom de l'entité 1" },
        { ParameterType.Default, en = "Object name 2", de = "Skriptname 2", fr = "Nom de l'entité 2" },
        { ParameterType.Default, en = "Object name 3", de = "Skriptname 3", fr = "Nom de l'entité 3" },
        { ParameterType.Default, en = "Object name 4", de = "Skriptname 4", fr = "Nom de l'entité 4" },
    },
    ScriptNames = {};
}

function B_Goal_ActivateSeveralObjects:GetGoalTable()
    return {Objective.Object, { unpack(self.ScriptNames) } }
end

function B_Goal_ActivateSeveralObjects:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        assert(_Parameter ~= nil and _Parameter ~= "", "Goal_ActivateSeveralObjects: At least one IO needed!");
    end
    if _Parameter ~= nil and _Parameter ~= "" then
        table.insert(self.ScriptNames, _Parameter);
    end
end

function B_Goal_ActivateSeveralObjects:GetMsgKey()
    return "Quest_Object_Activate"
end

Revision:RegisterBehavior(B_Goal_ActivateSeveralObjects);

-- -------------------------------------------------------------------------- --

-- Überschreibt ObjectInit, sodass auch Custom Objects verwaltet werden können.
B_Reward_ObjectInit.CustomFunction = function(self, _Quest)
    local EntityID = GetID(self.ScriptName);
    if EntityID == 0 then
        return;
    end
    QSB.InitalizedObjekts[EntityID] = _Quest.Identifier;

    local GoodReward;
    if self.RewardType and self.RewardType ~= "-" then
        GoodReward = {Goods[self.RewardType], self.RewardAmount};
    end

    local GoodCosts;
    if self.FirstCostType and self.FirstCostType ~= "-" then
        GoodCosts = GoodReward or {};
        table.insert(GoodCosts, Goods[self.FirstCostType]);
        table.insert(GoodCosts, Goods[self.FirstCostAmount]);
    end
    if self.SecondCostType and self.SecondCostType ~= "-" then
        GoodCosts = GoodReward or {};
        table.insert(GoodCosts, Goods[self.SecondCostType]);
        table.insert(GoodCosts, Goods[self.SecondCostAmount]);
    end

    API.SetupObject {
        Name                   = self.ScriptName,
        Distance               = self.Distance,
        Waittime               = self.Waittime,
        Reward                 = GoodReward,
        Costs                  = GoodCosts,
    };
    API.InteractiveObjectActivate(self.ScriptName, self.UsingState);
end

