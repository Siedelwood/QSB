-- -------------------------------------------------------------------------- --

---
-- Dieses Modul ermöglicht es die Kosten für den Bau und Ausbau von Gebäuden anzupassen.
-- Asserdem können auch andere Baukosten angepasst werden (zB Palisaden, Mauern und Wege).
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.qsb_1_entity.qsb_1_entity.html">(1) Entitätensteuerung</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
-- @author EisenMonoxid, Jelumar
--

-- TODO: Check BuildingUpgraded Event

BCS = BCS or {
    UpgradeToOne = 1,
    UpgradeToTwo = 2,
    UpgradeThree = 3,
}

-- -------------------------------------------------------------------------- --

---
-- Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level
--
-- @param[type=number] _Building Der Typ des Gebäudes, zB Entities.B_Cathedral
-- @param[type=number] _Level    Das Level für das die Ausbaukosten überschrieben werden sollen
-- @param[type=number] _Good1    Der neue erste Rohstoff der für den Ausbau bezahlt werden soll
-- @param[type=number] _Amount1  (Optional) Die Menge des ersten Rohstoffs (bei nil wird gelöscht)
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Ausbau bezahlt werden soll
-- @param[type=number] _Amount2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
-- @see BCS.EditUpgradeCosts
--
-- @usage
-- -- Neue Ausbaukosten definieren
-- BCS.SetUpgradeCosts(Entities.B_Cathedral, 1, Goods.G_Wood, 100, Goods.G_Stone, 100)
-- -- Auf Originalkosten zurücksetzen
-- BCS.SetUpgradeCosts(Entities.B_Cathedral, 1, 0)
--
function BCS.SetUpgradeCosts(_Building, _Level, _Good1, _Amount1, _Good2, _Amount2)
    assert(_Building and type(_Building) == "number", "_Building muss ein number sein.")
    assert(_Level and type(_Level) == "number" and ( _Level >= 0 and _Level < 4 ), "_Level muss ein number zwischen 1 und 3 sein.")
    assert(_Good1 and type(_Good1) == "number", "_Good1 muss ein number sein.")
    assert(not _Amount1 or type(_Amount1) == "number" and _Amount1 > 0, "_Amount1 muss ein number größer null sein.")
    if _Good2 or _Amount2 then
        assert(_Good2 and type(_Good2) == "number", "_Good2 muss ein number sein.")
        assert(_Amount2 and type(_Amount2) == "number", "_Amount2 muss ein number sein.")
    end

    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		ModuleBuildingCost.Local:SetUpgradeCosts(_Building, _Level, _Good1, _Amount1, _Good2, _Amount2)
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				ModuleBuildingCost.Local:SetUpgradeCosts(%d, %d, %d, %d, %d, %d)
			]],
			_Building,
            _Level,
			_Good1,
			_Amount1,
			_Good2,
            _Amount2
		))
	end
end

---
-- Überschreibt die Baukosten eines Gebäudes
-- Hier muss beachtet werden, dass der erste Kostenparameter zusätzliche Kosten für den ersten Rohstoff darstellen und nicht den neuen Kostenwert
--
-- @param[type=number] _Building 			UpgradeKategorie des Gebäudes, zB UpgradeCategories.BroomMaker
-- @param[type=number] _AdditionalAmount1   Zusätzliche Menge für den ersten Rohstoff (bei nil wird gelöscht)
-- @param[type=number] _Good2    			(Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Amount2  			(Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
-- @see BCS.SetUpgradeCosts
--
-- @usage
-- -- Neue Ausbaukosten definieren
-- BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, 50, Goods.G_Gold, 100)
-- -- Auf Originalkosten zurücksetzen
-- BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, nil)
--
function BCS.SetConstructionCosts(_Building, _AdditionalAmount1, _Good2, _Amount2)
	assert(not _AdditionalAmount1 or (type(_AdditionalAmount1) == "number" and _AdditionalAmount1 >= 0), "_AdditionalAmount1 muss positiv sein")

	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		local upgradeCategory = Logic.GetUpgradeCategoryByBuildingType(_Building)
		-- Check for valid UpgradeCategory (Beautification_VictoryColumn == 97, the highest Category)
		assert(upgradeCategory > 0 and upgradeCategory <= UpgradeCategories.Beautification_VictoryColumn)

		if _AdditionalAmount1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Construction[upgradeCategory] = nil
			return
		end

		--Check for Invalid GoodAmount
		assert(not _Amount2 or _Amount2 >= 1)

		-- local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(upgradeCategory)
		local Costs = {ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost(_Building)}
		local newAmount1 = _AdditionalAmount1 + Costs[2]

		-- Insert/Update table entry
		ModuleBuildingCost.Local.Data.Costs.Construction[upgradeCategory] = {newAmount1, _Good2, _Amount2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.SetConstructionCosts(%d, %d, %d, %d)
			]],
			_Building,
			_AdditionalAmount1,
			_Good2,
			_Amount2
		))
	end
