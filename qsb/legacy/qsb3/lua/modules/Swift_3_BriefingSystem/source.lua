--[[
Swift_3_BriefingSystem/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleBriefingSystem = {
    Properties = {
        Name = "ModuleBriefingSystem",
    },

    Global = {
        Briefing = {},
        BriefingQueue = {},
        BriefingCounter = 0,
    },
    Local = {
        ParallaxWidgets = {
            {"/EndScreen/EndScreen/BackGround", "/EndScreen/EndScreen"},
            {"/InGame/Root/BlackStartScreen/BG", "/InGame/Root/BlackStartScreen"},
            {"/InGame/Root/EndScreen/BlackBG", "/InGame/Root/EndScreen"},
            {"/InGame/Root/EndScreen/BG", "/InGame/Root/EndScreen"},
        },
        Briefing = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            NextButton = {de = "Weiter",  en = "Forward",  fr = "Continuer"},
            PrevButton = {de = "Zurück",  en = "Previous", fr = "Retour"},
            EndButton  = {de = "Beenden", en = "Close",    fr = "Quitter"},
        },
    },
};

QSB.CinematicEventTypes.Briefing = 2;

QSB.Briefing = {
    TIMER_PER_CHAR = 0.175,
    CAMERA_ANGLEDEFAULT = 43,
    CAMERA_ROTATIONDEFAULT = -45,
    CAMERA_ZOOMDEFAULT = 6500,
    CAMERA_FOVDEFAULT = 42,
    DLGCAMERA_ANGLEDEFAULT = 27,
    DLGCAMERA_ROTATIONDEFAULT = -45,
    DLGCAMERA_ZOOMDEFAULT = 1750,
    DLGCAMERA_FOVDEFAULT = 25,
};

-- Global ------------------------------------------------------------------- --

function ModuleBriefingSystem.Global:OnGameStart()
    QSB.ScriptEvents.BriefingStarted = API.RegisterScriptEvent("Event_BriefingStarted");
    QSB.ScriptEvents.BriefingEnded = API.RegisterScriptEvent("Event_BriefingEnded");
    QSB.ScriptEvents.BriefingPageShown = API.RegisterScriptEvent("Event_BriefingPageShown");
    QSB.ScriptEvents.BriefingOptionSelected = API.RegisterScriptEvent("Event_BriefingOptionSelected");
    QSB.ScriptEvents.BriefingLeftClick = API.RegisterScriptEvent("Event_BriefingLeftClick");
    QSB.ScriptEvents.BriefingSkipButtonPressed = API.RegisterScriptEvent("Event_BriefingSkipButtonPressed");
    
    for i= 1, 8 do
        self.BriefingQueue[i] = {};
    end
    -- Updates the dialog queue for all players
    API.StartHiResJob(function()
        ModuleBriefingSystem.Global:UpdateQueue();
        ModuleBriefingSystem.Global:BriefingExecutionController();
    end);
end

function ModuleBriefingSystem.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EscapePressed then
        -- TODO fix problem with throneroom
    elseif _ID == QSB.ScriptEvents.BriefingStarted then
        self:NextPage(arg[1]);
    elseif _ID == QSB.ScriptEvents.BriefingEnded then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.BriefingEnded, %d, %s)]],
            arg[1],
            table.tostring(arg[2])
        ));
    elseif _ID == QSB.ScriptEvents.BriefingPageShown then
        local Page = self.Briefing[arg[1]][arg[2]];
        if type(Page) == "table" then
            Page = table.tostring(Page);
        end
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.BriefingPageShown, %d, %d, %s)]],
            arg[1],
            arg[2],
            Page
        ));
    elseif _ID == QSB.ScriptEvents.BriefingOptionSelected then
        self:OnOptionSelected(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.BriefingSkipButtonPressed then
        self:SkipButtonPressed(arg[1]);
    end
end

function ModuleBriefingSystem.Global:UpdateQueue()
    for i= 1, 8 do
        if self:CanStartBriefing(i) then
            local Next = ModuleDisplayCore.Global:LookUpCinematicInFromQueue(i);
            if Next and Next[1] == QSB.CinematicEventTypes.Briefing then
                self:NextBriefing(i);
            end
        end
    end
end

function ModuleBriefingSystem.Global:BriefingExecutionController()
    for i= 1, 8 do
        if self.Briefing[i] and not self.Briefing[i].DisplayIngameCutscene then
            local PageID = self.Briefing[i].CurrentPage;
            local Page = self.Briefing[i][PageID];
            -- Auto Skip
            if Page and not Page.MC and Page.Duration > 0 then
                if (Page.Started + Page.Duration) < Logic.GetTime() then
                    self:NextPage(i);
                end
            end
        end
    end
end

function ModuleBriefingSystem.Global:StartBriefing(_Name, _PlayerID, _Data)
    self.BriefingQueue[_PlayerID] = self.BriefingQueue[_PlayerID] or {};
    ModuleDisplayCore.Global:PushCinematicEventToQueue(
        _PlayerID,
        QSB.CinematicEventTypes.Briefing,
        _Name,
        _Data
    );
end

function ModuleBriefingSystem.Global:EndBriefing(_PlayerID)
    Logic.SetGlobalInvulnerability(0);
    API.SendScriptEvent(
        QSB.ScriptEvents.BriefingEnded,
        _PlayerID,
        self.Briefing[_PlayerID]
    );
    if self.Briefing[_PlayerID].Finished then
        self.Briefing[_PlayerID]:Finished();
    end
    API.FinishCinematicEvent(self.Briefing[_PlayerID].Name, _PlayerID);
    self.Briefing[_PlayerID] = nil;
end

function ModuleBriefingSystem.Global:NextBriefing(_PlayerID)
    if self:CanStartBriefing(_PlayerID) then
        local BriefingData = ModuleDisplayCore.Global:PopCinematicEventFromQueue(_PlayerID);
        assert(BriefingData[1] == QSB.CinematicEventTypes.Briefing);
        API.StartCinematicEvent(BriefingData[2], _PlayerID);

        local Briefing = BriefingData[3];
        Briefing.Name = BriefingData[2];
        Briefing.PlayerID = _PlayerID;
        Briefing.CurrentPage = 0;
        self.Briefing[_PlayerID] = Briefing;
        self:TransformAnimations(_PlayerID);
        self:TransformParallax(_PlayerID);

        if Briefing.EnableGlobalImmortality then
            Logic.SetGlobalInvulnerability(1);
        end
        if self.Briefing[_PlayerID].Starting then
            self.Briefing[_PlayerID]:Starting();
        end

        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.BriefingStarted, %d, %s)]],
            _PlayerID,
            table.tostring(self.Briefing[_PlayerID])
        ));
        API.SendScriptEvent(
            QSB.ScriptEvents.BriefingStarted,
            _PlayerID,
            self.Briefing[_PlayerID]
        );
    end
