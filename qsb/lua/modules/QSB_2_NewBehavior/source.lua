-- -------------------------------------------------------------------------- --

ModuleBehaviorCollection = {
    Properties = {
        Name = "ModuleBehaviorCollection",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Data = {
            PlayerID = 1,
        },
        SoldierKillsCounter = {},
        VictoryWithPartyEntities = {},
    },
    Local = {
        Data = {},
    },

    Shared = {},
};

-- Global ------------------------------------------------------------------- --

function ModuleBehaviorCollection.Global:OnGameStart()
    for i= 0, 8 do
        self.SoldierKillsCounter[i] = {};
    end
    self:OverrideIsObjectiveCompleted();
    self:OverrideOnQuestTriggered();
end

function ModuleBehaviorCollection.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ThiefInfiltratedBuilding then
        self:OnThiefInfiltratedBuilding(arg[1], arg[2], arg[3], arg[4]);
    elseif _ID == QSB.ScriptEvents.ThiefDeliverEarnings then
        self:OnThiefDeliverEarnings(arg[1], arg[2], arg[3], arg[4], arg[5]);
    elseif _ID == QSB.ScriptEvents.EntityKilled then
        self:OnEntityKilled(arg[1], arg[2], arg[3], arg[4]);
    end
end

function ModuleBehaviorCollection.Global:OverrideOnQuestTriggered()
    QuestTemplate.Trigger_Orig_QSB_NewBehaviors = QuestTemplate.Trigger;
    QuestTemplate.Trigger = function(self)
        for b= 1, #self.Objectives, 1 do
            if self.Objectives[b] then
                -- Special Objective.DestroyEntities for spawners
                if self.Objectives[b].Type == Objective.DestroyEntities and self.Objectives[b].Data[1] == 3 then
                    -- Refill spawner once at quest start
                    if self.Objectives[b].Data[5] ~= true then
                        local SpawnPoints = self.Objectives[b].Data[2][0];
                        local SpawnAmount = self.Objectives[b].Data[3];
                        -- Delete remaining entities
                        for i=1, SpawnPoints, 1 do
                            local ID = GetID(self.Objectives[b].Data[2][i]);
                            local SpawnedEntities = {Logic.GetSpawnedEntities(ID)};
                            for j= 1, #SpawnedEntities, 1 do
                                DestroyEntity(SpawnedEntities[j]);
                            end
                        end
                        -- Spawn new entities and distribute them equally over
                        -- all spawner entities
                        while (SpawnAmount > 0) do
                            for i=1, SpawnPoints, 1 do
                                if SpawnAmount < 1 then
                                    break;
                                end
                                local ID = GetID(self.Objectives[b].Data[2][i]);
                                Logic.RespawnResourceEntity_Spawn(ID);
                                SpawnAmount = SpawnAmount -1;
                            end
                        end
                        -- Set icon
                        local CategoryDefinigEntity = Logic.GetSpawnedEntities(self.Objectives[b].Data[2][1]);
                        if not self.Objectives[b].Data[6] then
                            self.Objectives[b].Data[6] = {7, 12};
                            if Logic.IsEntityInCategory(CategoryDefinigEntity, EntityCategories.AttackableAnimal) == 1 then
                                self.Objectives[b].Data[6] = {13, 8};
                            end
                        end
                        self.Objectives[b].Data[5] = true;
                    end
                end
            end
        end
        self:Trigger_Orig_QSB_NewBehaviors();
    end
end

