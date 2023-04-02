-- -------------------------------------------------------------------------- --

ModuleQuestJournal = {
    Properties = {
        Name = "ModuleQuestJournal",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Journal = {ID = 0},
        CustomInputAllowed = {},
        InputShown = {},
        TextColor  = "{tooltip}",
    };
    Local = {
        NextButton = "/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/TutorialNextButton",
        NextButtonIcon = {16, 10},
    };

    Shared = {
        Text = {
            Next  = {de = "Tagebuch anzeigen", en = "Show Journal", fr = "Afficher le journal"},
            Title = {de = "Tagebuch",          en = "Journal",      fr = "Journal"},
            Note  = {de = "Notiz",             en = "Note",         fr = "Note"},
        },
    };
};

-- -------------------------------------------------------------------------- --
-- Global Script

function ModuleQuestJournal.Global:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");
    QSB.ScriptEvents.QuestJournalPlayerNote = API.RegisterScriptEvent("Event_QuestJournalPlayerNote");

    API.RegisterScriptCommand("Cmd_TutorialNextClicked", function(_QuestName, _PlayerID)
        local CustomInput = self.CustomInputAllowed[_QuestName] == true;
        local FullText = self:FormatJournalEntry(_QuestName, _PlayerID);
        API.SendScriptEvent(
            QSB.ScriptEvents.QuestJournalDisplayed,
            _PlayerID, _QuestName, FullText, CustomInput
        );
    end);
end

function ModuleQuestJournal.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        self:ProcessChatInput(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.QuestJournalPlayerNote then
        self.InputShown[arg[1]] = arg[2];
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.QuestJournalPlayerNote, %d, "%s", %s)]],
            arg[1], arg[2], tostring(arg[3] == true)
        ));
    elseif _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.QuestJournalDisplayed, %d, "%s", "%s", %s)]],
            arg[1], arg[2], arg[3], tostring(arg[4])
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

function ModuleQuestJournal.Global:AssociateJournalEntryWithQuest(_ID, _Quest, _Flag)
    for i= 1, #self.Journal do
        if self.Journal[i].ID == _ID then
            self.Journal[i].Quests[_Quest] = _Flag == true;
        end
    end
end

function ModuleQuestJournal.Global:FormatJournalEntry(_QuestName, _PlayerID)
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
            local QuestName = self.InputShown[_PlayerID];
            local CustomInput = self.CustomInputAllowed[QuestName] == true;
            local ID = self:CreateJournalEntry(_Text, -1, false)
            self:AssociateJournalEntryWithQuest(ID, QuestName, true);
            local FullText = self:FormatJournalEntry(QuestName, _PlayerID);

            API.SendScriptEvent(
            QSB.ScriptEvents.QuestJournalDisplayed,
                _PlayerID, QuestName, FullText, CustomInput
            );
        end
        self.InputShown[_PlayerID] = nil;
    end
end

-- -------------------------------------------------------------------------- --
-- Local Script

function ModuleQuestJournal.Local:OnGameStart()
    QSB.ScriptEvents.QuestJournalDisplayed = API.RegisterScriptEvent("Event_QuestJournalDisplayed");
    QSB.ScriptEvents.QuestJournalPlayerNote = API.RegisterScriptEvent("Event_QuestJournalPlayerNote");

    self:OverrideUpdateVoiceMessage();
    self:OverrideTutorialNext();
    self:OverrideStringKeys();
    self:OverrideTimerButtons();
end

function ModuleQuestJournal.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.QuestJournalPlayerNote then
        if arg[1] == GUI.GetPlayerID() and arg[3] then
            API.ShowTextInput(arg[1], false);
        end
    elseif _ID == QSB.ScriptEvents.QuestJournalDisplayed then
        if arg[1] == GUI.GetPlayerID() then
            self:DisplayQuestJournal(arg[2], arg[1], arg[3], arg[4]);
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
                Text   = API.Localize{de = "Notiz", en = "Note", fr = "Note"},
                Action = function(_Data)
                    API.BroadcastScriptEventToGlobal("QuestJournalPlayerNote", _Data.PlayerID, _Data.QuestName, _Input);
                end
            }
        end
        ModuleRequester.Local:ShowTextWindow(Data);
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

function ModuleQuestJournal.Local:OverrideTimerButtons()
    GUI_Interaction.TimerButtonClicked_Orig_ModuleQuestJournal = GUI_Interaction.TimerButtonClicked;
    GUI_Interaction.TimerButtonClicked = function()
        if  XGUIEng.IsWidgetShown("/InGame/Root/Normal/ChatOptions") == 1
        and XGUIEng.IsWidgetShown("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget") == 1 then
            return;
        end
        GUI_Interaction.TimerButtonClicked_Orig_ModuleQuestJournal();
    end
end

function ModuleQuestJournal.Local:OverrideTutorialNext()
    GUI_Interaction.TutorialNext_Orig_ModuleQuestJournal = GUI_Interaction.TutorialNext;
    GUI_Interaction.TutorialNext = function()
        if g_Interaction.CurrentMessageQuestIndex then
            local QuestID = g_Interaction.CurrentMessageQuestIndex;
            local Quest = Quests[QuestID];
            API.BroadcastScriptCommand(
                QSB.ScriptCommands.TutorialNextClicked,
                Quest.Identifier,
                GUI.GetPlayerID()
            );
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

