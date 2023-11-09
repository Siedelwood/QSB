-- -------------------------------------------------------------------------- --

--
-- Stellt Cheats und Befehle für einfacheres Testen bereit.
--
-- @set sort=true
-- @within Beschreibung
-- @local
--

Swift.Debug = {
    CheckAtRun           = false;
    TraceQuests          = false;
    DevelopingCheats     = false;
    DevelopingShell      = false;
};

function Swift.Debug:Initalize()
    QSB.ScriptEvents.DebugChatConfirmed = Swift.Event:CreateScriptEvent("Event_DebugChatConfirmed");
    QSB.ScriptEvents.DebugConfigChanged = Swift.Event:CreateScriptEvent("Event_DebugConfigChanged");

    if Swift.Environment == QSB.Environment.LOCAL then
        self:InitalizeQsbDebugHotkeys();

        API.AddScriptEventListener(
            QSB.ScriptEvents.ChatClosed,
            function(...)
                Swift.Debug:ProcessDebugInput(unpack(arg));
            end
        );
    end
end

function Swift.Debug:OnSaveGameLoaded()
    if Swift.Environment == QSB.Environment.LOCAL then
        self:InitalizeDebugWidgets();
        self:InitalizeQsbDebugHotkeys();
    end
end

function Swift.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    if Swift.Environment == QSB.Environment.LOCAL then
        return;
    end

    self.CheckAtRun       = _CheckAtRun == true;
    self.TraceQuests      = _TraceQuests == true;
    self.DevelopingCheats = _DevelopingCheats == true;
    self.DevelopingShell  = _DevelopingShell == true;

    Swift.Event:DispatchScriptEvent(
        QSB.ScriptEvents.DebugModeStatusChanged,
        self.CheckAtRun,
        self.TraceQuests,
        self.DevelopingCheats,
        self.DevelopingShell
    );

    Logic.ExecuteInLuaLocalState(string.format(
        [[
            Swift.Debug.CheckAtRun       = %s;
            Swift.Debug.TraceQuests      = %s;
            Swift.Debug.DevelopingCheats = %s;
            Swift.Debug.DevelopingShell  = %s;

            Swift.Event:DispatchScriptEvent(
                QSB.ScriptEvents.DebugModeStatusChanged,
                Swift.Debug.CheckAtRun,
                Swift.Debug.TraceQuests,
                Swift.Debug.DevelopingCheats,
                Swift.Debug.DevelopingShell
            );
            Swift.Debug:InitalizeDebugWidgets();
        ]],
        tostring(self.CheckAtRun),
        tostring(self.TraceQuests),
        tostring(self.DevelopingCheats),
        tostring(self.DevelopingShell)
    ));
end

function Swift.Debug:InitalizeDebugWidgets()
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

function Swift.Debug:InitalizeQsbDebugHotkeys()
    if Framework.IsNetworkGame() then
        return;
    end
    -- Restart map
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.ModifierShift + Keys.ModifierAlt + Keys.R,
        "Swift.Debug:ProcessDebugShortcut('RestartMap')",
        30,
        false
    );
    -- Open chat
    Input.KeyBindDown(
        Keys.ModifierShift + Keys.OemPipe,
        "Swift.Debug:ProcessDebugShortcut('Terminal')",
        30,
        false
    );
end

function Swift.Debug:ProcessDebugShortcut(_Type, _Params)
    if self.DevelopingCheats then
        if _Type == "RestartMap" then
            Framework.RestartMap();
        elseif _Type == "Terminal" then
            API.ShowTextInput(GUI.GetPlayerID(), true);
        end
    end
end

function Swift.Debug:ProcessDebugInput(_Input, _PlayerID, _DebugAllowed)
    if _DebugAllowed then
        if _Input:lower():find("^restartmap") then
            self:ProcessDebugShortcut("RestartMap");
        elseif _Input:lower():find("^clear") then
            GUI.ClearNotes();
        elseif _Input:lower():find("^version") then
            local Slices = _Input:slice(" ");
            if Slices[2] then
                for i= 1, #Swift.ModuleRegister do
                    if Swift.ModuleRegister[i].Properties.Name ==  Slices[2] then
                        GUI.AddStaticNote("Version: " ..Swift.ModuleRegister[i].Properties.Version);
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
    Swift.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell);
end

-- Aktiviert DisplayScriptErrors, auch wenn der Benutzer das Spiel nicht
-- mit dem Kommandozeilenparameter gestartet hat.
-- @param[type=boolean] _active An/Aus.

function API.ToggleDisplayScriptErrors(_active)
    if Swift.Environment == QSB.Environment.LOCAL then
		g_DisplayScriptErrors = _active
		GUI.SendScriptCommand([[g_DisplayScriptErrors = ]]..tostring(_active)..[[]])
		return;
    end

	g_DisplayScriptErrors = _active
	Logic.ExecuteInLuaLocalState([[g_DisplayScriptErrors = ]]..tostring(_active)..[[]])
end
-- #EOF
