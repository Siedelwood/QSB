-- -------------------------------------------------------------------------- --

--
-- Es werden einige Fehler im Spiel behoben.
--
-- @set sort=true
-- @local
--

Swift.Bugfix = {};

function Swift.Bugfix:Initalize()
    if Swift.Environment == QSB.Environment.GLOBAL then
        self:FixResourceSlotsInStorehouses();
        self:OverrideConstructionCompleteCallback();
        self:OverrideIsMerchantArrived();
        self:OverrideIsObjectiveCompleted();
        self:FixBanditCampFireplace();
    end
    if Swift.Environment == QSB.Environment.LOCAL then
        self:FixInteractiveObjectClicked();
        self:FixCathedralName();
        self:FixHouseMenuIconsAndCounting();
    end
end

function Swift.Bugfix:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- Luxury for NPCs

function Swift.Bugfix:FixResourceSlotsInStorehouses()
    for i= 1, 8 do
        local StoreHouseID = Logic.GetStoreHouse(i);
        if StoreHouseID ~= 0 then
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Salt, 0, true, true);
            Logic.AddGoodToStock(StoreHouseID, Goods.G_Dye, 0, true, true);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Respawning for ME barracks

function Swift.Bugfix:OverrideConstructionCompleteCallback()
    GameCallback_OnBuildingConstructionComplete_Orig_QSB_Core = GameCallback_OnBuildingConstructionComplete;
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_Core(_PlayerID, _EntityID);
        local EntityType = Logic.GetEntityType(_EntityID);
        if EntityType == Entities.B_NPC_Barracks_ME then
            Logic.RespawnResourceSetMaxSpawn(_EntityID, 0.01);
            Logic.RespawnResourceSetMinSpawn(_EntityID, 0.01);
        end
    end

    for k, v in pairs(Logic.GetEntitiesOfType(Entities.B_NPC_Barracks_ME)) do
        Logic.RespawnResourceSetMaxSpawn(v, 0.01);
        Logic.RespawnResourceSetMinSpawn(v, 0.01);
    end
end

-- -------------------------------------------------------------------------- --
-- Delivery checkpoint

function Swift.Bugfix:OverrideIsMerchantArrived()
    function QuestTemplate:IsMerchantArrived(objective)
        if objective.Data[3] ~= nil then
            if objective.Data[3] == 1 then
                if objective.Data[5].ID ~= nil then
                    objective.Data[3] = objective.Data[5].ID;
                    DeleteQuestMerchantWithID(objective.Data[3]);
                    if MapCallback_DeliverCartSpawned then
                        MapCallback_DeliverCartSpawned(self, objective.Data[3], objective.Data[1]);
                    end
                end
            elseif Logic.IsEntityDestroyed(objective.Data[3]) then
                DeleteQuestMerchantWithID(objective.Data[3]);
                objective.Data[3] = nil;
                objective.Data[5].ID = nil;
            else
                local Target = objective.Data[6] and objective.Data[6] or self.SendingPlayer;
                local StorehouseID = Logic.GetStoreHouse(Target);
                local MarketplaceID = Logic.GetStoreHouse(Target);
                local HeadquartersID = Logic.GetStoreHouse(Target);
                local HasArrived = nil;

                if StorehouseID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(StorehouseID);
                    HasArrived = API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                if MarketplaceID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(MarketplaceID);
                    HasArrived = HasArrived or API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                if HeadquartersID > 0 then
                    local x,y = Logic.GetBuildingApproachPosition(HeadquartersID);
                    HasArrived = HasArrived or API.GetDistance(objective.Data[3], {X= x, Y= y}) < 1000;
                end
                return HasArrived;
            end
        end
        return false;
    end
end

-- -------------------------------------------------------------------------- --
-- IO costs

