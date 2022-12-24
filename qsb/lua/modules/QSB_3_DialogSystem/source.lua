--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleDialogSystem = {
    Properties = {
        Name = "ModuleDialogSystem",
    },

    Global = {
        Dialog = {},
        DialogQueue = {},
        DialogCounter = 0,
    },
    Local = {
        Dialog = {},
    },
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Text = {
            Continue = {
                de = "{cr}{cr}{azure}(Weiter mit ESC)",
                en = "{cr}{cr}{azure}(Continue with ESC)",
                fr = "{cr}{cr}{azure}(Continuer avec ESC)",
            }
        },
    },
};

QSB.CinematicEventTypes.Dialog = 5;

QSB.Dialog = {
    TIMER_PER_CHAR = 0.175,
    CAMERA_ANGLEDEFAULT = 43,
    CAMERA_ROTATIONDEFAULT = -45,
    CAMERA_ZOOMDEFAULT = 6500,
    CAMERA_FOVDEFAULT = 42,
    DLGCAMERA_ANGLEDEFAULT = 27,
    DLGCAMERA_ROTATIONDEFAULT = -45,
    DLGCAMERA_ZOOMDEFAULT = 1750,
    DLGCAMERA_FOVDEFAULT = 25,
}

-- Global ------------------------------------------------------------------- --

function ModuleDialogSystem.Global:OnGameStart()
    QSB.ScriptEvents.DialogStarted = API.RegisterScriptEvent("Event_DialogStarted");
    QSB.ScriptEvents.DialogEnded = API.RegisterScriptEvent("Event_DialogEnded");
    QSB.ScriptEvents.DialogPageShown = API.RegisterScriptEvent("Event_DialogPageShown");
    QSB.ScriptEvents.DialogOptionSelected = API.RegisterScriptEvent("Event_DialogOptionSelected");

    for i= 1, 8 do
        self.DialogQueue[i] = {};
    end
    API.StartHiResJob(function()
        ModuleDialogSystem.Global:UpdateQueue();
        ModuleDialogSystem.Global:DialogExecutionController();
    end);
end

function ModuleDialogSystem.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
        self:SkipButtonPressed(arg[1]);
    elseif _ID == QSB.ScriptEvents.DialogStarted then
        self:NextPage(arg[1]);
    elseif _ID == QSB.ScriptEvents.DialogEnded then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DialogEnded, %d, %s)]],
            arg[1],
            table.tostring(arg[2])
        ));
    elseif _ID == QSB.ScriptEvents.DialogPageShown then
        local Page = self.Dialog[arg[1]][arg[2]];
        if type(Page) == "table" then
            Page = table.tostring(Page);
        end
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DialogPageShown, %d, %d, %s)]],
            arg[1],
            arg[2],
            Page
        ));
    elseif _ID == QSB.ScriptEvents.DialogOptionSelected then
        self:OnOptionSelected(arg[1], arg[2]);
    end
end

-- Manages the actual activation of dialogues.
function ModuleDialogSystem.Global:UpdateQueue()
    for i= 1, 8 do
        if self:CanStartDialog(i) then
            local Next = ModuleGuiEffects.Global:LookUpCinematicInQueue(i);
            if Next and Next[1] == QSB.CinematicEventTypes.Dialog then
                self:NextDialog(i);
            end
        end
    end
end

-- Manages auto skipping of pages.
function ModuleDialogSystem.Global:DialogExecutionController()
    for i= 1, 8 do
        if self.Dialog[i] then
            local PageID = self.Dialog[i].CurrentPage;
            local Page = self.Dialog[i][PageID];
            if Page and not Page.MC and Page.Duration > 0 and Page.AutoSkip then
                if (Page.Started + Page.Duration) < Logic.GetTime() then
                    self:NextPage(i);
                end
            end
        end
    end
end

function ModuleDialogSystem.Global:CreateDialogGetPage(_Dialog)
    _Dialog.GetPage = function(self, _NameOrID)
        local ID = ModuleDialogSystem.Global:GetPageIDByName(_Dialog.PlayerID, _NameOrID);
        return ModuleDialogSystem.Global.Dialog[_Dialog.PlayerID][ID];
    end
end

