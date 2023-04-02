--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Stellt Behavior bereit um die Tagebuchfunktion über den Assistenten nutzbar
-- zu machen.
--
-- @set sort=true
--

QSB.JournalEntryNameToQuestName = {};
QSB.JournalEntryNameToID = {};

-- -------------------------------------------------------------------------- --

---
-- Zeigt das Tagebuch für einen Quest an oder versteckt es.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _Active    Tagebuch ist aktiv
-- @within Reprisal
--
function Reprisal_JournalEnable(...)
    return B_Reprisal_JournalEnable:new(...);
end

B_Reprisal_JournalEnable = {
    Name = "Reprisal_JournalEnable",
    Description = {
        en = "Reprisal: Displays the journal for a quest or hides it.",
        de = "Vergeltung: Zeigt das Tagebuch für einen Quest an oder versteckt es.",
        fr = "Rétribution: Affiche ou cache le journal pour une quête.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name",     de = "Name Quest",     fr = "Nom de la quête" },
        { ParameterType.Custom,    en = "Journal active", de = "Tagebuch aktiv", fr = "Journal actif" },
    },
}

function B_Reprisal_JournalEnable:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_JournalEnable:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter;
    elseif (_Index == 1) then
        self.ActiveFlag = API.ToBoolean(_Parameter);
    end
end

function B_Reprisal_JournalEnable:CustomFunction(_Quest)
    API.ShowJournalForQuest(self.QuestName, self.ActiveFlag == true);
end

function B_Reprisal_JournalEnable:Debug(_Quest)
    if not API.IsValidQuest(GetQuestID(self.QuestName)) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": quest '" ..tostring(self.QuestName).."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_JournalEnable);

-- -------------------------------------------------------------------------- --

---
-- Zeigt das Tagebuch für einen Quest an oder versteckt es.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _Active    Tagebuch ist aktiv
-- @within Reward
--
function Reward_JournalEnable(...)
    return B_Reward_JournalEnable:new(...);
end

B_Reward_JournalEnable = Swift.LuaBase:CopyTable(B_Reprisal_JournalEnable);
B_Reward_JournalEnable.Name = "Reward_JournalEnable";
B_Reward_JournalEnable.Description.en = "Reward: Displays the journal for a quest or hides it.";
B_Reward_JournalEnable.Description.de = "Lohn: Zeigt das Tagebuch für einen Quest an oder versteckt es.";
B_Reward_JournalEnable.Description.fr = "Récompense: Affiche ou cache le journal d'une quête.";
B_Reward_JournalEnable.GetReprisalTable = nil;

B_Reward_JournalEnable.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_JournalEnable);

-- -------------------------------------------------------------------------- --

---
-- Schreibt einen Tagebucheintrag zu dem angegebenen Quest.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _EntryName Name des Eintrag
-- @param[type=string] _EntryText Text des Eintrag
-- @within Reprisal
--
function Reprisal_JournalWrite(...)
    return B_Reprisal_JournalWrite:new(...);
end

B_Reprisal_JournalWrite = {
    Name = "Reprisal_JournalWrite",
    Description = {
        en = "Reprisal: Adds or alters a journal entry to a quest.",
        de = "Vergeltung: Schreibt oder ändert einen Tagebucheintrag.",
        fr = "Rétribution: Écrit ou modifie une entrée de journal.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Name Quest",   fr = "Nom de la quête" },
        { ParameterType.Default,   en = "Entry name", de = "Name Eintrag", fr = "Nom de l'entrée" },
        { ParameterType.Default,   en = "Entry text", de = "Text Eintrag", fr = "Texte de l'entrée" },
    },
}

function B_Reprisal_JournalWrite:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_JournalWrite:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter;
    elseif (_Index == 1) then
        self.EntryName = _Parameter;
    elseif (_Index == 2) then
        self.EntryText = _Parameter;
    end
end

