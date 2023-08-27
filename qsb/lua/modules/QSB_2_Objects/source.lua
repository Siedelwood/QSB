-- -------------------------------------------------------------------------- --

ModuleObjectInteraction = {
    Properties = {
        Name = "ModuleObjectInteraction",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Data = {},
        SlaveSequence = 0,
    };
    Local  = {
        Data = {},
    };

    Shared = {
        Text = {}
    };
};

QSB.IO = {
    LastHeroEntityID = 0,
    LastObjectEntityID = 0
};

-- Global Script ------------------------------------------------------------ --

function ModuleObjectInteraction.Global:OnGameStart()
    QSB.ScriptEvents.ObjectClicked = API.RegisterScriptEvent("Event_ObjectClicked");
    QSB.ScriptEvents.ObjectInteraction = API.RegisterScriptEvent("Event_ObjectInteraction");
    QSB.ScriptEvents.ObjectReset = API.RegisterScriptEvent("Event_ObjectReset");
    QSB.ScriptEvents.ObjectDelete = API.RegisterScriptEvent("Event_ObjectDelete");

    IO = {};
    IO_UserDefindedNames = {};
    IO_SlaveToMaster = {};
    IO_SlaveState = {};

    self:OverrideObjectInteraction();
    self:StartObjectDestructionController();
    self:StartObjectConditionController();
    self:CreateDefaultObjectNames();
end

function ModuleObjectInteraction.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ObjectInteraction then
        self:OnObjectInteraction(arg[1], arg[2], arg[3]);
    elseif _ID == QSB.ScriptEvents.ChatClosed then
        if arg[3] then
            self:ProcessChatInput(arg[1]);
        end
    end
end

function ModuleObjectInteraction.Global:OnObjectInteraction(_ScriptName, _KnightID, _PlayerID)
    QSB.IO.LastObjectEntityID = GetID(_ScriptName);
    QSB.IO.LastHeroEntityID = _KnightID;

    if IO_SlaveToMaster[_ScriptName] then
        _ScriptName = IO_SlaveToMaster[_ScriptName];
    end
    if IO[_ScriptName] then
        IO[_ScriptName].IsUsed = true;
        Logic.ExecuteInLuaLocalState(string.format(
            [[
                local ScriptName = "%s"
                if IO[ScriptName] then
                    IO[ScriptName].IsUsed = true
                end
            ]],
            _ScriptName
        ));
        if IO[_ScriptName].Action then
            IO[_ScriptName]:Action(_PlayerID, _KnightID);
        end
    end
end

function ModuleObjectInteraction.Global:CreateObject(_Description)
    local ID = GetID(_Description.Name);
    if ID == 0 then
        return;
    end

    if _Description.Callback then
        _Description.Action = _Description.Callback
    end

    self:DestroyObject(_Description.Name);

    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(ID));
    if TypeName and not TypeName:find("^I_X_") then
        self:CreateSlaveObject(_Description);
    end

    _Description.IsActive = true;
    _Description.IsUsed = false;
    _Description.Player = _Description.Player or {1, 2, 3, 4, 5, 6, 7, 8};
    IO[_Description.Name] = _Description;
    Logic.ExecuteInLuaLocalState(string.format(
        [[IO["%s"] = %s]],
        _Description.Name,
        table.tostring(IO[_Description.Name])
    ));
    self:SetupObject(_Description);
    return _Description;
end

function ModuleObjectInteraction.Global:DestroyObject(_ScriptName)
    if not IO[_ScriptName] then
        return;
    end
    if IO[_ScriptName].Slave then
        IO_SlaveToMaster[IO[_ScriptName].Slave] = nil;
        Logic.ExecuteInLuaLocalState(string.format(
            [[IO_SlaveToMaster["%s"] = nil]],
            IO[_ScriptName].Slave
        ));
        IO_SlaveState[IO[_ScriptName].Slave] = nil;
        DestroyEntity(IO[_ScriptName].Slave);
    end
    self:SetObjectState(_ScriptName, 2);
    API.SendScriptEvent(QSB.ScriptEvents.ObjectDelete, _ScriptName);
    Logic.ExecuteInLuaLocalState(string.format(
        [[
            local ScriptName = "%s"
            API.SendScriptEvent(QSB.ScriptEvents.ObjectDelete, ScriptName)
            IO[ScriptName] = nil
        ]],
        _ScriptName
    ));
    IO[_ScriptName] = nil;
