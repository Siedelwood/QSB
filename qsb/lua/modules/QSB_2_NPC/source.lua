-- -------------------------------------------------------------------------- --

ModuleNpcInteraction = {
    Properties = {
        Name = "ModuleNpcInteraction",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Interactions = {},
        NPC = {},
        UseMarker = true,
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            StartConversation = {
                de = "Gespräch beginnen",
                en = "Start conversation",
                fr = "Commencer la conversation",
            }
        }
    };
};

QSB.Npc = {
    LastNpcEntityID = 0,
    LastHeroEntityID = 0,
}

-- Global Script ------------------------------------------------------------ --

function ModuleNpcInteraction.Global:OnGameStart()
    QSB.ScriptEvents.NpcInteraction = API.RegisterScriptEvent("Event_NpcInteraction");

    self:OverrideQuestFunctions();

    API.StartHiResJob(function()
        if Logic.GetTime() > 1 then
            ModuleNpcInteraction.Global:InteractionTriggerController();
        end
    end);
    API.StartJob(function()
        ModuleNpcInteraction.Global:InteractableMarkerController();
    end);
end

function ModuleNpcInteraction.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.NpcInteraction then
        QSB.Npc.LastNpcEntityID = arg[1];
        QSB.Npc.LastHeroEntityID = arg[2];
        self.Interactions[arg[1]] = self.Interactions[arg[1]] or {};
        if self.Interactions[arg[1]][arg[2]] then
            if Logic.GetCurrentTurn() <= self.Interactions[arg[1]][arg[2]] + 5 then
                return;
            end
        end
        self.Interactions[arg[1]][arg[2]] = Logic.GetCurrentTurn();
        self:PerformNpcInteraction(arg[3]);
    end
end

function ModuleNpcInteraction.Global:CreateNpc(_Data)
    self.NPC[_Data.Name] = {
        Name              = _Data.Name,
        Active            = true,
        Type              = _Data.Type or 1,
        Player            = _Data.Player or {1, 2, 3, 4, 5, 6, 7, 8},
        WrongPlayerAction = _Data.WrongPlayerAction,
        Hero              = _Data.Hero,
        WrongHeroAction   = _Data.WrongHeroAction,
        Distance          = _Data.Distance or 350,
        Condition         = _Data.Condition,
        Callback          = _Data.Callback,
        UseMarker         = self.UseMarker == true,
        MarkerID          = 0
    }
    self:UpdateNpc(_Data);
    return self.NPC[_Data.Name];
end

function ModuleNpcInteraction.Global:DestroyNpc(_Data)
    _Data.Active = false;
    self:UpdateNpc(_Data);
    self:DestroyMarker(_Data.Name);
    self.NPC[_Data.Name] = nil;
end

function ModuleNpcInteraction.Global:GetNpc(_ScriptName)
    return self.NPC[_ScriptName];
end

function ModuleNpcInteraction.Global:UpdateNpc(_Data)
    if not IsExisting(_Data.Name) then
        return;
    end
    if not self.NPC[_Data.Name] then
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, 0);
        return;
    end
    for k, v in pairs(_Data) do
        self.NPC[_Data.Name][k] = v;
    end
    self:CreateMarker(_Data.Name);
    if self.NPC[_Data.Name].Active then
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, self.NPC[_Data.Name].Type);
    else
        local EntityID = GetID(_Data.Name);
        Logic.SetOnScreenInformation(EntityID, 0);
    end
end