end

---
-- Gibt an welchen Rabatt Hakim auf das Ausbauen von Gebäuden erhält
--
-- @param[type=number] _Discount Rabatt den Hakim bekommt zwischen 0 (nichts) und 1 (alles)
-- @within Suche
-- @see BCS.SetUpgradeDiscountFunction
--
-- @usage
-- -- Hakim bekommt 20 Prozent Rabatt auf den Ausbau von Gebäuden
-- BCS.SetHakimUpgradeDiscount(0.2)
--
function BCS.SetHakimUpgradeDiscount(_Discount)
    assert(_Discount and type(_Discount) == "number" and _Discount >= 0 and _Discount <= 1, "Hakims Rabatt muss zwischen 0 und 1 liegen")

    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
        ModuleBuildingCost.Local:SetHakimUpgradeDiscount(_Discount)
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.SetHakimUpgradeDiscount(%d)
			]],
			_Discount
		))
	end
end

---
-- Übergibt eine Rabattfunktion für den Ausbau von Gebäuden.
-- Diese gelten nur für angepasste Ausbaukosten und können nicht mehr zurückgenommen werden.
--
-- @param[type=number]  _Function  Rabattfunktion die einen Wert zwischen 0 und 1 zurückgibt
-- @param[type=boolean] _CanBeZero Soll der zweite Rohstoff auf Null gerundet werden können?
-- @within Suche
-- @see BCS.SetHakimUpgradeDiscount
--
-- @usage
-- -- Der Spieler bekommt 20 Prozent Rabatt auf den Ausbau von Gebäuden.
-- -- Die Kosten des zweiten Rohstoffs wird werden immer mindestens 1 sein.
-- BCS.SetUpgradeDiscountFunction(function()
--     return 0.2
-- end, false)
--
function BCS.SetUpgradeDiscountFunction(_Function, _CanBeZero)
    assert(API.GetScriptEnvironment() == QSB.Environment.LOCAL, "Discount functions can only be set in local environment.")
    assert(_Function and type(_Function) == "function", "Only functions can be set as discount functions.")

    ModuleBuildingCost.Local:SetUpgradeDiscountFunction(_Function, _CanBeZero)
end

---
-- Übergibt eine Rabattfunktion für die Zusatzkosten auf den Originalrohstoff beim den Bau von Gebäuden.
-- Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.
--
-- @param[type=number]  _Function  Rabattfunktion die einen Wert zwischen 0 und 1 zurückgibt
-- @param[type=boolean] _CanBeZero Soll der zweite Rohstoff auf Null gerundet werden können?
-- @within Suche
-- @see BCS.SetConstructionAddedGoodDiscountFunction
--
-- @usage
-- -- Der Spieler bekommt 20 Prozent Rabatt auf die Zusatzkosten auf den Originalrohstoff für den Bau von Gebäuden.
-- -- Die Zusatzkosten können auf Null herabgerundet werden.
-- BCS.SetConstructionOriginalGoodDiscountFunction(function()
--     return 0.2
-- end, true)
--
function BCS.SetConstructionOriginalGoodDiscountFunction(_Function, _CanBeZero)
    assert(API.GetScriptEnvironment() == QSB.Environment.LOCAL, "Discount functions can only be set in local environment.")
    assert(_Function and type(_Function) == "function", "Only functions can be set as discount functions.")

    ModuleBuildingCost.Local:SetConstructionOriginalGoodDiscountFunction(_Function, _CanBeZero)
