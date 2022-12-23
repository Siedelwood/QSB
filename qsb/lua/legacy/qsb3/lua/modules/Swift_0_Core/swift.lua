--[[
Swift_0_Core/Swift

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

API = API or {};
QSB = QSB or {};
SCP = SCP or {
    Core = {}
};

QSB.Version = "Version 3.0.0 BETA (1.1.19-1)";
QSB.Language = nil;
QSB.HumanPlayerID = 1;
QSB.ScriptCommandSequence = 2;
QSB.ScriptCommands = {};
QSB.ScriptEvents = {};
QSB.CustomVariable = {};
QSB.RefillAmounts = {};

Swift = Swift or {};

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

-- Core  -------------------------------------------------------------------- --

Swift = {
    ModuleRegister            = {};
    BehaviorRegister          = {};
    AIProperties              = {};
    NoQuicksaveConditions     = {};
    LanguageRegister          = {
        {"de", "Deutsch", "en"},
        {"en", "English", "en"},
        {"fr", "Français", "en"},
    };
    Environment               = "global";
    LogLevel                  = 2;
    FileLogLevel              = 3;
};

function Swift:LoadCore()
    self.LuaBase:OverrideBaseLua();
    self:DetectEnvironment();
    self:DetectLanguage();

    if self:IsGlobalEnvironment() then
        self.Debug:InitalizeDebugModeGlobal();
        self.Bugfix:InitalizeBugfixesGlobal();
        self.Behavior:InstallBehaviorGlobal();
        self.Event:InitalizeScriptCommands();
        self.Event:InitalizeEventsGlobal();
        self:InitalizeAIVariables();
        self:DisableLogicFestival();
        self:OverrideSaveLoadedCallback();
        self:OverrideQuestSystemGlobal();
        self:OverwriteGeologistRefill();
        self:OverrideSoldierPayment();
        self:OverrideOnMPGameStart();
    end

    if self:IsLocalEnvironment() then
        self.Debug:InitalizeDebugModeLocal();
        self.Bugfix:InitalizeBugfixesLocal();
        self.Behavior:InstallBehaviorLocal();
        self.Event:InitalizeEventsLocal();
        self:OverrideDoQuicksave();
        self:AlterQuickSaveHotkey();
        self:SetEscapeKeyTrigger();
        self:ValidateTerritories();

        -- Saving human player ID makes only sense in singleplayer context
        -- 'cause in multiplayer there would be more than one.
        -- FIXME Find sufficient solution for this!
        if not Framework.IsNetworkGame() then
            local HumanID = GUI.GetPlayerID();
            GUI.SendScriptCommand("QSB.HumanPlayerID = " ..HumanID);
            QSB.HumanPlayerID = HumanID;
        end
        StartSimpleHiResJob("Swift_EventJob_WaitForLoadScreenHidden");
    end
    self:LoadExternFiles();
    self:LoadBehaviors();
    -- Copy texture positions
    if self:IsLocalEnvironment() then
        StartSimpleJobEx(function()
            if Logic.GetTime() > 1 then
                for k, v in pairs(g_TexturePositions) do
                    for kk, vv in pairs(v) do
                        Swift.Event:DispatchScriptCommand(
                            QSB.ScriptCommands.UpdateTexturePosition,
                            GUI.GetPlayerID(),
                            k,
                            kk,
                            vv
                        );
                    end
                end
                return true;
            end
        end);
    end
end

-- Restore Swift

function Swift:OverrideSaveLoadedCallback()
    if Mission_OnSaveGameLoaded then
        Mission_OnSaveGameLoaded_Orig_Swift = Mission_OnSaveGameLoaded;
        Mission_OnSaveGameLoaded = function()
            Mission_OnSaveGameLoaded_Orig_Swift();
            Swift:RestoreAfterLoad();
            Logic.ExecuteInLuaLocalState("Swift:RestoreAfterLoad()");
            Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.SaveGameLoaded);
            Logic.ExecuteInLuaLocalState("Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.SaveGameLoaded)");
        end
    end
end

function Swift:RestoreAfterLoad()
    debug("Loading save game", true);
    self.LuaBase:OverrideBaseLua();
    if self:IsGlobalEnvironment() then
        self.Debug:GlobalRestoreDebugAfterLoad();
        self.Bugfix:GlobalRestoreBugfixesAfterLoad();
        self:DisableLogicFestival();
    end
    if self:IsLocalEnvironment() then
        self.Debug:LocalRestoreDebugAfterLoad();
        self.Bugfix:LocalRestoreBugfixesAfterLoad();
        self:SetEscapeKeyTrigger();
        self:CreateRandomSeed();
        self:AlterQuickSaveHotkey();
    end
end

-- Load files

function Swift:LoadExternFiles()
    if Mission_LoadFiles then
        local FilesList = Mission_LoadFiles();
        for i= 1, #FilesList, 1 do
            if type(FilesList[i]) == "function" then
                FilesList[i]();
            else
                Script.Load(FilesList[i]);
            end
        end
    end
end

-- Environment Detection

function Swift:DetectEnvironment()
    self.Environment = (nil ~= GUI and "local") or "global";
end

function Swift:IsGlobalEnvironment()
    return "global" == self.Environment;
end

function Swift:IsLocalEnvironment()
    return "local" == self.Environment;
end

function Swift:ValidateTerritories()
    local InvalidTerritories = false;
    local Territories = {Logic.GetTerritories()};
    for i= 1, #Territories, 1 do
        local x, y = GUI.ComputeTerritoryPosition(Territories[i]);
        if not x or not y then
            error("Territory " ..Territories[i].. " is invalid!");
            InvalidTerritories = true;
        end
    end
    if InvalidTerritories then
        error ("A territory must have a size greater 0 and no separated areas!");
    end
end

-- Modules

function Swift:LoadModules()
    for i= 1, #self.ModuleRegister, 1 do
        if self:IsGlobalEnvironment() then 
            self.ModuleRegister[i]["Local"] = nil;
            if self.ModuleRegister[i]["Global"].OnGameStart then
                self.ModuleRegister[i]["Global"]:OnGameStart();
            end
        end
        if self:IsLocalEnvironment() then
            self.ModuleRegister[i]["Global"] = nil;
            if self.ModuleRegister[i]["Local"].OnGameStart then
                self.ModuleRegister[i]["Local"]:OnGameStart();
            end
        end
    end
end

function Swift:RegisterModule(_Module)
    if (type(_Module) ~= "table") then
        assert(false, "Modules must be tables!");
        return;
    end
    if _Module.Properties == nil or _Module.Properties.Name == nil then
        assert(false, "Expected name for Module!");
        return;
    end
    table.insert(self.ModuleRegister, _Module);
end

function Swift:IsModuleRegistered(_Name)
    for k, v in pairs(self.ModuleRegister) do
        return v.Properties and v.Properties.Name == _Name;
    end
end

-- Quests

function Swift:OverrideQuestSystemGlobal()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Swift:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
        Swift:SendQuestStateEvent(_quest.Identifier, "QuestTrigger");
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_Quest)
        _Quest:Interrupt_Orig_QSB_Core();

        for i=1, _Quest.Objectives[0] do
            if _Quest.Objectives[i].Type == Objective.Custom2 and _Quest.Objectives[i].Data[1].Interrupt then
                _Quest.Objectives[i].Data[1]:Interrupt(_Quest, i);
            end
        end
        for i=1, _Quest.Triggers[0] do
            if _Quest.Triggers[i].Type == Triggers.Custom2 and _Quest.Triggers[i].Data[1].Interrupt then
                _Quest.Triggers[i].Data[1]:Interrupt(_Quest, i);
            end
        end

        Swift:SendQuestStateEvent(_Quest.Identifier, "QuestInterrupt");
    end

    QuestTemplate.Fail_Orig_QSB_Core = QuestTemplate.Fail;
    QuestTemplate.Fail = function(_Quest)
        _Quest:Fail_Orig_QSB_Core();
        Swift:SendQuestStateEvent(_Quest.Identifier, "QuestFailure");
    end

    QuestTemplate.Success_Orig_QSB_Core = QuestTemplate.Success;
    QuestTemplate.Success = function(_Quest)
        _Quest:Success_Orig_QSB_Core();
        Swift:SendQuestStateEvent(_Quest.Identifier, "QuestSuccess");
    end
