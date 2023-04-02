function StartScript()
    API.StartDelay(5,  TestHideMinimap);
    API.StartDelay(10, TestHideToggleMinimap);
    API.StartDelay(15, TestHideDiplomacyMenu);
    API.StartDelay(20, TestHideProductionMenu);
    API.StartDelay(25, TestHideWeatherMenu);
    API.StartDelay(30, TestHideBuyTerritory);
    API.StartDelay(35, TestHideKnightAbility);
    API.StartDelay(40, TestHideKnightButton);
    API.StartDelay(45, TestHideSelectionButton);
    API.StartDelay(50, TestHideBuildMenu);
    API.StartDelay(55, TestRestoreInterface);

    API.StartDelay(60, TestChangeColor1);
    API.StartDelay(62, TestChangeColor2);
    API.StartDelay(64, TestChangeColor3);
    API.StartDelay(66, TestChangeColor4);
end

function TestChangeColor1()
    Logic.DEBUG_AddNote("Ändere die Spielerfarbe.");
    API.SetPlayerColor(1, 2);
end

function TestChangeColor2()
    Logic.DEBUG_AddNote("Ändere die Spielerfarbe.");
    API.SetPlayerColor(1, 3);
end

function TestChangeColor3()
    Logic.DEBUG_AddNote("Ändere die Spielerfarbe.");
    API.SetPlayerColor(1, 4);
end

function TestChangeColor4()
    Logic.DEBUG_AddNote("Ändere die Spielerfarbe.");
    API.SetPlayerColor(1, 1);
    Logic.DEBUG_AddNote("ENDE");
end

function TestRestoreInterface()
    Logic.DEBUG_AddNote("Menu wird wiederhergestellt.");
    API.HideMinimap(false);
    API.HideToggleMinimap(false);
    API.HideDiplomacyMenu(false);
    API.HideProductionMenu(false);
    API.HideWeatherMenu(false);
    API.HideBuyTerritory(false);
    API.HideKnightAbility(false);
    API.HideKnightButton(false);
    API.HideSelectionButton(false);
    API.HideBuildMenu(false);
end

function TestHideMinimap()
    Logic.DEBUG_AddNote("Minimap wird ausgeblendet.");
    API.HideMinimap(true);
end

function TestHideToggleMinimap()
    Logic.DEBUG_AddNote("Minimap Button wird ausgeblendet.");
    API.HideToggleMinimap(true);
end

function TestHideDiplomacyMenu()
    Logic.DEBUG_AddNote("Diplomatiemenü wird ausgeblendet.");
    API.HideDiplomacyMenu(true);
end

function TestHideProductionMenu()
    Logic.DEBUG_AddNote("Produktionsmenü wird ausgeblendet.");
    API.HideProductionMenu(true);
end

function TestHideWeatherMenu()
    Logic.DEBUG_AddNote("Wettermenü wird ausgeblendet.");
    API.HideWeatherMenu(true);
end

function TestHideBuyTerritory()
    Logic.DEBUG_AddNote("Territorium Button wird ausgeblendet.");
    API.HideBuyTerritory(true);
end

function TestHideKnightAbility()
    Logic.DEBUG_AddNote("Heldenfähigkeit wird ausgeblendet.");
    API.HideKnightAbility(true);
end

function TestHideKnightButton()
    Logic.DEBUG_AddNote("Selektionsbutton wird ausgeblendet.");
    API.HideKnightButton(true);
end

function TestHideSelectionButton()
    Logic.DEBUG_AddNote("Militärselektionsbutton wird ausgeblendet.");
    API.HideSelectionButton(true);
end

function TestHideBuildMenu()
    Logic.DEBUG_AddNote("Baumenü wird ausgeblendet.");
    API.HideBuildMenu(true);
end

