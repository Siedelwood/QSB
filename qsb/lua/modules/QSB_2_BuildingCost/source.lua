-- -------------------------------------------------------------------------- --

ModuleBuildingCost = {
    Properties = {
        Name = "ModuleBuildingCost",
        Version = "1.0.0 beta 1",
    },

    Global = {
        Data = {
            Original = {},
			AreBuildingCostsAvailable = nil,
		},
    },
    Local = {
        Data = {
            HakimGetsDiscount = false,
            HakimDiscount = 0.8,
            DiscountFunctions = {
				CanBeZero = {
					Upgrade = false,
					Construction = {
						OriginalGood = false,
						AddedGood = false,
					},
				},
				Upgrade = {},
				Construction = {
					OriginalGood = {},
					AddedGood = {},
				},
			},
            Original = {},
            Costs = {
				Upgrade = {},
				Construction = {},
				Other = {
					Road = nil,
					Trail = nil,
					Palisade = nil,
					Wall = nil,
					Festival = nil,
				},
			},
            CurrentConstructions = {},
            CurrentUpgrades = {},
            CurrentOutpostWorkers = {},
            ReturningSettler = {},
			BuildingIDTable = {},
            MainBuildings = {
                Entities.B_Castle_AS,
                Entities.B_Castle_ME,
                Entities.B_Castle_NA,
                Entities.B_Castle_NE,
                Entities.B_Castle_SE,
                Entities.B_Cathedral,
                Entities.B_Cathedral_Big,
                Entities.B_StoreHouse,
            },
            RoadMultiplier = {
                First = 1,
                Second = 1,
                CurrentActualCost = 1,
            },
            StreetMultiplier = {
                First = 1,
                Second = 1,
                CurrentX = 1,
                CurrentY = 1,
            },
            Overlay = {
                Widget = "/EndScreen",
                Shown = false,
            },
            MarketplaceGoodsCount = false,
            RefundCityGoods = true,
            CurrentKnockDownFactor = 0.5, -- Half the new good cost is refunded at knock down
            CurrentOriginalGoodKnockDownFactor = 0.2,
			IsInWallOrPalisadeContinueState = false,
			CurrentWallTypeForClimate = nil, -- Save climate zone wall type here
			CurrentExpectedBuildingType = nil, -- Used for KnockDown saving
			IsCurrentBuildingInCostTable = false, -- Set at BuildClicked, true in hovering mode, reset at AfterBuildingPlacement
        },
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function ModuleBuildingCost.Global:OnGameStart()
	if self.Data.Original.GameCallback_BuildingDestroyed == nil then
		self.Data.Original.GameCallback_BuildingDestroyed = GameCallback_BuildingDestroyed;
	end
	GameCallback_BuildingDestroyed = function(_EntityID, _PlayerID, _KnockedDown)
		self.Data.Original.GameCallback_BuildingDestroyed(_EntityID, _PlayerID, _KnockedDown)
		if (_KnockedDown == 1) and (_PlayerID == 1) then

			local IsReachable = CanEntityReachTarget(_PlayerID, Logic.GetStoreHouse(_PlayerID), _EntityID, nil, PlayerSectorTypes.Civil)
			-- Return nothing in case the building is not reachable
			if IsReachable == false then
				return;
			end

			Logic.ExecuteInLuaLocalState(" ModuleBuildingCost.Local:RefundKnockDown(".._EntityID..")")
		end
	end

	if self.Data.Original.GameCallback_CanPlayerPlaceBuilding == nil then
		self.Data.Original.GameCallback_CanPlayerPlaceBuilding = GameCallback_CanPlayerPlaceBuilding;
	end
	GameCallback_CanPlayerPlaceBuilding = function(_PlayerID, _Type, _X, _Y)
		if self.Data.AreBuildingCostsAvailable ~= nil then
			return self.Data.AreBuildingCostsAvailable
		else
			return self.Data.Original.GameCallback_CanPlayerPlaceBuilding(_PlayerID, _Type, _X, _Y)
		end
	end
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Private
-- @local
--
function ModuleBuildingCost.Local:OnGameStart()
	-- UpgradeCosts
    self:InitEvents()
    self:OverrideFunctions()

	-- BuildingCosts
	self:InitializeBuildingCostSystem()
	self:AddBuildingCostScriptEvents()
end

function ModuleBuildingCost.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        self:InitializeBuildingCostSystem()
    end
end

function ModuleBuildingCost.Local:SetHakimUpgradeDiscount(_Discount)
    if _Discount == 1 or _Discount == 0 or Logic.GetEntityType(Logic.GetKnightID(GUI.GetPlayerID())) ~= Entities.U_KnightWisdom then
        self.Data.HakimGetsDiscount = false
    else
		self.Data.HakimGetsDiscount = true
    end
    self.Data.HakimDiscount = _Discount
end

function ModuleBuildingCost.Local:InitEvents()
    
    API.AddScriptEventListener(QSB.ScriptEvents.SettlerAttracted, function(_EntityID, _PlayerID)
        if (Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 0)
        and (Logic.GetEntityType(_EntityID) ~= Entities.U_WallConstructionWorker) then
            return
        end
        if Logic.GetEntityType(_EntityID) == Entities.U_OutpostConstructionWorker then
            table.insert(self.Data.CurrentOutpostWorkers, _EntityID)
        end
        local WorkPlaceID = Logic.GetSettlersWorkBuilding(_EntityID)
        for i,v in ipairs(self.Data.CurrentUpgrades) do
            if v.BuildingID == WorkPlaceID then
                v.SettlerID = _EntityID
                break
            end
        end
    end)

    API.AddScriptEventListener(QSB.ScriptEvents.BuildingUpgradeCollapsed, function(BuildingID, _PlayerID, _NewUpgradeLevel)
        local entityType = Logic.GetEntityType(BuildingID)
        if not table.contains(self.Data.MainBuildings, entityType) then
            ModuleBuildingCost.Local:AddReturningSettler(BuildingID)
        end
    end)

    API.AddScriptEventListener(QSB.ScriptEvents.EntityDestroyed, function(_EntityID, _PlayerID)
        if _PlayerID ~= GUI.GetPlayerID() then
            return
        end
        local index
        if table.contains(self.Data.CurrentOutpostWorkers, _EntityID) then
            -- This represents the destruction of an Outpost worker
            for i,v in ipairs(self.Data.CurrentUpgrades) do
                if v.SettlerID == _EntityID then
                    index = i
                    break
                end
            end
            if index then
                table.remove(self.Data.CurrentUpgrades, index)
            end
            return
        end
        for i,v in ipairs(self.Data.ReturningSettler) do
            if v.SettlerID == _EntityID then
                index = i
                self:RefundUpgradeCosts(v.Costs.Original, v.Costs.Actual, v.PlayerID)
                break
            end
        end
        if index then
            table.remove(self.Data.ReturningSettler, index)
        end
    end)

    API.AddScriptEventListener(QSB.ScriptEvents.BuildingUpgraded, function( _BuildingID, _PlayerID, _NewUpgradeLevel)
        local index
        local level = Logic.GetUpgradeLevel(_BuildingID)
        for i,v in ipairs(self.Data.CurrentUpgrades) do
            if v.BuildingID == _BuildingID and v.Level.To == level then
                index = i
                break
            end
        end
        if index then
            table.remove(self.Data.CurrentUpgrades, index)
        end
    end)
end

function ModuleBuildingCost.Local:OverrideFunctions()

    self.Data.Original.GetUpgradeCosts = GUI_BuildingButtons.GetUpgradeCosts
    self.Data.Original.UpgradeClicked  = GUI_BuildingButtons.UpgradeClicked

    function GUI_BuildingButtons.GetUpgradeCosts(...)
        local EntityID = GUI.GetSelectedEntity()
        local level = Logic.GetUpgradeLevel(EntityID) + 1
        local buildingType = Logic.GetEntityType(EntityID)
        local buildingCosts = ModuleBuildingCost.Local.Data.Costs.Upgrade[buildingType]
        if buildingCosts == nil then
            return  ModuleBuildingCost.Local.Data.Original.GetUpgradeCosts(unpack(arg))
        else
            local costs = buildingCosts[level] and table.copy(buildingCosts[level]) or {}
            if costs == nil then
                return  ModuleBuildingCost.Local.Data.Original.GetUpgradeCosts(unpack(arg))
            else
                local factor = 1
                if ModuleBuildingCost.Local.Data.HakimGetsDiscount then
                    factor = factor - ModuleBuildingCost.Local.Data.HakimDiscount
                end
                if #ModuleBuildingCost.Local.Data.DiscountFunctions.Upgrade > 0 then
                    for i,v in ipairs(ModuleBuildingCost.Local.Data.DiscountFunctions.Upgrade) do
                        factor = factor - (v() or 0)
                    end
                end
                if costs[2] then
                    costs[2] = math.floor(costs[2] * factor + 0.5)
                    if costs[2] == 0 then
                        costs[2] = 1
                    end
                end
                if costs[4] then
                    costs[4] = math.floor(costs[4] * factor + 0.5)
					if not self.Data.DiscountFunctions.CanBeZero.Upgrade then
						if costs[4] == 0 then
							costs[4] = 1
						end
					end
                end
                return costs
            end
        end
    end

    function GUI_BuildingButtons.UpgradeClicked()
        local EntityID = GUI.GetSelectedEntity()

        if Logic.CanCancelUpgradeBuilding(EntityID) then
            Sound.FXPlay2DSound("ui\\menu_click")
            GUI.CancelBuildingUpgrade(EntityID)

            ModuleBuildingCost.Local:AddReturningSettler(EntityID)

            XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/BuildingButtons",1)
            return
        end

        local Costs = GUI_BuildingButtons.GetUpgradeCosts()
        local CanBuyBoolean, CanNotBuyString = AreCostsAffordable(Costs)

        if CanBuyBoolean == true then
            Sound.FXPlay2DSound("ui\\menu_click")

            local playerID, origCosts = ModuleBuildingCost.Local:AddCurrentUpgrade(EntityID, Costs)
            ModuleBuildingCost.Local:UpgradeBuilding(EntityID, Costs, playerID)

            if ModuleBuildingCost.Local.Data.HakimGetsDiscount or origCosts then
                StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightWisdom)
            end

            if XGUIEng.GetCurrentWidgetID() ~= 0 then
                SaveButtonPressed(XGUIEng.GetCurrentWidgetID())
            end
        else
            Message(CanNotBuyString)
        end
    end

end

function ModuleBuildingCost.Local:SetUpgradeDiscountFunction(_Function, _CanBeZero)
	self.Data.DiscountFunctions.CanBeZero.Upgrade = _CanBeZero or false
    table.insert(self.Data.DiscountFunctions.Upgrade, _Function)
end

function ModuleBuildingCost.Local:SetConstructionOriginalGoodDiscountFunction(_Function, _CanBeZero)
	self.Data.DiscountFunctions.CanBeZero.Construction.OriginalGood = _CanBeZero or false
    table.insert(self.Data.DiscountFunctions.Construction.OriginalGood, _Function)
end

function ModuleBuildingCost.Local:SetConstructionAddedGoodDiscountFunction(_Function, _CanBeZero)
	self.Data.DiscountFunctions.CanBeZero.Construction.AddedGood = _CanBeZero or false
    table.insert(self.Data.DiscountFunctions.Construction.AddedGood, _Function)
end

function ModuleBuildingCost.Local:SetUpgradeCosts(_Building, _Level, _Good1, _Amount1, _Good2, _Amount2)
    self.Data.Costs.Upgrade[_Building] = self.Data.Costs.Upgrade[_Building] or {}
    if _Good2 then
        self.Data.Costs.Upgrade[_Building][_Level] = {
            _Good1,
            _Amount1,
            _Good2,
            _Amount2,
        }
    elseif _Good1 then
        self.Data.Costs.Upgrade[_Building][_Level] = {
            _Good1,
            _Amount1,
        }
	else
		self.Data.Costs.Upgrade[_Building][_Level] = nil
    end
end

function ModuleBuildingCost.Local:RefundUpgradeCosts(_OriginalCosts, _ActualCosts, _PlayerID)
    local resource
    for i,v in ipairs(_OriginalCosts) do
        if i % 2 == 1 then
            resource = v
        else
            GUI.SendScriptCommand(string.format(
                [[
                    RemoveResourcesFromPlayer(%d, %d, %d)
                ]],
                resource,
                v,
                _PlayerID
            ))
        end
    end
    for i,v in ipairs(_ActualCosts) do
        if i % 2 == 1 then
            resource = v
        else
            GUI.SendScriptCommand(string.format(
                [[
                    AddResourcesToPlayer(%d, %d, %d)
                ]],
                resource,
                v,
                _PlayerID
            ))
        end
    end
end

function ModuleBuildingCost.Local:AddCurrentUpgrade(_EntityID, _Costs)
    local owner = Logic.EntityGetPlayer(_EntityID)
    if owner == GUI.GetPlayerID() then
        local level = Logic.GetUpgradeLevel(_EntityID)
        local orginalCosts = self.Data.Original.GetUpgradeCosts()
        if table.equals(orginalCosts, _Costs) then
            return owner, true
        end

        -- Main Buildings do not get handled when upgrades are interupted
        local entityType = Logic.GetEntityType(_EntityID)
        if table.contains(self.Data.MainBuildings, entityType) then
            return owner
        end

        -- Remove potential former Upgrade for same Building that finished
        local index
        for i,v in ipairs(self.Data.CurrentUpgrades) do
            if v.BuildingID == _EntityID and v.Level.To == level then
                index = i
                break
            end
        end
        if index then
            table.remove(self.Data.CurrentUpgrades, index)
        end

        local currentUpgrade = {
            Level = {
                From = level,
                To = level + 1,
            },
            PlayerID = owner,
            SettlerID = nil,
            BuildingID = _EntityID,
            Costs = {
                Original = orginalCosts,
                Actual = _Costs,
            },
        }
        table.insert(self.Data.CurrentUpgrades, currentUpgrade)
    end
    return owner
end

function ModuleBuildingCost.Local:UpgradeBuilding(_EntityID, _Costs, _PlayerID)
    GUI.SendScriptCommand(string.format(
        [[ Logic.UpgradeBuilding(%d) ]],
        _EntityID
    ))
    local resource
    for i,v in ipairs(_Costs) do
        if i % 2 == 1 then
            resource = v
        else
            GUI.SendScriptCommand(string.format(
                [[
                    RemoveResourcesFromPlayer(%d, %d, %d)
                ]],
                resource,
                v,
                _PlayerID
            ))
        end
    end
end

function ModuleBuildingCost.Local:AddReturningSettler(_EntityID)
    local index
    for i,v in ipairs(self.Data.CurrentUpgrades) do
        if v.BuildingID == _EntityID or v.SettlerID == _EntityID then
            index = i
            table.insert(self.Data.ReturningSettler, v)
            break
        end
    end
    if index then
        table.remove(self.Data.CurrentUpgrades, index)
    end
end

-- -------------------------------------------------------------------------- --
-- BuildingCostSystem refactored by EisenMonoxid (QSB-Refactoring by Jelumar) --
-- -------------------------------------------------------------------------- --

function ModuleBuildingCost.Local:AddBuildingCostScriptEvents()
	API.AddScriptEventListener(QSB.ScriptEvents.SettlerAttracted, function(_EntityID, _PlayerID)
		if (_PlayerID == GUI.GetPlayerID()) then
			if (Logic.IsEntityInCategory(_EntityID, EntityCategories.Worker) == 1) 
			or (Logic.GetEntityType(_EntityID) == Entities.U_OutpostConstructionWorker) 
			or (Logic.GetEntityType(_EntityID) == Entities.U_WallConstructionWorker) then
				API.StartHiResJob(function()
					return ModuleBuildingCost.Local:GetLastPlacedBuildingIDForKnockDown(_EntityID)
				end)
			end
		end
    end)
end

-- Table Managment

function ModuleBuildingCost.Local:GetCostByCostTable(_upgradeCategory)
	if _upgradeCategory == nil or _upgradeCategory == 0 then
		return
	end
	local CurrentCostTable = self.Data.Costs.Construction[_upgradeCategory]
	if #self.Data.DiscountFunctions.Construction.AddedGood > 0 then
		local factor = 1
		for i,v in ipairs(self.Data.DiscountFunctions.Construction.AddedGood) do
			factor = factor - (v() or 0)
		end
		if CurrentCostTable[3] then
			CurrentCostTable[3] = math.floor(CurrentCostTable[3] * factor + 0.5)
			if not self.Data.DiscountFunctions.CanBeZero.Construction.AddedGood then
				if CurrentCostTable[3] == 0 then
					CurrentCostTable[3] = 1
				end
			end
		end
	end
	if #self.Data.DiscountFunctions.Construction.OriginalGood > 0 then
		local factor = 1
		for i,v in ipairs(self.Data.DiscountFunctions.Construction.OriginalGood) do
			factor = factor - (v() or 0)
		end

		local _, building = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
		local originalCosts = {ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost(building)}
		local originalCost = originalCosts[2]
		local addedCosts = CurrentCostTable[1] - originalCost
		addedCosts = math.floor(addedCosts * factor + 0.5)
		if not self.Data.DiscountFunctions.CanBeZero.Construction.OriginalGood then
			if addedCosts == 0 then
				addedCosts = 1
			end
		end
		CurrentCostTable[1] = originalCost + addedCosts
	end
	return CurrentCostTable
end

function ModuleBuildingCost.Local:GetCostByBuildingIDTable(_EntityID)
	if _EntityID == nil or _EntityID == 0 then
		return
	end

	for Type, CurrentCostTable in pairs(self.Data.BuildingIDTable) do
		if (CurrentCostTable[1] == _EntityID) then
			return CurrentCostTable, Type
		end
	end

	return nil
end

function ModuleBuildingCost.Local:AddBuildingToIDTable(_EntityID)
	local FGood, FAmount, SGood, SAmount = Logic.GetEntityTypeFullCost(Logic.GetEntityType(_EntityID))
	if FGood ~= nil and FGood ~= 0 then
		table.insert(self.Data.BuildingIDTable, {_EntityID, FGood, FAmount, SGood, SAmount})
	else
		info("BCS: AddBuildingToIDTable() -> FGood was nil/0! Nothing was added!")
	end
end

-- Ingame Resource Management

function ModuleBuildingCost.Local:RemoveCostsFromOutStock(_upgradeCategory)
	local PlayerID = GUI.GetPlayerID()
	local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
	local Costs = {Logic.GetEntityTypeFullCost(FirstBuildingType)}
	local OriginalCosts = {self.Data.Original.GetEntityTypeFullCost(FirstBuildingType)}

	local FAmountToRemove = (Costs[2] - OriginalCosts[2])
	local CurrentID = self:GetEntityIDToAddToOutStock(Costs[1])
	if CurrentID == false then
		self:RemoveCostsFromOutStockCityGoods(Costs[1], FAmountToRemove, PlayerID, self.Data.MarketplaceGoodsCount)
	else
		local FGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, Costs[1])
		if FGoodCurrentAmount < FAmountToRemove then
			GUI.RemoveGoodFromStock(CurrentID, Costs[1], FGoodCurrentAmount)
		else
			GUI.RemoveGoodFromStock(CurrentID, Costs[1], FAmountToRemove)
		end
	end

	if Costs[3] ~= nil and Costs[3] ~= 0 then
		if OriginalCosts[4] == nil then
			OriginalCosts[4] = 0
		end
		local SAmountToRemove = (Costs[4] - OriginalCosts[4])

		CurrentID = self:GetEntityIDToAddToOutStock(Costs[3])
		if CurrentID == false then
			self:RemoveCostsFromOutStockCityGoods(Costs[3], SAmountToRemove, PlayerID, self.Data.MarketplaceGoodsCount)
		else
			local SGoodCurrentAmount = Logic.GetAmountOnOutStockByGoodType(CurrentID, Costs[3])
			if SGoodCurrentAmount < SAmountToRemove then
				GUI.RemoveGoodFromStock(CurrentID, Costs[3], SGoodCurrentAmount)
			else
				GUI.RemoveGoodFromStock(CurrentID, Costs[3], SAmountToRemove)
			end
		end
	end
