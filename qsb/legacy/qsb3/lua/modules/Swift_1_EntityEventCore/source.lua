--[[
Swift_1_EntityEventCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleEntityEventCore = {
    Properties = {
        Name = "ModuleEntityEventCore",
    },

    Global = {
        RegisteredEntities = {},
        MineAmounts = {},
        AttackedEntities = {},
        OverkillEntities = {},
        DisableThiefStorehouseHeist = false,
        DisableThiefCathedralSabotage = false,
        DisableThiefCisternSabotage = false,

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
        -- and disappearing depending of if they have resources spawned. Sadly
        -- they change their ID every time they do it.
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
}

-- Global ------------------------------------------------------------------- --

function ModuleEntityEventCore.Global:OnGameStart()
    QSB.ScriptEvents.BuildingPlaced = API.RegisterScriptEvent("Event_BuildingPlaced");
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

    local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, 5, 5, 0, 0);
    Logic.DestroyEntity(ID);
end

function ModuleEntityEventCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OnSaveGameLoaded();
    elseif _ID == QSB.ScriptEvents.EntityHurt then
        self.AttackedEntities[arg[1]] = {arg[3], 100};
    end
end

function ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldID, _OldOwnerID, _NewID, _NewOwnerID)
    _OldID = (type(_OldID) ~= "table" and {_OldID}) or _OldID;
    _NewID = (type(_NewID) ~= "table" and {_NewID}) or _NewID;
    assert(#_OldID == #_NewID, "Sums of entities with changed owner does not add up!");
    for i=1, #_OldID do
        API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, _OldID[i], _OldOwnerID, _NewID[i], _NewOwnerID);
        Logic.ExecuteInLuaLocalState(string.format(
            "API.SendScriptEvent(QSB.ScriptEvents.EntityOwnerChanged, %d)",
            _OldID[i],
            _OldOwnerID,
            _NewID[i],
            _NewOwnerID
        ));
    end
end

function ModuleEntityEventCore.Global:OnSaveGameLoaded()
    self:OverrideLogic();
end

function ModuleEntityEventCore.Global:CleanTaggedAndDeadEntities()
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

function ModuleEntityEventCore.Global:OverrideCallback()
    GameCallback_SettlerSpawned_Orig_QSB_EntityCore = GameCallback_SettlerSpawned;
    GameCallback_SettlerSpawned = function(_PlayerID, _EntityID)
        GameCallback_SettlerSpawned_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:TriggerSettlerArrivedEvent(_PlayerID, _EntityID);
    end

    GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore = GameCallback_OnBuildingConstructionComplete;
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_EntityCore(_PlayerID, _EntityID);
        ModuleEntityEventCore.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID);
    end

    GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore = GameCallback_FarmAnimalChangedPlayerID;
    GameCallback_FarmAnimalChangedPlayerID = function(_PlayerID, _NewEntityID, _OldEntityID)
        GameCallback_FarmAnimalChangedPlayerID_Orig_QSB_EntityCore(_PlayerID, _NewEntityID, _OldEntityID);
        local OldPlayerID = Logic.EntityGetPlayer(_OldEntityID);
        local NewPlayerID = Logic.EntityGetPlayer(_NewEntityID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, OldPlayerID, _NewEntityID, NewPlayerID);
    end

    GameCallback_EntityCaptured_Orig_QSB_EntityCore = GameCallback_EntityCaptured;
    GameCallback_EntityCaptured = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_EntityCaptured_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_CartFreed_Orig_QSB_EntityCore = GameCallback_CartFreed;
    GameCallback_CartFreed = function(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID)
        GameCallback_CartFreed_Orig_QSB_EntityCore(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(_OldEntityID, _OldEntityPlayerID, _NewEntityID, _NewEntityPlayerID);
    end

    GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore = GameCallback_OnThiefDeliverEarnings;
    GameCallback_OnThiefDeliverEarnings = function(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount)
        GameCallback_OnThiefDeliverEarnings_Orig_QSB_EntityCore(_ThiefPlayerID, _ThiefID, _BuildingID, _GoodAmount);
        local BuildingPlayerID = Logic.EntityGetPlayer(_BuildingID);
        ModuleEntityEventCore.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, BuildingPlayerID, _GoodAmount);
    end

    GameCallback_OnThiefStealBuilding_Orig_QSB_EntityCore = GameCallback_OnThiefStealBuilding;
    GameCallback_OnThiefStealBuilding = function(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
        ModuleEntityEventCore.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID);
    end

    GameCallback_OnBuildingUpgraded_Orig_QSB_EntityCore = GameCallback_OnBuildingUpgradeFinished;
	GameCallback_OnBuildingUpgradeFinished = function(_PlayerID, _EntityID, _NewUpgradeLevel)
		GameCallback_OnBuildingUpgraded_Orig_QSB_EntityCore(_PlayerID, _EntityID, _NewUpgradeLevel);
        ModuleEntityEventCore.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel);
    end

    GameCallback_OnUpgradeLevelCollapsed_Orig_QSB_EntityCore = GameCallback_OnUpgradeLevelCollapsed;
    GameCallback_OnUpgradeLevelCollapsed = function(_PlayerID, _BuildingID, _NewUpgradeLevel)
        GameCallback_OnUpgradeLevelCollapsed_Orig_QSB_EntityCore(_PlayerID, _BuildingID, _NewUpgradeLevel);
        ModuleEntityEventCore.Global:TriggerUpgradeCollapsedEvent(_PlayerID, _BuildingID, _NewUpgradeLevel);
    end
