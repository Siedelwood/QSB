--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

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
            -- Can not set UV coordinates for this... :(
            -- {"/EndScreen/EndScreen/BG", "/EndScreen/EndScreen"},
            {"/EndScreen/EndScreen/BackGround", "/EndScreen/EndScreen"},
            -- Can not set UV coordinates for this... :(
            -- {"/InGame/MissionStatistic/BG", "/InGame/MissionStatistic"},
            {"/InGame/Root/EndScreen/BlackBG", "/InGame/Root/EndScreen"},
            {"/InGame/Root/EndScreen/BG", "/InGame/Root/EndScreen"},
            {"/InGame/Root/BlackStartScreen/BG", "/InGame/Root/BlackStartScreen"},
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

function ModuleBriefingSystem.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
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
            local Next = ModuleGuiEffects.Global:LookUpCinematicInQueue(i);
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

function ModuleBriefingSystem.Global:CreateBriefingGetPage(_Briefing)
    _Briefing.GetPage = function(self, _NameOrID)
        local ID = ModuleBriefingSystem.Global:GetPageIDByName(_Briefing.PlayerID, _NameOrID);
        return ModuleBriefingSystem.Global.Briefing[_Briefing.PlayerID][ID];
    end
end

function ModuleBriefingSystem.Global:CreateBriefingAddPage(_Briefing)
    _Briefing.AddPage = function(self, _Page)
        -- Briefing length
        self.Length = (self.Length or 0) +1;
        -- Animations
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};
        -- Parallaxes
        _Briefing.PageParallax = _Briefing.PageParallax or {};

        -- Set page name
        local Identifier = "Page" ..(#self +1);
        if _Page.Name then
            Identifier = _Page.Name;
        else
            _Page.Name = Identifier;
        end

        -- Make page legit
        _Page.__Legit = true;
        -- Language
        _Page.Title = API.Localize(_Page.Title or "");
        _Page.Text = API.Localize(_Page.Text or "");

        -- Bars
        if _Page.BigBars == nil then
            _Page.BigBars = true;
        end

        -- Simple camera animation
        if _Page.Position then
            -- Fill angle
            if not _Page.Angle then
                _Page.Angle = QSB.Briefing.CAMERA_ANGLEDEFAULT;
                if _Page.DialogCamera then
                    _Page.Angle = QSB.Briefing.DLGCAMERA_ANGLEDEFAULT;
                end
            end
            -- Fill rotation
            if not _Page.Rotation then
                _Page.Rotation = QSB.Briefing.CAMERA_ROTATIONDEFAULT;
                if _Page.DialogCamera then
                    _Page.Rotation = QSB.Briefing.DLGCAMERA_ROTATIONDEFAULT;
                end
            end
            -- Fill zoom
            if not _Page.Zoom then
                _Page.Zoom = QSB.Briefing.CAMERA_ZOOMDEFAULT;
                if _Page.DialogCamera then
                    _Page.Zoom = QSB.Briefing.DLGCAMERA_ZOOMDEFAULT;
                end
            end
            -- Optional fly to
            local Position2, Rotation2, Zoom2, Angle2;
            if _Page.FlyTo then
                Position2 = _Page.FlyTo.Position or Position2;
                Rotation2 = _Page.FlyTo.Rotation or Rotation2;
                Zoom2     = _Page.FlyTo.Zoom or Zoom2;
                Angle2    = _Page.FlyTo.Angle or Angle2;
            end
            -- Create the animation
            _Briefing.PageAnimations[Identifier] = {
                Clear = true,
                {_Page.Duration or 1,
                 _Page.Position, _Page.Rotation, _Page.Zoom, _Page.Angle,
                 Position2, Rotation2, Zoom2, Angle2}
            };
        end

        -- Field of View
        if not _Page.FOV then
            if _Page.DialogCamera then
                _Page.FOV = QSB.Briefing.DLGCAMERA_FOVDEFAULT;
            else
                _Page.FOV = QSB.Briefing.CAMERA_FOVDEFAULT;
            end
        end

        -- Display time
        if not _Page.Duration then
            if not _Page.Position then
                _Page.DisableSkipping = false;
                _Page.Duration = -1;
            else
                if _Page.DisableSkipping == nil then
                    _Page.DisableSkipping = false;
                end
                _Page.Duration = _Page.Text:len() * QSB.Briefing.TIMER_PER_CHAR;
                _Page.Duration = (_Page.Duration < 6 and 6) or _Page.Duration < 6;
            end
        end

        -- Multiple choice selection
        _Page.GetSelected = function(self)
            return 0;
        end
        -- Return page
        table.insert(self, _Page);
        return _Page;
    end
end

function ModuleBriefingSystem.Global:CreateBriefingAddMCPage(_Briefing)
    _Briefing.AddMCPage = function(self, _Page)
        -- Create base page
        local Page = self:AddPage(_Briefing);

        -- Multiple choice selection
        Page.GetSelected = function(self)
            if self.MC then
                return self.MC.Selected;
            end
            return 0;
        end

        -- Multiple Choice
        if _Page.MC then
            for i= 1, #_Page.MC do
                _Page.MC[i][1] = API.Localize(_Page.MC[i][1]);
                _Page.MC[i].ID = _Page.MC[i].ID or i;
            end
            _Page.BigBars = true;
            _Page.DisableSkipping = true;
            _Page.Duration = -1;
        end
        -- Return page
        return Page;
    end
end

function ModuleBriefingSystem.Global:CreateBriefingAddRedirect(_Briefing)
    _Briefing.AddRedirect = function(self, _Target)
        -- Dialog length
        self.Length = (self.Length or 0) +1;
        -- Return page
        local Page = (_Target == nil and -1) or _Target;
        table.insert(self, Page);
        return Page;
    end
end

function ModuleBriefingSystem.Global:StartBriefing(_Name, _PlayerID, _Data)
    self.BriefingQueue[_PlayerID] = self.BriefingQueue[_PlayerID] or {};
    ModuleGuiEffects.Global:PushCinematicEventToQueue(
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
        local BriefingData = ModuleGuiEffects.Global:PopCinematicEventFromQueue(_PlayerID);
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

        -- This is an exception from the rule that the global event is send
        -- before the local event! For timing reasons...
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
                self.Briefing[_PlayerID][PageID].Animations.Repeat = v.Repeat == true;
                self.Briefing[_PlayerID][PageID].Animations.Clear = v.Clear == true;
                for i= 1, #v, 1 do
                    -- Relaive position
                    if type(v[i][3]) == "number" then
                        local Entry = {};
                        Entry.Interpolation = v[i].Interpolation;
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
                self.Briefing[_PlayerID][PageID].Parallax.Clear = v.Clear == true;
                for i= 1, 4, 1 do
                    if v[i] then
                        local Entry = {};
                        Entry.Image = v[i][1];
                        Entry.Interpolation = v[i].Interpolation;
                        Entry.Duration = v[i][2] or (2 * 60);
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
            self.LoadscreenClosed;
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

function ModuleBriefingSystem.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
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
    ModuleGuiControl.Local:UpdateHiddenWidgets();

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
    ModuleGuiEffects.Local:ResetFarClipPlane();
    local Page = self.Briefing[_PlayerID][_PageID];
    if Page.FarClipPlane then
        ModuleGuiEffects.Local:SetFarClipPlane(Page.FarClipPlane);
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
        if Page.Animations.Clear then
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
        if Page.Parallax.Clear then
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
                Factor = math.min(v:Interpolation(CurrentTime), 1);
            end
            local Alpha = v.Start.A  + (v.End.A - v.Start.A)   * Factor;
            local u0    = v.Start.U0 + (v.End.U0 - v.Start.U0) * Factor;
            local v0    = v.Start.V0 + (v.End.V0 - v.Start.V0) * Factor;
            local u1    = v.Start.U1 + (v.End.U1 - v.Start.U1) * Factor;
            local v1    = v.Start.U1 + (v.End.U1 - v.Start.U1) * Factor;
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
        "BriefingOptionSelected",
        _PlayerID,
        AnswerID
    );
end

function ModuleBriefingSystem.Local:ThroneRoomCameraControl(_PlayerID, _Page)
    if _Page then
        -- Camera
        self:ControlCameraAnimation(_PlayerID);
        local FOV = (type(_Page) == "table" and _Page.FOV) or 42;
        local PX, PY, PZ = self:GetPagePosition(_PlayerID);
        local LX, LY, LZ = self:GetPageLookAt(_PlayerID);
        if PX and not LX then
            LX, LY, LZ, PX, PY, PZ, FOV = self:GetCameraProperties(_PlayerID, FOV);
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
            if #self.Briefing[_PlayerID].AnimationQueue > 0 then
                self.Briefing[_PlayerID].CurrentAnimation = nil;
            end
        end
    end
    if self.Briefing[_PlayerID].CurrentAnimation == nil then
        if self.Briefing[_PlayerID].AnimationQueue and #self.Briefing[_PlayerID].AnimationQueue > 0 then
            local PageID = self.Briefing[_PlayerID].CurrentPage;
            local Page = self.Briefing[_PlayerID][PageID];
            local Next = table.remove(self.Briefing[_PlayerID].AnimationQueue, 1);
            if Page and Page.Animations and Page.Animations.Repeat then
                table.insert(self.Briefing[_PlayerID].AnimationQueue, Next);
            end
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
        if lX and lY and lZ then
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
        if lX and lY and lZ then
            x = x + (lX - x) * self:GetInterpolationFactor(_PlayerID);
            y = y + (lY - y) * self:GetInterpolationFactor(_PlayerID);
            z = z + (lZ - z) * self:GetInterpolationFactor(_PlayerID);
        end
    end
    return x, y, z;
end

function ModuleBriefingSystem.Local:ConvertPosition(_Table)
    local x, y, z;
    if _Table and type(_Table) == "table" then
        if _Table.X then
            x = _Table.X;
            y = _Table.Y;
            z = _Table.Z;
        elseif _Table[3] then
            x = _Table[1];
            y = _Table[2];
            z = _Table[3];
        else
            x, y, z = Logic.EntityGetPos(GetID(_Table[1]));
            z = z + (_Table[2] or 0);
        end
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

function ModuleBriefingSystem.Local:GetCameraProperties(_PlayerID, _FOV)
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

    local factor = self:GetInterpolationFactor(_PlayerID);

    local lPLX, lPLY, lPLZ = self:ConvertPosition(startPosition);
    local cPLX, cPLY, cPLZ = self:ConvertPosition(endPosition);
    local lookAtX = lPLX + (cPLX - lPLX) * factor;
    local lookAtY = lPLY + (cPLY - lPLY) * factor;
    local lookAtZ = lPLZ + (cPLZ - lPLZ) * factor;

    local zoomDistance = startZoomDistance + (endZoomDistance - startZoomDistance) * factor;
    local zoomAngle = startZoomAngle + (endZoomAngle - startZoomAngle) * factor;
    local rotation = startRotation + (endRotation - startRotation) * factor;
    local line = zoomDistance * math.cos(math.rad(zoomAngle));
    local positionX = lookAtX + math.cos(math.rad(rotation - 90)) * line;
    local positionY = lookAtY + math.sin(math.rad(rotation - 90)) * line;
    local positionZ = lookAtZ + (zoomDistance) * math.sin(math.rad(zoomAngle));

    return lookAtX, lookAtY, lookAtZ, positionX, positionY, positionZ, _FOV;
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
                "BriefingLeftClick",
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
                "BriefingSkipButtonPressed",
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

    if not self.LoadscreenClosed then
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

    if not self.LoadscreenClosed then
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

    ModuleGuiEffects.Local:ResetFarClipPlane();
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleBriefingSystem);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Briefing zu verwenden.
--
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
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
-- @field BriefingStarted           Ein Briefing beginnt (Parameter: PlayerID, BriefingTable)
-- @field BriefingEnded             Ein Briefing endet (Parameter: PlayerID, BriefingTable)
-- @field BriefingPageShown         Ein Briefing endet (Parameter: PlayerID, PageIndex)
-- @field BriefingSkipButtonPressed Der Spieler überspringt eine Seite (Parameter: PlayerID)
-- @field BriefingOptionSelected    Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
-- @field BriefingLeftClick         Left Mouse wurde während des Briefings gedrückt (Parameter: PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet ein Briefing.
--
-- Die Funktion bekommt ein Table mit der Briefingdefinition, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- <h5>Einstellungen</h5>
-- Für ein Briefing können verschiedene spezielle Einstellungen vorgenommen
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
-- <td>(Optional) Eine Funktion, die beim Start des Briefing ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.BriefingStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Briefing ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.BriefingEnded aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>RestoreCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Kameraposition am Ende des Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>RestoreGameSpeed</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Geschwindigkeit von vor dem Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange das Briefing aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während des Briefing angezeigt. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird während des Briefing angezeigt. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden während des Briefing angezeigt. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- <h5>Animationen</h5>
-- Kameraanimationen für Seiten eines Briefings können vom Text einer Page
-- entkoppelt werden. Das hat den Charme, dass Spielfiguren erzählen und
-- erzählen und die Kamera über die ganze Zeit die gleiche Animation zeigt,
-- was das Lesen angenehmer macht.
--
-- <b>Hinweis:</b> Animationen werden nur erzeugt, wenn die Page noch keine
-- Position hat! Andernfalls werden die Werte für Angle, Rotation und Zoom
-- aus der Page genommen und/oder Defaults verwendet.
--
-- Animationen können über eine Table angegeben werden. Diese wird direkt
-- in die Briefing Table geschrieben. Die Animation wird die Kamera dann von
-- Position 1 zu Position 2 bewegen. Dabei ist die zweite Position optional
-- und kann weggelassen werden.
-- 
-- <p>(→ Beispiel #2)</p>
-- <p>(→ Beispiel #3)</p>
-- <p>(→ Beispiel #4)</p>
--
-- <h5>Parallax</h5>
-- Unter Parallax versteht man (im Kontext eines Videospiels) einen Hintergrund,
-- dessen Bildausschnitt veränderlich ist. So wurden früher z.B. der Hintergrund
-- eines Side Scrollers (Super Mario, Sonic, ...) realisiert.
--
-- Während eines Briefings können bis zu 6 übereinander liegende Ebenen solcher
-- Parallaxe verwendet werden. Dabei wird eine Grafik vorgegeben, die durch
-- Angabe von UV-Koordinaten und Alphawert animiert werden kann. Diese Grafiken
-- liegen hinter allen Elementen des Thronerooms.
--
-- Parallaxe können über eine Table angegeben werden. Diese wird direkt in die
-- Briefing Table geschrieben. Jede Ebene kann getrennt von den anderen agieren.
-- Ein Parallax kann statisch ein Bild anzeigen oder animiert sein. In diesem
-- Fall wird sich von Position 1 zu Position 2 bewegt, wobei Position 2 optional
-- ist und weggelassen werden kann.
--
-- Die UV-Koordinaten ergeben zwei Punkte auf der Grafik aus der ein Rechteck
-- ergänzt wird. Die Koordinaten können entweder pixelgenau order relativ
-- angegeben werden. Pixelgenau bedeutet, dass man einen Punkt exakt an einer
-- bestimmten Position auf der Grafik auswählt und setzt (z.B. 100, 50). Gibt
-- man relative Werte an, dann benutzt man Zahlen zwischen 0 und 1, wobei 0 für
-- 0% und 1 für 100% steht. In jedem Fall sind die Koordinaten absolut oder
-- relativ zur Grafik und nicht zur Bildschirmgröße.
--
-- <b>Achtung:</b> Die Grafiken müssen immer im 16:9 Format sein. Für den Fall,
-- dass das Spiel in einer 4:3 Auflösung gespielt wird, werden automatisch die
-- angegebenen Koordinaten umgerechnet und links und rechts abgeschnitten.
-- Konzipiere Grafiken also stets so, dass sie auch im 4:3 Format noch das
-- wichtigste zeigen.
--
-- <p>(→ Beispiel #5)</p>
-- <p>(→ Beispiel #6)</p>
--
-- @param[type=table]  _Briefing Definition des Briefing
-- @param[type=string] _Name     Name des Briefing
-- @param[type=number] _PlayerID Empfänger des Briefing
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Grobes Gerüst eines Briefings
-- function Briefing1(_Name, _PlayerID)
--     local Briefing = {
--         -- Hier können verschiedene Konfigurationen vorgenommen werden.
--     };
--     local AP, ASP = API.AddBriefingPages(Briefing);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Briefing.Starting = function(_Data)
--         -- Mach was tolles hier, wenn es anfängt.
--     end
--     Briefing.Finished = function(_Data)
--         -- Mach was tolles hier, wenn es endet.
--     end
--     -- Das Briefing wird gestartet
--     API.StartBriefing(Briefing, _Name, _PlayerID);
-- end
--
-- @usage
-- -- Beispiel #2: Angabe von Animationen
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Relativdarstellung
--         -- Animationsdauer, Position1, Rotation1, Zoom1, Angle1, Position2, Rotation2, Zoom2, Angle2
--         {30, "pos4", -60, 2000, 35, "pos4", -30, 2000, 25},
--         -- Hier können weitere Animationen folgen...
--     },
--     ["Page3"] = {
--         -- Vektordarstellung
--         -- Animationsdauer, {Position1, Höhe}, {LookAt1, Höhe}, {Position2, Höhe}, {LookAt2, Höhe}
--         {30, {"pos2", 500}, {"pos4", 0}, {"pos7", 1000}, {"pos8", 0}},
--         -- Hier können weitere Animationen folgen...
--     },
--     -- Hier können weitere Pages folgen...
-- };
--
-- @usage
-- -- Beispiel #3: Laufende Animationen ersetzen
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Löscht alle laufenden Animationen
--         Clear = true,
--         {30, "pos4", -60, 2000, 35, "pos4", -30, 2000, 25},
--     },
-- };
--
-- @usage
-- -- Beispiel #4: Animation in Endlosschleife
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Lässt die Animationen sich wiederholen
--         Repeat = true,
--         {30, "pos4",   0, 4000, 35, "pos4", 180, 4000, 35},
--         {30, "pos4", 180, 4000, 35, "pos4", 360, 4000, 35},
--     },
-- };
--
-- @usage
-- -- Beispiel #5: Angabe von Parallaxen
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Bilddatei, Anzeigedauer,
--         -- U0Start, V0Start, U1Start, V1Start, AlphaStart,
--         -- U0End, V0End, U1End, V1End, AlphaEnd
--         {"maps/externalmap/mapname/graphics/Parallax6.png", 60,
--          0, 0, 0.8, 1, 255,
--          0.2, 0, 1, 1, 255},
--         -- Hier können weitere Einträge folgen...
--     },
--     ["Page3"] = {
--         -- Bilddatei, Anzeigedauer,
--         -- U0Start, V0Start, U1Start, V1Start, AlphaStart
--         {"maps/externalmap/mapname/graphics/Parallax1.png", 1,
--          0, 0, 1, 1, 180},
--         -- Hier können weitere Einträge folgen...
--     }
--     -- Hier können weitere Pages folgen...
-- };
--
-- @usage
-- -- Beispiel #6: Laufende Parallaxe ersetzen
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Löscht alle laufenden Paralaxe
--         Clear = true,
--         {"maps/externalmap/mapname/graphics/Parallax6.png",
--          60, 0, 0, 0.8, 1, 255, 0.2, 0, 1, 1, 255},
--     },
-- };
--
-- @usage
-- -- Beispiel #7: Parallaxe im Vordergrund
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Parallaxe erscheinen im Vordergrund
--         Foreground = true,
--         {"maps/externalmap/mapname/graphics/Parallax6.png",
--          60, 0, 0, 0.8, 1, 255, 0.2, 0, 1, 1, 255},
--     },
-- };
--
function API.StartBriefing(_Briefing, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Briefing) ~= "table" then
        error("API.StartBriefing (" .._Name.. "): _Briefing must be a table!");
        return;
    end
    if #_Briefing == 0 then
        error("API.StartBriefing (" .._Name.. "): _Briefing does not contain pages!");
        return;
    end
    for i=1, #_Briefing do
        if type(_Briefing[i]) == "table" and not _Briefing[i].__Legit then
            error("API.StartBriefing (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Briefing.EnableSky == nil then
        _Briefing.EnableSky = true;
    end
    if _Briefing.EnableFoW == nil then
        _Briefing.EnableFoW = false;
    end
    if _Briefing.EnableGlobalImmortality == nil then
        _Briefing.EnableGlobalImmortality = true;
    end
    if _Briefing.EnableBorderPins == nil then
        _Briefing.EnableBorderPins = false;
    end
    if _Briefing.RestoreGameSpeed == nil then
        _Briefing.RestoreGameSpeed = true;
    end
    if _Briefing.RestoreCamera == nil then
        _Briefing.RestoreCamera = true;
    end
    ModuleBriefingSystem.Global:StartBriefing(_Name, PlayerID, _Briefing);
end

---
-- Prüft ob für den Spieler gerade ein Briefing aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Briefing ist aktiv
-- @within Anwenderfunktionen
--
function API.IsBriefingActive(_PlayerID)
    if Revision.Environment == QSB.Environment.GLOBAL then
        return ModuleBriefingSystem.Global:GetCurrentBriefing(_PlayerID) ~= nil;
    end
    return ModuleBriefingSystem.Local:GetCurrentBriefing(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten und Animationen in einem
-- Briefing. Diese Funktion muss vor dem Start eines Briefing aufgerufen werden,
-- damit Seiten gebunden werden können. Je nach Bedarf können Rückgaben von
-- rechts nach links weggelassen werden.
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @within Anwenderfunktionen
-- @see API.StartBriefing
--
-- @usage
-- -- Wenn nur AP benötigt wird.
-- local AP = API.AddBriefingPages(Briefing);
-- -- Wenn zusätzlich ASP benötigt wird.
-- local AP, ASP = API.AddBriefingPages(Briefing);
--
function API.AddBriefingPages(_Briefing)
    ModuleBriefingSystem.Global:CreateBriefingGetPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddMCPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddRedirect(_Briefing);

    local AP = function(_Page)
        local Page;
        if type(_Page) == "table" then
            if _Page.MC then
                Page = _Briefing:AddMCPage(_Page);
            else
                Page = _Briefing:AddPage(_Page);
            end
        else
            Page = _Briefing:AddRedirect(_Page);
        end
        return Page;
    end

    local ASP = function(...)
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};

        local Name, Title,Text, Position;
        local DialogCam = false;
        local Action = function() end;
        local NoSkipping = false;

        -- Set page parameters
        if (#arg == 3 and type(arg[1]) == "string")
        or (#arg >= 4 and type(arg[4]) == "boolean") then
            Name = table.remove(arg, 1);
        end
        Title = table.remove(arg, 1);
        Text = table.remove(arg, 1);
        if #arg > 0 then
            DialogCam = table.remove(arg, 1) == true;
        end
        if #arg > 0 then
            Position = table.remove(arg, 1);
        end
        if #arg > 0 then
            Action = table.remove(arg, 1);
        end
        if #arg > 0 then
            NoSkipping = not table.remove(arg, 1);
        end

        -- Calculate camera rotation
        local Rotation;
        if Position then
            Rotation = QSB.Briefing.CAMERA_ROTATIONDEFAULT;
            if Position and Logic.IsSettler(GetID(Position)) == 1 then
                Rotation = Logic.GetEntityOrientation(GetID(Position)) + 90;
            end
        end

        -- Create page
        return _Briefing:AddPage {
            Name            = Name,
            Title           = Title,
            Text            = Text,
            Action          = Action,
            Position        = Position,
            DisableSkipping = NoSkipping,
            DialogCamera    = DialogCam,
            Rotation        = Rotation,
        };
    end

    -- Prevent hard errors
    local AAN = function()
        error("AAN has been removed!");
    end;
    return AP, ASP, AAN;
end

---
-- Erzeugt eine neue Seite für das Briefing.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- <h5>Briefing Page</h5>
-- Die Briefing Page definiert, was zum Zeitpunkt ihrer Anzeige dargestellt
-- wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
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
-- <td>Position</td>
-- <td>string</td>
-- <td>Striptname des Entity, welches die Kamera ansieht.</td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>number</td>
-- <td>(Optional) Bestimmt, wie lange die Page angezeigt wird. Wird es
-- weggelassen, wird automatisch eine Anzeigezeit anhand der Textlänge bestimmt.
-- Diese ist immer mindestens 6 Sekunden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Eine Boolean, welche angibt, ob Nah- oder Fernsicht benutzt
-- wird.</td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Das Überspringen der Seite wird unterbunden.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, sobald
-- die Seite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>FarClipPlane</td>
-- <td>number</td>
-- <td>(Optional) Renderdistanz für die Seite (Default 100000).
-- wird.</td>
-- </tr>
-- <tr>
-- <tr>
-- <td>Rotation</td>
-- <td>number</td>
-- <td>(Optional) Rotation der Kamera gibt den Winkel an, indem die Kamera
-- um das Ziel gedreht wird.</td>
-- </tr>
-- <tr>
-- <td>Zoom</td>
-- <td>number</td>
-- <td>(Optional) Zoom bestimmt die Entfernung der Kamera zum Ziel.</td>
-- </tr>
-- <tr>
-- <td>Angle</td>
-- <td>number</td>
-- <td>(Optional) Angle gibt den Winkel an, in dem die Kamera gekippt wird.
-- </td>
-- </tr>
-- <tr>
-- <td>FlyTo</td>
-- <td>table</td>
-- <td>(Optional) Kann ein zweites Set von Position, Rotation, Zoom und Angle
-- enthalten, zudem sich die Kamera dann bewegt.
-- </td>
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
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(Optional) Liste von Optionen zur Verzweigung des Briefings. Dies kann
-- benutzt werden, um z.B. Dialoge mit Antwortmöglichkeiten zu erstellen.</td>
-- </tr>
-- </table>
--
-- <h5>Multiple Choice</h5>
-- In einem Briefing kann der Spieler auch zur Auswahl einer Option gebeten
-- werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
-- in eine Untertabelle MC.
--
-- <p>(→ Beispiel #2)</p>
-- 
-- Es kann der Name der Zielseite angegeben werden, oder eine Funktion, die
-- den Namen des Ziels zurück gibt. In der Funktion können vorher beliebige
-- Dinge getan werden, wie z.B. Variablen setzen.
--
-- Eine Antwort kann markiert werden, dass sie auch bei einem Rücksprung,
-- nicht mehrfach gewählt werden kann. In diesem Fall ist sie bei erneutem
-- Aufsuchen der Seite nicht mehr gelistet.
-- 
-- <p>(→ Beispiel #3)</p>
--
-- Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
-- angegeben, welche über die Sichtbarkeit entscheidet.
-- 
-- <p>(→ Beispiel #4)</p>
--
-- Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
-- dem angegebenen Namen geleitet.
--
-- Um das Briefing zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß das Briefing, das es an dieser
-- Stelle zuende ist.
--
-- <p>(→ Beispiel #5)</p>
--
-- Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
-- Name der Seite angeben werden, zu der gesprungen werden soll.
--
-- <p>(→ Beispiel #6)</p>
--
-- Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
-- erfahren, muss der Name der Seite genutzt werden.
-- 
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
-- 
-- <p>(→ Beispiel #7)</p>
--
-- @param[type=table] _Data Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Briefing
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AP {
--    -- Hier werden die Attribute der Page angegeben
--    Title        = "Marcus",
--    Text         = "Das ist eine simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
-- };
--
-- @usage
-- -- Beispiel #2: Verwendung von Multiple Choice
-- AP {
--    Title        = "Marcus",
--    Text         = "Das ist eine nicht so simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
--    -- MC ist das Table mit den auswählbaren Antworten
--    MC = {
--        -- Zielseite ist der Name der Page, zu der gesprungen wird.
--        {"Antwort 1", "Zielseite"},
--        -- Option2Clicked ist eine Funktion, die etwas macht und
--        -- danach die Page zurückgibt, zu der gesprungen wird.
--        {"Antwort 2", Option2Clicked},
--    },
-- };
--
-- @usage
-- -- Beispiel #3: Antwort, die nur einmal gewählt werden kann
-- MC = {
--     {"Antwort 3", "AnotherPage", Remove = true},
-- }
--
-- @usage
-- -- Beispiel #4: Antwort mit gesteuerter Sichtbarkeit
-- MC = {
--     {"Antwort 3", "AnotherPage", Disable = OptionIsDisabled},
-- }
--
-- @usage
-- -- Beispiel #5: Abbruch des Briefings
-- AP()
--
-- @usage
-- -- Beispiel #6: Sprung zu anderer Seite
-- AP("SomePageName")
--
-- @usage
-- -- Beispiel #7: Erfragen der gewählten Antwort
-- Briefing.Finished = function(_Data)
--     local Choosen = _Data:GetPage("Choice"):GetSelected();
--     -- In Choosen steht der Index der Antwort
-- end
--
function AP(_Data)
    assert(false);
end

---
-- Erzeugt eine neue Seite für das Briefing in Kurzschreibweise.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- Die Seite erhält automatisch einen Namen, entsprechend der Reihenfolge aller
-- Seitenaufrufe von AP oder ASP. Werden also vor dem Aufruf bereits 2 Seiten
-- erzeugt, so würde die Seite den Namen "Page3" erhalten.
--
-- Folgende Parameter werden in <u>genau dieser Reihenfolge</u> an die Funktion
-- übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Bezeichnung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>string</td>
-- <td>Der interne Name der Page.</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der angezeigte Titel der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der angezeigte Text der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>Die Kamera geht in Nahsicht und stellt Charaktere dar. Wird
-- sie weggelassen, wird die Fernsicht verwendet.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>(Optional) Skriptname des Entity zu das die Kamera springt.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, wenn die Seite
-- angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>EnableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Steuert, ob die Seite übersprungen werden darf. Wenn es nicht
-- angegeben wird, ist das Überspringen immer deaktiviert.</td>
-- </tr>
-- </table>
--
-- @param ... Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Briefing
--
-- @usage
-- -- Hinweis dazu: In Lua werden Parameter von links nach rechts aufgelöst.
-- -- Will man also Parameter weglassen, wenn danach noch welche folgen, muss
-- -- man die Leerstellen mit nil auffüllen.
--
-- -- Fernsicht
-- ASP("Title", "Some important text.", false, "HQ");
-- -- Page Name
-- ASP("Page1", "Title", "Some important text.", false, "HQ");
-- -- Nahsicht
-- ASP("Title", "Some important text.", true, "Marcus");
-- -- Aktion ausführen
-- ASP("Title", "Some important text.", true, "Marcus", MyFunction);
-- -- Überspringen erlauben/verbieten
-- ASP("Title", "Some important text.", true, "HQ", nil, true);
--
function ASP(...)
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
-- Fügt Behavior zur Steuerung von Briefings hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reprisal
--
function Reprisal_Briefing(...)
    return B_Reprisal_Briefing:new(...);
end

B_Reprisal_Briefing = {
    Name = "Reprisal_Briefing",
    Description = {
        en = "Reprisal: Calls a function to start an new briefing.",
        de = "Vergeltung: Ruft die Funktion auf und startet das enthaltene Briefing.",
        fr = "Rétribution: Appelle la fonction et démarre le briefing qu'elle contient.",
    },
    Parameter = {
        { ParameterType.Default, en = "Briefing name",     de = "Name des Briefing",     fr = "Nom du briefing" },
        { ParameterType.Default, en = "Briefing function", de = "Funktion mit Briefing", fr = "Fonction avec briefing" },
    },
}

function B_Reprisal_Briefing:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function B_Reprisal_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Briefing:CustomFunction(_Quest)
    _G[self.Function](self.BriefingName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Briefing:Debug(_Quest)
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Reprisal_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Briefing.
--
-- Jedes Briefing braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Briefing
-- @param[type=string] _Briefing Funktionsname als String
-- @within Reward
--
function Reward_Briefing(...)
    return B_Reward_Briefing:new(...);
end

B_Reward_Briefing = Revision.LuaBase:CopyTable(B_Reprisal_Briefing);
B_Reward_Briefing.Name = "Reward_Briefing";
B_Reward_Briefing.Description.en = "Reward: Calls a function to start an new briefing.";
B_Reward_Briefing.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Briefing.";
B_Reward_Briefing.Description.fr = "Récompense: Appelle la fonction et démarre le briefing qu'elle contient.";
B_Reward_Briefing.GetReprisalTable = nil;

B_Reward_Briefing.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Revision:RegisterBehavior(B_Reward_Briefing);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Briefing beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Briefing
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Briefing(...)
    return B_Trigger_Briefing:new(...);
end

B_Trigger_Briefing = {
    Name = "Trigger_Briefing",
    Description = {
        en = "Trigger: Checks if an briefing has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob ein Briefing beendet ist und startet dann den Quest.",
        fr = "Déclencheur: Vérifie si un briefing est terminé et lance ensuite la quête.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Briefing name", de = "Name des Briefing", fr = "Nom du briefing" },
        { ParameterType.PlayerID, en = "Player ID",     de = "Player ID",         fr = "Player ID" },
        { ParameterType.Number,   en = "Wait time",     de = "Wartezeit",         fr = "Temps d'attente" },
    },
}

function B_Trigger_Briefing:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Briefing:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.BriefingName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Briefing:CustomFunction(_Quest)
    if API.GetCinematicEvent(self.BriefingName, self.PlayerID) == CinematicEvent.Concluded then
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

function B_Trigger_Briefing:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.BriefingName == nil or self.BriefingName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Trigger_Briefing);

