--[[
Swift_2_InputOutputCore/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

SCP.InputOutputCore = {};

ModuleInputOutputCore = {
    Properties = {
        Name = "ModuleInputOutputCore",
    },

    Global = {};
    Local  = {
        DisableQuestTimerToggling = false,
        CheatsDisabled = false,
        Chat = {
            Data = {},
            History = {},
            Visible = {},
            Widgets = {}
        },
        Requester = {
            ActionFunction = nil,
            ActionRequester = nil,
            Next = nil,
            Queue = {},
        },
    };
    -- This is a shared structure but the values are asynchronous!
    Shared = {
        Colors = {
            red     = "{@color:255,80,80,255}",
            blue    = "{@color:104,104,232,255}",
            yellow  = "{@color:255,255,80,255}",
            green   = "{@color:80,180,0,255}",
            white   = "{@color:255,255,255,255}",
            black   = "{@color:0,0,0,255}",
            grey    = "{@color:140,140,140,255}",
            azure   = "{@color:0,160,190,255}",
            orange  = "{@color:255,176,30,255}",
            amber   = "{@color:224,197,117,255}",
            violet  = "{@color:180,100,190,255}",
            pink    = "{@color:255,170,200,255}",
            scarlet = "{@color:190,0,0,255}",
            magenta = "{@color:190,0,89,255}",
            olive   = "{@color:74,120,0,255}",
            sky     = "{@color:145,170,210,255}",
            tooltip = "{@color:51,51,120,255}",
            lucid   = "{@color:0,0,0,0}",
            none    = "{@color:none}"
        },

        Placeholders = {
            Names = {},
            EntityTypes = {},
        };

        Text = {
            ChooseLanguage = {
                Title = {
                    de = "Wählt die Sprache",
                    en = "Chose your Tongue",
                    fr = "Sélectionnez la langue",
                },
                Text = {
                    de = "Wählt aus der Liste die Sprache aus, in die Handlungstexte übersetzt werden sollen.",
                    en = "Choose from the list below which language story texts shall be presented to you.",
                    fr = "Sélectionne dans la liste la langue dans laquelle les textes narratifs doivent être traduits.",
                }
            }
        }
    };
};

-- Global ------------------------------------------------------------------- --

function ModuleInputOutputCore.Global:OnGameStart()
    QSB.ScriptEvents.ChatOpened = API.RegisterScriptEvent("Event_ChatOpened");
    QSB.ScriptEvents.ChatClosed = API.RegisterScriptEvent("Event_ChatClosed");

    API.RegisterScriptCommand("Cmd_SetDecisionResult", SCP.InputOutputCore.SetDecisionResult);
    API.RegisterScriptCommand("Cmd_SetLanguageResult", SCP.InputOutputCore.SetLanguageResult);
end

function ModuleInputOutputCore.Global:OnEvent(_ID, _Event, ...)
    -- This event is synchronized in multiplayer! HAS to be because it alters
    -- quest data.
    -- FIXME: Input behavior is still not usable in MP!
    if _ID == QSB.ScriptEvents.ChatClosed then
        -- Send event back to all players local script
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ChatClosed, "%s", %d, %s)]],
            arg[1], arg[2], tostring(arg[3] == true)
        ));
        -- Alter quest data
        for i= 1, Quests[0], 1 do
            if Quests[i].State == QuestState.Active and QSB.GoalInputDialogQuest == Quests[i].Identifier then
                for j= 1, #Quests[i].Objectives, 1 do
                    if Quests[i].Objectives[j].Type == Objective.Custom2 then
                        if Quests[i].Objectives[j].Data[1].Name == "Goal_InputDialog" then
                            Quests[i].Objectives[j].Data[1].InputDialogResult = arg[1];
                        end
                    end
                end
            end
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleInputOutputCore.Local:OnGameStart()
    QSB.ScriptEvents.ChatOpened = API.RegisterScriptEvent("Event_ChatOpened");
    QSB.ScriptEvents.ChatClosed = API.RegisterScriptEvent("Event_ChatClosed");

    for i= 1, 8 do
        self.Chat.Data[i] = {};
        self.Chat.History[i] = {};
        self.Chat.Visible[i] = false;
        self.Chat.Widgets[i] = {};
    end

    self:OverrideQuicksave();
    self:OverrideCheats();
    self:OverrideChatLog();
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();
    self:OverrideDebugInput();
    self:OverrideShowQuestTimerButton();
end

