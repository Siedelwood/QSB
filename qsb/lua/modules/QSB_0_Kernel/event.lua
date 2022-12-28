--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Kommunikation von Komponenten über Events aus dem Skript.
--
-- @set sort=true
-- @local
--

Swift.Event = {
    ScriptEventRegister   = {};
    ScriptEventListener   = {};
    ScriptCommandRegister = {};
};

QSB.ScriptCommandSequence = 2;
QSB.ScriptCommands = {};
QSB.ScriptEvents = {};

function Swift.Event:Initalize()
    self:OverrideSoldierPayment();
    if Swift.Environment == QSB.Environment.GLOBAL then
        self:CreateScriptCommand("Cmd_SendScriptEvent", function(_Event, ...)
            assert(QSB.ScriptEvents[_Event] ~= nil);
            API.SendScriptEvent(QSB.ScriptEvents[_Event], unpack(arg));
        end);
    end
end

function Swift.Event:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Script Commands

function Swift.Event:OverrideSoldierPayment()
    GameCallback_SetSoldierPaymentLevel_Orig_Swift = GameCallback_SetSoldierPaymentLevel;
    GameCallback_SetSoldierPaymentLevel = function(_PlayerID, _Level)
        if _Level <= 2 then
            return GameCallback_SetSoldierPaymentLevel_Orig_Swift(_PlayerID, _Level);
        end
        Swift.Event:ProcessScriptCommand(_PlayerID, _Level);
    end
end

function Swift.Event:CreateScriptCommand(_Name, _Function)
    if Swift.Environment == QSB.Environment.LOCAL then
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
    if Swift.Environment == QSB.Environment.GLOBAL then
        return;
    end
    assert(_ID ~= nil);
    if self.ScriptCommandRegister[_ID] then
        local PlayerID = GUI.GetPlayerID();
        local NamePlayerID = PlayerID +4;
        local PlayerName = Logic.GetPlayerName(NamePlayerID);
        local Parameters = self:EncodeScriptCommandParameters(unpack(arg));

        if Framework.IsNetworkGame() and Swift.GameVersion == QSB.GameVersion.HISTORY_EDITION then
            GUI.SetPlayerName(NamePlayerID, Parameters);
            GUI.SetSoldierPaymentLevel(_ID);
        else
            GUI.SendScriptCommand(string.format(
                [[Swift.Event:ProcessScriptCommand(%d, %d, "%s")]],
                arg[1],
                _ID,
                Parameters
            ));
        end
        debug(string.format(
            "Dispatching script command %s to global.",
            self.ScriptCommandRegister[_ID]
        ), true);

        if Framework.IsNetworkGame() and Swift.GameVersion == QSB.GameVersion.HISTORY_EDITION then
            GUI.SetPlayerName(NamePlayerID, PlayerName);
            GUI.SetSoldierPaymentLevel(PlayerSoldierPaymentLevel[PlayerID]);
        end
    end
end

function Swift.Event:ProcessScriptCommand(_PlayerID, _ID, _ParameterString)
    if not self.ScriptCommandRegister[_ID] then
        return;
    end
    local PlayerName = _ParameterString;
    if Framework.IsNetworkGame() and Swift.GameVersion == QSB.GameVersion.HISTORY_EDITION then
        PlayerName = Logic.GetPlayerName(_PlayerID +4);
    end
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
            Parameter = string.gsub(Parameter, '#', "<<<HT>>>");
            Parameter = string.gsub(Parameter, '"', "<<<QT>>>");
            if Parameter:len() == 0 then
                Parameter = "<<<ES>>>";
            end
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

-- -------------------------------------------------------------------------- --
-- Script Events

function Swift.Event:CreateScriptEvent(_Name)
    for i= 1, #self.ScriptEventRegister, 1 do
        if self.ScriptEventRegister[i] == _Name then
            return 0;
        end
    end
    local ID = #self.ScriptEventRegister+1;
    debug(string.format("Create script event %s", _Name), true);
    self.ScriptEventRegister[ID] = _Name;
    return ID;
end

function Swift.Event:DispatchScriptEvent(_ID, ...)
    if not self.ScriptEventRegister[_ID] then
        return;
    end
    -- Dispatch module events
    for i= 1, #Swift.ModuleRegister, 1 do
        local Env = (Swift.Environment == QSB.Environment.GLOBAL and "Global") or "Local";
        if Swift.ModuleRegister[i][Env] and Swift.ModuleRegister[i][Env].OnEvent then
            Swift.ModuleRegister[i][Env]:OnEvent(_ID, unpack(arg));
        end
    end
    -- Call event game callback
    if GameCallback_QSB_OnEventReceived then
        GameCallback_QSB_OnEventReceived(_ID, unpack(arg));
    end
    -- Call event listeners
    if self.ScriptEventListener[_ID] then
        for k, v in pairs(self.ScriptEventListener[_ID]) do
            if tonumber(k) then
                v(unpack(arg));
            end
        end
    end
end

-- -------------------------------------------------------------------------- --
-- API

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

---
-- Legt ein neues Script Event an.
--
-- @param[type=string]   _Name     Identifier des Event
-- @return[type=number] ID des neuen Script Event
-- @within Event
-- @local
--
-- @usage
-- local EventID = API.RegisterScriptEvent("MyNewEvent");
--
function API.RegisterScriptEvent(_Name)
    return Swift.Event:CreateScriptEvent(_Name);
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
-- @local
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
-- @param[type=number] _EventName Name des Event
-- @param              ... Optionale Parameter (nil, string, number, boolean, (array) table)
-- @within Event
-- @local
--
-- @usage
-- API.SendScriptEventToGlobal("SomeEventName", Param1, Param2, ...);
--
function API.BroadcastScriptEventToGlobal(_EventName, ...)
    if not GUI then
        return;
    end
    Swift.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        0,
        _EventName,
        unpack(arg)
    );
end

---
-- Triggerd ein Script Event im globalen Skript aus dem lokalen Skript.
--
-- Das Event wird asynchron für den kontrollierenden Spieler gesendet.
--
-- @param[type=number] _EventName Name des Event
-- @param              ... Optionale Parameter (nil, string, number, boolean, (array) table)
-- @within Event
-- @local
--
-- @usage
-- API.SendScriptEventToGlobal("SomeEventName", Param1, Param2, ...);
--
function API.SendScriptEventToGlobal(_EventName, ...)
    if not GUI then
        return;
    end
    Swift.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        GUI.GetPlayerID(),
        _EventName,
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
-- @see API.RemoveScriptEventListener
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
-- @see API.AddScriptEventListener
--
function API.RemoveScriptEventListener(_EventID, _ID)
    if Swift.Event.ScriptEventListener[_EventID] then
        Swift.Event.ScriptEventListener[_EventID][_ID] = nil;
    end
end

