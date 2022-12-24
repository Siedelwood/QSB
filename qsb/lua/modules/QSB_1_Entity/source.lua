--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleEntity = {
    Properties = {
        Name = "ModuleEntity",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {
        RegisteredEntities = {},
        MineAmounts = {},
        AttackedEntities = {},
        OverkillEntities = {},
        DisableThiefStorehouseHeist = false,
        DisableThiefCathedralSabotage = false,
        DisableThiefCisternSabotage = false,

        -- TODO: Add predators?
        StaticSpawnerTypes = {
            "B_NPC_BanditsHQ_ME",
            "B_NPC_BanditsHQ_NA",
            "B_NPC_BanditsHQ_NE",
            "B_NPC_BanditsHQ_SE",
            "B_NPC_BanditsHutBig_ME",
            "B_NPC_BanditsHutBig_NA",
            "B_NPC_BanditsHutBig_NE",
            "B_NPC_BanditsHutBig_SE",
            "B_NPC_BanditsHutSmall_ME",
            "B_NPC_BanditsHutSmall_NA",
            "B_NPC_BanditsHutSmall_NE",
            "B_NPC_BanditsHutSmall_SE",
            "B_NPC_Barracks_ME",
            "B_NPC_Barracks_NA",
            "B_NPC_Barracks_NE",
            "B_NPC_Barracks_SE",
            "B_NPC_BanditsHQ_AS",
            "B_NPC_BanditsHutBig_AS",
            "B_NPC_BanditsHutSmall_AS",
            "B_NPC_Barracks_AS",
        },

        -- Those are "fluctuating" spawner entities that are keep appearing
        -- and disappearing depending of if they have resources spawned. They
        -- change their ID every time they do it. So scriptnames are a nono.
        DynamicSpawnerTypes = {
            "S_AxisDeer_AS",
            "S_Deer_ME",
            "S_FallowDeer_SE",
            "S_Gazelle_NA",
            "S_Herbs",
            "S_Moose_NE",
            "S_RawFish",
            "S_Reindeer_NE",
            "S_WildBoar",
            "S_Zebra_NA",
        },
    },
    Local = {},
    Shared = {},
}

-- Global ------------------------------------------------------------------- --

function ModuleEntity.Global:OnGameStart()
    QSB.ScriptEvents.SettlerAttracted = API.RegisterScriptEvent("Event_SettlerAttracted");
    QSB.ScriptEvents.EntitySpawned = API.RegisterScriptEvent("Event_EntitySpawned");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");
    QSB.ScriptEvents.EntityResourceChanged = API.RegisterScriptEvent("Event_EntityResourceChanged");

    QSB.ScriptEvents.ThiefInfiltratedBuilding = API.RegisterScriptEvent("Event_ThiefInfiltratedBuilding");
    QSB.ScriptEvents.ThiefDeliverEarnings = API.RegisterScriptEvent("Event_ThiefDeliverEarnings");
    QSB.ScriptEvents.BuildingConstructed = API.RegisterScriptEvent("Event_BuildingConstructed");
    QSB.ScriptEvents.BuildingUpgradeCollapsed = API.RegisterScriptEvent("Event_BuildingUpgradeCollapsed");
    QSB.ScriptEvents.BuildingUpgraded = API.RegisterScriptEvent("Event_BuildingUpgraded");

    self:StartTriggers();
    self:OverrideCallback();
    self:OverrideLogic();
end

function ModuleEntity.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OnSaveGameLoaded();
    elseif _ID == QSB.ScriptEvents.EntityHurt then
        self.AttackedEntities[arg[1]] = {arg[3], 100};
    end
end

function ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(_OldID, _OldOwnerID, _NewID, _NewOwnerID)
    _OldID = (type(_OldID) ~= "table" and {_OldID}) or _OldID;
    _NewID = (type(_NewID) ~= "table" and {_NewID}) or _NewID;
    assert(#_OldID == #_NewID, "Sums of entities with changed owner does not add up!");
    for i=1, #_OldID do
        API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, _OldID[i], _OldOwnerID, _NewID[i], _NewOwnerID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, %d)",
            _OldID[i], _OldOwnerID, _NewID[i], _NewOwnerID
        ));
    end
end

function ModuleEntity.Global:OnSaveGameLoaded()
    self:OverrideLogic();
end

