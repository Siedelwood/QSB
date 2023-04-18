--[[
Swift_1_JobsCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul erweitert die standardmäßig vorhandenen Jobs. Du kannst für
-- jedes (in Siedler implementierte) Event einen Job als Funktionsreferenz
-- oder Inline Job schreiben.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
-- @usage
-- local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return ModuleJobsCore.Shared.SecondsSinceGameStart;
end

---
-- Erzeugt einen neuen Event-Job.
--
-- <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
-- können ResumeJob und YieldJob auf den Job angewendet werden.
--
-- <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!
--
-- <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
-- Kopie angelegt um Speicherprobleme zu verhindern. Es handelt sich also um
-- eine neue Table und keine Referenz!
--
-- @param[type=number]   _EventType Event-Typ
-- @param _Function      Funktion (Funktionsreferenz oder String)
-- @param ...            Optionale Argumente des Job
-- @return[type=number] ID des Jobs
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartJobByEventType(
--     Events.LOGIC_EVENT_EVERY_SECOND,
--     FunctionRefToCall
-- );
--
function API.StartJobByEventType(_EventType, _Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartJobByEventType: Can not find function!")
        return;
    end
    return ModuleJobsCore.Shared:CreateEventJob(_EventType, _Function, unpack(arg));
end

---
-- Führt eine Funktion ein mal pro Sekunde aus. Die weiteren Argumente werden an
-- die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
--
-- @usage
-- -- Führt eine Funktion nach 15 Sekunden aus.
-- API.StartJob(function(_Time, _EntityType)
--     if Logic.GetTime() > _Time + 15 then
--         MachWas(_EntityType);
--         return true;
--     end
-- end, Logic.GetTime(), Entities.U_KnightHealing)
--
-- -- Startet einen Job
-- StartSimpleJob("MeinJob");
--
function API.StartJob(_Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartJob: _Function must be a function!");
        return;
    end
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_SECOND, Function, unpack(arg));
end
StartSimpleJob = API.StartJob;
StartSimpleJobEx = API.StartJob;

---
-- Führt eine Funktion ein mal pro Turn aus. Ein Turn entspricht einer 1/10
-- Sekunde in der Spielzeit. Die weiteren Argumente werden an die Funktion
-- übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
-- @see API.StartJob
--
function API.StartHiResJob(_Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartHiResJob: _Function must be a function!");
        return;
    end
    return API.StartJobByEventType(Events.LOGIC_EVENT_EVERY_TURN, Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

---
-- Beendet den Job mit der übergebenen ID endgültig.
--
-- @param[type=number] _JobID ID des Jobs
-- @within Anwenderfunktionen
--
-- @usage
-- API.EndJob(AnyJobID);
--
function API.EndJob(_JobID)
    if ModuleJobsCore.Shared.EventJobs[_JobID] then
        Trigger.UnrequestTrigger(ModuleJobsCore.Shared.EventJobs[_JobID][1]);
        ModuleJobsCore.Shared.EventJobs[_JobID] = nil;
        return;
    end
    EndJob(_JobID);
end

---
-- Gibt zurück, ob der Job mit der übergebenen ID aktiv ist.
--
-- @param[type=number] _JobID ID des Jobs
-- @return[type=boolean] Job ist aktiv
-- @within Anwenderfunktionen
--
-- @usage
-- if API.JobIsRunning(AnyJobID) then
--     -- Mach was
-- end;
--
function API.JobIsRunning(_JobID)
    if ModuleJobsCore.Shared.EventJobs[_JobID] then
        return ModuleJobsCore.Shared.EventJobs[_JobID][2] == true;
    end
    return JobIsRunning(_JobID);
end

---
-- Aktiviert einen pausierten Job.
--
-- @param[type=number] _JobID ID des Jobs
-- @within Anwenderfunktionen
--
-- @usage
-- API.ResumeJob(AnyJobID);
--
function API.ResumeJob(_JobID)
    if ModuleJobsCore.Shared.EventJobs[_JobID] then
        if ModuleJobsCore.Shared.EventJobs[_JobID][2] ~= true then
            ModuleJobsCore.Shared.EventJobs[_JobID][2] = true;
        end
        return;
    end
    error("API.ResumeJob: Job " ..tostring(_JobID).. " can not be resumed!");
end

---
-- Pausiert einen aktivien Job.
--
-- @param[type=number] _JobID ID des Jobs
-- @within Anwenderfunktionen
--
-- @usage
-- API.YieldJob(AnyJobID);
--
function API.YieldJob(_JobID)
    if ModuleJobsCore.Shared.EventJobs[_JobID] then
        if ModuleJobsCore.Shared.EventJobs[_JobID][2] == true then
            ModuleJobsCore.Shared.EventJobs[_JobID][2] = false;
        end
        return;
    end
    error("API.YieldJob: Job " ..tostring(_JobID).. " can not be paused!");
end

---
-- Wartet die angebene Zeit in Sekunden und führt anschließend die Funktion aus.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- @param[type=number] _Waittime   Wartezeit in Sekunden
-- @param[type=function] _Function Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartDelay(
--     30,
--     function()
--         Logic.DEBUG_AddNote("Zeit abgelaufen!");
--     end
-- )
--
function API.StartDelay(_Waittime, _Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartDelay: _Function must be a function!");
        return;
    end
    return API.StartHiResJob(
        function(_StartTime, _Delay, _Callback, _Arguments)
            if _StartTime + _Delay <= Logic.GetTime() then
                _Callback(unpack(_Arguments or {}));
                return true;
            end
        end,
        Logic.GetTime(),
        _Waittime,
        _Function,
        {...}
    );
end

---
-- Wartet die angebene Zeit in Turns und führt anschließend die Funktion aus.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- @param[type=number] _Waittime   Wartezeit in Turns
-- @param[type=function] _Function Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartHiResDelay(
--     30,
--     function()
--         Logic.DEBUG_AddNote("Zeit abgelaufen!");
--     end
-- )
--
function API.StartHiResDelay(_Waittime, _Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartHiResDelay: _Function must be a function!");
        return;
    end
    return API.StartHiResJob(
        function(_StartTime, _Delay, _Callback, _Arguments)
            if _StartTime + _Delay <= Logic.GetCurrentTurn() then
                _Callback(unpack(_Arguments or {}));
                return true;
            end
        end,
        Logic.GetTime(),
        _Waittime,
        _Function,
        {...}
    );
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend die
-- Funktion aus.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- @param[type=number] _Waittime   Wartezeit in realen Sekunden
-- @param[type=function] _Function Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] ID der Verzögerung
-- @within Anwenderfunktionen
--
-- @usage
-- API.StartRealTimeDelay(
--     30,
--     function()
--         Logic.DEBUG_AddNote("Zeit abgelaufen!");
--     end
-- )
--
function API.StartRealTimeDelay(_Waittime, _Function, ...)
    local Function = _G[_Function] or _Function;
    if type(Function) ~= "function" then
        error("API.StartRealTimeDelay: _Function must be a function!");
        return;
    end
    return API.StartHiResJob(
        function(_StartTime, _Delay, _Callback, _Arguments)
            if (ModuleJobsCore.Shared.SecondsSinceGameStart >= _StartTime + _Delay) then
                _Callback(unpack(_Arguments or {}));
                return true;
            end
        end,
        ModuleJobsCore.Shared.SecondsSinceGameStart,
        _Waittime,
        _Function,
        {...}
    );
end