end

function Swift:SendQuestStateEvent(_QuestName, _StateName)
    local QuestID = API.GetQuestID(_QuestName);
    if Quests[QuestID] then
        Swift.Event:DispatchScriptEvent(QSB.ScriptEvents[_StateName], QuestID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.Event:DispatchScriptEvent(QSB.ScriptEvents["%s"], %d)]],
            _StateName,
            QuestID
        ));
    end
end

function Swift:ChangeCustomQuestCaptionText(_Text, _Quest)
    if _Quest and _Quest.Visible then
        _Quest.QuestDescription = _Text;
        Logic.ExecuteInLuaLocalState([[
            XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
            local identifier = "]].._Quest.Identifier..[["
            for i=1, Quests[0] do
                if Quests[i].Identifier == identifier then
                    local text = Quests[i].QuestDescription
                    XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                    break
                end
            end
        ]]);
    end
end

-- Behavior

function Swift:LoadBehaviors()
    for i= 1, #self.BehaviorRegister, 1 do
        local Behavior = self.BehaviorRegister[i];

        if not _G["B_" .. Behavior.Name].new then
            _G["B_" .. Behavior.Name].new = function(self, ...)
                local arg = {...};
                local behavior = table.copy(self);
                -- Raw parameters
                behavior.i47ya_6aghw_frxil = {};
                -- Overhead parameters
                behavior.v12ya_gg56h_al125 = {};
                for i= 1, #arg, 1 do
                    table.insert(behavior.v12ya_gg56h_al125, arg[i]);
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end
    end