function ModuleNpcInteraction.Global:PerformNpcInteraction(_PlayerID)
    local ScriptName = Logic.GetEntityName(QSB.Npc.LastNpcEntityID);
    if self.NPC[ScriptName] then
        local Data = self.NPC[ScriptName];
        self:RotateActorsToEachother(_PlayerID);
        self:AdjustHeroTalkingDistance(Data.Distance);

        if not self:InteractionIsAppropriatePlayer(ScriptName, _PlayerID, QSB.Npc.LastHeroEntityID) then
            return;
        end
        Data.TalkedTo = QSB.Npc.LastHeroEntityID;

        if not self:InteractionIsAppropriateHero(ScriptName) then
            return;
        end

        if Data.Condition == nil or Data:Condition(_PlayerID, QSB.Npc.LastHeroEntityID) then
            Data.Active = false;
            if Data.Callback then
                Data:Callback(_PlayerID, QSB.Npc.LastHeroEntityID);
            end
        else
            Data.TalkedTo = 0;
        end

        self:UpdateNpc(Data);
    end
end

function ModuleNpcInteraction.Global:InteractionIsAppropriatePlayer(_ScriptName, _PlayerID, _HeroID)
    local Appropriate = true;
    if self.NPC[_ScriptName] then
        local Data = self.NPC[_ScriptName];
        if Data.Player ~= nil then
            if type(Data.Player) == "table" then
                Appropriate = table.contains(Data.Player, _PlayerID);
            else
                Appropriate = Data.Player == _PlayerID;
            end

            if not Appropriate then
                local LastTime = (Data.WrongHeroTick or 0) +1;
                local CurrentTime = Logic.GetTime();
                if Data.WrongPlayerAction and LastTime < CurrentTime then
                    self.NPC[_ScriptName].LastWongPlayerTick = CurrentTime;
                    Data:WrongPlayerAction(_PlayerID);
                end
            end
        end
    end
    return Appropriate;
end

function ModuleNpcInteraction.Global:InteractionIsAppropriateHero(_ScriptName)
    local Appropriate = true;
    if self.NPC[_ScriptName] then
        local Data = self.NPC[_ScriptName];
        if Data.Hero ~= nil then
            if type(Data.Hero) == "table" then
                Appropriate = table.contains(Data.Hero, Logic.GetEntityName(QSB.Npc.LastHeroEntityID));
            end
            Appropriate = Data.Hero == Logic.GetEntityName(QSB.Npc.LastHeroEntityID);

            if not Appropriate then
                local LastTime = (Data.WrongHeroTick or 0) +1;
                local CurrentTime = Logic.GetTime();
                if Data.WrongHeroAction and LastTime < CurrentTime then
                    self.NPC[_ScriptName].WrongHeroTick = CurrentTime;
                    Data:WrongHeroAction(QSB.Npc.LastHeroEntityID);
                end
            end
        end
    end
    return Appropriate;
end

function ModuleNpcInteraction.Global:GetEntityMovementTarget(_EntityID)
    local X = API.GetFloat(_EntityID, QSB.ScriptingValue.Destination.X);
    local Y = API.GetFloat(_EntityID, QSB.ScriptingValue.Destination.Y);
    return {X= X, Y= Y};
end

function ModuleNpcInteraction.Global:RotateActorsToEachother(_PlayerID)
    local PlayerKnights = {};
    Logic.GetKnights(_PlayerID, PlayerKnights);
    for k, v in pairs(PlayerKnights) do
        local Target = self:GetEntityMovementTarget(v);
        local x, y, z = Logic.EntityGetPos(QSB.Npc.LastNpcEntityID);
        if math.floor(Target.X) == math.floor(x) and math.floor(Target.Y) == math.floor(y) then
            x, y, z = Logic.EntityGetPos(v);
            Logic.MoveEntity(v, x, y);
            API.LookAt(v, QSB.Npc.LastNpcEntityID);
        end
    end
    API.LookAt(QSB.Npc.LastHeroEntityID, QSB.Npc.LastNpcEntityID);
    API.LookAt(QSB.Npc.LastNpcEntityID, QSB.Npc.LastHeroEntityID);
end

