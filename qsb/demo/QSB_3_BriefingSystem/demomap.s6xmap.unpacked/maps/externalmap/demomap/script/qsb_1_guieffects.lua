--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleGuiEffects = {
    Properties = {
        Name = "ModuleGuiEffects",
        Version = "4.0.0 (ALPHA 1.0.0)"
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
    self:ShowInitialBlackscreen();
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
            ModuleGuiEffects.Local.SavingWasDisabled = Revision.Save.SavingDisabled == true;
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

function ModuleGuiEffects.Global:ShowInitialBlackscreen()
    if not Framework.IsNetworkGame() then
        Logic.ExecuteInLuaLocalState([[
            XGUIEng.PopPage();
            API.ActivateColoredScreen(GUI.GetPlayerID(), 0, 0, 0, 255);
            API.DeactivateNormalInterface(GUI.GetPlayerID());
            XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
        ]]);
    end
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
        if not Framework.IsNetworkGame() then
            self:InterfaceDeactivateImageBackground(GUI.GetPlayerID());
            self:InterfaceActivateNormalInterface(GUI.GetPlayerID());
        end
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

Revision:RegisterModule(ModuleGuiEffects);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Verschiedene Anzeigeeffekte nutzen und Kinoevents bereitstellen.
--
-- <h5>Cinematic Event</h5>
-- <u>Ein Kinoevent hat nichts mit den Script Events zu tun!</u> <br>
-- Es handelt sich um eine Markierung, ob für einen Spieler gerade ein Ereignis
-- stattfindet, das das normale Spielinterface manipuliert und den normalen
-- Spielfluss einschränkt. Es wird von der QSB benutzt um festzustellen, ob
-- bereits ein solcher veränderter Zustand aktiv ist und entsorechend darauf
-- zu reagieren, damit sichergestellt ist, dass beim Zurücksetzen des normalen
-- Zustandes keine Fehler passieren.
-- 
-- Der Anwender braucht sich damit nicht zu befassen, es sei denn man plant
-- etwas, das mit Kinoevents kollidieren kann. Wenn ein Feature ein Kinoevent
-- auslöst, ist dies in der Dokumentation ausgewiesen.
-- 
-- Während eines Kinoevent kann zusätzlich nicht gespeichert werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.CinematicEvent = {};

CinematicEvent = {
    NotTriggered = 0,
    Active = 1,
    Concluded = 2,
}

---
-- Events, auf die reagiert werden kann.
--
-- @field CinematicActivated  Ein Kinoevent wurde aktiviert (Parameter: KinoEventID, PlayerID)
-- @field CinematicConcluded  Ein Kinoevent wurde deaktiviert (Parameter: KinoEventID, PlayerID)
-- @field BorderScrollLocked  Scrollen am Bildschirmrand wurde gesperrt (Parameter: PlayerID)
-- @field BorderScrollReset   Scrollen am Bildschirmrand wurde freigegeben (Parameter: PlayerID)
-- @field GameInterfaceShown  Die Spieloberfläche wird angezeigt (Parameter: PlayerID)
-- @field GameInterfaceHidden Die Spieloberfläche wird ausgeblendet (Parameter: PlayerID)
-- @field ImageScreenShown    Der schwarze Hintergrund wird angezeigt (Parameter: PlayerID)
-- @field ImageScreenHidden   Der schwarze Hintergrund wird ausgeblendet (Parameter: PlayerID)
-- @field TypewriterStarted   Ein Schreibmaschineneffekt beginnt (Parameter: PlayerID, DataTable)
-- @field TypewriterEnded     Ein Schreibmaschineneffekt endet (Parameter: PlayerID, DataTable)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- Just to be compatible with the old version.
function API.ActivateColoredScreen(_PlayerID, _Red, _Green, _Blue, _Alpha)
    API.ActivateImageScreen(_PlayerID, "", _Red or 0, _Green or 0, _Blue or 0, _Alpha);
end

-- Just to be compatible with the old version.
function API.DeactivateColoredScreen(_PlayerID)
    API.DeactivateImageScreen(_PlayerID)
end

---
-- Blendet eine Graphic über der Spielwelt aber hinter dem Interface ein.
-- Die Grafik muss im 16:9-Format sein. Bei 4:3-Auflösungen wird
-- links und rechts abgeschnitten.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Image Pfad zur Grafik
-- @param[type=number] _Red   (Optional) Rotwert (Standard: 255)
-- @param[type=number] _Green (Optional) Grünwert (Standard: 255)
-- @param[type=number] _Blue  (Optional) Blauwert (Standard: 255)
-- @param[type=number] _Alpha (Optional) Alphawert (Standard: 255)
-- @within Anwenderfunktionen
--
function API.ActivateImageScreen(_PlayerID, _Image, _Red, _Green, _Blue, _Alpha)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleGuiEffects.Local:InterfaceActivateImageBackground(%d, "%s", %d, %d, %d, %d)]],
            _PlayerID,
            _Image,
            (_Red ~= nil and _Red) or 255,
            (_Green ~= nil and _Green) or 255,
            (_Blue ~= nil and _Blue) or 255,
            (_Alpha ~= nil and _Alpha) or 255
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateImageBackground(_PlayerID, _Image, _Red, _Green, _Blue, _Alpha);
end