end

---
-- Übergibt eine Rabattfunktion für die Kosten des zweiten Rohstoffs für den Bauen von Gebäuden.
-- Diese gelten nur für angepasste Baukosten und können nicht mehr zurückgenommen werden.
--
-- @param[type=number]  _Function  Rabattfunktion die einen Wert zwischen 0 und 1 zurückgibt
-- @param[type=boolean] _CanBeZero Soll der zweite Rohstoff auf Null gerundet werden können?
-- @within Suche
-- @see BCS.SetConstructionOriginalGoodDiscountFunction
--
-- @usage
-- -- Der Spieler bekommt 20 Prozent Rabatt auf die Kosten des zweiten Rohstoffs beim Bau von Gebäuden.
-- -- Die Kosten des zweiten Rohstoffs wird werden immer mindestens 1 sein.
-- BCS.SetConstructionAddedGoodDiscountFunction(function()
--     return 0.2
-- end, false)
--
function BCS.SetConstructionAddedGoodDiscountFunction(_Function, _CanBeZero)
    assert(API.GetScriptEnvironment() == QSB.Environment.LOCAL, "Discount functions can only be set in local environment.")
    assert(_Function and type(_Function) == "function", "Only functions can be set as discount functions.")

    ModuleBuildingCost.Local:SetConstructionAddedGoodDiscountFunction(_Function, _CanBeZero)
end

---
-- Überschreibt die Baukosten eines Gebäudes
--
-- @param[type=number] _UpgradeCategory UpgradeKategorie des Gebäudes, zB UpgradeCategories.BroomMaker
-- @param[type=number] _Amount1  		Die neue Menge des ersten Rohstoffs (bei nil wird gelöscht)
-- @param[type=number] _Good2    		(Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Amount2  		(Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
-- @see BCS.SetUpgradeCosts
--
-- @usage
-- -- Neue Ausbaukosten definieren
-- BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, 100, Goods.G_Gold, 100)
-- -- Auf Originalkosten zurücksetzen
-- BCS.SetUpgradeCosts(UpgradeCategories.BroomMaker, nil)
--
function BCS.EditBuildingCosts(_UpgradeCategory, _Amount1, _Good2, _Amount2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		-- Check for unloaded script
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		-- Check for valid UpgradeCategory (Beautification_VictoryColumn == 97, the highest Category)
		assert(_UpgradeCategory > 0 and _UpgradeCategory <= UpgradeCategories.Beautification_VictoryColumn)

		if _Amount1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Construction[_UpgradeCategory] = nil
			return
		end

		assert(not _Amount2 or _Amount2 >= 1)
		local AmountOfTypes, FirstBuildingType = Logic.GetBuildingTypesInUpgradeCategory(_UpgradeCategory)
		local Costs = {ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost(FirstBuildingType)}
		assert(_Amount1 >= Costs[2])

		-- Insert/Update table entry
		ModuleBuildingCost.Local.Data.Costs.Construction[_UpgradeCategory] = {_Amount1, _Good2, _Amount2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditBuildingCosts(%d, %d, %d, %d)
			]],
			_UpgradeCategory,
			_Amount1,
			_Good2,
			_Amount2
		))
	end
end