function Swift.Bugfix:FixInteractiveObjectClicked()
    GUI_Interaction.InteractiveObjectClicked = function()
        local ButtonNumber = tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()));
        local ObjectID = g_Interaction.ActiveObjectsOnScreen[ButtonNumber];
        if ObjectID == nil or not Logic.InteractiveObjectGetAvailability(ObjectID) then
            return;
        end
        local PlayerID = GUI.GetPlayerID();
        local Costs = {Logic.InteractiveObjectGetEffectiveCosts(ObjectID, PlayerID)};
        local CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources");

        -- Check activation costs
        local Affordable = true;
        if Affordable and Costs ~= nil and Costs[1] ~= nil then
            if Costs[1] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[1] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[1]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[1], PlayerID, false) >= Costs[2];
        end
        if Affordable and Costs ~= nil and Costs[3] ~= nil then
            if Costs[3] == Goods.G_Gold then
                CanNotBuyString = XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_G_Gold");
            end
            if Costs[3] ~= Goods.G_Gold and Logic.GetGoodCategoryForGoodType(Costs[3]) ~= GoodCategories.GC_Resource then
                error("Only resources can be used as costs for objects!");
                Affordable = false;
            end
            Affordable = Affordable and GetPlayerGoodsInSettlement(Costs[3], PlayerID, false) >= Costs[4];
        end
        if not Affordable then
            Message(CanNotBuyString);
            return;
        end

        -- Check click override
        if not GUI_Interaction.InteractionClickOverride
        or not GUI_Interaction.InteractionClickOverride(ObjectID) then
            Sound.FXPlay2DSound( "ui\\menu_click");
        end
        -- Check feedback speech override
        if not GUI_Interaction.InteractionSpeechFeedbackOverride
        or not GUI_Interaction.InteractionSpeechFeedbackOverride(ObjectID) then
            GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent", g_FeedbackSpeech.Categories.CartsUnderway, nil, nil);
        end
        -- Check action override and perform action
        if not Mission_Callback_OverrideObjectInteraction
        or not Mission_Callback_OverrideObjectInteraction(ObjectID, PlayerID, Costs) then
            GUI.ExecuteObjectInteraction(ObjectID, PlayerID);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Destroy all units

function Swift.Bugfix:OverrideIsObjectiveCompleted()
    QuestTemplate.IsObjectiveCompleted_Orig_QSB_Kernel = QuestTemplate.IsObjectiveCompleted;
    QuestTemplate.IsObjectiveCompleted = function(self, objective)
        local objectiveType = objective.Type;
        if objective.Completed ~= nil then
            return objective.Completed;
        end
        local data = objective.Data;

        -- Solves the problem that special entities and construction sites
        -- let the script beleave that the player is still alive.
        if objectiveType == Objective.DestroyAllPlayerUnits then
            local PlayerEntities = GetPlayerEntities(data, 0);
            local IllegalEntities = {};

            for i= #PlayerEntities, 1, -1 do
                local Type = Logic.GetEntityType(PlayerEntities[i]);
                if Logic.IsEntityInCategory(PlayerEntities[i], EntityCategories.AttackableBuilding) == 0 or Logic.IsEntityInCategory(PlayerEntities[i], EntityCategories.Wall) == 0 then
                    if Logic.IsConstructionComplete(PlayerEntities[i]) == 0 then
                        table.insert(IllegalEntities, PlayerEntities[i]);
                    end
                end
                local IndestructableEntities = {Entities.XD_ScriptEntity, Entities.S_AIHomePosition, Entities.S_AIAreaDefinition};
                if table.contains(IndestructableEntities, Type) then
                    table.insert(IllegalEntities, PlayerEntities[i]);
                end
            end

            if #PlayerEntities == 0 or #PlayerEntities - #IllegalEntities == 0 then
                objective.Completed = true;
            end
        elseif objectiveType == Objective.Distance then
            objective.Completed = Swift.Behavior:IsQuestPositionReached(self, objective);
        else
            return self:IsObjectiveCompleted_Orig_QSB_Kernel(objective);
        end
    end
end


-- -------------------------------------------------------------------------- --
-- Cathedral name

function Swift.Bugfix:FixCathedralName()
	GUI_BuildingInfo.BuildingNameUpdate_Orig_QSB_Kernel = GUI_BuildingInfo.BuildingNameUpdate;
	GUI_BuildingInfo.BuildingNameUpdate = function()
		GUI_BuildingInfo.BuildingNameUpdate_Orig_QSB_Kernel()
		
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		if XGUIEng.GetText(CurrentWidgetID) == "{center}B_Cathedral_Big" then
			local CurrentLanguage = Network.GetDesiredLanguage()
			if CurrentLanguage == "de" then
				XGUIEng.SetText(CurrentWidgetID, "{center}Kathedrale")
			else
				XGUIEng.SetText(CurrentWidgetID, "{center}Cathedral")
			end
		end
		
	end
