--[[
Swift_2_InputOutputCore/Behavior

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]


---
-- Fügt Behavior zur Aufforderung einer Eingabe hinzu.
--
-- @set sort=true
--

---
-- Lässt den Spieler zwischen zwei Antworten wählen.
--
-- Dabei kann zwischen den Labels Ja/Nein und Ok/Abbrechen gewählt werden.
--
-- <b>Hinweis:</b> Es können nur geschlossene Fragen gestellt werden. Dialoge
-- müssen also immer mit Ja oder Nein beantwortbar sein oder auf Okay und
-- Abbrechen passen.
--
-- <h5>Multiplayer</h5>
-- Nicht für Multiplayer geeignet.
--
-- @param _Text   Fenstertext
-- @param _Title  Fenstertitel
-- @param _Labels Label der Buttons
--
-- @within Goal
--
function Goal_Decide(...)
    return B_Goal_Decide:new(...);
end

B_Goal_Decide = {
    Name = "Goal_Decide",
    Description = {
        en = "Goal: Opens a Yes/No Dialog. Decision = Quest Result",
        de = "Ziel: Öffnet einen Ja/Nein-Dialog. Die Entscheidung bestimmt das Quest-Ergebnis (ja=true, nein=false).",
        fr = "Objectif: ouvre une fenêtre de dialogue oui/non. La décision détermine le résultat de la quête (oui=true, non=false).",
    },
    Parameter = {       
        { ParameterType.Default, en = "Text",          de = "Text",                fr = "Text", },
        { ParameterType.Default, en = "Title",         de = "Titel",               fr = "Titre", },
        { ParameterType.Custom,  en = "Button labels", de = "Button Beschriftung", fr = "Inscription sur le bouton", },
    },
}

function B_Goal_Decide:GetGoalTable()
    return { Objective.Custom2, { self, self.CustomFunction } }
end

function B_Goal_Decide:AddParameter( _Index, _Parameter )
    if (_Index == 0) then
        self.Text = _Parameter
    elseif (_Index == 1) then
        self.Title = _Parameter
    elseif (_Index == 2) then
        self.Buttons = (_Parameter == "Ok/Cancel")
    end
end

function B_Goal_Decide:CustomFunction(_Quest)
    if Framework.IsNetworkGame() then
        return false;
    end
    if not API.IsCinematicEventActive or (API.IsCinematicEventActive and API.IsCinematicEventActive() == false) then
        if not QSB.GoalDecideDialogDisplayed then
            local buttons = (self.Buttons and "true") or "nil"
            QSB.GoalDecideDialogDisplayed = true;
            
            -- FIXME This will not work in multiplayer when more than one
            -- instances of this behavior are active!
            Logic.ExecuteInLuaLocalState(string.format(
                [[
                    local Action = function(_Yes)
                        API.BroadcastScriptCommand(QSB.ScriptCommands.SetDecisionResult, GUI.GetPlayerID(), _Yes == true);
                    end
                    API.DialogRequestBox("%s", "%s", Action, %s)
                ]],
                self.Title,
                self.Text,
                (self.Buttons and "true") or "nil"
            ));
        end
        local result = QSB.DecisionWindowResult
        if result ~= nil then
            QSB.GoalDecideDialogDisplayed = nil;
            QSB.DecisionWindowResult = nil
            return result
        end
    end
end

function B_Goal_Decide:GetIcon()
    return {4,12}
end

function B_Goal_Decide:GetCustomData(_Index)
    if _Index == 2 then
        return { "Yes/No", "Ok/Cancel" }
    end
end

function B_Goal_Decide:Debug(_Quest)
    if Framework.IsNetworkGame() then
        error(_Quest.Identifier.. ": " ..self.Name..": Can not be used in multiplayer!");
        return true;
    end
    return false;
end

function B_Goal_Decide:Reset()
    QSB.GoalDecideDialogDisplayed = nil;
end

Swift:RegisterBehavior(B_Goal_Decide);

-- -------------------------------------------------------------------------- --

---
-- Der Spieler muss im Chatdialog eine Eingabe tätigen.
--
-- Das Behaviour kann auch eingesetzt werden, um ein Passwort zu prüfen.
-- In diesem Fall wird die Eingabe mit dem Passwort verglichen. Die Anzal der
-- Versuche bestimmt, wie oft falsch eingegeben werden darf.
--
-- Wenn die Anzahl der Versuche begrenzt ist, wird eine Srandardnachricht mit
-- den übrigen Versuchen angezeigt. Optional kann eine Nachricht angegeben
-- werden, die stattdessen nach <u>jeder</u> Falscheingabe, <u>außer</u> der
-- letzten, angezeigt wird.
--
-- <b>Achtung</b>: Alle aktiven Quests mit einem Input Behavior werden die
-- erste Eingabe annehmen, die getätigt wird. Dabei ist es egal, ob der Input
-- durch sie selbst oder extern aktiviert wurde.
--
-- <h5>Multiplayer</h5>
-- Nicht für Multiplayer geeignet.
--
-- @param _Passwords Liste der Passwörter
-- @param _Trials    Anzahl versuche (0 für unendlich)
-- @param _Message   Alternative Fehlernachricht
--
-- @within Goal
--
function Goal_InputDialog(...)
    return B_Goal_InputDialog:new(...);
end

B_Goal_InputDialog  = {
    Name = "Goal_InputDialog",
    Description = {
        en = "Goal: Player must type in something. The passwords have to be seperated by ; and whitespaces will be ignored.",
        de = "Ziel: Öffnet einen Dialog, der Spieler muss Lösungswörter eingeben. Diese sind durch ; abzutrennen. Leerzeichen werden ignoriert.",
        fr = "Objectif: Ouvre un dialogue, le joueur doit entrer des mots de solution. Ceux-ci doivent être séparés par ;. Les espaces sont ignorés.",
    },
    DefaultMessage = {
        de = "Versuche bis zum Fehlschlag: ",
        en = "Trials remaining until failure: ",
        fr = "Tentatives jusqu'à l'échec: ",
    },
    Parameter = {
        {ParameterType.Default, en = "Password to enter",               de = "Einzugebendes Passwort",              fr = "Mot de passe à saisir" },
        {ParameterType.Number,  en = "Trials till failure (0 endless)", de = "Versuche bis Fehlschlag (0 endlos)",  fr = "Tentatives jusqu'à l'échec (0 sans fin)" },
        {ParameterType.Default, en = "Wrong password message",          de = "Text bei Falscheingabe",              fr = "Texte en cas d'erreur de saisie" },
    }
}

function B_Goal_InputDialog:GetGoalTable()
    return { Objective.Custom2, {self, self.CustomFunction}}
end

function B_Goal_InputDialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.Password = self:LowerCase(_Parameter or "");
    elseif (_Index == 1) then
        self.Trials = (_Parameter or 0) * 1;
    elseif (_Index == 2) then
        self.Message = _Parameter;
    end
end

function B_Goal_InputDialog:CustomFunction(_Quest)
    if Framework.IsNetworkGame() then
        return false;
    end

    if not self.Shown then
        if (not self.Trials) or (self.Trials) == 0 then
            QSB.GoalInputDialogQuest = _Quest.Identifier;
            self.Shown = true;
            API.ShowTextInput(_Quest.ReceivingPlayer);
        elseif not self.Shown then
            QSB.GoalInputDialogQuest = _Quest.Identifier;
            self.Shown = true;
            self.TrialCounter = self.TrialCounter or self.Trials;
            API.ShowTextInput(_Quest.ReceivingPlayer);
            self.TrialCounter = self.TrialCounter - 1;
        end
    end

    if not API.IsCinematicEventActive or (API.IsCinematicEventActive and API.IsCinematicEventActive() == false) then
        if self.InputDialogResult then
            if self.Password ~= nil and self.Password ~= "" then
                self.Shown = nil;

                if self:LowerCase(self.InputDialogResult) == self.Password then
                    return true;
                elseif (self.Trials == 0) or (self.Trials > 0 and self.TrialCounter > 0) then
                    self:OnWrongInput(_Quest);
                    return;
                else
                    return false;
                end
            end
            QSB.GoalInputDialogQuest = nil;
            return true;
        end
    end
end

function B_Goal_InputDialog:OnWrongInput(_Quest)
    if self.Trials > 0 and not self.Message then
        local lang = QSB.Language;
        Logic.DEBUG_AddNote(API.Localize(self.DefaultMessage) .. self.TrialCounter);
        return;
    end
    if self.Message then
        Logic.DEBUG_AddNote(API.Localize(self.Message));
    end
    self.InputDialogResult = nil;
    self.Shown = nil;
end

function B_Goal_InputDialog:LowerCase(_Text)
    _Text = _Text:lower(_Text);
    -- Umlaute manuell austauschen
    -- FIXME: Ausländische Umlaute auch anpassen.
    _Text = _Text:gsub("Ä", "ä");
    _Text = _Text:gsub("Ö", "ö");
    _Text = _Text:gsub("Ü", "ü");
    return _Text;
end

function B_Goal_InputDialog:GetIcon()
    return {12,2};
end

function B_Goal_InputDialog:Debug(_Quest)
    if Framework.IsNetworkGame() then
        error(_Quest.Identifier.. ": " ..self.Name..": Can not be used in multiplayer!");
        return true;
    end
    return false;
end

function B_Goal_InputDialog:Reset(_Quest)
    QSB.GoalInputDialogQuest = nil;
    self.InputDialogResult = nil;
    self.TrialCounter = nil;
    self.Shown = nil;
end

function B_Goal_InputDialog:Interrupt(_Quest)
    self:Reset(_Quest);
end

Swift:RegisterBehavior(B_Goal_InputDialog);