end

function ModuleObjectInteraction.Global:CreateSlaveObject(_Object)
    local Name;
    for k, v in pairs(IO_SlaveToMaster) do
        if v == _Object.Name and IsExisting(k) then
            Name = k;
        end
    end
    if Name == nil then
        self.SlaveSequence = self.SlaveSequence +1;
        Name = "QSB_SlaveObject_" ..self.SlaveSequence;
    end

    local SlaveID = GetID(Name);
    if not IsExisting(Name) then
        local x,y,z = Logic.EntityGetPos(GetID(_Object.Name));
        SlaveID = Logic.CreateEntity(Entities.I_X_DragonBoatWreckage, x, y, 0, 0);
        Logic.SetModel(SlaveID, Models.Effects_E_Mosquitos);
        Logic.SetEntityName(SlaveID, Name);
        IO_SlaveToMaster[Name] = _Object.Name;
        Logic.ExecuteInLuaLocalState(string.format(
            [[IO_SlaveToMaster["%s"] = "%s"]],
            Name,
            _Object.Name
        ));
        _Object.Slave = Name;
    end
    IO_SlaveState[Name] = 1;
    return SlaveID;
end

function ModuleObjectInteraction.Global:SetupObject(_Object)
    local ID = GetID((_Object.Slave and _Object.Slave) or _Object.Name);
    Logic.InteractiveObjectClearCosts(ID);
    Logic.InteractiveObjectClearRewards(ID);
    Logic.InteractiveObjectSetInteractionDistance(ID, _Object.Distance);
    Logic.InteractiveObjectSetTimeToOpen(ID, _Object.Waittime);

    local RewardResourceCart = _Object.RewardResourceCartType or Entities.U_ResourceMerchant;
    Logic.InteractiveObjectSetRewardResourceCartType(ID, RewardResourceCart);
    local RewardGoldCart = _Object.RewardGoldCartType or Entities.U_GoldCart;
    Logic.InteractiveObjectSetRewardGoldCartType(ID, RewardGoldCart);
    local CostResourceCart = _Object.CostResourceCartType or Entities.U_ResourceMerchant;
    Logic.InteractiveObjectSetCostResourceCartType(ID, CostResourceCart);
    local CostGoldCart = _Object.CostGoldCartType or Entities.U_GoldCart;
    Logic.InteractiveObjectSetCostGoldCartType(ID, CostGoldCart);

    if GetNameOfKeyInTable(Entities, _Object.Replacement) then
        Logic.InteractiveObjectSetReplacingEntityType(ID, _Object.Replacement);
    end
    if _Object.Reward then
        Logic.InteractiveObjectAddRewards(ID, _Object.Reward[1], _Object.Reward[2]);
    end
    if _Object.Costs and _Object.Costs[1] then
        Logic.InteractiveObjectAddCosts(ID, _Object.Costs[1], _Object.Costs[2]);
    end
    if _Object.Costs and _Object.Costs[3] then
        Logic.InteractiveObjectAddCosts(ID, _Object.Costs[3], _Object.Costs[4]);
    end
    table.insert(HiddenTreasures, ID);
    API.InteractiveObjectActivate(Logic.GetEntityName(ID), _Object.State or 0);
end

function ModuleObjectInteraction.Global:ResetObject(_ScriptName)
    local ID = GetID((IO[_ScriptName].Slave and IO[_ScriptName].Slave) or _ScriptName);
    RemoveInteractiveObjectFromOpenedList(ID);
    table.insert(HiddenTreasures, ID);
    Logic.InteractiveObjectSetAvailability(ID, true);
    self:SetObjectState(ID, IO[_ScriptName].State or 0);
    IO[_ScriptName].IsUsed = false;
    IO[_ScriptName].IsActive = true;

    API.SendScriptEvent(QSB.ScriptEvents.ObjectReset, _ScriptName);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.ObjectReset, "%s")]],
        _ScriptName
    ));