end

-- -------------------------------------------------------------------------- --
-- Bandit Fireplace

function Swift.Bugfix:FixBanditCampFireplace()
    g_Outlaws.ReplaceCampType = {};
    g_Outlaws.ReplaceCampType[Entities.D_X_Fireplace01] = Entities.D_X_Fireplace01_Expired;
    g_Outlaws.ReplaceCampType[Entities.D_X_Fireplace02] = Entities.D_X_Fireplace02_Expired;

    ActivateFireplaceforBanditPack = function(_CampID)
        local BanditsPlayerID = Logic.EntityGetPlayer(_CampID);
        if g_Outlaws.Players[BanditsPlayerID][_CampID].CampFire == nil then
            local ApX, ApY = Logic.GetBuildingApproachPosition(_CampID);
            local PosX, PosY = Logic.GetEntityPosition(_CampID);
            local x = (ApX - PosX) * 1.3 + ApX;
            local y = (ApY - PosY) * 1.3 + ApY;

            local FireplaceType = Entities.D_X_Fireplace01;
            if Logic.IsEntityInCategory( _CampID, EntityCategories.Storehouse) == 1 then
                FireplaceType = Entities.D_X_Fireplace02;
            end
            g_Outlaws.Players[BanditsPlayerID][_CampID].CampFireType = FireplaceType;
            local OldID = g_Outlaws.Players[BanditsPlayerID][_CampID].ExtinguishedFire;
            Logic.DestroyEntity(OldID);
            local NewID = Logic.CreateEntityOnUnblockedLand(FireplaceType, x, y, 0, 0);
            g_Outlaws.Players[BanditsPlayerID][_CampID].CampFire = NewID
            g_Outlaws.Players[BanditsPlayerID][_CampID].CampFirePos = {X= x, Y= y};
            return true;
        end
        return false;
    end

    DisableFireplaceforBanditPack = function(_CampID)
        local BanditsPlayerID = Logic.EntityGetPlayer(_CampID);
        if g_Outlaws.Players[BanditsPlayerID][_CampID].CampFire ~= nil then
            local x = g_Outlaws.Players[BanditsPlayerID][_CampID].CampFirePos.X;
            local y = g_Outlaws.Players[BanditsPlayerID][_CampID].CampFirePos.Y;

            local OldID = g_Outlaws.Players[BanditsPlayerID][_CampID].CampFire;
            Logic.DestroyEntity(OldID);
            local CampfireType = g_Outlaws.Players[BanditsPlayerID][_CampID].CampFireType;
            local FireplaceType = g_Outlaws.ReplaceCampType[CampfireType];
            local NewID = Logic.CreateEntityOnUnblockedLand(FireplaceType, x, y, 0, 0);
            g_Outlaws.Players[BanditsPlayerID][_CampID].ExtinguishedFire = NewID;
            g_Outlaws.Players[BanditsPlayerID][_CampID].CampFire = nil;
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Icons and Counting in House Menu