function ModuleNpcInteraction.Global:AdjustHeroTalkingDistance(_Distance)
    local Distance = _Distance * API.GetFloat(QSB.Npc.LastNpcEntityID, QSB.ScriptingValue.Size);
    if API.GetDistance(QSB.Npc.LastHeroEntityID, QSB.Npc.LastNpcEntityID) <= Distance * 0.7 then
        local Orientation = Logic.GetEntityOrientation(QSB.Npc.LastNpcEntityID);
        local x1, y1, z1 = Logic.EntityGetPos(QSB.Npc.LastHeroEntityID);
        local x2 = x1 + ((Distance * 0.5) * math.cos(math.rad(Orientation)));
        local y2 = y1 + ((Distance * 0.5) * math.sin(math.rad(Orientation)));
        local ID = Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity, x2, y2, 0, 0);
        local x3, y3, z3 = Logic.EntityGetPos(ID);
        Logic.MoveSettler(QSB.Npc.LastHeroEntityID, x3, y3);
        API.StartHiResJob( function(_HeroID, _NPCID, _Time)
            if Logic.GetTime() > _Time +0.5 and Logic.IsEntityMoving(_HeroID) == false then
                API.LookAt(_HeroID, _NPCID);
                API.LookAt(_NPCID, _HeroID);
                return true;
            end
        end, QSB.Npc.LastHeroEntityID, QSB.Npc.LastNpcEntityID, Logic.GetTime());
    end
end

function ModuleNpcInteraction.Global:OverrideQuestFunctions()
    GameCallback_OnNPCInteraction_Orig_QSB_ModuleNpcInteraction = GameCallback_OnNPCInteraction;
    GameCallback_OnNPCInteraction = function(_EntityID, _PlayerID, _KnightID)
        GameCallback_OnNPCInteraction_Orig_QSB_ModuleNpcInteraction(_EntityID, _PlayerID, _KnightID);

        local ClosestKnightID = _KnightID or ModuleNpcInteraction.Global:GetClosestKnight(_EntityID, _PlayerID);
        API.SendScriptEvent(QSB.ScriptEvents.NpcInteraction, _EntityID, ClosestKnightID, _PlayerID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.NpcInteraction, %d, %d, %d)]],
            _EntityID,
            ClosestKnightID,
            _PlayerID
        ));
    end

    QuestTemplate.RemoveQuestMarkers_Orig_ModuleNpcInteraction = QuestTemplate.RemoveQuestMarkers
    QuestTemplate.RemoveQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[1] ~= -65565 then
                    QuestTemplate.RemoveQuestMarkers_Orig_ModuleNpcInteraction(self);
                else
                    if self.Objectives[i].Data[4] then
                        API.NpcDispose(self.Objectives[i].Data[4].NpcInstance);
                        self.Objectives[i].Data[4].NpcInstance = nil;
                    end
                end
            else
                QuestTemplate.RemoveQuestMarkers_Orig_ModuleNpcInteraction(self);
            end
        end
    end

    QuestTemplate.ShowQuestMarkers_Orig_ModuleNpcInteraction = QuestTemplate.ShowQuestMarkers
    QuestTemplate.ShowQuestMarkers = function(self)
        for i=1, self.Objectives[0] do
            if self.Objectives[i].Type == Objective.Distance then
                if self.Objectives[i].Data[1] ~= -65565 then
                    QuestTemplate.ShowQuestMarkers_Orig_ModuleNpcInteraction(self);
                else
                    if not self.Objectives[i].Data[4].NpcInstance then
                        self.Objectives[i].Data[4].NpcInstance = API.NpcCompose {
                            Name   = self.Objectives[i].Data[3],
                            Hero   = self.Objectives[i].Data[2],
                            Player = self.ReceivingPlayer,
                        }
                    end
                end
            end
        end
    end

    QuestTemplate.IsObjectiveCompleted_Orig_ModuleNpcInteraction = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        local data = objective.Data;
        if objective.Completed ~= nil then
            return objective.Completed;
        end

        if objectiveType ~= Objective.Distance then
            return self:IsObjectiveCompleted_Orig_ModuleNpcInteraction(objective);
        else
            if data[1] == -65565 then
                if not IsExisting(data[3]) then
                    error(data[3].. " is dead! :(");
                    objective.Completed = false;
                else
                    if API.NpcTalkedTo(data[4].NpcInstance, data[2], self.ReceivingPlayer) then
                        objective.Completed = true;
                    end
                end
            else
                return self:IsObjectiveCompleted_Orig_ModuleNpcInteraction(objective);
            end
        end
    end
