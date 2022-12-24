--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Bietet erweiterte Möglichkeiten mit Jobs erweitern.
-- @set sort=true
-- @local
--

Swift.Job = {
    EventJobMappingID = 0;
    EventJobMapping = {},
    EventJobs = {},

    SecondsSinceGameStart = 0;
    LastTimeStamp = 0;
};

function Swift.Job:Initalize()
    self:StartJobs();
end

function Swift.Job:OnSaveGameLoaded()
end

function Swift.Job:StartJobs()
    -- Update Real time variable
    self:CreateEventJob(
        Events.LOGIC_EVENT_EVERY_TURN,
        function()
            Swift.Job:RealtimeController();
        end
    )
end

function Swift.Job:CreateEventJob(_Type, _Function, ...)
    self.EventJobMappingID = self.EventJobMappingID +1;
    local ID = Trigger.RequestTrigger(
        _Type,
        "",
        "QSB_EventJob_EventJobExecutor",
        1,
        {},
        {self.EventJobMappingID}
    );
    self.EventJobs[ID] = {ID, true, _Function, arg};
    self.EventJobMapping[self.EventJobMappingID] = ID;
    return ID;
end

function Swift.Job:EventJobExecutor(_MappingID)
    local ID = self.EventJobMapping[_MappingID];
    if ID and self.EventJobs[ID] and self.EventJobs[ID][2] then
        local Parameter = self.EventJobs[ID][4];
        if self.EventJobs[ID][3](unpack(Parameter)) then
            self.EventJobs[ID][2] = false;
        end
    end
end

function Swift.Job:RealtimeController()
    if not self.LastTimeStamp then
        self.LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    if self.LastTimeStamp ~= CurrentTimeStamp then
        self.LastTimeStamp = CurrentTimeStamp;
        self.SecondsSinceGameStart = self.SecondsSinceGameStart +1;
    end
end

-- -------------------------------------------------------------------------- --
-- Helper Jobs

function QSB_EventJob_EventJobExecutor(_MappingID)
    Swift.Job:EventJobExecutor(_MappingID);
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Job
--
-- @usage
-- local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return Swift.Job.SecondsSinceGameStart;
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
-- @within Job
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
        error("API.StartJobByEventType: Can not find function!");
        return;
    end
    return Swift.Job:CreateEventJob(_EventType, _Function, unpack(arg));
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
-- @within Job
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
-- @within Job
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
-- @within Job
--
-- @usage
-- API.EndJob(AnyJobID);
--
function API.EndJob(_JobID)
    if Swift.Job.EventJobs[_JobID] then
        Trigger.UnrequestTrigger(Swift.Job.EventJobs[_JobID][1]);
        Swift.Job.EventJobs[_JobID] = nil;
        return;
    end
    EndJob(_JobID);
end

---
-- Gibt zurück, ob der Job mit der übergebenen ID aktiv ist.
--
-- @param[type=number] _JobID ID des Jobs
-- @return[type=boolean] Job ist aktiv
-- @within Job
--
-- @usage
-- if API.JobIsRunning(AnyJobID) then
--     -- Mach was
-- end;
--
function API.JobIsRunning(_JobID)
    if Swift.Job.EventJobs[_JobID] then
        return Swift.Job.EventJobs[_JobID][2] == true;
    end
    return JobIsRunning(_JobID);
end

---
-- Aktiviert einen pausierten Job.
--
-- @param[type=number] _JobID ID des Jobs
-- @within Job
--
-- @usage
-- API.ResumeJob(AnyJobID);
--
function API.ResumeJob(_JobID)
    if Swift.Job.EventJobs[_JobID] then
        if Swift.Job.EventJobs[_JobID][2] ~= true then
            Swift.Job.EventJobs[_JobID][2] = true;
        end
        return;
    end
    error("API.ResumeJob: Job " ..tostring(_JobID).. " can not be resumed!");
end

---
-- Pausiert einen aktivien Job.
--
-- @param[type=number] _JobID ID des Jobs
-- @within Job
--
-- @usage
-- API.YieldJob(AnyJobID);
--
function API.YieldJob(_JobID)
    if Swift.Job.EventJobs[_JobID] then
        if Swift.Job.EventJobs[_JobID][2] == true then
            Swift.Job.EventJobs[_JobID][2] = false;
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
-- @within Job
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
    return API.StartJob(
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
-- @within Job
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
-- @within Job
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
            if (Swift.Job.SecondsSinceGameStart >= _StartTime + _Delay) then
                _Callback(unpack(_Arguments or {}));
                return true;
            end
        end,
        Swift.Job.SecondsSinceGameStart,
        _Waittime,
        _Function,
        {...}
    );
end