function ModuleInputOutputCore.Local:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:OverrideDebugInput();
        self:OverrideCheats();
        self:DialogAltF4Hotkey();
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if arg[3] then
            if arg[1] == "restartmap" then
                API.RestartMap();
            elseif arg[1]:find("^> ") then
                GUI.SendScriptCommand(arg[1]:sub(3), true);
            elseif arg[1]:find("^>> ") then
                GUI.SendScriptCommand(string.format(
                    "Logic.ExecuteInLuaLocalState(\"%s\")",
                    arg[1]:sub(4)
                ), true);
            elseif arg[1]:find("^< ") then
                GUI.SendScriptCommand(string.format(
                    [[Script.Load("%s")]],
                    arg[1]:sub(3)
                ));
            elseif arg[1]:find("^<< ") then
                Script.Load(arg[1]:sub(4));
            elseif arg[1]:find("^clear$") then
                GUI.ClearNotes();
            elseif arg[1]:find("^version$") then
                GUI.AddStaticNote(QSB.Version);
            elseif arg[1] == "dummy" then
                API.Note("Debug: proccessing commands");
            end
        end
        self.DisableQuestTimerToggling = false;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleInputOutputCore.Local:ShowTextWindow(_Data)
    _Data.PlayerID = _Data.PlayerID or 1;
    _Data.Button = _Data.Button or {};
    local PlayerID = GUI.GetPlayerID();
    if _Data.PlayerID ~= PlayerID then
        return;
    end
    if XGUIEng.IsWidgetShown("/InGame/Root/Normal/ChatOptions") == 1 then
        self:UpdateChatLogText(_Data);
        return;
    end
    self.Chat.Data[PlayerID] = _Data;
    self:CloseTextWindow(PlayerID);
    self:AlterChatLog();

    XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ChatLog", _Data.Content);
    XGUIEng.SetText("/InGame/Root/Normal/MessageLog/Name","{center}" .._Data.Caption);
    if _Data.DisableClose then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/Exit",0);
    end
    if _Data.Pause then
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
            XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
        end
    end
    self:ShouldShowSlider(_Data.Content);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",1);
end

function ModuleInputOutputCore.Local:CloseTextWindow(_PlayerID)
    assert(_PlayerID ~= nil);
    local PlayerID = GUI.GetPlayerID();
    if _PlayerID ~= PlayerID then
        return;
    end
    GUI_Chat.CloseChatMenu();
end

function ModuleInputOutputCore.Local:UpdateChatLogText(_Data)
    XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ChatLog", _Data.Content);
end

function ModuleInputOutputCore.Local:AlterChatLog()
    local PlayerID = GUI.GetPlayerID();
    if self.Chat.Visible[PlayerID] then
        return;
    end
    self.Chat.Visible[PlayerID] = true;
    self.Chat.History[PlayerID] = table.copy(g_Chat.ChatHistory);
    g_Chat.ChatHistory = {};
    self:AlterChatLogDisplay();
end

function ModuleInputOutputCore.Local:RestoreChatLog()
    local PlayerID = GUI.GetPlayerID();
    if not self.Chat.Visible[PlayerID] then
        return;
    end
    self.Chat.Visible[PlayerID] = false;
    g_Chat.ChatHistory = {};
    for i= 1, #self.Chat.History[PlayerID] do
        GUI_Chat.ChatlogAddMessage(self.Chat.History[PlayerID][i]);
    end
    self:RestoreChatLogDisplay();
    self.Chat.History[PlayerID] = {};
    self.Chat.Widgets[PlayerID] = {};
    self.Chat.Data[PlayerID] = {};
end

function ModuleInputOutputCore.Local:UpdateToggleWhisperTarget()
    local PlayerID = GUI.GetPlayerID();
    local MotherWidget = "/InGame/Root/Normal/ChatOptions/";
    if not self.Chat.Data[PlayerID] or not self.Chat.Data[PlayerID].Button
    or not self.Chat.Data[PlayerID].Button.Action then
        XGUIEng.ShowWidget(MotherWidget.. "ToggleWhisperTarget",0);
        return;
    end
    local ButtonText = self.Chat.Data[PlayerID].Button.Text;
    XGUIEng.SetText(MotherWidget.. "ToggleWhisperTarget","{center}" ..ButtonText);
end

function ModuleInputOutputCore.Local:ShouldShowSlider(_Text)
    local stringlen = string.len(_Text);
    local iterator  = 1;
    local carreturn = 0;
    while (true)
    do
        local s,e = string.find(_Text, "{cr}", iterator);
        if not e then
            break;
        end
        if e-iterator <= 58 then
            stringlen = stringlen + 58-(e-iterator);
        end
        iterator = e+1;
    end
    if (stringlen + (carreturn*55)) > 1000 then
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogSlider",1);
    end
end

