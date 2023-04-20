-- -------------------------------------------------------------------------- --

---
-- Ermöglicht, Entities suchen und auf bestimmte Ereignisse reagieren.
--
-- <h5>Entity Suche</h5>
-- Es kann entweder mit vordefinierten Funktionen oder mit eigenen Filtern
-- nach allen Entities gesucht werden.
--
-- <h5>Diebstahleffekte</h5>
-- Die Effekte von Diebstählen können deaktiviert und mittels Event neu
-- geschrieben werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field EntitySpawned Ein Entity wurde aus einem Spawner erzeugt. (Parameter: EntityID, PlayerID, SpawnerID)
-- @field SettlerAttracted Ein Siedler kommt in die Siedlung. (Parameter: EntityID, PlayerID)
-- @field EntityDestroyed Ein Entity wurde zerstört. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID, PlayerID)
-- @field EntityHurt Ein Entity wurde angegriffen. (Parameter: AttackedEntityID, AttackedPlayerID, AttackingEntityID, AttackingPlayerID)
-- @field EntityKilled Ein Entity wurde getötet. (Parameter: KilledEntityID, KilledPlayerID, KillerEntityID, KillerPlayerID)
-- @field EntityOwnerChanged Ein Entity wechselt den Besitzer. (Parameter: OldIDList, OldPlayer, NewIDList, OldPlayer)
-- @field EntityResourceChanged Resourcen im Entity verändern sich. (Parameter: EntityID, GoodType, OldAmount, NewAmount)
-- @field BuildingConstructed Ein Gebäude wurde fertiggestellt. (Parameter: BuildingID, PlayerID)
-- @field BuildingUpgraded Ein Gebäude wurde aufgewertet. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field BuildingUpgradeCollapsed Eine Ausbaustufe eines Gebäudes wurde zerstört. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field ThiefInfiltratedBuilding Ein Dieb hat ein Gebäude infiltriert. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID)
-- @field ThiefDeliverEarnings Ein Dieb liefert seine Beute ab. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID, GoldAmount)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- -------------------------------------------------------------------------- --
-- Search

---
-- Findet <u>alle</u> Entities.
--
-- @param[type=number]  _PlayerID               (Optional) ID des Besitzers
-- @param[type=boolean] _WithoutDefeatResistant (Optional) Niederlageresistente Entities filtern
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- -- ALLE Entities
-- local Result = API.SearchEntities();
-- -- Alle Entities von Spieler 5.
-- local Result = API.SearchEntities(5);
--
function API.SearchEntities(_PlayerID, _WithoutDefeatResistant)
    if _WithoutDefeatResistant == nil then
        _WithoutDefeatResistant = false;
    end
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _WithoutDefeatResistant then
            if (Logic.IsBuilding(_ID) or Logic.IsWall(_ID)) and Logic.IsConstructionComplete(_ID) == 0 then
                return false;
            end
            local Type = Logic.GetEntityType(_ID);
            local TypeName = Logic.GetEntityType(Type);
            if TypeName and (string.find(TypeName, "^S_") or string.find(TypeName, "^XD_")) then
                return false;
            end
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities des Typs in einem Gebiet.
--
-- @param[type=number] _Area     Größe des Suchgebiet
-- @param              _Position Mittelpunkt (EntityID, Skriptname oder Table)
-- @param[type=number] _Type     Typ des Entity
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInArea(5000, "Busches", Entities.R_HerbBush);
--
function API.SearchEntitiesOfTypeInArea(_Area, _Position, _Type, _PlayerID)
    return API.SearchEntitiesInArea(_Area, _Position, _PlayerID, _Type, nil);
end

