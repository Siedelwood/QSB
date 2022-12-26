--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleArmySystem = {
    Properties = {
        Name = "ModuleArmySystem",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        AiPlayer = {},
    },
    Local = {},
    Shared = {}
}

-- -------------------------------------------------------------------------- --
-- Global Script

function ModuleArmySystem.Global:OnGameStart()
    QSB.ScriptEvents.ArmyCreated = API.RegisterScriptEvent("Event_ArmyCreated");
    QSB.ScriptEvents.ArmyDefeated = API.RegisterScriptEvent("Event_ArmyDefeated");

    for i= 1, 8 do
        self.AiPlayer[i] = {
            ArmyMax = 3,
            AutoEmploy = false,
            Armies = {}
        };
    end

    API.StartHiResJob(function()
        ModuleArmySystem.Global:ControlAiPlayer();
    end)
end

function ModuleArmySystem.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleArmySystem.Global:ControlAiPlayer()
    for PlayerID = 1, 8 do
        for ArmyID, Army in pairs(ModuleArmySystem.Global.AiPlayer[PlayerID].Armies) do
            -- Control player
            -- ...

            -- Control armies
            if math.floor(Logic.GetTime() * 10) % ArmyID == 0 then
                if Army:IsAlive() then
                    if Army.Commands[1] then
                        local Command = Army.Commands[1];
                        if Command[1](Army) == true then
                            Army:RemoveCommand();
                            if Command[2] then
                                Army:AddCommand(Command[1], true);
                            end
                        end
                    end
                else
                    self:DisbandArmy(PlayerID, ArmyID);
                end
            end
        end
    end
end

function ModuleArmySystem.Global:CountArmies(_PlayerID)
    local Count = 0;
    for k,v in pairs(self.AiPlayer[_PlayerID].Armies) do
        Count = Count +1;
    end
    return Count;
end

-- -------------------------------------------------------------------------- --

function ModuleArmySystem.Global:GetArmy(_PlayerID, _ArmyID)
    return self.AiPlayer[_PlayerID].Armies[_ArmyID];
end

function ModuleArmySystem.Global:CreateArmyForPlayer(_PlayerID, _HomePosition)
    local Army = TWA.Army:New(_PlayerID, _HomePosition);
    self.AiPlayer[_PlayerID].Armies[Army.ID] = Army;
    return Army.ID;
end

function ModuleArmySystem.Global:DisbandArmyOfPlayer(_PlayerID, _ArmyID)
    if self.AiPlayer[_PlayerID].Armies[_ArmyID] then
        self.AiPlayer[_PlayerID].Armies[_ArmyID]:Dispose();
    end
    self.AiPlayer[_PlayerID].Armies[_ArmyID] = nil;
end

