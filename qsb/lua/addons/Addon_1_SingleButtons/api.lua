
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
end