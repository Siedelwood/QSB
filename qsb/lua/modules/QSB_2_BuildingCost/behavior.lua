---
-- Setzt neue Baukosten eines Gebäudes über das BCS.
--
-- @param[type=string]  _upgradeCategory Die UpgradeCategory.
-- @param[type=boolean] _Controlled Durch KI kontrollieren an/aus
--
-- @within Reward
--
-- -------------------------------------------------------------------------- --

function Reward_EditBuildingConstructionCosts(...)
    return b_Reward_EditBuildingConstructionCosts:new(...);
end

b_Reward_EditBuildingConstructionCosts = {
    Name = "Reward_EditBuildingConstructionCosts",
    Description = {
        en = "Reward: Changes the construction cost for a building type.",
        de = "Lohn: Ändert die Gebäudekosten eines Gebäudetyps.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Building type", de = "Gebäudetyp" },
		{ ParameterType.Custom, en = "Amount of original good", de = "Menge Originalware" },
        { ParameterType.Custom, en = "New second good", de = "Neue zweite Ware" },
		{ ParameterType.Custom, en = "Amount of new good", de = "Menge der neuen Warea" }
    },
}

function b_Reward_EditBuildingConstructionCosts:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_EditBuildingConstructionCosts:GetCustomData(_Index)
    if _Index == 1 then
        return UpgradeCategories; -- TODO: This in Global Lua State?
    elseif _Index == 2 then -- Old Cost Amount
        return 4; -- TODO: Find a better way to get the costs in global state ? (Logic accessible?)
    elseif _Index == 3 then -- New Good
        return Goods;
    elseif _Index == 4 then -- New Good Amount
        return 1;
    end
end

function b_Reward_EditBuildingConstructionCosts:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.UpgradeCategory = _Parameter;
	elseif (_Index == 1) then
		self.OriginalCostAmount = _Parameter;
    elseif (_Index == 2) then
        self.NewGood = _Parameter;
	elseif (_Index == 3) then
		self.NewGoodAmount = _Parameter;
	else
		assert(false, "Reward_EditBuildingConstructionCosts: Missing _Index")
    end
end

function b_Reward_EditBuildingConstructionCosts:CustomFunction(_Quest)
    if BCS then
        BCS.SetConstructionCosts(self.UpgradeCategory, self.OriginalCostAmount, self.NewGood, self.NewGoodAmount)
    else
        assert(false, "Reward_EditBuildingConstructionCosts: BCS was not initialized!")
    end
end

Swift:RegisterBehavior(b_Reward_EditBuildingConstructionCosts);

---
-- Setzt neue Ausbaukosten eines Gebäudes über das BCS.
--
-- @param[type=string]  _upgradeCategory Die UpgradeCategory.
-- @param[type=boolean] _Controlled Durch KI kontrollieren an/aus
--
-- @within Reward
--
-- -------------------------------------------------------------------------- --

function Reward_EditBuildingUpgradeCosts(...)
    return b_Reward_EditBuildingUpgradeCosts:new(...);
end

b_Reward_EditBuildingUpgradeCosts = {
    Name = "Reward_EditBuildingUpgradeCosts",
    Description = {
        en = "Reward: Changes the construction cost for a building type.",
        de = "Lohn: Ändert die Gebäudekosten eines Gebäudetyps.",
    },
    Parameter = {
        { ParameterType.Custom, en = "Building type", de = "Gebäudetyp" },
		{ ParameterType.Custom, en = "Amount of original good", de = "Menge Originalware" },
        { ParameterType.Custom, en = "New second good", de = "Neue zweite Ware" },
		{ ParameterType.Custom, en = "Amount of new good", de = "Menge der neuen Warea" }
    },
}

function b_Reward_EditBuildingUpgradeCosts:GetRewardTable()
    return { Reward.Custom, {self, self.CustomFunction} }
end

function b_Reward_EditBuildingUpgradeCosts:GetCustomData(_Index)
    if _Index == 1 then
        return UpgradeCategories; -- TODO: This in Global Lua State?
    elseif _Index == 2 then -- Old Cost Amount
        return 4; -- TODO: Find a better way to get the costs in global state ? (Logic accessible?)
    elseif _Index == 3 then -- New Good
        return Goods;
    elseif _Index == 4 then -- New Good Amount
        return 1;
    end
end

function b_Reward_EditBuildingUpgradeCosts:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.UpgradeCategory = _Parameter;
	elseif (_Index == 1) then
		self.OriginalCostAmount = _Parameter;
    elseif (_Index == 2) then
        self.NewGood = _Parameter;
	elseif (_Index == 3) then
		self.NewGoodAmount = _Parameter;
	else
		assert(false, "Reward_EditBuildingUpgradeCosts: Missing _Index")
    end
end

function b_Reward_EditBuildingUpgradeCosts:CustomFunction(_Quest)
    if BCS then
        BCS.SetConstructionCosts(self.UpgradeCategory, self.OriginalCostAmount, self.NewGood, self.NewGoodAmount)
    else
        assert(false, "Reward_EditBuildingUpgradeCosts: BCS was not initialized!")
    end
end

Swift:RegisterBehavior(b_Reward_EditBuildingUpgradeCosts);