end

function ModuleBriefingSystem.Global:TransformAnimations(_PlayerID)
    if self.Briefing[_PlayerID].PageAnimations then
        for k, v in pairs(self.Briefing[_PlayerID].PageAnimations) do
            local PageID = self:GetPageIDByName(_PlayerID, k);
            if PageID ~= 0 then
                self.Briefing[_PlayerID][PageID].Animations = {};
                self.Briefing[_PlayerID][PageID].Animations.PurgeOld = v.PurgeOld == true;
                for i= 1, #v, 1 do
                    -- Relaive position
                    if type(v[i][3]) == "number" then
                        local Entry = {};
                        Entry.Interpolation = v[i].Interpolation;
                        Entry.Repeat = v[i].Repeat == true;
                        Entry.Duration = v[i][1] or (2 * 60);
                        Entry.Start = {
                            Position = (type(v[i][2]) ~= "table" and {v[i][2],0}) or v[i][2],
                            Rotation = v[i][3] or -45,
                            Zoom     = v[i][4] or 9000,
                            Angle    = v[i][5] or 47,
                        };
                        local EndPosition = v[i][6] or Entry.Start.Position;
                        Entry.End = {
                            Position = (type(EndPosition) ~= "table" and {EndPosition,0}) or EndPosition,
                            Rotation = v[i][7] or Entry.Start.Rotation,
                            Zoom     = v[i][8] or Entry.Start.Zoom,
                            Angle    = v[i][9] or Entry.Start.Angle,
                        };
                        table.insert(self.Briefing[_PlayerID][PageID].Animations, Entry);
                    -- Vector
                    elseif type(v[i][3]) == "table" then
                        local Entry = {};
                        Entry.Interpolation = v[i].Interpolation;
                        Entry.Repeat = v[i].Repeat == true;
                        Entry.Duration = v[i][1] or (2 * 60);
                        Entry.Start = {
                            Position = (type(v[i][2]) ~= "table" and {v[i][2],0}) or v[i][2],
                            LookAt   = (type(v[i][3]) ~= "table" and {v[i][3],0}) or v[i][3],
                        };
                        local EndPosition = v[i][4] or Entry.Start.Position;
                        local EndLookAt   = v[i][5] or Entry.Start.LookAt;
                        Entry.End = {
                            Position = (type(EndPosition) ~= "table" and {EndPosition,0}) or EndPosition,
                            LookAt   = (type(EndLookAt) ~= "table" and {EndLookAt,0}) or EndLookAt,
                        };
                        table.insert(self.Briefing[_PlayerID][PageID].Animations, Entry);
                    end
                end
            end
        end
        self.Briefing[_PlayerID].PageAnimations = nil;
    end
end

