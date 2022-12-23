--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleRequester = {
    Properties = {
        Name = "ModuleRequester",
        Version = "4.0.0 (ALPHA 1.0.0)",
    },

    Global = {},
    Local  = {
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
    },

    Shared = {
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
        };
    },
}

-- -------------------------------------------------------------------------- --
-- Global

function ModuleRequester.Global:OnGameStart()
end

function ModuleRequester.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --
-- Local

function ModuleRequester.Local:OnGameStart()
    for i= 1, 8 do
        self.Chat.Data[i] = {};
        self.Chat.History[i] = {};
        self.Chat.Visible[i] = false;
        self.Chat.Widgets[i] = {};
    end

    self:OverrideChatLog();
    self:DialogOverwriteOriginal();
    self:DialogAltF4Hotkey();
end

function ModuleRequester.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:DialogAltF4Hotkey();
    end
end

-- -------------------------------------------------------------------------- --
-- Requester

function ModuleRequester.Local:DialogAltF4Hotkey()
    StartSimpleJobEx(function ()
        if ModuleRequester.Local.LoadscreenClosed then
            Input.KeyBindDown(Keys.ModifierAlt + Keys.F4, "ModuleRequester.Local:DialogAltF4Action()", 2, false);
            return true;
        end
    end);
end

function ModuleRequester.Local:DialogAltF4Action()
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
            ModuleRequester.Local:DialogAltF4Hotkey();
        end
    );
end

function ModuleRequester.Local:Callback(_PlayerID)
    if self.Requester.ActionFunction then
        self.Requester.ActionFunction(CustomGame.Knight + 1, _PlayerID);
    end
    self:OnDialogClosed();
end

function ModuleRequester.Local:CallbackRequester(_yes, _PlayerID)
    if self.Requester.ActionRequester then
        self.Requester.ActionRequester(_yes, _PlayerID);
    end
    self:OnDialogClosed();
end

function ModuleRequester.Local:OnDialogClosed()
    if not self.SavingWasDisabled then
        API.DisableSaving(false);
    end
    self.SavingWasDisabled = false;
    self.DialogWindowShown = false;
    self:DialogQueueStartNext();
end

function ModuleRequester.Local:DialogQueueStartNext()
    self.Requester.Next = table.remove(self.Requester.Queue, 1);

    API.StartHiResJob(function()
        local Entry = ModuleRequester.Local.Requester.Next;
        if Entry and Entry[1] and Entry[2] then
            local Methode = Entry[1];
            ModuleRequester.Local[Methode](ModuleRequester.Local, unpack(Entry[2]));
            ModuleRequester.Local.Requester.Next = nil;
        end
        return true;
    end);
end

function ModuleRequester.Local:DialogQueuePush(_Methode, _Args)
    local Entry = {_Methode, _Args};
    table.insert(self.Requester.Queue, Entry);
end

function ModuleRequester.Local:OpenDialog(_PlayerID, _Title, _Text, _Action)
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    if XGUIEng.IsWidgetShown(RequesterDialog) == 0 then
        assert(type(_Title) == "string");
        assert(type(_Text) == "string");

        _Title = "{center}" .. Revision.Text:ConvertPlaceholders(_Title);
        _Text  = Revision.Text:ConvertPlaceholders(_Text);
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
            Action = Action .. "; ModuleRequester.Local.Callback(ModuleRequester.Local, GUI.GetPlayerID())";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        else
            self.Requester.ActionFunction = nil;
            local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)";
            Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
            Action = Action .. "; XGUIEng.PopPage()";
            Action = Action .. "; ModuleRequester.Local.Callback(ModuleRequester.Local, GUI.GetPlayerID())";
            XGUIEng.SetActionFunction(RequesterDialog_Ok, Action);
        end

        XGUIEng.SetText(RequesterDialog_Message, "{center}" .. _Text);
        XGUIEng.SetText(RequesterDialog_Title, _Title);
        XGUIEng.SetText(RequesterDialog_Title.."White", _Title);
        XGUIEng.PushPage(RequesterDialog,false);

        if Revision.Save.SavingDisabled then
            self.SavingWasDisabled = true;
        end
        API.DisableSaving(true);
        self.DialogWindowShown = true;
    else
        self:DialogQueuePush("OpenDialog", {_PlayerID, _Title, _Text, _Action});
    end
