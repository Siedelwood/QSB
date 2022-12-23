--[[
Swift_0_Core/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Stellt wichtige Kernfunktionen bereit.
--
-- <h4>Script Events</h4>
--
-- Um dem Mapper das (z.T. fehlerbehaftete) Überschreiben von Game Callbacks
-- oder anlegen von (echten) Triggern zu ersparen, wurden die Script Events
-- eingeführt. Sie vereinheitlichen alle diese Operationen. Ein Event kann
-- über einen Event Listener oder ein spezielles Game Callback gefangen werden.
--
-- Ein Event zu fangen, bedeutet auf ein eingetretenes Ereignis - z.B. Wenn ein
-- Spielstand geladen wurde - zu reagieren. Events werden immer sowohl im
-- globalen als auch lokalen Skript ausgelöst, wenn ein entsprechendes Ereignis
-- aufgetreten ist, anstatt vieler Callbacks, die auf eine spezifische Umgebung
-- beschränkt sind.
--
-- Module bringen manchmal Events mit. Jedes Modul, welches ein neues Event
-- einführt, wird es in seiner API-Beschreibung aufgführen.
--
-- @set sort=true
-- @within Beschreibung
--

Swift = Swift or {};

QSB.Metatable = {Init = false, Weak = {}, Metas = {}, Key = 0};

QSB.DefaultNumber = -1;
QSB.DefaultString = "";
QSB.DefaultList = {};
QSB.DefaultFunction = function() end;

-- Script Events

---
-- Liste der grundlegenden Script Events.
--
-- @field SaveGameLoaded     Ein Spielstand wird geladen.
-- @field EscapePressed      Escape wurde gedrückt. (Parameter: PlayerID)
-- @field QuestFailure       Ein Quest schlug fehl (Parameter: QuestID)
-- @field QuestInterrupt     Ein Quest wurde unterbrochen (Parameter: QuestID)
-- @field QuestReset         Ein Quest wurde zurückgesetzt (Parameter: QuestID)
-- @field QuestSuccess       Ein Quest wurde erfolgreich abgeschlossen (Parameter: QuestID)
-- @field QuestTrigger       Ein Quest wurde aktiviert (Parameter: QuestID)
-- @field CustomValueChanged Eine Custom Variable hat sich geändert (Parameter: Name, OldValue, NewValue)
-- @field LanguageSet        Die Sprache wurde geändert (Parameter: OldLanguage, NewLanguage)
-- @field LoadscreenClosed   Der Ladebildschirm wurde beendet.
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- Script Event Callback --

-- The callback is put into a never called local function because LDoc can't
-- process the callback when it self is declared local. For ... reasons we do
-- not want to use the -a switch on LDoc so that seems to be the only solution.
-- Creators should never give a function this name. But I don't think that this
-- will be very likley to happen anyway. ;)
local function ThisWillForeverBeLostToTheVoidBecauseNoOneComesUpWithThatName()
    ---
    -- Wird aufgerufen, wenn ein beliebiges Event empfangen wird.
    --
    -- <b>Hinweis</b>: Der Enent Listener darf jeweils nur einmal im globalen
    -- und lokalen Skript definiert werden.
    --
    -- Wenn ein Event empfangen wird, kann es sein, dass Parameter mit übergeben
    -- werden. Um für alle Events gewappnet zu sein, muss der Listener als
    -- Varargs-Funktion, also mit ... in der Parameterliste geschrieben werden.
    --
    -- Zugegriffen wird auf die Parameter, indem die Parameterliste entsprechend
    -- indexiert wird. Für Parameter 1 wird dann arg[1] geschrieben usw.
    --
    -- @param[type=number] _EventID ID des Event
    -- @param              ...      Parameterliste des Event
    -- @within Event
    --
    -- @usage
    -- GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    --     if _EventID == QSB.ScriptEvents.EscapePressed then
    --         Logic.DEBUG_AddNote("Player " ..arg[1].. " has pressed Escape!");
    --     elseif _EventID == QSB.ScriptEvents.SaveGameLoaded then
    --         Logic.DEBUG_AddNote("A save has been loaded!");
    --     end
    -- end
    --
    GameCallback_QSB_OnEventReceived = function(_EventID, ...)
    end
end

-- Base --

---
-- Installiert Swift.
--
-- @within Base
-- @local
--
function API.Install()
    Swift:LoadCore();
    Swift:LoadModules();
    collectgarbage("collect");
end

---
-- Prüft, ob das laufende Spiel in der History Edition gespielt wird.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Base
--
function API.IsHistoryEdition()
    return Swift:IsHistoryEdition();
end

function API.IsCommunityPatch()
    return Entities.U_PolarBear ~= nil;
end

---
-- Prüft, ob das laufende Spiel eine Multiplayerpartie in der History Edition
-- ist.
--
-- <b>Hinweis</b>: Es ist unmöglich, dass Original und History Edition in einer
-- Partie aufeinander treffen, da die alten Server längst abgeschaltet und die
-- Option zum LAN-Spiel in der HE nicht verfügbar ist.
--
-- @return[type=boolean] Spiel ist History Edition
-- @within Base
--
function API.IsHistoryEditionNetworkGame()
    return API.IsHistoryEdition() and Framework.IsNetworkGame();
end

---
-- Gibt den Slot zurück, den der Spieler einnimmt. Hat der Spieler keinen
-- Slot okkupiert oder ist nicht menschlich, wird -1 zurückgegeben.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=number] ID des Player
-- @return[type=number] Slot ID des Player
-- @within Base
--
function API.GetPlayerSlotID(_PlayerID)
    for i= 1, 8 do
        if Network.IsNetworkSlotIDUsed(i) then
            local CurrentPlayerID = Logic.GetSlotPlayerID(i);
            if  Logic.PlayerGetIsHumanFlag(CurrentPlayerID)
            and CurrentPlayerID == _PlayerID then
                return i;
            end
        end
    end
    return -1;
end

---
-- Gibt den Spieler zurück, welcher den Slot okkupiert. Hat der Slot keinen
-- Spieler oder ist der Spieler nicht menschlich, wird -1 zurückgegeben.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=number] Slot ID des Player
-- @return[type=number] ID des Player
-- @within Base
--
function API.GetSlotPlayerID(_SlotID)
    if Network.IsNetworkSlotIDUsed(_SlotID) then
        local CurrentPlayerID = Logic.GetSlotPlayerID(_SlotID);
        if Logic.PlayerGetIsHumanFlag(CurrentPlayerID)  then
            return CurrentPlayerID;
        end
    end
    return -1;
end