end

function ModuleObjectInteraction.Global:SetObjectState(_ScriptName, _State, ...)
    arg = ((not arg or #arg == 0) and {1, 2, 3, 4, 5, 6, 7, 8}) or arg;
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
    for i= 1, #arg, 1 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), arg[i], _State);
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), _State ~= 2);
end

function ModuleObjectInteraction.Global:CreateDefaultObjectNames()
    IO_UserDefindedNames["D_X_ChestClosed"]    = {
        de = "Schatztruhe",
        en = "Treasure Chest",
        fr = "Coffre au Trésor"
    };
    IO_UserDefindedNames["D_X_ChestOpenEmpty"] = {
        de = "Leere Truhe",
        en = "Empty Chest",
        fr = "Coffre vide"
    };

    Logic.ExecuteInLuaLocalState(string.format(
        [[IO_UserDefindedNames = %s]],
        table.tostring(IO_UserDefindedNames)
    ));
end

function ModuleObjectInteraction.Global:OverrideObjectInteraction()
    GameCallback_OnObjectInteraction = function(_EntityID, _PlayerID)
        OnInteractiveObjectOpened(_EntityID, _PlayerID);
        OnTreasureFound(_EntityID, _PlayerID);

        local ScriptName = Logic.GetEntityName(_EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end
        local KnightIDs = {};
        Logic.GetKnights(_PlayerID, KnightIDs);
        local KnightID = API.GetClosestToTarget(_EntityID, KnightIDs);
        API.SendScriptEvent(QSB.ScriptEvents.ObjectInteraction, ScriptName, KnightID, _PlayerID);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.ObjectInteraction, "%s", %d, %d)]],
            ScriptName,
            KnightID,
            _PlayerID
        ));
    end

    QuestTemplate.AreObjectsActivated = function(self, _ObjectList)
        for i=1, _ObjectList[0] do
            if not _ObjectList[-i] then
                _ObjectList[-i] = GetID(_ObjectList[i]);
            end
            local EntityName = Logic.GetEntityName(_ObjectList[-i]);
            if IO_SlaveToMaster[EntityName] then
                EntityName = IO_SlaveToMaster[EntityName];
            end

            if IO[EntityName] then
                if IO[EntityName].IsUsed ~= true then
                    return false;
                end
            elseif Logic.IsInteractiveObject(_ObjectList[-i]) then
                if not IsInteractiveObjectOpen(_ObjectList[-i]) then
                    return false;
                end
            end
        end
        return true;
    end
end

function ModuleObjectInteraction.Global:ProcessChatInput(_Text)
    local Commands = Swift.Text:CommandTokenizer(_Text);
    for i= 1, #Commands, 1 do
        if Commands[1] == "enableobject" then
            local State = (Commands[3] and tonumber(Commands[3])) or nil;
            local PlayerID = (Commands[4] and tonumber(Commands[4])) or nil;
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.InteractiveObjectActivate(Commands[2], State, PlayerID);
            info("activated object " ..Commands[2].. ".");
        elseif Commands[1] == "disableobject" then
            local PlayerID = (Commands[3] and tonumber(Commands[3])) or nil;
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.InteractiveObjectDeactivate(Commands[2], PlayerID);
            info("deactivated object " ..Commands[2].. ".");
        elseif Commands[1] == "initobject" then
            if not IsExisting(Commands[2]) then
                error("object " ..Commands[2].. " does not exist!");
                return;
            end
            API.SetupObject({
                Name     = Commands[2],
                Waittime = 0,
                State    = 0
            });
            info("quick initalization of object " ..Commands[2].. ".");
        end
    end
end

