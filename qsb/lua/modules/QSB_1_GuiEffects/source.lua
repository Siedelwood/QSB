-- -------------------------------------------------------------------------- --

ModuleGuiEffects = {
    Properties = {
        Name = "ModuleGuiEffects",
        Version = "3.0.0 (BETA 2.0.0)"
    },

    Global = {
        CinematicEventID = 0,
        CinematicEventStatus = {},
        CinematicEventQueue = {},
        TypewriterEventData = {},
        TypewriterEventCounter = 0,
    },
    Local = {
        CinematicEventStatus = {},
        ChatOptionsWasShown = false,
        MessageLogWasShown = false,
        PauseScreenShown = false,
        NormalModeHidden = false,
        BorderScrollDeactivated = false,
    },

    Shared = {};
}

QSB.FarClipDefault = {
    -- Default: 0
    -- Setting this to 0 when the max default is not also set to 0 results in
    -- nothing being rendered at all.
    MIN = 45000,
    -- Default: 1000000
    -- Using the default is way to much render distance and will cause the
    -- game to stutter when in cutscene mode.
    MAX = 45000
};
QSB.CinematicEvent = {};
QSB.CinematicEventTypes = {};

-- Global ------------------------------------------------------------------- --

function ModuleGuiEffects.Global:OnGameStart()
    QSB.ScriptEvents.BuildingPlaced = API.RegisterScriptEvent("Event_BuildingPlaced");
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.ImageScreenShown = API.RegisterScriptEvent("Event_ImageScreenShown");
    QSB.ScriptEvents.ImageScreenHidden = API.RegisterScriptEvent("Event_ImageScreenHidden");
    QSB.ScriptEvents.TypewriterStarted = API.RegisterScriptEvent("Event_TypewriterStarted");
    QSB.ScriptEvents.TypewriterEnded = API.RegisterScriptEvent("Event_TypewriterEnded");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
        self.CinematicEventQueue[i] = {};
    end
    API.StartHiResJob(function()
        ModuleGuiEffects.Global:ControlTypewriter();
    end);
end

function ModuleGuiEffects.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.CinematicActivated then
        -- Save cinematic state
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
        -- deactivate black background
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(%d)",
            arg[2]
        ));
        -- activate GUI
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceActivateNormalInterface(%d)",
            arg[2]
        ));
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        -- Save cinematic state
        if self.CinematicEventStatus[arg[2]][arg[1]] then
            self.CinematicEventStatus[arg[2]][arg[1]] = 2;
        end
        if #self.CinematicEventQueue[arg[2]] > 0 then
            -- activate black background
            Logic.ExecuteInLuaLocalState(string.format(
                [[ModuleGuiEffects.Local:InterfaceActivateImageBackground(%d, "", 0, 0, 0, 255)]],
                arg[2]
            ));
            -- deactivate GUI
            Logic.ExecuteInLuaLocalState(string.format(
                "ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(%d)",
                arg[2]
            ));
        end
    end
end

function ModuleGuiEffects.Global:PushCinematicEventToQueue(_PlayerID, _Type, _Name, _Data)
    table.insert(self.CinematicEventQueue[_PlayerID], {_Type, _Name, _Data});
end

function ModuleGuiEffects.Global:LookUpCinematicInQueue(_PlayerID)
    if #self.CinematicEventQueue[_PlayerID] > 0 then
        return self.CinematicEventQueue[_PlayerID][1];
    end
end

function ModuleGuiEffects.Global:PopCinematicEventFromQueue(_PlayerID)
    if #self.CinematicEventQueue[_PlayerID] > 0 then
        return table.remove(self.CinematicEventQueue[_PlayerID], 1);
    end
end

function ModuleGuiEffects.Global:GetNewCinematicEventID()
    self.CinematicEventID = self.CinematicEventID +1;
    return self.CinematicEventID;
end

function ModuleGuiEffects.Global:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleGuiEffects.Global:ActivateCinematicEvent(_PlayerID)
    local ID = self:GetNewCinematicEventID();
    API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, ID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, %d, %d);
          if GUI.GetPlayerID() == %d then
            ModuleGuiEffects.Local.SavingWasDisabled = Swift.Save.SavingDisabled == true;
            API.DisableSaving(true);
          end]],
        ID,
        _PlayerID,
        _PlayerID
    ))
    return ID;