function ModuleInputOutputCore.Local:OverrideChatLog()
    GUI_Chat.ChatlogAddMessage_Orig_InputOutputCore = GUI_Chat.ChatlogAddMessage;
    GUI_Chat.ChatlogAddMessage = function(_Message)
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ChatlogAddMessage_Orig_InputOutputCore(_Message);
            return;
        end
        table.insert(ModuleInputOutputCore.Local.Chat.History[PlayerID], _Message);
    end

    GUI_Chat.DisplayChatLog_Orig_InputOutputCore = GUI_Chat.DisplayChatLog;
    GUI_Chat.DisplayChatLog = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.DisplayChatLog_Orig_InputOutputCore();
        end
    end

    GUI_Chat.CloseChatMenu_Orig_InputOutputCore = GUI_Chat.CloseChatMenu;
    GUI_Chat.CloseChatMenu = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.CloseChatMenu_Orig_InputOutputCore();
            return;
        end
        if ModuleInputOutputCore.Local.Chat.Data[PlayerID].Pause then
            if not Framework.IsNetworkGame() then
                Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
                XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
            end
        end
        ModuleInputOutputCore.Local:RestoreChatLog();
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",0);
    end

    GUI_Chat.ToggleWhisperTargetUpdate_Orig_InputOutputCore = GUI_Chat.ToggleWhisperTargetUpdate;
    GUI_Chat.ToggleWhisperTargetUpdate = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ToggleWhisperTargetUpdate_Orig_InputOutputCore();
            return;
        end
        ModuleInputOutputCore.Local:UpdateToggleWhisperTarget();
    end

    GUI_Chat.CheckboxMessageTypeWhisperUpdate_Orig_InputOutputCore = GUI_Chat.CheckboxMessageTypeWhisperUpdate;
    GUI_Chat.CheckboxMessageTypeWhisperUpdate = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.CheckboxMessageTypeWhisperUpdate_Orig_InputOutputCore();
            return;
        end
    end

    GUI_Chat.ToggleWhisperTarget_Orig_InputOutputCore = GUI_Chat.ToggleWhisperTarget;
    GUI_Chat.ToggleWhisperTarget = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleInputOutputCore.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ToggleWhisperTarget_Orig_InputOutputCore();
            return;
        end
        if ModuleInputOutputCore.Local.Chat.Data[PlayerID].Button.Action then
            local Data = ModuleInputOutputCore.Local.Chat.Data[PlayerID];
            ModuleInputOutputCore.Local.Chat.Data[PlayerID].Button.Action(Data);
        end
    end
end

function ModuleInputOutputCore.Local:AlterChatLogDisplay()
    local PlayerID = GUI.GetPlayerID();

    local w,h,x,y;
    local Widget;
    local MotherWidget = "/InGame/Root/Normal/ChatOptions/";
    x,y = XGUIEng.GetWidgetLocalPosition(MotherWidget.. "ToggleWhisperTarget");
    w,h = XGUIEng.GetWidgetSize(MotherWidget.. "ToggleWhisperTarget");
    self.Chat.Widgets[PlayerID]["ToggleWhisperTarget"] = {X= x, Y= y, W= w, H= h};
    Widget = self.Chat.Widgets[PlayerID]["ToggleWhisperTarget"];

    x,y = XGUIEng.GetWidgetLocalPosition(MotherWidget.. "ChatLog");
    w,h = XGUIEng.GetWidgetSize(MotherWidget.. "ChatLog");
    self.Chat.Widgets[PlayerID]["ChatLog"] = {X= x, Y= y, W= w, H= h};
    Widget = self.Chat.Widgets[PlayerID]["ChatLog"];

    x,y = XGUIEng.GetWidgetLocalPosition(MotherWidget.. "ChatLogSlider");
    w,h = XGUIEng.GetWidgetSize(MotherWidget.. "ChatLogSlider");
    self.Chat.Widgets[PlayerID]["ChatLogSlider"] = {X= x, Y= y, W= w, H= h};
    Widget = self.Chat.Widgets[PlayerID]["ChatLogSlider"];

    XGUIEng.ShowWidget(MotherWidget.. "ChatModeAllPlayers",0);
    XGUIEng.ShowWidget(MotherWidget.. "ChatModeTeam",0);
    XGUIEng.ShowWidget(MotherWidget.. "ChatModeWhisper",0);
    XGUIEng.ShowWidget(MotherWidget.. "ChatChooseModeCaption",0);
    XGUIEng.ShowWidget(MotherWidget.. "Background/TitleBig",1);
    XGUIEng.ShowWidget(MotherWidget.. "Background/TitleBig/Info",0);
    XGUIEng.ShowWidget(MotherWidget.. "ChatLogCaption",0);
    XGUIEng.ShowWidget(MotherWidget.. "BGChoose",0);
    XGUIEng.ShowWidget(MotherWidget.. "BGChatLog",0);
    XGUIEng.ShowWidget(MotherWidget.. "ChatLogSlider",0);

    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/BG",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Close",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Slider",0);
    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Text",0);
    XGUIEng.SetText("/InGame/Root/Normal/MessageLog/Name","{center}Test");
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog",15,90);
    XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog/Name",0,0);
    XGUIEng.SetTextColor("/InGame/Root/Normal/MessageLog/Name",51,51,121,255);

    XGUIEng.SetWidgetSize(MotherWidget.. "ChatLogSlider",46,600);
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ChatLogSlider",780,130);
    XGUIEng.SetWidgetSize(MotherWidget.. "Background/DialogBG/1 (2)/2",150,400);
    XGUIEng.SetWidgetPositionAndSize(MotherWidget.. "Background/DialogBG/1 (2)/3",400,500,350,400);
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ToggleWhisperTarget",280,760);
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ChatLog",140,150);
    XGUIEng.SetWidgetSize(MotherWidget.. "ChatLog",640,560);