end

function ModuleRequester.Local:OpenRequesterDialog(_PlayerID, _Title, _Text, _Action, _OkCancel)
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
        Action = Action .. "; ModuleRequester.Local.CallbackRequester(ModuleRequester.Local, true, GUI.GetPlayerID())"
        XGUIEng.SetActionFunction(RequesterDialog_Yes, Action);
        local Action = "XGUIEng.ShowWidget(RequesterDialog, 0)"
        Action = Action .. "; if not Framework.IsNetworkGame() then Game.GameTimeSetFactor(GUI.GetPlayerID(), 1) end";
        Action = Action .. "; XGUIEng.PopPage()";
        Action = Action .. "; ModuleRequester.Local.CallbackRequester(ModuleRequester.Local, false, GUI.GetPlayerID())"
        XGUIEng.SetActionFunction(RequesterDialog_No, Action);
    else
        self:DialogQueuePush("OpenRequesterDialog", {_PlayerID, _Title, _Text, _Action, _OkCancel});
    end
end

function ModuleRequester.Local:OpenSelectionDialog(_PlayerID, _Title, _Text, _Action, _List)
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
        Action = Action .. "; ModuleRequester.Local.Callback(ModuleRequester.Local, GUI.GetPlayerID())";
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

function ModuleRequester.Local:DialogOverwriteOriginal()
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

-- -------------------------------------------------------------------------- --
-- Chat Log

function ModuleRequester.Local:ShowTextWindow(_Data)
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
    self:ShouldShowSlider(_Data.Content);
    XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",1);
end

function ModuleRequester.Local:CloseTextWindow(_PlayerID)
    assert(_PlayerID ~= nil);
    local PlayerID = GUI.GetPlayerID();
    if _PlayerID ~= PlayerID then
        return;
    end
    GUI_Chat.CloseChatMenu();
end

function ModuleRequester.Local:UpdateChatLogText(_Data)
    XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ChatLog", _Data.Content);
end

function ModuleRequester.Local:AlterChatLog()
    local PlayerID = GUI.GetPlayerID();
    if self.Chat.Visible[PlayerID] then
        return;
    end
    self.Chat.Visible[PlayerID] = true;
    self.Chat.History[PlayerID] = table.copy(g_Chat.ChatHistory);
    g_Chat.ChatHistory = {};
    self:AlterChatLogDisplay();
end

function ModuleRequester.Local:RestoreChatLog()
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

function ModuleRequester.Local:UpdateToggleWhisperTarget()
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

function ModuleRequester.Local:ShouldShowSlider(_Text)
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

function ModuleRequester.Local:OverrideChatLog()
    GUI_Chat.ChatlogAddMessage_Orig_Requester = GUI_Chat.ChatlogAddMessage;
    GUI_Chat.ChatlogAddMessage = function(_Message)
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ChatlogAddMessage_Orig_Requester(_Message);
            return;
        end
        table.insert(ModuleRequester.Local.Chat.History[PlayerID], _Message);
    end

    GUI_Chat.DisplayChatLog_Orig_Requester = GUI_Chat.DisplayChatLog;
    GUI_Chat.DisplayChatLog = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.DisplayChatLog_Orig_Requester();
        end
    end

    GUI_Chat.CloseChatMenu_Orig_Requester = GUI_Chat.CloseChatMenu;
    GUI_Chat.CloseChatMenu = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.CloseChatMenu_Orig_Requester();
            return;
        end
        ModuleRequester.Local:RestoreChatLog();
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",0);
    end

    GUI_Chat.ToggleWhisperTargetUpdate_Orig_Requester = GUI_Chat.ToggleWhisperTargetUpdate;
    GUI_Chat.ToggleWhisperTargetUpdate = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ToggleWhisperTargetUpdate_Orig_Requester();
            return;
        end
        ModuleRequester.Local:UpdateToggleWhisperTarget();
    end

    GUI_Chat.CheckboxMessageTypeWhisperUpdate_Orig_Requester = GUI_Chat.CheckboxMessageTypeWhisperUpdate;
    GUI_Chat.CheckboxMessageTypeWhisperUpdate = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.CheckboxMessageTypeWhisperUpdate_Orig_Requester();
            return;
        end
    end

    GUI_Chat.ToggleWhisperTarget_Orig_Requester = GUI_Chat.ToggleWhisperTarget;
    GUI_Chat.ToggleWhisperTarget = function()
        local PlayerID = GUI.GetPlayerID();
        if not ModuleRequester.Local.Chat.Visible[PlayerID] then
            GUI_Chat.ToggleWhisperTarget_Orig_Requester();
            return;
        end
        if ModuleRequester.Local.Chat.Data[PlayerID].Button.Action then
            local Data = ModuleRequester.Local.Chat.Data[PlayerID];
            ModuleRequester.Local.Chat.Data[PlayerID].Button.Action(Data);
        end
    end