end

function ModuleGuiEffects.Global:ConcludeCinematicEvent(_ID, _PlayerID)
    API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, _ID, _PlayerID);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, %d, %d);
          if GUI.GetPlayerID() == %d then
            if not ModuleGuiEffects.Local.SavingWasDisabled then
                API.DisableSaving(false);
            end
            ModuleGuiEffects.Local.SavingWasDisabled = false;
          end]],
        _ID,
        _PlayerID,
        _PlayerID
    ))
end

-- Local -------------------------------------------------------------------- --

function ModuleGuiEffects.Local:OnGameStart()
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset  = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.ImageScreenShown = API.RegisterScriptEvent("Event_ImageScreenShown");
    QSB.ScriptEvents.ImageScreenHidden = API.RegisterScriptEvent("Event_ImageScreenHidden");
    QSB.ScriptEvents.TypewriterStarted = API.RegisterScriptEvent("Event_TypewriterStarted");
    QSB.ScriptEvents.TypewriterEnded = API.RegisterScriptEvent("Event_TypewriterEnded");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
    end
    self:OverrideInterfaceUpdateForCinematicMode();
    self:OverrideInterfaceThroneroomForCinematicMode();
    self:ResetFarClipPlane();
end

function ModuleGuiEffects.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.CinematicActivated then
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        for i= 1, 8 do
            if self.CinematicEventStatus[i][arg[1]] then
                self.CinematicEventStatus[i][arg[1]] = 2;
            end
        end
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:ResetFarClipPlane();
    end
end

-- -------------------------------------------------------------------------- --

function ModuleGuiEffects.Global:StartTypewriter(_Data)
    self.TypewriterEventCounter = self.TypewriterEventCounter +1;
    local EventName = "CinematicEvent_Typewriter" ..self.TypewriterEventCounter;
    _Data.Name = EventName;
    if not self.LoadscreenClosed or API.IsCinematicEventActive(_Data.PlayerID) then
        ModuleGuiEffects.Global:PushCinematicEventToQueue(
            _Data.PlayerID,
            QSB.CinematicEventTypes.Typewriter,
            EventName,
            _Data
        );
        return _Data.Name;
    end
    return self:PlayTypewriter(_Data);
end

function ModuleGuiEffects.Global:PlayTypewriter(_Data)
    local ID = API.StartCinematicEvent(_Data.Name, _Data.PlayerID);
    _Data.ID = ID;
    _Data.TextTokens = self:TokenizeText(_Data);
    self.TypewriterEventData[_Data.PlayerID] = _Data;
    Logic.ExecuteInLuaLocalState(string.format(
        [[
        if GUI.GetPlayerID() == %d then
            API.ActivateImageScreen(GUI.GetPlayerID(), "%s", %d, %d, %d, %d)
            API.DeactivateNormalInterface(GUI.GetPlayerID())
            API.DeactivateBorderScroll(GUI.GetPlayerID(), %d)
            Input.CutsceneMode()
            GUI.ClearNotes()
        end
        ]],
        _Data.PlayerID,
        _Data.Image,
        _Data.Color.R or 0,
        _Data.Color.G or 0,
        _Data.Color.B or 0,
        _Data.Color.A or 255,
        _Data.TargetEntity
    ));

    API.SendScriptEvent(QSB.ScriptEvents.TypewriterStarted, _Data.PlayerID, _Data);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.TypewriterStarted, %d, %s)]],
        _Data.PlayerID,
        table.tostring(_Data)
    ));
    return _Data.Name;
end