function B_Reprisal_JournalWrite:CustomFunction(_Quest)
    if QSB.JournalEntryNameToQuestName[self.EntryName] then
        local EntryID = QSB.JournalEntryNameToID[self.EntryName];
        API.AlterJournalEntry(EntryID, self.EntryText);
    else
        local EntryID = API.CreateJournalEntry(self.EntryText);
        API.AddJournalEntryToQuest(EntryID, self.QuestName);
        QSB.JournalEntryNameToQuestName[self.EntryName] = self.QuestName;
        QSB.JournalEntryNameToID[self.EntryName] = EntryID;
    end
end

function B_Reprisal_JournalWrite:Debug(_Quest)
    if not API.IsValidQuest(GetQuestID(self.QuestName)) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": quest '" ..tostring(self.QuestName).."' does not exist!");
        return true;
    end
    if QSB.JournalEntryNameToQuestName[self.EntryName] ~= self.QuestName then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry name '" ..tostring(self.EntryName).."' is already in use in another quest!");
        return true;
    end
    if not QSB.JournalEntryNameToID[self.EntryName] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry '" ..tostring(self.EntryName).."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_JournalWrite);

-- -------------------------------------------------------------------------- --

---
-- Schreibt einen Tagebucheintrag zu dem angegebenen Quest.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _EntryName Name des Eintrag
-- @param[type=string] _EntryText Text des Eintrag
-- @within Reward
--
function Reward_JournalWrite(...)
    return B_Reward_JournalWrite:new(...);
end

B_Reward_JournalWrite = Swift.LuaBase:CopyTable(B_Reprisal_JournalWrite);
B_Reward_JournalWrite.Name = "Reward_JournalWrite";
B_Reward_JournalWrite.Description.en = "Reward: Adds or alters a journal entry to a quest.";
B_Reward_JournalWrite.Description.de = "Lohn: Schreibt oder ändert einen Tagebucheintrag.";
B_Reward_JournalWrite.Description.de = "Récompense: Écrit ou modifie une entrée de journal.";
B_Reward_JournalWrite.GetReprisalTable = nil;

B_Reward_JournalWrite.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_JournalWrite);

-- -------------------------------------------------------------------------- --

---
-- Entfernt einen Tagebucheintrag von einem Quest.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _EntryName Name des Entry
-- @within Reprisal
--
function Reprisal_JournalRemove(...)
    return B_Reprisal_JournalRemove:new(...);
end

B_Reprisal_JournalRemove = {
    Name = "Reprisal_JournalRemove",
    Description = {
        en = "Reprisal: Remove a journal entry from a quest.",
        de = "Vergeltung: Entfernt einen Tagebucheintrag vom Quest.",
        fr = "Rétribution: Supprime une entrée de journal de la quête.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name", de = "Name Quest",   fr = "Nom de la quête" },
        { ParameterType.Default,   en = "Entry name", de = "Name Eintrag", fr = "Nom de l'entrée" },
    },
}

function B_Reprisal_JournalRemove:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_JournalRemove:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter;
    elseif (_Index == 1) then
        self.EntryName = _Parameter;
    end
end

function B_Reprisal_JournalRemove:CustomFunction(_Quest)
    if QSB.JournalEntryNameToQuestName[self.EntryName] then
        local EntryID = QSB.JournalEntryNameToID[self.EntryName];
        API.RemoveJournalEntryFromQuest(EntryID, self.QuestName);
        API.DeleteJournalEntry(EntryID);
        QSB.JournalEntryNameToQuestName[self.EntryName] = nil;
        QSB.JournalEntryNameToID[self.EntryName] = nil;
    end
end

function B_Reprisal_JournalRemove:Debug(_Quest)
    if not API.IsValidQuest(GetQuestID(self.QuestName)) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": quest '" ..tostring(self.QuestName).."' does not exist!");
        return true;
    end
    if QSB.JournalEntryNameToQuestName[self.EntryName] ~= self.QuestName then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry name '" ..tostring(self.EntryName).."' is already in use in another quest!");
        return true;
    end
    if not QSB.JournalEntryNameToID[self.EntryName] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry '" ..tostring(self.EntryName).."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_JournalRemove);

