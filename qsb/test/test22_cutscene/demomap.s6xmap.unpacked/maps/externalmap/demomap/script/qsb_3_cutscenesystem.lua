--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleCutsceneSystem = {
    Properties = {
        Name = "ModuleCutsceneSystem",
    },

    Global = {
        Cutscene = {},
        CutsceneQueue = {},
        CutsceneCounter = 0;
    },
    Local = {
        Cutscene = {},
    },

    Shared = {
        Text = {
            FastForwardActivate   = {de = "Beschleunigen",      en = "Fast Forward", fr = "Accélérer"},
            FastForwardDeactivate = {de = "Zurücksetzen",       en = "Normal Speed", fr = "Réinitialiser"},
            FastFormardMessage    = {de = "SCHNELLER VORLAUF",  en = "FAST FORWARD", fr = "AVANCÉ RAPIDE"},
        },
    },
};

QSB.CinematicEventTypes.Cutscene = 3;

-- Global ------------------------------------------------------------------- --

function ModuleCutsceneSystem.Global:OnGameStart()
    QSB.ScriptEvents.CutsceneStarted = API.RegisterScriptEvent("Event_CutsceneStarted");
    QSB.ScriptEvents.CutsceneEnded = API.RegisterScriptEvent("Event_CutsceneEnded");
    QSB.ScriptEvents.CutsceneSkipButtonPressed = API.RegisterScriptEvent("Event_CutsceneSkipButtonPressed");
    QSB.ScriptEvents.CutsceneFlightStarted = API.RegisterScriptEvent("Event_CutsceneFlightStarted");
    QSB.ScriptEvents.CutsceneFlightEnded = API.RegisterScriptEvent("Event_CutsceneFlightEnded");

    for i= 1, 8 do
        self.CutsceneQueue[i] = {};
    end

    API.StartHiResJob(function()
        ModuleCutsceneSystem.Global:UpdateQueue();
    end);
end

function ModuleCutsceneSystem.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
        -- Nothing to do?
    elseif _ID == QSB.ScriptEvents.CutsceneStarted then
        -- Nothing to do?
    elseif _ID == QSB.ScriptEvents.CutsceneEnded then
        self:EndCutscene(arg[1]);
    elseif _ID == QSB.ScriptEvents.CutsceneFlightStarted then
        self:StartCutsceneFlight(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.CutsceneFlightEnded then
        self:EndCutsceneFlight(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.CutsceneSkipButtonPressed then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.CutsceneSkipButtonPressed, %d)]],
            arg[1]
        ));
    end
end

function ModuleCutsceneSystem.Global:UpdateQueue()
    for i= 1, 8 do
        if self:CanStartCutscene(i) then
            local Next = ModuleGuiEffects.Global:LookUpCinematicInQueue(i);
            if Next and Next[1] == QSB.CinematicEventTypes.Cutscene then
                self:NextCutscene(i);
            end
        end
    end
end

function ModuleCutsceneSystem.Global:CreateCutsceneGetPage(_Cutscene)
    _Cutscene.GetPage = function(self, _PlayerID, _NameOrID)
        local ID = ModuleCutsceneSystem.Global:GetPageIDByName(_PlayerID, _NameOrID);
        return ModuleCutsceneSystem.Global.Cutscene[_PlayerID][ID];
    end
end

function ModuleCutsceneSystem.Global:CreateCutsceneAddPage(_Cutscene)
    _Cutscene.AddPage = function(self, _Page)
        if type(_Page) == "table" then
            -- Make page legit
            _Page.__Legit = true;

            -- Translate text
            _Page.Title = API.Localize(_Page.Title);
            if _Page.Text then
                _Page.Text = API.Localize(_Page.Text);
            end
            -- Translate text lines
            if _Page.Lines then
                _Page.Lines = API.Localize(_Page.Lines);
            end
            if not _Page.Lines and not _Page.Text then
                assert(false, "Missing Lines or Text attribute!");
                return;
            end

            -- Set bar default
            if _Page.BigBars == nil then
                _Page.BigBars = false;
            end
        end
        table.insert(_Cutscene, _Page);
        return _Page;
    end
end

