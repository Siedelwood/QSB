--[[
Swift_4_QuestJournal/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleQuestJournal = {
    Properties = {
        Name = "ModuleQuestJournal",
    },

    Global = {
        Journal = {ID = 0},
        CustomInputAllowed = {},
        InputShown = {},
        TextColor  = "{tooltip}",
    };
    Local = {
        CurrentJournalEntry = nil,
        NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
        NextButtonIcon = {16, 10},
    };
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Next  = { de = "Tagebuch anzeigen", en = "Show Journal", fr = "Afficher le journal" },
            Title = { de = "Tagebuch",          en = "Journal",      fr = "Journal"},
            Note  = { de = "Notiz",             en = "Note",         fr = "Note"},
        },
    };
};

-- Global Script ---------------------------------------------------------------

function ModuleQuestJournal.Global:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");
    QSB.ScriptEvents.QuestJournalPlayerNote = API.RegisterScriptEvent("Event_QuestJournalPlayerNote");
end

function ModuleQuestJournal.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ChatClosed then
        self:ProcessChatInput(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.QuestJournalPlayerNote then
        self.InputShown[arg[1]] = arg[2];
    elseif _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        local Info = self:DisplayJournalEntry(arg[1], arg[2]);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.QuestJournalDisplayed, "%s", %d, "%s", %s)]],
            arg[1],
            arg[2],
            Info,
            tostring(self.CustomInputAllowed[arg[1]] ~= nil)
        ));
    end
end

function ModuleQuestJournal.Global:CreateJournalEntry(_Text, _Rank, _AlwaysVisible)
    self.Journal.ID = self.Journal.ID +1;
    table.insert(self.Journal, {
        ID            = self.Journal.ID,
        AlwaysVisible = _AlwaysVisible == true,
        Quests        = {},
        Rank          = _Rank,
        _Text
    });
    return self.Journal.ID;
end

function ModuleQuestJournal.Global:GetJournalEntry(_ID)
    for i= 1, #self.Journal do
        if self.Journal[i].ID == _ID then
            return self.Journal[i];
        end
    end
end

function ModuleQuestJournal.Global:UpdateJournalEntry(_ID, _Text, _Rank, _AlwaysVisible, _Deleted)
    for i= 1, #self.Journal do
        if self.Journal[i].ID == _ID then
            self.Journal[i].AlwaysVisible = _AlwaysVisible == true;
            self.Journal[i].Deleted       = _Deleted == true;
            self.Journal[i].Rank          = _Rank;

            self.Journal[i][1] = self.Journal[i][1] or _Text;
        end
    end
end

function ModuleQuestJournal.Global:AssociateJournalEntryToQuest(_ID, _Quest, _Flag)
    for i= 1, #self.Journal do
        if self.Journal[i].ID == _ID then
            self.Journal[i].Quests[_Quest] = _Flag == true;
        end
    end
end

function ModuleQuestJournal.Global:DisplayJournalEntry(_QuestName, _PlayerID)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest and Quest.QuestNotes and Quest.ReceivingPlayer == _PlayerID then
        local Journal = self:GetJournalEntriesSorted();
        local SeperateImportant = false;
        local SeperateNormal = false;
        local Info = "";
        for i= 1, #Journal, 1 do
            if Journal[i].AlwaysVisible or Journal[i].Quests[_QuestName] then
                if not Journal[i].Deleted then
                    local Text = API.ConvertPlaceholders(API.Localize(Journal[i][1]));

                    if Journal[i].Rank == 1 then
                        Text = "{scarlet}" .. Text .. self.TextColor;
                        SeperateImportant = true;
                    end
                    if Journal[i].Rank == 0 then
                        if SeperateImportant then
                            SeperateImportant = false;
                            Text = "{cr}----------{cr}{cr}" .. Text;
                        end
                        SeperateNormal = true;
                    end
                    -- Unused. Reserved for future notes by the player.
                    if Journal[i].Rank == -1 then
                        local Color = "";
                        if SeperateNormal then
                            SeperateNormal = false;
                            Color = "{violet}";
                            Text = "{cr}----------{cr}{cr}" .. Text;
                        end
                        Text = Color .. Text .. self.TextColor;
                    end

                    Info = Info .. ((Info ~= "" and "{cr}") or "") .. Text;
                end
            end
        end
        return Info;
    end
end

function ModuleQuestJournal.Global:GetJournalEntriesSorted()
    local Journal = {};
    for i= 1, #self.Journal, 1 do
        table.insert(Journal, self.Journal[i]);
    end
    table.sort(Journal, function(a, b)
        return a.Rank > b.Rank;
    end)
    return Journal;