function ModuleGuiEffects.Global:FinishTypewriter(_PlayerID)
    if self.TypewriterEventData[_PlayerID] then
        local EventData = table.copy(self.TypewriterEventData[_PlayerID]);
        local EventPlayer = self.TypewriterEventData[_PlayerID].PlayerID;
        Logic.ExecuteInLuaLocalState(string.format(
            [[
            if GUI.GetPlayerID() == %d then
                ModuleGuiEffects.Local:ResetFarClipPlane()
                API.DeactivateImageScreen(GUI.GetPlayerID())
                API.ActivateNormalInterface(GUI.GetPlayerID())
                API.ActivateBorderScroll(GUI.GetPlayerID())
                if ModuleGuiControl then
                    ModuleGuiControl.Local:UpdateHiddenWidgets()
                end
                Input.GameMode()
                GUI.ClearNotes()
            end
            ]],
            _PlayerID
        ));
        API.SendScriptEvent(QSB.ScriptEvents.TypewriterEnded, EventPlayer, EventData);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.TypewriterEnded, %d, %s)]],
            EventPlayer,
            table.tostring(EventData)
        ));
        self.TypewriterEventData[_PlayerID]:Callback();
        API.FinishCinematicEvent(EventData.Name, EventPlayer);
        self.TypewriterEventData[_PlayerID] = nil;
    end
end

