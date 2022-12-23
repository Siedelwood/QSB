--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Grundlegende Steuerung von Quests mittels Funktionen und Events.
-- @set sort=true
-- @local
--

Revision.Quest = {}

function Revision.Quest:Initalize()
    QSB.ScriptEvents.QuestFailure = Revision.Event:CreateScriptEvent("Event_QuestFailure");
    QSB.ScriptEvents.QuestInterrupt = Revision.Event:CreateScriptEvent("Event_QuestInterrupt");
    QSB.ScriptEvents.QuestReset = Revision.Event:CreateScriptEvent("Event_QuestReset");
    QSB.ScriptEvents.QuestSuccess = Revision.Event:CreateScriptEvent("Event_QuestSuccess");
    QSB.ScriptEvents.QuestTrigger = Revision.Event:CreateScriptEvent("Event_QuestTrigger");

    if Revision.Environment == QSB.Environment.GLOBAL then
        self:OverrideQuestSystemGlobal();
    end
end

function Revision.Quest:OnSaveGameLoaded()
end

function Revision.Quest:OverrideQuestSystemGlobal()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Revision.Quest:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
        Revision.Quest:SendQuestStateEvent(_quest.Identifier, "QuestTrigger");
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_Quest)
        _Quest:Interrupt_Orig_QSB_Core();

        for i=1, _Quest.Objectives[0] do
            if _Quest.Objectives[i].Type == Objective.Custom2 and _Quest.Objectives[i].Data[1].Interrupt then
                _Quest.Objectives[i].Data[1]:Interrupt(_Quest, i);
            end
        end
        for i=1, _Quest.Triggers[0] do
            if _Quest.Triggers[i].Type == Triggers.Custom2 and _Quest.Triggers[i].Data[1].Interrupt then
                _Quest.Triggers[i].Data[1]:Interrupt(_Quest, i);
            end
        end

        Revision.Quest:SendQuestStateEvent(_Quest.Identifier, "QuestInterrupt");
    end

    QuestTemplate.Fail_Orig_QSB_Core = QuestTemplate.Fail;
    QuestTemplate.Fail = function(_Quest)
        _Quest:Fail_Orig_QSB_Core();
        Revision.Quest:SendQuestStateEvent(_Quest.Identifier, "QuestFailure");
    end

    QuestTemplate.Success_Orig_QSB_Core = QuestTemplate.Success;
    QuestTemplate.Success = function(_Quest)
        _Quest:Success_Orig_QSB_Core();
        Revision.Quest:SendQuestStateEvent(_Quest.Identifier, "QuestSuccess");
    end
end

function Revision.Quest:SendQuestStateEvent(_QuestName, _StateName)
    local QuestID = API.GetQuestID(_QuestName);
    if Quests[QuestID] then
        Revision.Event:DispatchScriptEvent(QSB.ScriptEvents[_StateName], QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Event:DispatchScriptEvent(QSB.ScriptEvents["%s"], %d)]],
            _StateName,
            QuestID
        ));
    end
end

function Revision.Quest:ChangeCustomQuestCaptionText(_Text, _Quest)
    if _Quest and _Quest.Visible then
        _Quest.QuestDescription = _Text;
        Logic.ExecuteInLuaLocalState([[
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
            local identifier = "]].._Quest.Identifier..[["
            for i=1, Quests[0] do
                if Quests[i].Identifier == identifier then
                    local text = Quests[i].QuestDescription
                    XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                    break
                end
            end
        ]]);
    end
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- @param[type=string] _Name Name des Quest
-- @return[type=number] ID des Quest
-- @within Quest
--
function API.GetQuestID(_Name)
    if type(_Name) == "number" then
        return _Name;
    end
    for k, v in pairs(Quests) do
        if v and k > 0 then
            if v.Identifier == _Name then
                return k;
            end
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob zu der angegebenen ID ein Quest existiert. Wird ein Questname
-- angegeben wird dessen Quest-ID ermittelt und geprüft.
--
-- @param[type=number] _QuestID ID oder Name des Quest
-- @return[type=boolean] Quest existiert
-- @within Quest
--
function API.IsValidQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[API.GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidQuest;

---
-- Prüft den angegebenen Questnamen auf verbotene Zeichen.
--
-- @param[type=number] _Name Name des Quest
-- @return[type=boolean] Name ist gültig
-- @within Quest
--
function API.IsValidQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_ @ÄÖÜäöüß]+$") ~= nil;
end
IsValidQuestName = API.IsValidQuestName;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.FailQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Fail();
        -- Note: Event is send in QuestTemplate:Fail()!
    end
end

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.RestartQuest(_QuestName, _NoMessage)
    -- All changes on default behavior must be considered in this function.
    -- When a default behavior is changed in a module this function must be
    -- changed as well.

    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("restart quest " .._QuestName);
        end

        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;

                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil;
                    data[4] = nil;
                    data[5] = nil;
                    data[9] = nil;

                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil;

                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil;
                    end

                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 2 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 3 then
                    objective.Data[4] = nil;
                    objective.Data[5] = nil;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i);
                end
            end
        end

        local function resetCustom(_type, _customType)
            local Quest = Quest;
            local behaviors = Quest[_type];
            if behaviors then
                for i = 1, behaviors[0] do
                    local behavior = behaviors[i];
                    if behavior.Type == _customType then
                        local behaviorDef = behavior.Data[1];
                        if behaviorDef and behaviorDef.Reset then
                            behaviorDef:Reset(Quest, i);
                        end
                    end
                end
            end
        end

        resetCustom("Triggers", Triggers.Custom2);
        resetCustom("Rewards", Reward.Custom);
        resetCustom("Reprisals", Reprisal.Custom);

        Quest.Result = nil;
        local OldQuestState = Quest.State;
        Quest.State = QuestState.NotTriggered;
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")");
        if OldQuestState == QuestState.Over then
            Quest.Job = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "Quest_Loop", 1, 0, {Quest.QueueID});
        end
        -- Note: Send the event
        Revision.Event:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Revision.Event:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, %d)",
            QuestID
        ));
        return QuestID, Quest;
    end
end

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.StartQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        Quest:Trigger();
        -- Note: Event is send in QuestTemplate:Trigger()!
    end
end

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.StopQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
        -- Note: Event is send in QuestTemplate:Interrupt()!
    end
end

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _NoMessage Meldung nicht anzeigen
-- @within Quest
--
function API.WinQuest(_QuestName, _NoMessage)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _NoMessage then
            Logic.DEBUG_AddNote("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Success();
        -- Note: Event is send in QuestTemplate:Success()!
    end
end