function ModuleDialogSystem.Global:CreateDialogAddPage(_Dialog)
    _Dialog.AddPage = function(self, _Page)
        -- Dialog length
        self.Length = (self.Length or 0) +1;

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
        _Page.Text = API.Localize(_Page.Text or "");

        -- Skip page
        _Page.AutoSkip = false;
        if _Page.Duration then
            if _Page.Duration == -1 then
                _Page.Duration = string.len(_Page.Text or "") * QSB.Dialog.TIMER_PER_CHAR;
                _Page.Duration = (_Page.Duration < 6 and 6) or _Page.Duration < 6;
            end
            _Page.AutoSkip = _Page.Duration > 0;
        end

        -- Default camera rotation
        if not _Page.Rotation then
            _Page.Rotation = QSB.Dialog.CAMERA_ROTATIONDEFAULT;
            if _Page.DialogCamera then
                _Page.Rotation = QSB.Dialog.DLGCAMERA_ROTATIONDEFAULT;
            end
            if _Page.Position and type(_Page.Position) ~= "table" then
                local ID = GetID(_Page.Position);
                local Orientation = Logic.GetEntityOrientation(ID) +90;
                _Page.Rotation = Orientation;
            elseif _Page.Target then
                local ID = GetID(_Page.Target);
                local Orientation = Logic.GetEntityOrientation(ID) +90;
                _Page.Rotation = Orientation;
            end
        end
        -- Default camera distance
        if not _Page.Distance then
            _Page.Distance = QSB.Dialog.CAMERA_ZOOMDEFAULT;
            if _Page.DialogCamera then
                _Page.Distance = QSB.Dialog.DLGCAMERA_ZOOMDEFAULT;
            end
        end
        -- Default camera angle
        if not _Page.Angle then
            _Page.Angle = QSB.Dialog.CAMERA_ANGLEDEFAULT;
            if _Page.DialogCamera then
                _Page.Angle = QSB.Dialog.DLGCAMERA_ANGLEDEFAULT;
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

function ModuleDialogSystem.Global:CreateDialogAddMCPage(_Dialog)
    _Dialog.AddMCPage = function(self, _Page)
        -- Create base page
        local Page = self:AddPage(_Page);

        -- Multiple Choice options
        if Page.MC then
            for i= 1, #Page.MC do
                Page.MC[i][1] = API.Localize(Page.MC[i][1]);
                Page.MC[i].ID = Page.MC[i].ID or i;
            end
            Page.AutoSkip = false;
            Page.Duration = -1;
        end

        -- Multiple choice selection
        Page.GetSelected = function(self)
            if self.MC then
                return self.MC.Selected;
            end
            return 0;
        end
        -- Return page
        return Page;
    end
end

function ModuleDialogSystem.Global:CreateDialogAddRedirect(_Dialog)
    _Dialog.AddRedirect = function(self, _Target)
        -- Dialog length
        self.Length = (self.Length or 0) +1;
        -- Return page
        local Page = (_Target == nil and -1) or _Target;
        table.insert(self, Page);
        return Page;
    end
end

-- Does not really start the dialog. It is pushed inside the global queue for
-- all informational stuff and executed later by a job.
function ModuleDialogSystem.Global:StartDialog(_Name, _PlayerID, _Data)
    self.DialogQueue[_PlayerID] = self.DialogQueue[_PlayerID] or {};
    ModuleGuiEffects.Global:PushCinematicEventToQueue(
        _PlayerID,
        QSB.CinematicEventTypes.Dialog,
        _Name,
        _Data
    );
end

function ModuleDialogSystem.Global:EndDialog(_PlayerID)
    Logic.SetGlobalInvulnerability(0);
    Logic.ExecuteInLuaLocalState(string.format(
        [[ModuleDialogSystem.Local:ResetTimerButtons(%d);
          Camera.RTS_FollowEntity(0);]],
        _PlayerID
    ));
    API.SendScriptEvent(
        QSB.ScriptEvents.DialogEnded,
        _PlayerID,
        self.Dialog[_PlayerID]
    );
    if self.Dialog[_PlayerID].Finished then
        self.Dialog[_PlayerID]:Finished();
    end
    API.FinishCinematicEvent(self.Dialog[_PlayerID].Name, _PlayerID);
    self.Dialog[_PlayerID] = nil;
end

