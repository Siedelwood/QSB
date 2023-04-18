--[[
Swift_1_DisplayCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleDisplayCore = {
    Properties = {
        Name = "ModuleDisplayCore",
    },

    Global = {
        CinematicEventID = 0,
        CinematicEventStatus = {},
        CinematicEventQueue = {},
    },
    Local = {
        CinematicEventStatus = {},

        ChatOptionsWasShown = false,
        MessageLogWasShown = false,
        PauseScreenShown = false,
        NormalModeHidden = false,
        BorderScrollDeactivated = false,
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {};
}

-- Just because I am a control freak and want to know what the default is...
QSB.DisplayConstants = {
    FAR_CLIP_MIN = 50000,
    FAR_CLIP_MAX = 50000,
}

QSB.CinematicEvents = {};
QSB.CinematicEventTypes = {};

-- Global ------------------------------------------------------------------- --

function ModuleDisplayCore.Global:OnGameStart()
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.BlackScreenShown = API.RegisterScriptEvent("Event_BlackScreenShown");
    QSB.ScriptEvents.BlackScreenHidden = API.RegisterScriptEvent("Event_BlackScreenHidden");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
        self.CinematicEventQueue[i] = {};
    end
    self:ShowInitialBlackscreen();
end

function ModuleDisplayCore.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.CinematicActivated then
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        if self.CinematicEventStatus[arg[2]][arg[1]] then
            self.CinematicEventStatus[arg[2]][arg[1]] = 2;
        end
        -- HACK: prevents flickering by always activate a blackscreen when the
        -- cinematic queue is not empty.
        if #self.CinematicEventQueue[arg[2]] > 0 then
            API.DeactivateImageScreen(arg[2]);
            API.ActivateNormalInterface(arg[2]);
        end
    end
end

function ModuleDisplayCore.Global:PushCinematicEventToQueue(_PlayerID, _Type, _Name, _Data)
    table.insert(self.CinematicEventQueue[_PlayerID], {_Type, _Name, _Data});
end

function ModuleDisplayCore.Global:LookUpCinematicInFromQueue(_PlayerID)
    if #self.CinematicEventQueue[_PlayerID] > 0 then
        return self.CinematicEventQueue[_PlayerID][1];
    end
end

function ModuleDisplayCore.Global:PopCinematicEventFromQueue(_PlayerID)
    if #self.CinematicEventQueue[_PlayerID] > 0 then
        return table.remove(self.CinematicEventQueue[_PlayerID], 1);
    end
end

function ModuleDisplayCore.Global:GetNewCinematicEventID()
    self.CinematicEventID = self.CinematicEventID +1;
    return self.CinematicEventID;
end

function ModuleDisplayCore.Global:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleDisplayCore.Global:ActivateCinematicEvent(_PlayerID)
    local ID = self:GetNewCinematicEventID();
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, %d, %d);
          if GUI.GetPlayerID() == %d then
            XGUIEng.DisableButton("/InGame/InGame/MainMenu/Container/QuickSave", 1);
            XGUIEng.DisableButton("/InGame/InGame/MainMenu/Container/SaveGame", 1);
          end]],
        ID,
        _PlayerID,
        _PlayerID
    ))
    API.SendScriptEvent(QSB.ScriptEvents.CinematicActivated, ID, _PlayerID);
    return ID;
end

function ModuleDisplayCore.Global:ConcludeCinematicEvent(_ID, _PlayerID)
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, %d, %d);
          if GUI.GetPlayerID() == %d then
            XGUIEng.DisableButton("/InGame/InGame/MainMenu/Container/QuickSave", 0);
            XGUIEng.DisableButton("/InGame/InGame/MainMenu/Container/SaveGame", 0);
          end]],
        _ID,
        _PlayerID,
        _PlayerID
    ))
    API.SendScriptEvent(QSB.ScriptEvents.CinematicConcluded, _ID, _PlayerID);
end