function ModuleBehaviorCollection.Global:OverrideIsObjectiveCompleted()
    QuestTemplate.IsObjectiveCompleted_Orig_QSB_NewBehaviors = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        if objective.Completed ~= nil then
            if objectiveType == Objective.DestroyEntities and objective.Data[1] == 3 then
                objective.Data[5] = nil;
            end
            return objective.Completed;
        end

        if objectiveType == Objective.DestroyEntities then
            if objective.Data[1] == 3 then
                objective.Completed = self:AreSpawnedQuestEntitiesDestroyed(objective);
            else
                return self:IsObjectiveCompleted_Orig_QSB_NewBehaviors(objective);
            end
        else
            return self:IsObjectiveCompleted_Orig_QSB_NewBehaviors(objective);
        end
    end

    QuestTemplate.AreSpawnedQuestEntitiesDestroyed = function(self, _Objective)
        if _Objective.Data[1] == 3 then
            local AllSpawnedEntities = {};
            for i=1, _Objective.Data[2][0], 1 do
                local ID = GetID(_Objective.Data[2][i]);
                AllSpawnedEntities = Array_Append(
                    AllSpawnedEntities,
                    {Logic.GetSpawnedEntities(ID)}
                );
            end
            if #AllSpawnedEntities == 0 then
                return true;
            end
        end
    end
end

function ModuleBehaviorCollection.Global:GetPossibleModels()
    local Data = {};
    -- Add generic models
    for k, v in pairs(Models) do
        if  not string.find(k, "Animals_")
        and not string.find(k, "MissionMap_")
        and not string.find(k, "R_Fish")
        and not string.find(k, "^[GEHUVXYZgt][ADSTfm]*")
        and not string.find(string.lower(k), "goods|tools_") then
            table.insert(Data, k);
        end
    end
    -- Add specific models
    table.insert(Data, "Effects_Dust01");
    table.insert(Data, "Effects_E_DestructionSmoke");
    table.insert(Data, "Effects_E_DustLarge");
    table.insert(Data, "Effects_E_DustSmall");
    table.insert(Data, "Effects_E_Firebreath");
    table.insert(Data, "Effects_E_Fireworks01");
    table.insert(Data, "Effects_E_Flies01");
    table.insert(Data, "Effects_E_Grasshopper03");
    table.insert(Data, "Effects_E_HealingFX");
    table.insert(Data, "Effects_E_Knight_Chivalry_Aura");
    table.insert(Data, "Effects_E_Knight_Plunder_Aura");
    table.insert(Data, "Effects_E_Knight_Song_Aura");
    table.insert(Data, "Effects_E_Knight_Trader_Aura");
    table.insert(Data, "Effects_E_Knight_Wisdom_Aura");
    table.insert(Data, "Effects_E_KnightFight");
    table.insert(Data, "Effects_E_NA_BlowingSand01");
    table.insert(Data, "Effects_E_NE_BlowingSnow01");
    table.insert(Data, "Effects_E_Oillamp");
    table.insert(Data, "Effects_E_SickBuilding");
    table.insert(Data, "Effects_E_Splash");
    table.insert(Data, "Effects_E_Torch");
    table.insert(Data, "Effects_Fire01");
    table.insert(Data, "Effects_FX_Lantern");
    table.insert(Data, "Effects_FX_SmokeBIG");
    table.insert(Data, "Effects_XF_BuildingSmoke");
    table.insert(Data, "Effects_XF_BuildingSmokeLarge");
    table.insert(Data, "Effects_XF_BuildingSmokeMedium");
    table.insert(Data, "Effects_XF_HouseFire");
    table.insert(Data, "Effects_XF_HouseFireLo");
    table.insert(Data, "Effects_XF_HouseFireMedium");
    table.insert(Data, "Effects_XF_HouseFireSmall");
    if g_GameExtraNo > 0 then
        table.insert(Data, "Effects_E_KhanaTemple_Fire");
        table.insert(Data, "Effects_E_Knight_Saraya_Aura");
    end
    -- Sort list
    table.sort(Data);
    return Data;
end