function ModuleCutsceneSystem.Global:StartCutscene(_Name, _PlayerID, _Data)
    self.CutsceneQueue[_PlayerID] = self.CutsceneQueue[_PlayerID] or {};
    ModuleGuiEffects.Global:PushCinematicEventToQueue(
        _PlayerID,
        QSB.CinematicEventTypes.Cutscene,
        _Name,
        _Data
    );
end

function ModuleCutsceneSystem.Global:EndCutscene(_PlayerID)
    Logic.SetGlobalInvulnerability(0);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CutsceneEnded, %d)]],
        _PlayerID
    ));
    if self.Cutscene[_PlayerID].Finished then
        self.Cutscene[_PlayerID]:Finished();
    end
    API.FinishCinematicEvent(self.Cutscene[_PlayerID].Name, _PlayerID);
    self.Cutscene[_PlayerID] = nil;
end

function ModuleCutsceneSystem.Global:NextCutscene(_PlayerID)
    if self:CanStartCutscene(_PlayerID) then
        local CutsceneData = ModuleGuiEffects.Global:PopCinematicEventFromQueue(_PlayerID);
        assert(CutsceneData[1] == QSB.CinematicEventTypes.Cutscene);
        API.StartCinematicEvent(CutsceneData[2], _PlayerID);

        local Cutscene = CutsceneData[3];
        Cutscene.Name = CutsceneData[2];
        Cutscene.PlayerID = _PlayerID;
        Cutscene.BarOpacity = Cutscene.BarOpacity or 1;
        Cutscene.CurrentPage = 0;
        self.Cutscene[_PlayerID] = Cutscene;

        if Cutscene.EnableGlobalImmortality then
            Logic.SetGlobalInvulnerability(1);
        end
        if self.Cutscene[_PlayerID].Starting then
            self.Cutscene[_PlayerID]:Starting();
        end

        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.CutsceneStarted, %d, %s)]],
            _PlayerID,
            table.tostring(self.Cutscene[_PlayerID])
        ));
        API.SendScriptEvent(
            QSB.ScriptEvents.CutsceneStarted,
            _PlayerID,
            self.Cutscene[_PlayerID]
        );
    end
end

function ModuleCutsceneSystem.Global:StartCutsceneFlight(_PlayerID, _PageID, _Duration)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    self.Cutscene[_PlayerID][_PageID].Duration = _Duration;
    if self.Cutscene[_PlayerID][_PageID].Action then
        self.Cutscene[_PlayerID][_PageID]:Action();
    end

    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CutsceneFlightStarted, %d, %d, %d)]],
        _PlayerID,
        _PageID,
        _Duration
    ));
end

function ModuleCutsceneSystem.Global:EndCutsceneFlight(_PlayerID, _PageID)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CutsceneFlightEnded, %d, %d)]],
        _PlayerID,
        _PageID
    ));
end

function ModuleCutsceneSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.CutscenePageShown, %d, %d)]],
        _PlayerID,
        _PageID
    ));
end

function ModuleCutsceneSystem.Global:GetCurrentCutscene(_PlayerID)
    return self.Cutscene[_PlayerID];
end

function ModuleCutsceneSystem.Global:GetCurrentCutscenePage(_PlayerID)
    if self.Cutscene[_PlayerID] then
        local PageID = self.Cutscene[_PlayerID].CurrentPage;
        return self.Cutscene[_PlayerID][PageID];
    end
end

