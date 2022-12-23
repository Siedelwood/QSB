--[[
Swift_2_Quests/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul ermöglicht es einen Quest, bzw. Auftrag, per Skript zu 
-- erstellen.
--
-- Normaler Weise werden Aufträge im Questassistenten erzeugt. Dies ist aber
-- statisch und das Kopieren von Aufträgen ist nicht möglich. Wenn Aufträge
-- im Skript erzeugt werden, verschwinden alle diese Nachteile. Aufträge
-- können im Skript kopiert und angepasst werden. Es ist ebenfalls machbar,
-- die Aufträge in Sequenzen zu erzeugen.
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Parameter</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>stop</td>
-- <td>QuestName</td>
-- <td>Unterbricht den angegebenen Quest.</td>
-- </tr>
-- <tr>
-- <td>start</td>
-- <td>QuestName</td>
-- <td>Startet den angegebenen Quest.</td>
-- </tr>
-- <tr>
-- <td>win</td>
-- <td>QuestName</td>
-- <td>Schließt den angegebenen Quest erfolgreich ab.</td>
-- </tr>
-- <tr>
-- <td>fail</td>
-- <td>QuestName</td>
-- <td>Lässt den angegebenen Quest fehlschlagen</td>
-- </tr>
-- <tr>
-- <td>restart</td>
-- <td>QuestName</td>
-- <td>Startet den angegebenen Quest neu.</td>
-- </tr>
-- </table>
--
-- <h4>Bekannte Probleme</h4>
-- Jede Voice Message - <b>Quests sind ebenfalls Voice Messages</b> - hat die
-- Chance, dass die Message Queue des Spiels hängen bleibt und dann ein leeres
-- Fenster mit dem Titel "Rhian over the Sea Chapell" angezeigt wird, welches
-- das Portrait Window dauerhaft blockiert und verhindert, dass weitere Voice
-- Messages - <b>auch Quests</b> - angezeigt werden können.
--
-- Es wird dringend geraten, Quests <b>ausschließlich</b> zur Darstellung von
-- Aufgaben für den Spieler und für <b>nichts anderes</b> zu benutzen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.GeneratedQuestDialogs = {};

---
-- Die Abschlussarten eines Quest Segment.
--
-- @field Success Phase muss erfolgreich abgeschlossen werden.
-- @field Failure Phase muss fehlschlagen.
-- @field Ignore  Erfolg und Misserfolg werden geleichermaßen akzeptiert.
--
QSB.SegmentResult = QSB.SegmentResult or {}

---
-- Erstellt einen Quest.
--
-- Ein Auftrag braucht immer wenigstens ein Goal und einen Trigger um ihn
-- erstellen zu können. Hat ein Quest keinen Namen, erhält er automatisch
-- einen mit fortlaufender Nummerierung.
--
-- Ein Quest besteht aus verschiedenen Eigenschaften und Behavior, die nicht
-- alle zwingend gesetzt werden müssen. Behavior werden einfach nach den
-- Eigenschaften nacheinander angegeben.
-- <p><u>Eigenschaften:</u></p>
-- <ul>
-- <li>Name: Der eindeutige Name des Quests</li>
-- <li>Sender: PlayerID des Auftraggeber (Default 1)</li>
-- <li>Receiver: PlayerID des Auftragnehmer (Default 1)</li>
-- <li>Suggestion: Vorschlagnachricht des Quests</li>
-- <li>Success: Erfolgsnachricht des Quest</li>
-- <li>Failure: Fehlschlagnachricht des Quest</li>
-- <li>Description: Aufgabenbeschreibung (Nur bei Custom)</li>
-- <li>Time: Zeit bis zu, Fehlschlag/Abschluss</li>
-- <li>Loop: Funktion, die während der Laufzeit des Quests aufgerufen wird</li>
-- <li>Callback: Funktion, die nach Abschluss aufgerufen wird</li>
-- </ul>
--
-- @param[type=table] _Data Questdefinition
-- @return[type=string] Name des Quests
-- @return[type=number] Gesamtzahl Quests
-- @within Anwenderfunktionen
-- @see API.CreateNestedQuest
--
-- @usage
-- API.CreateQuest {
--     Name        = "UnimaginativeQuestname",
--     Suggestion  = "Wir müssen das Kloster finden.",
--     Success     = "Dies sind die berümten Heilermönche.",
--
--     Goal_DiscoverPlayer(4),
--     Reward_Diplomacy(1, 4, "EstablishedContact"),
--     Trigger_Time(0),
-- }
--
function API.CreateQuest(_Data)
    if GUI then
        return;
    end
    if _Data.Name and Quests[GetQuestID(_Data.Name)] then
        error("API.CreateQuest: A quest named " ..tostring(_Data.Name).. " already exists!");
        return;
    end
    return ModuleQuests.Global:CreateSimpleQuest(_Data);
end

---
-- Erstellt einen verschachtelten Auftrag.
--
-- Verschachtelte Aufträge (Nested Quests) vereinfachen aufschreiben und
-- zuordnen der zugeordneten Aufträge. Ein Nested Quest ist selbst unsichtbar
-- und hat mindestens ein ihm untergeordnetes Segment. Die Segmente eines
-- Nested Quest sind wiederum eigenständige Quests.
--
-- Du kannst für Segmente die gleichen Einträge setzen, wie bei gewöhnlichen
-- Quests. Zudem kannst du auch ihnen einen Namen geben. Wenn du das nicht tust,
-- werden sie automatisch benannt. Der Name setzt sich zusammen aus dem Namen
-- des Nested Quest und ihrem Index (z.B. "UnimaginativeQuestname@Segment1").
--
-- Segmente haben ein erwartetes Ergebnis. Für gewöhnlich ist dies auf Erfolg
-- festgelegt. Du kanns es aber auch auf Fehlschlag ändern oder ganz ignorieren.
-- Ein Nested Quest ist abgeschlossen, wenn alle Segmente mit ihrem erwarteten
-- Ergebnis abgeschlossen wurden (Erfolg) oder mindestens einer ein anderes
-- Ergebnis als erwartet hatte (Fehlschlag).
--
-- Werden Status oder Resultat eines Quest über Funktionen verändert (zb.
-- API.StopQuest bzw "stop" Konsolenbefehl), dann werden automatisch die
-- Segmente ausgelöst oder abgebrochen.
--
-- Es ist nicht zwingend notwendig, einen Trigger für die Segmente zu setzen.
-- Alle Segmente starten automatisch sobald der Nested Quest startet. Du kannst
-- weitere Trigger zu Segmenten hinzufügen, um dieses Verhalten nach deinen
-- Bedürfnissen abzuändern (z.B. auf ein vorangegangenes Segment triggern).
--
-- Nested Quests können auch ineinander verschachtelt werden. Man kann also
-- innerhalb eines Hauptauftrag eine untergeordneten Hauptauftrag anlegen.
--
-- @param[type=table] _Data Daten des Quest
-- @return[type=string] Name des Nested Quest oder nil bei Fehler
-- @within Anwenderfunktionen
-- @see QSB.SegmentResult
-- @see API.CreateQuest
--
-- @usage
-- API.CreateNestedQuest {
--     Name        = "UnimaginativeQuestname",
--     Segments    = {
--         {
--             Suggestion  = "Wir benötigen einen höheren Titel!",
--
--             Goal_KnightTitle("Mayor"),
--         },
--         {
--             -- Mit dem Typ Ignore wird Fehlschlag ignoriert.
--             Result      = QSB.SegmentResult.Ignore,
--
--             Suggestion  = "Wir benötigen außerdem mehr Asche! Und das sofort...",
--             Success     = "Geschafft!",
--             Failure     = "Versagt!",
--             Time        = 3 * 60,
--
--             Goal_Produce("G_Gold", 5000),
--
--             Trigger_OnQuestSuccess("UnimaginativeQuestname@Segment1", 1),
--             -- Segmented Quest wird gewonnen.
--             Reward_QuestSuccess("UnimaginativeQuestname"),
--         },
--         {
--             Suggestion  = "Dann versuchen wir es mit Eisen...",
--             Success     = "Geschafft!",
--             Failure     = "Versagt!",
--             Time        = 3 * 60,
--
--             Trigger_OnQuestFailure("UnimaginativeQuestname@Segment2"),
--             Goal_Produce("G_Iron", 50),
--         }
--     },
--
--     -- Wenn ein Quest nicht das erwartete Ergebnis hat, Fehlschlag.
--     Reprisal_Defeat(),
--     -- Wenn alles erfüllt wird, ist das Spiel gewonnen.
--     Reward_VictoryWithParty(),
-- };
--
function API.CreateNestedQuest(_Data)
    if GUI or type(_Data) ~= "table" then
        return;
    end
    if _Data.Segments == nil or #_Data.Segments == 0 then
        error(string.format("API.CreateNestedQuest: Segmented quest '%s' is missing it's segments!", tostring(_Data.Name)));
        return;
    end
    return ModuleQuests.Global:CreateNestedQuest(_Data);
end

---
-- Erzeugt eine Nachricht im Questfenster.
--
-- Der Quest wird immer nach Ablauf der Wartezeit nach
-- Abschluss des Ancestor Quest gestartet bzw. unmittelbar, wenn es keinen
-- Ancestor Quest gibt. Das Callback ist eine Funktion, die zur Anzeigezeit
-- des Quests ausgeführt wird.
--
-- Alle Paramater sind optional und können von rechts nach links weggelassen
-- oder mit nil aufgefüllt werden.
--
-- @param[type=string]   _Text        Anzeigetext der Nachricht
-- @param[type=number]   _Sender      Sender der Nachricht
-- @param[type=number]   _Receiver    Receiver der Nachricht
-- @param[type=number]   _AncestorWt  Wartezeit
-- @param[type=function] _Callback    Callback
-- @param[type=string]   _Ancestor    Vorgänger-Quest
-- @return[type=string] QuestName
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateQuestMessage("Das ist ein Text", 4, 1);
--
function API.CreateQuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor)
    if GUI then
        return;
    end
    if tonumber(_Sender) == nil or _Sender < 1 or _Sender > 8 then
        error("API.GetResourceOfProduct: _Sender is wrong!");
        return;
    end
    if tonumber(_Receiver) == nil or _Receiver < 1 or _Receiver > 8 then
        error("API.GetResourceOfProduct: _Receiver is wrong!");
        return;
    end
    return ModuleQuests.Global:QuestMessage(_Text, _Sender, _Receiver, _AncestorWt, _Callback, _Ancestor);
end

---
-- Fügt eine Prüfung hinzu, ob Quests getriggert werden. Soll ein Quest nicht
-- getriggert werden, muss false zurückgegeben werden, sonst true.
--
-- @param[type=function] _Function Prüffunktion
-- @within Anwenderfunktionen
-- @local
--
function API.AddDisableTriggerCondition(_Function)
    if GUI then
        return;
    end
    table.insert(ModuleQuests.Global.ExternalTriggerConditions, _Function);
end

---
-- Fügt eine Prüfung hinzu, ob für laufende Quests Zeit vergeht. Soll keine Zeit
-- vergehen für einen Quest muss false zurückgegeben werden, sonst true.
--
-- @param[type=function] _Function Prüffunktion
-- @within Anwenderfunktionen
-- @local
--
function API.AddDisableTimerCondition(_Function)
    if GUI then
        return;
    end
    table.insert(ModuleQuests.Global.ExternalTimerConditions, _Function);
end

---
-- Fügt eine Prüfung hinzu, ob für laufende Quests Ziele geprüft werden. Sollen
-- keine Ziele geprüft werden muss false zurückgegeben werden, sonst true.
--
-- @param[type=function] _Function Prüffunktion
-- @within Anwenderfunktionen
-- @local
--
function API.AddDisableDecisionCondition(_Function)
    if GUI then
        return;
    end
    table.insert(ModuleQuests.Global.ExternalDecisionConditions, _Function);
end