end

function ModuleNpcInteraction.Global:GetClosestKnight(_EntityID, _PlayerID)
    local KnightIDs = {};
    Logic.GetKnights(_PlayerID, KnightIDs);
    return API.GetClosestToTarget(_EntityID, KnightIDs);
end

function ModuleNpcInteraction.Global:ToggleMarkerUsage(_Flag)
    self.UseMarker = _Flag == true;
    for k, v in pairs(self.NPC) do
        self.NPC[k].UseMarker = _Flag == true;
        self:HideMarker(k);
    end
end

function ModuleNpcInteraction.Global:CreateMarker(_ScriptName)
    if self.NPC[_ScriptName] then
        local x,y,z = Logic.EntityGetPos(GetID(_ScriptName));
        local MarkerID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, 0, 0);
        DestroyEntity(self.NPC[_ScriptName].MarkerID);
        self.NPC[_ScriptName].MarkerID = MarkerID;
        self:HideMarker(_ScriptName);
    end
end

function ModuleNpcInteraction.Global:DestroyMarker(_ScriptName)
    if self.NPC[_ScriptName] then
        DestroyEntity(self.NPC[_ScriptName].MarkerID);
        self.NPC[_ScriptName].MarkerID = 0;
    end
end

function ModuleNpcInteraction.Global:HideMarker(_ScriptName)
    if self.NPC[_ScriptName] then
        if IsExisting(self.NPC[_ScriptName].MarkerID) then
            Logic.SetModel(self.NPC[_ScriptName].MarkerID, Models.Effects_E_NullFX);
            Logic.SetVisible(self.NPC[_ScriptName].MarkerID, false);
        end
    end
end

function ModuleNpcInteraction.Global:ShowMarker(_ScriptName)
    if self.NPC[_ScriptName] then
        if self.NPC[_ScriptName].UseMarker == true and IsExisting(self.NPC[_ScriptName].MarkerID) then
            local Size = API.GetFloat(_ScriptName, QSB.ScriptingValue.Size);
            API.SetFloat(self.NPC[_ScriptName].MarkerID, QSB.ScriptingValue.Size, Size);
            Logic.SetModel(self.NPC[_ScriptName].MarkerID, Models.Effects_E_Wealth);
            Logic.SetVisible(self.NPC[_ScriptName].MarkerID, true);
        end
    end
end

function ModuleNpcInteraction.Global:GetEntityMovingTarget(_EntityID)
    local x = API.GetFloat(_EntityID, QSB.ScriptingValue.Destination.X);
    local y = API.GetFloat(_EntityID, QSB.ScriptingValue.Destination.Y);
    return {X= x, Y= y};
end

function ModuleNpcInteraction.Global:InteractionTriggerController()
    for PlayerID = 1, 8, 1 do
        local PlayersKnights = {};
        Logic.GetKnights(PlayerID, PlayersKnights);
        for i= 1, #PlayersKnights, 1 do
            if Logic.GetCurrentTaskList(PlayersKnights[i]) == "TL_NPC_INTERACTION" then
                for k, v in pairs(self.NPC) do
                    if v.Distance >= 350 then
                        local Target = self:GetEntityMovementTarget(PlayersKnights[i]);
                        local x2, y2 = Logic.EntityGetPos(GetID(k));
                        if math.floor(Target.X) == math.floor(x2) and math.floor(Target.Y) == math.floor(y2) then
                            if IsExisting(k) and IsNear(PlayersKnights[i], k, v.Distance) then
                                GameCallback_OnNPCInteraction(GetID(k), PlayerID, PlayersKnights[i]);
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