-- HACK: This is an attemp to fix the problem, that the normal game screen is
-- shown for a split second when the loadscreen is clicked away.
function ModuleDisplayCore.Global:ShowInitialBlackscreen()
    Logic.ExecuteInLuaLocalState([[
        XGUIEng.PopPage();
        API.ActivateColoredScreen(GUI.GetPlayerID(), 0, 0, 0, 255);
        API.DeactivateNormalInterface(GUI.GetPlayerID());
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    ]]);
end

-- Local -------------------------------------------------------------------- --

function ModuleDisplayCore.Local:OnGameStart()
    QSB.ScriptEvents.CinematicActivated = API.RegisterScriptEvent("Event_CinematicEventActivated");
    QSB.ScriptEvents.CinematicConcluded = API.RegisterScriptEvent("Event_CinematicEventConcluded");
    QSB.ScriptEvents.BorderScrollLocked = API.RegisterScriptEvent("Event_BorderScrollLocked");
    QSB.ScriptEvents.BorderScrollReset  = API.RegisterScriptEvent("Event_BorderScrollReset");
    QSB.ScriptEvents.GameInterfaceShown = API.RegisterScriptEvent("Event_GameInterfaceShown");
    QSB.ScriptEvents.GameInterfaceHidden = API.RegisterScriptEvent("Event_GameInterfaceHidden");
    QSB.ScriptEvents.BlackScreenShown = API.RegisterScriptEvent("Event_BlackScreenShown");
    QSB.ScriptEvents.BlackScreenHidden = API.RegisterScriptEvent("Event_BlackScreenHidden");

    for i= 1, 8 do
        self.CinematicEventStatus[i] = {};
    end
    self:OverrideInterfaceUpdateForCinematicMode();
    self:OverrideInterfaceThroneroomForCinematicMode();
    self:ResetFarClipPlane();
end

function ModuleDisplayCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.CinematicActivated then
        self.CinematicEventStatus[arg[2]][arg[1]] = 1;
    elseif _ID == QSB.ScriptEvents.CinematicConcluded then
        for i= 1, 8 do
            if self.CinematicEventStatus[i][arg[1]] then
                self.CinematicEventStatus[i][arg[1]] = 2;
            end
        end
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:ResetFarClipPlane();
    -- HACK: This is the second part of the blackscreen hack. Removes it after
    -- the loadscreen is clicked away.
    elseif _ID == QSB.ScriptEvents.LoadscreenClosed then
        API.DeactivateImageScreen(GUI.GetPlayerID());
        API.ActivateNormalInterface(GUI.GetPlayerID());
    end
end

function ModuleDisplayCore.Local:SetFarClipPlane(_View)
    Camera.Cutscene_SetFarClipPlane(_View, _View);
    Display.SetFarClipPlaneMinAndMax(_View, _View);
end

function ModuleDisplayCore.Local:ResetFarClipPlane()
    Camera.Cutscene_SetFarClipPlane(QSB.DisplayConstants.FAR_CLIP_MAX);
    Display.SetFarClipPlaneMinAndMax(
        QSB.DisplayConstants.FAR_CLIP_MIN,
        QSB.DisplayConstants.FAR_CLIP_MAX
    );
end

function ModuleDisplayCore.Local:GetCinematicEventStatus(_InfoID)
    for i= 1, 8 do
        if self.CinematicEventStatus[i][_InfoID] then
            return self.CinematicEventStatus[i][_InfoID];
        end
    end
    return 0;
end