function ModuleEntity.Global:CleanTaggedAndDeadEntities()
    -- check if entity should no longer be considered attacked
    for k,v in pairs(self.AttackedEntities) do
        self.AttackedEntities[k][2] = v[2] - 1;
        if v[2] <= 0 then
            self.AttackedEntities[k] = nil;
        else
            -- Send killed event for knights
            if IsExisting(k) and IsExisting(v[1]) and Logic.IsKnight(k) then
                if not self.OverkillEntities[k] and Logic.KnightGetResurrectionProgress(k) ~= 1 then
                    local PlayerID1 = Logic.EntityGetPlayer(k);
                    local PlayerID2 = Logic.EntityGetPlayer(v[1]);
                    self:TriggerEntityKilledEvent(k, PlayerID1, v[1], PlayerID2);
                    self.OverkillEntities[k] = 50;
                    self.AttackedEntities[k] = nil;
                end
            end
        end
    end
    -- unregister overkill entities
    for k,v in pairs(self.OverkillEntities) do
        self.OverkillEntities[k] = v - 1;
        if v <= 0 then
            self.OverkillEntities[k] = nil;
        end
    end
end

function ModuleEntity.Global:OverrideCallback()
    GameCallback_SettlerSpawned_Orig_QSB_EntityCore = GameCallback_SettlerSpawned;
    GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
        GameCallback_SettlerSpawned_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntity.Global:TriggerSettlerArrivedEvent(_PlayerID, _EntityID);
    end

    GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore = GameCallback_OnBuildingConstructionComplete;
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntity.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID);
    end

    GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore = GameCallback_FarmAnimalChangedPlayerID;
    GameCallback_FarmAnimalChangedPlayerID = function(_PlayerID, _NewEntityID, _OldEntityID)
        GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore(_PlayerID, _NewEntityID, _OldEntityID);
        local OldPlayerID = Logic.EntityGetPlayer(_OldEntityID);
        local NewPlayerID = Logic.EntityGetPlayer(_NewEntityID);
        ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, OldPlayerID, _NewEntityID, NewPlayerID);
    end

    GameCallback_EntityCaptured_Orig_QSB_EntityCore = GameCallback_EntityCaptured;
    GameCallback_EntityCaptured = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_EntityCaptured_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_CartFreed_Orig_QSB_EntityCore = GameCallback_CartFreed;
    GameCallback_CartFreed = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_CartFreed_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
        ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore = GameCallback_OnThiefDeliverEarnings;
    GameCallback_OnThiefDeliverEarnings = function(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount)
        GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount);
        local BuildingPlayerID = Logic.EntityGetPlayer(_BuildingID);
        ModuleEntity.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, BuildingPlayerID, _GoodAmount);
    end

    GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore = GameCallback_OnThiefStealBuilding;
    GameCallback_OnThiefStealBuilding = function(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
        ModuleEntity.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
    end

    GameCallback_OnBuildingUpgraded_Orig_QSB_EntityCore = GameCallback_OnBuildingUpgradeFinished;
	GameCallback_OnBuildingUpgradeFinished = function(_PlayerID, _EntityID, _NewUpgradeLevel)
		GameCallback_OnBuildingUpgraded_Orig_QSB_EntityCore(_PlayerID, _EntityID, _NewUpgradeLevel);
        ModuleEntity.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel);
    end

    GameCallback_OnUpgradeLevelCollapsed_Orig_QSB_EntityCore = GameCallback_OnUpgradeLevelCollapsed;
    GameCallback_OnUpgradeLevelCollapsed = function(_PlayerID, _BuildingID, _NewUpgradeLevel)
        GameCallback_OnUpgradeLevelCollapsed_Orig_QSB_EntityCore(_PlayerID, _BuildingID, _NewUpgradeLevel);
        ModuleEntity.Global:TriggerUpgradeCollapsedEvent(_PlayerID, _BuildingID, _NewUpgradeLevel);
    end
end

function ModuleEntity.Global:OverrideLogic()
    self.Logic_ChangeEntityPlayerID = Logic.ChangeEntityPlayerID;
    Logic.ChangeEntityPlayerID = function(...)
        local OldID = {arg[1]};
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local NewID = {self.Logic_ChangeEntityPlayerID(unpack(arg))};
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID;
    end

    self.Logic_ChangeSettlerPlayerID = Logic.ChangeSettlerPlayerID;
    Logic.ChangeSettlerPlayerID = function(...)
        local OldID = {arg[1]};
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local OldSoldierTable = {Logic.GetSoldiersAttachedToLeader(arg[1])};
        if OldSoldierTable[1] and OldSoldierTable[1] > 0 then
            for i=2, OldSoldierTable[1]+1 do
                table.insert(OldID, OldSoldierTable[i]);
            end
        end
        local NewID = {self.Logic_ChangeSettlerPlayerID(unpack(arg))};
        local NewSoldierTable = {Logic.GetSoldiersAttachedToLeader(NewID[1])};
        if NewSoldierTable[1] and NewSoldierTable[1] > 0 then
            for i=2, NewSoldierTable[1]+1 do
                table.insert(NewID, NewSoldierTable[i]);
            end
        end
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntity.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID[1];
    end