function ModuleBehaviorCollection.Global:OnThiefInfiltratedBuilding(_ThiefID, _PlayerID, _BuildingID, _BuildingPlayerID)
    for i=1, Quests[0] do
        if Quests[i] and Quests[i].State == QuestState.Active and Quests[i].ReceivingPlayer == _PlayerID then
            for j=1, Quests[i].Objectives[0] do
                if Quests[i].Objectives[j].Type == Objective.Custom2 then
                    if Quests[i].Objectives[j].Data[1].Name == "Goal_SpyOnBuilding" then
                        if GetID(Quests[i].Objectives[j].Data[1].Building) == _BuildingID then
                            Quests[i].Objectives[j].Data[1].Infiltrated = true;
                            if Quests[i].Objectives[j].Data[1].Delete then
                                DestroyEntity(_ThiefID);
                            end
                        end

                    elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealFromBuilding" then
                        local found;
                        local isCathedral = Logic.IsEntityInCategory(_BuildingID, EntityCategories.Cathedrals) == 1;
                        local isWarehouse = Logic.GetEntityType(_BuildingID) == Entities.B_StoreHouse;
                        if isWarehouse or isCathedral then
                            Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                        else
                            for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                                local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                                if stohlen[1] == _BuildingID and stohlen[2] == _ThiefID then
                                    found = true;
                                    break;
                                end
                            end
                        end
                        if not found then
                            table.insert(Quests[i].Objectives[j].Data[1].RobberList, {_BuildingID, _ThiefID});
                        end
                    end
                end
            end
        end
    end
end

function ModuleBehaviorCollection.Global:OnThiefDeliverEarnings(_ThiefID, _PlayerID, _BuildingID, _BuildingPlayerID, _GoldAmount)
    for i=1, Quests[0] do
        if Quests[i] and Quests[i].State == QuestState.Active and Quests[i].ReceivingPlayer == _PlayerID then
            for j=1, Quests[i].Objectives[0] do
                if Quests[i].Objectives[j].Type == Objective.Custom2 then
                    if Quests[i].Objectives[j].Data[1].Name == "Goal_StealFromBuilding" then
                        for k=1, #Quests[i].Objectives[j].Data[1].RobberList do
                            local stohlen = Quests[i].Objectives[j].Data[1].RobberList[k];
                            if stohlen[1] == GetID(Quests[i].Objectives[j].Data[1].Building) and stohlen[2] == _ThiefID then
                                Quests[i].Objectives[j].Data[1].SuccessfullyStohlen = true;
                                break;
                            end
                        end

                    elseif Quests[i].Objectives[j].Data[1].Name == "Goal_StealGold" then
                        local CurrentObjective = Quests[i].Objectives[j].Data[1];
                        if CurrentObjective.Target == -1 or CurrentObjective.Target == _BuildingPlayerID then
                            Quests[i].Objectives[j].Data[1].StohlenGold = Quests[i].Objectives[j].Data[1].StohlenGold + _GoldAmount;
                            if CurrentObjective.Printout then
                                API.Note(string.format(
                                    "%d/%d %s",
                                    CurrentObjective.StohlenGold,
                                    CurrentObjective.Amount,
                                    API.Localize({de = "Talern gestohlen",en = "gold stolen",})
                                ));
                            end
                        end
                    end
                end
            end
        end
    end
end

function ModuleBehaviorCollection.Global:OnEntityKilled(_KilledEntityID, _KilledPlayerID, _KillerEntityID, _KillerPlayerID)
    if _KilledPlayerID ~= 0 and _KillerPlayerID ~= 0 then
        self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] = self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] or 0
        if Logic.IsEntityInCategory(_KilledEntityID, EntityCategories.Soldier) == 1 then
            self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] = self.SoldierKillsCounter[_KillerPlayerID][_KilledPlayerID] +1
        end
    end
end

function ModuleBehaviorCollection.Global:GetEnemySoldierKillsOfPlayer(_PlayerID1, _PlayerID2)
    return self.SoldierKillsCounter[_PlayerID1][_PlayerID2] or 0;
end

-- Local -------------------------------------------------------------------- --

function ModuleBehaviorCollection.Local:OnGameStart()
    self:DisplayQuestObjective();
    self:GetEntitiesOrTerritoryList();
    self:OverrideSaveQuestEntityTypes();
    GUI.SendScriptCommand("ModuleBehaviorCollection.Global.Data.PlayerID = " .. GUI.GetPlayerID())
end

function ModuleBehaviorCollection.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