function ModuleGuiEffects.Global:TokenizeText(_Data)
    local TextTokens = {};
    local TempTokens = {};
    local Text = API.ConvertPlaceholders(_Data.Text);
    Text = Text:gsub("%s+", " ");
    while (true) do
        local s1, e1 = Text:find("{");
        local s2, e2 = Text:find("}");
        if not s1 or not s2 then
            table.insert(TempTokens, Text);
            break;
        end
        if s1 > 1 then
            table.insert(TempTokens, Text:sub(1, s1 -1));
        end
        table.insert(TempTokens, Text:sub(s1, e2));
        Text = Text:sub(e2 +1);
    end

    local LastWasPlaceholder = false;
    for i= 1, #TempTokens, 1 do
        if TempTokens[i]:find("{") then
            local Index = #TextTokens;
            if LastWasPlaceholder then
                TextTokens[Index] = TextTokens[Index] .. TempTokens[i];
            else
                table.insert(TextTokens, Index+1, TempTokens[i]);
            end
            LastWasPlaceholder = true;
        else
            local Index = 1;
            while (Index <= #TempTokens[i]) do
                if string.byte(TempTokens[i]:sub(Index, Index)) == 195 then
                    table.insert(TextTokens, TempTokens[i]:sub(Index, Index+1));
                    Index = Index +1;
                else
                    table.insert(TextTokens, TempTokens[i]:sub(Index, Index));
                end
                Index = Index +1;
            end
            LastWasPlaceholder = false;
        end
    end
    return TextTokens;
end

function ModuleGuiEffects.Global:ControlTypewriter()
    -- Check queue for next event
    for i= 1, 8 do
        if self.LoadscreenClosed and not API.IsCinematicEventActive(i) then
            local Next = ModuleGuiEffects.Global:LookUpCinematicInQueue(i);
            if Next and Next[1] == QSB.CinematicEventTypes.Typewriter then
                local Data = ModuleGuiEffects.Global:PopCinematicEventFromQueue(i);
                self:PlayTypewriter(Data[3]);
            end
        end
    end

    -- Perform active events
    for k, v in pairs(self.TypewriterEventData) do
        if self.TypewriterEventData[k].Delay > 0 then
            self.TypewriterEventData[k].Delay = self.TypewriterEventData[k].Delay -1;
            -- Just my paranoia...
            Logic.ExecuteInLuaLocalState(string.format(
                [[if GUI.GetPlayerID() == %d then GUI.ClearNotes() end]],
                self.TypewriterEventData[k].PlayerID
            ));
        end
        if self.TypewriterEventData[k].Delay == 0 then
            self.TypewriterEventData[k].Index = v.Index + v.CharSpeed;
            if v.Index > #self.TypewriterEventData[k].TextTokens then
                self.TypewriterEventData[k].Index = #self.TypewriterEventData[k].TextTokens;
            end
            local Index = math.floor(v.Index + 0.5);
            local Text = "";
            for i= 1, Index, 1 do
                Text = Text .. self.TypewriterEventData[k].TextTokens[i];
            end
            Logic.ExecuteInLuaLocalState(string.format(
                [[
                if GUI.GetPlayerID() == %d then
                    GUI.ClearNotes()
                    GUI.AddNote("]] ..Text.. [[");
                end
                ]],
                self.TypewriterEventData[k].PlayerID
            ));
            if Index == #self.TypewriterEventData[k].TextTokens then
                self.TypewriterEventData[k].Waittime = v.Waittime -1;
                if v.Waittime <= 0 then
                    self:FinishTypewriter(k);
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------- --

function ModuleGuiEffects.Local:SetFarClipPlane(_View)
    Camera.Cutscene_SetFarClipPlane(_View, _View);
    Display.SetFarClipPlaneMinAndMax(_View, _View);
end

function ModuleGuiEffects.Local:ResetFarClipPlane()
    Camera.Cutscene_SetFarClipPlane(QSB.FarClipDefault.MAX);
    Display.SetFarClipPlaneMinAndMax(
        QSB.FarClipDefault.MIN,
        QSB.FarClipDefault.MAX
    );
end

function ModuleGuiEffects.Local:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleGuiEffects.Local:OverrideInterfaceUpdateForCinematicMode()
    GameCallback_GameSpeedChanged_Orig_ModuleGuiEffectsInterface = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function(_Speed)
        if not ModuleGuiEffects.Local.PauseScreenShown then
            GameCallback_GameSpeedChanged_Orig_ModuleGuiEffectsInterface(_Speed);
        end
    end

    MissionTimerUpdate_Orig_ModuleGuiEffectsInterface = MissionTimerUpdate;
    MissionTimerUpdate = function()
        MissionTimerUpdate_Orig_ModuleGuiEffectsInterface();
        if ModuleGuiEffects.Local.NormalModeHidden
        or ModuleGuiEffects.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
        end
    end

    MissionGoodOrEntityCounterUpdate_Orig_ModuleGuiEffectsInterface = MissionGoodOrEntityCounterUpdate;
    MissionGoodOrEntityCounterUpdate = function()
        MissionGoodOrEntityCounterUpdate_Orig_ModuleGuiEffectsInterface();
        if ModuleGuiEffects.Local.NormalModeHidden
        or ModuleGuiEffects.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
        end
    end

    MerchantButtonsUpdater_Orig_ModuleGuiEffectsInterface = GUI_Merchant.ButtonsUpdater;
    GUI_Merchant.ButtonsUpdater = function()
        MerchantButtonsUpdater_Orig_ModuleGuiEffectsInterface();
        if ModuleGuiEffects.Local.NormalModeHidden
        or ModuleGuiEffects.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
        end
    end

    if GUI_Tradepost then
        TradepostButtonsUpdater_Orig_ModuleGuiEffectsInterface = GUI_Tradepost.ButtonsUpdater;
        GUI_Tradepost.ButtonsUpdater = function()
            TradepostButtonsUpdater_Orig_ModuleGuiEffectsInterface();
            if ModuleGuiEffects.Local.NormalModeHidden
            or ModuleGuiEffects.Local.PauseScreenShown then
                XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
            end
        end
    end
end

function ModuleGuiEffects.Local:OverrideInterfaceThroneroomForCinematicMode()
    GameCallback_Camera_StartButtonPressed = function(_PlayerID)
    end
    OnStartButtonPressed = function()
        GameCallback_Camera_StartButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_BackButtonPressed = function(_PlayerID)
    end
    OnBackButtonPressed = function()
        GameCallback_Camera_BackButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_SkipButtonPressed = function(_PlayerID)
    end
    OnSkipButtonPressed = function()
        GameCallback_Camera_SkipButtonPressed(GUI.GetPlayerID());
    end

    GameCallback_Camera_ThroneRoomLeftClick = function(_PlayerID)
    end
    ThroneRoomLeftClick = function()
        GameCallback_Camera_ThroneRoomLeftClick(GUI.GetPlayerID());
    end

    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
    end
    ThroneRoomCameraControl = function()
        GameCallback_Camera_ThroneroomCameraControl(GUI.GetPlayerID());
    end
end

function ModuleGuiEffects.Local:InterfaceActivateImageBackground(_PlayerID, _Graphic, _R, _G, _B, _A)
    if _PlayerID ~= GUI.GetPlayerID() or self.PauseScreenShown then
        return;
    end
    self.PauseScreenShown = true;

    XGUIEng.PushPage("/InGame/Root/Normal/PauseScreen", false);
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    if _Graphic and _Graphic ~= "" then
        local Size = {GUI.GetScreenSize()};
        local u0, v0, u1, v1 = 0, 0, 1, 1;
        if Size[1]/Size[2] < 1.6 then
            u0 = u0 + (u0 / 0.125);
            u1 = u1 - (u1 * 0.125);
        end
        XGUIEng.SetMaterialTexture("/InGame/Root/Normal/PauseScreen", 0, _Graphic);
        XGUIEng.SetMaterialUV("/InGame/Root/Normal/PauseScreen", 0, u0, v0, u1, v1);
    end
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, _R, _G, _B, _A);
    API.SendScriptEventToGlobal("ImageScreenShown", _PlayerID);
    API.SendScriptEvent(QSB.ScriptEvents.ImageScreenShown, _PlayerID);
