
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
        },
    },
}

-- Global ------------------------------------------------------------------- --

function Addon_SingleButtons.Global:OnGameStart()
    -- Was zum Spielstart im Globalen Script ausgeführt werden sollte
end

function Addon_SingleButtons.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

-- Local -------------------------------------------------------------------- --

function Addon_SingleButtons.Local:OnGameStart()
    -- Was zum Spielstart im Lokalen Script ausgeführt werden sollte
end

function Addon_SingleButtons.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        -- Was nach dem laden eines Spielstandes ausgeführt werden sollte
        return
    end
end

function Addon_SingleButtons.Local:AddSingleStopButton()
    if self.Data.Button.SingleStop then
        return
    end
    self.Data.Button.SingleStop = API.AddBuildingButton(
        function(_WidgetID, _EntityID)
            -- Den Gestoppt-Status abfragen
            local IsStopped = Logic.IsBuildingStopped(_EntityID)
            -- Den Gestoppt-Status ins Gegenteil umkehren
            GUI.SetStoppedState(_EntityID, not IsStopped)
        end,
        function(WidgetID, EntityID)
            -- Wir zeigen im Regelfall den Text für "Produktion anhalten" an.
            local Title = "Produktion anhalten"
            local Text = "- Gebäude produziert keine Waren {cr}- Siedler "..
                         " verbrauchen keine Güter {cr}- Bedürfnisse müssen "..
                         " nicht erfüllt werden"
            -- Wenn das Gebäude gestoppt ist, wollen wir den Text für "Produktion
            -- fortführen" anzeigen.
            if Logic.IsBuildingStopped(_EntityID) then
                Title = "Produktion fortführen";
                Text = "- Gebäude produziert Waren {cr}- Siedler verbrauchen"..
                       " Güter {cr}- Bedürfnisse müssen erfüllt werden"
            end
            -- Texte an die Tooltip-Funktion übergeben
            API.SetTooltipCosts(Title, Text)
        end,
        function(_WidgetID, _EntityID)
            -- Unter diesen Umständen darf der Button nicht zu sehen sein
            if Logic.IsEntityInCategory(_EntityID, EntityCategories.OuterRimBuilding) == 0
            or Logic.IsEntityInCategory(_EntityID, EntityCategories.CityBuilding) == 0
            or Logic.IsConstructionComplete(_EntityID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0)
            else
                XGUIEng.ShowWidget(_WidgetID, 1)
            end
            -- Unter diesen Umständen darf der Button nicht klickbar sein
            if Logic.IsBuildingBeingUpgraded(_EntityID)
            or Logic.IsBuildingBeingKnockedDown(_EntityID)
            or Logic.IsBurning(_EntityID) then
                XGUIEng.DisableButton(_WidgetID, 1)
            else
                XGUIEng.DisableButton(_WidgetID, 0)
            end
            -- Icon setzen
            SetIcon(_WidgetID, {4, 13})
            if Logic.IsBuildingStopped(_EntityID) then
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
        function(_WidgetID, _EntityID)
        end,
        function(WidgetID, EntityID)
        end,
        function(_WidgetID, _EntityID)
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
        function(_WidgetID, _EntityID)
        end,
        function(WidgetID, EntityID)
        end,
        function(_WidgetID, _EntityID)
        end
    )
end

function Addon_SingleButtons.Local:DropSingleDowngradeButton()
    if self.Data.Button.SingleKnockDown then
        API.DropBuildingButton(self.Data.Button.SingleKnockDown)
        self.Data.Button.SingleKnockDown = nil
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(Addon_SingleButtons)