---
-- Überschreibt die Ausbaukosten eines Gebäudes für eingegebenes Level
--
-- @param[type=number] _UpgradeCategory UpgradeKategorie des Gebäudes, zB UpgradeCategories.Cathedral
-- @param[type=number] _Level    		Das Level für das die Ausbaukosten überschrieben werden sollen
-- @param[type=number] _Good1    		Der neue erste Rohstoff der für den Ausbau bezahlt werden soll
-- @param[type=number] _Amount1  		(Optional) Die Menge des ersten Rohstoffs (bei nil wird gelöscht)
-- @param[type=number] _Good2    		(Optional) Der neue zweite Rohstoff der für den Ausbau bezahlt werden soll
-- @param[type=number] _Amount2  		(Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
-- @see BCS.SetUpgradeCosts
--
-- @usage
-- -- Neue Ausbaukosten definieren
-- BCS.SetUpgradeCosts(UpgradeCategories.Cathedral, 1, Goods.G_Wood, 100, Goods.G_Stone, 100)
-- -- Auf Originalkosten zurücksetzen
-- BCS.SetUpgradeCosts(UpgradeCategories.Cathedral, 1, 0)
--
function BCS.EditUpgradeCosts(_UpgradeCategory, _Level, _Good1, _Amount1, _Good2, _Amount2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		local amount, building = Logic.GetBuildingTypesInUpgradeCategory(_UpgradeCategory)
		BCS.SetUpgradeCosts(building, _Level, _Good1, _Amount1, _Good2, _Amount2)
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditUpgradeCosts(%d, %d, %d, %d, %d, %d)
			]],
			_UpgradeCategory,
            _Level,
			_Good1,
			_Amount1,
			_Good2,
            _Amount2
		))
	end
end

---
-- Überschreibt die Baukosten der Straßen
--
-- @param[type=number] _Factor1  Der neue Faktor für den ersten Rohstoff
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
--
-- @usage
-- -- Neue Baukosten definieren
-- BCS.EditRoadCosts(5, Goods.G_Gold, 5)
-- -- Auf Originalkosten zurücksetzen
-- BCS.EditRoadCosts(nil)
--
function BCS.EditRoadCosts(_Factor1, _Good2, _Factor2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		if _Factor1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Other.Road = nil
			return
		end
		assert(_Factor1 >= 3)
		ModuleBuildingCost.Local.Data.Costs.Other.Road = {Goods.G_Stone, _Factor1, _Good2, _Factor2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditRoadCosts(%d, %d, %d)
			]],
			_Factor1,
			_Good2,
			_Factor2
		))
	end
end

---
-- Überschreibt die Baukosten der Mauern
--
-- @param[type=number] _Factor1  Der neue Faktor für den ersten Rohstoff
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
--
-- @usage
-- -- Neue Baukosten definieren
-- BCS.EditWallCosts(5, Goods.G_Gold, 5)
-- -- Auf Originalkosten zurücksetzen
-- BCS.EditWallCosts(nil)
--
function BCS.EditWallCosts(_Factor1, _Good2, _Factor2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		if _Factor1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Other.Wall = nil
			return
		end
		assert(_Factor1 >= 3)
		ModuleBuildingCost.Local.Data.Costs.Other.Wall = {Goods.G_Stone, _Factor1, _Good2, _Factor2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditWallCosts(%d, %d, %d)
			]],
			_Factor1,
			_Good2,
			_Factor2
		))
	end
end

---
-- Überschreibt die Baukosten der Palisaden
--
-- @param[type=number] _Factor1  Der neue Faktor für den ersten Rohstoff
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
--
-- @usage
-- -- Neue Baukosten definieren
-- BCS.EditPalisadeCosts(5, Goods.G_Gold, 5)
-- -- Auf Originalkosten zurücksetzen
-- BCS.EditPalisadeCosts(nil)
--
function BCS.EditPalisadeCosts(_Factor1, _Good2, _Factor2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		if _Factor1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Other.Palisade = nil
			return
		end
		assert(_Factor1 >= 3)
		ModuleBuildingCost.Local.Data.Costs.Other.Palisade = {Goods.G_Wood, _Factor1, _Good2, _Factor2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditPalisadeCosts(%d, %d, %d)
			]],
			_Factor1,
			_Good2,
			_Factor2
		))
	end
end