---
-- Gibt eine Liste aller Spieler im Spiel zurück.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=table] Liste der aktiven Spieler
-- @within Base
--
function API.GetActivePlayers()
    local PlayerList = {};
    for i= 1, 8 do
        if Network.IsNetworkSlotIDUsed(i) then
            local PlayerID = Logic.GetSlotPlayerID(i);
            if Logic.PlayerGetIsHumanFlag(PlayerID) and Logic.PlayerGetGameState(PlayerID) ~= 0 then
                table.insert(PlayerList, PlayerID);
            end
        end
    end
    return PlayerList;
end

---
-- Gibt alle Spieler zurück, auf die gerade gewartet wird.
--
-- <h5>Multiplayer</h5>
-- Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!
--
-- @return[type=table] Liste der aktiven Spieler
-- @within Base
--
function API.GetDelayedPlayers()
    local PlayerList = {};
    for k, v in pairs(API.GetActivePlayers()) do
        if Network.IsWaitingForNetworkSlotID(API.GetPlayerSlotID(v)) then
            table.insert(PlayerList, v);
        end
    end
    return PlayerList;
end

---
-- Speichert den Wert der Custom Variable im globalen und lokalen Skript.
--
-- Des weiteren wird in beiden Umgebungen ein Event ausgelöst, wenn der Wert
-- gesetzt wird. Das Event bekommt den Namen der Variable, den alten Wert und
-- den neuen Wert übergeben.
--
-- @param[type=boolean] _Name  Name der Custom Variable
-- @param               _Value Neuer Wert
-- @within Base
--
-- @usage
-- local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.SaveCustomVariable(_Name, _Value)
    Swift:SetCustomVariable(_Name, _Value);
end

---
-- Gibt den aktuellen Wert der Custom Variable zurück oder den Default-Wert.
-- @param[type=boolean] _Name    Name der Custom Variable
-- @param               _Default (Optional) Defaultwert falls leer
-- @return Wert
-- @within Base
--
-- @usage
-- local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.ObtainCustomVariable(_Name, _Default)
    local Value = QSB.CustomVariable[_Name];
    if not Value and _Default then
        Value = _Default;
    end
    return Value;
end

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben. Bei
-- einem Table mit einem passenden Sprach-Key (de, en) wird die entsprechende
-- Sprache zurückgegeben. Sollte ein Nested Table übergeben werden, werden alle
-- Texte innerhalb des Tables rekursiv übersetzt als Table zurückgegeben. Alle
-- anderen Werte sind nicht in der Rückgabe enthalten.
--
-- @param _Text Anzeigetext (String oder Table)
-- @return Übersetzten Text oder Table mit Texten
-- @within Base
--
-- @usage
-- -- Einstufige Table
-- local Text = API.Localize({de = "Deutsch", en = "English"});
-- -- Rückgabe: "Deutsch"
--
-- -- Mehrstufige Table
-- API.Localize{{de = "Deutsch", en = "English"}, {{1,2,3,4, de = "A", en = "B"}}}
-- -- Rückgabe: {"Deutsch", {"A"}}
--
function API.Localize(_Text)
    return Swift:Localize(_Text);
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- @param _Value Wahrheitswert
-- @return[type=boolean] Wahrheitswert
-- @within Base
-- @local
--
-- @usage
-- local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("1")  --> Bool = true
-- local Bool = API.ToBoolean(1)  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Swift.LuaBase:ToBoolean(_Value);
end

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- Zusätzlich können die Dezimalstellen beschränkt werden. Alle überschüssigen
-- Dezimalstellen werden abgeschnitten.
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within Base
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        local Overhead = nil;
        if Value:len() > e + _DecimalDigits then
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value);
end

---
-- Fügt eine Bedingung für Quicksaves hinzu.
--
-- <b>Hinweis:</b> Nur im lokalen Skript möglich!
--
-- @param[type=function] _Function Bedingungsprüfung
-- @within Base
--
function API.AddBlockQuicksaveCondition(_Function)
    if not GUI or type(_Function) ~= "function" then
        return;
    end
    Swift:AddBlockQuicksaveCondition(_Function);
end

function API.IsLoadscreenVisible()
    return Swift.LoadScreenHidden ~= true;
end

-- Debug

---
-- Aktiviert oder deaktiviert Optionen des Debug Mode.
--
-- <b>Hinweis:</b> Du kannst alle Optionen unbegrenzt oft beliebig ein-
-- und ausschalten.
--
-- @param[type=boolean] _CheckAtRun       Custom Behavior prüfen an/aus
-- @param[type=boolean] _TraceQuests      Quest Trace an/aus
-- @param[type=boolean] _DevelopingCheats Cheats an/aus
-- @param[type=boolean] _DevelopingShell  Eingabeaufforderung an/aus
-- @within Debug
--
function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Swift.Debug:ActivateDebugMode(
        _CheckAtRun == true,
        _TraceQuests == true,
        _DevelopingCheats == true,
        _DevelopingShell == true
    );
end

---
-- Prüft, ob der Debug Behavior überprüfen darf.
--
-- <b>Hinweis:</b> Module müssen die Behandlung dieser Option selbst
-- inmpelentieren. Das Core Modul übernimmt diese Aufgabe nicht!
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugBehaviorCheckActive()
    return Swift.Debug.CheckAtRun == true;
end

---
-- Prüft, ob Quest Trace benutzt wird.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugQuestTraceActive()
    return Swift.Debug.TraceQuests == true;
end

---
-- Prüft, ob die Cheats aktiviert sind.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugCheatsActive()
    return Swift.Debug.DevelopingCheats == true;
end

---
-- Prüft, ob die Eingabeaufforderung aktiv ist.
--
-- <b>Hinweis:</b> Viele Kommandos müssen von Modulen implementiert werden.
-- Siehe die Doku dieser Module.
--
-- @return[type=boolean] Option Aktiv
-- @within Debug
--
function API.IsDebugShellActive()
    return Swift.Debug.DevelopingShell == true;
end

---
-- Beginnt einen überwachten Zeitraum.
--
-- @param[type=string] _Identifier Name des Benchmark
-- @within Debug
-- @see API.StopBenchmark
--
function API.BeginBenchmark(_Identifier)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.BeginBenchmark("%s")]],
            _Identifier
        ));
        return;
    end
    Swift:BeginBenchmark(_Identifier);
end

