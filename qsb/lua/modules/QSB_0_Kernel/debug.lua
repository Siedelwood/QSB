--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Stellt Cheats und Befehle für einfacheres Testen bereit.
--
-- @set sort=true
-- @within Beschreibung
-- @local
--

Revision.Debug = {
    CheckAtRun           = false;
    TraceQuests          = false;
    DevelopingCheats     = false;
    DevelopingShell      = false;
};

function Revision.Debug:Initalize()
    QSB.ScriptEvents.DebugChatConfirmed = Revision.Event:CreateScriptEvent("Event_DebugChatConfirmed");
    QSB.ScriptEvents.DebugConfigChanged = Revision.Event:CreateScriptEvent("Event_DebugConfigChanged");

    if Revision.Environment == QSB.Environment.LOCAL then
        self:InitalizeQsbDebugHotkeys();

        API.AddScriptEventListener(
            QSB.ScriptEvents.ChatClosed,
            function(...)
                Revision.Debug:ProcessDebugInput(unpack(arg));
            end
        );
    end
end

function Revision.Debug:OnSaveGameLoaded()
    if Revision.Environment == QSB.Environment.LOCAL then
        self:InitalizeDebugWidgets();
        self:InitalizeQsbDebugHotkeys();
    end
end

function Revision.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    if Revision.Environment == QSB.Environment.LOCAL then
        return;
    end

    self.CheckAtRun       = _CheckAtRun == true;
    self.TraceQuests      = _TraceQuests == true;
    self.DevelopingCheats = _DevelopingCheats == true;
    self.DevelopingShell  = _DevelopingShell == true;

    Revision.Event:DispatchScriptEvent(
        QSB.ScriptEvents.DebugModeStatusChanged,
        self.CheckAtRun,
        self.TraceQuests,
        self.DevelopingCheats,
        self.DevelopingShell
    );

    Logic.ExecuteInLuaLocalState(string.format(
        [[
            Revision.Debug.CheckAtRun       = %s;
            Revision.Debug.TraceQuests      = %s;
            Revision.Debug.DevelopingCheats = %s;
            Revision.Debug.DevelopingShell  = %s;

            Revision.Event:DispatchScriptEvent(
                QSB.ScriptEvents.DebugModeStatusChanged,
                Revision.Debug.CheckAtRun,
                Revision.Debug.TraceQuests,
                Revision.Debug.DevelopingCheats,
                Revision.Debug.DevelopingShell
            );
            Revision.Debug:InitalizeDebugWidgets();
        ]],
        tostring(self.CheckAtRun),
        tostring(self.TraceQuests),
        tostring(self.DevelopingCheats),
        tostring(self.DevelopingShell)
    ));
end

function Revision.Debug:InitalizeDebugWidgets()
    if Network.IsNATReady ~= nil and Framework.IsNetworkGame() then
        return;
    end
    if self.DevelopingCheats then
        KeyBindings_EnableDebugMode(1);
        KeyBindings_EnableDebugMode(2);
        KeyBindings_EnableDebugMode(3);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
        self.GameClock = true;
    else
        KeyBindings_EnableDebugMode(0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
        self.GameClock = false;
    end
end

function Revision.Debug:InitalizeQsbDebugHotkeys()
    if Framework.IsNetworkGame() then
        return;
    end
    -- Restart map
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.ModifierAlt + Keys.R,
        "Revision.Debug:ProcessDebugShortcut('RestartMap')",
        30,
        false
    );
    -- Open chat
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.OemPipe,
        "Revision.Debug:ProcessDebugShortcut('Terminal')",
        30,
        false
    );
end

function Revision.Debug:ProcessDebugShortcut(_Type, _Params)
    if self.DevelopingCheats then
        if _Type == "RestartMap" then
            Framework.RestartMap();
        elseif _Type == "Terminal" then
            API.ShowTextInput(GUI.GetPlayerID(), true);
        end
    end
end

function Revision.Debug:ProcessDebugInput(_Input, _PlayerID, _DebugAllowed)
    if _DebugAllowed then
        if _Input:lower():find("^restartmap") then
            self:ProcessDebugShortcut("RestartMap");
        elseif _Input:lower():find("^clear") then
            GUI.ClearNotes();
        elseif _Input:lower():find("^version") then
            local Slices = _Input:slice(" ");
            if Slices[2] then
                for i= 1, #Revision.ModuleRegister do
                    if Revision.ModuleRegister[i].Properties.Name ==  Slices[2] then
                        GUI.AddStaticNote("Version: " ..Revision.ModuleRegister[i].Properties.Version);
                    end
                end
                return;
            end
            GUI.AddStaticNote("Version: " ..QSB.Version);
        elseif _Input:find("^> ") then
            GUI.SendScriptCommand(_Input:sub(3), true);
        elseif _Input:find("^>> ") then
            GUI.SendScriptCommand(string.format(
                "Logic.ExecuteInLuaLocalState(\"%s\")",
                _Input:sub(4)
            ), true);
        elseif _Input:find("^< ") then
            GUI.SendScriptCommand(string.format(
                [[Script.Load("%s")]],
                _Input:sub(3)
            ));
        elseif _Input:find("^<< ") then
            Script.Load(_Input:sub(4));
        end
    end
end

-- -------------------------------------------------------------------------- --
-- API

---
-- Aktiviert oder deaktiviert Optionen des Debug Mode.
--
-- <b>Hinweis:</b> Du kannst alle Optionen unbegrenzt oft beliebig ein-
-- und ausschalten.
--
-- <ul>
-- <li><u>Prüfung zum Spielbeginn</u>: <br>
-- Quests werden auf konsistenz geprüft, bevor sie starten. </li>
-- <li><u>Questverfolgung</u>: <br>
-- Jede Statusänderung an einem Quest löst eine Nachricht auf dem Bildschirm
-- aus, die die Änderung wiedergibt. </li>
-- <li><u>Eintwickler Cheaks</u>: <br>
-- Aktivier die Entwickler Cheats. </li>
-- <li><u>Debug Chat-Eingabe</u>: <br>
-- Die Chat-Eingabe kann zur Eingabe von Befehlen genutzt werden. </li>
-- </ul>
--
-- @param[type=boolean] _CheckAtRun       Custom Behavior prüfen an/aus
-- @param[type=boolean] _TraceQuests      Quest Trace an/aus
-- @param[type=boolean] _DevelopingCheats Cheats an/aus
-- @param[type=boolean] _DevelopingShell  Eingabeaufforderung an/aus
-- @within System
--
function API.ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    Revision.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell);
end