function ModuleBehaviorCollection.Local:DisplayQuestObjective()
    GUI_Interaction.DisplayQuestObjective_Orig_NewBehavior = GUI_Interaction.DisplayQuestObjective;
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end
        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);

        if QuestType == Objective.DestroyEntities and Quest.Objectives[1].Data[1] == 3 then
            local QuestObjectiveContainer = QuestObjectivesPath .. "/GroupEntityType";
            local QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestDestroy");
            local EntitiesList = GUI_Interaction.GetEntitiesOrTerritoryListForQuest( Quest, QuestType );
            local EntitiesAmount = #EntitiesList;
            if not Quest.Objectives[1].Data[5] and #EntitiesList == 0 then
                EntitiesAmount = Quest.Objectives[1].Data[2][0] * Quest.Objectives[1].Data[3];
            end

            XGUIEng.ShowWidget(QuestObjectiveContainer .. "/AdditionalCaption", 0);
            XGUIEng.ShowWidget(QuestObjectiveContainer .. "/AdditionalCondition", 0);
            SetIcon(QuestObjectiveContainer .. "/Icon", Quest.Objectives[1].Data[6]);
            XGUIEng.SetText(QuestObjectiveContainer .. "/Number", "{center}" .. EntitiesAmount);

            XGUIEng.SetText(QuestObjectiveContainer .. "/Caption", "{center}" .. QuestTypeCaption);
            XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
            GUI_Interaction.SetQuestTypeIcon(QuestObjectiveContainer .. "/QuestTypeIcon", _QuestIndex);
            if Quest.State == QuestState.Over then
                if Quest.Result == QuestResult.Success then
                    XGUIEng.ShowWidget(QuestObjectivesPath .. "/QuestOverSuccess", 1);
                elseif Quest.Result == QuestResult.Failure then
                    XGUIEng.ShowWidget(QuestObjectivesPath .. "/QuestOverFailure", 1);
                end
            end
            return;
        end
        GUI_Interaction.DisplayQuestObjective_Orig_NewBehavior(_QuestIndex, _MessageKey);
    end
end

function ModuleBehaviorCollection.Local:GetEntitiesOrTerritoryList()
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_NewBehavior = GUI_Interaction.GetEntitiesOrTerritoryListForQuest;
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest = function(_Quest, _QuestType)
        local IsEntity = true;
        local EntityOrTerritoryList = {};
        if _QuestType == Objective.DestroyEntities then
            if _Quest.Objectives[1].Data and _Quest.Objectives[1].Data[1] == 3 then
                for i=1, _Quest.Objectives[1].Data[2][0], 1 do
                    local ID = GetID(_Quest.Objectives[1].Data[2][i]);
                    EntityOrTerritoryList = Array_Append(EntityOrTerritoryList, {Logic.GetSpawnedEntities(ID)});
                end
                return EntityOrTerritoryList, IsEntity;
            end
        end
        return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_NewBehavior(_Quest, _QuestType);
    end
end

function ModuleBehaviorCollection.Local:OverrideSaveQuestEntityTypes()
    GUI_Interaction.SaveQuestEntityTypes_Orig_NewBehavior = GUI_Interaction.SaveQuestEntityTypes;
    GUI_Interaction.SaveQuestEntityTypes = function(_QuestIndex)
        if g_Interaction.SavedQuestEntityTypes[_QuestIndex] ~= nil then
            return;
        end
        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        if QuestType == Objective.DestroyEntities and Quest.Objectives[1].Data[1] == 3 then
            local EntitiesList = GUI_Interaction.GetEntitiesOrTerritoryListForQuest(Quest, QuestType);
            EntitiesList[0] = #EntitiesList;
            if EntitiesList ~= nil then
                g_Interaction.SavedQuestEntityTypes[_QuestIndex] = {};
                for i = 1, EntitiesList[0], 1 do
                    if Logic.IsEntityAlive(EntitiesList[i]) then
                        local EntityType = Logic.GetEntityType(GetID(EntitiesList[i]));
                        table.insert(g_Interaction.SavedQuestEntityTypes[_QuestIndex], i, EntityType);
                    end
                end
                return;
            end
        end
        GUI_Interaction.SaveQuestEntityTypes_Orig_NewBehavior(_QuestIndex)
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleBehaviorCollection);