function ModuleObjectInteraction.Global:StartObjectDestructionController()
    API.StartJobByEventType(Events.LOGIC_EVENT_ENTITY_DESTROYED, function()
        local DestryoedEntityID = Event.GetEntityID();
        local SlaveName  = Logic.GetEntityName(DestryoedEntityID);
        local MasterName = IO_SlaveToMaster[SlaveName];
        if SlaveName and MasterName then
            local Object = IO[MasterName];
            if not Object then
                return;
            end
            info("slave " ..SlaveName.. " of master " ..MasterName.. " has been deleted!");
            info("try to create new slave...");
            IO_SlaveToMaster[SlaveName] = nil;
            Logic.ExecuteInLuaLocalState(string.format(
                [[IO_SlaveToMaster["%s"] = nil]],
                SlaveName
            ));
            local SlaveID = ModuleObjectInteraction.Global:CreateSlaveObject(Object);
            if not IsExisting(SlaveID) then
                error("failed to create slave!");
                return;
            end
            ModuleObjectInteraction.Global:SetupObject(Object);
            if Object.IsUsed == true or (IO_SlaveState[SlaveName] and IO_SlaveState[SlaveName] == 0) then
                API.InteractiveObjectDeactivate(Object.Slave);
            end
            info("new slave created for master " ..MasterName.. ".");
        end
    end);
end

function ModuleObjectInteraction.Global:StartObjectConditionController()
    API.StartHiResJob(function()
        for k, v in pairs(IO) do
            if v and not v.IsUsed and v.IsActive then
                IO[k].IsFullfilled = true;
                if IO[k].Condition then
                    local IsFulfulled = v:Condition();
                    IO[k].IsFullfilled = IsFulfulled;
                end
                Logic.ExecuteInLuaLocalState(string.format(
                    [[
                        local ScriptName = "%s"
                        if IO[ScriptName] then
                            IO[ScriptName].IsFullfilled = %s
                        end
                    ]],
                    k,
                    tostring(IO[k].IsFullfilled)
                ))
            end
        end
    end);
end

-- Local Script ------------------------------------------------------------- --

function ModuleObjectInteraction.Local:OnGameStart()
    QSB.ScriptEvents.ObjectClicked = API.RegisterScriptEvent("Event_ObjectClicked");
    QSB.ScriptEvents.ObjectInteraction = API.RegisterScriptEvent("Event_ObjectInteraction");
    QSB.ScriptEvents.ObjectReset = API.RegisterScriptEvent("Event_ObjectReset");
    QSB.ScriptEvents.ObjectDelete = API.RegisterScriptEvent("Event_ObjectDelete");

    IO = {};
    IO_UserDefindedNames = {};
    IO_SlaveToMaster = {};
    IO_SlaveState = {};

    self:OverrideGameFunctions();
end

function ModuleObjectInteraction.Local:OnEvent(_ID, _ScriptName, _KnightID, _PlayerID)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ObjectReset then
        if IO[_ScriptName] then
            IO[_ScriptName].IsUsed = false;
        end
    elseif _ID == QSB.ScriptEvents.ObjectInteraction then
        QSB.IO.LastObjectEntityID = GetID(_ScriptName);
        QSB.IO.LastHeroEntityID = _KnightID;
    end
end