function Swift.Bugfix:FixHouseMenuIconsAndCounting()
	-- Fix HouseMenu not showing Cathedrals, Castles != the current climate zone and Outposts != the current climate zone
	HouseMenuSetIconsPart = function(_Part, _HighlightBool)
		local PlayerID = GUI.GetPlayerID()
		local HouseMenuButtons = {XGUIEng.ListSubWidgets(_Part)}
		local Buildings = {Logic.GetBuildingsByPlayer(PlayerID)}
		local WidgetName, CurrentCategory

		for i = 1, #HouseMenuButtons do
			WidgetName = XGUIEng.GetWidgetNameByID(HouseMenuButtons[i])
			CurrentCategory = HouseMenuBugFixGetEntityCategory(WidgetName)
		
			local WidgetPosEntry = Entities[WidgetName]
			local Button = _Part .. "/" .. WidgetName .. "/Button"

			SetIcon(Button, g_TexturePositions.Entities[WidgetPosEntry])

			local Count = 0
			local CategoryBuildings
			if CurrentCategory ~= nil then
				CategoryBuildings = {Logic.GetPlayerEntitiesInCategory(PlayerID, CurrentCategory)}
				Count = #CategoryBuildings
			else
				for j = 1, #Buildings do
					local EntityType = Logic.GetEntityType(Buildings[j])
					local EntityName = Logic.GetEntityTypeName(EntityType)
					local ClimateWidgetName = GetClimateEntityName(WidgetName)

					if EntityName == ClimateWidgetName then
						Count = Count + 1
					end
				end
			end

			if Count == 0 then
				XGUIEng.DisableButton(Button, 1)
			else
				XGUIEng.DisableButton(Button, 0)
			end

			local Amount = _Part .. "/" .. WidgetName .. "/Amount"
			XGUIEng.SetText(Amount, "{center}" .. Count)

			local StopWidget = _Part .. "/" .. WidgetName .. "/Stop"
			UpdateStopOverlay(StopWidget, WidgetName, Count)

			-- display overlay icon of current building
			if WidgetName == HouseMenu.Widget.CurrentBuilding then
				UpdateStopOverlay(HouseMenu.Widget.CurrentStop, HouseMenu.Widget.CurrentBuilding, Count)
			end
		end

		HouseMenu.Counter = HouseMenu.Counter + 1

		if _HighlightBool or math.mod(HouseMenu.Counter, 20) == 0 then
			for j = 1, #HouseMenuButtons do
				local WidgetNameHighlighted = XGUIEng.GetWidgetNameByID(HouseMenuButtons[j])
				local ButtonHighlighted = _Part .. "/" .. WidgetNameHighlighted .. "/Button"
				WidgetNameHighlighted = GetClimateEntityName(WidgetNameHighlighted)

				if WidgetNameHighlighted == HouseMenu.Widget.CurrentBuilding then
					XGUIEng.HighLightButton(ButtonHighlighted, 1)
				else
					XGUIEng.HighLightButton(ButtonHighlighted, 0)
				end
			end
		end
	end

	HouseMenuGetNextBuildingID = function(WidgetName)
		local PlayerID = GUI.GetPlayerID()
		local CurrentCategory = HouseMenuBugFixGetEntityCategory(WidgetName)
		WidgetName = GetClimateEntityName(WidgetName)
	
		local Buildings, i
		if CurrentCategory ~= nil then
			Buildings = {Logic.GetPlayerEntitiesInCategory(PlayerID, CurrentCategory)}
		else
			Buildings = {Logic.GetBuildingsByPlayer(PlayerID)}
		end

		if HouseMenu.Widget.CurrentBuilding ~= WidgetName then
			HouseMenu.Widget.CurrentBuilding = WidgetName
			HouseMenu.Widget.CurrentBuildingNumber = 0
		end

		local FoundNumber = 0
		local HigherBuildingFound = false

		for i = 1, #Buildings do
			local EntityType = Logic.GetEntityType(Buildings[i])
			local EntityName = Logic.GetEntityTypeName(EntityType)

			if CurrentCategory ~= nil or EntityName == WidgetName then
				FoundNumber = i

				if FoundNumber > HouseMenu.Widget.CurrentBuildingNumber then
					HouseMenu.Widget.CurrentBuildingNumber = FoundNumber
					HigherBuildingFound = true
					break;
				end
			end
		end

		if FoundNumber == 0 then
			return nil;
		end

		if not HigherBuildingFound then
			for i = 1, #Buildings do
				local EntityType = Logic.GetEntityType(Buildings[i])
				local EntityName = Logic.GetEntityTypeName(EntityType)
				if CurrentCategory ~= nil or EntityName == WidgetName then
					HouseMenu.Widget.CurrentBuildingNumber = i
					break;
				end
			end
		end

		return Buildings[HouseMenu.Widget.CurrentBuildingNumber]
	end
	
	HouseMenuBugFixGetEntityCategory = function(_WidgetName)
		if _WidgetName == "B_Castle_ME" then
			return EntityCategories.Headquarters
		elseif _WidgetName == "B_Outpost_ME" then
			return EntityCategories.Outpost
		elseif _WidgetName == "B_Cathedral" then
			return EntityCategories.Cathedrals
		end
		return nil
	end
end
--#EOF