end

function ModuleBuildingCost.Local:GetAmountOfGoodsInSettlement(_goodType, _playerID, _countMarketplace)
	local CurrentID = self:GetEntityIDToAddToOutStock(_goodType)

	if CurrentID ~= false then
		return Logic.GetAmountOnOutStockByGoodType(CurrentID, _goodType)	
	end

	local Amount = 0
	local BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	local Buildings = GetPlayerEntities(_playerID, BuildingTypes[1])

    for _, building in ipairs(Buildings) do
		Amount = Amount + Logic.GetAmountOnOutStockByGoodType(building, _goodType)
    end

	if _countMarketplace == true then
		local MarketSlots = {Logic.GetPlayerEntities(_playerID, Entities.B_Marketslot, 5, 0)}
        for j = 2, #MarketSlots, 1 do
            if Logic.GetIndexOnOutStockByGoodType(MarketSlots[j], _goodType) ~= -1 then
                local GoodAmountOnMarketplace = Logic.GetAmountOnOutStockByGoodType(MarketSlots[j], _goodType)
				Amount = Amount + GoodAmountOnMarketplace
            end
        end
	end

	return Amount
end

function ModuleBuildingCost.Local:RemoveCostsFromOutStockCityGoods(_goodType, _goodAmount, _playerID, _countMarketplace)
	local PlayerID = _playerID
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings

	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(PlayerID, BuildingTypes[1])

	local CurrentOutStock = 0
    for _, building in ipairs(Buildings) do
		CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(building, _goodType)
		if CurrentOutStock < AmountToRemove then
			GUI.RemoveGoodFromStock(building, _goodType, CurrentOutStock)
			AmountToRemove = AmountToRemove - CurrentOutStock
		else
			GUI.RemoveGoodFromStock(building, _goodType, AmountToRemove)
			AmountToRemove = 0
			break;
		end
    end

	if _countMarketplace == true and AmountToRemove > 0 then
		local MarketSlots = {Logic.GetPlayerEntities(_playerID, Entities.B_Marketslot, 5, 0)}
        for j = 2, #MarketSlots, 1 do
            if Logic.GetIndexOnOutStockByGoodType(MarketSlots[j], _goodType) ~= -1 then
                CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(MarketSlots[j], _goodType)
				if CurrentOutStock < AmountToRemove then
					GUI.RemoveGoodFromStock(MarketSlots[j], _goodType, CurrentOutStock)
					AmountToRemove = AmountToRemove - CurrentOutStock
				else
					GUI.RemoveGoodFromStock(MarketSlots[j], _goodType, AmountToRemove)
					AmountToRemove = 0
					break;
				end
            end
        end
	end
