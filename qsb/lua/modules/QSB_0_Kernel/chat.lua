--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Steuerung des Chat als Eingabefenster.
-- @set sort=true
-- @local
--

Swift.Chat = {
    DebugInput = {};
};

function Swift.Chat:Initalize()
    QSB.ScriptEvents.ChatOpened = Swift.Event:CreateScriptEvent("Event_ChatOpened");
    QSB.ScriptEvents.ChatClosed = Swift.Event:CreateScriptEvent("Event_ChatClosed");
    for i= 1, 8 do
        self.DebugInput[i] = {};
    end
end

function Swift.Chat:OnSaveGameLoaded()
end

function Swift.Chat:ShowTextInput(_PlayerID, _AllowDebug)
    if  Swift.GameVersion == QSB.GameVersion.HISTORY_EDITION
    and Framework.IsNetworkGame() then
        return;
    end
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.Chat:ShowTextInput(%d, %s)]],
            _PlayerID,
            tostring(_AllowDebug == true)
        ))
        return;
    end
    _PlayerID = _PlayerID or GUI.GetPlayerID();
    self:PrepareInputVariable(_PlayerID);
    self:ShowInputBox(_PlayerID, _AllowDebug == true);
end

function Swift.Chat:ShowInputBox(_PlayerID, _Debug)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.DebugInput[_PlayerID] = _Debug == true;

    Swift.Job:CreateEventJob(
        Events.LOGIC_EVENT_EVERY_TURN,
        function()
            -- Open chat
            Input.ChatMode();
            XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
            XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
            XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");
            -- Send event to global script
            Swift.Event:DispatchScriptCommand(
                QSB.ScriptCommands.SendScriptEvent,
                GUI.GetPlayerID(),
                "ChatOpened",
                _PlayerID
            );
            -- Send event to local script
            Swift.Event:DispatchScriptEvent(
                QSB.ScriptEvents.ChatOpened,
                _PlayerID
            );
            -- Slow down game time. We can not set the game time to 0 because
            -- then Logic.ExecuteInLuaLocalState and GUI.SendScriptCommand do
            -- not work anymore.
            if not Framework.IsNetworkGame() then
                Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
            end
            return true;
        end
    )
end

function Swift.Chat:PrepareInputVariable(_PlayerID)
    if Swift.Environment == QSB.Environment.GLOBAL then
        return;
    end

    GUI_Chat.Abort_Orig_Swift = GUI_Chat.Abort_Orig_Swift or GUI_Chat.Abort;
    GUI_Chat.Confirm_Orig_Swift = GUI_Chat.Confirm_Orig_Swift or GUI_Chat.Confirm;

    GUI_Chat.Confirm = function()
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 0);
        local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        local IsDebug = Swift.Chat.DebugInput[_PlayerID];
        Swift.ChatBoxInput = ChatMessage;
        Swift.Chat:SendInputToGlobalScript(ChatMessage, IsDebug);
        g_Chat.JustClosed = 1;
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(_PlayerID, 1);
        end
        Input.GameMode();
        if  ChatMessage:len() > 0
        and Framework.IsNetworkGame()
        and not IsDebug then
            GUI.SendChatMessage(
                ChatMessage,
                _PlayerID,
                g_Chat.CurrentMessageType,
                g_Chat.CurrentWhisperTarget
            );
        end
    end

    if not Framework.IsNetworkGame() then
        GUI_Chat.Abort = function()
        end
    end
end

function Swift.Chat:SendInputToGlobalScript(_Text, _Debug)
    _Text = (_Text == nil and "") or _Text;
    local PlayerID = GUI.GetPlayerID();
    -- Send chat input to global script
    Swift.Event:DispatchScriptCommand(
        QSB.ScriptCommands.SendScriptEvent,
        0,
        "ChatClosed",
        (_Text or "<<<ES>>>"),
        GUI.GetPlayerID(),
        _Debug == true
    );
    -- Send chat input to local script
    Swift.Event:DispatchScriptEvent(
        QSB.ScriptEvents.ChatClosed,
        (_Text or "<<<ES>>>"),
        GUI.GetPlayerID(),
        _Debug == true
    );
    -- Reset debug flag
    self.DebugInput[PlayerID] = false;
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Offnet das Chatfenster für eine Eingabe.
--
-- <b>Hinweis</b>: Im Multiplayer kann der Chat nicht über Skript gesteuert
-- werden.
-- 
-- @param[type=number]  _PlayerID   Spieler für den der Chat geöffnet wird
-- @param[type=boolean] _AllowDebug Debug Eingaben werden bearbeitet
-- @within System
--
function API.ShowTextInput(_PlayerID, _AllowDebug)
    Swift.Chat:ShowTextInput(_PlayerID, _AllowDebug);
end