end

function ModuleInputOutputCore.Local:RestoreChatLogDisplay()
    local PlayerID = GUI.GetPlayerID();

    local Widget;
    local MotherWidget = "/InGame/Root/Normal/ChatOptions/";
    Widget = self.Chat.Widgets[PlayerID]["ToggleWhisperTarget"];
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ToggleWhisperTarget", Widget.X, Widget.Y);
    XGUIEng.SetWidgetSize(MotherWidget.. "ToggleWhisperTarget", Widget.W, Widget.H);
    Widget = self.Chat.Widgets[PlayerID]["ChatLog"];
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ChatLog", Widget.X, Widget.Y);
    XGUIEng.SetWidgetSize(MotherWidget.. "ChatLog", Widget.W, Widget.H);
    Widget = self.Chat.Widgets[PlayerID]["ChatLogSlider"];
    XGUIEng.SetWidgetLocalPosition(MotherWidget.. "ChatLogSlider", Widget.X, Widget.Y);
    XGUIEng.SetWidgetSize(MotherWidget.. "ChatLogSlider", Widget.W, Widget.H);

    XGUIEng.ShowWidget(MotherWidget.. "ChatModeAllPlayers",1);
    XGUIEng.ShowWidget(MotherWidget.. "ChatModeTeam",1);
    XGUIEng.ShowWidget(MotherWidget.. "ChatModeWhisper",1);
    XGUIEng.ShowWidget(MotherWidget.. "ChatChooseModeCaption",1);
    XGUIEng.ShowWidget(MotherWidget.. "Background/TitleBig",1);
    XGUIEng.ShowWidget(MotherWidget.. "Background/TitleBig/Info",1);
    XGUIEng.ShowWidget(MotherWidget.. "ChatLogCaption",1);
    XGUIEng.ShowWidget(MotherWidget.. "BGChoose",1);
    XGUIEng.ShowWidget(MotherWidget.. "BGChatLog",1);
    XGUIEng.ShowWidget(MotherWidget.. "ChatLogSlider",1);
    XGUIEng.ShowWidget(MotherWidget.. "ToggleWhisperTarget",1);

    XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",0);
end

-- -------------------------------------------------------------------------- --

function ModuleInputOutputCore.Local:OverrideQuicksave()
    API.AddBlockQuicksaveCondition(function()
        return ModuleInputOutputCore.Local.DialogWindowShown;
    end);

    KeyBindings_SaveGame = function(...)
        if not Swift:CanDoQuicksave(unpack(arg)) then
            return;
        end
        if g_Throneroom ~= nil
        or Framework and Framework.IsNetworkGame()
        or XGUIEng.IsWidgetShownEx("/InGame/MissionStatistic") == 1
        or GUI_Window.IsOpen("MissionEndScreen")
        or XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 1
        or XGUIEng.IsWidgetShownEx("/InGame/Dialog") == 1 then
            return;
        end
        OpenDialog(
            XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. "QuickSave",
            XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}"
        );
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Dialog_SetUpdateCallback(KeyBindings_SaveGame_Delayed);
    end

    SaveDialog_HoldGameState = function(name)
        SaveDialog.Name = name;
        if SaveDialog_SearchFilename(name) == true then
            OpenRequesterDialog(
                "{cr}" .. name .. " : " .. XGUIEng.GetStringTableText("UI_Texts/ConfirmOverwriteFile"),
                XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"),
                "SaveDialog_SaveFile()"
            );
        else
            SaveDialog_SaveFile();
        end
    end

    SaveDialog_SaveFile = function()
        CloseSaveDialog();
        GUI_Window.Toggle("MainMenu");
        local SaveMsgText;
        if string.len(SaveDialog.Name) > 15 then
            SaveMsgText = XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. SaveDialog.Name;
        else
            SaveMsgText = XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. SaveDialog.Name;
        end
        OpenDialog(SaveMsgText, XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}");
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame(SaveDialog.Name,"--");
    end

    GUI_Window.MainMenuSaveClicked = function()
        GUI_Window.CloseInGameMenu();
        OpenDialog(
            XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center") .. "{cr}{cr}{cr}{cr}{cr}" .. "QuickSave",
            XGUIEng.GetStringTableText("UI_Texts/Saving_center") .. "{cr}{cr}{cr}"
        );
        XGUIEng.ShowWidget("/InGame/Dialog/Ok", 0);
        Framework.SaveGame("QuickSave", "Quicksave");
    end