function ModuleCutsceneSystem.Global:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Cutscene[_PlayerID] ~= nil then
            for i= 1, #self.Cutscene[_PlayerID], 1 do
                if type(self.Cutscene[_PlayerID][i]) == "table" and self.Cutscene[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleCutsceneSystem.Global:CanStartCutscene(_PlayerID)
    return  self.Cutscene[_PlayerID] == nil and
            not API.IsCinematicEventActive(_PlayerID) and
            self.LoadscreenClosed;
end

-- Local -------------------------------------------------------------------- --

function ModuleCutsceneSystem.Local:OnGameStart()
    QSB.ScriptEvents.CutsceneStarted = API.RegisterScriptEvent("Event_CutsceneStarted");
    QSB.ScriptEvents.CutsceneEnded = API.RegisterScriptEvent("Event_CutsceneEnded");
    QSB.ScriptEvents.CutsceneSkipButtonPressed = API.RegisterScriptEvent("Event_CutsceneSkipButtonPressed");
    QSB.ScriptEvents.CutsceneFlightStarted = API.RegisterScriptEvent("Event_CutsceneFlightStarted");
    QSB.ScriptEvents.CutsceneFlightEnded = API.RegisterScriptEvent("Event_CutsceneFlightEnded");

    self:OverrideThroneRoomFunctions();
end

function ModuleCutsceneSystem.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
        -- Nothing to do?
    elseif _ID == QSB.ScriptEvents.CutsceneStarted then
        self:StartCutscene(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.CutsceneEnded then
        self:EndCutscene(arg[1]);
    elseif _ID == QSB.ScriptEvents.CutsceneFlightStarted then
        self:StartCutsceneFlight(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.CutsceneFlightEnded then
        self:EndCutsceneFlight(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.CutsceneSkipButtonPressed then
        self:SkipButtonPressed(arg[1]);
    end
end

function ModuleCutsceneSystem.Local:StartCutscene(_PlayerID, _Cutscene)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Cutscene[_PlayerID] = _Cutscene;
    self.Cutscene[_PlayerID].LastSkipButtonPressed = 0;
    self.Cutscene[_PlayerID].CurrentPage = 0;

    API.DeactivateNormalInterface(_PlayerID);
    API.DeactivateBorderScroll(_PlayerID);

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:ActivateCinematicMode(_PlayerID);
    self:NextFlight(_PlayerID);
end

function ModuleCutsceneSystem.Local:EndCutscene(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:DeactivateCinematicMode(_PlayerID);
    API.ActivateNormalInterface(_PlayerID);
    API.ActivateBorderScroll(_PlayerID);
    ModuleGuiControl.Local:UpdateHiddenWidgets();

    self.Cutscene[_PlayerID] = nil;
end

function ModuleCutsceneSystem.Local:NextFlight(_PlayerID)
    if self.Cutscene[_PlayerID] then
        self.Cutscene[_PlayerID].CurrentPage = self.Cutscene[_PlayerID].CurrentPage +1;
        local PageID = self.Cutscene[_PlayerID].CurrentPage;

        if self.Cutscene[_PlayerID][PageID] then
            local Flight = self.Cutscene[_PlayerID][PageID].Flight;
            if Camera.IsValidCutscene(Flight) then
                if GUI.GetPlayerID() == _PlayerID then
                    Camera.StartCutscene(Flight);
                end
            else
                -- This shouldn't happen!
                error("ModuleCutsceneSystem.Local:NextFlight: " ..tostring(Flight).. " is an invalid flight!");
                self:PropagateCutsceneEnded(_PlayerID);
            end
        else
            self:PropagateCutsceneEnded(_PlayerID);
        end
    end
end

function ModuleCutsceneSystem.Local:PropagateCutsceneEnded(_PlayerID)
    if not self.Cutscene[_PlayerID] then
        return;
    end
    API.BroadcastScriptEventToGlobal(
        "CutsceneEnded",
        _PlayerID
    );
end

function ModuleCutsceneSystem.Local:FlightStarted(_Duration)
    local PlayerID = GUI.GetPlayerID();
    if self.Cutscene[PlayerID] then
        local PageID = self.Cutscene[PlayerID].CurrentPage;
        API.BroadcastScriptEventToGlobal(
            "CutsceneFlightStarted",
            PlayerID,
            PageID,
            _Duration
        );
    end
end
CutsceneFlightStarted = function(_Duration)
    ModuleCutsceneSystem.Local:FlightStarted(_Duration);
end

function ModuleCutsceneSystem.Local:StartCutsceneFlight(_PlayerID, _PageID, _Duration)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    self:DisplayPage(_PlayerID, _PageID, _Duration);
end

function ModuleCutsceneSystem.Local:FlightFinished()
    local PlayerID = GUI.GetPlayerID();
    if self.Cutscene[PlayerID] then
        local PageID = self.Cutscene[PlayerID].CurrentPage;
        API.BroadcastScriptEventToGlobal(
            "CutsceneFlightEnded",
            PlayerID,
            PageID
        );
    end
end
CutsceneFlightFinished = function()
    ModuleCutsceneSystem.Local:FlightFinished();
end

function ModuleCutsceneSystem.Local:EndCutsceneFlight(_PlayerID, _PageID)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    self:NextFlight(_PlayerID);
end

function ModuleCutsceneSystem.Local:DisplayPage(_PlayerID, _PageID, _Duration)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Cutscene[_PlayerID].AnimationQueue = self.Cutscene[_PlayerID].AnimationQueue or {};
    self.Cutscene[_PlayerID].CurrentPage = _PageID;
    if type(self.Cutscene[_PlayerID][_PageID]) == "table" then
        self.Cutscene[_PlayerID][_PageID].Started = Logic.GetTime();
        self.Cutscene[_PlayerID][_PageID].Duration = _Duration;
        ModuleGuiEffects.Local:ResetFarClipPlane();
        self:DisplayPageBars(_PlayerID, _PageID);
        self:DisplayPageTitle(_PlayerID, _PageID);
        self:DisplayPageText(_PlayerID, _PageID);
        self:DisplayPageControls(_PlayerID, _PageID);
        self:DisplayPageFader(_PlayerID, _PageID);
    end
end

function ModuleCutsceneSystem.Local:DisplayPageBars(_PlayerID, _PageID)
    local Page = self.Cutscene[_PlayerID][_PageID];
    local Opacity = (Page.Opacity ~= nil and Page.Opacity) or 1;
    local OpacityBig = (255 * Opacity);
    local OpacitySmall = (255 * Opacity);

    local BigVisibility = (Page.BigBars and 1) or 0;
    local SmallVisibility = (Page.BigBars and 0) or 1;
    if Opacity == 0 then
        BigVisibility = 0;
        SmallVisibility = 0;
    end

    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", SmallVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", BigVisibility);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", SmallVisibility);

    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop", 1, OpacityBig);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom", 1, OpacitySmall);
    XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop", 1, OpacitySmall);
end

function ModuleCutsceneSystem.Local:DisplayPageTitle(_PlayerID, _PageID)
    local Page = self.Cutscene[_PlayerID][_PageID];
    local TitleWidget = "/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight";
    XGUIEng.SetText(TitleWidget, "");
    if Page.Title then
        local Title = API.ConvertPlaceholders(Page.Title);
        if Title:find("^[A-Za-Z0-9_]+/[A-Za-Z0-9_]+$") then
            Title = XGUIEng.GetStringTableText(Title);
        end
        if Title:sub(1, 1) ~= "{" then
            Title = "{@color:255,250,0,255}{center}" ..Title;
        end
        XGUIEng.SetText(TitleWidget, Title);
    end
end

function ModuleCutsceneSystem.Local:DisplayPageText(_PlayerID, _PageID)
    local Page = self.Cutscene[_PlayerID][_PageID];
    local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
    XGUIEng.SetText(TextWidget, "Bockwurst");
    if Page.Text then
        local Text = API.ConvertPlaceholders(Page.Text);
        if Text:find("^[A-Za-Z0-9_]+/[A-Za-Z0-9_]+$") then
            Text = XGUIEng.GetStringTableText(Text);
        end
        if Text:sub(1, 1) ~= "{" then
            Text = "{center}" ..Text;
        end
        if not Page.BigBars then
            Text = "{cr}{cr}{cr}" .. Text;
        end
        XGUIEng.SetText(TextWidget, Text);
    end
end

function ModuleCutsceneSystem.Local:DisplayPageControls(_PlayerID, _PageID)
    local Page = self.Cutscene[_PlayerID][_PageID];
    local SkipFlag = 1;
    if Page.DisableSkipping == true then
        self.Cutscene[_PlayerID].FastForward = false;
        Game.GameTimeSetFactor(_PlayerID, 1);
        SkipFlag = 0;
    end
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", SkipFlag);
end

function ModuleCutsceneSystem.Local:DisplayPageFader(_PlayerID, _PageID)
    local Page = self.Cutscene[_PlayerID][_PageID];
    g_Fade.To = Page.FaderAlpha or 0;

    local PageFadeIn = Page.FadeIn;
    if PageFadeIn then
        FadeIn(PageFadeIn);
    end

    local PageFadeOut = Page.FadeOut;
    if PageFadeOut then
        -- FIXME: This would create jobs that are only be paused at the end!
        self.Cutscene[_PlayerID].FaderJob = API.StartHiResJob(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                FadeOut(_FadeOut);
                return true;
            end
        end, (Page.Started * 1000) + (Page.Duration * 100), PageFadeOut);
    end
end

function ModuleCutsceneSystem.Local:ThroneRoomCameraControl(_PlayerID, _Page)
    if _Page then
        if _Page.DisableSkipping then
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");
            -- XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 0);
            return;
        end
        -- XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);

        -- Button text
        local SkipText = API.Localize(ModuleCutsceneSystem.Shared.Text.FastForwardActivate);
        if self.Cutscene[_PlayerID].FastForward then
            SkipText = API.Localize(ModuleCutsceneSystem.Shared.Text.FastForwardDeactivate);
        end
        XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..SkipText);

        -- Fast forward message
        if self.Cutscene[_PlayerID].FastForward then
            local RealTime = API.RealTimeGetSecondsPassedSinceGameStart();
            if not self.Cutscene[_PlayerID].FastForwardRealTime then
                self.Cutscene[_PlayerID].FastForwardRealTime = RealTime;
            end
            if self.Cutscene[_PlayerID].FastForwardRealTime < RealTime then
                self.Cutscene[_PlayerID].FastForwardIndent = (self.Cutscene[_PlayerID].FastForwardIndent or 0) +1;
                if self.Cutscene[_PlayerID].FastForwardIndent > 4 then
                    self.Cutscene[_PlayerID].FastForwardIndent = 1;
                end
                self.Cutscene[_PlayerID].FastForwardRealTime = RealTime;
            end
            local Text = "{cr}{cr}" ..API.Localize(ModuleCutsceneSystem.Shared.Text.FastFormardMessage);
            local Indent = string.rep("  ", (self.Cutscene[_PlayerID].FastForwardIndent or 0));
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", Text..Indent.. ". . .");
        else
            XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");
        end

        -- Far Clip Plane
        -- (After each camera event is executed, the value is reset to what ever
        -- is set in it. So to not need to add script events to each flight we
        -- need to set the value here.)
        if _Page.FarClipPlane then
            ModuleGuiEffects.Local:SetFarClipPlane(_Page.FarClipPlane);
        end
    end