function ModuleNpcInteraction.Global:InteractableMarkerController()
    for k, v in pairs(self.NPC) do
        if v.Active then
            if  v.UseMarker and IsExisting(v.MarkerID)
            and API.GetInteger(v.MarkerID, QSB.ScriptingValue.Visible) == 801280 then
                self:HideMarker(k);
            else
                self:ShowMarker(k);
            end
            local x1,y1,z1 = Logic.EntityGetPos(v.MarkerID);
            local x2,y2,z2 = Logic.EntityGetPos(GetID(k));
            if math.abs(x1-x2) > 20 or math.abs(y1-y2) > 20 then
                Logic.DEBUG_SetPosition(v.MarkerID, x2, y2);
            end
        end
    end
end

-- Local Script ------------------------------------------------------------- --

function ModuleNpcInteraction.Local:OnGameStart()
    QSB.ScriptEvents.NpcInteraction = API.RegisterScriptEvent("Event_NpcInteraction");

    self:OverrideQuestFunctions();
end

function ModuleNpcInteraction.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.NpcInteraction then
        QSB.Npc.LastNpcEntityID = arg[1];
        QSB.Npc.LastHeroEntityID = arg[2];
    end
end

function ModuleNpcInteraction.Local:OverrideQuestFunctions()
    GUI_Interaction.DisplayQuestObjective_Orig_ModuleNpcInteraction = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end

        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
        local QuestObjectiveContainer;
        local QuestTypeCaption;

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Distance then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            if Quest.Objectives[1].Data[1] == -65565 then
                QuestObjectiveContainer = QuestObjectivesPath .. "/Distance";
                QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestMoveHere");
                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{7,10});

                local MoverEntityID = GetID(Quest.Objectives[1].Data[2]);
                local MoverEntityType = Logic.GetEntityType(MoverEntityID);
                local MoverIcon = g_TexturePositions.Entities[MoverEntityType];
                if not MoverIcon then
                    MoverIcon = {7, 9};
                end
                SetIcon(QuestObjectiveContainer .. "/IconMover", MoverIcon);

                local TargetEntityID = GetID(Quest.Objectives[1].Data[3]);
                local TargetEntityType = Logic.GetEntityType(TargetEntityID);
                local TargetIcon = g_TexturePositions.Entities[TargetEntityType];
                if not TargetIcon then
                    TargetIcon = {14, 10};
                end

                local IconWidget = QuestObjectiveContainer .. "/IconTarget";
                local ColorWidget = QuestObjectiveContainer .. "/TargetPlayerColor";

                SetIcon(IconWidget, TargetIcon);
                XGUIEng.SetMaterialColor(ColorWidget, 0, 255, 255, 255, 0);

                SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{16,12});
                local caption = ModuleNpcInteraction.Shared.Text.StartConversation;
                QuestTypeCaption = API.Localize(caption);

                XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
                XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
            else
                GUI_Interaction.DisplayQuestObjective_Orig_ModuleNpcInteraction(_QuestIndex, _MessageKey);
            end
        else
            GUI_Interaction.DisplayQuestObjective_Orig_ModuleNpcInteraction(_QuestIndex, _MessageKey);
        end
    end

    GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleNpcInteraction = GUI_Interaction.GetEntitiesOrTerritoryListForQuest
    GUI_Interaction.GetEntitiesOrTerritoryListForQuest = function( _Quest, _QuestType )
        local EntityOrTerritoryList = {}
        local IsEntity = true

        if _QuestType == Objective.Distance then
            if _Quest.Objectives[1].Data[1] == -65565 then
                local Entity = GetID(_Quest.Objectives[1].Data[3]);
                table.insert(EntityOrTerritoryList, Entity);
            else
                return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleNpcInteraction(_Quest, _QuestType);
            end

        else
            return GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_ModuleNpcInteraction(_Quest, _QuestType);
        end
        return EntityOrTerritoryList, IsEntity
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleNpcInteraction);