end

function ModuleEntity.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount)
    API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, %d, %d, %d, %d, %d)",
        _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount
    ));
end

function ModuleEntity.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
    local HeadquartersID = Logic.GetHeadquarters(_BuildingPlayerID);
    local CathedralID = Logic.GetCathedral(_BuildingPlayerID);
    local StorehouseID = Logic.GetStoreHouse(_BuildingPlayerID);
    local IsVillageStorehouse = Logic.IsEntityInCategory(StorehouseID, EntityCategories.VillageStorehouse) == 0;
    local BuildingType = Logic.GetEntityType(_BuildingID);

    -- Aus Lagerhaus stehlen
    if StorehouseID == _BuildingID and (not IsVillageStorehouse or HeadquartersID == 0) then
        if not self.DisableThiefStorehouseHeist then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end
    -- Kirche sabotieren
    if CathedralID == _BuildingID then
        if not self.DisableThiefCathedralSabotage then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end
    -- Brunnen sabotieren
    if Framework.GetGameExtraNo() > 0 and BuildingType == Entities.B_Cistern then
        if not self.DisableThiefCisternSabotage then
            GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
        end
    end

    -- Send event
    API.SendScriptEvent(QSB.ScriptEvents.ThiefInfiltratedBuilding, _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ThiefInfiltratedBuilding, %d, %d, %d, %d)",
        _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID
    ));
end

function ModuleEntity.Global:TriggerEntitySpawnedEvent(_EntityID, _SpawnerID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    API.SendScriptEvent(QSB.ScriptEvents.EntitySpawned, _EntityID, PlayerID, _SpawnerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntitySpawned, %d, %d, %d)",
        _EntityID, PlayerID, _SpawnerID
    ));
end

function ModuleEntity.Global:TriggerSettlerArrivedEvent(_PlayerID, _EntityID)
    API.SendScriptEvent(QSB.ScriptEvents.SettlerAttracted, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.SettlerAttracted, %d, %d)",
        _EntityID, _PlayerID
    ));
end

function ModuleEntity.Global:TriggerEntityDestroyedEvent(_EntityID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, %d, %d)",
        _EntityID, _PlayerID
    ));
end

function ModuleEntity.Global:TriggerEntityKilledEvent(_EntityID1, _PlayerID1, _EntityID2, _PlayerID2)
    API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, _EntityID1, _PlayerID1, _EntityID2, _PlayerID2);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, %d, %d, %d, %d)",
        _EntityID1, _PlayerID1, _EntityID2, _PlayerID2
    ));
end

function ModuleEntity.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, %d, %d)",
        _EntityID, _PlayerID
    ));
end

function ModuleEntity.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, _EntityID, _PlayerID, _NewUpgradeLevel);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, %d, %d, %d)",
        _EntityID, _PlayerID, _NewUpgradeLevel
    ));
end

function ModuleEntity.Global:TriggerUpgradeCollapsedEvent(_PlayerID, _EntityID, _NewUpgradeLevel)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgradeCollapsed, _EntityID, _PlayerID, _NewUpgradeLevel);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgradeCollapsed, %d, %d, %d)",
        _EntityID, _PlayerID, _NewUpgradeLevel
    ));
end

function ModuleEntity.Global:StartTriggers()
    API.StartHiResJob(function()
        if Logic.GetCurrentTurn() > 0 then
            ModuleEntity.Global:CleanTaggedAndDeadEntities();
            ModuleEntity.Global:CheckOnSpawnerEntities();
        end
    end);

    API.StartJob(function()
        local MineEntityTypes = {
            Entities.R_IronMine,
            Entities.R_StoneMine
        };
        for i= 1, #MineEntityTypes do
            local Mines = Logic.GetEntitiesOfType(MineEntityTypes[i]);
            for j= 1, #Mines do
                local Old = self.MineAmounts[Mines[j]];
                local New = Logic.GetResourceDoodadGoodAmount(Mines[j]);
                if Old and New and Old ~= New then
                    local Type = Logic.GetResourceDoodadGoodType(Mines[j]);
                    API.SendScriptEvent(QSB.ScriptEvents.EntityResourceChanged, Mines[j], Type, Old, New);
                    Logic.ExecuteInLuaLocalState(string.format(
                        [[API.SendScriptEvent(QSB.ScriptEvents.EntityResourceChanged, %d, %d, %d, %d)]],
                        Mines[j], Type, Old, New
                    ));
                end
                self.MineAmounts[Mines[j]] = New;
            end
        end
    end);

    API.StartJobByEventType(
        Events.LOGIC_EVENT_ENTITY_DESTROYED,
        function()
            local EntityID1 = Event.GetEntityID();
            local PlayerID1 = Logic.EntityGetPlayer(EntityID1);
            ModuleEntity.Global:TriggerEntityDestroyedEvent(EntityID1, PlayerID1);
            if ModuleEntity.Global.AttackedEntities[EntityID1] ~= nil then
                local EntityID2 = ModuleEntity.Global.AttackedEntities[EntityID1][1];
                local PlayerID2 = Logic.EntityGetPlayer(EntityID2);
                ModuleEntity.Global.AttackedEntities[EntityID1] = nil;
                ModuleEntity.Global:TriggerEntityKilledEvent(EntityID1, PlayerID1, EntityID2, PlayerID2);
            end
        end
    );

    API.StartJobByEventType(
        Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,
        function()
            local EntityID1 = Event.GetEntityID1();
            local PlayerID1 = Logic.EntityGetPlayer(EntityID1);
            local EntityID2 = Event.GetEntityID2();
            local PlayerID2 = Logic.EntityGetPlayer(EntityID2);

            API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, EntityID2, PlayerID2, EntityID1, PlayerID1);
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, %d, %d, %d, %d)]],
                EntityID2, PlayerID2, EntityID1, PlayerID1
            ));
        end
    );