end

function Swift:RegisterBehavior(_Behavior)
    if self:IsLocalEnvironment() then
        return;
    end
    if type(_Behavior) ~= "table" or _Behavior.Name == nil then
        assert(false, "Behavior is invalid!");
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end
    if not _G["B_" .. _Behavior.Name] then
        error(string.format("Behavior %s does not exist!", _Behavior.Name));
        return;
    end

    for i= 1, #g_QuestBehaviorTypes, 1 do
        if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
            return;
        end
    end
    table.insert(g_QuestBehaviorTypes, _Behavior);
    table.insert(self.BehaviorRegister, _Behavior);
end

-- History Edition

function Swift:IsHistoryEdition()
    return Network.IsNATReady ~= nil;
end

function Swift:IsCommunityPatch()
    return Entities.U_PolarBear ~= nil;
end

function Swift:OverrideDoQuicksave()
    -- Quicksave must not be possible while loading map
    self:AddBlockQuicksaveCondition(function()
        return GUI and XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") ~= 0;
    end);

    KeyBindings_SaveGame_Orig_Module_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function(...)
        if not Swift:CanDoQuicksave(unpack(arg)) then
            return;
        end
        KeyBindings_SaveGame_Orig_Module_SaveGame();
    end
end

function Swift:AlterQuickSaveHotkey()
    StartSimpleHiResJob("Swift_EventJob_AlterQuickSaveHotkey");
end

function Swift:AddBlockQuicksaveCondition(_Function)
    table.insert(self.NoQuicksaveConditions, _Function);
end

function Swift:CanDoQuicksave(...)
    for i= 1, #self.NoQuicksaveConditions, 1 do
        if self.NoQuicksaveConditions[i](unpack(arg)) then
            return false;
        end
    end
    return true;
end

-- Logging

LOG_LEVEL_ALL     = 4;
LOG_LEVEL_INFO    = 3;
LOG_LEVEL_WARNING = 2;
LOG_LEVEL_ERROR   = 1;
LOG_LEVEL_OFF     = 0;