---
-- Beendet einen überwachten Zeitraum und schreibt die Dauer ins Log.
--
-- <b>Exkurs</b>: Wenn die Ausführungsdauer für einen Prozess gemessen wird,
-- nennt man dies Benchmarking. Dabei wird geschaut, wie lange die Ausführung
-- des Prozesses dauert.
--
-- Dabei gilt, dass man möglichst kleine Werte erziehlen will. Die Zeiten werden
-- in milisekunden (ms) gemessen.
--
-- @param[type=string] _Identifier Name des Benchmark
-- @within Debug
--
-- @usage
-- API.BeginBenchmark("HowMuchIsTheFish")
-- local j= 0
-- for i= 1, 1000000 do
--     j = j +1
-- end
-- API.StopBenchmark("HowMuchIsTheFish")
--
-- -- Ausgabe im Log:
-- Benchmark 'HowMuchIsTheFish': Execution took 0.015 ms to complete
--
function API.StopBenchmark(_Identifier)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.StopBenchmark("%s")]],
            _Identifier
        ));
        return;
    end
    Swift:StopBenchmark(_Identifier);
end

---
-- Setzt, ab wann Log-Nachrichten angezeigt bzw. ins Log geschrieben werden.
--
-- Mögliche Level:
-- <table border=1>
-- <tr>
-- <td><b>Name</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>LOG_LEVEL_ALL</td>
-- <td>Alle Stufen ausgeben (Debug, Info, Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>LOG_LEVEL_INFO</td>
-- <td>Erst ab Stufe Info ausgeben (Info, Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>LOG_LEVEL_WARNING</td>
-- <td>Erst ab Stufe Warning ausgeben (Warning, Error)</td>
-- </tr>
-- <tr>
-- <td>LOG_LEVEL_ERROR</td>
-- <td>Erst ab Stufe Error ausgeben (Error)</td>
-- </tr>
-- <tr>
-- <td>LOG_LEVEL_OFF</td>
-- <td>Keine Meldungen ausgeben</td>
-- </tr>
-- </table>
--
-- @param[type=number] _ScreenLogLevel Level für Bildschirmausgabe
-- @param[type=number] _FileLogLevel   Level für Dateiausgaabe
-- @within Debug
--
-- @usage
-- API.SetLogLevel(LOG_LEVEL_ERROR, LOG_LEVEL_WARNING);
--
function API.SetLogLevel(_ScreenLogLevel, _FileLogLevel)
    Swift:SetLogLevel(_ScreenLogLevel, _FileLogLevel);
end

-- Command
-- The commands will not appear in the doc to not confuse the users. If they
-- want to synchronize things in their maps they can use the event system.

function API.RegisterScriptCommand(_Name, _Function)
    return Swift.Event:CreateScriptCommand(_Name, _Function);
end

function API.BroadcastScriptCommand(_NameOrID, ...)
    local ID = _NameOrID;
    if type(ID) == "string" then
        for i= 1, #Swift.Event.ScriptCommandRegister, 1 do
            if Swift.Event.ScriptCommandRegister[i][1] == _NameOrID then
                ID = i;
            end
        end
    end
    assert(type(ID) == "number");
    if not GUI then
        return;
    end
    Swift.Event:DispatchScriptCommand(ID, 0, unpack(arg));
end

-- Does this function makes any sense? Calling the synchronization but only for
-- one player seems to be stupid...
function API.SendScriptCommand(_NameOrID, ...)
    local ID = _NameOrID;
    if type(ID) == "string" then
        for i= 1, #Swift.Event.ScriptCommandRegister, 1 do
            if Swift.Event.ScriptCommandRegister[i][1] == _NameOrID then
                ID = i;
            end
        end
    end
    assert(type(ID) == "number");
    if not GUI then
        return;
    end
    Swift.Event:DispatchScriptCommand(ID, GUI.GetPlayerID(), unpack(arg));
end

-- Event

---
-- Legt ein neues Script Event an.
--
-- @param[type=string]   _Name     Identifier des Event
-- @return[type=number] ID des neuen Script Event
-- @within Event
--
-- @usage
-- local EventID = API.RegisterScriptEvent("MyNewEvent");
--
function API.RegisterScriptEvent(_Name)
    return Swift.Event:CreateScriptEvent(_Name, nil);
end

---
-- Sendet das Script Event mit der übergebenen ID und überträgt optional
-- Parameter.
--
-- <h5>Multiplayer</h5>
-- Im Multiplayer kann diese Funktion nicht benutzt werden, um Script Events
-- synchron oder asynchron aus dem lokalen im globalen Skript auszuführen.
--
-- @param[type=number] _EventID ID des Event
-- @param              ... Optionale Parameter (nil, string, number, boolean, (array) table)
-- @within Event
--
-- @usage
-- API.SendScriptEvent(SomeEventID, Param1, Param2, ...);
--
function API.SendScriptEvent(_EventID, ...)
    Swift.Event:DispatchScriptEvent(_EventID, unpack(arg));
end

---
-- Triggerd ein Script Event im globalen Skript aus dem lokalen Skript.
--
-- Das Event wird synchron für alle Spieler gesendet.
--
-- @param[type=number] _EventID ID des Event
-- @param              ... Optionale Parameter (nil, string, number, boolean, (array) table)
-- @within Event
--
-- @usage
-- API.SendScriptEventToGlobal(SomeEventID, Param1, Param2, ...);
--
function API.BroadcastScriptEventToGlobal(_EventID, ...)
    if not GUI then
        return;
    end
    -- Becase I don't want the user to fuck around with parameters.
    for k, v in pairs(arg) do
        if not Swift.Event:IsAllowedEventParameter(v) then
            error("API.BroadcastScriptEventToGlobal: Parameter " ..k.. " has non appropriate type! (" ..type(v).. ")");
            return;
        end
    end
    Swift.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        0,
        _EventID,
        unpack(arg)
    );
end

---
-- Triggerd ein Script Event im globalen Skript aus dem lokalen Skript.
--
-- Das Event wird asynchron für den kontrollierenden Spieler gesendet.
--
-- @param[type=number] _EventID ID des Event
-- @param              ... Optionale Parameter (nil, string, number, boolean, (array) table)
-- @within Event
--
-- @usage
-- API.SendScriptEventToGlobal(SomeEventID, Param1, Param2, ...);
--
function API.SendScriptEventToGlobal(_EventID, ...)
    if not GUI then
        return;
    end
    -- Becase I don't want the user to fuck around with parameters.
    for k, v in pairs(arg) do
        if not Swift.Event:IsAllowedEventParameter(v) then
            error("API.SendScriptEventToGlobal: Parameter " ..k.. " has non appropriate type! (" ..type(v).. ")");
            return;
        end
    end
    Swift.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        GUI.GetPlayerID(),
        _EventID,
        unpack(arg)
    );
end

