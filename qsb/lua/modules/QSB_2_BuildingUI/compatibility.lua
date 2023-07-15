
---
-- Fügt einen optionalen Gebäudeschalter hinzu. Der Index bestimmt, welcher
-- der beiden möglichen Buttons verwendet wird.
--
-- Mit dieser Funktion können zwei ungenutzte Buttons im Gebäudemenu mit einer
-- Funktionalität versehen werden. Es obliegt dem Mapper für welche Gebäude
-- der Button angezeigt wird und welche Funktion er hat. Es ist nicht möglich
-- Kosten im Tooltip anzuzeigen.
--
-- Jeder Button kann immer nur mit einer Aktion versehen werden. Soll die
-- Aktion für verschiedene Gebäudetypen unterschiedlich sein, muss in der
-- Aktion eine Fallunterscheidung durchgeführt werden.
--
-- Ein optionaler Button benötigt immer drei Funktionen:
-- <ul>
-- <li>Action: Steuert, was der Button tut.</li>
-- <li>Tooltip: Steuert, welcher Beschreibungstext angezeigt wird.</li>
-- <li>Update: Steuert, wann und wie der Button angezeigt wird.</li>
-- </ul>
-- Alle drei Funktionen erhalten die ID des Buttons und die ID des Gebäudes,
-- das gerade selektiert ist.
--
-- <b>QSB:</b> API.AddBuildingButton(_Action, _Tooltip, _Update)
--
-- @param[type=number]   _Index Index des Buttons
-- @param[type=function] _Action Aktion des Buttons
-- @param[type=function] _Tooltip Tooltip Control
-- @param[type=function] _Update Button Update
-- @within QSB_2_BuildingUI
--
-- @usage
-- -- Aktion
-- function ExampleButtonAction(_WidgetID, _BuildingID)
--     GUI.AddNote("Hier passiert etwas!");
-- end
-- -- Tooltip
-- function ExampleButtonTooltip(_WidgetID, _BuildingID)
--     UserSetTextNormal("Beschreibung", "Das ist die Beschreibung!");
-- end
-- -- Update
-- function ExampleButtonUpdate(_WidgetID, _BuildingID)
--     SetIcon(_WidgetID, {1, 1});
-- end
--
-- -- Beispiel für einen einfachen Button, der immer angezeigt wird, das Bild
-- -- eines Apfels trägt und eine Nachricht anzeigt.
-- API.AddCustomBuildingButton(1, ExampleButtonAction, ExampleButtonTooltip, ExampleButtonUpdate);
--
function API.AddCustomBuildingButton(_Index, _Action, _Tooltip, _Update)
    ModuleBuildingButtons.Local.Data.Compatibility = ModuleBuildingButtons.Local.Data.Compatibility or {}
    ModuleBuildingButtons.Local.Data.Compatibility[_Index] = API.AddBuildingButton(_Action, _Tooltip, _Update)
end

---
-- Entfernt den optionalen Gebäudeschalter mit dem angegebenen Index.
--
-- <b>QSB:</b> API.RemoveCustomBuildingButton(_Index)
--
-- @param[type=number] _Index Index des Buttons
-- @within QSB_2_BuildingUI
--
-- @usage
-- -- Entfernt die Konfiguration für Button 1
-- API.RemoveCustomBuildingButton(1);
--
function API.RemoveCustomBuildingButton(_Index)
    if ModuleBuildingButtons.Local.Data.Compatibility and ModuleBuildingButtons.Local.Data.Compatibility[_Index] then
        API.DropBuildingButton(ModuleBuildingButtons.Local.Data.Compatibility[_Index])
    end
end