function Swift:Log(_Text, _Level, _Verbose)
    if Swift.FileLogLevel >= _Level then
        local Level = _Text:sub(1, _Text:find(":"));
        local Text = _Text:sub(_Text:find(":")+1);
        Text = string.format(
            " (%s) %s%s",
            Swift.Environment,
            Framework.GetSystemTimeDateString(),
            Text
        )
        Framework.WriteToLog(Level .. Text);
    end
    if _Verbose then
        if self:IsGlobalEnvironment() then
            if Swift.LogLevel >= _Level then
                Logic.ExecuteInLuaLocalState(string.format(
                    [[GUI.AddStaticNote("%s")]],
                    _Text
                ));
            end
            return;
        end
        if Swift.LogLevel >= _Level then
            GUI.AddStaticNote(_Text);
        end
    end
end

function Swift:SetLogLevel(_ScreenLogLevel, _FileLogLevel)
    if self:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.FileLogLevel = %d]],
            (_FileLogLevel or 0)
        ));
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift.LogLevel = %d]],
            (_ScreenLogLevel or 0)
        ));
        self.FileLogLevel = (_FileLogLevel or 0);
        self.LogLevel = (_ScreenLogLevel or 0);
    end
end

-- note that debug is a reserved word in normal lua but in settlers lua debug
-- is removed so it does not matter.
function debug(_Text, _Silent)
    Swift:Log("DEBUG: " .._Text, LOG_LEVEL_ALL, not _Silent);
end
function info(_Text, _Silent)
    Swift:Log("INFO: " .._Text, LOG_LEVEL_INFO, not _Silent);
end
function warn(_Text, _Silent)
    Swift:Log("WARNING: " .._Text, LOG_LEVEL_WARNING, not _Silent);
end
function error(_Text, _Silent)
    Swift:Log("ERROR: " .._Text, LOG_LEVEL_ERROR, not _Silent);
end

-- Language

function Swift:DetectLanguage()
    local DefaultLanguage = Network.GetDesiredLanguage();
    if DefaultLanguage ~= "de" and DefaultLanguage ~= "fr" then
        DefaultLanguage = "en";
    end
    QSB.Language = DefaultLanguage;
end

function Swift:OnLanguageChanged(_PlayerID, _GUI_PlayerID, _Language)
    self:ChangeSystemLanguage(_PlayerID, _Language, _GUI_PlayerID);
end

function Swift:ChangeSystemLanguage(_PlayerID, _Language, _GUI_PlayerID)
    local OldLanguage = QSB.Language;
    local NewLanguage = _Language;
    if _GUI_PlayerID == nil or _GUI_PlayerID == _PlayerID then
        QSB.Language = _Language;
    end

    Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.LanguageSet, OldLanguage, NewLanguage);
    Logic.ExecuteInLuaLocalState(string.format([[
        local OldLanguage = "%s"
        local NewLanguage = "%s"
        if GUI.GetPlayerID() == %d then
            QSB.Language = NewLanguage
        end
        Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.LanguageSet, OldLanguage, NewLanguage)
    ]], OldLanguage, NewLanguage, _PlayerID));
end

function Swift:Localize(_Text)
    local LocalizedText;
    if type(_Text) == "table" then
        LocalizedText = {};
        if _Text.en == nil and _Text[QSB.Language] == nil then
            for k,v in pairs(_Text) do
                if type(v) == "table" then
                    LocalizedText[k] = self:Localize(v);
                end
            end
        else
            if _Text[QSB.Language] then
                LocalizedText = _Text[QSB.Language];
            else
                for k, v in pairs(self.LanguageRegister) do
                    if v[1] == QSB.Language and v[3] ~= nil then
                        LocalizedText = _Text[v[3]];
                        break;
                    end
                end
            end
            if type(LocalizedText) == "table" then
                LocalizedText = "ERROR_NO_TEXT";
            end
        end
    else
        LocalizedText = tostring(_Text);
    end
    return LocalizedText;
end

-- Random Seed