---
-- Überschreibt die Baukosten der Wege
--
-- @param[type=number] _Good1    Der neue erste Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor1  Der neue Faktor für den ersten Rohstoff
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
--
-- @usage
-- -- Neue Baukosten definieren
-- BCS.EditTrailCosts(Goods.G_Wood ,5, Goods.G_Gold, 5)
-- -- Auf Originalkosten zurücksetzen
-- BCS.EditTrailCosts(nil)
--
function BCS.EditTrailCosts(_Good1, _Factor1, _Good2, _Factor2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		if _Good1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Other.Trail = nil
			return
		end
		ModuleBuildingCost.Local.Data.Costs.Other.Trail = {_Good1, _Factor1, _Good2, _Factor2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.EditTrailCosts(%d, %d, %d, %d)
			]],
			_Good1,
			_Factor1,
			_Good2,
			_Factor2
		))
	end
end

---
-- Setzt den Rückerstattungssatz beim Abriß von Gebäuden
--
-- @param[type=number] _Factor1  Anteil der Rückerstattung für den ersten Rohstoff
-- @param[type=number] _Factor2  Anteil der Rückerstattung für den zweiten Rohstoff
-- @within Suche
--
-- @usage
-- -- Es wird die Hälfte Zurückerstattet
-- BCS.SetKnockDownFactor(0.5, 0.5)
--
function BCS.SetKnockDownFactor(_Factor1, _Factor2) --0.5 is half of the cost
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		assert(_Factor1 <= 1 and _Factor2 <= 1)
		ModuleBuildingCost.Local.Data.CurrentKnockDownFactor = _Factor2
		ModuleBuildingCost.Local.Data.CurrentOriginalGoodKnockDownFactor = _Factor1
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.SetKnockDownFactor(%d, %d)
			]],
			_Factor1,
			_Factor2
		))
	end
end

---
-- Überschreibt die Kosten für Feste
--
-- @param[type=number] _Factor1  Der neue Faktor für den ersten Rohstoff
-- @param[type=number] _Good2    (Optional) Der neue zweite Rohstoff der für den Bau bezahlt werden soll
-- @param[type=number] _Factor2  (Optional) Die Menge des zweiten Rohstoffs
-- @within Suche
--
-- @usage
-- -- Neue Kosten definieren
-- BCS.EditFestivalCosts(5, Goods.G_Stone, 5)
-- -- Auf Originalkosten zurücksetzen
-- BCS.EditFestivalCosts(nil)
--
function BCS.EditFestivalCosts(_Factor1, _Good2, _Factor2)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		assert(type(ModuleBuildingCost.Local.Data.Original.GetEntityTypeFullCost) == "function")

		if _Factor1 == nil then
			ModuleBuildingCost.Local.Data.Costs.Other.Festival = nil
			return
		end

		assert(_Factor1 >= 1)
		ModuleBuildingCost.Local.Data.Costs.Other.Festival = {Goods.G_Gold, _Factor1, _Good2, _Factor2}
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				BCS.(%d, %d, %d)
			]],
			_Factor1,
			_Good2,
			_Factor2
		))
	end
end

---
-- Sollen Stadtgüter zurückerstattet werden?
--
-- @param[type=boolean] _Flag Sollen Stadtgüter zurückerstattet werden?
-- @within Suche
--
-- @usage
-- -- Stadtgüter werden zurückerstattet
-- BCS.SetRefundCityGoods(true)
--
function BCS.SetRefundCityGoods(_Flag)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		ModuleBuildingCost.Local.Data.RefundCityGoods = _Flag
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				ModuleBuildingCost.Local.Data.RefundCityGoods = %s
			]],
			tostring(_Flag)
		))
	end
end

---
-- Sollen Güter auf dem Marktplatz betrachtet werden?
--
-- @param[type=boolean] _Flag Sollen Güter auf dem Marktplatz betrachtet werden?
-- @within Suche
--
-- @usage
-- -- Güter auf dem Marktplatz werden betrachtet
-- BCS.SetCountGoodsOnMarketplace(true)
--
function BCS.SetCountGoodsOnMarketplace(_Flag)
	if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
		ModuleBuildingCost.Local.Data.MarketplaceGoodsCount = _Flag
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				ModuleBuildingCost.Local.Data.MarketplaceGoodsCount = %s
			]],
			tostring(_Flag)
		))
	end
end