end

function ModuleRequester.Local:AlterChatLogDisplay()
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

function ModuleRequester.Local:RestoreChatLogDisplay()
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

Revision:RegisterModule(ModuleRequester);

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Stellt verschiedene Dialogfenster zur Verfügung.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="QSB_0_Kernel.api.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Öffnet ein einfaches Textfenster mit dem angegebenen Text.
--
-- Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
-- Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.
--
-- <h5>Multiplayer</h5>
-- Im Multiplayer muss zwingend der Spieler angegeben werden, für den das
-- Fenster angezeigt werden soll.
--
-- @param[type=string] _Caption  Titel des Fenster
-- @param[type=string] _Content  Inhalt des Fenster
-- @param[type=number] _PlayerID Spieler, der das Fenster sieht
-- @within Anwenderfunktionen
--
-- @usage
-- local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,"..
--              " sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--              " magna aliquyam erat, sed diam voluptua. At vero eos et"..
--              " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--              " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--              " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--              " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--              " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--              " et accusam et justo duo dolores et ea rebum. Stet clita"..
--              " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--              " dolor sit amet.";
-- API.TextWindow("Überschrift", Text);
--
function API.TextWindow(_Caption, _Content, _PlayerID)
    _PlayerID = _PlayerID or 1;
    _Caption = API.Localize(_Caption);
    _Content = API.Localize(_Content);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.TextWindow("%s", "%s", %d)]],
            _Caption,
            _Content,
            _PlayerID
        ));
        return;
    end
    ModuleRequester.Local:ShowTextWindow {
        PlayerID = _PlayerID,
        Caption  = _Caption,
        Content  = _Content,
    };
end

---
-- Öffnet einen Info-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- An die Action wird der Spieler übergeben, der den Dialog bestätigt hat.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param                _Action   Funktionsreferenz
-- @within Anwenderfunktionen
--
-- @usage
-- API.DialogInfoBox("Wichtige Information", "Diese Information ist Spielentscheidend!");
--
function API.DialogInfoBox(_PlayerID, _Title, _Text, _Action)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    return ModuleRequester.Local:OpenDialog(_PlayerID, _Title, _Text, _Action);
end

---
-- Öffnet einen Ja-Nein-Dialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
-- Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
-- Entscheidung getroffen hat, plus die ID des Spielers.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title    Titel des Dialog
-- @param[type=string]   _Text     Text des Dialog
-- @param                _Action   Funktionsreferenz
-- @param[type=boolean]  _OkCancel Okay/Abbrechen statt Ja/Nein
-- @within Anwenderfunktionen
--
-- @usage
-- function YesNoAction(_Yes, _PlayerID)
--     if _Yes then GUI.AddNote("Ja wurde gedrückt"); end
-- end
-- API.DialogRequestBox("Frage", "Möchtest du das wirklich tun?", YesNoAction, false);
--
function API.DialogRequestBox(_PlayerID, _Title, _Text, _Action, _OkCancel)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _OkCancel = _Action;
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    return ModuleRequester.Local:OpenRequesterDialog(_PlayerID, _Title, _Text, _Action, _OkCancel);
end