end

function ModuleInputOutputCore.Local:OverrideCheats()
    if self.CheatsDisabled then
        Input.KeyBindDown(
            Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
            "KeyBindings_EnableDebugMode(0)",
            2,
            false
        );
    else
        Input.KeyBindDown(
            Keys.ModifierControl + Keys.ModifierShift + Keys.Divide,
            "KeyBindings_EnableDebugMode(1)",
            2,
            false
        );
    end
end

-- Override the original usage of the chat box to make it compatible to this
-- module. Otherwise there would be no reaction whatsoever to console commands.
function ModuleInputOutputCore.Local:OverrideDebugInput()
    StartSimpleJobEx(function (_Time)
        if not API.IsLoadscreenVisible() and Logic.GetTime() > _Time+1 then
            Swift.InitalizeQsbDebugShell = function(self)
                if not self.Debug.DevelopingShell then
                    return;
                end
                Input.KeyBindDown(Keys.ModifierShift + Keys.OemPipe, "API.ShowTextInput(GUI.GetPlayerID(), true)", 2, false);
            end
            Swift:InitalizeQsbDebugShell();
            return true;
        end
    end, Logic.GetTime());
end

function ModuleInputOutputCore.Local:OverrideShowQuestTimerButton()
    GUI_Interaction.TimerButtonClicked_Orig_ModuleInputOutputCore = GUI_Interaction.TimerButtonClicked;
    GUI_Interaction.TimerButtonClicked = function()
        if ModuleInputOutputCore.Local.DisableQuestTimerToggling then
            return;
        end
        GUI_Interaction.TimerButtonClicked_Orig_ModuleInputOutputCore();
    end
end

function ModuleInputOutputCore.Local:DialogAltF4Hotkey()
    StartSimpleJobEx(function ()
        if not API.IsLoadscreenVisible() then
            Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "ModuleInputOutputCore.Local:DialogAltF4Action()", 2, false);
            return true;
        end
    end);
end

function ModuleInputOutputCore.Local:DialogAltF4Action()
    Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "", 30, false);
    self:OpenRequesterDialog(
        GUI.GetPlayerID(),
        XGUIEng.GetStringTableText("UI_Texts/MainMenuExitGame_center"),
        XGUIEng.GetStringTableText("UI_Texts/ConfirmQuitCurrentGame"),
        function (_Yes)
            if _Yes then
                Framework.ExitGame();
            end
            if not Framework.IsNetworkGame() then
                Game.GameTimeSetFactor(GUI.GetPlayerID(), 1);
            end
            if not ModuleDisplayCore or not ModuleDisplayCore.Local.PauseScreenShown then
                XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
            end
            ModuleInputOutputCore.Local:DialogAltF4Hotkey();
        end
    );
    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
    end
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
end

function ModuleInputOutputCore.Local:Callback(_PlayerID)
    if self.Requester.ActionFunction then
        self.Requester.ActionFunction(CustomGame.Knight + 1, _PlayerID);
    end
    self:OnDialogClosed();
end

function ModuleInputOutputCore.Local:CallbackRequester(_yes, _PlayerID)
    if self.Requester.ActionRequester then
        self.Requester.ActionRequester(_yes, _PlayerID);
    end
    self:OnDialogClosed();
end

function ModuleInputOutputCore.Local:OnDialogClosed()
    self:DialogQueueStartNext();
    self:RestoreSaveGame();
end

function ModuleInputOutputCore.Local:DialogQueueStartNext()
    self.Requester.Next = table.remove(self.Requester.Queue, 1);

    DialogQueueStartNext_HiResControl = function()
        local Entry = ModuleInputOutputCore.Local.Requester.Next;
        if Entry and Entry[1] and Entry[2] then
            local Methode = Entry[1];
            ModuleInputOutputCore.Local[Methode]( ModuleInputOutputCore.Local, unpack(Entry[2]) );
            ModuleInputOutputCore.Local.Requester.Next = nil;
        end
        return true;
    end
    StartSimpleHiResJob("DialogQueueStartNext_HiResControl");