-- -------------------------------------------------------------------------- --

---
-- Entfernt einen Tagebucheintrag von einem Quest.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string] _EntryName Name des Entry
-- @within Reward
--
function Reward_JournalRemove(...)
    return B_Reward_JournalRemove:new(...);
end

B_Reward_JournalRemove = Swift.LuaBase:CopyTable(B_Reprisal_JournalRemove);
B_Reward_JournalRemove.Name = "Reward_JournalRemove";
B_Reward_JournalRemove.Description.en = "Reward: Remove a journal entry from a quest.";
B_Reward_JournalRemove.Description.de = "Lohn: Entfernt einen Tagebucheintrag vom Quest.";
B_Reward_JournalRemove.Description.fr = "Récompense: Supprime une entrée de journal de la quête.";
B_Reward_JournalRemove.GetReprisalTable = nil;

B_Reward_JournalRemove.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_JournalRemove);

-- -------------------------------------------------------------------------- --

---
-- Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string]  _EntryName   Name des Eintrag
-- @param[type=boolean] _Highlighted Eintrag ist hervorgehoben
-- @within Reprisal
--
function Reprisal_JournaHighlight(...)
    return B_Reprisal_JournaHighlight:new(...);
end

B_Reprisal_JournaHighlight = {
    Name = "Reprisal_JournaHighlight",
    Description = {
        en = "Reprisal: Highlights or unhighlights a journal entry of a quest.",
        de = "Vergeltung: Hebt einen Tagebucheintrag hevor oder hebt die Hervorhebung auf.",
        fr = "Rétribution: met en valeur ou annule la mise en valeur d'une entrée de journal.",
    },
    Parameter = {
        { ParameterType.QuestName, en = "Quest name",      de = "Name Quest",   fr= "Nom de la quête" },
        { ParameterType.Default,   en = "Name of entry",   de = "Name Eintrag", fr= "Nom de l'entrée" },
        { ParameterType.Custom,    en = "Highlight entry", de = "Hebe hervor",  fr= "Mettre en valeur" },
    },
}

function B_Reprisal_JournaHighlight:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} };
end

function B_Reprisal_JournaHighlight:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.QuestName = _Parameter;
    elseif (_Index == 1) then
        self.EntryName = _Parameter;
    elseif (_Index == 2) then
        self.IsImportant = API.ToBoolean(_Parameter);
    end
end

function B_Reprisal_JournaHighlight:GetCustomData(_Index)
    return {"true","false"};
end

function B_Reprisal_JournaHighlight:CustomFunction(_Quest)
    if QSB.JournalEntryNameToQuestName[self.EntryName] then
        local EntryID = QSB.JournalEntryNameToID[self.EntryName];
        API.HighlightJournalEntry(EntryID, self.IsImportant == true);
    end
end

function B_Reprisal_JournaHighlight:Debug(_Quest)
    if not API.IsValidQuest(GetQuestID(self.QuestName)) then
        error(_Quest.Identifier.. ": " ..self.Name .. ": quest '" ..tostring(self.QuestName).."' does not exist!");
        return true;
    end
    if QSB.JournalEntryNameToQuestName[self.EntryName] ~= self.QuestName then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry name '" ..tostring(self.EntryName).."' is not mapped to the quest!");
        return true;
    end
    if not QSB.JournalEntryNameToID[self.EntryName] then
        error(_Quest.Identifier.. ": " ..self.Name .. ": entry '" ..tostring(self.EntryName).."' does not exist!");
        return true;
    end
    return false;
end

Swift:RegisterBehavior(B_Reprisal_JournaHighlight);

-- -------------------------------------------------------------------------- --