function ModuleArmySystem.Global:EnlargeArmyOfPlayer(_PlayerID, _ArmyID, _Melee, _Ranged, _Rams, _Towers, _Catapults, _AmmoCarts, _ReuseTroops, _UnitType)
    local Army = self:GetArmy(_PlayerID, _ArmyID);
    if not Army then
        return;
    end
    local Position = Army:GetAnchor();

    local MeleeToSpawn = _Melee or 0;
    if _ReuseTroops then
        MeleeToSpawn = self:AddUnemployedMeleeToArmyOfPlayer(_PlayerID, _ArmyID, _Melee);
    end
    local RangedToSpawn = _Ranged or 0;
    if _ReuseTroops then
        RangedToSpawn = self:AddUnemployedRangedToArmyOfPlayer(_PlayerID, _ArmyID, _Ranged);
    end
    local RamsToSpawn = _Rams or 0;
    if _ReuseTroops then
        RamsToSpawn = self:AddUnemployedRamsToArmyOfPlayer(_PlayerID, _ArmyID, _Rams);
    end
    local TowersToSpawn = _Towers or 0;
    if _ReuseTroops then
        TowersToSpawn = self:AddUnemployedTowersToArmyOfPlayer(_PlayerID, _ArmyID, _Towers);
    end
    local CatapultsToSpawn = _Catapults or 0;
    if _ReuseTroops then
        CatapultsToSpawn = self:AddUnemployedCatapultsToArmyOfPlayer(_PlayerID, _ArmyID, _Catapults);
    end
    local AmmoCartsToSpawn = _AmmoCarts or 0;

    for i= 1, MeleeToSpawn do
        local FighterType = AIScriptHelper_GetTroopTypeOverride(Entities.U_MilitarySword, _UnitType)
        local EntityID = Logic.CreateBattalionOnUnblockedLand(FighterType, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
    for i= 1, RangedToSpawn do
        local FighterType = AIScriptHelper_GetTroopTypeOverride(Entities.U_MilitaryBow, _UnitType)
        local EntityID = Logic.CreateBattalionOnUnblockedLand(FighterType, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
    for i= 1, RamsToSpawn do
        local EntityID = Logic.CreateEntityOnUnblockedLand(Entities.U_BatteringRamCart, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
    for i= 1, TowersToSpawn do
        local EntityID = Logic.CreateEntityOnUnblockedLand(Entities.U_SiegeTowerCart, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
    for i= 1, CatapultsToSpawn do
        local EntityID = Logic.CreateEntityOnUnblockedLand(Entities.U_CatapultCart, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
    for i= 1, AmmoCartsToSpawn do
        local EntityID = Logic.CreateEntityOnUnblockedLand(Entities.U_AmmunitionCart, Position.X, Position.Y, 0, _PlayerID);
        AICore.AddEntityToArmy(_PlayerID, _ArmyID, EntityID);
    end
end

function ModuleArmySystem.Global:AddUnemployedMeleeToArmyOfPlayer(_PlayerID, _ArmyID, _Amount)
    local FoundSword = _Amount;
    for i = _Amount, 1, -1 do
        if AICore.CheckFreeUnits(_PlayerID, i, 0, 0, 0, 0 ) then
            AICore.AddSwordsmenToArmy(_PlayerID, _ArmyID, i, i, i);
            FoundSword = _Amount - i;
            break
        end
    end
    return FoundSword;
end

function ModuleArmySystem.Global:AddUnemployedRangedToArmyOfPlayer(_PlayerID, _ArmyID, _Amount)
    local FoundBow = _Amount;
    for i = _Amount, 1, -1 do
        if AICore.CheckFreeUnits(_PlayerID, 0, i, 0, 0, 0) then
            AICore.AddBowmenToArmy(_PlayerID, _ArmyID, i, i, i);
            FoundBow = _Amount - i;
            break
        end
    end
    return FoundBow;
end

function ModuleArmySystem.Global:AddUnemployedRamsToArmyOfPlayer(_PlayerID, _ArmyID, _Amount)
    local FoundRams = _Amount;
    for i = _Amount, 1, -1 do
        if AICore.CheckFreeUnits(_PlayerID, 0, 0, i, 0, 0) then
            AICore.AddRamToArmy(_PlayerID, _ArmyID, i, i, i);
            FoundRams = _Amount - i;
            break
        end
    end
    return FoundRams;
end

function ModuleArmySystem.Global:AddUnemployedTowersToArmyOfPlayer(_PlayerID, _ArmyID, _Amount)
    local FoundTowers = _Amount;
    for i = _Amount, 1, -1 do
        if AICore.CheckFreeUnits(_PlayerID, 0, 0, 0, i, 0) then
            AICore.AddTowerToArmy(_PlayerID, _ArmyID, i, i, i);
            FoundTowers = _Amount - i;
            break
        end
    end
    return FoundTowers;
end

function ModuleArmySystem.Global:AddUnemployedCatapultsToArmyOfPlayer(_PlayerID, _ArmyID, _Amount)
    local FoundCatapults = _Amount;
    for i = _Amount, 1, -1 do
        if AICore.CheckFreeUnits(_PlayerID, 0, 0, 0, 0, i) then
            AICore.AddCatapultToArmy(_PlayerID, _ArmyID, i, i, i);
            CatapultsNew = _Amount - i;
            break
        end
    end
    return FoundCatapults;
end

-- -------------------------------------------------------------------------- --
-- Local Script

function ModuleArmySystem.Local:OnGameStart()
    QSB.ScriptEvents.ArmyCreated = API.RegisterScriptEvent("Event_ArmyCreated");
    QSB.ScriptEvents.ArmyDefeated = API.RegisterScriptEvent("Event_ArmyDefeated");
end

function ModuleArmySystem.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleArmySystem);

