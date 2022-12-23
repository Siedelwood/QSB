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

Revision:RegisterModule(ModuleDialogSystem);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es Dialoge zu verwenden.
--
-- Dialoge dienen zur Darstellung von Gesprächen. Mit Multiple Choice können
-- dem Spieler mehrere Auswahlmöglichkeiten gegeben, multiple Handlungsstränge
-- gestartet werden. Mittels Sprüngen und Leerseiten kann innerhalb des
-- Dialog navigiert werden.
--
-- Das Dialogsystem soll eine Alternative zu den Briefings darstellen, denen
-- die Darstellung wie im Thronsaal zu "unpersönlich" ist.
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
-- @field DialogStarted        Ein Dialog beginnt (Parameter: PlayerID, DialogTable)
-- @field DialogEnded          Ein Dialog endet (Parameter: PlayerID, DialogTable)
-- @field DialogPageShown      Ein Dialog endet (Parameter: PlayerID, PageIndex)
-- @field DialogOptionSelected Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet einen Dialog.
--
-- Die Funktion bekommt ein Table mit der Dialogdefinition, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- Für einen Dialog können verschiedene spezielle Einstellungen vorgenommen
-- werden.<br>Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start des Dialog ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.DialogStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Dialog ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.DialogEnded aufgerufen!
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
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange der Dialog aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Dialog   Definition des Dialog
-- @param[type=string] _Name     Name des Dialog
-- @param[type=number] _PlayerID Empfänger des Dialog
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Grobes Gerüst eines Briefings
-- function Dialog1(_Name, _PlayerID)
--     local Dialog = {
--         DisableFow = true,
--         DisableBoderPins = true,
--     };
--     local AP, ASP = API.AddDialogPages(Dialog);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Dialog.Starting = function(_Data)
--         -- Mach was tolles hier, wenn es anfängt.
--     end
--     Dialog.Finished = function(_Data)
--         -- Mach was tolles hier, wenn es endet.
--     end
--     API.StartDialog(Dialog, _Name, _PlayerID);
-- end
--
function API.StartDialog(_Dialog, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Dialog) ~= "table" then
        error("API.StartDialog (" .._Name.. "): _Dialog must be a table!");
        return;
    end
    if #_Dialog == 0 then
        error("API.StartDialog (" .._Name.. "): _Dialog does not contain pages!");
        return;
    end
    for i=1, #_Dialog do
        if type(_Dialog[i]) == "table" and not _Dialog[i].__Legit then
            error("API.StartDialog (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Dialog.EnableSky == nil then
        _Dialog.EnableSky = true;
    end
    if _Dialog.EnableFoW == nil then
        _Dialog.EnableFoW = false;
    end
    if _Dialog.EnableGlobalImmortality == nil then
        _Dialog.EnableGlobalImmortality = true;
    end
    if _Dialog.EnableBorderPins == nil then
        _Dialog.EnableBorderPins = false;
    end
    if _Dialog.RestoreGameSpeed == nil then
        _Dialog.RestoreGameSpeed = true;
    end
    if _Dialog.RestoreCamera == nil then
        _Dialog.RestoreCamera = true;
    end
    ModuleDialogSystem.Global:StartDialog(_Name, PlayerID, _Dialog);
end

---
-- Prüft ob für den Spieler gerade ein Dialog aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Dialog ist aktiv
-- @within Anwenderfunktionen
--
function API.IsDialogActive(_PlayerID)
    if Revision.Environment == QSB.Environment.GLOBAL then
        return ModuleDialogSystem.Global:GetCurrentDialog(_PlayerID) ~= nil;
    end
    return ModuleDialogSystem.Local:GetCurrentDialog(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten in einem Dialog und bindet
-- sie an selbigen. Diese Funktion muss vor dem Start eines Dialog aufgerufen
-- werden um Seiten hinzuzufügen.
--
-- @param[type=table] _Dialog Dialog Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @within Anwenderfunktionen
--
-- @usage
-- -- Wenn nur AP benötigt wird.
-- local AP = API.AddPages(Dialog);
-- -- Wenn zusätzlich ASP benötigt wird.
-- local AP, ASP = API.AddPages(Dialog);
--
function API.AddDialogPages(_Dialog)
    ModuleDialogSystem.Global:CreateDialogGetPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddMCPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddRedirect(_Dialog);

    local AP = function(_Page)
        local Page;
        if type(_Page) == "table" then
            if _Page.MC then
                Page = _Dialog:AddMCPage(_Page);
            else
                Page = _Dialog:AddPage(_Page);
            end
        else
            Page = _Dialog:AddRedirect(_Page);
        end
        return Page;
    end

    local ASP = function(...)
        if type(arg[1]) ~= "number" then
            Name = table.remove(arg, 1);
        end
        local Sender   = table.remove(arg, 1);
        local Position = table.remove(arg, 1);
        local Title    = table.remove(arg, 1);
        local Text     = table.remove(arg, 1);
        local Dialog   = table.remove(arg, 1);
        local Action;
        if type(arg[1]) == "function" then
            Action = table.remove(arg, 1);
        end
        return _Dialog:AddPage{
            Name         = Name,
            Title        = Title,
            Text         = Text,
            Actor        = Sender,
            Target       = Position,
            DialogCamera = Dialog == true,
            Action       = Action,
        };
    end
    return AP, ASP;
end

---
-- Erstellt eine Seite für einen Dialog.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- <h5>Dialog Page</h5>
-- Eine Dialog Page stellt den gesprochenen Text mit und ohne Akteur dar.
--
-- <p>(→ Beispiel #1)</p>
-- 
-- Mögliche Felder:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Actor</td>
-- <td>number</td>
-- <td>(optional) Spieler-ID des Akteur</td>
-- </tr>
-- <tr>
-- <td>Titel</td>
-- <td>string</td>
-- <td>(optional) Zeigt den Namen des Sprechers an. (Nur mit Akteur)</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>(optional) Zeigt Text auf der Dialogseite an.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(optional) Führt eine Funktion aus, wenn die aktuelle Dialogseite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>any (string|number|table)</td>
-- <td>Legt die Kameraposition der Seite fest.</td>
-- </tr>
-- <tr>
-- <td>Target</td>
-- <td>any (string|number)</td>
-- <td>Legt das Entity fest, dem die Kamera folgt.</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>number</td>
-- <td>(optional) Bestimmt die Entfernung der Kamera zur Position.</td>
-- </tr>
-- <tr>
-- <td>Rotation</td>
-- <td>number</td>
-- <td>(optional) Rotationswinkel der Kamera. Werte zwischen 0 und 360 sind möglich.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(optional) Table mit möglichen Dialogoptionen. (Multiple Choice)</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn der Page.<br>
-- Die Page benötigt eine Anzeigedauer!</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Abblendens zu Schwarz am Ende der Page.<br>
-- Die Page benötigt eine Anzeigedauer!</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>number</td>
-- <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
-- wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
-- der nächsten mit FadeIn muss immer eine Seite mit FaderAlpha sein!</b></td>
-- </tr>
-- </table>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Dialog kann der Spieler auch zur Auswahl einer Option gebeten
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
-- Um den Dialog zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß der Dialog, das er an dieser
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
-- <p>(→ Beispiel #7)</p>
--
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
--
-- @param[type=table] _Page Spezifikation der Seite
-- @return[type=table] Refernez auf die angelegte Seite
-- @within Dialog
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AP {
--     Title        = "Hero",
--     Text         = "This page has an actor and a choice.",
--     Actor        = 1,
--     Duration     = 2,
--     FadeIn       = 2,
--     Position     = "npc1",
--     DialogCamera = true,
-- };
--
-- @usage
-- -- Beispiel #2: Verwendung von Multiple Choice
-- AP {
--     Title        = "Hero",
--     Text         = "This page has an actor and a choice.",
--     Actor        = 1,
--     Duration     = 2,
--     FadeIn       = 2,
--     Position     = "npc1",
--     DialogCamera = true,
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
-- -- Beispiel #5: Abbruch des Dialog
-- AP()
--
-- @usage
-- -- Beispiel #6: Sprung zu anderer Seite
-- AP("SomePageName")
--
-- @usage
-- -- Beispiel #7: Erfragen der gewählten Antwort
-- Dialog.Finished = function(_Data)
--     local Choosen = _Data:GetPage("Choice"):GetSelected();
--     -- In Choosen steht der Index der Antwort
-- end
-- 
--
function AP(_Data)
    assert(false);
end

---
-- Erstellt eine Seite in vereinfachter Syntax. Es wird davon ausgegangen, dass
-- das Entity ein Siedler ist. Die Kamera schaut den Siedler an.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- @param[type=string]   _Name         (Optional) Name der Seite
-- @param[type=number]   _Sender       Spieler-ID des Akteur
-- @param[type=string]   _Target       Entity auf die die Kamera schaut
-- @param[type=string]   _Title        Name des Sprechers
-- @param[type=string]   _Text         Text der Seite
-- @param[type=boolean]  _DialogCamera Nahsicht an/aus
-- @param[type=function] _Action       (Optional) Callback-Funktion
-- @return[type=table] Referenz auf die Seite
-- @within Dialog
--
-- @usage
-- -- Beispiel ohne Page Name
-- ASP(1, "hans", "Hans", "Ich gehe in die weitel Welt hinein.", true);
-- -- Beispiel mit Page Name
-- ASP("Page1", 1, "hans", "Hans", "Ich gehe in die weitel Welt hinein.", true);
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
-- Fügt Behavior zur Steuerung von Dialogs hinzu.
--
-- @set sort=true
--

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Dialog.
--
-- Jedes Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reprisal
--
function Reprisal_Dialog(...)
    return B_Reprisal_Dialog:new(...);
end

B_Reprisal_Dialog = {
    Name = "Reprisal_Dialog",
    Description = {
        en = "Reprisal: Calls a function to start an new dialog.",
        de = "Vergeltung: Ruft die Funktion auf und startet das enthaltene Dialog.",
        fr = "Rétribution: Appelle la fonction et démarre le dialogue contenu.",
    },
    Parameter = {
        { ParameterType.Default, en = "Dialog name",     de = "Name des Dialog",     fr = "Nom du dialogue" },
        { ParameterType.Default, en = "Dialog function", de = "Funktion mit Dialog", fr = "Fonction du dialogue" },
    },
}

function B_Reprisal_Dialog:GetReprisalTable()
    return { Reprisal.Custom,{self, self.CustomFunction} }
end

function B_Reprisal_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 1) then
        self.Function = _Parameter;
    end
end

function B_Reprisal_Dialog:CustomFunction(_Quest)
    _G[self.Function](self.DialogName, _Quest.ReceivingPlayer);
end

function B_Reprisal_Dialog:Debug(_Quest)
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    if not type(_G[self.Function]) == "function" then
        error(_Quest.Identifier..": "..self.Name..": '"..self.Function.."' was not found!");
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Reprisal_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Ruft die Funktion auf und startet das enthaltene Dialog.
--
-- Jedes Dialog braucht einen eindeutigen Namen!
--
-- @param[type=string] _Name   Bezeichner des Dialog
-- @param[type=string] _Dialog Funktionsname als String
-- @within Reward
--
function Reward_Dialog(...)
    return B_Reward_Dialog:new(...);
end

B_Reward_Dialog = Revision.LuaBase:CopyTable(B_Reprisal_Dialog);
B_Reward_Dialog.Name = "Reward_Dialog";
B_Reward_Dialog.Description.en = "Reward: Calls a function to start an new dialog.";
B_Reward_Dialog.Description.de = "Lohn: Ruft die Funktion auf und startet das enthaltene Dialog.";
B_Reward_Dialog.Description.fr = "Récompense: Appelle la fonction et lance le dialogue qu'elle contient.";
B_Reward_Dialog.GetReprisalTable = nil;

B_Reward_Dialog.GetRewardTable = function(self, _Quest)
    return { Reward.Custom,{self, self.CustomFunction} }
end

Revision:RegisterBehavior(B_Reward_Dialog);

-- -------------------------------------------------------------------------- --

---
-- Prüft, ob ein Dialog beendet ist und startet dann den Quest.
--
-- @param[type=string] _Name     Bezeichner des Dialog
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Waittime (optional) Wartezeit in Sekunden
-- @within Trigger
--
function Trigger_Dialog(...)
    return B_Trigger_Dialog:new(...);
end

B_Trigger_Dialog = {
    Name = "Trigger_Dialog",
    Description = {
        en = "Trigger: Checks if an dialog has concluded and starts the quest if so.",
        de = "Auslöser: Prüft, ob ein Dialog beendet ist und startet dann den Quest.",
        fr = "Déclencheur: Vérifie si un dialogue est terminé et démarre alors la quête.",
    },
    Parameter = {
        { ParameterType.Default,  en = "Dialog name", de = "Name des Dialog", fr = "Nom du dialogue" },
        { ParameterType.PlayerID, en = "Player ID",   de = "Player ID",       fr = "Player ID" },
        { ParameterType.Number,   en = "Wait time",   de = "Wartezeit",       fr = "Temps d'attente" },
    },
}

function B_Trigger_Dialog:GetTriggerTable()
    return { Triggers.Custom2,{self, self.CustomFunction} }
end

function B_Trigger_Dialog:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.DialogName = _Parameter;
    elseif (_Index == 1) then
        self.PlayerID = _Parameter * 1;
    elseif (_Index == 2) then
        _Parameter = _Parameter or 0;
        self.WaitTime = _Parameter * 1;
    end
end

function B_Trigger_Dialog:CustomFunction(_Quest)
    if API.GetCinematicEvent(self.DialogName, self.PlayerID) == CinematicEvent.Concluded then
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

function B_Trigger_Dialog:Debug(_Quest)
    if self.WaitTime < 0 then
        error(string.format("%s: %s: Wait time must be 0 or greater!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.PlayerID < 1 or self.PlayerID > 8 then
        error(string.format("%s: %s: Player-ID must be between 1 and 8!", _Quest.Identifier, self.Name));
        return true;
    end
    if self.DialogName == nil or self.DialogName == "" then
        error(string.format("%s: %s: Dialog name is invalid!", _Quest.Identifier, self.Name));
        return true;
    end
    return false;
end

Revision:RegisterBehavior(B_Trigger_Dialog);