function ModuleBriefingSystem.Global:TransformParallax(_PlayerID)
    if self.Briefing[_PlayerID].PageParallax then
        for k, v in pairs(self.Briefing[_PlayerID].PageParallax) do
            local PageID = self:GetPageIDByName(_PlayerID, k);
            if PageID ~= 0 then
                self.Briefing[_PlayerID][PageID].Parallax = {};
                self.Briefing[_PlayerID][PageID].Parallax.PurgeOld = v.PurgeOld == true;
                for i= 1, 4, 1 do
                    if v[i] then
                        local Entry = {};
                        Entry.Image = v[i][1];
                        Entry.Interpolation = v[i].Interpolation;
                        Entry.Duration = v[i][2] or (2 * 60);
                        Entry.Repeat = v[i].Repeat == true;
                        Entry.Start = {
                            U0 = v[i][3] or 0,
                            V0 = v[i][4] or 0,
                            U1 = v[i][5] or 1,
                            V1 = v[i][6] or 1,
                            A  = v[i][7] or 255
                        };
                        Entry.End = {
                            U0 = v[i][8] or Entry.Start.U0,
                            V0 = v[i][9] or Entry.Start.V0,
                            U1 = v[i][10] or Entry.Start.U1,
                            V1 = v[i][11] or Entry.Start.V1,
                            A  = v[i][12] or Entry.Start.A
                        };
                        self.Briefing[_PlayerID][PageID].Parallax[i] = Entry;
                    end
                end
            end
        end
        self.Briefing[_PlayerID].PageParallax = nil;
    end
end

function ModuleBriefingSystem.Global:NextPage(_PlayerID)
    if self.Briefing[_PlayerID] == nil then
        return;
    end

    self.Briefing[_PlayerID].CurrentPage = self.Briefing[_PlayerID].CurrentPage +1;
    local PageID = self.Briefing[_PlayerID].CurrentPage;
    if PageID == -1 or PageID == 0 then
        self:EndBriefing(_PlayerID);
        return;
    end

    local Page = self.Briefing[_PlayerID][PageID];
    if type(Page) == "table" then
        if PageID <= #self.Briefing[_PlayerID] then
            self.Briefing[_PlayerID][PageID].Started = Logic.GetTime();
            self.Briefing[_PlayerID][PageID].Duration = Page.Duration or -1;
            if self.Briefing[_PlayerID][PageID].Action then
                self.Briefing[_PlayerID][PageID]:Action();
            end
            self:DisplayPage(_PlayerID, PageID);
        else
            self:EndBriefing(_PlayerID);
        end
    elseif type(Page) == "number" or type(Page) == "string" then
        local Target = self:GetPageIDByName(_PlayerID, self.Briefing[_PlayerID][PageID]);
        self.Briefing[_PlayerID].CurrentPage = Target -1;
        self:NextPage(_PlayerID);
    else
        self:EndBriefing(_PlayerID);
    end
end

function ModuleBriefingSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Briefing[_PlayerID] == nil then
        return;
    end

    local Page = self.Briefing[_PlayerID][_PageID];
    if type(Page) == "table" then
        local PageID = self.Briefing[_PlayerID].CurrentPage;
        if Page.MC then
            for i= 1, #Page.MC, 1 do
                if type(Page.MC[i][3]) == "function" then
                    self.Briefing[_PlayerID][PageID].MC[i].Visible = Page.MC[i][3](_PlayerID, PageID, i);
                end
            end
        end
    end

    API.SendScriptEvent(
        QSB.ScriptEvents.BriefingPageShown,
        _PlayerID,
        _PageID,
        self.Briefing[_PlayerID][_PageID]
    );
end

function ModuleBriefingSystem.Global:SkipButtonPressed(_PlayerID, _PageID)
    if not self.Briefing[_PlayerID] then
        return;
    end
    local PageID = self.Briefing[_PlayerID].CurrentPage;
    if self.Briefing[_PlayerID][PageID].OnForward then
        self.Briefing[_PlayerID][PageID]:OnForward();
    end
    self:NextPage(_PlayerID);
end

function ModuleBriefingSystem.Global:OnOptionSelected(_PlayerID, _OptionID)
    if self.Briefing[_PlayerID] == nil then
        return;
    end
    local PageID = self.Briefing[_PlayerID].CurrentPage;
    if type(self.Briefing[_PlayerID][PageID]) ~= "table" then
        return;
    end
    local Page = self.Briefing[_PlayerID][PageID];
    if Page.MC then
        local Option;
        for i= 1, #Page.MC, 1 do
            if Page.MC[i].ID == _OptionID then
                Option = Page.MC[i];
            end
        end
        if Option ~= nil then
            local Target = Option[2];
            if type(Option[2]) == "function" then
                Target = Option[2](_PlayerID, PageID, _OptionID);
            end
            self.Briefing[_PlayerID][PageID].MC.Selected = Option.ID;
            self.Briefing[_PlayerID].CurrentPage = self:GetPageIDByName(_PlayerID, Target) -1;
            self:NextPage(_PlayerID);
        end
    end
end

function ModuleBriefingSystem.Global:GetCurrentBriefing(_PlayerID)
    return self.Briefing[_PlayerID];
end

function ModuleBriefingSystem.Global:GetCurrentBriefingPage(_PlayerID)
    if self.Briefing[_PlayerID] then
        local PageID = self.Briefing[_PlayerID].CurrentPage;
        return self.Briefing[_PlayerID][PageID];
    end
end