function ModuleDialogSystem.Global:NextDialog(_PlayerID)
    if self:CanStartDialog(_PlayerID) then
        local DialogData = ModuleGuiEffects.Global:PopCinematicEventFromQueue(_PlayerID);
        assert(DialogData[1] == QSB.CinematicEventTypes.Dialog);
        API.StartCinematicEvent(DialogData[2], _PlayerID);

        local Dialog = DialogData[3];
        Dialog.Name = DialogData[2];
        Dialog.PlayerID = _PlayerID;
        Dialog.LastSkipButtonPressed = 0;
        Dialog.CurrentPage = 0;
        self.Dialog[_PlayerID] = Dialog;

        if Dialog.EnableGlobalImmortality then
            Logic.SetGlobalInvulnerability(1);
        end
        if self.Dialog[_PlayerID].Starting then
            self.Dialog[_PlayerID]:Starting();
        end

        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.DialogStarted, %d, %s)]],
            _PlayerID,
            table.tostring(self.Dialog[_PlayerID])
        ));
        API.SendScriptEvent(
            QSB.ScriptEvents.DialogStarted,
            _PlayerID,
            self.Dialog[_PlayerID]
        );
    end
end

function ModuleDialogSystem.Global:NextPage(_PlayerID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end

    self.Dialog[_PlayerID].CurrentPage = self.Dialog[_PlayerID].CurrentPage +1;
    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if PageID == -1 or PageID == 0 then
        self:EndDialog(_PlayerID);
        return;
    end

    local Page = self.Dialog[_PlayerID][PageID];
    if type(Page) == "table" then
        if PageID <= #self.Dialog[_PlayerID] then
            self.Dialog[_PlayerID][PageID].Started = Logic.GetTime();
            self.Dialog[_PlayerID][PageID].Duration = Page.Duration or -1;
            if self.Dialog[_PlayerID][PageID].Action then
                self.Dialog[_PlayerID][PageID]:Action();
            end
            self:DisplayPage(_PlayerID, PageID);
        else
            self:EndDialog(_PlayerID);
        end
    elseif type(Page) == "number" or type(Page) == "string" then
        local Target = self:GetPageIDByName(_PlayerID, self.Dialog[_PlayerID][PageID]);
        self.Dialog[_PlayerID].CurrentPage = Target -1;
        self:NextPage(_PlayerID);
    else
        self:EndDialog(_PlayerID);
    end
end

function ModuleDialogSystem.Global:DisplayPage(_PlayerID, _PageID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end

    local Page = self.Dialog[_PlayerID][_PageID];
    if type(Page) == "table" then
        local PageID = self.Dialog[_PlayerID].CurrentPage;
        if Page.MC then
            for i= 1, #Page.MC, 1 do
                if type(Page.MC[i][3]) == "function" then
                    self.Dialog[_PlayerID][PageID].MC[i].Visible = Page.MC[i][3](_PlayerID, PageID, i);
                end
            end
        end
    end

    API.SendScriptEvent(
        QSB.ScriptEvents.DialogPageShown,
        _PlayerID,
        _PageID,
        self.Dialog[_PlayerID][_PageID]
    );
end

-- There is no skip button but I want to keep the original names to make
-- comparisons easier for other authors who might want to implement yet
-- another information system.
function ModuleDialogSystem.Global:SkipButtonPressed(_PlayerID, _PageID)
    if not self.Dialog[_PlayerID] then
        return;
    end
    if (self.Dialog[_PlayerID].LastSkipButtonPressed + 500) > Logic.GetTimeMs() then
        return;
    end
    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if self.Dialog[_PlayerID][PageID].AutoSkip
    or self.Dialog[_PlayerID][PageID].MC then
        return;
    end
    if self.Dialog[_PlayerID][PageID].OnForward then
        self.Dialog[_PlayerID][PageID]:OnForward();
    end
    self.Dialog[_PlayerID].LastSkipButtonPressed = Logic.GetTimeMs();
    self:NextPage(_PlayerID);
end

function ModuleDialogSystem.Global:OnOptionSelected(_PlayerID, _OptionID)
    if self.Dialog[_PlayerID] == nil then
        return;
    end
    local PageID = self.Dialog[_PlayerID].CurrentPage;
    if type(self.Dialog[_PlayerID][PageID]) ~= "table" then
        return;
    end
    local Page = self.Dialog[_PlayerID][PageID];
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
            self.Dialog[_PlayerID][PageID].MC.Selected = Option.ID;
            self.Dialog[_PlayerID].CurrentPage = self:GetPageIDByName(_PlayerID, Target) -1;
            self:NextPage(_PlayerID);
        end
    end
end

function ModuleDialogSystem.Global:GetCurrentDialog(_PlayerID)
    return self.Dialog[_PlayerID];
end

function ModuleDialogSystem.Global:GetCurrentDialogPage(_PlayerID)
    if self.Dialog[_PlayerID] then
        local PageID = self.Dialog[_PlayerID].CurrentPage;
        return self.Dialog[_PlayerID][PageID];
    end
end

function ModuleDialogSystem.Global:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Dialog[_PlayerID] ~= nil then
            for i= 1, #self.Dialog[_PlayerID], 1 do
                if type(self.Dialog[_PlayerID][i]) == "table" and self.Dialog[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleDialogSystem.Global:CanStartDialog(_PlayerID)
    return self.Dialog[_PlayerID] == nil
           and not API.IsCinematicEventActive(_PlayerID)
           and self.LoadscreenClosed;
end

-- Local -------------------------------------------------------------------- --

function ModuleDialogSystem.Local:OnGameStart()
    QSB.ScriptEvents.DialogStarted = API.RegisterScriptEvent("Event_DialogStarted");
    QSB.ScriptEvents.DialogEnded = API.RegisterScriptEvent("Event_DialogEnded");
    QSB.ScriptEvents.DialogPageShown = API.RegisterScriptEvent("Event_DialogPageShown");
    QSB.ScriptEvents.DialogOptionSelected = API.RegisterScriptEvent("Event_DialogOptionSelected");

    self:OverrideThroneRoomFunctions();
end

function ModuleDialogSystem.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.EscapePressed then
        -- Nothing to do?
    elseif _ID == QSB.ScriptEvents.DialogStarted then
        self:StartDialog(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.DialogEnded then
        self:EndDialog(arg[1], arg[2]);
    elseif _ID == QSB.ScriptEvents.DialogPageShown then
        self:DisplayPage(arg[1], arg[2], arg[3]);
    end
end

function ModuleDialogSystem.Local:StartDialog(_PlayerID, _Dialog)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Dialog[_PlayerID] = _Dialog;
    self.Dialog[_PlayerID].CurrentPage = 0;
    local PosX, PosY = Camera.RTS_GetLookAtPosition();
    local Rotation = Camera.RTS_GetRotationAngle();
    local ZoomFactor = Camera.RTS_GetZoomFactor();
    local SpeedFactor = Game.GameTimeGetFactor(_PlayerID);
    local SubX, SubY = XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/AlignBottomLeft/SubTitles");
    self.Dialog[_PlayerID].Backup = {
        SubTitles = {SubX, SubY},
        Camera    = {PosX, PosY, Rotation, ZoomFactor},
        Speed     = SpeedFactor,
    };

    API.DeactivateNormalInterface(_PlayerID);
    API.DeactivateBorderScroll(_PlayerID);

    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, 1);
    end
    self:ActivateCinematicMode(_PlayerID);
end

function ModuleDialogSystem.Local:EndDialog(_PlayerID, _Dialog)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    if self.Dialog[_PlayerID].RestoreGameSpeed and not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(_PlayerID, self.Dialog[_PlayerID].Backup.Speed);
    end
    if self.Dialog[_PlayerID].RestoreCamera then
        Camera.RTS_SetLookAtPosition(self.Dialog[_PlayerID].Backup.Camera[1], self.Dialog[_PlayerID].Backup.Camera[2]);
        Camera.RTS_SetRotationAngle(self.Dialog[_PlayerID].Backup.Camera[3]);
        Camera.RTS_SetZoomFactor(self.Dialog[_PlayerID].Backup.Camera[4]);
    end

    self:DeactivateCinematicMode(_PlayerID);
    API.ActivateNormalInterface(_PlayerID);
    API.ActivateBorderScroll(_PlayerID);
    ModuleGuiControl.Local:UpdateHiddenWidgets();

    self.Dialog[_PlayerID] = nil;
    Display.SetRenderFogOfWar(1);
    Display.SetRenderBorderPins(1);
    Display.SetRenderSky(0);
end

function ModuleDialogSystem.Local:DisplayPage(_PlayerID, _PageID, _PageData)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.Dialog[_PlayerID][_PageID] = _PageData;
    self.Dialog[_PlayerID].CurrentPage = _PageID;

    if type(self.Dialog[_PlayerID][_PageID]) == "table" then
        self.Dialog[_PlayerID][_PageID].Started = Logic.GetTime();
        self:DisplayPageFader(_PlayerID, _PageID);
        self:DisplayPagePosition(_PlayerID, _PageID);
        self:DisplayPageActor(_PlayerID, _PageID);
        self:DisplayPageTitle(_PlayerID, _PageID);
        self:DisplayPageText(_PlayerID, _PageID);
        if self.Dialog[_PlayerID][_PageID].MC then
            self:DisplayPageOptionsDialog(_PlayerID, _PageID);
        end
    end
end

function ModuleDialogSystem.Local:DisplayPagePosition(_PlayerID, _PageID)
    local Page = self.Dialog[_PlayerID][_PageID];
    -- Camera
    Camera.RTS_FollowEntity(0);
    if Page.Position then
        local Position = Page.Position;
        if type(Position) ~= "table" then
            Position = GetPosition(Page.Position);
        end
        Camera.RTS_SetLookAtPosition(Position.X, Position.Y);
    elseif Page.Target then
        Camera.RTS_FollowEntity(GetID(Page.Target));
    else
        assert(false);
    end
    Camera.RTS_SetRotationAngle(Page.Rotation);
    Camera.RTS_SetZoomFactor(Page.Distance / 18000);
    -- FIXME: This does not work?
    Camera.RTS_SetZoomAngle(Page.Angle);
end

function ModuleDialogSystem.Local:DisplayPageFader(_PlayerID, _PageID)
    local Page = self.Dialog[_PlayerID][_PageID];
    g_Fade.To = Page.FaderAlpha or 0;

    local PageFadeIn = Page.FadeIn;
    if PageFadeIn then
        FadeIn(PageFadeIn);
    end

    local PageFadeOut = Page.FadeOut;
    if PageFadeOut then
        -- FIXME: This would create jobs that are only be paused at the end!
        self.Dialog[_PlayerID].FaderJob = API.StartHiResJob(function(_Time, _FadeOut)
            if Logic.GetTimeMs() > _Time - (_FadeOut * 1000) then
                FadeOut(_FadeOut);
                return true;
            end
        end, Logic.GetTimeMs() + ((Page.Duration or 0) * 1000), PageFadeOut);
    end
end

function ModuleDialogSystem.Local:DisplayPageActor(_PlayerID, _PageID)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message";
    XGUIEng.ShowWidget(PortraitWidget, 1);
    XGUIEng.ShowAllSubWidgets(PortraitWidget, 1);
    XGUIEng.ShowWidget(PortraitWidget.. "/QuestLog", 0);
    XGUIEng.ShowWidget(PortraitWidget.. "/Update", 0);
    local Page = self.Dialog[_PlayerID][_PageID];
    if not Page.Actor or Page.Actor == -1 then
        XGUIEng.ShowWidget(PortraitWidget, 0);
        return;
    end
    local Actor = self:GetPageActor(_PlayerID, _PageID);
    self:DisplayActorPortrait(_PlayerID, Actor);
end

function ModuleDialogSystem.Local:GetPageActor(_PlayerID, _PageID)
    local Actor = g_PlayerPortrait[_PlayerID];
    local Page = self.Dialog[_PlayerID][_PageID];
    if type(Page.Actor) == "string" then
        Actor = Page.Actor;
    elseif type(Page.Actor) == "number" then
        Actor = g_PlayerPortrait[Page.Actor];
    end
    -- If someone doesn't read the fucking manual...
    if not Models["Heads_" .. tostring(Actor)] then
        Actor = "H_NPC_Generic_Trader";
    end
    return Actor;
end

function ModuleDialogSystem.Local:DisplayPageTitle(_PlayerID, _PageID)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message";
    local Page = self.Dialog[_PlayerID][_PageID];
    if Page.Title then
        local Title = API.ConvertPlaceholders(Page.Title);
        if Title:find("^[A-Za-Z0-9_]+/[A-Za-Z0-9_]+$") then
            Title = XGUIEng.GetStringTableText(Title);
        end
        if Title:sub(1, 1) ~= "{" then
            Title = "{center}" ..Title;
        end
        XGUIEng.SetText(PortraitWidget.. "/MessagePortrait/PlayerName", Title);
        XGUIEng.ShowWidget(PortraitWidget.. "/MessagePortrait/PlayerName", 1);
    else
        XGUIEng.ShowWidget(PortraitWidget.. "/MessagePortrait/PlayerName", 0);
    end
end

function ModuleDialogSystem.Local:DisplayPageText(_PlayerID, _PageID)
    self:ResetSubtitlesPosition(_PlayerID);
    local Page = self.Dialog[_PlayerID][_PageID];
    local SubtitlesWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    if not Page or not Page.Text or Page.Text == "" then
        XGUIEng.SetText(SubtitlesWidget.. "/VoiceText1", " ");
        XGUIEng.ShowWidget(SubtitlesWidget, 0);
        return;
    end
    XGUIEng.ShowWidget(SubtitlesWidget, 1);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/Update", 0);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/VoiceText1", 1);
    XGUIEng.ShowWidget(SubtitlesWidget.. "/BG", 1);

    local Text = API.ConvertPlaceholders(API.Localize(Page.Text));
    local Extension = "";
    if not Page.AutoSkip and not Page.MC then
        Extension = API.ConvertPlaceholders(API.Localize(ModuleDialogSystem.Shared.Text.Continue));
    end
    XGUIEng.SetText(SubtitlesWidget.. "/VoiceText1", Text .. Extension);
    self:SetSubtitlesPosition(_PlayerID, _PageID);
end

function ModuleDialogSystem.Local:SetSubtitlesPosition(_PlayerID, _PageID)
    local Page = self.Dialog[_PlayerID][_PageID];
    local MotherWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    local Height = XGUIEng.GetTextHeight(MotherWidget.. "/VoiceText1", true);
    local W, H = XGUIEng.GetWidgetSize(MotherWidget.. "/VoiceText1");
    local X,Y = XGUIEng.GetWidgetLocalPosition(MotherWidget);
    if Page.Actor then
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 120);
        Y = 675 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, X, Y);
    else
        XGUIEng.SetWidgetSize(MotherWidget.. "/BG", W + 10, Height + 35);
        Y = 1115 - Height;
        XGUIEng.SetWidgetLocalPosition(MotherWidget, 46, Y);
    end