function Swift:CreateRandomSeed()
    local Seed = 0;
    local MapName = Framework.GetCurrentMapName();
    local MapType = Framework.GetCurrentMapTypeAndCampaignName();
    local SeedString = Framework.GetMapGUID(MapName, MapType);
    for PlayerID = 1, 8 do
        if Logic.PlayerGetIsHumanFlag(PlayerID) and Logic.PlayerGetGameState(PlayerID) ~= 0 then
            if GUI.GetPlayerID() == PlayerID then
                local PlayerName = Logic.GetPlayerName(PlayerID);
                local DateText = Framework.GetSystemTimeDateString();
                SeedString = SeedString .. PlayerName .. " " .. DateText;
                for s in SeedString:gmatch(".") do
                    Seed = Seed + ((tonumber(s) ~= nil and tonumber(s)) or s:byte());
                end
                if Framework.IsNetworkGame() then
                    Swift.Event:DispatchScriptCommand(QSB.ScriptCommands.ProclaimateRandomSeed, 0, Seed);
                else
                    GUI.SendScriptCommand("SCP.Core.ProclaimateRandomSeed(" ..Seed.. ")");
                end
            end
            break;
        end
    end
end

function Swift:OverrideOnMPGameStart()
    GameCallback_OnMPGameStart = function()
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "VictoryConditionHandler", 1)
    end
end

-- AI

function Swift:InitalizeAIVariables()
    for i= 1, 8 do
        self.AIProperties[i] = {};
    end
end

function Swift:DisableLogicFestival()
    Swift.Logic_StartFestival = Logic.StartFestival;
    Logic.StartFestival = function(_PlayerID, _Type)
        if Logic.PlayerGetIsHumanFlag(_PlayerID) ~= true then
            if Swift.AIProperties[_PlayerID].ForbidFestival == true then
                return;
            end
        end
        Swift.Logic_StartFestival(_PlayerID, _Type);
    end
end

-- Custom Variable

function Swift:GetCustomVariable(_Name)
    return QSB.CustomVariable[_Name];
end

function Swift:SetCustomVariable(_Name, _Value)
    Swift:UpdateCustomVariable(_Name, _Value);
    local Value = tostring(_Value);
    if type(_Value) ~= "number" then
        Value = [["]] ..Value.. [["]];
    end
    if GUI then
        Swift.Event:DispatchScriptCommand(QSB.ScriptCommands.UpdateCustomVariable, 0, _Name, Value);
    else
        Logic.ExecuteInLuaLocalState(string.format(
            [[Swift:UpdateCustomVariable("%s", %s)]],
            _Name,
            Value
        ));
    end
end

function Swift:UpdateCustomVariable(_Name, _Value)
    if QSB.CustomVariable[_Name] then
        local Old = QSB.CustomVariable[_Name];
        QSB.CustomVariable[_Name] = _Value;
        Swift.Event:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            Old,
            _Value
        );
    else
        QSB.CustomVariable[_Name] = _Value;
        Swift.Event:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            nil,
            _Value
        );
    end
end

-- Boolean variants

-- Logical connectors

NOT = function(_ID, _Predicate)
    local Predicate = table.copy(_Predicate);
    local Function = table.remove(Predicate, 1);
    return not Function(_ID, unpack(Predicate));
end

XOR = function(_ID, ...)
    local Predicates = table.copy(arg);
    local Truths = 0;
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        Truths = Truths + ((Predicate(_ID, unpack(Predicates[i])) and 1) or 0);
    end
    return Truths == 1;
end

ALL = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if not Predicate(_ID, unpack(Predicates[i])) then
            return false;
        end
    end
    return true;
end

ANY = function(_ID, ...)
    local Predicates = table.copy(arg);
    for i= 1, #Predicates do
        local Predicate = table.remove(Predicates[i], 1);
        if Predicate(_ID, unpack(Predicates[i])) then
            return true;
        end
    end
    return false;
end

-- Callbacks

-- Trigger Entity Killed Callbacks

