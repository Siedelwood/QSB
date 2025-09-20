-- -------------------------------------------------------------------------- --

---
-- Setzt die Lagermenge im Lagerhaus.
--
--
-- Wenn der Parameter _upgradeLevel == nil ist, dann wird die derzeitige Lagermenge
-- für ein spezifisches Lagerhaus gesetzt. Ansonsten wird für den Entitätentyp der
-- übergebenen ID der Wert gesetzt.
--
-- @param[type=number]   _storehouseID ID oder Scriptname des Lagerhauses.
-- @param[type=number]   _stockSize Die neue Lagermenge.
-- @param[type=number]   _upgradeLevel Für welche Ausbaustufe der Wert gesetzt werden soll.
-- @within HookLibrary
--
function API.SetStorehouseStockSize(_storehouseID, _stockSize, _upgradeLevel)
	assert(_stockSize and type(_stockSize) == "number" and _stockSize > 0, "_stockSize must be a positive integer value!")

	local OriginalValues = {250, 500, 1000, 2000}
	local Storehouse = GetID(_storehouseID)
	if Storehouse ~= 0 and Storehouse ~= nil then
		local IsVillageStorehouse = Logic.IsEntityInCategory(Storehouse, EntityCategories.VillageStorehouse) == 0;
		local IsCityStorehouse = Logic.IsEntityInCategory(Storehouse, EntityCategories.Storehouse) == 0;
		if not IsVillageStorehouse and not IsCityStorehouse then -- TODO: Does this cover all storehouses?
			assert(false, "Storehouse was not valid!")
			return;
		end

		if _upgradeLevel == nil then
			local Amount = Logic.GetMaxAmountOnStock(Storehouse) -- Very important, do not delete!
			EMXHookLibrary.SetMaxStorehouseStockSize(Storehouse, _stockSize)
		else
			EMXHookLibrary.SetEntityTypeOutStockCapacity(Logic.GetEntityType(Storehouse), _upgradeLevel, _stockSize)
			ModuleHookLibrary.Global.ResetValues[EMXHookLibrary.SetEntityTypeOutStockCapacity] = ModuleHookLibrary.Global.ResetValues[EMXHookLibrary.SetEntityTypeOutStockCapacity] or {}
			ModuleHookLibrary.Global.ResetValues[EMXHookLibrary.SetEntityTypeOutStockCapacity][Logic.GetEntityType(Storehouse)] = ModuleHookLibrary.Global.ResetValues[EMXHookLibrary.SetEntityTypeOutStockCapacity][Logic.GetEntityType(Storehouse)] or {}
			ModuleHookLibrary.Global.ResetValues[EMXHookLibrary.SetEntityTypeOutStockCapacity][Logic.GetEntityType(Storehouse)] = OriginalValues
		end
	end
	
end