end

function ModuleQuestJournal.Global:ProcessChatInput(_Text, _PlayerID)
    if self.InputShown[_PlayerID] then
        if _Text and _Text ~= "" then
            local ID = self:CreateJournalEntry(_Text, -1, false)
            self:AssociateJournalEntryToQuest(ID, self.InputShown[_PlayerID], true);
        end
        self.InputShown[_PlayerID] = nil;
    end
end

-- Local Script ----------------------------------------------------------------

function ModuleQuestJournal.Local:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");
    QSB.ScriptEvents.QuestJournalPlayerNote = API.RegisterScriptEvent("Event_QuestJournalPlayerNote");

    self:OverrideUpdateVoiceMessage();
    self:OverrideTutorialNext();
    self:OverrideStringKeys();
end

function ModuleQuestJournal.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        self:DisplayQuestJournal(arg[1], arg[2], arg[3], arg[4]);
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if arg[2] == GUI.GetPlayerID() then
            if self.CurrentJournalEntry then
                local Data = table.copy(self.CurrentJournalEntry);
                self.CurrentJournalEntry = nil;
                API.BroadcastScriptEventToGlobal(
                    QSB.ScriptEvents.QuestJournalDisplayed,
                    Data.QuestName,
                    GUI.GetPlayerID()
                );
            end
        end
    end
end

function ModuleQuestJournal.Local:DisplayQuestJournal(_QuestName, _PlayerID, _Info, _Input)
    if _Info and GUI.GetPlayerID() == _PlayerID then
        local Title = API.Localize(ModuleQuestJournal.Shared.Text.Title);
        local Data = {
            PlayerID  = _PlayerID,
            Caption   = Title,
            Content   = API.ConvertPlaceholders(_Info),
            QuestName = _QuestName
        }
        if _Input then
            Data.Button = {
                Text   = API.Localize{ de = "Notiz", en = "Note", fr = "Note" },
                Action = function(_Data)
                    API.BroadcastScriptEventToGlobal(QSB.ScriptEvents.QuestJournalPlayerNote, _Data.PlayerID, _Data.QuestName);
                    API.ShowTextInput(_Data.PlayerID, false);
                end
            }
        end
        self.CurrentJournalEntry = Data;
        ModuleInputOutputCore.Local:ShowTextWindow(Data);
    end
end

function ModuleQuestJournal.Local:OverrideUpdateVoiceMessage()
    GUI_Interaction.UpdateVoiceMessage_Orig_ModuleQuestJournal = GUI_Interaction.UpdateVoiceMessage;
    GUI_Interaction.UpdateVoiceMessage = function()
        GUI_Interaction.UpdateVoiceMessage_Orig_ModuleQuestJournal();
        if not QuestLog.IsQuestLogShown() then
            if ModuleQuestJournal.Local:IsShowingJournalButton(g_Interaction.CurrentMessageQuestIndex) then
                XGUIEng.ShowWidget(ModuleQuestJournal.Local.NextButton, 1);
                SetIcon(
                    ModuleQuestJournal.Local.NextButton,
                    ModuleQuestJournal.Local.NextButtonIcon
                );
            else
                XGUIEng.ShowWidget(ModuleQuestJournal.Local.NextButton, 0);
            end
        end
    end
end

function ModuleQuestJournal.Local:IsShowingJournalButton(_ID)
    if not g_Interaction.CurrentMessageQuestIndex then
        return false;
    end
    local Quest = Quests[_ID];
    if type(Quest) == "table" and Quest.QuestNotes then
        return true;
    end
    return false;
end

function ModuleQuestJournal.Local:OverrideTutorialNext()
    GUI_Interaction.TutorialNext_Orig_ModuleQuestJournal = GUI_Interaction.TutorialNext;
    GUI_Interaction.TutorialNext = function()
        if g_Interaction.CurrentMessageQuestIndex then
            local QuestID = g_Interaction.CurrentMessageQuestIndex;
            local Quest = Quests[QuestID];
            API.BroadcastScriptEventToGlobal(QSB.ScriptEvents.QuestJournalDisplayed, Quest.Identifier, GUI.GetPlayerID());
        end
    end
end

function ModuleQuestJournal.Local:OverrideStringKeys()
    GetStringTableText_Orig_ModuleQuestJournal = XGUIEng.GetStringTableText;
    XGUIEng.GetStringTableText = function(_key)
        if _key == "UI_ObjectNames/TutorialNextButton" then
            return API.Localize(ModuleQuestJournal.Shared.Text.Next);
        end
        return GetStringTableText_Orig_ModuleQuestJournal(_key);
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleQuestJournal);

