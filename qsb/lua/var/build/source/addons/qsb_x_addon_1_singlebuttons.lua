
---
-- Dieses Addon erlaubt es Gebäuden einen Button für Single Reserve und Single Knockdown zu geben
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.qsb_2_buildingui.qsb_2_buildingui.html">(2) Gebäudeschalter</a></li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
-- @author EisenMonoxid, totalwarANGEL, Jelumar
--

API = API or {}

---
-- Aktiviert oder deaktiviert die Single Stop Buttons. Single Stop ermöglicht
-- das Anhalten eines einzelnen Betriebes, anstelle des Anhaltens aller
-- Betriebe des gleichen Typs.
--
-- @param[type=boolean] _Flag Single Stop nutzen
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
-- @usage
-- -- Single Stop nutzen
-- API.UseSingleStop(true)
-- -- Single Stop deaktivieren
-- API.UseSingleStop(false)
--
function API.UseSingleStop(_Flag)
    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
        if _Flag == true then
            Addon_SingleButtons.Local:AddSingleStopButton()
        else
            Addon_SingleButtons.Local:DropSingleStopButton()
        end
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				API.UseSingleStop(%s)
			]],
            tostring(_Flag)
		))
	end
end

---
-- Aktiviert oder deaktiviert die Single Reserve Buttons. Single Reserve ermöglicht
-- das Anhalten des Verbrauchs eines Gebäudetyps.
--
-- @param[type=boolean] _Flag Single Reserve nutzen
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
-- @usage
-- -- Single Reserve nutzen
-- API.UseSingleReserve(true)
-- -- Single Reserve deaktivieren
-- API.UseSingleReserve(false)
--
function API.UseSingleReserve(_Flag)
    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
        if _Flag == true then
            Addon_SingleButtons.Local:AddSingleReserveButton()
        else
            Addon_SingleButtons.Local:DropSingleReserveButton()
        end
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				API.UseSingleReserve(%s)
			]],
            tostring(_Flag)
		))
	end
end

---
-- Aktiviere oder deaktiviere Rückbau bei Stadt- und Rohstoffgebäuden. Die
-- Rückbaufunktion erlaubt es dem Spieler bei Stadt- und Rohstoffgebäude
-- der Stufe 2 und 3 jeweils eine Stufe zu zerstören. Der überflüssige
-- Arbeiter wird entlassen.
--
-- @param[type=boolean] _Flag Downgrade nutzen
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
-- @usage
-- -- Downgrade nutzen
-- API.UseDowngrade(true)
-- -- Downgrade deaktivieren
-- API.UseDowngrade(false)
--
function API.UseDowngrade(_Flag)
    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
        if _Flag == true then
            Addon_SingleButtons.Local:AddSingleDowngradeButton()
        else
            Addon_SingleButtons.Local:DropSingleDowngradeButton()
        end
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				API.UseDowngrade(%s)
			]],
            tostring(_Flag)
		))
	end
end

---
-- Setze die Kosten für den Rückbau von Gebäuden
--
-- @param[type=number] _Amount Setze Kosten für den Rückbau von Gebäuden
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
-- @usage
-- -- Downgrade Kosten auf 50 Gold setzen
-- API.SetDowngradeCosts(50)
-- -- Downgrade Kosten zurücksetzen
-- API.SetDowngradeCosts(0)
--
function API.SetDowngradeCosts(_Amount)
    if API.GetScriptEnvironment() == QSB.Environment.LOCAL then
        assert(_Amount and type(_Amount) == "number" and _Amount >= 0, " API.SetDowngradeCosts: Costs for downgrade must be positive")
        Addon_SingleButtons.Local:SetDowngradeCosts(_Amount)
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				API.SetDowngradeCosts(%d)
			]],
            _Amount
		))
	end
end-- -------------------------------------------------------------------------- --