end

function ModuleBuildingCost.Local:RemoveVariableCostsFromOutStock(_type)
	-- 1 = Palisade, 2 = Wall, 3 = Trail, 4 = Road
	local CostTable, OriginalCosts, CurrentID
	local Costs = {0,0,0,0} -- Just to be sure
	local PlayerID = GUI.GetPlayerID()

	if _type == 1 then -- Palisade
		CostTable = self.Data.Costs.Other.Palisade
		Costs = {Logic.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = {self.Data.Original.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = OriginalCosts[2]
	elseif _type == 2 then -- Wall
		CostTable = self.Data.Costs.Other.Wall
		Costs = {Logic.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = {self.Data.Original.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		OriginalCosts = OriginalCosts[2]
	elseif _type == 3 then -- Trail
		CostTable = self.Data.Costs.Other.Trail
		Costs[2] = self.Data.StreetMultiplier.First
		Costs[4] = self.Data.StreetMultiplier.Second
		OriginalCosts = 0 -- Trail has no costs in base game
	elseif _type == 4 then -- Road
		CostTable = self.Data.Costs.Other.Road
		Costs[2] = self.Data.RoadMultiplier.First
		Costs[4] = self.Data.RoadMultiplier.Second
		OriginalCosts = self.Data.RoadMultiplier.CurrentActualCost
	else
		return -- No valid type, so remove nothing
	end

	CurrentID = self:GetEntityIDToAddToOutStock(CostTable[1])
	if CurrentID == false then
		self:RemoveCostsFromOutStockCityGoods(CostTable[1], Costs[2] - OriginalCosts, PlayerID, self.Data.MarketplaceGoodsCount)
	else
		GUI.RemoveGoodFromStock(CurrentID, CostTable[1], Costs[2] - OriginalCosts)
	end

	if CostTable[3] ~= nil and CostTable[3] ~= 0 then
		CurrentID = self:GetEntityIDToAddToOutStock(CostTable[3])
		if CurrentID == false then
			self:RemoveCostsFromOutStockCityGoods(CostTable[3], Costs[4], PlayerID, self.Data.MarketplaceGoodsCount)
		else
			GUI.RemoveGoodFromStock(CurrentID, CostTable[3], Costs[4])
		end
	end
end

function ModuleBuildingCost.Local:AreResourcesAvailable(_upgradeCategory, _FGoodAmount, _SGoodAmount)
	local PlayerID = GUI.GetPlayerID()
	local AmountOfTypes, FirstBuildingType, Costs

	if _FGoodAmount ~= nil then
		_SGoodAmount = _SGoodAmount or 0
		if _upgradeCategory == 1 then --Road
			Costs = self.Data.Costs.Other.Road
		elseif _upgradeCategory == 2 then--Wall
			Costs = self.Data.Costs.Other.Wall
		elseif _upgradeCategory == 3 then --Palisade
			Costs = self.Data.Costs.Other.Palisade
		else --Street/Trail
			Costs = self.Data.Costs.Other.Trail
		end
	else --Normal Buildings
		AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_upgradeCategory)
		Costs = {Logic.GetEntityTypeFullCost(FirstBuildingType)}
		_FGoodAmount = Costs[2]
		_SGoodAmount = Costs[4] or 0
	end

	local AmountOfFirstGood, AmountOfSecondGood
	AmountOfFirstGood = self:GetAmountOfGoodsInSettlement(Costs[1], PlayerID, self.Data.MarketplaceGoodsCount)
	if Costs[3] then
		AmountOfSecondGood = self:GetAmountOfGoodsInSettlement(Costs[3], PlayerID, self.Data.MarketplaceGoodsCount)
	else
		AmountOfSecondGood = 0
	end

	if (AmountOfFirstGood < _FGoodAmount or AmountOfSecondGood < _SGoodAmount) then
		return false
	else
		return true
	end
end

function ModuleBuildingCost.Local:RefundKnockDown(_entityID)
	-- WARNING: _entityID is not valid here anymore! DO NOT USE ON GAME FUNCTIONS!
	-- -> Just used to get the corresponding table index
	local PlayerID = GUI.GetPlayerID()
	local CostTable, Type = self:GetCostByBuildingIDTable(_entityID)

	if CostTable == nil then -- Building has no costs
		return;
	end

	local IDFirstGood = self:GetEntityIDToAddToOutStock(CostTable[2])
	local IDSecondGood
	if CostTable[4] then
		IDSecondGood = self:GetEntityIDToAddToOutStock(CostTable[4])
	end

	if IDFirstGood == false then -- CityGood
		if self.Data.RefundCityGoods == true then
			self:RefundKnockDownForCityGoods(CostTable[2], (math.ceil(CostTable[3] * self.Data.CurrentOriginalGoodKnockDownFactor)))
		end
	else
		GUI.SendScriptCommand([[
			Logic.AddGoodToStock(]]..IDFirstGood..[[, ]]..CostTable[2]..[[, ]]..(math.ceil(CostTable[3] * self.Data.CurrentOriginalGoodKnockDownFactor))..[[)	
		]])
	end
	if CostTable[4] then
		if IDSecondGood == false then -- CityGood
			if self.Data.RefundCityGoods == true then
				self:RefundKnockDownForCityGoods(CostTable[4], (math.ceil(CostTable[5] * self.Data.CurrentKnockDownFactor)))
			end
		else
			GUI.SendScriptCommand([[
				Logic.AddGoodToStock(]]..IDSecondGood..[[, ]]..CostTable[4]..[[, ]]..(math.ceil(CostTable[5] * self.Data.CurrentKnockDownFactor))..[[)	
			]])
		end
	end

	self.Data.BuildingIDTable[Type] = nil -- Delete the Entity ID from the table

	info("BCS: KnockDown for Building "..tostring(_entityID).." done! Size of KnockDownList: "..tostring(#self.Data.BuildingIDTable))
end

function ModuleBuildingCost.Local:RefundKnockDownForCityGoods(_goodType, _goodAmount)
	local PlayerID = GUI.GetPlayerID()
	local AmountToRemove = _goodAmount
	local BuildingTypes, Buildings

	BuildingTypes = {Logic.GetBuildingTypesProducingGood(_goodType)}
	Buildings = GetPlayerEntities(PlayerID, BuildingTypes[1])

	local CurrentOutStock, CurrentMaxOutStock = 0, 0
    for _, building in ipairs(Buildings) do
		if Logic.IsBuilding(Buildings[i]) == 1 and Logic.IsConstructionComplete(building) == 1 then
			CurrentOutStock = Logic.GetAmountOnOutStockByGoodType(building, _goodType)
			CurrentMaxOutStock = Logic.GetMaxAmountOnStock(building)
			if CurrentOutStock < CurrentMaxOutStock then
				local FreeStock = CurrentMaxOutStock - CurrentOutStock
				if FreeStock >= AmountToRemove then
					GUI.SendScriptCommand([[
						Logic.AddGoodToStock(]]..building..[[, ]].._goodType..[[, ]]..AmountToRemove..[[)	
					]])
					break;
				else
					AmountToRemove = AmountToRemove - FreeStock
					GUI.SendScriptCommand([[
						Logic.AddGoodToStock(]]..building..[[, ]].._goodType..[[, ]]..FreeStock..[[)	
					]])
				end
			end
		end
    end

	info("BCS: Refunded City Goods with type ".._goodType.." and amount ".._goodAmount..". Amount Lost: "..AmountToRemove)
end

function ModuleBuildingCost.Local:GetEntityIDToAddToOutStock(_goodType)
	local PlayerID = GUI.GetPlayerID()

	if _goodType == Goods.G_Gold then 
		return Logic.GetHeadquarters(PlayerID) 
	end

	if Logic.GetIndexOnOutStockByGoodType(Logic.GetStoreHouse(PlayerID), _goodType) ~= -1 then
		return Logic.GetStoreHouse(PlayerID)
	end

	--Check here for Buildings, when player uses production goods as building material
	if Logic.GetGoodCategoryForGoodType(_goodType) ~= GoodCategories.GC_Resource then
		return false	
	end

	return nil -- This should never happen
end

function ModuleBuildingCost.Local:GetLastPlacedBuildingIDForKnockDown(_EntityID)
	info("BCS: Job "..tostring(_EntityID).." Created!")
	-- Are we even waiting on something?
	if self.Data.CurrentExpectedBuildingType == nil then
		info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType was nil!")
		return true;
	end
	if not IsExisting(_EntityID) then
		info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker Entity was deleted!")
		return true;
	elseif string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_EntityID)), 'NPC') then
		info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Worker was an NPC - Settler!")
		return true;
	elseif Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 1 and Logic.GetTaskHistoryEntry(_EntityID, 0) ~= 9 then
		info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: TaskHistoryEntry was not 1 or 9 (Just Spawned/BuildingPhase)")
		return true;
	end
	-- Here, we expect that a building was being placed recently
	local WorkPlaceID = Logic.GetSettlersWorkBuilding(_EntityID)
	if WorkPlaceID ~= 0 and WorkPlaceID ~= nil then
		local Type = Logic.GetEntityType(WorkPlaceID)
		info("BCS: Job "..tostring(_EntityID).." has BuildingType: " ..tostring(Type) .." - Expected: "..tostring(self.Data.CurrentExpectedBuildingType))	
		if Type == self.Data.CurrentExpectedBuildingType then

			self:AddBuildingToIDTable(WorkPlaceID)
			self.Data.CurrentExpectedBuildingType = nil
			info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: Building Added To ID Table: " ..tostring(WorkPlaceID))

			return true;
		else
			info("BCS: Job " ..tostring(_EntityID) .. " finished! Reason: CurrentExpectedBuildingType ~= WorkplaceID-Type!")
			return true;
		end
	end
end

-- Hacking the game functions

function ModuleBuildingCost.Local:HasCurrentBuildingOwnBuildingCosts(_upgradeCategory)
	local CostTable = self:GetCostByCostTable(_upgradeCategory)
	if (CostTable == nil or CostTable == 0) then
		self:SetAwaitingVariable(false)
		info("BCS: Building NOT Custom with Category: "..tostring(_upgradeCategory))
	else
		self:SetAwaitingVariable(true)
		info("BCS: Building Custom with Category: "..tostring(_upgradeCategory))
	end
end
function ModuleBuildingCost.Local:SetAwaitingVariable(_isAwaiting)
	self.Data.IsCurrentBuildingInCostTable = _isAwaiting
end
function ModuleBuildingCost.Local:GetAwaitingVariable()
	return self.Data.IsCurrentBuildingInCostTable
end

function ModuleBuildingCost.Local:OverwriteAfterPlacement()
	if self.Data.Original.GameCallback_GUI_AfterBuildingPlacement == nil then
		self.Data.Original.GameCallback_GUI_AfterBuildingPlacement = GameCallback_GUI_AfterBuildingPlacement;
	end
    GameCallback_GUI_AfterBuildingPlacement = function()
		if (self:GetAwaitingVariable() == true) then
			local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(g_LastPlacedParam)
			self.Data.CurrentExpectedBuildingType = FirstBuildingType

			self:RemoveCostsFromOutStock(g_LastPlacedParam)
			self:SetAwaitingVariable(false)
		end
        self.Data.Original.GameCallback_GUI_AfterBuildingPlacement();
    end

	if self.Data.Original.GameCallback_GUI_AfterWallGatePlacement == nil then
		self.Data.Original.GameCallback_GUI_AfterWallGatePlacement = GameCallback_GUI_AfterWallGatePlacement;
	end
    GameCallback_GUI_AfterWallGatePlacement = function()
		if (self:GetAwaitingVariable() == true) then
			local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(g_LastPlacedParam)
			self.Data.CurrentExpectedBuildingType = FirstBuildingType

			self:RemoveCostsFromOutStock(g_LastPlacedParam);
			self:SetAwaitingVariable(false)
		end
        self.Data.Original.GameCallback_GUI_AfterWallGatePlacement();
    end

	if self.Data.Original.GameCallback_GUI_AfterRoadPlacement == nil then
		self.Data.Original.GameCallback_GUI_AfterRoadPlacement = GameCallback_GUI_AfterRoadPlacement;
	end
    GameCallback_GUI_AfterRoadPlacement = function()
		if g_LastPlacedParam == false then --Road
			if (self.Data.Costs.Other.Road ~= nil) then
				self:RemoveVariableCostsFromOutStock(4)
			end
		else --Trail
			if (self.Data.Costs.Other.Trail ~= nil) then
				self:RemoveVariableCostsFromOutStock(3)
			end
		end

		self:ResetTrailAndRoadCosts()
        self.Data.Original.GameCallback_GUI_AfterRoadPlacement();
    end

	if self.Data.Original.GameCallback_GUI_AfterWallPlacement == nil then
		self.Data.Original.GameCallback_GUI_AfterWallPlacement = GameCallback_GUI_AfterWallPlacement;
	end
    GameCallback_GUI_AfterWallPlacement = function()
		if g_LastPlacedParam == UpgradeCategories.PalisadeSegment then --Palisade
			if (self.Data.Costs.Other.Palisade ~= nil) then
				self:RemoveVariableCostsFromOutStock(1)
				if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
					GUI.CancelState()
				end
			end
		elseif g_LastPlacedParam == self.Data.CurrentWallTypeForClimate then --Wall
			if (self.Data.Costs.Other.Wall ~= nil) then
				self:RemoveVariableCostsFromOutStock(2)
				if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
					GUI.CancelState()
				end
			end
		end

		self.Data.IsInWallOrPalisadeContinueState = false
		self:ResetWallTurretPositions()
        self.Data.Original.GameCallback_GUI_AfterWallPlacement()
    end
end

function ModuleBuildingCost.Local:OverwriteBuildClicked()
	if self.Data.Original.BuildClicked == nil then
		self.Data.Original.BuildClicked = GUI_Construction.BuildClicked;
	end
	GUI_Construction.BuildClicked = function(_BuildingType)
		if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
		self:HasCurrentBuildingOwnBuildingCosts(_BuildingType)
		g_LastPlacedParam = _BuildingType
		self.Data.IsInWallOrPalisadeContinueState = false
		self.Data.Original.BuildClicked(_BuildingType)
	end

	if self.Data.Original.BuildWallClicked == nil then
		self.Data.Original.BuildWallClicked = GUI_Construction.BuildWallClicked;
	end
	GUI_Construction.BuildWallClicked = function(_BuildingType)
		if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
	    if _BuildingType == nil then
			_BuildingType = GetUpgradeCategoryForClimatezone("WallSegment")
			self.Data.CurrentWallTypeForClimate = _BuildingType
		end
		self:ResetWallTurretPositions()
		self:SetAwaitingVariable(false)
		g_LastPlacedParam = _BuildingType
		self.Data.IsInWallOrPalisadeContinueState = false
		self.Data.Original.BuildWallClicked(_BuildingType)
	end

	if self.Data.Original.BuildWallGateClicked == nil then
		self.Data.Original.BuildWallGateClicked = GUI_Construction.BuildWallGateClicked;
	end
	GUI_Construction.BuildWallGateClicked = function(_BuildingType)
		if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
	    if _BuildingType == nil then
			_BuildingType = GetUpgradeCategoryForClimatezone("WallGate")
		end
		self:HasCurrentBuildingOwnBuildingCosts(_BuildingType)
		g_LastPlacedParam = _BuildingType
		self.Data.IsInWallOrPalisadeContinueState = false
		self.Data.Original.BuildWallGateClicked(_BuildingType)
	end

	if self.Data.Original.BuildStreetClicked == nil then
		self.Data.Original.BuildStreetClicked = GUI_Construction.BuildStreetClicked;
	end
	GUI_Construction.BuildStreetClicked = function(_IsTrail)
		if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
		self:ResetTrailAndRoadCosts()
	    if _IsTrail == nil then
			_IsTrail = false
		end
		self:SetAwaitingVariable(false)
		g_LastPlacedParam = _IsTrail
		self.Data.IsInWallOrPalisadeContinueState = false
		self.Data.Original.BuildStreetClicked(_IsTrail)
	end

	if self.Data.Original.ContinueWallClicked == nil then
		self.Data.Original.ContinueWallClicked = GUI_BuildingButtons.ContinueWallClicked;
	end	
	GUI_BuildingButtons.ContinueWallClicked = function()
		if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
			GUI.CancelState()
		end
		self:ResetWallTurretPositions()

		local TurretID = GUI.GetSelectedEntity()
		local TurretType = Logic.GetEntityType(TurretID)
		local UpgradeCategory = UpgradeCategories.PalisadeSegment

		if TurretType ~= Entities.B_PalisadeTurret
			and TurretType ~= Entities.B_PalisadeGate_Turret_L
			and TurretType ~= Entities.B_PalisadeGate_Turret_R then
				UpgradeCategory = GetUpgradeCategoryForClimatezone("WallSegment")
				self.Data.CurrentWallTypeForClimate = UpgradeCategory
		end

		g_LastPlacedParam = UpgradeCategory
		self.Data.IsInWallOrPalisadeContinueState = true

		self.Data.Original.ContinueWallClicked()
	end

	if self.Data.Original.ContinueWallMouseOver == nil then
		self.Data.Original.ContinueWallMouseOver = GUI_BuildingButtons.ContinueWallMouseOver;
	end	
	GUI_BuildingButtons.ContinueWallMouseOver = function()
		local TurretID = GUI.GetSelectedEntity()
		local WeaponSlotID = Logic.GetWeaponHolder(TurretID)

		if WeaponSlotID ~= nil then
			TurretID = WeaponSlotID
		end

		local TurretType = Logic.GetEntityType(TurretID)
		local Costs
		local TooltipTextKey

		if TurretType == Entities.B_PalisadeTurret
        or TurretType == Entities.B_PalisadeGate_Turret_L
        or TurretType == Entities.B_PalisadeGate_Turret_R then
			TooltipTextKey = "ContinuePalisade"

			if self.Data.Costs.Other.Palisade ~= nil then
				Costs = {self.Data.Costs.Other.Palisade[1], -1, self.Data.Costs.Other.Palisade[3], -1}
			else
				Costs = {Goods.G_Wood, -1}
			end
		else
			TooltipTextKey = "ContinueWall"
			if self.Data.Costs.Other.Wall ~= nil then
				Costs = {self.Data.Costs.Other.Wall[1], -1, self.Data.Costs.Other.Wall[3], -1}
			else
				Costs = {Goods.G_Stone, -1}
			end
		end

		GUI_Tooltip.TooltipBuy(Costs, TooltipTextKey)
	end
end

function ModuleBuildingCost.Local:OverwriteGetCostLogics()
	if self.Data.Original.GetEntityTypeFullCost == nil then
		self.Data.Original.GetEntityTypeFullCost = Logic.GetEntityTypeFullCost;
	end
	Logic.GetEntityTypeFullCost = function(_buildingType)
        local Costs = self:GetCostByCostTable(Logic.GetUpgradeCategoryByBuildingType(_buildingType))
        if (Costs == nil or Costs == 0) then
            return self.Data.Original.GetEntityTypeFullCost(_buildingType);
        else
            local OriginalCosts = {self.Data.Original.GetEntityTypeFullCost(_buildingType)}
            return OriginalCosts[1], Costs[1], Costs[2], Costs[3];
        end
    end

	if self.Data.Original.GetCostForWall == nil then
		self.Data.Original.GetCostForWall = Logic.GetCostForWall;
	end
	Logic.GetCostForWall = function(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
		if _SegmentType == Entities.B_PalisadeSegment and _TurretType == Entities.B_PalisadeTurret then -- Palisade
			if (self.Data.Costs.Other.Palisade == nil) then
				return self.Data.Original.GetCostForWall(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
			else
				local Distance = self:CalculateVariableCosts(_StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
				return self.Data.Costs.Other.Palisade[1], math.ceil(Distance * self.Data.Costs.Other.Palisade[2]), self.Data.Costs.Other.Palisade[3], math.ceil(Distance * self.Data.Costs.Other.Palisade[4])
			end
		else -- Wall
			if (self.Data.Costs.Other.Wall == nil) then
				return self.Data.Original.GetCostForWall(_SegmentType, _TurretType, _StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
			else
				local Distance = self:CalculateVariableCosts(_StartTurretX, _StartTurretY, _EndTurretX, _EndTurretY)
				return self.Data.Costs.Other.Wall[1], math.ceil(Distance * self.Data.Costs.Other.Wall[2]), self.Data.Costs.Other.Wall[3], math.ceil(Distance * self.Data.Costs.Other.Wall[4])
			end
		end
	end
end

function ModuleBuildingCost.Local:OverwriteVariableCostBuildings()
	if self.Data.Original.GameCallBack_GUI_BuildRoadCostChanged == nil then
		self.Data.Original.GameCallBack_GUI_BuildRoadCostChanged = GameCallBack_GUI_BuildRoadCostChanged;
	end	
    GameCallBack_GUI_BuildRoadCostChanged = function(_Length)
		if self.Data.Costs.Other.Road == nil then
			self.Data.Original.GameCallBack_GUI_BuildRoadCostChanged(_Length)
		else
			local Meters = _Length / 100
			local MetersPerUnit = Logic.GetRoadMetersPerRoadUnit()
			local AmountFirstGood = math.ceil(self.Data.Costs.Other.Road[2] * (Meters / MetersPerUnit))
			local AmountSecondGood = math.ceil(self.Data.Costs.Other.Road[4] * (Meters / MetersPerUnit))

			if AmountFirstGood == 0 then
				AmountFirstGood = 1
			end
			if AmountSecondGood == 0 then
				AmountSecondGood = 1
			end

			self:ShowTooltipCostsOnly({Goods.G_Stone, AmountFirstGood, self.Data.Costs.Other.Road[3], AmountSecondGood})

			self.Data.RoadMultiplier.First = AmountFirstGood;
			self.Data.RoadMultiplier.Second = AmountSecondGood;

			local Costs = {Logic.GetRoadCostPerRoadUnit()}
			for i = 2, table.getn(Costs), 2 do
				Costs[i] = math.ceil(Costs[i] * (Meters / MetersPerUnit))
				if Costs[i] == 0 then
					Costs[i] = 1
				end
			end
			self.Data.RoadMultiplier.CurrentActualCost = Costs[2]
		end
    end

	if self.Data.Original.GameCallBack_GUI_ConstructWallSegmentCountChanged == nil then
		self.Data.Original.GameCallBack_GUI_ConstructWallSegmentCountChanged = GameCallBack_GUI_ConstructWallSegmentCountChanged;
	end	
	GameCallBack_GUI_ConstructWallSegmentCountChanged = function(_SegmentType, _TurretType)
		if _SegmentType == Entities.B_PalisadeSegment and _TurretType == Entities.B_PalisadeTurret then -- Palisade
			if self.Data.Costs.Other.Palisade == nil then
				self.Data.Original.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				self:ShowTooltipCostsOnly(Costs)
			end
		else
			if self.Data.Costs.Other.Wall == nil then
				self.Data.Original.GameCallBack_GUI_ConstructWallSegmentCountChanged(_SegmentType, _TurretType)
			else
				local Costs = {Logic.GetCostForWall(_SegmentType, _TurretType, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
				self:ShowTooltipCostsOnly(Costs)
			end
		end
	end

	if self.Data.Original.GameCallback_GUI_Street_Started == nil then
		self.Data.Original.GameCallback_GUI_Street_Started = GameCallback_GUI_Street_Started;
	end	
	GameCallback_GUI_Street_Started = function(_PlayerID, _X, _Y)
		self.Data.Original.GameCallback_GUI_Street_Started(_PlayerID, _X, _Y)
		if self.Data.Costs.Other.Trail ~= nil and _PlayerID == 1 then
			self.Data.StreetMultiplier.CurrentX = _X
			self.Data.StreetMultiplier.CurrentY = _Y
		end
	end

	if self.Data.Original.GameCallback_Street_Placed_Local == nil then
		self.Data.Original.GameCallback_Street_Placed_Local = GameCallback_Street_Placed_Local;
	end	
	GameCallback_Street_Placed_Local = function(_PlayerID, _X, _Y)
		self.Data.Original.GameCallback_Street_Placed_Local(_PlayerID, _X, _Y)
		if self.Data.Costs.Other.Trail ~= nil and _PlayerID == 1 then
			self.Data.StreetMultiplier.CurrentX = _X
			self.Data.StreetMultiplier.CurrentY = _Y
		end
	end
end

function ModuleBuildingCost.Local:ShowTooltipCostsOnly(_Costs)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipCostsOnly"
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath)
    local TooltipCostsContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/Costs")

	self:SetCustomToolTipCosts(TooltipCostsContainer, _Costs, false, true)
	local TooltipContainerSizeWidgets = {TooltipCostsContainer}
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, nil, nil)
	XGUIEng.ShowWidget(TooltipContainerPath, 1)
end

function ModuleBuildingCost.Local:SetCustomToolTipCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean, _UseBCSCosts)
	local TooltipCostsContainerPath = XGUIEng.GetWidgetPathByID(_TooltipCostsContainer)
	local Good1ContainerPath = TooltipCostsContainerPath .. "/1Good"
	local Goods2ContainerPath = TooltipCostsContainerPath .. "/2Goods"
	local NumberOfValidAmounts, Good1Path, Good2Path = 0, 0, 0

	for i = 2, #_Costs, 2 do
		if _Costs[i] ~= 0 then
			NumberOfValidAmounts = NumberOfValidAmounts + 1
		end
	end

	if NumberOfValidAmounts == 0 then
		XGUIEng.ShowWidget(Good1ContainerPath, 0)
		XGUIEng.ShowWidget(Goods2ContainerPath, 0)
		return
	elseif NumberOfValidAmounts == 1 then
		XGUIEng.ShowWidget(Good1ContainerPath, 1)
		XGUIEng.ShowWidget(Goods2ContainerPath, 0)
		Good1Path = Good1ContainerPath .. "/Good1Of1"
	elseif NumberOfValidAmounts == 2 then
		XGUIEng.ShowWidget(Good1ContainerPath, 0)
		XGUIEng.ShowWidget(Goods2ContainerPath, 1)
		Good1Path = Goods2ContainerPath .. "/Good1Of2"
		Good2Path = Goods2ContainerPath .. "/Good2Of2"
	elseif NumberOfValidAmounts > 2 then
		GUI.AddNote("Debug: Invalid Costs table. Not more than 2 GoodTypes allowed.")
	end

	local ContainerIndex = 1

	for i = 1, #_Costs, 2 do
		if _Costs[i + 1] ~= 0 then
			local CostsGoodType = _Costs[i]
			local CostsGoodAmount = _Costs[i + 1]     
			local IconWidget, AmountWidget
            
			if ContainerIndex == 1 then
				IconWidget = Good1Path .. "/Icon"
				AmountWidget = Good1Path .. "/Amount"
			else
				IconWidget = Good2Path .. "/Icon"
				AmountWidget = Good2Path .. "/Amount"
			end
            
			SetIcon(IconWidget, g_TexturePositions.Goods[CostsGoodType], 44)
            
			local PlayerID = GUI.GetPlayerID()
			local PlayersGoodAmount
			local ID = self:GetEntityIDToAddToOutStock(CostsGoodType)
				
			if _UseBCSCosts == true then
				PlayersGoodAmount = self:GetAmountOfGoodsInSettlement(CostsGoodType, PlayerID, self.Data.MarketplaceGoodsCount)
			elseif _GoodsInSettlementBoolean == true then
				PlayersGoodAmount = GetPlayerGoodsInSettlement(CostsGoodType, PlayerID, true)
			else 
				local IsInOutStock, BuildingID           
				if CostsGoodType == Goods.G_Gold then
					BuildingID = Logic.GetHeadquarters(PlayerID)
					IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType)
				else
					BuildingID = Logic.GetStoreHouse(PlayerID)
					IsInOutStock = Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType)
				end
                
				if IsInOutStock ~= -1 then
					PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType)
				else
					BuildingID = GUI.GetSelectedEntity()
                    
					if BuildingID ~= nil then
						if Logic.GetIndexOnOutStockByGoodType(BuildingID, CostsGoodType) == nil then
							BuildingID = Logic.GetRefillerID(GUI.GetSelectedEntity())
						end
                        
						PlayersGoodAmount = Logic.GetAmountOnOutStockByGoodType(BuildingID, CostsGoodType)
					else
						PlayersGoodAmount = 0
					end
				end
			end		
			if PlayersGoodAmount == nil then
				PlayersGoodAmount = 0
			end
      
			local Color = ""           
			if PlayersGoodAmount < CostsGoodAmount then
				Color = "{@script:ColorRed}"
			end
            
			if CostsGoodAmount > 0 then
				XGUIEng.SetText(AmountWidget, "{center}" .. Color .. CostsGoodAmount)
			else
				XGUIEng.SetText(AmountWidget, "")
			end
			ContainerIndex = ContainerIndex + 1
		end
	end
end

function ModuleBuildingCost.Local:OverwriteTooltipHandling()
	function GUI_Tooltip.SetCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean)
		local UseBCSCosts = false

		local Name = XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID())
		if Name == "Street" and self.Data.Costs.Other.Road ~= nil then
			if self.Data.Costs.Other.Road[3] then
				_Costs = {self.Data.Costs.Other.Road[1], -1, self.Data.Costs.Other.Road[3], -1}
			else
				_Costs = {self.Data.Costs.Other.Road[1], -1}
			end
		elseif Name == "Trail" and self.Data.Costs.Other.Trail ~= nil then
			if self.Data.Costs.Other.Trail[3] then
				_Costs = {self.Data.Costs.Other.Trail[1], -1, self.Data.Costs.Other.Trail[3], -1}
			else
				_Costs = {self.Data.Costs.Other.Trail[1], -1}
			end
		elseif Name == "Palisade" and self.Data.Costs.Other.Palisade ~= nil then
			if self.Data.Costs.Other.Palisade[3] then
				_Costs = {self.Data.Costs.Other.Palisade[1], -1, self.Data.Costs.Other.Palisade[3], -1}
			else
				_Costs = {self.Data.Costs.Other.Palisade[1], -1}
			end
		elseif Name == "Wall" and self.Data.Costs.Other.Wall ~= nil then
			if self.Data.Costs.Other.Wall[3] then
				_Costs = {self.Data.Costs.Other.Wall[1], -1, self.Data.Costs.Other.Wall[3], -1}
			else
				_Costs = {self.Data.Costs.Other.Wall[1], -1}
			end
		elseif Name == "StartFestival" and self.Data.Costs.Other.Festival ~= nil then
			UseBCSCosts = true
		elseif Name == "PlaceField" then
			local EntityType = Logic.GetEntityType(GUI.GetSelectedEntity())
			local UpgradeCategory

			if EntityType == Entities.B_GrainFarm then
				UpgradeCategory = GetUpgradeCategoryForClimatezone("GrainField")
			elseif EntityType == Entities.B_Beekeeper then
				UpgradeCategory = UpgradeCategories.BeeHive
			elseif EntityType == Entities.B_CattleFarm then
				UpgradeCategory = UpgradeCategories.CattlePasture
			elseif EntityType == Entities.B_SheepFarm then
				UpgradeCategory = UpgradeCategories.SheepPasture
			end
			local CostTable = self:GetCostByCostTable(UpgradeCategory)
			if (CostTable ~= nil) then
				UseBCSCosts = true
			end
		else
			local Entity = Entities[Name]
			if Entity ~= 0 and Entity ~= nil then
				local CostTable = self:GetCostByCostTable(Logic.GetUpgradeCategoryByBuildingType(Entity))
				if (CostTable ~= nil) then
					UseBCSCosts = true
				end
			end
		end

		self:SetCustomToolTipCosts(_TooltipCostsContainer, _Costs, _GoodsInSettlementBoolean, UseBCSCosts)
	end