function ModuleObjectInteraction.Local:OverrideGameFunctions()
    g_CurrentDisplayedQuestID = 0;

    GUI_Interaction.InteractiveObjectClicked_Orig_ModuleObjectInteraction = GUI_Interaction.InteractiveObjectClicked;
    GUI_Interaction.InteractiveObjectClicked = function()
        local i = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local EntityID = g_Interaction.ActiveObjectsOnScreen[i];
        local PlayerID = GUI.GetPlayerID();
        if not EntityID then
            return;
        end
        local ScriptName = Logic.GetEntityName(EntityID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end
        if IO[ScriptName] then
            if not IO[ScriptName].IsFullfilled then
                local Text = XGUIEng.GetStringTableText("UI_ButtonDisabled/PromoteKnight");
                if IO[ScriptName].ConditionInfo then
                    Text = API.ConvertPlaceholders(API.Localize(IO[ScriptName].ConditionInfo));
                end
                Message(Text);
                return;
            end
            if type(IO[ScriptName].Costs) == "table" and #IO[ScriptName].Costs ~= 0 then
                local StoreHouseID = Logic.GetStoreHouse(PlayerID);
                local CastleID     = Logic.GetHeadquarters(PlayerID);
                if StoreHouseID == nil or StoreHouseID == 0 or CastleID == nil or CastleID == 0 then
                    GUI.AddNote("DEBUG: Player needs special buildings when using activation costs!");
                    return;
                end
            end
        end
        GUI_Interaction.InteractiveObjectClicked_Orig_ModuleObjectInteraction();

        -- Send additional click event
        -- This is supposed to be used in singleplayer only!
        if not Framework.IsNetworkGame() then
            local KnightIDs = {};
            Logic.GetKnights(PlayerID, KnightIDs);
            local KnightID = API.GetClosestToTarget(EntityID, KnightIDs);
            API.SendScriptEventToGlobal("ObjectClicked", ScriptName, KnightID, PlayerID);
            API.SendScriptEvent(QSB.ScriptEvents.ObjectClicked, ScriptName, KnightID, PlayerID);
        end
    end

    GUI_Interaction.InteractiveObjectUpdate = function()
        if g_Interaction.ActiveObjects == nil then
            return;
        end

        local PlayerID = GUI.GetPlayerID();
        for i = 1, #g_Interaction.ActiveObjects do
            local ObjectID = g_Interaction.ActiveObjects[i];
            local MasterObjectID = ObjectID;
            local ScriptName = Logic.GetEntityName(ObjectID);
            if IO_SlaveToMaster[ScriptName] then
                MasterObjectID = GetID(IO_SlaveToMaster[ScriptName]);
            end
            local X, Y = GUI.GetEntityInfoScreenPosition(MasterObjectID);
            local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize();
            if X ~= 0 and Y ~= 0 and X > -50 and Y > -50 and X < (ScreenSizeX + 50) and Y < (ScreenSizeY + 50) then
                if not table.contains(g_Interaction.ActiveObjectsOnScreen, ObjectID) then
                    table.insert(g_Interaction.ActiveObjectsOnScreen, ObjectID);
                end
            else
                for i = 1, #g_Interaction.ActiveObjectsOnScreen do
                    if g_Interaction.ActiveObjectsOnScreen[i] == ObjectID then
                        table.remove(g_Interaction.ActiveObjectsOnScreen, i);
                    end
                end
            end
        end

        for i = 1, #g_Interaction.ActiveObjectsOnScreen do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" ..i;
            if XGUIEng.IsWidgetExisting(Widget) == 1 then
                local ObjectID       = g_Interaction.ActiveObjectsOnScreen[i];
                local MasterObjectID = ObjectID;
                local ScriptName     = Logic.GetEntityName(ObjectID);
                if IO_SlaveToMaster[ScriptName] then
                    MasterObjectID = GetID(IO_SlaveToMaster[ScriptName]);
                    ScriptName = Logic.GetEntityName(MasterObjectID);
                end
                local EntityType = Logic.GetEntityType(ObjectID);
                local X, Y = GUI.GetEntityInfoScreenPosition(MasterObjectID);
                local WidgetSize = {XGUIEng.GetWidgetScreenSize(Widget)};
                XGUIEng.SetWidgetScreenPosition(Widget, X - (WidgetSize[1]/2), Y - (WidgetSize[2]/2));
                local BaseCosts = {Logic.InteractiveObjectGetCosts(ObjectID)};
                local EffectiveCosts = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
                local IsAvailable = Logic.InteractiveObjectGetAvailability(ObjectID);
                local HasSpace = Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID);
                local Disable = false;

                if BaseCosts[1] ~= nil and EffectiveCosts[1] == nil and IsAvailable == true then
                    Disable = true;
                end
                if HasSpace == false then
                    Disable = true
                end
                if Disable == false then
                    if IO[ScriptName] and type(IO[ScriptName].Player) == "table" then
                        Disable = not self:IsAvailableForGuiPlayer(ScriptName);
                    elseif IO[ScriptName] and type(IO[ScriptName].Player) == "number" then
                        Disable = IO[ScriptName].Player ~= PlayerID;
                    end
                end

                if Disable == true then
                    XGUIEng.DisableButton(Widget, 1);
                else
                    XGUIEng.DisableButton(Widget, 0);
                end
                if GUI_Interaction.InteractiveObjectUpdateEx1 ~= nil then
                    GUI_Interaction.InteractiveObjectUpdateEx1(Widget, EntityType);
                end
                XGUIEng.ShowWidget(Widget, 1);
            end
        end

        for i = #g_Interaction.ActiveObjectsOnScreen + 1, 2 do
            local Widget = "/InGame/Root/Normal/InteractiveObjects/" .. i;
            XGUIEng.ShowWidget(Widget, 0);
        end

        for i = 1, #g_Interaction.ActiveObjectsOnScreen do
            local Widget     = "/InGame/Root/Normal/InteractiveObjects/" ..i;
            local ObjectID   = g_Interaction.ActiveObjectsOnScreen[i];
            local ScriptName = Logic.GetEntityName(ObjectID);
            if IO_SlaveToMaster[ScriptName] then
                ScriptName = IO_SlaveToMaster[ScriptName];
            end
            if IO[ScriptName] and IO[ScriptName].Texture then
                local FileBaseName;
                local a = (IO[ScriptName].Texture[1]) or 14;
                local b = (IO[ScriptName].Texture[2]) or 10;
                local c = (IO[ScriptName].Texture[3]) or 0;
                if type(c) == "string" then
                    FileBaseName = c;
                    c = 0;
                end
                API.SetIcon(Widget, {a, b, c}, nil, FileBaseName);
            end
        end
    end

    GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction = GUI_Interaction.InteractiveObjectMouseOver;
    GUI_Interaction.InteractiveObjectMouseOver = function()
        local PlayerID = GUI.GetPlayerID();
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        local EntityType = Logic.GetEntityType(ObjectID);

        if g_GameExtraNo > 0 then
            local EntityTypeName = Logic.GetEntityTypeName(EntityType);
            if table.contains ({"R_StoneMine", "R_IronMine", "B_Cistern", "B_Well", "I_X_TradePostConstructionSite"}, EntityTypeName) then
                GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
                return;
            end
        end
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        if string.find(EntityTypeName, "^I_X_") and tonumber(Logic.GetEntityName(ObjectID)) ~= nil then
            GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
            return;
        end
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local ScriptName = Logic.GetEntityName(ObjectID);
        if IO_SlaveToMaster[ScriptName] then
            ScriptName = IO_SlaveToMaster[ScriptName];
        end

        local CheckSettlement;
        if IO[ScriptName] and IO[ScriptName].IsUsed ~= true then
            local Key = "InteractiveObjectAvailable";
            if (IO[ScriptName] and type(IO[ScriptName].Player) == "table" and not self:IsAvailableForGuiPlayer(ScriptName))
            or (IO[ScriptName] and type(IO[ScriptName].Player) == "number" and IO[ScriptName].Player ~= PlayerID)
            or Logic.InteractiveObjectGetAvailability(ObjectID) == false then
                Key = "InteractiveObjectNotAvailable";
            end
            local DisabledKey;
            if Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(ObjectID, PlayerID) == false then
                DisabledKey = "InteractiveObjectAvailableReward";
            end
            local Title = IO[ScriptName].Title or ("UI_ObjectNames/" ..Key);
            Title = API.ConvertPlaceholders(API.Localize(Title));
            if Title and Title:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Title = XGUIEng.GetStringTableText(Title);
            end
            local Text = IO[ScriptName].Text or ("UI_ObjectDescription/" ..Key);
            Text = API.ConvertPlaceholders(API.Localize(Text));
            if Text and Text:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                Text = XGUIEng.GetStringTableText(Text);
            end
            local Disabled = IO[ScriptName].DisabledText or DisabledKey;
            if Disabled then
                Disabled = API.ConvertPlaceholders(API.Localize(Disabled));
                if Disabled and Disabled:find("^[A-Za-z0-9_]+/[A-Za-z0-9_]+$") then
                    Disabled = XGUIEng.GetStringTableText(Disabled);
                end
            end
            Costs = IO[ScriptName].Costs;
            if Costs and Costs[1] and Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                CheckSettlement = true;
            end
            API.SetTooltipCosts(Title, Text, Disabled, Costs, CheckSettlement);
            return;
        end
        GUI_Interaction.InteractiveObjectMouseOver_Orig_ModuleObjectInteraction();
    end

    GUI_Interaction.DisplayQuestObjective_Orig_ModuleObjectInteraction = GUI_Interaction.DisplayQuestObjective
    GUI_Interaction.DisplayQuestObjective = function(_QuestIndex, _MessageKey)
        local QuestIndexTemp = tonumber(_QuestIndex);
        if QuestIndexTemp then
            _QuestIndex = QuestIndexTemp;
        end

        local Quest, QuestType = GUI_Interaction.GetPotentialSubQuestAndType(_QuestIndex);
        local QuestObjectivesPath = "/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives";
        XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives", 0);
        local QuestObjectiveContainer;
        local QuestTypeCaption;

        g_CurrentDisplayedQuestID = _QuestIndex;

        if QuestType == Objective.Object then
            QuestObjectiveContainer = QuestObjectivesPath .. "/List";
            QuestTypeCaption = Wrapped_GetStringTableText(_QuestIndex, "UI_Texts/QuestInteraction");
            local ObjectList = {};

            for i = 1, Quest.Objectives[1].Data[0] do
                local ObjectType;
                if Logic.IsEntityDestroyed(Quest.Objectives[1].Data[i]) then
                    ObjectType = g_Interaction.SavedQuestEntityTypes[_QuestIndex][i];
                else
                    ObjectType = Logic.GetEntityType(GetID(Quest.Objectives[1].Data[i]));
                end
                local ObjectEntityName = Logic.GetEntityName(Quest.Objectives[1].Data[i]);
                local ObjectName = "";
                if ObjectType ~= nil and ObjectType ~= 0 then
                    local ObjectTypeName = Logic.GetEntityTypeName(ObjectType)
                    ObjectName = Wrapped_GetStringTableText(_QuestIndex, "Names/" .. ObjectTypeName);
                    if ObjectName == "" then
                        ObjectName = Wrapped_GetStringTableText(_QuestIndex, "UI_ObjectNames/" .. ObjectTypeName);
                    end
                    if ObjectName == "" then
                        ObjectName = IO_UserDefindedNames[ObjectTypeName];
                    end
                    if ObjectName == nil then
                        ObjectName = IO_UserDefindedNames[ObjectEntityName];
                    end
                    if ObjectName == nil then
                        ObjectName = "Debug: ObjectName missing for " .. ObjectTypeName;
                    end
                end
                table.insert(ObjectList, API.Localize(API.ConvertPlaceholders(ObjectName)));
            end
            for i = 1, 4 do
                local String = ObjectList[i];
                if String == nil then
                    String = "";
                end
                XGUIEng.SetText(QuestObjectiveContainer .. "/Entry" .. i, "{center}" .. String);
            end

            SetIcon(QuestObjectiveContainer .. "/QuestTypeIcon",{14, 10});
            XGUIEng.SetText(QuestObjectiveContainer.."/Caption","{center}"..QuestTypeCaption);
            XGUIEng.ShowWidget(QuestObjectiveContainer, 1);
        else
            GUI_Interaction.DisplayQuestObjective_Orig_ModuleObjectInteraction(_QuestIndex, _MessageKey);
        end
    end
end

function ModuleObjectInteraction.Local:IsAvailableForGuiPlayer(_ScriptName)
    local PlayerID = GUI.GetPlayerID();
    if IO[_ScriptName] and type(IO[_ScriptName].Player) == "table" then
        for i= 1, 8 do
            if IO[_ScriptName].Player[i] and IO[_ScriptName].Player[i] == PlayerID then
                return true;
            end
        end
        return false;
    end
    return true;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleObjectInteraction);

