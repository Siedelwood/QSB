-- -------------------------------------------------------------------------- --

Addon_HuntableLifestock = {
    Properties = {
        Name = "Addon_HuntableLifestock",
        Version = "1.0.0",
    },

    Global = {
        -- Die Globalen Funktionen und Daten des Addons
        Data = {
			IsEnabled = false,
		},
    },

    Local = {
        -- Die Lokalen Funktionen und Daten des Addons
		Data = {
			IsEnabled = false,
			WasActivated = false,
			HunterButtonID = 0,
		},
    },

    Shared = {
        -- Funktionen und Daten des Addons die jeweils in beiden Scripten
        -- vorhanden sein sollen
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_HuntableLifestock.Global:OnGameStart() return end
function Addon_HuntableLifestock.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return;
    end
end

function Addon_HuntableLifestock.Global:ToggleHuntableLifestock(_enable)
	if self.Data.IsEnabled ~= _enable then
		Logic.ExecuteInLuaLocalState([[
			Addon_HuntableLifestock.Local.ToggleHuntableLifestock(]].._enable..[[)
		]])
		self.Data.IsEnabled = _enable
	end
end
-- Local -------------------------------------------------------------------- --
function Addon_HuntableLifestock.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return;
    end
end
function Addon_HuntableLifestock.Local:ToggleHuntableLifestock(_enable)
	self.Data.IsEnabled = _enable
	
	if not self.Data.WasActivated then
		self:AddHuntableLifestockButton()
		self.Data.WasActivated = true
	end
end

function Addon_HuntableLifestock.Local:AddHuntableLifestockButton()
	if self.Data.HunterButtonID == 0 then
		self.Data.HunterButtonID = API.AddBuildingButton(
		-- Aktion
		function(_WidgetID, _BuildingID)
			local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
			local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)
			if HuntCowsAllowed == true then
				GUI.SetOptionalHuntableState(_BuildingID, 2, false)
				GUI.SetOptionalHuntableState(_BuildingID, 1, true)
				Message("Es werden Schafe gejagt!")
			elseif HuntSheepAllowed == true then
				GUI.SetOptionalHuntableState(_BuildingID, 2, false)
				GUI.SetOptionalHuntableState(_BuildingID, 1, false)
				Message("Es werden keine Weidetiere gejagt!")
			else
				GUI.SetOptionalHuntableState(_BuildingID, 2, true)
				GUI.SetOptionalHuntableState(_BuildingID, 1, false)
				Message("Es werden Kühe gejagt!")
			end
			Sound.FXPlay2DSound("ui\\menu_click")
		end,
		-- Tooltip
		function(_WidgetID, _BuildingID)
			local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
			local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)
			local ToolTipText = ""
			if HuntCowsAllowed == true then
				ToolTipText = "Kühe"
			elseif HuntSheepAllowed == true then
				ToolTipText = "Schafe"
			else
				ToolTipText = "keine Tiere"
			end
			API.SetTooltipCosts("Jagd auf Weidetiere", "Gebt Schafe und Kühe zur Jagd frei!{cr}{@color:0,128,0,255}Momentan werden "..ToolTipText.." gejagt!", 
				"Momentan nicht möglich", {nil, nil});
		end,
		-- Update
		function(_WidgetID, _BuildingID)
			if Logic.GetEntityType(_BuildingID) == Entities.B_HuntersHut and self.Data.IsEnabled then
				XGUIEng.ShowWidget(_WidgetID, 1)
				local HuntCowsAllowed = Logic.GetOptionalHuntableState(_BuildingID, 2)
				local HuntSheepAllowed = Logic.GetOptionalHuntableState(_BuildingID, 1)
				if HuntCowsAllowed == true then
					SetIcon(_WidgetID, {4, 1});
				elseif HuntSheepAllowed == true then
					SetIcon(_WidgetID, {4, 2});
				else
					SetIcon(_WidgetID, {3, 16});			
				end
			else
				XGUIEng.ShowWidget(_WidgetID, 0)	
			end
		end);
	end
end

Swift:RegisterModule(Addon_HuntableLifestock)