end

function ModuleEntity.Global:CheckOnSpawnerEntities()
    -- Get spawners
    local SpawnerEntities = {};
    for i= 1, #self.DynamicSpawnerTypes do
        if Entities[self.DynamicSpawnerTypes[i]] then
            if Logic.GetCurrentTurn() % 10 == i then
                for k, v in pairs(Logic.GetEntitiesOfType(Entities[self.DynamicSpawnerTypes[i]])) do
                    table.insert(SpawnerEntities, v);
                end
            end
        end
    end
    for i= 1, #self.StaticSpawnerTypes do
        if Entities[self.StaticSpawnerTypes[i]] then
            if Logic.GetCurrentTurn() % 10 == i then
                for k, v in pairs(Logic.GetEntitiesOfType(Entities[self.StaticSpawnerTypes[i]])) do
                    table.insert(SpawnerEntities, v);
                end
            end
        end
    end
    -- Check spawned entities
    for i= 1, #SpawnerEntities do
        for k, v in pairs{Logic.GetSpawnedEntities(SpawnerEntities[i])} do
            -- On Spawner entity spawned
            if not self.RegisteredEntities[v] then
                self:TriggerEntitySpawnedEvent(v, SpawnerEntities[i]);
                self.RegisteredEntities[v] = SpawnerEntities[i];
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleEntity.Local:OnGameStart()
    QSB.ScriptEvents.SettlerAttracted = API.RegisterScriptEvent("Event_SettlerAttracted");
    QSB.ScriptEvents.EntitySpawned = API.RegisterScriptEvent("Event_EntitySpawned");
    QSB.ScriptEvents.EntityDestroyed = API.RegisterScriptEvent("Event_EntityDestroyed");
    QSB.ScriptEvents.EntityHurt = API.RegisterScriptEvent("Event_EntityHurt");
    QSB.ScriptEvents.EntityKilled = API.RegisterScriptEvent("Event_EntityKilled");
    QSB.ScriptEvents.EntityOwnerChanged = API.RegisterScriptEvent("Event_EntityOwnerChanged");
    QSB.ScriptEvents.EntityResourceChanged = API.RegisterScriptEvent("Event_EntityResourceChanged");

    QSB.ScriptEvents.ThiefInfiltratedBuilding = API.RegisterScriptEvent("Event_ThiefInfiltratedBuilding");
    QSB.ScriptEvents.ThiefDeliverEarnings = API.RegisterScriptEvent("Event_ThiefDeliverEarnings");
    QSB.ScriptEvents.BuildingConstructed = API.RegisterScriptEvent("Event_BuildingConstructed");
    QSB.ScriptEvents.BuildingUpgradeCollapsed = API.RegisterScriptEvent("Event_BuildingUpgradeCollapsed");
    QSB.ScriptEvents.BuildingUpgraded = API.RegisterScriptEvent("Event_BuildingUpgraded");
end

function ModuleEntity.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- Shared ------------------------------------------------------------------- --

function ModuleEntity.Shared:IterateOverEntities(_Filter, _TypeList)
    _TypeList = _TypeList or Entities;
    local ResultList = {};
    for _, v in pairs(_TypeList) do
        local AllEntitiesOfType = Logic.GetEntitiesOfType(v);
        for i= 1, #AllEntitiesOfType do
            if _Filter(AllEntitiesOfType[i]) then
                table.insert(ResultList, AllEntitiesOfType[i]);
            end
        end
    end
    return ResultList;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntity);