end

function ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(_PlayerID)
    if _PlayerID ~= GUI.GetPlayerID() or not self.PauseScreenShown then
        return;
    end
    self.PauseScreenShown = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
    XGUIEng.SetMaterialTexture("/InGame/Root/Normal/PauseScreen", 0, "");
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 40, 40, 40, 180);
    XGUIEng.PopPage();
    API.SendScriptEventToGlobal("ImageScreenHidden", _PlayerID);
    API.SendScriptEvent(QSB.ScriptEvents.ImageScreenHidden, _PlayerID);
end

function ModuleGuiEffects.Local:InterfaceDeactivateBorderScroll(_PlayerID, _PositionID)
    if _PlayerID ~= GUI.GetPlayerID() or self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = true;
    if _PositionID then
        Camera.RTS_FollowEntity(_PositionID);
    end
    Camera.RTS_SetBorderScrollSize(0);
    Camera.RTS_SetZoomWheelSpeed(0);

    API.SendScriptEventToGlobal("BorderScrollLocked", _PlayerID, (_PositionID or 0));
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollLocked, _PlayerID, _PositionID);
end

function ModuleGuiEffects.Local:InterfaceActivateBorderScroll(_PlayerID)
    if _PlayerID ~= GUI.GetPlayerID() or not self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = false;
    Camera.RTS_FollowEntity(0);
    Camera.RTS_SetBorderScrollSize(3.0);
    Camera.RTS_SetZoomWheelSpeed(4.2);

    API.SendScriptEventToGlobal("BorderScrollReset", _PlayerID);
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollReset, _PlayerID);
end

function ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID or self.NormalModeHidden then
        return;
    end
    self.NormalModeHidden = true;

    XGUIEng.PushPage("/InGame/Root/Normal/NotesWindow", false);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/TextMessages", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
    HideOtherMenus();
    if XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignTopLeft/GameClock") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 0);
        self.GameClockWasShown = true;
    end
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/ChatOptions/Background") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 0);
        self.ChatOptionsWasShown = true;
    end
    if XGUIEng.IsWidgetShownEx("/InGame/Root/Normal/MessageLog/Name") == 1 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 0);
        self.MessageLogWasShown = true;
    end
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
    end

    API.SendScriptEventToGlobal("GameInterfaceHidden", GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceHidden, GUI.GetPlayerID());
end

function ModuleGuiEffects.Local:InterfaceActivateNormalInterface(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID or not self.NormalModeHidden then
        return;
    end
    self.NormalModeHidden = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal", 1);
    XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopRight", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/TopBar/UpdateFunction", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/Buttons", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestLogButton", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/QuestTimers", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message", 1);
    XGUIEng.PopPage();

    -- Timer
    if g_MissionTimerEndTime then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 1);
    end
    -- Counter
    if g_MissionGoodOrEntityCounterAmountToReach then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 1);
    end
    -- Debug Clock
    if self.GameClockWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock", 1);
        self.GameClockWasShown = false;
    end
    -- Chat Options
    if self.ChatOptionsWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions", 1);
        self.ChatOptionsWasShown = false;
    end
    -- Message Log
    if self.MessageLogWasShown then
        XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog", 1);
        self.MessageLogWasShown = false;
    end
    -- Handelsposten
    if g_GameExtraNo > 0 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 1);
    end

    API.SendScriptEventToGlobal("GameInterfaceShown", GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceShown, GUI.GetPlayerID());
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleGuiEffects);