---
-- Erstellt einen neuen Listener für das Event.
--
-- An den Listener werden die gleichen Parameter übergeben, die für das Event
-- auch bei GameCallback_QSB_OnEventReceived übergeben werden.
--
-- <b>Hinweis</b>: Event Listener für ein spezifisches Event werden nach
-- GameCallback_QSB_OnEventReceived aufgerufen.
--
-- @param[type=number]   _EventID  ID des Event
-- @param[type=function] _Function Listener Funktion
-- @return[type=number] ID des Listener
-- @within Event
--
-- @usage
-- local ListenerID = API.AddScriptEventListener(QSB.ScriptEvents.SaveGameLoaded, function()
--     Logic.DEBUG_AddNote("A save has been loaded!");
-- end);
--
function API.AddScriptEventListener(_EventID, _Function)
    if not Swift.Event.ScriptEventListener[_EventID] then
        Swift.Event.ScriptEventListener[_EventID] = {
            IDSequence = 0;
        }
    end
    local Data = Swift.Event.ScriptEventListener[_EventID];
    assert(type(_Function) == "function");
    Swift.Event.ScriptEventListener[_EventID].IDSequence = Data.IDSequence +1;
    Swift.Event.ScriptEventListener[_EventID][Data.IDSequence] = _Function;
    return Data.IDSequence;
end

---
-- Entfernt einen Listener von dem Event.
--
-- @param[type=number] _EventID ID des Event
-- @param[type=number] _ID      ID des Listener
-- @within Event
--
function API.RemoveScriptEventListener(_EventID, _ID)
    if Swift.Event.ScriptEventListener[_EventID] then
        Swift.Event.ScriptEventListener[_EventID][_ID] = nil;
    end
end

-- Entity

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- Für Siedler wird automatisch die Tasklist TL_NPC_IDLE gesetzt, damit
-- sie nicht versteinert in der Landschaft rumstehen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Entity
-- @usage
-- API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local ID1 = GetID(_Entity);
    if ID1 == 0 then
        return;
    end
    local pos = GetPosition(ID1);
    local player = _NewOwner or Logic.EntityGetPlayer(ID1);
    local orientation = Logic.GetEntityOrientation(ID1);
    local name = Logic.GetEntityName(ID1);
    DestroyEntity(ID1);
    local ID2 = Logic.CreateEntity(_Type, pos.X, pos.Y, orientation, player);
    Logic.SetEntityName(ID2, name);
    if Logic.IsSettler(ID2) == 1 then
        Logic.SetTaskList(ID2, TaskLists.TL_NPC_IDLE);
    end
    return ID2;
end
ReplaceEntity = API.ReplaceEntity;

---
-- Gibt den Typen des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Typ des Entity
-- @within Entity
--
function API.GetEntityType(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetEntityType(EntityID);
    end
    error("API.EntityGetType: _Entity (" ..tostring(_Entity).. ") must be a leader with soldiers!");
    return 0;
end

---
-- Gibt den Typnamen des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=string] Typname des Entity
-- @within Entity
--
function API.GetEntityTypeName(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityTypeName: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    return Logic.GetEntityTypeName(API.GetEntityType(_Entity));
end

---
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
--
-- @param               _Entity Entity (Scriptname oder ID)
-- @param[type=boolean] _Flag Verwundbar
-- @within Entity
--
function API.SetEntityVulnerableFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 1) or 0;
    if EntityID > 0 then
        if API.CountSoldiersOfGroup(EntityID) > 0 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                Logic.SetEntityInvulnerabilityFlag(v, VulnerabilityFlag);
            end
        end
        Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
    end
end

MakeVulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, false);
end
MakeInvulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, true);
end

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- @param _Position                        Position (Skriptname oder Entity-ID)
-- @param[type=number] _PlayerID           Zielspieler
-- @param[type=number] _GoodType           Warentyp
-- @param[type=number] _Amount             Warenmenge
-- @param[type=number] _CartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _IgnoreReservation (optional) Marktplatzreservation ignorieren
-- @param[type=boolean] _Overtake          (optional) Mit Position austauschen
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within Entity
-- @usage
-- -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
--
function API.SendCart(_Position, _PlayerID, _GoodType, _Amount, _CartOverlay, _IgnoreReservation, _Overtake)
    local OriginalID = GetID(_Position);
    if not IsExisting(OriginalID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(OriginalID);
    local ResourceCategory = Logic.GetGoodCategoryForGoodType(_GoodType);
    local Orientation = Logic.GetEntityOrientation(OriginalID);
    local ScriptName = Logic.GetEntityName(OriginalID);
    if Logic.IsBuilding(OriginalID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(OriginalID);
        Orientation = Logic.GetEntityOrientation(OriginalID)-90;
    end

    -- Macht Waren lagerbar im Lagerhaus
    if ResourceCategory == GoodCategories.GC_Resource or _GoodType == Goods.G_None then
        local TypeName = Logic.GetGoodTypeName(_GoodType);
        local SHID = Logic.GetStoreHouse(_PlayerID);
        local HQID = Logic.GetHeadquarters(_PlayerID);
        if SHID ~= 0 and Logic.GetIndexOnInStockByGoodType(SHID, _GoodType) == -1 then
            if _GoodType ~= Goods.G_Gold or (_GoodType == Goods.G_Gold and HQID == 0) then
                info(
                    "API.SendCart: creating stock for " ..TypeName.. " in" ..
                    "storehouse of player " .._PlayerID.. "."
                );
                Logic.AddGoodToStock(SHID, _GoodType, 0, true, true);
            end
        end
    end

    info("API.SendCart: Creating cart ("..
        tostring(_Position) ..","..
        tostring(_PlayerID) ..","..
        Logic.GetGoodTypeName(_GoodType) ..","..
        tostring(_Amount) ..","..
        tostring(_CartOverlay) ..","..
        tostring(_IgnoreReservation) ..
    ")");

    if ResourceCategory == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y, Orientation, _PlayerID);
    elseif _GoodType == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y, Orientation,_PlayerID);
    elseif _GoodType == Goods.G_Gold or _GoodType == Goods.G_None or _GoodType == Goods.G_Information then
        if _CartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_CartOverlay, x, y, Orientation, _PlayerID);
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y, Orientation, _PlayerID);
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y, Orientation, _PlayerID);
    end
    info("API.SendCart: Executing hire merchant...");
    Logic.HireMerchant(ID, _PlayerID, _GoodType, _Amount, _PlayerID, _IgnoreReservation);
    if _Overtake and Logic.IsBuilding(OriginalID) == 0 then
        info("API.SendCart: Cart replaced original.");
        Logic.SetEntityName(ID, ScriptName);
        DestroyEntity(OriginalID);
    end
    info("API.SendCart: Cart has been send successfully.");
    return ID
end

