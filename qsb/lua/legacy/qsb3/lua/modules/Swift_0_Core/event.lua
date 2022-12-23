--[[
Swift_0_Core/Events

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

Swift = Swift or {};
Swift.Event = {
    ScriptEventRegister   = {};
    ScriptEventListener   = {};
    ScriptCommandRegister = {};
};

-- Local Script Command

function Swift.Event:InitalizeScriptCommands()
    self:CreateScriptCommand("Cmd_SendScriptEvent", API.SendScriptEvent);
    self:CreateScriptCommand("Cmd_GlobalQsbLoaded", SCP.Core.GlobalQsbLoaded);
    self:CreateScriptCommand("Cmd_ProclaimateRandomSeed", SCP.Core.ProclaimateRandomSeed);
    self:CreateScriptCommand("Cmd_RegisterLoadscreenHidden", SCP.Core.LoadscreenHidden);
    self:CreateScriptCommand("Cmd_UpdateCustomVariable", SCP.Core.UpdateCustomVariable);
    self:CreateScriptCommand("Cmd_UpdateTexturePosition", SCP.Core.UpdateTexturePosition);
    self:CreateScriptCommand("Cmd_LanguageChanged", SCP.Core.LanguageChanged);
end

function Swift.Event:CreateScriptCommand(_Name, _Function)
    if not Swift:IsGlobalEnvironment() then
        return 0;
    end
    QSB.ScriptCommandSequence = QSB.ScriptCommandSequence +1;
    local ID = QSB.ScriptCommandSequence;
    local Name = _Name;
    if string.find(_Name, "^Cmd_") then
        Name = string.sub(_Name, 5);
    end
    self.ScriptCommandRegister[ID] = {Name, _Function};
    Logic.ExecuteInLuaLocalState(string.format(
        [[
            local ID = %d
            local Name = "%s"
            Swift.Event.ScriptCommandRegister[ID] = Name
            QSB.ScriptCommands[Name] = ID
        ]],
        ID,
        Name
    ));
    QSB.ScriptCommands[Name] = ID;
    return ID;
end

function Swift.Event:DispatchScriptCommand(_ID, ...)
    if not Swift:IsLocalEnvironment() then
        return;
    end
    assert(_ID ~= nil);
    if self.ScriptCommandRegister[_ID] then
        local PlayerID = GUI.GetPlayerID();
        local NamePlayerID = 8;
        local PlayerName = Logic.GetPlayerName(NamePlayerID);
        local Parameters = self:EncodeScriptCommandParameters(unpack(arg));
        GUI.SetPlayerName(NamePlayerID, Parameters);

        if Framework.IsNetworkGame() and self:IsHistoryEdition() then
            GUI.SetSoldierPaymentLevel(_ID);
        else
            GUI.SendScriptCommand(string.format(
                [[Swift.Event:ProcessScriptCommand(%d, %d)]],
                arg[1],
                _ID
            ));
        end
        debug(string.format(
            "Dispatching script command %s to global.",
            self.ScriptCommandRegister[_ID]
        ), true);

        GUI.SetPlayerName(NamePlayerID, PlayerName);
        GUI.SetSoldierPaymentLevel(PlayerSoldierPaymentLevel[PlayerID]);
    end
end

function Swift.Event:ProcessScriptCommand(_PlayerID, _ID)
    if not self.ScriptCommandRegister[_ID] then
        return;
    end
    local PlayerName = Logic.GetPlayerName(8);
    local Parameters = self:DecodeScriptCommandParameters(PlayerName);
    local PlayerID = table.remove(Parameters, 1);
    if PlayerID ~= 0 and PlayerID ~= _PlayerID then
        return;
    end
    debug(string.format(
        "Processing script command %s in global.",
        self.ScriptCommandRegister[_ID][1]
    ), true);
    self.ScriptCommandRegister[_ID][2](unpack(Parameters));
end

function Swift.Event:EncodeScriptCommandParameters(...)
    local Query = "";
    for i= 1, #arg do
        local Parameter = arg[i];
        if type(Parameter) == "string" then
            Parameter = string.replaceAll(Parameter, '#', "<<<HT>>>");
            Parameter = string.replaceAll(Parameter, '"', "<<<QT>>>");
            if Parameter:len() == 0 then
                Parameter = "<<<ES>>>";
            end
        -- FIXME This covers only array tables!
        -- (But we shouldn't encourage passing objects anyway!)
        elseif type(Parameter) == "table" then
            Parameter = "{" ..table.concat(Parameter, ",") .."}";
        end
        if string.len(Query) > 0 then
            Query = Query .. "#";
        end
        Query = Query .. tostring(Parameter);
    end
    return Query;
end

function Swift.Event:DecodeScriptCommandParameters(_Query)
    local Parameters = {};
    for k, v in pairs(string.slice(_Query, "#")) do
        local Value = v;
        Value = string.replaceAll(Value, "<<<HT>>>", '#');
        Value = string.replaceAll(Value, "<<<QT>>>", '"');
        Value = string.replaceAll(Value, "<<<ES>>>", '');
        if Value == nil then
            Value = nil;
        elseif Value == "true" or Value == "false" then
            Value = Value == "true";
        elseif string.indexOf(Value, "{") == 1 then
            -- FIXME This covers only array tables!
            -- (But we shouldn't encourage passing objects anyway!)
            local ValueTable = string.slice(string.sub(Value, 2, string.len(Value)-1), ",");
            Value = {};
            for i= 1, #ValueTable do
                Value[i] = (tonumber(ValueTable[i]) ~= nil and tonumber(ValueTable[i]) or ValueTable);
            end
        elseif tonumber(Value) ~= nil then
            Value = tonumber(Value);
        end
        table.insert(Parameters, Value);
    end
    return Parameters;
end

-- Script Events

function Swift.Event:InitalizeEventsGlobal()
    QSB.ScriptEvents.SaveGameLoaded = self:CreateScriptEvent("Event_SaveGameLoaded", nil);
    QSB.ScriptEvents.EscapePressed = self:CreateScriptEvent("Event_EscapePressed", nil);
    QSB.ScriptEvents.QuestFailure = self:CreateScriptEvent("Event_QuestFailure", nil);
    QSB.ScriptEvents.QuestInterrupt = self:CreateScriptEvent("Event_QuestInterrupt", nil);
    QSB.ScriptEvents.QuestReset = self:CreateScriptEvent("Event_QuestReset", nil);
    QSB.ScriptEvents.QuestSuccess = self:CreateScriptEvent("Event_QuestSuccess", nil);
    QSB.ScriptEvents.QuestTrigger = self:CreateScriptEvent("Event_QuestTrigger", nil);
    QSB.ScriptEvents.CustomValueChanged = self:CreateScriptEvent("Event_CustomValueChanged", nil);
    QSB.ScriptEvents.LanguageSet = self:CreateScriptEvent("Event_LanguageSet", nil);
    QSB.ScriptEvents.LoadscreenClosed = self:CreateScriptEvent("Event_LoadscreenClosed", nil);
end
function Swift.Event:InitalizeEventsLocal()
    QSB.ScriptEvents.SaveGameLoaded = self:CreateScriptEvent("Event_SaveGameLoaded", nil);
    QSB.ScriptEvents.EscapePressed = self:CreateScriptEvent("Event_EscapePressed", nil);
    QSB.ScriptEvents.QuestFailure = self:CreateScriptEvent("Event_QuestFailure", nil);
    QSB.ScriptEvents.QuestInterrupt = self:CreateScriptEvent("Event_QuestInterrupt", nil);
    QSB.ScriptEvents.QuestReset = self:CreateScriptEvent("Event_QuestReset", nil);
    QSB.ScriptEvents.QuestSuccess = self:CreateScriptEvent("Event_QuestSuccess", nil);
    QSB.ScriptEvents.QuestTrigger = self:CreateScriptEvent("Event_QuestTrigger", nil);
    QSB.ScriptEvents.CustomValueChanged = self:CreateScriptEvent("Event_CustomValueChanged", nil);
    QSB.ScriptEvents.LanguageSet = self:CreateScriptEvent("Event_LanguageSet", nil);
    QSB.ScriptEvents.LoadscreenClosed = self:CreateScriptEvent("Event_LoadscreenClosed", nil);
end

function Swift.Event:CreateScriptEvent(_Name, _Function)
    for i= 1, #self.ScriptEventRegister, 1 do
        if self.ScriptEventRegister[i][1] == _Name then
            return 0;
        end
    end
    local ID = #self.ScriptEventRegister+1;
    debug(string.format("Create script event %s", _Name), true);
    self.ScriptEventRegister[ID] = {_Name, _Function};
    return ID;
end

function Swift.Event:DispatchScriptEvent(_ID, ...)
    if not self.ScriptEventRegister[_ID] then
        return;
    end
    -- Dispatch module events
    for i= 1, #Swift.ModuleRegister, 1 do
        local Env = "Local";
        if Swift:IsGlobalEnvironment() then
            Env = "Global";
        end
        if Swift.ModuleRegister[i][Env] and Swift.ModuleRegister[i][Env].OnEvent then
            debug(string.format(
                "Dispatching %s script event %s to Module %s",
                Env:lower(),
                self.ScriptEventRegister[_ID][1],
                Swift.ModuleRegister[i].Properties.Name
            ), true);
            Swift.ModuleRegister[i][Env]:OnEvent(_ID, self.ScriptEventRegister[_ID], unpack(arg));
        end
    end
    -- Call event callback
    if GameCallback_QSB_OnEventReceived then
        GameCallback_QSB_OnEventReceived(_ID, unpack(arg));
    end
    -- Call event listeners
    if self.ScriptEventListener[_ID] then
        for k, v in pairs(self.ScriptEventListener[_ID]) do
            if tonumber(k) then
                v(_ID, unpack(arg));
            end
        end
    end
end

function Swift.Event:IsAllowedEventParameter(_Parameter)
    if type(_Parameter) == "function" or type(_Parameter) == "thread" or type(_Parameter) == "userdata" then
        return false;
    elseif type(_Parameter) == "table" then
        for k, v in pairs(_Parameter) do
            if type(k) ~= "number" and k ~= "n" then
                return false;
            end
            if type(v) == "function" or type(v) == "thread" or type(v) == "userdata" then
                return false;
            end
        end
    end
    return true;
end