function Swift:TriggerEntityKilledCallbacks(_Entity, _Attacker)
    local DefenderID = GetID(_Entity);
    local AttackerID = GetID(_Attacker or 0);
    if AttackerID == 0 or DefenderID == 0 or Logic.GetEntityHealth(DefenderID) > 0 then
        return;
    end
    local x, y, z     = Logic.EntityGetPos(DefenderID);
    local DefPlayerID = Logic.EntityGetPlayer(DefenderID);
    local DefType     = Logic.GetEntityType(DefenderID);
    local AttPlayerID = Logic.EntityGetPlayer(AttackerID);
    local AttType     = Logic.GetEntityType(AttackerID);

    GameCallback_EntityKilled(DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType);
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_Feedback_EntityKilled(%d, %d, %d, %d,%d, %d, %f, %f)",
        DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType, x, y
    ));
end

-- Escape Callback

function Swift:SetEscapeKeyTrigger()
    Input.KeyBindDown(Keys.Escape, "Swift:ExecuteEscapeCallback()", 30, false);
end

function Swift:ExecuteEscapeCallback()
    -- Global
    API.BroadcastScriptEventToGlobal(
        QSB.ScriptEvents.EscapePressed,
        GUI.GetPlayerID()
    );
    -- Local
    Swift.Event:DispatchScriptEvent(QSB.ScriptEvents.EscapePressed, GUI.GetPlayerID());
end

-- Geologist Refill Callback

function Swift:OverwriteGeologistRefill()
    if Framework.GetGameExtraNo() >= 1 then
        GameCallback_OnGeologistRefill_Orig_QSB_SwiftCore = GameCallback_OnGeologistRefill;
        GameCallback_OnGeologistRefill = function(_PlayerID, _TargetID, _GeologistID)
            GameCallback_OnGeologistRefill_Orig_QSB_SwiftCore(_PlayerID, _TargetID, _GeologistID);
            if QSB.RefillAmounts[_TargetID] then
                local RefillAmount = QSB.RefillAmounts[_TargetID];
                local RefillRandom = RefillAmount + math.random(1, math.floor((RefillAmount * 0.2) + 0.5));
                Logic.SetResourceDoodadGoodAmount(_TargetID, RefillRandom);
                if RefillRandom > 0 then
                    if Logic.GetResourceDoodadGoodType(_TargetID) == Goods.G_Iron then
                        Logic.SetModel(_TargetID, Models.Doodads_D_SE_ResourceIron);
                    else
                        Logic.SetModel(_TargetID, Models.R_ResorceStone_Scaffold);
                    end
                end
            end
        end
    end
end

-- Soldier Payment Callback

function Swift:OverrideSoldierPayment()
    GameCallback_SetSoldierPaymentLevel_Orig = GameCallback_SetSoldierPaymentLevel;
    GameCallback_SetSoldierPaymentLevel = function(_PlayerID, _Level)
        if _Level <= 2 then
            return GameCallback_SetSoldierPaymentLevel_Orig(_PlayerID, _Level);
        end
        Swift.Event:ProcessScriptCommand(_PlayerID, _Level);
    end
end

-- Jobs

function Swift_EventJob_AlterQuickSaveHotkey()
    Input.KeyBindDown(
        Keys.ModifierControl + Keys.S,
        "KeyBindings_SaveGame(true)",
        2,
        false
    );
    return true;
end

function Swift_EventJob_WaitForLoadScreenHidden()
    if XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") == 0 then
        Swift.Event:DispatchScriptCommand(QSB.ScriptCommands.RegisterLoadscreenHidden, GUI.GetPlayerID());
        return true;
    end
end

function Swift_EventJob_PostTexturesToGlobal()
    if Logic.GetTime() > 1 then
        for k, v in pairs(g_TexturePositions) do
            for kk, vv in pairs(v) do
                Swift.Event:DispatchScriptCommand(QSB.ScriptCommands.UpdateTexturePosition, GUI.GetPlayerID(), k, kk, v);
            end
        end
        return true;
    end
end