function ModuleDisplayCore.Local:OverrideInterfaceUpdateForCinematicMode()
    API.AddBlockQuicksaveCondition(function()
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.BorderScrollDeactivated
        or ModuleDisplayCore.Local.PauseScreenShown
        or API.IsCinematicEventActive(GUI.GetPlayerID()) then
            return true;
        end
    end);

    GameCallback_GameSpeedChanged_Orig_ModuleDisplayCoreInterface = GameCallback_GameSpeedChanged;
    GameCallback_GameSpeedChanged = function(_Speed)
        if not ModuleDisplayCore.Local.PauseScreenShown then
            GameCallback_GameSpeedChanged_Orig_ModuleDisplayCoreInterface(_Speed);
        end
    end

    MissionTimerUpdate_Orig_ModuleDisplayCoreInterface = MissionTimerUpdate;
    MissionTimerUpdate = function()
        MissionTimerUpdate_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionTimer", 0);
        end
    end

    MissionGoodOrEntityCounterUpdate_Orig_ModuleDisplayCoreInterface = MissionGoodOrEntityCounterUpdate;
    MissionGoodOrEntityCounterUpdate = function()
        MissionGoodOrEntityCounterUpdate_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter", 0);
        end
    end

    MerchantButtonsUpdater_Orig_ModuleDisplayCoreInterface = GUI_Merchant.ButtonsUpdater;
    GUI_Merchant.ButtonsUpdater = function()
        MerchantButtonsUpdater_Orig_ModuleDisplayCoreInterface();
        if ModuleDisplayCore.Local.NormalModeHidden
        or ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Merchant", 0);
        end
    end

    if GUI_Tradepost then
        TradepostButtonsUpdater_Orig_ModuleDisplayCoreInterface = GUI_Tradepost.ButtonsUpdater;
        GUI_Tradepost.ButtonsUpdater = function()
            TradepostButtonsUpdater_Orig_ModuleDisplayCoreInterface();
            if ModuleDisplayCore.Local.NormalModeHidden
            or ModuleDisplayCore.Local.PauseScreenShown then
                XGUIEng.ShowWidget("/InGame/Root/Normal/Selected_Tradepost", 0);
            end
        end
    end
end

function ModuleDisplayCore.Local:OverrideInterfaceThroneroomForCinematicMode()
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

function ModuleDisplayCore.Local:InterfaceActivateImageBackground(_PlayerID, _Graphic, _R, _G, _B, _A)
    if self.PauseScreenShown then
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
    API.SendScriptEventToGlobal( QSB.ScriptEvents.BlackScreenShown, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BlackScreenShown, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateImageBackground(_PlayerID)
    if not self.PauseScreenShown then
        return;
    end
    self.PauseScreenShown = false;

    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
    XGUIEng.SetMaterialTexture("/InGame/Root/Normal/PauseScreen", 0, "");
    XGUIEng.SetMaterialColor("/InGame/Root/Normal/PauseScreen", 0, 40, 40, 40, 180);
    XGUIEng.PopPage();
    API.SendScriptEventToGlobal( QSB.ScriptEvents.BlackScreenHidden, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BlackScreenHidden, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateBorderScroll(_PlayerID, _PositionID)
    if self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = true;
    if _PositionID then
        Camera.RTS_FollowEntity(_PositionID);
    end
    Camera.RTS_SetBorderScrollSize(0);
    Camera.RTS_SetZoomWheelSpeed(0);

    API.SendScriptEventToGlobal(
        QSB.ScriptEvents.BorderScrollLocked,
        GUI.GetPlayerID(),
        (_PositionID or 0)
    );
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollLocked, GUI.GetPlayerID(), _PositionID);
end

function ModuleDisplayCore.Local:InterfaceActivateBorderScroll(_PlayerID)
    if not self.BorderScrollDeactivated then
        return;
    end
    self.BorderScrollDeactivated = false;
    Camera.RTS_FollowEntity(0);
    Camera.RTS_SetBorderScrollSize(3.0);
    Camera.RTS_SetZoomWheelSpeed(4.2);

    API.SendScriptEventToGlobal(QSB.ScriptEvents.BorderScrollReset, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.BorderScrollReset, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceDeactivateNormalInterface(_PlayerID)
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

    API.SendScriptEventToGlobal(QSB.ScriptEvents.GameInterfaceHidden, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceHidden, GUI.GetPlayerID());
end

function ModuleDisplayCore.Local:InterfaceActivateNormalInterface(_PlayerID)
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

    API.SendScriptEventToGlobal(QSB.ScriptEvents.GameInterfaceShown, GUI.GetPlayerID());
    API.SendScriptEvent(QSB.ScriptEvents.GameInterfaceShown, GUI.GetPlayerID());
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleDisplayCore);