Addon_SingleButtons = {
    Properties = {
        Name = "Addon_SingleButtons",
        Version = "1.0.0",
    },

    Global = {
        Data = {},
    },

    Local = {
        Data = {
            Button = {
                SingleStop = nil,
                SingleReserve = nil,
                SingleKnockDown = nil,
            },
            DowngradeCosts = 0,
        },
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_SingleButtons.Global:OnGameStart()
end

-- Local -------------------------------------------------------------------- --

function Addon_SingleButtons.Local:OnGameStart()
end

function Addon_SingleButtons.Local:AddSingleStopButton()
    if self.Data.Button.SingleStop then
        return
    end
    self.Data.Button.SingleStop = API.AddBuildingButton(
        function(_WidgetID, _BuildingID)
            local IsStopped = Logic.IsBuildingStopped(_BuildingID)
            GUI.SetStoppedState(_BuildingID, not IsStopped)
        end,
        function(_WidgetID, _BuildingID)
            local Title = {
                de = "Produktion anhalten",
                en = "Stop production",
                fr = "Arrêter la production",
            }
            local Text = {
                de = "- Gebäude produziert keine Waren {cr}- Siedler verbrauchen keine Güter {cr}- Bedürfnisse müssen nicht erfüllt werden",
                en = "- Building does not produce goods {cr}- Settlers do not consume goods {cr}- Needs do not have to be met",
                fr = "- le bâtiment ne produit pas de biens {cr}- les settlers ne consomment pas de biens {cr}- les besoins ne doivent pas être satisfaits",
            }
            if Logic.IsBuildingStopped(_BuildingID) then
                Title = {
                    de = "Produktion fortführen",
                    en = "Continue production",
                    fr = "Poursuivre la production",
                }
                Text = {
                    de = "- Gebäude produziert Waren {cr}- Siedler verbrauchen Güter {cr}- Bedürfnisse müssen erfüllt werden",
                    en = "- Building produces goods {cr}- settlers consume goods {cr}- needs must be met",
                    fr = "- Le bâtiment produit des biens {cr}- Les settlers consomment des biens {cr}- Les besoins doivent être satisfaits",
                }
            end
            API.SetTooltipCosts(Title, Text)
        end,
        function(_WidgetID, _BuildingID)
            if Logic.IsEntityInCategory(_BuildingID, EntityCategories.OuterRimBuilding) == 0
            and Logic.IsEntityInCategory(_BuildingID, EntityCategories.CityBuilding) == 0
            or Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0)
            else
                XGUIEng.ShowWidget(_WidgetID, 1)
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID)
            or Logic.IsBuildingBeingKnockedDown(_BuildingID)
            or Logic.IsBurning(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1)
            else
                XGUIEng.DisableButton(_WidgetID, 0)
            end
            SetIcon(_WidgetID, {4, 13})
            if Logic.IsBuildingStopped(_BuildingID) then
                SetIcon(_WidgetID, {4, 12})
            end
        end
    )
end

function Addon_SingleButtons.Local:DropSingleStopButton()
    if self.Data.Button.SingleStop then
        API.DropBuildingButton(self.Data.Button.SingleStop)
        self.Data.Button.SingleStop = nil
    end
end

function Addon_SingleButtons.Local:AddSingleReserveButton()
    if self.Data.Button.SingleReserve then
        return
    end
    self.Data.Button.SingleReserve = API.AddBuildingButton(
        function(_WidgetID, _BuildingID)

        end,
        function(WidgetID, _BuildingID)
            local Title = {
                de = "",
                en = "",
                fr = "",
            }
            local Text = {
                de = "",
                en = "",
                fr = "",
            }
            if Logic.IsBuildingStopped(_BuildingID) then -- Change to reserviert
                Title = {
                    de = "",
                    en = "",
                    fr = "",
                }
                Text = {
                    de = "",
                    en = "",
                    fr = "",
                }
            end
            API.SetTooltipCosts(Title, Text)
        end,
        function(_WidgetID, _BuildingID)
            if Logic.IsEntityInCategory(_BuildingID, EntityCategories.OuterRimBuilding) == 0
            and Logic.IsEntityInCategory(_BuildingID, EntityCategories.CityBuilding) == 0
            or Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0)
            else
                XGUIEng.ShowWidget(_WidgetID, 1)
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID)
            or Logic.IsBuildingBeingKnockedDown(_BuildingID)
            or Logic.IsBurning(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1)
            else
                XGUIEng.DisableButton(_WidgetID, 0)
            end
            SetIcon(_WidgetID, {15, 6})
            if Logic.IsBuildingStopped(_BuildingID) then -- Change to reserviert
                SetIcon(_WidgetID, {10, 9})
            end
        end
    )