end

function ModuleInputOutputCore.Local:DialogQueuePush(_Methode, _Args)
    local Entry = {_Methode, _Args};
    table.insert(self.Requester.Queue, Entry);
end

function ModuleInputOutputCore.Local:OpenDialog(_PlayerID, _Title, _Text, _Action)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");

        _Title = "{center}" .. API.ConvertPlaceholders(_Title);
        _Text  = API.ConvertPlaceholders(_Text);
        if string.len(_Text) < 35 then
            _Text = _Text .. "{cr}";
        end

        g_MapAndHeroPreview.SelectKnight = function(_Knight)
        end

        XGUIEng.ShowAllSubWidgets("/InGame/Dialog/BG",1);
        XGUIEng.ShowWidget("/InGame/Dialog/Backdrop",0);
        XGUIEng.ShowWidget(RequesterDialog,1);
        XGUIEng.ShowWidget(RequesterDialog_Yes,0);
        XGUIEng.ShowWidget(RequesterDialog_No,0);
        XGUIEng.ShowWidget(RequesterDialog_Ok,1);

        if type(_Action) == "function" then
            self.Requester.ActionFunction = _Action;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local, GUI.GetPlayerID())";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        else
            self.Requester.ActionFunction = nil;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local, GUI.GetPlayerID())";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        end

        XGUIEng.SetText(RequesterDialog_Message, "{center}" .. _Text);
        XGUIEng.SetText(RequesterDialog_Title, _Title);
        XGUIEng.SetText(RequesterDialog_Title.."White", _Title);
        XGUIEng.PushPage(RequesterDialog,false);

        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 0);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 0);
        self.DialogWindowShown = true;
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
            XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
        end
    else
        self:DialogQueuePush("OpenDialog", {_PlayerID, _Title, _Text, _Action});
    end
end

function ModuleInputOutputCore.Local:OpenRequesterDialog(_PlayerID, _Title, _Text, _Action, _OkCancel)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");
        _Title = "{center}" .. _Title;

        self:OpenDialog(_PlayerID, _Title, _Text, _Action);
        XGUIEng.ShowWidget(RequesterDialog_Yes,1);
        XGUIEng.ShowWidget(RequesterDialog_No,1);
        XGUIEng.ShowWidget(RequesterDialog_Ok,0);

        if _OkCancel then
            XGUIEng.SetText(RequesterDialog_Yes, XGUIEng.GetStringTableText("UI_Texts/Ok_center"));
            XGUIEng.SetText(RequesterDialog_No, XGUIEng.GetStringTableText("UI_Texts/Cancel_center"));
        else
            XGUIEng.SetText(RequesterDialog_Yes, XGUIEng.GetStringTableText("UI_Texts/Yes_center"));
            XGUIEng.SetText(RequesterDialog_No, XGUIEng.GetStringTableText("UI_Texts/No_center"));
        end

        self.Requester.ActionRequester = nil;
        if _Action then
            assert(type(_Action) == "function");
            self.Requester.ActionRequester = _Action;
        end
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
        Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.CallbackRequester(ModuleInputOutputCore.Local, true, GUI.GetPlayerID())"
        XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.CallbackRequester(ModuleInputOutputCore.Local, false, GUI.GetPlayerID())"
        XGUIEng.SetActionFunction(RequesterDialog_No, Action);
    else
        self:DialogQueuePush("OpenRequesterDialog", {_PlayerID, _Title, _Text, _Action, _OkCancel});
    end
end

function ModuleInputOutputCore.Local:OpenSelectionDialog(_PlayerID, _Title, _Text, _Action, _List)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        self:OpenDialog(_PlayerID, _Title, _Text, _Action);

        local HeroComboBoxID = XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList);
        XGUIEng.ListBoxPopAll(HeroComboBoxID);
        for i=1,#_List do
            XGUIEng.ListBoxPushItem(HeroComboBoxID, _List[i] );
        end
        XGUIEng.ListBoxSetSelectedIndex(HeroComboBoxID, 0);
        CustomGame.Knight = 0;

        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleInputOutputCore.Local.Callback(ModuleInputOutputCore.Local, GUI.GetPlayerID())";
        XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);

        local Container = "/InGame/Singleplayer/CustomGame/ContainerSelection/";
        XGUIEng.SetText(Container .. "HeroComboBoxMain/HeroComboBox", "");
        if _List[1] then
            XGUIEng.SetText(Container .. "HeroComboBoxMain/HeroComboBox", _List[1]);
        end
        XGUIEng.PushPage(Container .. "HeroComboBoxContainer", false);
        XGUIEng.PushPage(Container .. "HeroComboBoxMain",false);
        XGUIEng.ShowWidget(Container .. "HeroComboBoxContainer", 0);
        local screen = {GUI.GetScreenSize()};
        local x1, y1 = XGUIEng.GetWidgetScreenPosition(RequesterDialog_Ok);
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxMain", x1-25, y1-(90*(screen[2]/1080)));
        XGUIEng.SetWidgetScreenPosition(Container .. "HeroComboBoxContainer", x1-25, y1-(20*(screen[2]/1080)));
    else
        self:DialogQueuePush("OpenSelectionDialog", {_PlayerID, _Title, _Text, _Action, _List});
    end