end

function ModuleDialogSystem.Local:ResetSubtitlesPosition(_PlayerID)
    local Position = self.Dialog[_PlayerID].Backup.SubTitles;
    local SubtitleWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
    XGUIEng.SetWidgetLocalPosition(SubtitleWidget, Position[1], Position[2]);
end

-- This is needed to reset the timer buttons after the portrait widget has been
-- abused to show the actor in the dialog.
function ModuleDialogSystem.Local:ResetTimerButtons(_PlayerID)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if not g_Interaction.TimerQuests then
        return;
    end
    local MainWidget = "/InGame/Root/Normal/AlignTopLeft/QuestTimers/";
    for i= 1,6 do
        local ButtonWidget = MainWidget ..i.. "/TimerButton";
        local QuestIndex = g_Interaction.TimerQuests[i];
        if QuestIndex ~= nil then
            local Quest = Quests[QuestIndex];
            if g_Interaction.CurrentMessageQuestIndex == QuestIndex and not QuestLog.IsQuestLogShown() then
                g_Interaction.CurrentMessageQuestIndex = nil;
                g_VoiceMessageIsRunning = false;
                g_VoiceMessageEndTime = nil;
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait", 0);
                XGUIEng.ShowWidget(QuestLog.Widget.Main, 0);
                XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);
                XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
                XGUIEng.HighLightButton(ButtonWidget, 0);
            end
            if Quest then
                self:DisplayActorPortrait(Quest.SendingPlayer);
            end
        end
    end
