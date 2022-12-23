function StartScript()
    AddGeneralBuildingButton();
    AddTypeBuildingButton();
    AddNameBuildingButton();
end

-- Ein allgemeiner Button
-- Allgemeine Buttons werden prinzipiell für alle Gebäude angezeigt, wenn nicht
-- anders in ihrer Update-Funktion beschrieben. Buttons für Typen oder benannte
-- Entities haben eine höhere Anzeigepriorität und verdrängen diesen Button.
function AddGeneralBuildingButton()
    SpecialButtonID = API.AddBuildingButton(
        -- Aktion
        function(_WidgetID, _BuildingID)
            GUI.AddNote("Allgemeiner Button wurde geklickt.");
        end,
        -- Tooltip
        function(_WidgetID, _BuildingID)
            API.SetTooltipCosts("Gewöhnlicher Button", "Dieser Button ist immer da, wenn er nicht durch höhere Prioritär verdrängt wird.");
        end,
        -- Update
        function(_WidgetID, _BuildingID)
            if Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0);
                return;
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1);
            end
            SetIcon(_WidgetID, {1, 1});
        end
    );
end

-- Ein Button für einen Typ
-- Buttons für Typen sind für alle Gebäude eines Typs sichtbar, außer in der
-- Update-Funktion wurde anderes festgelegt. Buttons für mit Skriptnamen
-- versehene Entities verdrängen diesen Button.
function AddTypeBuildingButton()
    SpecialButtonID = API.AddBuildingButtonByType(
        -- Der Gebäudetyp
        Entities.B_Butcher,
        -- Aktion
        function(_WidgetID, _BuildingID)
            GUI.AddNote("Der spezielle Metzgerbutton wurde geklickt.");
        end,
        -- Tooltip
        function(_WidgetID, _BuildingID)
            API.SetTooltipCosts("Besonderer Button", "Dieser Button wird für alle Metzger angezeigt, wenn er nicht durch höhere Prioritär verdrängt wird.");
        end,
        -- Update
        function(_WidgetID, _BuildingID)
            if Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0);
                return;
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1);
            end
            SetIcon(_WidgetID, {1, 2});
        end
    );
end

-- Ein Button für ein bestimmtes Entity
-- Dieser Button ist nur für das Entity "Building1" sichtbar. Er hat die höchste
-- Priorität und kann nicht verdrängt werden.
function AddNameBuildingButton()
    SpecialButtonID = API.AddBuildingButtonByEntity(
        -- Der Skriptname
        "Building1",
        -- Aktion
        function(_WidgetID, _BuildingID)
            GUI.AddNote("Exklusiver Button für \"Building1\" wurde geklickt.");
        end,
        -- Tooltip
        function(_WidgetID, _BuildingID)
            API.SetTooltipCosts("Exklusiver Button", "Dieser Button ist nur für das Entity \"Building1\" sichtbar.");
        end,
        -- Update
        function(_WidgetID, _BuildingID)
            if Logic.IsConstructionComplete(_BuildingID) == 0 then
                XGUIEng.ShowWidget(_WidgetID, 0);
                return;
            end
            if Logic.IsBuildingBeingUpgraded(_BuildingID) then
                XGUIEng.DisableButton(_WidgetID, 1);
            end
            SetIcon(_WidgetID, {1, 3});
        end
    );
end