end

function ModuleInputOutputCore.Local:RestoreSaveGame()
    if not ModuleInterfaceCore or not ModuleInterfaceCore.Local.ForbidRegularSave then
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave", 1);
        XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame", 1);
    end
    self.DialogWindowShown = false;
end

function ModuleInputOutputCore.Local:DialogOverwriteOriginal()
    OpenDialog_Orig_Windows = OpenDialog;
    OpenDialog = function(_Message, _Title, _IsMPError)
        if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            OpenDialog_Orig_Windows(_Title, _Message);
        end
    end

    OpenRequesterDialog_Orig_Windows = OpenRequesterDialog;
    OpenRequesterDialog = function(_Message, _Title, action, _OkCancel, no_action)
        if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; XGUIEng.PopPage()";
            XGUIEng.SetActionFunction(RequesterDialog_No, Action);
            OpenRequesterDialog_Orig_Windows(_Message, _Title, action, _OkCancel, no_action);
        end
    end
end

function ModuleInputOutputCore.Local:ShowInputBox(_PlayerID, _Debug)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    Swift.Debug:SetProcessDebugCommands(_Debug);
    StartSimpleHiResJob("ModuleInputOutputCore_Local_InputBoxJob");
end

function ModuleInputOutputCore_Local_InputBoxJob()
    Input.ChatMode();
    if not Framework.IsNetworkGame() then
        Game.GameTimeSetFactor(GUI.GetPlayerID(), 0.0000001);
    end
    XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "");
    XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 1);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 1);
    XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput");

    ModuleInputOutputCore.Local.DisableQuestTimerToggling = true;
    -- Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ModuleInputOutputCore_Local_DisableQuestToggle", 1, {}, {GUI.GetPlayerID()});
    return true;
end

function ModuleInputOutputCore_Local_DisableQuestToggle(_PlayerID)
    if GUI.GetPlayerID() == _PlayerID then
        ModuleInputOutputCore.Local.DisableQuestTimerToggling = true;
    end
    return true;
end

function ModuleInputOutputCore.Local:PrepareInputVariable(_PlayerID)
    -- FIXME: Must this be syncronized? Who has opened the chat is totaly
    -- uninteresting in the global script i.m.o
    API.SendScriptEventToGlobal(QSB.ScriptEvents.ChatOpened, _PlayerID);
    API.SendScriptEvent(QSB.ScriptEvents.ChatOpened, _PlayerID);

    GUI_Chat.Abort_Orig_ModuleInputOutputCore = GUI_Chat.Abort_Orig_ModuleInputOutputCore or GUI_Chat.Abort;
    GUI_Chat.Confirm_Orig_ModuleInputOutputCore = GUI_Chat.Confirm_Orig_ModuleInputOutputCore or GUI_Chat.Confirm;

    GUI_Chat.Confirm = function()
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput", 0);
        if not ModuleDisplayCore or not ModuleDisplayCore.Local.PauseScreenShown then
            XGUIEng.ShowWidget("/InGame/Root/Normal/PauseScreen", 0);
        end
        local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput");
        local IsDebug = Swift.Debug:IsProcessDebugCommands();
        Swift.ChatBoxInput = ChatMessage;
        ModuleInputOutputCore.Local:LocalToGlobal(ChatMessage, IsDebug);
        g_Chat.JustClosed = 1;
        if not Framework.IsNetworkGame() then
            Game.GameTimeSetFactor(_PlayerID, 1);
        end
        Input.GameMode();
        if ChatMessage:len() > 0 and Framework.IsNetworkGame() and not IsDebug then
            GUI.SendChatMessage(ChatMessage, _PlayerID, g_Chat.CurrentMessageType, g_Chat.CurrentWhisperTarget);
        end
    end

    if not Framework.IsNetworkGame() then
        GUI_Chat.Abort = function()
        end
    end
end