---
-- Gibt die relative Gesundheit des Entity zurück.
--
-- <b>Hinweis</b>: Der Wert wird als Prozentwert zurückgegeben. Das bedeutet,
-- der Wert liegt zwischen 0 und 100.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Aktuelle Gesundheit
-- @within Entity
--
function API.GetEntityHealth(_Entity)
    local EntityID = GetID(_Entity);
    if IsExisting(EntityID) then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        local Health    = Logic.GetEntityHealth(EntityID);
        return (Health/MaxHealth) * 100;
    end
    error("API.GetEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Health   Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within Entity
--
function API.ChangeEntityHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                API.ChangeEntityHealth(v, _Health, _Relative);
            end
        else
            local OldHealth = Logic.GetEntityHealth(EntityID);
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            if NewHealth > OldHealth then
                Logic.HealEntity(EntityID, NewHealth - OldHealth);
            elseif NewHealth < OldHealth then
                Logic.HurtEntity(EntityID, OldHealth - NewHealth);
            end
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end

---
-- Schreibt ein genaues Abbild der Table ins Log. Funktionen, Threads und
-- Metatables werden als Adresse geschrieben.
--
-- @param[type=table]  _Table Tabelle, die gedumpt wird
-- @param[type=string] _Name Optionaler Name im Log
-- @within Base
-- @local
-- @usage
-- Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Start = "{";
    if _Name then
        Start = _Name.. " = \n" ..Start;
    end
    Framework.WriteToLog(Start);

    for k, v in pairs(_Table) do
        if type(v) == "table" then
            Framework.WriteToLog("[" ..k.. "] = ");
            API.DumpTable(v);
        elseif type(v) == "string" then
            Framework.WriteToLog("[" ..k.. "] = \"" ..v.. "\"");
        else
            Framework.WriteToLog("[" ..k.. "] = " ..tostring(v));
        end
    end
    Framework.WriteToLog("}");
end

---
-- Gibt alle Kategorien zurück, zu denen das Entity gehört.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @return[type=table] Kategorien des Entity
-- @within Entity
--
function API.GetEntityCategoyList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityCategoyList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    return API.GetEntityTypeCategoyList(Logic.GetEntityType(EntityID));
end

---
-- Gibt alle Kategorien zurück, zu denen der Entity-Typ gehört.
--
-- @param              _Type Typ des Entity
-- @return[type=table] Kategorien des Entity
-- @within Entity
--
function API.GetEntityTypeCategoyList(_Type)
    local Categories = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityTypeInCategory(_Type, v) == 1 then
            Categories[#Categories+1] = v;
        end
    end
    return Categories;
end

---
-- Prüft, ob das Entity mindestens eine der Kategorien hat.
--
-- @param              _Entity Entity (Skriptname oder ID)
-- @param[type=number] ...     Liste mit Kategorien
-- @return[type=boolean] Entity hat Kategorie
-- @within Entity
--
function API.IsEntityInAtLeastOneCategory(_Entity, ...)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        for k, v in pairs(arg) do
            if table.contains(API.GetEntityCategoyList(_Entity), v) then
                return true;
            end
        end
        return;
    end
    error("API.IsEntityInAtLeastOneCategory: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end

---
-- Gibt die aktuelle Tasklist des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Tasklist
-- @within Entity
--
function API.GetEntityTaskList(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    local CurrentTask = Logic.GetCurrentTaskList(EntityID) or "";
    return TaskLists[CurrentTask];
end

---
-- Weist dem Entity ein Neues Model zu.
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewModel Neues Model
-- @param[type=number] _AnimSet  (optional) Animation Set
-- @within Entity
--
function API.SetEntityModel(_Entity, _NewModel, _AnimSet)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityModel: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewModel) ~= "number" or _NewModel < 1 then
        error("API.SetEntityModel: _NewModel (" ..tostring(_NewModel).. ") is wrong!");
        return;
    end
    if _AnimSet and (type(_AnimSet) ~= "number" or _AnimSet < 1) then
        error("API.SetEntityModel: _AnimSet (" ..tostring(_AnimSet).. ") is wrong!");
        return;
    end
    if not _AnimSet then
        Logic.SetModel(EntityID, _NewModel);
    else
        Logic.SetModelAndAnimSet(EntityID, _NewModel, _AnimSet);
    end
end

---
-- Setzt die aktuelle Tasklist des Entity.
--
-- @param              _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _NewTask Neuer Task
-- @within Entity
--
function API.SetEntityTaskList(_Entity, _NewTask)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityTaskList: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_NewTask) ~= "number" or _NewTask < 1 then
        error("API.SetEntityTaskList: _NewTask (" ..tostring(_NewTask).. ") is wrong!");
        return;
    end
    Logic.SetTaskList(EntityID, _NewTask);
end

---
-- Gibt die Menge an Rohstoffen des Entity zurück. Optional kann
-- eine neue Menge gesetzt werden.
--
-- @param _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Menge an Rohstoffen
-- @within Entity
--
function API.GetResourceAmount(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return Logic.GetResourceDoodadGoodAmount(EntityID);
    end
    error("API.GetResourceAmount: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end

---
-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- @param              _Entity       Rohstoffvorkommen (Skriptname oder ID)
-- @param[type=number] _StartAmount  Menge an Rohstoffen
-- @param[type=number] _RefillAmount Minimale Nachfüllmenge (> 0)
-- @within Entity
--
-- @usage
-- API.SetResourceAmount("mine1", 250, 150);
--
function API.SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    if GUI or not IsExisting(_Entity) then
        return;
    end
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");

    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        return;
    end
    if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
        EntityID = ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
    end
    Logic.SetResourceDoodadGoodAmount(EntityID, _StartAmount);
    if _RefillAmount then
        QSB.RefillAmounts[EntityID] = _RefillAmount;
    end
end

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- @param[type=number] _PlayerID  PlayerID [0-8] oder -1 für alle
-- @param[type=number] _Category  Kategorie, der die Entities angehören
-- @param[type=number] _Territory Zielterritorium
-- @within Entity
-- @local
-- @usage
-- local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_PlayerID, _Category, _Territory)
    local PlayerEntities = {};
    local Units = {};
    if (_PlayerID == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_Territory, i, _Category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_Territory, _PlayerID, _Category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end

---
-- Sucht auf den angegebenen Territorium nach Entities mit bestimmten
-- Kategorien. Dabei kann für eine Partei oder für mehrere Parteien gesucht
-- werden.
--
-- @param _PlayerID    PlayerID [0-8] oder Table mit PlayerIDs (Einzelne Spielernummer oder Table)
-- @param _Category    Kategorien oder Table mit Kategorien (Einzelne Kategorie oder Table)
-- @param _Territory   Zielterritorium oder Table mit Territorien (Einzelnes Territorium oder Table)
-- @return[type=table] Liste mit Resultaten
-- @within Entity
--
-- @usage
-- local Result = API.GetEntitiesOfCategoriesInTerritories({1, 2, 3}, EntityCategories.Hero, {5, 12, 23, 24});
--
function API.GetEntitiesOfCategoriesInTerritories(_PlayerID, _Category, _Territory)
    -- Tables erzwingen
    local p = (type(_PlayerID) == "table" and _PlayerID) or {_PlayerID};
    local c = (type(_Category) == "table" and _Category) or {_Category};
    local t = (type(_Territory) == "table" and _Territory) or {_Territory};

    local PlayerEntities = {};
    for i=1, #p, 1 do
        for j=1, #c, 1 do
            for k=1, #t, 1 do  
                local Units = API.GetEntitiesOfCategoryInTerritory(p[i], c[j], t[k]);
                PlayerEntities = Array_Append(PlayerEntities, Units);
            end
        end
    end
    return PlayerEntities;
end

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within Entity
--
function API.CreateEntityName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "AutomaticScriptName_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end

-- Mögliche (zufällige) Siedler, getrennt in männlich und weiblich.
QSB.PossibleSettlerTypes = {
    Male = {
        Entities.U_BannerMaker,
        Entities.U_Baker,
        Entities.U_Barkeeper,
        Entities.U_Blacksmith,
        Entities.U_Butcher,
        Entities.U_BowArmourer,
        Entities.U_BowMaker,
        Entities.U_CandleMaker,
        Entities.U_Carpenter,
        Entities.U_DairyWorker,
        Entities.U_Pharmacist,
        Entities.U_Tanner,
        Entities.U_SmokeHouseWorker,
        Entities.U_Soapmaker,
        Entities.U_SwordSmith,
        Entities.U_Weaver,
    },
    Female = {
        Entities.U_BathWorker,
        Entities.U_SpouseS01,
        Entities.U_SpouseS02,
        Entities.U_SpouseS03,
        Entities.U_SpouseF01,
        Entities.U_SpouseF02,
        Entities.U_SpouseF03,
    }
}

---
-- Wählt aus einer festen Liste von Typen einen zufälligen Siedler-Typ aus.
-- Es werden nur Stadtsiedler zurückgegeben. Sie können männlich oder
-- weiblich sein.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomSettlerType()
    local Gender = (math.random(1, 2) == 1 and "Male") or "Female";
    local Type   = math.random(1, #QSB.PossibleSettlerTypes[Gender]);
    return QSB.PossibleSettlerTypes[Gender][Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen männlichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomMaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Male);
    return QSB.PossibleSettlerTypes.Male[Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen weiblichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomFemaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Female);
    return QSB.PossibleSettlerTypes.Female[Type];
end

-- Group

---
-- Gibt die Mänge an Soldaten zurück, die dem Entity unterstehen
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Gruppe
--
function API.CountSoldiersOfGroup(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.CountSoldiersOfGroup: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsLeader(EntityID) == 0 then
        return 0;
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    return SoldierTable[1];
end

---
-- Gibt die IDs aller Soldaten zurück, die zum Battalion gehören.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Liste aller Soldaten
-- @within Gruppe
--
function API.GetGroupSoldiers(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupSoldiers: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return {};
    end
    if Logic.IsLeader(EntityID) == 0 then
        return {};
    end
    local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
    table.remove(SoldierTable, 1);
    return SoldierTable;
end

---
-- Gibt den Leader des Soldaten zurück.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Gruppe
--
function API.GetGroupLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupLeader: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 0 then
        return 0;
    end
    return Logic.SoldierGetLeaderEntityID(EntityID);
end

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within Gruppe
--
function API.GroupHeal(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        error("API.GroupHeal: _Entity (" ..tostring(_Entity).. ") must be an existing leader!");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.GroupHeal: _Amount (" ..tostring(_Amount).. ") must greatier than 0!");
        return;
    end
    API.ChangeEntityHealth(EntityID, Logic.GetEntityHealth(EntityID) + _Amount);
end

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within Gruppe
--
function API.GroupHurt(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GroupHurt: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if API.IsEntityInAtLeastOneCategory(EntityID, EntityCategories.Soldier) then
        API.GroupHurt(API.GetGroupLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        EntityToHurt = API.GetGroupSoldiers(EntityToHurt)[1];
    end
    if type(_Damage) ~= "number" or _Damage < 0 then
        error("API.GroupHurt: _Damage (" ..tostring(_Damage).. ") must be greater than 0!");
        return;
    end

    if EntityToHurt then
        local Health = Logic.GetEntityHealth(EntityToHurt);
        if Health <= _Damage then
            _Damage = _Damage - Health;
            Logic.HurtEntity(EntityToHurt, Health);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
            if IsLeader and _Damage > 0 then
                API.GroupHurt(EntityToHurt, _Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            Swift:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
        end
    end
end

-- Object --

---
-- Aktiviert ein Interaktives Objekt.
--
-- <b>Hinweis</b>: Diese Funktion wird von einem anderen Modul überschrieben!<br>
-- <a href="Swift_2_ObjectInteraction.api.html#API.InteractiveObjectActivate">(2) Object Interaction</a>
--
-- @param[type=string] _EntityName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @within Entity
--
function API.InteractiveObjectActivate(_ScriptName, _State)
    _State = _State or 0;
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt.
--
-- <b>Hinweis</b>: Diese Funktion wird von einem anderen Modul überschrieben!<br>
-- <a href="Swift_2_ObjectInteraction.api.html#API.InteractiveObjectDeactivate">(2) Object Interaction</a>
--
-- @param[type=string] _EntityName Scriptname des Objektes
-- @within Entity
--
function API.InteractiveObjectDeactivate(_ScriptName)
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

-- Position And Orientation

---
-- Gibt die Ausrichtung des Entity zurück.
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @return[type=number] Ausrichtung in Grad
-- @within Entity
--
function API.GetEntityOrientation(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.Round(Logic.GetEntityOrientation(EntityID));
    end
    error("API.GetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end

---
-- Setzt die Ausrichtung des Entity.
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _Orientation Neue Ausrichtung
-- @within Entity
--
function API.SetEntityOrientation(_Entity, _Orientation)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if type(_Orientation) ~= "number" then
            error("API.SetEntityOrientation: _Orientation is wrong!");
            return
        end
        Logic.SetOrientation(EntityID, API.Round(_Orientation));
    else
        error("API.SetEntityOrientation: _Entity (" ..tostring(_Entity).. ") does not exist!");
    end
end

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param _Target      Ziel (Skriptname, ID oder Position)
-- @param[type=number] _Offset Winkel Offset
-- @within Entity
-- @usage
-- API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_Entity, _Target, _Offset)
    _Offset = _Offset or 0;
    local ID1 = GetID(_Entity);
    if ID1 == 0 then
        return;
    end
    local x1,y1,z1 = Logic.EntityGetPos(ID1);
    local ID2;
    local x2, y2, z2;
    if type(_Target) == "table" then
        x2 = _Target.X;
        y2 = _Target.Y;
        z2 = _Target.Z;
    else
        ID2 = GetID(_Target);
        if ID2 == 0 then
            return;
        end
        x2,y2,z2 = Logic.EntityGetPos(ID2);
    end

    if not API.IsValidPosition({X= x1, Y= y1, Z= z1}) then
        return;
    end
    if not API.IsValidPosition({X= x2, Y= y2, Z= z2}) then
        return;
    end
    Angle = math.deg(math.atan2((y2 - y1), (x2 - x1))) + _Offset;
    if Angle < 0 then
        Angle = Angle + 360;
    end

    if Logic.IsLeader(ID1) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID1)};
        for i= 2, Soldiers[1]+1 do
            Logic.SetOrientation(Soldiers[i], Angle);
        end
    end
    Logic.SetOrientation(ID1, Angle);
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Entity
-- @usage
-- API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Position
-- @usage
-- local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        warn("API.GetDistance: Distance could not be calculated!");
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Bestimmt den Winkel zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- @param _Pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _Pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Winkel zwischen den Punkten
-- @within Position
-- @usage
-- local Angle = API.GetAngleBetween("HQ1", Logic.GetKnightID(1))
--
function API.GetAngleBetween(_Pos1, _Pos2)
	local delta_X = 0;
	local delta_Y = 0;
	local alpha   = 0;
	if type (_Pos1) == "string" or type (_Pos1) == "number" then
		_Pos1 = GetPosition(GetID(_Pos1));
	end
	if type (_Pos2) == "string" or type (_Pos2) == "number" then
		_Pos2 = GetPosition(GetID(_Pos2));
	end
	delta_X = _Pos1.X - _Pos2.X;
	delta_Y = _Pos1.Y - _Pos2.Y;
	if delta_X == 0 and delta_Y == 0 then
		return 0;
	end
	alpha = math.deg(math.asin(math.abs(delta_X)/(math.sqrt((delta_X ^ 2)+delta_Y ^ 2))));
	if delta_X >= 0 and delta_Y > 0 then
		alpha = 270 - alpha ;
	elseif delta_X < 0 and delta_Y > 0 then
		alpha = 270 + alpha;
	elseif delta_X < 0 and delta_Y <= 0 then
		alpha = 90  - alpha;
	elseif delta_X >= 0 and delta_Y <= 0 then
		alpha = 90  + alpha;
	end
	return alpha;
end

---
-- Gibt das Entity aus der Liste zurück, welches dem Ziel am nähsten ist.
--
-- @param             _Target Entity oder Position
-- @param[type=table] _List   Liste von Entities oder Positionen
-- @return Nähste Entity oder Position
-- @within Position
-- @usage
-- local Clostest = API.GetClosestToTarget("HQ1", {"Marcus", "Alandra", "Hakim"});
--
function API.GetClosestToTarget(_Target, _List)
    local ClosestToTarget = 0;
    local ClosestToTargetDistance = Logic.WorldGetSize();
    for i= 1, #_List, 1 do
        local DistanceBetween = API.GetDistance(_List[i], _Target);
        if DistanceBetween < ClosestToTargetDistance then
            ClosestToTargetDistance = DistanceBetween;
            ClosestToTarget = _List[i];
        end
    end
    return ClosestToTarget;
end

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Position
-- @usage
-- local Position = API.GetPosition("Hans");
--
function API.GetPosition(_Entity)
    if _Entity == nil then
        return {X= 0, Y= 0, Z= 0};
    end
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        warn("API.GetPosition: Entity (" ..tostring(_Entity).. ") does not exist!");
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= API.Round(x), Y= API.Round(y), Z= API.Round(y)};
end
API.LocateEntity = API.GetPosition;
GetPosition = API.GetPosition;

---
-- Setzt ein Entity auf eine neue Position
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param _Target Ziel (Skriptname, ID oder Position)
-- @within Position
-- @usage
-- API.SetPosition("Hans", "Horst");
--
function API.SetPosition(_Entity, _Target)
    local ID = GetID(_Entity);
    if not ID then
        return;
    end

    local Target;
    if type(_Target) ~= "table" then
        local ID2 = GetID(_Target);
        local x,y,z = Logic.EntityGetPos(ID2);
        Target = {X= x, Y= y};
    else
        Target = _Target;
    end

    if Logic.IsLeader(ID) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
        for i= 2, Soldiers[1]+1 do
            Logic.DEBUG_SetSettlerPosition(Soldiers[i], Target.X, Target.Y);
        end
    end
    Logic.DEBUG_SetSettlerPosition(ID, Target.X, Target.Y);
end
API.RelocateEntity = API.SetPosition;
SetPosition = API.SetPosition;

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Position
--
function API.IsValidPosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()};
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X < world[1] and _pos.X > 0 and _pos.Y < world[2] and _pos.Y > 0 then
                return true;
            end
        end
    end
    return false;
end

-- Math --

---
-- Bestimmt die Durchschnittsposition mehrerer Entities.
--
-- @param ... Positionen mit Komma getrennt
-- @return[type=table] Durchschnittsposition aller Positionen
-- @within Mathematik
-- @usage
-- local Center = API.GetGeometricFocus("Hakim", "Marcus", "Alandra");
--
function API.GetGeometricFocus(...)
    local PositionData = {X= 0, Y= 0, Z= 0};
    local ValidEntryCount = 0;
    for i= 1, #arg do
        local Position = API.GetPosition(arg[i]);
        if API.IsValidPosition(Position) then
            PositionData.X = PositionData.X + Position.X;
            PositionData.Y = PositionData.Y + Position.Y;
            PositionData.Z = PositionData.Z + (Position.Z or 0);
            ValidEntryCount = ValidEntryCount +1;
        end
    end
    return {
        X= PositionData.X * (1/ValidEntryCount);
        Y= PositionData.Y * (1/ValidEntryCount);
        Z= PositionData.Z * (1/ValidEntryCount);
    }
end

---
-- Gib eine Position auf einer Linie im relativen Abstand zur ersten Position
-- zurück.
--
-- @param               _Pos1       Erste Position
-- @param               _Pos2       Zweite Position
-- @param[type=number]  _Percentage Entfernung zu Erster Position
-- @return[type=table] Position auf Linie
-- @within Mathematik
-- @usage
-- local Position = API.GetLinePosition("HQ1", "HQ2", 0.75);
--
function API.GetLinePosition(_Pos1, _Pos2, _Percentage)
    if _Percentage > 1 then
        _Percentage = _Percentage / 100;
    end

    if not API.IsValidPosition(_Pos1) and not IsExisting(_Pos1) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos1 = _Pos1;
    if type(Pos1) ~= "table" then
        Pos1 = GetPosition(Pos1);
    end

    if not API.IsValidPosition(_Pos2) and not IsExisting(_Pos2) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos2 = _Pos2;
    if type(Pos2) ~= "table" then
        Pos2 = GetPosition(Pos2);
    end

	local dx = Pos2.X - Pos1.X;
	local dy = Pos2.Y - Pos1.Y;
    return {X= Pos1.X+(dx*_Percentage), Y= Pos1.Y+(dy*_Percentage)};
end

---
-- Gib Positionen im gleichen Abstand auf der Linie zurück.
--
-- @param               _Pos1    Erste Position
-- @param               _Pos2    Zweite Position
-- @param[type=number]  _Periode Anzahl an Positionen
-- @return[type=table] Positionen auf Linie
-- @within Mathematik
-- @usage
-- local PositionList = API.GetLinePosition("HQ1", "HQ2", 6);
--
function API.GetLinePositions(_Pos1, _Pos2, _Periode)
    local PositionList = {};
    for i= 0, 100, (1/_Periode)*100 do
        local Section = API.GetLinePosition(_Pos1, _Pos2, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

---
-- Gibt eine Position auf einer Kreisbahn um einen Punkt zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Angle           Winkel auf dem Kreis
-- @return[type=table] Position auf Kreisbahn
-- @within Mathematik
-- @usage
-- local Position = API.GetCirclePosition("HQ1", 3000, -45);
--
function API.GetCirclePosition(_Target, _Distance, _Angle)
    if not API.IsValidPosition(_Target) and not IsExisting(_Target) then
        error("API.GetCirclePosition: _Target does not exist or is invalid position!");
        return;
    end

    local Position = _Target;
    local Orientation = 0+ (_Angle or 0);
    if type(_Target) ~= "table" then
        local EntityID = GetID(_Target);
        Orientation = Logic.GetEntityOrientation(EntityID)+(_Angle or 0);
        Position = GetPosition(EntityID);
    end

    local Result = {
        X= Position.X+_Distance * math.cos(math.rad(Orientation)),
        Y= Position.Y+_Distance * math.sin(math.rad(Orientation)),
        Z= Position.Z
    };
    return Result;
end
API.GetRelatiePos = API.GetCirclePosition;

---
-- Gibt Positionen im gleichen Abstand auf der Kreisbahn zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Periode         Anzahl an Positionen
-- @param[type=number]  _Offset          Start Offset
-- @return[type=table] Positionend auf Kreisbahn
-- @within Mathematik
-- @usage
-- local PositionList = API.GetCirclePosition("Position", 3000, 6, 45);
--
function API.GetCirclePositions(_Target, _Distance, _Periode, _Offset)
    local Periode = API.Round(360 / _Periode, 0);
    local PositionList = {};
    for i= (Periode + _Offset), (360 + _Offset) do
        local Section = API.GetCirclePosition(_Target, _Distance, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

-- Quest --

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
    -- Alle Änderungen an Standardbehavior müssen hier berücksichtigt werden.
    -- Wird ein Standardbehavior in einem Modul verändert, muss auch diese
    -- Funktion angepasst oder überschrieben werden.
    
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
        -- Note: This is a special operation outside of the quest system!
        Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            "Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.QuestReset, %d)",
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

-- AI

---
-- Aktiviert Feste für den angegebenen KI-Spieler.
--
-- @param[type=number]  _PlayerID ID der KI
-- @within AI
--
function API.AllowFestival(_PlayerID)
    Swift.AIProperties[_PlayerID].ForbidFestival = false;
end

---
-- Deaktiviert Feste für den angegebenen KI-Spieler.
--
-- @param[type=number]  _PlayerID ID der KI
-- @within AI
--
function API.ForbidFestival(_PlayerID)
    Swift.AIProperties[_PlayerID].ForbidFestival = true;
end

---
-- Startet die Map sofort neu.
--
-- <b>Achtung:</b> Die Funktion Framework.RestartMap kann nicht mehr verwendet
-- werden, da es sonst zu Fehlern mit dem Ladebildschirm kommt!
--
-- @within Base
--
function API.RestartMap()
    Camera.RTS_FollowEntity(0);
    Framework.SetLoadScreenNeedButton(1);
    Framework.RestartMap();
end

-- Local callbacks

function SCP.Core.LoadscreenHidden()
    -- FIXME: Maybe the whole loadscreen hidden business should be converted
    -- into an event on wich every module can listen to? This way of doing it
    -- is a relict from ancient times before the event system...
    Swift.LoadScreenHidden = true;
    API.SendScriptEvent(QSB.ScriptEvents.LoadscreenClosed);
    Logic.ExecuteInLuaLocalState([[
        Swift.LoadScreenHidden = true
        API.SendScriptEvent(QSB.ScriptEvents.LoadscreenClosed)
    ]]);
end

function SCP.Core.GlobalQsbLoaded()
    if Mission_MP_OnQsbLoaded and not Swift.MP_FMA_Loaded and Framework.IsNetworkGame() then
        Logic.ExecuteInLuaLocalState([[
            if Mission_MP_LocalOnQsbLoaded then
                Mission_MP_LocalOnQsbLoaded();
            end
        ]]);
        Swift.MP_FMA_Loaded = true;
        Mission_MP_OnQsbLoaded();
    end
end

function SCP.Core.ProclaimateRandomSeed(_Seed)
    if Swift.MP_Seed_Set then
        return;
    end
    Swift.MP_Seed_Set = true;
    math.randomseed(_Seed);
    local void = math.random(1, 100);
    Logic.ExecuteInLuaLocalState(string.format([[math.randomseed(%d); math.random(1, 100)]], _Seed));
    info("Created seed: " .._Seed);
end

function SCP.Core.UpdateCustomVariable(_Name, Value)
    Swift:UpdateCustomVariable(_Name, Value);
end

function SCP.Core.UpdateTexturePosition(_Category, _Key, _Value)
    g_TexturePositions = g_TexturePositions or {};
    g_TexturePositions[_Category] = g_TexturePositions[_Category] or {};
    g_TexturePositions[_Category][_Key] = _Value;
end

function SCP.Core.LanguageChanged(_PlayerID, _GUI_PlayerID, _Language)
    Swift:ChangeSystemLanguage(_PlayerID, _Language, _GUI_PlayerID);
end