---
-- Findet alle Entities der Kategorie in einem Gebiet.
--
-- @param[type=number] _Area     Größe des Suchgebiet
-- @param              _Position Mittelpunkt (EntityID, Skriptname oder Table)
-- @param[type=number] _Category Category des Entity
-- @param[type=number] _PlayerID (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInArea(5000, "City", EntityCategories.CityBuilding, 2);
--
function API.SearchEntitiesOfCategoryInArea(_Area, _Position, _Category, _PlayerID)
    return API.SearchEntitiesInArea(_Area, _Position, _PlayerID, nil, _Category);
end

-- Not supposed to be used directly!
function API.SearchEntitiesInArea(_Area, _Position, _PlayerID, _Type, _Category)
    local Position = _Position;
    if type(Position) ~= "table" then
        Position = GetPosition(Position);
    end
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _Type and Logic.GetEntityType(_ID) ~= _Type then
            return false;
        end
        if _Category and Logic.IsEntityInCategory(_ID, _Category) == 0 then
            return false;
        end
        if API.GetDistance(_ID, Position) > _Area then
            return false;
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities des Typs in einem Territorium.
--
-- @param[type=number] _Territory Territorium für die Suche
-- @param[type=number] _Type      Typ des Entity
-- @param[type=number] _PlayerID  (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInTerritory(7, Entities.R_HerbBush);
--
function API.SearchEntitiesOfTypeInTerritory(_Territory, _Type, _PlayerID)
    return API.SearchEntitiesInTerritory(_Territory, _PlayerID, _Type, nil);
end

---
-- Findet alle Entities der Kategorie in einem Territorium.
--
-- @param[type=number] _Territory Territorium für die Suche
-- @param[type=number] _Category  Category des Entity
-- @param[type=number] _PlayerID  (Optional) ID des Besitzers
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- local Result = API.SearchEntitiesInTerritory(7, EntityCategories.CityBuilding, 6);
--
function API.SearchEntitiesOfCategoryInTerritory(_Territory, _Category, _PlayerID)
    return API.SearchEntitiesInTerritory(_Territory, _PlayerID, nil, _Category);
end

-- Not supposed to be used directly!
function API.SearchEntitiesInTerritory(_Territory, _PlayerID, _Type, _Category)
    local Filter = function(_ID)
        if _PlayerID and Logic.EntityGetPlayer(_ID) ~= _PlayerID then
            return false;
        end
        if _Type and Logic.GetEntityType(_ID) ~= _Type then
            return false;
        end
        if _Category and Logic.IsEntityInCategory(_ID, _Category) == 0 then
            return false;
        end
        if _Territory and GetTerritoryUnderEntity(_ID) ~= _Territory then
            return false;
        end
        return true;
    end
    return API.CommenceEntitySearch(Filter);
end

---
-- Findet alle Entities deren Skriptname das Suchwort enthält.
--
-- @param[type=number] _Pattern Suchwort
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
-- @see API.CommenceEntitySearch
--
-- @usage
-- -- Findet alle Entities, deren Name mit "TreasureChest" beginnt.
-- local Result = API.SearchEntitiesByScriptname("^TreasureChest");
--
function API.SearchEntitiesByScriptname(_Pattern)
    _Filter = _Filter or function(_ID)
        local ScriptName = Logic.GetEntityName(_ID);
        if not string.find(ScriptName, _Pattern) then
            return false;
        end
        return true;
    end
    return ModuleEntity.Shared:IterateOverEntities(_Filter);
end

---
-- Führt eine benutzerdefinierte Suche nach Entities aus.
--
-- <b>Achtung</b>: Die Reihenfolge der Abfragen im Filter hat direkten
-- Einfluss auf die Dauer der Suche. Während Abfragen auf den Besitzer oder
-- den Typ schnell gehen, dauern Gebietssuchen lange! Es ist daher klug, zuerst
-- Kriterien auszuschließen, die schnell bestimmt werden können!
--
-- @param[type=function] _Filter Funktion zur Filterung
-- @return[type=table] Liste mit Ergebnissen
-- @within Suche
--
-- @usage
-- -- Es werden alle Kühe und Schafe von Spieler 1 gefunden, die nicht auf den
-- -- Territorien 7 und 15 sind.
-- local Result = API.CommenceEntitySearch(
--     function(_ID)
--         -- Nur Entities von Spieler 1 akzeptieren
--         if Logic.EntityGetPlayer(_ID) == 1 then
--             -- Nur Entities akzeptieren, die Kühe oder Schafe sind.
--             if Logic.IsEntityInCategory(_ID, EntityCategories.CattlePasture) == 1
--             or Logic.IsEntityInCategory(_ID, EntityCategories.SheepPasture) == 1 then
--                 -- Nur Entities akzeptieren, die nicht auf den Territorien 7 und 15 sind.
--                 local Territory = GetTerritoryUnderEntity(_ID);
--                 return Territory ~= 7 and Territory ~= 15;
--             end
--         end
--         return false;
--     end
-- );
--
function API.CommenceEntitySearch(_Filter)
    _Filter = _Filter or function(_ID)
        return true;
    end
    return ModuleEntity.Shared:IterateOverEntities(_Filter);
end

-- Compatibility option
-- FIXME: Realy needed? Don't they throw the old version in the script anyway?
function API.GetEntitiesOfCategoriesInTerritories(_PlayerID, _Category, _Territory)
    local p = (type(_PlayerID) == "table" and _PlayerID) or {_PlayerID};
    local c = (type(_Category) == "table" and _Category) or {_Category};
    local t = (type(_Territory) == "table" and _Territory) or {_Territory};
    local PlayerEntities = {};
    for i=1, #p, 1 do
        for j=1, #c, 1 do
            for k=1, #t, 1 do
                local Units = API.SearchEntitiesOfCategoryInTerritory(t[k], c[j], p[i]);
                PlayerEntities = Array_Append(PlayerEntities, Units);
            end
        end
    end
    return PlayerEntities;
end

-- -------------------------------------------------------------------------- --
-- Thief

---
-- Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableStorehouseEffect(true);
-- -- Aktivieren
-- API.ThiefDisableStorehouseEffect(false);
--
function API.ThiefDisableStorehouseEffect(_Flag)
    ModuleEntity.Global.DisableThiefStorehouseHeist = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCathedralEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCathedralEffect(false);
--
function API.ThiefDisableCathedralEffect(_Flag)
    ModuleEntity.Global.DisableThiefCathedralSabotage = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.
--
-- <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Dieb
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCisternEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCisternEffect(false);
--
function API.ThiefDisableCisternEffect(_Flag)
    ModuleEntity.Global.DisableThiefCisternSabotage = _Flag == true;
end

-- -------------------------------------------------------------------------- --

ModuleEntity = {
    Properties = {
        Name = "ModuleEntity",
        Version = "3.0.0 (BETA 2.0.0)",
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