function ModuleInputOutputCore.Local:LocalToGlobal(_Text, _Debug)
    _Text = (_Text == nil and "") or _Text;
    API.BroadcastScriptEventToGlobal(
        QSB.ScriptEvents.ChatClosed,
        (_Text or "<<<ES>>>"),
        GUI.GetPlayerID(),
        _Debug == true
    );
    Swift.Debug:SetProcessDebugCommands(false);
end

-- Shared ------------------------------------------------------------------- --

function ModuleInputOutputCore.Shared:Note(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddNote("%s")]],
            _Text
        ));
    else
        GUI.AddNote(_Text);
    end
end

function ModuleInputOutputCore.Shared:StaticNote(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[GUI.AddStaticNote("%s")]],
            _Text
        ));
        return;
    end
    GUI.AddStaticNote(_Text);
end

function ModuleInputOutputCore.Shared:Message(_Text)
    _Text = self:ConvertPlaceholders(Swift:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Message("%s")]],
            _Text
        ));
        return;
    end
    Message(_Text);
end

function ModuleInputOutputCore.Shared:ClearNotes()
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState([[GUI.ClearNotes()]]);
        return;
    end
    GUI.ClearNotes();
end

function ModuleInputOutputCore.Shared:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{n:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{n:");
            Replacement = self.Placeholders.Names[Placeholder];
            _Text = Before .. Swift:Localize(Replacement or ("n:" ..tostring(Placeholder).. ": not found")) .. After;
        elseif _Text:find("{t:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{t:");
            Replacement = self.Placeholders.EntityTypes[Placeholder];
            _Text = Before .. Swift:Localize(Replacement or ("n:" ..tostring(Placeholder).. ": not found")) .. After;
        elseif _Text:find("{v:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{v:");
            Replacement = self:ReplaceValuePlaceholder(Placeholder);
            _Text = Before .. Swift:Localize(Replacement or ("v:" ..tostring(Placeholder).. ": not found")) .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

function ModuleInputOutputCore.Shared:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

function ModuleInputOutputCore.Shared:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(self.Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

function ModuleInputOutputCore.Shared:ReplaceValuePlaceholder(_Text)
    local Ref = _G;
    local Slice = string.slice(_Text, "%.");
    for i= 1, #Slice do
        local KeyOrIndex = Slice[i];
        local Index = tonumber(KeyOrIndex);
        if Index ~= nil then
            KeyOrIndex = Index;
        end
        if not Ref[KeyOrIndex] then
            return nil;
        end
        Ref = Ref[KeyOrIndex];
    end
    return Ref;
end

function ModuleInputOutputCore.Shared:CommandTokenizer(_Input)
    local Commands = {};
    if _Input == nil then
        return Commands;
    end
    local DAmberCommands = {_Input};
    local AmberCommands = {};

    -- parse & delimiter
    local s, e = string.find(_Input, "%s+&&%s+");
    if s then
        DAmberCommands = {};
        while (s) do
            local tmp = string.sub(_Input, 1, s-1);
            table.insert(DAmberCommands, tmp);
            _Input = string.sub(_Input, e+1);
            s, e = string.find(_Input, "%s+&&%s+");
        end
        if string.len(_Input) > 0 then 
            table.insert(DAmberCommands, _Input);
        end
    end

    -- parse & delimiter
    for i= 1, #DAmberCommands, 1 do
        local s, e = string.find(DAmberCommands[i], "%s+&%s+");
        if s then
            local LastCommand = "";
            while (s) do
                local tmp = string.sub(DAmberCommands[i], 1, s-1);
                table.insert(AmberCommands, LastCommand .. tmp);
                if string.find(tmp, " ") then
                    LastCommand = string.sub(tmp, 1, string.find(tmp, " ")-1) .. " ";
                end
                DAmberCommands[i] = string.sub(DAmberCommands[i], e+1);
                s, e = string.find(DAmberCommands[i], "%s+&%s+");
            end
            if string.len(DAmberCommands[i]) > 0 then 
                table.insert(AmberCommands, LastCommand .. DAmberCommands[i]);
            end
        else
            table.insert(AmberCommands, DAmberCommands[i]);
        end
    end

    -- parse spaces
    for i= 1, #AmberCommands, 1 do
        local CommandLine = {};
        local s, e = string.find(AmberCommands[i], "%s+");
        if s then
            while (s) do
                local tmp = string.sub(AmberCommands[i], 1, s-1);
                table.insert(CommandLine, tmp);
                AmberCommands[i] = string.sub(AmberCommands[i], e+1);
                s, e = string.find(AmberCommands[i], "%s+");
            end
            table.insert(CommandLine, AmberCommands[i]);
        else
            table.insert(CommandLine, AmberCommands[i]);
        end
        table.insert(Commands, CommandLine);
    end

    return Commands;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleInputOutputCore);