function ModuleBriefingSystem.Global:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Briefing[_PlayerID] ~= nil then
            for i= 1, #self.Briefing[_PlayerID], 1 do
                if type(self.Briefing[_PlayerID][i]) == "table" and self.Briefing[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleBriefingSystem.Global:CanStartBriefing(_PlayerID)
    return  self.Briefing[_PlayerID] == nil and
            not API.IsCinematicEventActive(_PlayerID) and
            not API.IsLoadscreenVisible();
end

-- Local -------------------------------------------------------------------- --

function ModuleBriefingSystem.Local:OnGameStart()
    QSB.ScriptEvents.BriefingStarted = API.RegisterScriptEvent("Event_BriefingStarted");
    QSB.ScriptEvents.BriefingEnded = API.RegisterScriptEvent("Event_BriefingEnded");
    QSB.ScriptEvents.BriefingPageShown = API.RegisterScriptEvent("Event_BriefingPageShown");
    QSB.ScriptEvents.BriefingOptionSelected = API.RegisterScriptEvent("Event_BriefingOptionSelected");
    QSB.ScriptEvents.BriefingLeftClick = API.RegisterScriptEvent("Event_BriefingLeftClick");
    QSB.ScriptEvents.BriefingSkipButtonPressed = API.RegisterScriptEvent("Event_BriefingSkipButtonPressed");

    self:OverrideThroneRoomFunctions();
end

function ModuleBriefingSystem.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.EscapePressed then
        -- TODO fix problem with throneroom
    elseif _ID == QSB.ScriptEvents.BriefingStarted then
        self:StartBriefing(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.BriefingEnded then
        self:EndBriefing(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.BriefingPageShown then
        self:DisplayPage(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.BriefingSkipButtonPressed then
        self:SkipButtonPressed(arg[1]);
    end
end

function ModuleBriefingSystem.Local:StartBriefing(_PlayerID, _Briefing)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Briefing[_PlayerID] = _Briefing;
    self.Briefing[_PlayerID].LastSkipButtonPressed = 0;
    self.Briefing[_PlayerID].CurrentPage = 0;
    local PosX, PosY = Camera.RTS_GetLookAtPosition();
    local Rotation = Camera.RTS_GetRotationAngle();
    local ZoomFactor = Camera.RTS_GetZoomFactor();
    local SpeedFactor = Game.GameTimeGetFactor(_PlayerID);
    self.Briefing[_PlayerID].Backup = {
        Camera = {PosX, PosY, Rotation, ZoomFactor},
        Speed  = SpeedFactor,
    };

    API.DeactivateNormalInterface(_PlayerID);
    API.DeactivateBorderScroll(_PlayerID);

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:ActivateCinematicMode(_PlayerID);
end

function ModuleBriefingSystem.Local:EndBriefing(_PlayerID, _Briefing)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    if self.Briefing[_PlayerID].RestoreGameSpeed and not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, self.Briefing[_PlayerID].Backup.Speed);
    end
    if self.Briefing[_PlayerID].RestoreCamera then
        Camera.RTS_SetLookAtPosition(self.Briefing[_PlayerID].Backup.Camera[1], self.Briefing[_PlayerID].Backup.Camera[2]);
        Camera.RTS_SetRotationAngle(self.Briefing[_PlayerID].Backup.Camera[3]);
        Camera.RTS_SetZoomFactor(self.Briefing[_PlayerID].Backup.Camera[4]);
    end

    self:DeactivateCinematicMode(_PlayerID);
    API.ActivateNormalInterface(_PlayerID);
    API.ActivateBorderScroll(_PlayerID);

    self.Briefing[_PlayerID] = nil;
    Display.SetRenderFogOfWar(1);
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);
end

function ModuleBriefingSystem.Local:DisplayPage(_PlayerID, _PageID, _PageData)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Briefing[_PlayerID][_PageID] = _PageData;
    self.Briefing[_PlayerID].AnimationQueue = self.Briefing[_PlayerID].AnimationQueue or {};
    self.Briefing[_PlayerID].ParallaxLayers = self.Briefing[_PlayerID].ParallaxLayers or {};
    self.Briefing[_PlayerID].CurrentPage = _PageID;
    if type(self.Briefing[_PlayerID][_PageID]) == "table" then
        self.Briefing[_PlayerID][_PageID].Started = Logic.GetTime();
        self:SetPageFarClipPlane(_PlayerID, _PageID);
        self:DisplayPageBars(_PlayerID, _PageID);
        self:DisplayPageTitle(_PlayerID, _PageID);
        self:DisplayPageText(_PlayerID, _PageID);
        self:DisplayPageControls(_PlayerID, _PageID);
        self:DisplayPageAnimations(_PlayerID, _PageID);
        self:DisplayPageFader(_PlayerID, _PageID);
        self:DisplayPageParallaxes(_PlayerID, _PageID);
        if self.Briefing[_PlayerID][_PageID].MC then
            self:DisplayPageOptionsDialog(_PlayerID, _PageID);
        end
    end
end

function ModuleBriefingSystem.Local:SetPageFarClipPlane(_PlayerID, _PageID)
    ModuleDisplayCore.Local:ResetFarClipPlane();
    local Page = self.Briefing[_PlayerID][_PageID];
    if Page.FarClipPlane then
        ModuleDisplayCore.Local:SetFarClipPlane(Page.FarClipPlane);
    end
end

function ModuleBriefingSystem.Local:DisplayPageBars(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    local Opacity = (Page.BarOpacity ~= nil and Page.BarOpacity) or 1;
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

function ModuleBriefingSystem.Local:DisplayPageTitle(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
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

function ModuleBriefingSystem.Local:DisplayPageText(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    local TextWidget = "/InGame/ThroneRoom/Main/MissionBriefing/Text";
    XGUIEng.SetText(TextWidget, "");
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

function ModuleBriefingSystem.Local:DisplayPageControls(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    local SkipFlag = 1;

    SkipFlag = ((Page.Duration == nil or Page.Duration == -1) and 1) or 0;
    if Page.DisableSkipping ~= nil then
        SkipFlag = (Page.DisableSkipping and 0) or 1;
    end
    if Page.MC ~= nil then
        SkipFlag = 0;
    end
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", SkipFlag);
end

function ModuleBriefingSystem.Local:DisplayPageAnimations(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    if Page.Animations then
        if Page.Animations.PurgeOld then
            self.Briefing[_PlayerID].CurrentAnimation = nil;
            self.Briefing[_PlayerID].AnimationQueue = {};
        end
        for i= 1, #Page.Animations, 1 do
            local Animation = table.copy(Page.Animations[i]);
            table.insert(self.Briefing[_PlayerID].AnimationQueue, Animation);
        end
    end
end

function ModuleBriefingSystem.Local:DisplayPageFader(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    g_Fade.To = Page.FaderAlpha or 0;

    local PageFadeIn = Page.FadeIn;
    if PageFadeIn then
        FadeIn(PageFadeIn);
    end

    local PageFadeOut = Page.FadeOut;
    if PageFadeOut then
        -- FIXME: This would create jobs that are only be paused at the end!
        self.Briefing[_PlayerID].FaderJob = API.StartHiResJob(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                FadeOut(_FadeOut);
                return true;
            end
        end, Logic.GetTimeMs() + ((Page.Duration or 0) * 1000), PageFadeOut);
    end
end

function ModuleBriefingSystem.Local:DisplayPageParallaxes(_PlayerID, _PageID)
    local Page = self.Briefing[_PlayerID][_PageID];
    if Page.Parallax then
        if Page.Parallax.PurgeOld then
            for i= 1, #self.ParallaxWidgets do
                XGUIEng.SetMaterialTexture(self.ParallaxWidgets[i][1], 1, "");
                XGUIEng.SetMaterialColor(self.ParallaxWidgets[i][1], 1, 255, 255, 255, 0);
            end
            self.Briefing[_PlayerID].ParallaxLayers = {};
        end
        for i= 1, 4, 1 do
            if Page.Parallax[i] then
                local Animation = table.copy(Page.Parallax[i]);
                Animation.Started = XGUIEng.GetSystemTime();
                self.Briefing[_PlayerID].ParallaxLayers[i] = Animation;
            end
        end
    end
end

function ModuleBriefingSystem.Local:ControlParallaxes(_PlayerID)
    if self.Briefing[_PlayerID].ParallaxLayers then
        local CurrentTime = XGUIEng.GetSystemTime();
        for k, v in pairs(self.Briefing[_PlayerID].ParallaxLayers) do
            local Widget = self.ParallaxWidgets[k][1];
            local Size = {GUI.GetScreenSize()};
            local Factor = math.min(math.lerp(v.Started, CurrentTime, v.Duration), 1);
            if v.Interpolation then
                Factor = v:Interpolation(CurrentTime);
            end
            if v.Repeat then
                self.Briefing[_PlayerID].ParallaxLayers[k].Started = CurrentTime;
            end
            local Alpha = v.Start.A + (v.End.A - v.Start.A) * Factor;
            local u0 = v.Start.U0 + (v.End.U0 - v.Start.U0) * Factor;
            local v0 = v.Start.V0 + (v.End.V0 - v.Start.V0) * Factor;
            local u1 = v.Start.U1 + (v.End.U1 - v.Start.U1) * Factor;
            local v1 = v.Start.U1 + (v.End.U1 - v.Start.U1) * Factor;
            if Size[1]/Size[2] < 1.6 then
                u0 = u0 + (u0 / 0.125);
                u1 = u1 - (u1 * 0.125);
            end
            XGUIEng.SetMaterialAlpha(Widget, 1, Alpha or 255);
            XGUIEng.SetMaterialTexture(Widget, 1, v.Image);
            XGUIEng.SetMaterialUV(Widget, 1, u0, v0, u1, v1);
        end
    end
end

function ModuleBriefingSystem.Local:DisplayPageOptionsDialog(_PlayerID, _PageID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Screen = {GUI.GetScreenSize()};
    local Page = self.Briefing[_PlayerID][_PageID];
    local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");

    self.Briefing[_PlayerID].MCSelectionBoxPosition = {
        XGUIEng.GetWidgetScreenPosition(Widget)
    };

    XGUIEng.ListBoxPopAll(Listbox);
    self.Briefing[_PlayerID].MCSelectionOptionsMap = {};
    for i=1, #Page.MC, 1 do
        if Page.MC[i].Visible ~= false then
            XGUIEng.ListBoxPushItem(Listbox, Page.MC[i][1]);
            table.insert(self.Briefing[_PlayerID].MCSelectionOptionsMap, Page.MC[i].ID);
        end
    end
    XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

    local wSize = {XGUIEng.GetWidgetScreenSize(Widget)};
    local xFix = math.ceil((Screen[1] /2) - (wSize[1] /2));
    local yFix = math.ceil(Screen[2] - (wSize[2] -10));
    if Page.Text and Page.Text ~= "" then
        yFix = math.ceil((Screen[2] /2) - (wSize[2] /2));
    end
    XGUIEng.SetWidgetScreenPosition(Widget, xFix, yFix);
    XGUIEng.PushPage(Widget, false);
    XGUIEng.ShowWidget(Widget, 1);
    self.Briefing[_PlayerID].MCSelectionIsShown = true;
end

function ModuleBriefingSystem.Local:OnOptionSelected(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Position = self.Briefing[_PlayerID].MCSelectionBoxPosition;
    XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
    XGUIEng.ShowWidget(Widget, 0);
    XGUIEng.PopPage();

    local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
    local AnswerID = self.Briefing[_PlayerID].MCSelectionOptionsMap[Selected];

    API.SendScriptEvent(QSB.ScriptEvents.BriefingOptionSelected, _PlayerID, AnswerID);
    API.BroadcastScriptEventToGlobal(
        QSB.ScriptEvents.BriefingOptionSelected,
        _PlayerID,
        AnswerID
    );
end

function ModuleBriefingSystem.Local:ThroneRoomCameraControl(_PlayerID, _Page)
    if _Page then
        -- Camera
        self:ControlCameraAnimation(_PlayerID);
        local PX, PY, PZ = self:GetPagePosition(_PlayerID);
        local LX, LY, LZ = self:GetPageLookAt(_PlayerID);
        if PX and not LX then
            LX, LY, LZ, PX, PY, PZ, FOV = self:GetCameraProperties(_PlayerID);
        end
        Camera.ThroneRoom_SetPosition(PX, PY, PZ);
        Camera.ThroneRoom_SetLookAt(LX, LY, LZ);
        Camera.ThroneRoom_SetFOV(FOV);

        -- Parallax
        self:ControlParallaxes(_PlayerID);

        -- Multiple Choice
        if self.Briefing[_PlayerID].MCSelectionIsShown then
            local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
            if XGUIEng.IsWidgetShown(Widget) == 0 then
                self.Briefing[_PlayerID].MCSelectionIsShown = false;
                self:OnOptionSelected(_PlayerID);
            end
        end

        -- Button texts
        local SkipText = API.Localize(ModuleBriefingSystem.Shared.Text.NextButton);
        local PageID = self.Briefing[_PlayerID].CurrentPage;
        if PageID == #self.Briefing[_PlayerID] or self.Briefing[_PlayerID][PageID+1] == -1 then
            SkipText = API.Localize(ModuleBriefingSystem.Shared.Text.EndButton);
        end
        XGUIEng.SetText("/InGame/ThroneRoom/Main/Skip", "{center}" ..SkipText);
    end
end

function ModuleBriefingSystem.Local:ControlCameraAnimation(_PlayerID)
    if self.Briefing[_PlayerID].CurrentAnimation then
        local CurrentTime = XGUIEng.GetSystemTime();
        local Animation = self.Briefing[_PlayerID].CurrentAnimation;
        if CurrentTime > Animation.Started + Animation.Duration then
            if not self.Briefing[_PlayerID].CurrentAnimation.Repeat then
                if #self.Briefing[_PlayerID].AnimationQueue > 0 then
                    self.Briefing[_PlayerID].CurrentAnimation = nil;
                end
            else
                self.Briefing[_PlayerID].CurrentAnimation.Started = CurrentTime;
            end
        end
    end
    if self.Briefing[_PlayerID].CurrentAnimation == nil then
        if self.Briefing[_PlayerID].AnimationQueue and #self.Briefing[_PlayerID].AnimationQueue > 0 then
            local Next = table.remove(self.Briefing[_PlayerID].AnimationQueue, 1);
            Next.Started = XGUIEng.GetSystemTime();
            self.Briefing[_PlayerID].CurrentAnimation = Next;
        end
    end
end

function ModuleBriefingSystem.Local:GetPagePosition(_PlayerID)
    local Position, FlyTo;
    if self.Briefing[_PlayerID].CurrentAnimation then
        Position = self.Briefing[_PlayerID].CurrentAnimation.Start.Position;
        FlyTo = self.Briefing[_PlayerID].CurrentAnimation.End;
    end

    local x, y, z = self:ConvertPosition(Position);
    if FlyTo then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.Position);
        if lX then
            x = x + (lX - x) * self:GetInterpolationFactor(_PlayerID);
            y = y + (lY - y) * self:GetInterpolationFactor(_PlayerID);
            z = z + (lZ - z) * self:GetInterpolationFactor(_PlayerID);
        end
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:GetPageLookAt(_PlayerID)
    local LookAt, FlyTo;
    if self.Briefing[_PlayerID].CurrentAnimation then
        LookAt = self.Briefing[_PlayerID].CurrentAnimation.Start.LookAt;
        FlyTo = self.Briefing[_PlayerID].CurrentAnimation.End;
    end

    local x, y, z = self:ConvertPosition(LookAt);
    if FlyTo and x then
        local lX, lY, lZ = self:ConvertPosition(FlyTo.LookAt);
        if lX then
            x = x + (lX - x) * self:GetInterpolationFactor(_PlayerID);
            y = y + (lY - y) * self:GetInterpolationFactor(_PlayerID);
            z = z + (lZ - z) * self:GetInterpolationFactor(_PlayerID);
        end
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:GetCameraProperties(_PlayerID)
    local CurrPage, FlyTo;
    if self.Briefing[_PlayerID].CurrentAnimation then
        CurrPage = self.Briefing[_PlayerID].CurrentAnimation.Start;
        FlyTo = self.Briefing[_PlayerID].CurrentAnimation.End;
    end

    local startPosition = CurrPage.Position;
    local endPosition = (FlyTo and FlyTo.Position) or CurrPage.Position;
    local startRotation = CurrPage.Rotation;
    local endRotation = (FlyTo and FlyTo.Rotation) or CurrPage.Rotation;
    local startZoomAngle = CurrPage.Angle;
    local endZoomAngle = (FlyTo and FlyTo.Angle) or CurrPage.Angle;
    local startZoomDistance = CurrPage.Zoom;
    local endZoomDistance = (FlyTo and FlyTo.Zoom) or CurrPage.Zoom;
    local startFOV = (CurrPage.FOV) or 42.0;
    local endFOV = ((FlyTo and FlyTo.FOV) or CurrPage.FOV) or 42.0;

    local factor = self:GetInterpolationFactor(_PlayerID);

    local lPLX, lPLY, lPLZ = self:ConvertPosition(startPosition);
    local cPLX, cPLY, cPLZ = self:ConvertPosition(endPosition);
    local lookAtX = lPLX + (cPLX - lPLX) * factor;
    local lookAtY = lPLY + (cPLY - lPLY) * factor;
    local lookAtZ = lPLZ + (cPLZ - lPLZ) * factor;
    local FOV = startFOV + (endFOV - startFOV) * factor;

    local zoomDistance = startZoomDistance + (endZoomDistance - startZoomDistance) * factor;
    local zoomAngle = startZoomAngle + (endZoomAngle - startZoomAngle) * factor;
    local rotation = startRotation + (endRotation - startRotation) * factor;
    local line = zoomDistance * math.cos(math.rad(zoomAngle));
    local positionX = lookAtX + math.cos(math.rad(rotation - 90)) * line;
    local positionY = lookAtY + math.sin(math.rad(rotation - 90)) * line;
    local positionZ = lookAtZ + (zoomDistance) * math.sin(math.rad(zoomAngle));

    return lookAtX, lookAtY, lookAtZ, positionX, positionY, positionZ, FOV;
end

function ModuleBriefingSystem.Local:ConvertPosition(_Table)
    local x, y, z;
    if _Table and _Table[3] then
        x = _Table[1]; y = _Table[2]; z = _Table[3];
    elseif _Table and not _Table[3] then
        x, y, z = Logic.EntityGetPos(GetID(_Table[1]));
        z = z + (_Table[2] or 0);
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:GetInterpolationFactor(_PlayerID)
    if self.Briefing[_PlayerID].CurrentAnimation then
        local CurrentTime = XGUIEng.GetSystemTime();
        if self.Briefing[_PlayerID].CurrentAnimation.Interpolation then
            return self.Briefing[_PlayerID].CurrentAnimation:Interpolation(CurrentTime);
        end
        local Factor = math.lerp(
            self.Briefing[_PlayerID].CurrentAnimation.Started,
            CurrentTime,
            self.Briefing[_PlayerID].CurrentAnimation.Duration
        );
        return math.min(Factor, 1);
    end
    return 1;
end

function ModuleBriefingSystem.Local:SkipButtonPressed(_PlayerID, _Page)
    if not self.Briefing[_PlayerID] then
        return;
    end
    if (self.Briefing[_PlayerID].LastSkipButtonPressed + 500) < Logic.GetTimeMs() then
        self.Briefing[_PlayerID].LastSkipButtonPressed = Logic.GetTimeMs();
    end
end

function ModuleBriefingSystem.Local:GetCurrentBriefing(_PlayerID)
    return self.Briefing[_PlayerID];
end

function ModuleBriefingSystem.Local:GetCurrentBriefingPage(_PlayerID)
    if self.Briefing[_PlayerID] then
        local PageID = self.Briefing[_PlayerID].CurrentPage;
        return self.Briefing[_PlayerID][PageID];
    end
end

function ModuleBriefingSystem.Local:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Briefing[_PlayerID] ~= nil then
            for i= 1, #self.Briefing[_PlayerID], 1 do
                if type(self.Briefing[_PlayerID][i]) == "table" and self.Briefing[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleBriefingSystem.Local:OverrideThroneRoomFunctions()
    GameCallback_Camera_ThroneRoomLeftClick_Orig_ModuleBriefingSystem = GameCallback_Camera_ThroneRoomLeftClick;
    GameCallback_Camera_ThroneRoomLeftClick = function(_PlayerID)
        GameCallback_Camera_ThroneRoomLeftClick_Orig_ModuleBriefingSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            -- Must trigger in global script for all players.
            API.BroadcastScriptEventToGlobal(
                QSB.ScriptEvents.BriefingLeftClick,
                _PlayerID
            );
            API.SendScriptEvent(QSB.ScriptEvents.BriefingLeftClick, _PlayerID);
        end
    end

    GameCallback_Camera_SkipButtonPressed_Orig_ModuleBriefingSystem = GameCallback_Camera_SkipButtonPressed;
    GameCallback_Camera_SkipButtonPressed = function(_PlayerID)
        GameCallback_Camera_SkipButtonPressed_Orig_ModuleBriefingSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            -- Must trigger in global script for all players.
            API.BroadcastScriptEventToGlobal(
                QSB.ScriptEvents.BriefingSkipButtonPressed,
                _PlayerID
            );
            API.SendScriptEvent(QSB.ScriptEvents.BriefingSkipButtonPressed, _PlayerID);
        end
    end

    GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleBriefingSystem = GameCallback_Camera_ThroneroomCameraControl;
    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
        GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleBriefingSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            local Briefing = ModuleBriefingSystem.Local:GetCurrentBriefing(_PlayerID);
            if Briefing ~= nil then
                ModuleBriefingSystem.Local:ThroneRoomCameraControl(
                    _PlayerID,
                    ModuleBriefingSystem.Local:GetCurrentBriefingPage(_PlayerID)
                );
            end
        end
    end

    GameCallback_Escape_Orig_BriefingSystem = GameCallback_Escape;
    GameCallback_Escape = function()
        if ModuleBriefingSystem.Local.Briefing[GUI.GetPlayerID()] then
            return;
        end
        GameCallback_Escape_Orig_BriefingSystem();
    end
end

function ModuleBriefingSystem.Local:ActivateCinematicMode(_PlayerID)
    if self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = true;

    local LoadScreenVisible = API.IsLoadscreenVisible();
    if LoadScreenVisible then
        XGUIEng.PopPage();
    end
    local ScreenX, ScreenY = GUI.GetScreenSize();

    -- Parallax
    function EndScreen_ExitGame() end
    function MissionFadeInEndScreen() end
    for i= 1, #self.ParallaxWidgets do
        XGUIEng.ShowWidget(self.ParallaxWidgets[i][1], 1);
        XGUIEng.ShowWidget(self.ParallaxWidgets[i][2], 1);
        XGUIEng.PushPage(self.ParallaxWidgets[i][2], false);

        XGUIEng.SetMaterialTexture(self.ParallaxWidgets[i][1], 1, "");
        XGUIEng.SetMaterialColor(self.ParallaxWidgets[i][1], 1, 255, 255, 255, 0);
        XGUIEng.SetMaterialUV(self.ParallaxWidgets[i][1], 1, 0, 0, 1, 1);
    end
    XGUIEng.ShowWidget("/EndScreen/EndScreen/BG", 0);

    -- Throneroom Main
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge", false);
    XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo/LeftFrame", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Title", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/updater", 1);

    -- Text
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives", " ");

    -- Title and back button
    local x,y = XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight");
    XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight", x, 65 * (ScreenY/1080));
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Objectives", 2, 0, 2000, 20);

    -- Briefing messages
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text", 1);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/BG", 0);
    XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text", " ");
    XGUIEng.SetWidgetPositionAndSize("/InGame/ThroneRoom/KnightInfo/Text", 200, 300, 1000, 10);

    self.SelectionBackup = {GUI.GetSelectedEntities()};
    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    if not self.Briefing[_PlayerID].EnableFoW then
        Display.SetRenderFogOfWar(0);
    end
    if self.Briefing[_PlayerID].EnableSky then
        Display.SetRenderSky(1);
    end
    if not self.Briefing[_PlayerID].EnableBorderPins then
        Display.SetRenderBorderPins(0);
    end
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(5);

    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    if LoadScreenVisible then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

function ModuleBriefingSystem.Local:DeactivateCinematicMode(_PlayerID)
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

    XGUIEng.ShowWidget("/EndScreen/EndScreen/BG", 1);
    for i= 1, #self.ParallaxWidgets do
        XGUIEng.ShowWidget(self.ParallaxWidgets[i][1], 0);
        XGUIEng.ShowWidget(self.ParallaxWidgets[i][2], 0);
        XGUIEng.PopPage();
    end
    XGUIEng.PopPage();
    XGUIEng.PopPage();
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

    ModuleDisplayCore.Local:ResetFarClipPlane();
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleBriefingSystem);

