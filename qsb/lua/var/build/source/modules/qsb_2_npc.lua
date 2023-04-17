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

Swift:RegisterBehavior(B_Goal_NPC);

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Interaktion mit NPC-Charakteren.
--
-- Ein NPC ist ein Charakter, der durch den Helden eines Spielers angesprochen
-- werden kann. Auf das Ansprechen kann eine beliebige Aktion folgen. Mittels
-- einer Bedingung kann festgelegt werden, wer mit dem NPC sprechen kann und
-- unter welchen Umständen es nicht möglich ist.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field NpcInteraction  (Parameter: NpcEntityID, HeroEntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erstellt einen neuen NPC für den angegebenen Siedler.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
-- </tr>
-- <tr>
-- <td>Type</td>
-- <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
-- vorhanden, den Anzeigemodus des NPC Icon.</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Player</td>
-- <td>(number|table) Spieler, der/die mit dem NPC sprechen kann/können.</td>
-- </tr>
-- <tr>
-- <td>WrongPlayerAction</td>
-- <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroAction</td>
-- <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Data Definition des NPC
-- @return[type=table] NPC Table
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Einfachen NPC erstellen
-- MyNpc = API.NpcCompose {
--     Name     = "HansWurst",
--     Callback = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
-- @usage
-- -- Beispiel #2: NPC mit Bedingung erstellen
-- MyNpc = API.NpcCompose {
--     Name      = "HansWurst",
--     Condition = function(_Data)
--         local NpcID = GetID(_Data.Name);
--         -- prüfe irgend was
--         return MyConditon == true;
--     end
--     Callback  = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
-- @usage
-- -- Beispiel #3: NPC auf Spieler beschränken
-- MyNpc = API.NpcCompose {
--     Name              = "HansWurst",
--     Player            = {1, 2},
--     WrongPlayerAction = function(_Data)
--         API.Note("Ich rede nicht mit Euch!");
--     end,
--     Callback          = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
function API.NpcCompose(_Data)
    if GUI or not type(_Data) == "table" or not _Data.Name then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcCompose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    local Npc = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    if Npc ~= nil and Npc.Active then
        error("API.NpcCompose: '" .._Data.Name.. "' is already composed as NPC!");
        return;
    end
    if _Data.Type and (not type(_Data.Type) == "number" or (_Data.Type < 1 or _Data.Type > 4)) then
        error("API.NpcCompose: Type must be a value between 1 and 4!");
        return;
    end
    return ModuleNpcInteraction.Global:CreateNpc(_Data);
end

---
-- Entfernt den NPC komplett vom Entity. Das Entity bleibt dabei erhalten.
--
-- @param[type=table] _Data NPC Table
-- @within Anwenderfunktionen
-- @usage
-- API.NpcDispose(MyNpc);
--
function API.NpcDispose(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) ~= nil then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleNpcInteraction.Global:DestroyNpc(_Data);
end

---
-- Aktualisiert die Daten des NPC.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
-- </tr>
-- <tr>
-- <td>Type</td>
-- <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
-- vorhanden, den Anzeigemodus des NPC Icon.</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Player</td>
-- <td>(number) Spieler, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongPlayerAction</td>
-- <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroAction</td>
-- <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Active</td>
-- <td>(boolean) Steuert, ob der NPC aktiv ist.</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data NPC Table
-- @within Anwenderfunktionen
-- @usage
-- -- Einen NPC wieder aktivieren
-- MyNpc.Active = true;
-- MyNpc.TalkedTo = 0;
-- -- Die Aktion ändern
-- MyNpc.Callback = function(_Data)
--     -- mach was hier
-- end;
-- API.NpcUpdate(MyNpc);
--
function API.NpcUpdate(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) == nil then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleNpcInteraction.Global:UpdateNpc(_Data);
end

---
-- Prüft, ob der NPC gerade aktiv ist.
--
-- @param[type=table] _Data NPC Table
-- @return[type=boolean] NPC ist aktiv
-- @within Anwenderfunktionen
-- @usage
-- if API.NpcIsActive(MyNpc) then
--
function API.NpcIsActive(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    local NPC = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    if NPC == nil then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    return NPC.Active == true and API.IsEntityActiveNpc(_Data.Name);
end

---
-- Prüft, ob ein NPC schon gesprochen hat und optional auch mit wem.
--
-- @param[type=table]  _Data     NPC Table
-- @param[type=string] _Hero     (Optional) Skriptname des Helden
-- @param[type=number] _PlayerID (Optional) Spieler ID
-- @within Anwenderfunktionen
-- 
-- @usage
-- -- Beispiel #1: Wurde mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc) then
-- 
-- @usage
-- -- Beispiel #2: Spieler hat mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc, nil, 1) then
-- 
-- @usage
-- -- Beispiel #3: Held des Spielers hat mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc, "Marcus", 1) then
--
function API.NpcTalkedTo(_Data, _Hero, _PlayerID)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcTalkedTo: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) == nil then
        error("API.NpcTalkedTo: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    local NPC = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    local TalkedTo = NPC.TalkedTo ~= nil and NPC.TalkedTo ~= 0;
    if _Hero and TalkedTo then
        TalkedTo = NPC.TalkedTo == GetID(_Hero);
    end
    if _PlayerID and TalkedTo then
        TalkedTo = Logic.EntityGetPlayer(NPC.TalkedTo) == _PlayerID;
    end
    return TalkedTo;
end

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