end

function ModuleCutsceneSystem.Local:SkipButtonPressed(_PlayerID)
    if self.Cutscene[_PlayerID] == nil then
        return;
    end
    if (self.Cutscene[_PlayerID].LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
        self.Cutscene[_PlayerID].LastSkipButtonPressed = Logic.GetTimeMs();

        -- Change speed of cutscene is only possible in singleplayer!
        if not Framework.IsNetworkGame() then
            if self.Cutscene[_PlayerID].FastForward then
                self.Cutscene[_PlayerID].FastForward = false;
                Game.GameTimeSetFactor(_PlayerID, 1);
            else
                self.Cutscene[_PlayerID].FastForward = true;
                Game.GameTimeSetFactor(_PlayerID, 10);
            end
        end
    end
end

function ModuleCutsceneSystem.Local:GetCurrentCutscene(_PlayerID)
    return self.Cutscene[_PlayerID];
end

function ModuleCutsceneSystem.Local:GetCurrentCutscenePage(_PlayerID)
    if self.Cutscene[_PlayerID] then
        local PageID = self.Cutscene[_PlayerID].CurrentPage;
        return self.Cutscene[_PlayerID][PageID];
    end
end

function ModuleCutsceneSystem.Local:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Cutscene[_PlayerID] ~= nil then
            for i= 1, #self.Cutscene[_PlayerID], 1 do
                if type(self.Cutscene[_PlayerID][i]) == "table" and self.Cutscene[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleCutsceneSystem.Local:OverrideThroneRoomFunctions()
    GameCallback_Camera_SkipButtonPressed_Orig_ModuleCutsceneSystem = GameCallback_Camera_SkipButtonPressed;
    GameCallback_Camera_SkipButtonPressed = function(_PlayerID)
        GameCallback_Camera_SkipButtonPressed_Orig_ModuleCutsceneSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            API.BroadcastScriptEventToGlobal(
                "CutsceneSkipButtonPressed",
                GUI.GetPlayerID()
            );
        end
    end

    GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleCutsceneSystem = GameCallback_Camera_ThroneroomCameraControl;
    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
        GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleCutsceneSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            local Cutscene = ModuleCutsceneSystem.Local:GetCurrentCutscene(_PlayerID);
            if Cutscene ~= nil then
                ModuleCutsceneSystem.Local:ThroneRoomCameraControl(
                    _PlayerID,
                    ModuleCutsceneSystem.Local:GetCurrentCutscenePage(_PlayerID)
                );
            end
        end
    end

    GameCallback_Escape_Orig_CutsceneSystem = GameCallback_Escape;
    GameCallback_Escape = function()
        if ModuleCutsceneSystem.Local.Cutscene[GUI.GetPlayerID()] then
            return;
        end
        GameCallback_Escape_Orig_CutsceneSystem();
    end
end

function ModuleCutsceneSystem.Local:ActivateCinematicMode(_PlayerID)
    if self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = true;

    if not self.LoadscreenClosed then
        XGUIEng.PopPage();
    end
    local ScreenX, ScreenY = GUI.GetScreenSize();

    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Cutscene", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/LeftFrame", 0);

    -- Text
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    -- Title and back button position
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65 * (ScreenY/1080));

    self.SelectionBackup = {GUI.GetSelectedEntities()};
    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    if not self.Cutscene[_PlayerID].EnableFoW then
        Display.SetRenderFogOfWar(0);
    end
    if self.Cutscene[_PlayerID].EnableSky then
        Display.SetRenderSky(1);
    end
    if not self.Cutscene[_PlayerID].EnableBorderPins then
        Display.SetRenderBorderPins(0);
    end
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(5);

    InitializeFader();
    g_Fade.To = 1;
    SetFaderAlpha(1);

    if not self.LoadscreenClosed then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