end

function ModuleDialogSystem.Local:DisplayActorPortrait(_PlayerID, _HeadModel)
    local PortraitWidget = "/InGame/Root/Normal/AlignBottomLeft/Message";
    local Actor = g_PlayerPortrait[_PlayerID];
    if _HeadModel then
        -- Just because I am paranoid... Should never happen.
        if not Models["Heads_" .. tostring(_HeadModel)] then
            _HeadModel = "H_NPC_Generic_Trader";
        end
        Actor = _HeadModel;
    end
    XGUIEng.ShowWidget(PortraitWidget.. "/MessagePortrait", 1);
    XGUIEng.ShowWidget(PortraitWidget.. "/QuestObjectives", 0);
    SetPortraitWithCameraSettings(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", Actor);
    GUI.PortraitWidgetSetRegister(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", "Mood_Friendly", 1,2,0);
    GUI.PortraitWidgetSetRegister(PortraitWidget.. "/MessagePortrait/3DPortraitFaceFX", "Mood_Angry", 1,2,0);
end

function ModuleDialogSystem.Local:DisplayPageOptionsDialog(_PlayerID, _PageID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Screen = {GUI.GetScreenSize()};
    local Page = self.Dialog[_PlayerID][_PageID];
    local Listbox = XGUIEng.GetWidgetID(Widget .. "/ListBox");

    -- Save original coordinates of sound provider selection
    self.Dialog[_PlayerID].MCSelectionBoxPosition = {
        XGUIEng.GetWidgetScreenPosition(Widget)
    };

    -- Fill sound provider selection with options
    XGUIEng.ListBoxPopAll(Listbox);
    self.Dialog[_PlayerID].MCSelectionOptionsMap = {};
    for i=1, #Page.MC, 1 do
        if Page.MC[i].Visible ~= false then
            XGUIEng.ListBoxPushItem(Listbox, Page.MC[i][1]);
            table.insert(self.Dialog[_PlayerID].MCSelectionOptionsMap, Page.MC[i].ID);
        end
    end
    XGUIEng.ListBoxSetSelectedIndex(Listbox, 0);

    -- Set choice position
    local ChoiceSize = {XGUIEng.GetWidgetScreenSize(Widget)};
    local CX = math.ceil((Screen[1] * 0.05) + (ChoiceSize[1] /2));
    local CY = math.ceil(Screen[2] - (ChoiceSize[2] + 60 * (Screen[2]/540)));
    if not Page.Actor then
        CX = 15 * (Screen[1]/960);
        CY = math.ceil(Screen[2] - (ChoiceSize[2] + 0 * (Screen[2]/540)));
    end
    XGUIEng.SetWidgetScreenPosition(Widget, CX, CY);
    XGUIEng.PushPage(Widget, false);
    XGUIEng.ShowWidget(Widget, 1);

    -- Set text position
    if not Page.Actor then
        local TextWidget = "/InGame/Root/Normal/AlignBottomLeft/SubTitles";
        local DX,DY = XGUIEng.GetWidgetLocalPosition(TextWidget);
        XGUIEng.SetWidgetLocalPosition(TextWidget, DX, DY-220);
    end

    self.Dialog[_PlayerID].MCSelectionIsShown = true;
end

function ModuleDialogSystem.Local:OnOptionSelected(_PlayerID)
    local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
    local Position = self.Dialog[_PlayerID].MCSelectionBoxPosition;
    XGUIEng.SetWidgetScreenPosition(Widget, Position[1], Position[2]);
    XGUIEng.ShowWidget(Widget, 0);
    XGUIEng.PopPage();

    local Selected = XGUIEng.ListBoxGetSelectedIndex(Widget .. "/ListBox")+1;
    local AnswerID = self.Dialog[_PlayerID].MCSelectionOptionsMap[Selected];

    API.SendScriptEvent(QSB.ScriptEvents.DialogOptionSelected, _PlayerID, AnswerID);
    API.BroadcastScriptEventToGlobal(
        "DialogOptionSelected",
        _PlayerID,
        AnswerID
    );
end

function ModuleDialogSystem.Local:ThroneRoomCameraControl(_PlayerID, _Page)
    if _Page then
        if self.Dialog[_PlayerID].MCSelectionIsShown then
            local Widget = "/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer";
            if XGUIEng.IsWidgetShown(Widget) == 0 then
                self.Dialog[_PlayerID].MCSelectionIsShown = false;
                self:OnOptionSelected(_PlayerID);
            end
        end
    end
end

function ModuleDialogSystem.Local:ConvertPosition(_Table)
    local Position = _Table;
    if type(Position) ~= "table" then
        Position = GetPosition(_Table);
    end
    return Position.X, Position.Y, Position.Z;
end

function ModuleDialogSystem.Local:GetCurrentDialog(_PlayerID)
    return self.Dialog[_PlayerID];
end

function ModuleDialogSystem.Local:GetCurrentDialogPage(_PlayerID)
    if self.Dialog[_PlayerID] then
        local PageID = self.Dialog[_PlayerID].CurrentPage;
        return self.Dialog[_PlayerID][PageID];
    end
end

function ModuleDialogSystem.Local:GetPageIDByName(_PlayerID, _Name)
    if type(_Name) == "string" then
        if self.Dialog[_PlayerID] ~= nil then
            for i= 1, #self.Dialog[_PlayerID], 1 do
                if type(self.Dialog[_PlayerID][i]) == "table" and self.Dialog[_PlayerID][i].Name == _Name then
                    return i;
                end
            end
        end
        return 0;
    end
    return _Name;
end

function ModuleDialogSystem.Local:IsAnyCinematicEventActive(_PlayerID)
    for k, v in pairs(ModuleGuiEffects.Local.CinematicEventStatus[_PlayerID]) do
        if v == 1 then
            return true;
        end
    end
    return false;
end

function ModuleDialogSystem.Local:OverrideThroneRoomFunctions()
    -- We only need this to update the sound provider list box for the multiple
    -- choice options. We do not even use the throneroom camera.
    GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleDialogSystem = GameCallback_Camera_ThroneroomCameraControl;
    GameCallback_Camera_ThroneroomCameraControl = function(_PlayerID)
        GameCallback_Camera_ThroneroomCameraControl_Orig_ModuleDialogSystem(_PlayerID);
        if _PlayerID == GUI.GetPlayerID() then
            local Dialog = ModuleDialogSystem.Local:GetCurrentDialog(_PlayerID);
            if Dialog ~= nil then
                ModuleDialogSystem.Local:ThroneRoomCameraControl(
                    _PlayerID,
                    ModuleDialogSystem.Local:GetCurrentDialogPage(_PlayerID)
                );
            end
        end
    end
end

function ModuleDialogSystem.Local:ActivateCinematicMode(_PlayerID)
    -- Check for cinematic mode running and UI player
    if self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = true;

    -- Pop loadscreen if visible
    if not self.LoadscreenClosed then
        XGUIEng.PopPage();
    end

    -- Show throneroom updater
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 1);
    XGUIEng.PushPage("/InGame/ThroneRoom/Main", false);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main", 1);
    XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/Main", 0);
    XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/updater", 1);

    -- Show message stuff
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechButtons/SpeechStartAgainOrStop", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 0);
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDialog/Text", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDialog/Title", " ");
    XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionDialog/Objectives", " ");

    -- Change ui state for cinematic
    self.SelectionBackup = {GUI.GetSelectedEntities()};
    GUI.ClearSelection();
    GUI.ClearNotes();
    GUI.ForbidContextSensitiveCommandsInSelectionState();
    GUI.ActivateCutSceneState();
    GUI.SetFeedbackSoundOutputState(0);
    GUI.EnableBattleSignals(false);
    Input.CutsceneMode();
    if not self.Dialog[_PlayerID].EnableFoW then
        Display.SetRenderFogOfWar(0);
    end
    if self.Dialog[_PlayerID].EnableSky then
        Display.SetRenderSky(1);
    end
    if not self.Dialog[_PlayerID].EnableBorderPins then
        Display.SetRenderBorderPins(0);
    end
    Display.SetUserOptionOcclusionEffect(0);
    Camera.SwitchCameraBehaviour(0);

    -- Prepare the fader
    InitializeFader();
    g_Fade.To = 0;
    SetFaderAlpha(0);

    -- Push loadscreen if previously visible
    -- (This should never happen)
    if not self.LoadscreenClosed then
        XGUIEng.PushPage("/LoadScreen/LoadScreen", false);
    end
end

function ModuleDialogSystem.Local:DeactivateCinematicMode(_PlayerID)
    -- Check for cinematic mode running and UI player
    if not self.CinematicActive or GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self.CinematicActive = false;

    -- Reset ui state
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

    -- Hide the message stuff
    XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/SubTitles/VoiceText1", " ");
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechButtons/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait/SpeechStartAgainOrStop", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/Update", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles/Update", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/MessagePortrait", 0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/SubTitles", 0);

    -- Reset the throneroom
    XGUIEng.PopPage();
    XGUIEng.ShowWidget("/InGame/ThroneRoom", 0);

    ModuleGuiEffects.Local:ResetFarClipPlane();
    self:ResetSubtitlesPosition(_PlayerID);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleDialogSystem);

