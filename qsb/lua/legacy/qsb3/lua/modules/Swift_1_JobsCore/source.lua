--[[
Swift_1_JobsCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleJobsCore = {
    Properties = {
        Name = "ModuleJobsCore",
    },

    Global = {};
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        EventJobMappingID = 0,
        EventJobMapping = {},
        EventJobs = {},
        TimeLineData = {},
        SecondsSinceGameStart = 0;
        LastTimeStamp = 0;
    };
};

function ModuleJobsCore.Global:OnGameStart()
    ModuleJobsCore.Shared:InstallBaseEventJobs();
end

function ModuleJobsCore.Local:OnGameStart()
    ModuleJobsCore.Shared:InstallBaseEventJobs();
end

function ModuleJobsCore.Shared:CreateEventJob(_Type, _Function, ...)
    self.EventJobMappingID = self.EventJobMappingID +1;
    local ID = Trigger.RequestTrigger(
        _Type,
        "",
        "ModuleJobCore_EventJob_BasicEventJobExecutor",
        1,
        {},
        {self.EventJobMappingID}
    );
    self.EventJobs[ID] = {ID, true, _Function, table.copy(arg)};
    self.EventJobMapping[self.EventJobMappingID] = ID;
    return ID;
end

function ModuleJobsCore.Shared:InstallBaseEventJobs()
    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_TURN,
        "",
        "ModuleJobCore_EventJob_RealtimeController",
        1
    );
end

-- Real Time

function ModuleJobCore_EventJob_RealtimeController()
    if not ModuleJobsCore.Shared.LastTimeStamp then
        ModuleJobsCore.Shared.LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    if ModuleJobsCore.Shared.LastTimeStamp ~= CurrentTimeStamp then
        ModuleJobsCore.Shared.LastTimeStamp = CurrentTimeStamp;
        ModuleJobsCore.Shared.SecondsSinceGameStart = ModuleJobsCore.Shared.SecondsSinceGameStart +1;
    end
end

-- Event Jobs

function ModuleJobCore_EventJob_BasicEventJobExecutor(_MappingID)
    local ID = ModuleJobsCore.Shared.EventJobMapping[_MappingID];
    if ID and ModuleJobsCore.Shared.EventJobs[ID] and ModuleJobsCore.Shared.EventJobs[ID][2] then
        local Parameter = ModuleJobsCore.Shared.EventJobs[ID][4];
        if ModuleJobsCore.Shared.EventJobs[ID][3](unpack(Parameter)) then
            ModuleJobsCore.Shared.EventJobs[ID][2] = false;
        end
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleJobsCore);