---
-- Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.
--
-- @param[type=string] _QuestName Name des Quest
-- @param[type=string]  _EntryName   Name des Eintrag
-- @param[type=boolean] _Highlighted Eintrag ist hervorgehoben
-- @within Reward
--
function Reward_JournaHighlight(...)
    return B_Reward_JournaHighlight:new(...);
end

B_Reward_JournaHighlight = Swift.LuaBase:CopyTable(B_Reprisal_JournaHighlight);
B_Reward_JournaHighlight.Name = "Reward_JournaHighlight";
B_Reward_JournaHighlight.Description.en = "Reward: Highlights or unhighlights a journal entry of a quest.";
B_Reward_JournaHighlight.Description.de = "Lohn: Hebt einen Tagebucheintrag hevor oder hebt die Hervorhebung auf.";
B_Reward_JournaHighlight.Description.fr = "Récompense: met en valeur ou annule la mise en valeur d'une entrée de journal.";
B_Reward_JournaHighlight.GetReprisalTable = nil;

B_Reward_JournaHighlight.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, { self, self.CustomFunction } };
end

Swift:RegisterBehavior(B_Reward_JournaHighlight);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Erlaubt es Notizen zu einem Quest hinzuzufügen.
-- 
-- <p><b>Vorausgesetzte Module:</b></p>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_1_Requester.QSB_1_Requester.html">(1) Requester</a></li>
-- <li><a href="modules.QSB_2_Quest.QSB_2_Quest.html">(2) Aufträge</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field QuestJournalDisplayed   (Parameter: PlayerID, QuestName, Text, NotizenErlaubt)
-- @field QuestJournalPlayerNote  (Parameter: PlayerID, QuestName, NotizenErlaubt)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Aktiviert oder Deaktiviert die Verfügbarkeit der Zusatzinformationen für den
-- übergebenen Quest.
--
-- <b>Hinweis</b>: Die Sichtbarkeit der Zusatzinformationen für einzelne Quests
-- ist generell deaktiviert und muss explizit aktiviert werden.
--
-- <b>Hinweis</b>: Der Button wird auch dann angezeigt, wenn es noch keine
-- Zusatzinformationen für den Quest gibt.
--
-- @param[type=string]  _Quest Name des Quest
-- @param[type=boolean] _Flag  Zusatzinfos aktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ShowJournalForQuest("MyQuest", false);
-- -- Aktivieren
-- API.ShowJournalForQuest("MyQuest", true);
--
function API.ShowJournalForQuest(_Quest, _Flag)
    if GUI then
        return;
    end
    local Quest = Quests[GetQuestID(_Quest)];
    if Quest then
        Quest.QuestNotes = _Flag == true;
    end
end

---
-- Aktiviert die Möglichkeit, selbst Notizen zu schreiben.
--
-- <b>Hinweis</b>: Die Zusatzinformationen müssen für den Quest aktiv sein.
--
-- @param[type=string]  _Quest Name des Quest
-- @param[type=boolean] _Flag  Notizen aktivieren
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.AllowNotesForQuest("MyQuest", false);
-- -- Aktivieren
-- API.AllowNotesForQuest("MyQuest", true);
--
function API.AllowNotesForQuest(_Quest, _Flag)
    if GUI then
        return;
    end
    local Quest = Quests[GetQuestID(_Quest)];
    if Quest then
        ModuleQuestJournal.Global.CustomInputAllowed[_Quest] = _Flag == true;
    end
end

---
-- Fugt eine Zusatzinformation für diesen Quests hinzu.
--
-- <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
-- ungeachtet ob sie einem Quest zugeordnet sind oder nicht.
--
-- <b>Hinweis</b>: Der Questname kann durch nil ersetzt werden. In diesem Fall
-- erscheint der Eintrag bei <i>allen</i> Quests (für die das Feature aktiviert
-- ist). Und das so lange, bis er wieder gelöscht wird.
--
-- <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.
--
-- @param[type=string] _Text  Text der Zusatzinfo
-- @return[type=number] ID des neuen Eintrags
-- @within Anwenderfunktionen
--
-- @usage
-- local NewEntryID = API.CreateJournalEntry("Wichtige Information zum Anzeigen");
--
function API.CreateJournalEntry(_Text)
    _Text = _Text:gsub("{@[A-Za-z0-9:,]+}", "");
    _Text = _Text:gsub("{[A-Za-z0-9_]+}", "");
    return ModuleQuestJournal.Global:CreateJournalEntry(_Text, 0, false);
