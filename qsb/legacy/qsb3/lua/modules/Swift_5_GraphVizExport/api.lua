--[[
Swift_5_GraphVizExport/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht es die erstellten Quests als Diagramm darzustellen.
--
-- Das Diagramm wird in einer bestimmten Notation ins Log geschrieben. Diese
-- Notation heißt DOT. Um daraus ein Diagramm zu generieren, musst du
-- GraphViz installieren.
--
-- <h5>Installation von GraphViz</h5>
-- Befolge folgende Schritte, um GraphViz zu installieren:
-- <ol>
-- <li>
-- Lade die Release-Version von GraphViz für Windows 10 herunter.<br/>
-- <a target="_blank" href="https://www2.graphviz.org/Packages/stable/windows/10/msbuild/Release/Win32/">Download</a>
-- </li>
-- <li>
-- Entpacke den Ordner im Archiv in das Programmverzeichnis. Es existiert
-- dann folgendes Verzeichnis:
-- <pre>C:/Programme/GraphViz</pre>
-- </li>
-- <li>
-- Erweitere die PATH Variable um Folgenden Eintrag:
-- <pre>C:/Programme/GraphViz/bin</pre>
-- Starte deinen Rechner neu. Das ist nötig, damit die Änderung an PATH
-- wirksam wird.
-- </li>
-- <li>
-- Teste die Installation in der Eingabeaufforderung.
-- <pre>dot -v</pre>
-- Du solltes u.a. eine Version angezeigt bekommen.
-- <pre>dot - graphviz version 2.44.1 (20200629.0800)
--...</pre>
-- Drücke CTRL + C um das Programm zu beenden.
-- </li>
-- </ol>
--
-- <h5>Diagramm mit GraphViz erzeugen</h5>
-- <ol>
-- <li>
-- Lasse zu einen beliebigen Zeitpunkt die Quests umwandeln.<br/>Siehe dazu
-- <a href="#API.ExportQuestsForGraphViz">API.ExportQuestsForGraphViz</a>.
-- </li>
-- <li>
-- Öffne nun die Log-Datei. Die Logs befinden sich in folgendem Verzeichnis:
-- <pre>C:\Users\BENUTZERNAME\Documents\DIE SIEDLER - Aufstieg eines Königreichs\Temp\Logs</pre>
-- </li>
-- <li>
-- Suche im Log nach GraphViz Export. Kopiere den "kryptischen Buchstabensalat"
-- innerhalb des markierten Bereichs (ohne die Markierungen) in eine Datei
-- (z.B. quests.dot).
-- Ein Log-Eintrag kann so aussehen:
-- <pre>==== GraphViz Export Start ====
--
-- digraph G { graph [    fontname = &quot;Helvetica-Oblique&quot;, fontsize = 30, label = &quot;total_awesome_map&quot; ] 
-- node [ fontname = &quot;Courier-Bold&quot; shape = &quot;box&quot; ] 
--     &quot;TestQuest_0&quot; [  label = &quot;TestQuest_0\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_Time(5)&quot; ] 
--     &quot;TestQuest_0&quot; -&gt; &quot;TestQuest_1&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_1&quot; [  label = &quot;TestQuest_1\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_0', 5)&quot; ] 
--     &quot;TestQuest_1&quot; -&gt; &quot;TestQuest_2&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_2&quot; [  label = &quot;TestQuest_2\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_1', 5)&quot; ] 
--     &quot;TestQuest_2&quot; -&gt; &quot;TestQuest_3&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_3&quot; [  label = &quot;TestQuest_3\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_2', 5)&quot; ] 
--     &quot;TestQuest_3&quot; -&gt; &quot;TestQuest_4&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_4&quot; [  label = &quot;TestQuest_4\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_3', 5)&quot; ] 
--     &quot;TestQuest_4&quot; -&gt; &quot;TestQuest_5&quot; [color=&quot;#00ff00&quot;] 
--     &quot;TestQuest_5&quot; [  label = &quot;TestQuest_5\n=== 2  -&gt;  1 ===\n\nGoal_InstantSuccess()\nTrigger_OnQuestSuccessWait('TestQuest_4', 5)&quot; ]
-- } 
--
-- ==== GraphViz Export Ende ====</pre>
-- </li>
-- <li>
-- Führe folgenden Befehl zur Erzeugung des Diagrams in der Eingabeaufforderung
-- aus:
-- <pre>dot -Tjpg quests.dot > quests.jpg</pre>
-- Du solltest nun ein JPG im gleichen Verzeichnis vorfinden.
-- </li>
-- </ol>
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_2_QuestCore.api.html">(2) Quest Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erzeugt aus allen Quests die DOT-Notation und schreibt sie ins Log. Aus
-- dem erzeugten Code können mit GraphViz Diagramme erstellt werden.
--
-- @param[type=boolean] _UseBreak Break in LuaDebugger auslösen
-- @return[type=String] DOT Diagramm
--
function API.ExportQuestsForGraphViz(_UseBreak)
    local DOT = ModuleGraphVizExport.Global:ExecuteGraphVizExport();
    -- Im LuaDebugger kann man das Diagramm dann aus der Variable kopieren.
    -- Alle anderen müssen ins Log gucken.
    if LuaDebugger and _UseBreak then
        LuaDebugger.Break();
    end
    return DOT;
end

