
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
    if _Flag == true then
        Addon_SingleButtons.Local:AddSingleStopButton()
    else
        Addon_SingleButtons.Local:DropSingleStopButton()
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
    if _Flag == true then
        Addon_SingleButtons.Local:AddSingleReserveButton()
    else
        Addon_SingleButtons.Local:DropSingleReserveButton()
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
    if _Flag == true then
        Addon_SingleButtons.Local:AddSingleDowngradeButton()
    else
        Addon_SingleButtons.Local:DropSingleDowngradeButton()
    end
end