end

---
-- Ändert den Text einer Zusatzinformation.
--
-- <b>Hinweis</b>: Der neue Text bezieht sich auf den Eintrag mit der ID. Ist
-- der Eintrag für alle Quests sichtbar, wird er in allen Quests geändert.
-- Kopien eines Eintrags werden nicht berücksichtigt.
--
-- <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.
--
-- @param[type=number] _ID   ID des Eintrag
-- @param              _Text Neuer Text
-- @within Anwenderfunktionen
--
-- @usage
-- API.AlterJournalEntry(SomeEntryID, "Das ist der neue Text.");
--
function API.AlterJournalEntry(_ID, _Text)
    _Text = _Text:gsub("{@[A-Za-z0-9:,]+}", "");
    _Text = _Text:gsub("{[A-Za-z0-9_]+}", "");
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            _Text,
            Entry.Rank,
            Entry.AlwaysVisible,
            Entry.Deleted
        );
    end
end

---
-- Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
-- setzt ihn zurück.
--
-- <b>Hinweis</b>: Wichtige Einträge erscheinen immer als erstes und sind durch
-- rote Färbung hervorgehoben. Eigene Farben in einer Nachricht beeinträchtigen
-- die rote hervorhebung.
--
-- @param[type=number]  _ID        ID des Eintrag
-- @param[type=boolean] _Important Wichtig Markierung
-- @within Anwenderfunktionen
--
-- @usage
-- API.HighlightJournalEntry(SomeEntryID, true);
--
function API.HighlightJournalEntry(_ID, _Important)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            (_Important == true and 1) or 0,
            Entry.AlwaysVisible,
            Entry.Deleted
        );
    end
end

---
-- Entfernt einen Eintrag aus den Zusatzinformationen.
--
-- <b>Hinweis</b>: Ein Eintrag wird niemals wirklich gelöscht, sondern nur
-- unsichtbar geschaltet.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.DeleteJournalEntry(SomeEntryID);
--
function API.DeleteJournalEntry(_ID)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            Entry.Rank,
            Entry.AlwaysVisible,
            true
        );
    end
end

---
-- Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.
--
-- @param[type=number] _ID ID des Eintrag
-- @within Anwenderfunktionen
--
-- @usage
-- API.RestoreJournalEntry(SomeEntryID);
--
function API.RestoreJournalEntry(_ID)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:UpdateJournalEntry(
            _ID,
            Entry[1],
            Entry.Rank,
            Entry.AlwaysVisible,
            false
        );
    end
end

---
-- Fügt einen Tagebucheintrag zu einem Quest hinzu.
--
-- @param[type=number]  _ID    ID des Eintrag
-- @param[type=boolean] _Quest Name des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.AddJournalEntryToQuest(_ID, _Quest);
--
function API.AddJournalEntryToQuest(_ID, _Quest)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:AssociateJournalEntryWithQuest(_ID, _Quest, true);
    end
end

---
-- Entfernt einen Tagebucheintrag von einem Quest.
--
-- @param[type=number]  _ID    ID des Eintrag
-- @param[type=boolean] _Quest Name des Quest
-- @within Anwenderfunktionen
--
-- @usage
-- API.RemoveJournalEntryFromQuest(_ID, _Quest);
--
function API.RemoveJournalEntryFromQuest(_ID, _Quest)
    local Entry = ModuleQuestJournal.Global:GetJournalEntry(_ID);
    if Entry then
        ModuleQuestJournal.Global:AssociateJournalEntryWithQuest(_ID, _Quest, false);
    end
end

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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

