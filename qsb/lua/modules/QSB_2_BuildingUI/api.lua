-- -------------------------------------------------------------------------- --

---
-- Ermöglicht es zusätzliche Buttons im Gebäudemenü platzieren.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(0) Anzeigesteuerung</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field UpgradeStarted     Ein Ausbau wurde gestartet. (Parameter: EntityID, PlayerID)
-- @field UpgradeCanceled    Ein Ausbau wurde abgebrochen. (Parameter: EntityID, PlayerID)
-- @field FestivalStarted    Ein Fest wurde gestartet. (Parameter: PlayerID)
-- @field SermonStarted      Eine Predigt wurde gestartet. (Parameter: PlayerID)
-- @field TheatrePlayStarted Ein Schauspiel wurde abgebrochen. (Parameter: EntityID, PlayerID)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Fügt einen allgemeinen Gebäudeschalter an der Position hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion.
--
-- Die Position wird lokal zur linken oberen Ecke des Fensters angegeben.
--
-- @param[type=number]   _X       X-Position des Button
-- @param[type=number]   _Y       Y-Position des Button
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
--
-- @usage
-- SpecialButtonID = API.AddBuildingButton(
--     -- Position (X, Y)
--     230, 180,
--     -- Aktion
--     function(_WidgetID, _BuildingID)
--         GUI.AddNote("Hier passiert etwas!");
--     end,
--     -- Tooltip
--     function(_WidgetID, _BuildingID)
--         -- Es MUSS ein Kostentooltip verwendet werden.
--         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
--     end,
--     -- Update
--     function(_WidgetID, _BuildingID)
--         -- Ausblenden, wenn noch in Bau
--         if Logic.IsConstructionComplete(_BuildingID) == 0 then
--             XGUIEng.ShowWidget(_WidgetID, 0);
--             return;
--         end
--         -- Deaktivieren, wenn ausgebaut wird.
--         if Logic.IsBuildingBeingUpgraded(_BuildingID) then
--             XGUIEng.DisableButton(_WidgetID, 1);
--         end
--         SetIcon(_WidgetID, {1, 1});
--     end
-- );
--
function API.AddBuildingButtonAtPosition(_X, _Y, _Action, _Tooltip, _Update)
    return ModuleBuildingButtons.Local:AddButtonBinding(0, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen allgemeinen Gebäudeschalter hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion.
--
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
--
-- @usage
-- SpecialButtonID = API.AddBuildingButton(
--     -- Aktion
--     function(_WidgetID, _BuildingID)
--         GUI.AddNote("Hier passiert etwas!");
--     end,
--     -- Tooltip
--     function(_WidgetID, _BuildingID)
--         -- Es MUSS ein Kostentooltip verwendet werden.
--         API.SetTooltipCosts("Beschreibung", "Das ist die Beschreibung!");
--     end,
--     -- Update
--     function(_WidgetID, _BuildingID)
--         -- Ausblenden, wenn noch in Bau
--         if Logic.IsConstructionComplete(_BuildingID) == 0 then
--             XGUIEng.ShowWidget(_WidgetID, 0);
--             return;
--         end
--         -- Deaktivieren, wenn ausgebaut wird.
--         if Logic.IsBuildingBeingUpgraded(_BuildingID) then
--             XGUIEng.DisableButton(_WidgetID, 1);
--         end
--         SetIcon(_WidgetID, {1, 1});
--     end
-- );
--
function API.AddBuildingButton(_Action, _Tooltip, _Update)
    return API.AddBuildingButtonAtPosition(nil, nil, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für den Entity-Typ hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle 
-- allgemeinen Buttons für den Typ ignoriert.
--
-- @param[type=number]   _Type    Typ des Gebäudes
-- @param[type=number]   _X       X-Position des Button
-- @param[type=number]   _Y       Y-Position des Button
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByTypeAtPosition(_Type, _X, _Y, _Action, _Tooltip, _Update)
    return ModuleBuildingButtons.Local:AddButtonBinding(_Type, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für den Entity-Typ hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion. Wenn ein Typ einen Button zugewiesen bekommt, werden alle 
-- allgemeinen Buttons für den Typ ignoriert.
--
-- @param[type=number]   _Type    Typ des Gebäudes
-- @param[type=function] _Action  Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update  Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByType(_Type, _Action, _Tooltip, _Update)
    return API.AddBuildingButtonByTypeAtPosition(_Type, nil, nil, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für das Entity hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
-- alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.
--
-- @param[type=function] _ScriptName Scriptname des Entity
-- @param[type=number]   _X          X-Position des Button
-- @param[type=number]   _Y          Y-Position des Button
-- @param[type=function] _Action     Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip    Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update     Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByEntityAtPosition(_ScriptName, _X, _Y, _Action, _Tooltip, _Update)
    return ModuleBuildingButtons.Local:AddButtonBinding(_ScriptName, _X, _Y, _Action, _Tooltip, _Update);
end

---
-- Fügt einen Gebäudeschalter für das Entity hinzu.
--
-- Einem Gebäude können maximal 6 Buttons zugewiesen werden! Auf diese Weise
-- hinzugefügte Buttons sind prinzipiell immer sichtbar, abhängig von ihrer
-- Update-Funktion. Wenn ein Entity einen Button zugewiesen bekommt, werden
-- alle allgemeinen Buttons und alle Buttons für Typen für das Entity ignoriert.
--
-- @param[type=function] _ScriptName Scriptname des Entity
-- @param[type=function] _Action     Funktion für die Aktion beim Klicken
-- @param[type=function] _Tooltip    Funktion für die angezeigte Beschreibung
-- @param[type=function] _Update     Funktion für Anzeige und Verfügbarkeit
-- @return[type=number] ID des Bindung
-- @within Anwenderfunktionen
-- @see API.AddBuildingButton
--
function API.AddBuildingButtonByEntity(_ScriptName, _Action, _Tooltip, _Update)
    return API.AddBuildingButtonByEntityAtPosition(_ScriptName, nil, nil, _Action, _Tooltip, _Update);
end

---
-- Entfernt einen allgemeinen Gebäudeschalter.
--
-- @param[type=number] _ID ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButton(SpecialButtonID);
--
function API.DropBuildingButton(_ID)
    return ModuleBuildingButtons.Local:RemoveButtonBinding(0, _ID);
end

---
-- Entfernt einen Gebäudeschalter vom Gebäudetypen.
--
-- @param[type=number] _Type Typ des Gebäudes
-- @param[type=number] _ID   ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButtonFromType(Entities.B_Bakery, SpecialButtonID);
--
function API.DropBuildingButtonFromType(_Type, _ID)
    return ModuleBuildingButtons.Local:RemoveButtonBinding(_Type, _ID);
end

---
-- Entfernt einen Gebäudeschalter vom benannten Gebäude.
--
-- @param[type=string] _ScriptName Skriptname des Entity
-- @param[type=number] _ID         ID des Bindung
-- @within Anwenderfunktionen
-- @usage
-- API.DropBuildingButtonFromEntity("Bakery", SpecialButtonID);
--
function API.DropBuildingButtonFromEntity(_ScriptName, _ID)
    return ModuleBuildingButtons.Local:RemoveButtonBinding(_ScriptName, _ID);
end

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
            ModuleBuildingButtons.Local:AddSingleStopButton()
        else
            ModuleBuildingButtons.Local:DropSingleStopButton()
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
            ModuleBuildingButtons.Local:AddSingleReserveButton()
        else
            ModuleBuildingButtons.Local:DropSingleReserveButton()
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
            ModuleBuildingButtons.Local:AddSingleDowngradeButton()
        else
            ModuleBuildingButtons.Local:DropSingleDowngradeButton()
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
        ModuleBuildingButtons.Local:SetDowngradeCosts(_Amount)
	else
		Logic.ExecuteInLuaLocalState(string.format(
			[[
				API.SetDowngradeCosts(%d)
			]],
            _Amount
		))
	end
end