end

function Addon_SingleButtons.Local:DropSingleReserveButton()
    if self.Data.Button.SingleReserve then
        API.DropBuildingButton(self.Data.Button.SingleReserve)
        self.Data.Button.SingleReserve = nil
    end
end

function Addon_SingleButtons.Local:AddSingleDowngradeButton()
    if self.Data.Button.SingleKnockDown then
        return
    end
    self.Data.Button.SingleKnockDown = API.AddBuildingButton(
        -- TODO: refactor in a way that the Button cannot be clicked when the downgradecosts are too high
        function(_WidgetID, _BuildingID)
            if self.Data.DowngradeCosts > 0 then
                local CastleID = Logic.GetHeadquarters(GUI.GetPlayerID())
                if Logic.GetAmountOnOutStockByGoodType(CastleID, Goods.G_Gold) >= self.Data.DowngradeCosts then
                    GUI.RemoveGoodFromStock(CastleID, Goods.G_Gold, self.Data.DowngradeCosts)
                else
                    API.Message("Nicht genug Gold!")
                    return
                end
            end
            local Health = Logic.GetEntityHealth(_BuildingID)
            local MaxHealth = Logic.GetEntityMaxHealth(_BuildingID)
            GUI.SendScriptCommand("Logic.HurtEntity(".._BuildingID..", ("..Health.." - ("..MaxHealth.."/2)))")
            Sound.FXPlay2DSound("ui\\menu_click")
            GUI.DeselectEntity(_BuildingID)
        end,
        function(_WidgetID, _BuildingID)
            local Text = {
                de = "Rückbau",
                en = "Downgrade",
                fr = "Déconstruction",
            }
            local Title = {
                de = "- Baut das Gebäude um eine Stufe zurück!",
                en = "- Downgrades the building by one level!",
                fr = "- Réduit le niveau du bâtiment d'un niveau !",
            }
            local Error = {
                de = "Momentan nicht möglich",
                en = "Currently not possible",
                fr = "Pas possible pour le moment",
            }
            if self.Data.DowngradeCosts > 0 then
                API.SetTooltipCosts(Text, Title, Error, {Goods.G_Gold, self.Data.DowngradeCosts})
            else
                API.SetTooltipCosts(Text, Title)
            end
        end,
        function(_WidgetID, _BuildingID)
            if Logic.IsEntityInCategory(_BuildingID, EntityCategories.OuterRimBuilding) == 0
            and Logic.IsEntityInCategory(_BuildingID, EntityCategories.CityBuilding) == 0
            or Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0)
            else
                XGUIEng.ShowWidget(_WidgetID, 1)
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID)
            or Logic.IsBuildingBeingKnockedDown(_BuildingID)
            or Logic.IsBurning(_BuildingID)
            or Logic.CanCancelUpgradeBuilding(_BuildingID)
            or Logic.CanCancelKnockDownBuilding(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1)
            else
                XGUIEng.DisableButton(_WidgetID, 0)
            end
            SetIcon(_WidgetID, {3, 15})
        end
    )
end

function Addon_SingleButtons.Local:DropSingleDowngradeButton()
    if self.Data.Button.SingleKnockDown then
        API.DropBuildingButton(self.Data.Button.SingleKnockDown)
        self.Data.Button.SingleKnockDown = nil
    end
end


function Addon_SingleButtons.Local:SetDowngradeCosts(_Amount)
    self.Data.DowngradeCosts = _Amount
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_SingleButtons)