end

function ModuleEntityEventCore.Global:OverrideLogic()
    self.Logic_ChangeEntityPlayerID = Logic.ChangeEntityPlayerID;
    Logic.ChangeEntityPlayerID = function(...)
        local OldID = {arg[1]};
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local NewID = {self.Logic_ChangeEntityPlayerID(unpack(arg))};
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID;
    end

    self.Logic_ChangeSettlerPlayerID = Logic.ChangeSettlerPlayerID;
    Logic.ChangeSettlerPlayerID = function(...)
        local OldID = {arg[1]};
        OldID = Array_Append(OldID, API.GetGroupSoldiers(arg[1]));
        local OldPlayerID = Logic.EntityGetPlayer(arg[1]);
        local NewID = {self.Logic_ChangeSettlerPlayerID(unpack(arg))};
        NewID = Array_Append(NewID, API.GetGroupSoldiers(NewID[1]));
        local NewPlayerID = Logic.EntityGetPlayer(NewID[1]);
        ModuleEntityEventCore.Global:TriggerEntityOnwershipChangedEvent(OldID, OldPlayerID, NewID, NewPlayerID);
        return NewID[1];
    end
end

function ModuleEntityEventCore.Global:TriggerThiefDeliverEarningsEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount)
    API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, _ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID, _GoodAmount);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.ThiefDeliverEarnings, %d, %d, %d, %d, %d)",
        _ThiefID,
        _ThiefPlayerID,
        _BuildingID,
        _BuildingPlayerID,
        _GoodAmount
    ));
end

function ModuleEntityEventCore.Global:TriggerThiefStealFromBuildingEvent(_ThiefID, _ThiefPlayerID, _BuildingID, _BuildingPlayerID)
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
        _ThiefID,
        _ThiefPlayerID,
        _BuildingID,
        _BuildingPlayerID
    ));
end

function ModuleEntityEventCore.Global:TriggerEntitySpawnedEvent(_EntityID, _SpawnerID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    API.SendScriptEvent(QSB.ScriptEvents.EntitySpawned, _EntityID, PlayerID, _SpawnerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntitySpawned, %d, %d, %d)",
        _EntityID,
        PlayerID,
        _SpawnerID
    ));
end

function ModuleEntityEventCore.Global:TriggerSettlerArrivedEvent(_PlayerID, _EntityID)
    API.SendScriptEvent(QSB.ScriptEvents.SettlerAttracted, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.SettlerAttracted, %d, %d)",
        _EntityID,
        _PlayerID
    ));
end

function ModuleEntityEventCore.Global:TriggerEntityDestroyedEvent(_EntityID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntityDestroyed, %d, %d)",
        _EntityID,
        _PlayerID
    ));
end

function ModuleEntityEventCore.Global:TriggerEntityKilledEvent(_EntityID1, _PlayerID1, _EntityID2, _PlayerID2)
    API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, _EntityID1, _PlayerID1, _EntityID2, _PlayerID2);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.EntityKilled, %d, %d, %d, %d)",
        _EntityID1,
        _PlayerID1,
        _EntityID2,
        _PlayerID2
    ));
end

function ModuleEntityEventCore.Global:TriggerConstructionCompleteEvent(_PlayerID, _EntityID)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, _EntityID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingConstructed, %d, %d)",
        _EntityID,
        _PlayerID
    ));
end

function ModuleEntityEventCore.Global:TriggerUpgradeCompleteEvent(_PlayerID, _EntityID, _NewUpgradeLevel)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, _EntityID, _PlayerID, _NewUpgradeLevel);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgraded, %d, %d, %d)",
        _EntityID,
        _PlayerID,
        _NewUpgradeLevel
    ));