---
-- Öffnet einen Auswahldialog. Sollte bereits ein Dialog zu sehen sein, wird
-- der Dialog der Dialogwarteschlange hinzugefügt.
--
-- In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
-- aus. Anschließend erhält das Callback den Index der selektierten Option und
-- die ID des Spielers, der den Dialog bestätigt hat.
--
-- <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.
--
-- @param[type=string]   _PlayerID (Optional) Empfangender Spieler
-- @param[type=string]   _Title  Titel des Dialog
-- @param[type=string]   _Text   Text des Dialog
-- @param                _Action Funktionsreferenz
-- @param[type=table]    _List   Liste der Optionen
-- @within Anwenderfunktionen
--
-- @usage
-- function OptionsAction(_Idx, _PlayerID)
--     GUI.AddNote(_Idx.. " wurde ausgewählt!");
-- end
-- local List = {"Option A", "Option B", "Option C"};
-- API.DialogSelectBox("Auswahl", "Wähle etwas aus!", OptionsAction, List);
--
function API.DialogSelectBox(_PlayerID, _Title, _Text, _Action, _List)
    if not GUI then
        return;
    end
    if type(_PlayerID) ~= "number" then
        _List = _Action;
        _Action = _Text;
        _Text = _Title;
        _Title = _PlayerID;
        _PlayerID = GUI.GetPlayerID();
    end
    if type(_Title) == "table" then
        _Title = API.Localize(_Title);
    end
    if type(_Text) == "table" then
        _Text  = API.Localize(_Text);
    end
    _Text = _Text .. "{cr}";
    ModuleRequester.Local:OpenSelectionDialog(_PlayerID, _Title, _Text, _Action, _List);
end

---
-- Öffnet den Dialog für die Auswahl der Sprache. Deutsch, Englisch und
-- Französisch sind vorkonfiguriert.
--
-- @param[type=number] _PlayerID (optional) Nur für diesen Spieler anzeigen
-- @within Anwenderfunktionen
--
-- @usage
-- -- Für alle Spieler
-- API.DialogLanguageSelection();
-- -- Nur für Spieler 2 anzeigen
-- API.DialogLanguageSelection(2);
--
function API.DialogLanguageSelection(_PlayerID)
    _PlayerID = _PlayerID or -1
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.DialogLanguageSelection(%d)]],
            _PlayerID
        ));
        return;
    end
    if _PlayerID ~= -1 and GUI.GetPlayerID() ~= _PlayerID then
        return;
    end

    local DisplayedList = {};
    for i= 1, #Revision.Text.Languages do
        table.insert(DisplayedList, Revision.Text.Languages[i][2]);
    end
    local Action = function(_Selected)
        API.BroadcastScriptCommand(
            QSB.ScriptCommands.SetLanguageResult,
            GUI.GetPlayerID(),
            Revision.Text.Languages[_Selected][1]
        );
    end
    local Text = API.Localize(ModuleRequester.Shared.Text.ChooseLanguage);
    API.DialogSelectBox(GUI.GetPlayerID(), Text.Title, Text.Text, Action, DisplayedList);
end

---
-- Fügt eine neue Sprache zur Auswahl hinzu.
--
-- @param[type=string] _Shortcut Kürzel der Sprache (vgl. de, en, ...)
-- @param[type=string] _Name     Anzeigename der Sprache
-- @param[type=string] _Fallback Kürzel der Ausweichsprache
-- @within Anwenderfunktionen
--
-- @usage
-- API.DefineLanguage("sx", "Sächsich", "de")
--
function API.DefineLanguage(_Shortcut, _Name, _Fallback)
    assert(type(_Shortcut) == "string");
    assert(type(_Name) == "string");
    assert(type(_Fallback) == "string");
    for k, v in pairs(Revision.Text.Languages) do
        if v[1] == _Shortcut then
            return;
        end
    end
    table.insert(Revision.Text.Languages, {_Shortcut, _Name, _Fallback});
    Logic.ExecuteInLuaLocalState(string.format([[
        table.insert(Revision.Text.Languages, {"%s", "%s", "%s"})
    ]], _Shortcut, _Name, _Fallback));
end