---
-- Deaktiviert ein angezeigtes Bild, wenn dieses angezeigt wird.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.DeactivateImageScreen(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(_PlayerID);
end

---
-- Zeigt das normale Interface an.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.ActivateNormalInterface(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceActivateNormalInterface(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateNormalInterface(_PlayerID);
end

---
-- Blendet das normale Interface aus.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.DeactivateNormalInterface(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(_PlayerID);
end

---
-- Akliviert border Scroll wieder und löst die Fixierung auf ein Entity auf.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.ActivateBorderScroll(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceActivateBorderScroll(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateBorderScroll(_PlayerID);
end

---
-- Deaktiviert Randscrollen und setzt die Kamera optional auf das Ziel
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Position (Optional) Entity auf das die Kamera schaut
-- @within Anwenderfunktionen
--
function API.DeactivateBorderScroll(_PlayerID, _Position)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    local PositionID;
    if _Position then
        PositionID = GetID(_Position);
    end
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateBorderScroll(%d, %d)",
            _PlayerID,
            (PositionID or 0)
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateBorderScroll(_PlayerID, PositionID);
end

---
-- Propagiert den Beginn des Kinoevent und bindet es an den Spieler.
--
-- <b>Hinweis:</b>Während des aktiven Kinoevent kann nicht gespeichert werden.
--
-- @param[type=string] _Name     Bezeichner
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.StartCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    local ID = ModuleGuiEffects.Global:ActivateCinematicEvent(_PlayerID);
    QSB.CinematicEvent[_PlayerID][_Name] = ID;
end

---
-- Propagiert das Ende des Kinoevent.
--
-- @param[type=string] _Name     Bezeichner
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.FinishCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    if QSB.CinematicEvent[_PlayerID][_Name] then
        ModuleGuiEffects.Global:ConcludeCinematicEvent(QSB.CinematicEvent[_PlayerID][_Name], _PlayerID);
    end
end

---
-- Gibt den Zustand des Kinoevent zurück.
--
-- @param _Identifier            Bezeichner oder ID
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Zustand des Kinoevent
-- @within Anwenderfunktionen
--
function API.GetCinematicEvent(_Identifier, _PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    if type(_Identifier) == "number" then
        if GUI then
            return ModuleGuiEffects.Local:GetCinematicEventStatus(_Identifier);
        end
        return ModuleGuiEffects.Global:GetCinematicEventStatus(_Identifier);
    end
    if QSB.CinematicEvent[_PlayerID][_Identifier] then
        if GUI then
            return ModuleGuiEffects.Local:GetCinematicEventStatus(QSB.CinematicEvent[_PlayerID][_Identifier]);
        end
        return ModuleGuiEffects.Global:GetCinematicEventStatus(QSB.CinematicEvent[_PlayerID][_Identifier]);
    end
    return CinematicEvent.NotTriggered;
end

---
-- Prüft ob gerade ein Kinoevent für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Kinoevent ist aktiv
-- @within Anwenderfunktionen
--
function API.IsCinematicEventActive(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    for k, v in pairs(QSB.CinematicEvent[_PlayerID]) do
        if API.GetCinematicEvent(k, _PlayerID) == CinematicEvent.Active then
            return true;
        end
    end
    return false;
end

---
-- Blendet einen Text Zeichen für Zeichen ein.
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein anderes
-- Cinematic Event läuft, wird gewartet, bis es beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Cinematic Events starten.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der anzuzeigene Text</td>
-- </tr>
-- <tr>
-- <td>PlayerID</td>
-- <td>number</td>
-- <td>(Optional) Spieler, dem der Effekt angezeigt wird (Default: Menschlicher Spieler)</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>function</td>
-- <td>(Optional) Funktion nach Abschluss der Textanzeige (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>TargetEntity</td>
-- <td>string|number</td>
-- <td>(Optional) TargetEntity der Kamera (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>CharSpeed</td>
-- <td>number</td>
-- <td>(Optional) Die Schreibgeschwindigkeit (Default: 1.0)</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>number</td>
-- <td>(Optional) Initiale Wartezeigt bevor der Effekt startet</td>
-- </tr>
-- <tr>
-- <td>Opacity</td>
-- <td>number</td>
-- <td>(Optional) Durchsichtigkeit des Hintergrund (Default: 1)</td>
-- </tr>
-- <tr>
-- <td>Color</td>
-- <td>table</td>
-- <td>(Optional) Farbe des Hintergrund (Default: {R= 0, G= 0, B= 0}}</td>
-- </tr>
-- <tr>
-- <td>Image</td>
-- <td>string</td>
-- <td>(Optional) Pfad zur anzuzeigenden Grafik</td>
-- </tr>
-- </table>
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen (vom Spiel) auf ein Leerzeichen reduziert!
--
-- @param[type=table] _Data Konfiguration
-- @return[type=string] Name des zugeordneten Event
--
-- @usage
-- local EventName = API.StartTypewriter {
--     PlayerID = 1,
--     Text     = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--                "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--                "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--                " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--                " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--                " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--                " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--                " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--                " et accusam et justo duo dolores et ea rebum. Stet clita"..
--                " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--                " dolor sit amet.",
--     Callback = function(_Data)
--         -- Hier kann was passieren
--     end
-- };
-- @within Anwenderfunktionen
--
function API.StartTypewriter(_Data)
    if Framework.IsNetworkGame() ~= true then
        _Data.PlayerID = _Data.PlayerID or QSB.HumanPlayerID;
    end
    if _Data.PlayerID == nil or (_Data.PlayerID < 1 or _Data.PlayerID > 8) then
        return;
    end
    _Data.Text = API.Localize(_Data.Text or "");
    _Data.Callback = _Data.Callback or function() end;
    _Data.CharSpeed = _Data.CharSpeed or 1;
    _Data.Waittime = (_Data.Waittime or 8) * 10;
    _Data.TargetEntity = GetID(_Data.TargetEntity or 0);
    _Data.Image = _Data.Image or "";
    _Data.Color = _Data.Color or {
        R = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        G = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        B = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        A = 255
    };
    if _Data.Opacity and _Data.Opacity >= 0 and _Data.Opacity then
        _Data.Color.A = math.floor((255 * _Data.Opacity) + 0.5);
    end
    _Data.Delay = 15;
    _Data.Index = 0;
    return ModuleGuiEffects.Global:StartTypewriter(_Data);
end
API.SimpleTypewriter = API.StartTypewriter;