end

function ModuleBuildingCost.Local:HandlePlacementModeUpdate(_currentUpgradeCategory)
	local LastPlaced = _currentUpgradeCategory
	local Available = false

	if (LastPlaced == false) and (self.Data.Costs.Other.Road ~= nil) then --Road
		Available = self:AreResourcesAvailable(1, self.Data.RoadMultiplier.First, self.Data.RoadMultiplier.Second)
		if (Available == false) and (self.Data.StreetMultiplier.CurrentX ~= 1 and self.Data.StreetMultiplier.CurrentY ~= 1) then
			self:ShowOverlayWidget(true)
		else
			self:ShowOverlayWidget(false)
		end
	elseif (LastPlaced == true) and (self.Data.Costs.Other.Trail ~= nil) then --Trail
		local CurrentAmountOfFirstGood, CurrentAmountOfSecondGood = self:CalculateStreetCosts()	
		if CurrentAmountOfSecondGood then -- Trail has no costs in original game, so we have to show the tooltip manually
			self:ShowTooltipCostsOnly({self.Data.Costs.Other.Trail[1], CurrentAmountOfFirstGood, self.Data.Costs.Other.Trail[3], CurrentAmountOfSecondGood})
		else
			self:ShowTooltipCostsOnly({self.Data.Costs.Other.Trail[1], CurrentAmountOfFirstGood})
		end

		self.Data.StreetMultiplier.First = CurrentAmountOfFirstGood
		self.Data.StreetMultiplier.Second = CurrentAmountOfSecondGood

		Available = self:AreResourcesAvailable(4, CurrentAmountOfFirstGood, CurrentAmountOfSecondGood)

		if (Available == false) and (self.Data.StreetMultiplier.CurrentX ~= 1 and self.Data.StreetMultiplier.CurrentY ~= 1) then
			self:ShowOverlayWidget(true)
		else
			self:ShowOverlayWidget(false)
		end	
	elseif (LastPlaced == UpgradeCategories.PalisadeSegment) and (self.Data.Costs.Other.Palisade ~= nil) then 
		local Costs = {Logic.GetCostForWall(Entities.B_PalisadeSegment, Entities.B_PalisadeTurret, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}

		Available = self:AreResourcesAvailable(3, Costs[2], Costs[4])
		if (Available == false) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
			self:ShowOverlayWidget(true)
		else
			self:ShowOverlayWidget(false)
		end	
	elseif (LastPlaced == self.Data.CurrentWallTypeForClimate) and (self.Data.Costs.Other.Wall ~= nil) then
		-- Just check for ME since all climate zones have the same costs anyway
		local Costs = {Logic.GetCostForWall(Entities.B_WallSegment_ME, Entities.B_WallTurret_ME, StartTurretX, StartTurretY, EndTurretX, EndTurretY)}
		Available = self:AreResourcesAvailable(2, Costs[2], Costs[4])
		if (Available == false) and (StartTurretX ~= 1 and StartTurretY ~= 1) then
			self:ShowOverlayWidget(true)
		else
			self:ShowOverlayWidget(false)
		end	
	else
		if (self:GetAwaitingVariable() == true) then
			if not (self:AreResourcesAvailable(LastPlaced)) then
				self:ShowOverlayWidget(true)
			else
				self:ShowOverlayWidget(false)
			end
		end	
	end
end

function ModuleBuildingCost.Local:IsCurrentStateABuildingState(_StateNameID)
	local CurrentStateID = _StateNameID

	if ((CurrentStateID == GUI.GetStateNameByID("PlaceBuilding")) 
		or (CurrentStateID == GUI.GetStateNameByID("PlaceWallGate"))
		or (CurrentStateID == GUI.GetStateNameByID("PlaceWall"))
		or (CurrentStateID == GUI.GetStateNameByID("PlaceRoad"))) then
			return true;
	else
		return false;
	end
end

-- [[
	-- > This here is the function that initializes the whole Building Cost System
	-- > Has to be called before everything else
-- ]]

function ModuleBuildingCost.Local:InitializeBuildingCostSystem()

	self:OverwriteAfterPlacement()
	self:OverwriteBuildClicked()
	self:OverwriteGetCostLogics()
	self:OverwriteVariableCostBuildings()
	self:OverwriteEndScreenCallback()
	self:FestivalCostsHandler()
	self:OverwriteTooltipHandling()

	self.Data.CurrentWallTypeForClimate = GetUpgradeCategoryForClimatezone("WallSegment")

	if self.Data.Original.PlacementUpdate == nil then
		self.Data.Original.PlacementUpdate = GUI_Construction.PlacementUpdate;
	end	
	GUI_Construction.PlacementUpdate = function()	
		self:HandlePlacementModeUpdate(g_LastPlacedParam)
		self.Data.Original.PlacementUpdate()	
	end

	if self.Data.Original.GameCallback_GUI_PlacementState == nil then
		self.Data.Original.GameCallback_GUI_PlacementState = GameCallback_GUI_PlacementState;
	end	
	GameCallback_GUI_PlacementState = function(_State, _Type)
		-- _Type = Building, Road, Wall, ...
		-- _State = Current Blocking State

		--This is needed because for some reason the Wall/Palisade Continue State does not call PlacementUpdate ?
		if self.Data.IsInWallOrPalisadeContinueState == true then
			self:HandlePlacementModeUpdate(g_LastPlacedParam)
		end
		self.Data.Original.GameCallback_GUI_PlacementState(_State, _Type)
	end

	if self.Data.Original.GUI_StateChanged == nil then
		self.Data.Original.GUI_StateChanged = GameCallback_GUI_StateChanged;
	end	
	GameCallback_GUI_StateChanged = function(_StateNameID, _Armed)
		if not self:IsCurrentStateABuildingState(_StateNameID) then
			self:SetAwaitingVariable(false)
			self:ShowOverlayWidget(false)
			self.Data.IsInWallOrPalisadeContinueState = false

			self:ResetTrailAndRoadCosts()
			self:ResetWallTurretPositions()
		end
		self.Data.Original.GUI_StateChanged(_StateNameID, _Armed)
	end

	if self.Data.Original.AreCostsAffordable == nil then
		self.Data.Original.AreCostsAffordable = AreCostsAffordable;
	end	
	AreCostsAffordable = function(_Costs, _GoodsInSettlementBoolean)
		if (self:GetAwaitingVariable() == true) then
			if (self:AreResourcesAvailable(g_LastPlacedParam) == false) then
				self:SetAwaitingVariable(false)
				if self:IsCurrentStateABuildingState(GUI.GetCurrentStateID()) == true then
					GUI.CancelState()
				end
				return false, XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources")
			else
				return true
			end
		end
		return self.Data.Original.AreCostsAffordable(_Costs, _GoodsInSettlementBoolean)
	end
		
	-- Trails don't work when called directly 
	function KeyBindings_BuildLastPlaced()
		if g_LastPlacedFunction ~= nil and g_LastPlacedParam == true then -- Trail
			KeyBindings_BuildTrail()
		elseif g_LastPlacedFunction ~= nil and g_LastPlacedParam == false then -- Road
			KeyBindings_BuildStreet()
		elseif g_LastPlacedFunction ~= nil then
			g_LastPlacedFunction(g_LastPlacedParam)
		end
	end
end

function ModuleBuildingCost.Local:OverwriteEndScreenCallback()
	if self.Data.Original.EndScreen_ExitGame == nil then
		self.Data.Original.EndScreen_ExitGame = EndScreen_ExitGame
	end	
	EndScreen_ExitGame = function()
		GUI.CancelState()
		Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
		Framework.WriteToLog("BCS: Resources Ran Out!")
	end
end

function ModuleBuildingCost.Local:ShowOverlayWidget(_flag)
	if _flag == true then
		if (self.Data.Overlay.Shown == false) or (XGUIEng.IsWidgetShownEx(self.Data.Overlay.Widget) == 0) then
			local ScreenSizeX, ScreenSizeY = GUI.GetScreenSize()
			XGUIEng.SetWidgetSize(self.Data.Overlay.Widget, ScreenSizeX * 2, ScreenSizeY * 2)
			XGUIEng.PushPage(self.Data.Overlay.Widget, false)
			XGUIEng.ShowAllSubWidgets(self.Data.Overlay.Widget, 1)
			XGUIEng.ShowWidget(self.Data.Overlay.Widget, 1)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/Background', 0)
			XGUIEng.ShowWidget('/EndScreen/EndScreen/BG', 1)
			XGUIEng.SetMaterialColor("/EndScreen/EndScreen/BG", 0, 0, 0, 0, 0);
			XGUIEng.SetWidgetScreenPosition(self.Data.Overlay.Widget, -100, -100) --To be on the safe side ^^
			
			self.Data.Overlay.Shown = true
			
			GUI.SendScriptCommand([[ModuleBuildingCost.Global.Data.AreBuildingCostsAvailable = false]])
		end
	else
		if self.Data.Overlay.Shown == true or (XGUIEng.IsWidgetShownEx(self.Data.Overlay.Widget) == 1) then
			XGUIEng.ShowAllSubWidgets(self.Data.Overlay.Widget, 0)
			XGUIEng.ShowWidget(self.Data.Overlay.Widget, 0)
			self.Data.Overlay.Shown = false
			GUI.SendScriptCommand([[ModuleBuildingCost.Global.Data.AreBuildingCostsAvailable = nil]])
		end
	end
end

function ModuleBuildingCost.Local:CalculateVariableCosts(_startX, _startY, _endX, _endY)
	local xDistance = math.abs(_startX - _endX)
	local yDistance = math.abs(_startY - _endY)
	return ((math.sqrt((xDistance ^ 2) + (yDistance ^ 2))) / 1000)
end

function ModuleBuildingCost.Local:CalculateStreetCosts()
	local posX, posY = GUI.Debug_GetMapPositionUnderMouse()
	if self.Data.StreetMultiplier.CurrentX ~= 1 and self.Data.StreetMultiplier.CurrentY ~= 1 then
		local Distance = self:CalculateVariableCosts(posX, posY, self.Data.StreetMultiplier.CurrentX, self.Data.StreetMultiplier.CurrentY)
		local FirstCostDistance = math.ceil(Distance * self.Data.Costs.Other.Trail[2])
		if FirstCostDistance < 1 then
			FirstCostDistance = 1
		end
		local SecondCostDistance
		if self.Data.Costs.Other.Trail[4] then
			SecondCostDistance = math.ceil(Distance * self.Data.Costs.Other.Trail[4])
			if SecondCostDistance < 1 then
				SecondCostDistance = 1
			end
		end
		return FirstCostDistance, SecondCostDistance
	else
		if self.Data.Costs.Other.Trail[4] then
			return 1, 1
		else
			return 1
		end
	end
end

function ModuleBuildingCost.Local:ResetTrailAndRoadCosts()
	self.Data.StreetMultiplier.First = 1
	self.Data.StreetMultiplier.Second = 1

	self.Data.StreetMultiplier.CurrentX = 1
	self.Data.StreetMultiplier.CurrentY = 1
	
	self.Data.RoadMultiplier.First = 1
	self.Data.RoadMultiplier.Second = 1
	
	self.Data.RoadMultiplier.CurrentActualCost = 1
end

function ModuleBuildingCost.Local:ResetWallTurretPositions()
	StartTurretX = 1 
	StartTurretY = 1
	
	EndTurretX = 1
	EndTurretY = 1
end

function ModuleBuildingCost.Local:FestivalCostsHandler()

	if self.Data.Original.GetFestivalCost == nil then
		self.Data.Original.GetFestivalCost = Logic.GetFestivalCost;
	end
	Logic.GetFestivalCost = function(_PlayerID, _FestivalIndex)
		if self.Data.Costs.Other.Festival == nil then
			return self.Data.Original.GetFestivalCost(_PlayerID, _FestivalIndex)
		else
			local Costs = {self.Data.Original.GetFestivalCost(_PlayerID, _FestivalIndex)}
			return self.Data.Costs.Other.Festival[1], math.ceil(Costs[2] * self.Data.Costs.Other.Festival[2]), self.Data.Costs.Other.Festival[3], self.Data.Costs.Other.Festival[4]
		end
	end

	if self.Data.Original.StartFestivalClicked == nil then
		self.Data.Original.StartFestivalClicked = GUI_BuildingButtons.StartFestivalClicked;
	end
	GUI_BuildingButtons.StartFestivalClicked = function(_FestivalIndex)
		if self.Data.Costs.Other.Festival == nil then
			self.Data.Original.StartFestivalClicked(_FestivalIndex)
		else
			local PlayerID = GUI.GetPlayerID()
			local MarketID = GUI.GetSelectedEntity()
	
			if MarketID ~= Logic.GetMarketplace(PlayerID) then
				self.Data.Original.StartFestivalClicked(_FestivalIndex)
				return;
			end
			
			local CanBuyBoolean = self:AreFestivalResourcesAvailable(PlayerID, _FestivalIndex)

			if CanBuyBoolean == true then
				Sound.FXPlay2DSound("ui\\menu_click")
				
				local Type, OriginalAmount = self.Data.Original.GetFestivalCost(PlayerID, _FestivalIndex)
				local Amount = math.ceil(OriginalAmount * self.Data.Costs.Other.Festival[2])
				
				Amount = Amount - OriginalAmount
				
				GUI.RemoveGoodFromStock(self:GetEntityIDToAddToOutStock(Goods.G_Gold), Goods.G_Gold, Amount)	

				-- Can be city goods too
				local CurrentID = self:GetEntityIDToAddToOutStock(self.Data.Costs.Other.Festival[3])
				if CurrentID == false then
					self:RemoveCostsFromOutStockCityGoods(self.Data.Costs.Other.Festival[3], self.Data.Costs.Other.Festival[4], PlayerID, false)
				else
					GUI.RemoveGoodFromStock(CurrentID, self.Data.Costs.Other.Festival[3], self.Data.Costs.Other.Festival[4])				
				end
			
				GUI.StartFestival(PlayerID, _FestivalIndex)
				StartEventMusic(MusicSystem.EventFestivalMusic, PlayerID)
				StartKnightVoiceForPermanentSpecialAbility(Entities.U_KnightSong)
				GUI.AddBuff(Buffs.Buff_Festival)
				
				info("BCS: Festival Started! Gold Amount: "..tostring(Amount))
			else
				Message(XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources"))
			end
		end
	end
end

function ModuleBuildingCost.Local:AreFestivalResourcesAvailable(_PlayerID, _FestivalIndex)
	local AmountOfFirstGood, AmountOfSecondGood;
	local Costs = {self.Data.Original.GetFestivalCost(_PlayerID, _FestivalIndex)}
	
	-- First one is always gold
	AmountOfFirstGood = Logic.GetAmountOnOutStockByGoodType(self:GetEntityIDToAddToOutStock(self.Data.Costs.Other.Festival[1]), self.Data.Costs.Other.Festival[1])
	
	local CurrentID = self:GetEntityIDToAddToOutStock(self.Data.Costs.Other.Festival[3])
	if CurrentID == false then
		AmountOfSecondGood = self:GetAmountOfGoodsInSettlement(self.Data.Costs.Other.Festival[3], _PlayerID, false)
	else
		AmountOfSecondGood = Logic.GetAmountOnOutStockByGoodType(CurrentID, self.Data.Costs.Other.Festival[3])
	end
	
	if (AmountOfFirstGood < math.ceil(Costs[2] * self.Data.Costs.Other.Festival[2]) or AmountOfSecondGood < self.Data.Costs.Other.Festival[4]) then
		return false
	else
		return true
	end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleBuildingCost)