end

function ModuleEntityEventCore.Global:TriggerUpgradeCollapsedEvent(_PlayerID, _EntityID, _NewUpgradeLevel)
    API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgradeCollapsed, _EntityID, _PlayerID, _NewUpgradeLevel);
    Logic.ExecuteInLuaLocalState(string.format(
        "API.SendScriptEvent(QSB.ScriptEvents.BuildingUpgradeCollapsed, %d, %d, %d)",
        _EntityID,
        _PlayerID,
        _NewUpgradeLevel
    ));
end

function ModuleEntityEventCore.Global:StartTriggers()
    function ModuleEntityEventCore_Trigger_EveryTurn()
        if Logic.GetCurrentTurn() > 0 then
            ModuleEntityEventCore.Global:CleanTaggedAndDeadEntities();
            ModuleEntityEventCore.Global:CheckOnSpawnerEntities();
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ModuleEntityEventCore_Trigger_EveryTurn", 1);

    function ModuleEntityEventCore_Trigger_EntityDestroyed()
        local EntityID1 = Event.GetEntityID();
        local PlayerID1 = Logic.EntityGetPlayer(EntityID1);
        ModuleEntityEventCore.Global:TriggerEntityDestroyedEvent(EntityID1, PlayerID1);
        if ModuleEntityEventCore.Global.AttackedEntities[EntityID1] ~= nil then
            local EntityID2 = ModuleEntityEventCore.Global.AttackedEntities[EntityID1][1];
            local PlayerID2 = Logic.EntityGetPlayer(EntityID2);
            ModuleEntityEventCore.Global.AttackedEntities[EntityID1] = nil;
            ModuleEntityEventCore.Global:TriggerEntityKilledEvent(EntityID1, PlayerID1, EntityID2, PlayerID2);
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ModuleEntityEventCore_Trigger_EntityDestroyed", 1);

    function ModuleEntityEventCore_Trigger_EntityHurt()
        local EntityID1 = Event.GetEntityID1();
        local PlayerID1 = Logic.EntityGetPlayer(EntityID1);
        local EntityID2 = Event.GetEntityID2();
        local PlayerID2 = Logic.EntityGetPlayer(EntityID2);

        API.SendScriptEvent(
            QSB.ScriptEvents.EntityHurt,
            EntityID2,
            PlayerID2,
            EntityID1,
            PlayerID1
        );
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.EntityHurt, %d, %d, %d, %d)]],
            EntityID2,
            PlayerID2,
            EntityID1,
            PlayerID1
        ));
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "ModuleEntityEventCore_Trigger_EntityHurt", 1);

    function ModuleEntityEventCore_Trigger_MineWatch()
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
                        Mines[j],
                        Type,
                        Old,
                        New
                    ))
                end
                self.MineAmounts[Mines[j]] = New;
            end
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "ModuleEntityEventCore_Trigger_MineWatch", 1);
end

function ModuleEntityEventCore.Global:CheckOnSpawnerEntities()
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

function ModuleEntityEventCore.Local:OnGameStart()
    QSB.ScriptEvents.BuildingPlaced = API.RegisterScriptEvent("Event_BuildingPlaced");
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

    self:OverrideAfterBuildingPlacement();
end

function ModuleEntityEventCore.Local:OnEvent(_ID, _Event, ...)
end

function ModuleEntityEventCore.Local:OverrideAfterBuildingPlacement()
    GameCallback_GUI_AfterBuildingPlacement_Orig_EntityEventCore = GameCallback_GUI_AfterBuildingPlacement;
    GameCallback_GUI_AfterBuildingPlacement = function ()
        GameCallback_GUI_AfterBuildingPlacement_Orig_EntityEventCore();

        local x,y = GUI.Debug_GetMapPositionUnderMouse();
        API.StartHiResDelay(0, function()
            local Results = {Logic.GetPlayerEntitiesInArea(GUI.GetPlayerID(), 0, x, y, 50, 16)};
            for i= 2, Results[1] +1 do
                if  Results[i]
                and Results[i] ~= 0
                and Logic.IsBuilding(Results[i]) == 1
                and Logic.IsConstructionComplete(Results[i]) == 0
                then
                    API.BroadcastScriptEventToGlobal(QSB.ScriptEvents.BuildingPlaced, Results[i], Logic.EntityGetPlayer(Results[i]));
                    API.SendScriptEvent(QSB.ScriptEvents.BuildingPlaced, Results[i], Logic.EntityGetPlayer(Results[i]));
                end
            end
        end, x, y);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntityEventCore);