function ModuleCutsceneSystem.Local:DeactivateCinematicMode(_PlayerID)
    if not self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = false;

    g_Fade.To = 0;
    SetFaderAlpha(0);
    XGUIEng.PopPage();
    Camera.SwitchCameraBehaviour(0);
    Display.UseStandardSettings();
    Input.GameMode();
    GUI.EnableBattleSignals(true);
    GUI.SetFeedbackSoundOutputState(1);
    GUI.ActivateSelectionState();
    GUI.PermitContextSensitiveCommandsInSelectionState();
    for k, v in pairs(self.SelectionBackup) do
        GUI.SelectEntity(v);
    end
    Display.SetRenderSky(0);
    Display.SetRenderBorderPins(1);
    Display.SetRenderFogOfWar(1);
    if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
        Display.SetUserOptionOcclusionEffect(1);
    end

    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.PopPage();
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    ModuleGuiEffects.Local:ResetFarClipPlane();
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleCutsceneSystem);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Cutscene zu verwenden.
--
-- Cutscenes sind Kameraflüge, die zur szenerischen Untermalung gedacht sind.
-- Texte sind kurz zu halten oder ganz wegzulassen, da der Spieler die Animation
-- genießen soll und bestimmt nicht die ganze Zeit mit den Augen am
-- Bildschirmrand festkleben will. Ebensowenig sind breite Bars oder der
-- stetige Wechsel zwischen schmal und breit zu empfehlen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_1_GuiEffects.QSB_1_GuiEffects.html">(1) Anzeigeeffekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field CutsceneStarted           Eine Cutscene beginnt (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneEnded             Eine Cutscene endet (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneSkipButtonPressed Der Spieler beschleunigt die Wiedergabegeschwindigkeit (Parameter: PlayerID)
-- @field CutsceneFlightStarted     Ein Flight wird gestartet (Parameter: PlayerID, PageIndex, Duration)
-- @field CutsceneFlightEnded       Ein Flight ist beendet (Parameter: PlayerID, PageIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet eine Cutscene.
--
-- Die Funktion bekommt ein Table mit der Definition der Cutscene, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- <h5>Einstellungen</h5>
-- Für eine Cutscene können verschiedene spezielle Einstellungen vorgenommen
-- werden.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start der Cutscene ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.CutsceneStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung der Cutscene ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.CutsceneEnded aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange die Cutscene aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während der Cutscene angezeigt. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird während der Cutscene angezeigt. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden während der Cutscene angezeigt. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Cutscene Definition der Cutscene
-- @param[type=string] _Name     Name der Cutscene
-- @param[type=number] _PlayerID Empfänger der Cutscene
-- @within Anwenderfunktionen
--
-- @usage
-- 
-- function Cutscene1(_Name, _PlayerID)
--     local Cutscene = {};
--     local AP = API.AddCutscenePages(Cutscene);
--
--     -- Aufrufe von AP um Seiten zu erstellen
--
--     Cutscene.Starting = function(_Data)
--         -- Mach was tolles hier wenn es anfängt.
--     end
--     Cutscene.Finished = function(_Data)
--         -- Mach was tolles hier wenn es endet.
--     end
--     API.StartCutscene(Cutscene, _Name, _PlayerID);
-- end
--
function API.StartCutscene(_Cutscene, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Cutscene) ~= "table" then
        error("API.StartCutscene (" .._Name.. "): _Cutscene must be a table!");
        return;
    end
    if #_Cutscene == 0 then
        error("API.StartCutscene (" .._Name.. "): _Cutscene does not contain pages!");
        return;
    end
    for i=1, #_Cutscene do
        if not _Cutscene[i].__Legit then
            error("API.StartCutscene (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Cutscene.EnableSky == nil then
        _Cutscene.EnableSky = true;
    end
    if _Cutscene.EnableFoW == nil then
        _Cutscene.EnableFoW = false;
    end
    if _Cutscene.EnableGlobalImmortality == nil then
        _Cutscene.EnableGlobalImmortality = true;
    end
    if _Cutscene.EnableBorderPins == nil then
        _Cutscene.EnableBorderPins = false;
    end
    ModuleCutsceneSystem.Global:StartCutscene(_Name, PlayerID, _Cutscene);
end

---
-- Prüft ob für den Spieler gerade eine Cutscene aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Cutscene ist aktiv
-- @within Anwenderfunktionen
--
function API.IsCutsceneActive(_PlayerID)
    if Revision.Environment == QSB.Environment.GLOBAL then
        return ModuleCutsceneSystem.Global:GetCurrentCutscene(_PlayerID) ~= nil;
    end
    return ModuleCutsceneSystem.Local:GetCurrentCutscene(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktion zur Erstellung von Flights in einer Cutscene. Diese
-- Funktion muss vor dem Start einer Cutscene aufgerufen werden, damit Seiten
-- gebunden werden können.
--
-- @param[type=table] _Cutscene Cutscene Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @within Anwenderfunktionen
--
-- @usage
-- local AP = API.AddCutscenePages(Cutscene);
--
function API.AddCutscenePages(_Cutscene)
    ModuleCutsceneSystem.Global:CreateCutsceneGetPage(_Cutscene);
    ModuleCutsceneSystem.Global:CreateCutsceneAddPage(_Cutscene);

    local AP = function(_Page)
        return _Cutscene:AddPage(_Page);
    end
    return AP;
end

---
-- Erzeugt einen neuen Flight für die Cutscene.
--
-- <p>(→ Beispiel #1)</p>
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddCutscenePages">API.AddCutscenePages</a> erzeugt und an
-- die Cutscene gebunden.
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Flight</td>
-- <td>string</td>
-- <td>Name der CS-Datei ohne Dateiendung</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der Titel, der oben angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der Text, der unten angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die ausgeführt wird, sobald der Flight
-- angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>FarClipPlane</td>
-- <td>number</td>
-- <td>(Optional) Renderdistanz für die Seite (Default 35000).
-- wird.</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn des Flight.</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Abblendens zu Schwarz am Ende des Flight.</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>number</td>
-- <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
-- wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
-- der nächsten mit Fade In muss immer eine Seite mit FaderAlpha sein!</b></td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Die Fast Forward Aktion wird unterbunden. Außerdem wird die Beschleunigung automatisch aufgehoben.</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</td>
-- </tr>
-- <tr>
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- </table>
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AF {
--     -- Dateiname der Cutscene ohne .cs
--     Flight       = "c02",
--     -- Maximale Renderdistanz
--     FarClipPlane = 45000,
--     -- Text
--     Title        = "Title",
--     Text         = "Text of the flight.",
-- };
--
-- @within Cutscene
--
function AP(_Data)
    assert(false);
end

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Fügt Behavior zur Steuerung von Cutscenes hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Cutscene.
--
-- Jede Cutscene braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Cutscene
-- @param[type=string] _Cutscene Funktionsname als String
-- @within Reprisal
--
function Reprisal_Cutscene(...)
    return B_Reprisal_Cutscene:new(...);
end

B_Reprisal_Cutscene = {
    Name = "Reprisal_Cutscene",
    Description = {
        en = "Reprisal: Calls a function to start an new Cutscene.",
        de = "Vergeltung: Ruft die Funktion auf und startet die enthaltene Cutscene.",
        fr = "Rétribution : Appelle la fonction et démarre la cutscene contenue.",
    },
    Parameter = {
        { ParameterType.Default, en = "Cutscene name",     de = "Name der Cutscene",     fr = "Nom de la cutscene", },
        { ParameterType.Default, en = "Cutscene function", de = "Funktion mit Cutscene", fr = "Fonction avec cutscene", },
    },
}

function B_Reprisal_Cutscene:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} }
end

function B_Reprisal_Cutscene:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.CutsceneName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Cutscene:CustomFunction(_Quest)
    _G[self.Function](self.CutsceneName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Cutscene:Debug(_Quest)
    if self.CutsceneName == nil or self.CutsceneName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Reprisal_Cutscene);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Cutscene.
--
-- Jede Cutscene braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Cutscene
-- @param[type=string] _Cutscene Funktionsname als String
-- @within Reward
--
function Reward_Cutscene(...)
    return B_Reward_Cutscene:new(...);
end

B_Reward_Cutscene = Revision.LuaBase:CopyTable(B_Reprisal_Cutscene);
B_Reward_Cutscene.Name = "Reward_Cutscene";
B_Reward_Cutscene.Description.en = "Reward: Calls a function to start an new Cutscene.";
B_Reward_Cutscene.Description.de = "Lohn: Ruft die Funktion auf und startet die enthaltene Cutscene.";
B_Reward_Cutscene.Description.fr = "Récompense: Appelle la fonction et démarre la cutscene contenue.";
B_Reward_Cutscene.GetReprisalTable = nil;

B_Reward_Cutscene.GetRewardTable = function(self, _Quest)
    return { Reward.Custom, {self, self.CustomFunction} }
end

Revision:RegisterBehavior(B_Reward_Cutscene);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Cutscene beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Cutscene
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Cutscene(...)
    return B_Trigger_Cutscene:new(...);
end

B_Trigger_Cutscene = {
    Name = "Trigger_Cutscene",
    Description = {
        en = "Trigger: Checks if an Cutscene has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob eine Cutscene beendet ist und startet dann den Quest.",
        fr = "Déclencheur: Vérifie si une cutscene est terminée et démarre ensuite la quête.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Cutscene name", de = "Name der Cutscene", fr  ="Nom de la cutscene" },
        { ParameterType.PlayerID, en = "Player ID",     de = "Player ID",         fr  ="Player ID" },
        { ParameterType.Number,   en = "Wait time",     de = "Wartezeit",         fr  ="Temps d'attente" },
    },
}

function B_Trigger_Cutscene:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Cutscene:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.CutsceneName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Cutscene:CustomFunction(_Quest)
    if API.GetCinematicEventStatus(self.CutsceneName, self.PlayerID) == CinematicEvent.Concluded then
        if self.WaitTime and self.WaitTime > 0 then
            self.WaitTimeTimer = self.WaitTimeTimer or Logic.GetTime();
            if Logic.GetTime() >= self.WaitTimeTimer + self.WaitTime then
                return true;
            end
        else
            return true;
        end
    end
    return false;
end

function B_Trigger_Cutscene:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.CutsceneName == nil or self.CutsceneName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Trigger_Cutscene);

