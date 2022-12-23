function StartScript()
    API.StartDelay(5, TestDeactivateBorderScroll);
    API.StartDelay(20, TestActivateBorderScroll);

    API.StartDelay(25, TestShowBlackscreen);
    API.StartDelay(40, TestHideBlackscreen);

    API.StartDelay(45, TestStartCinematicEvent);
    API.StartDelay(60, TestEndCinematicEvent);
end

function TestStartCinematicEvent()
    Logic.DEBUG_AddNote("Aktiviere Cinematic Event.");
    API.StartCinematicEvent("TestCinematic", 1);
end

function TestEndCinematicEvent()
    Logic.DEBUG_AddNote("Deaktiviere Cinematic Event.");
    API.FinishCinematicEvent("TestCinematic", 1);
    Logic.DEBUG_AddNote("ENDE");
end

function TestDeactivateBorderScroll()
    Logic.DEBUG_AddNote("Border Scroll ist jetzt deaktiviert.");
    API.DeactivateBorderScroll(1);
end

function TestActivateBorderScroll()
    Logic.DEBUG_AddNote("Border Scroll ist wieder aktiviert.");
    API.ActivateBorderScroll(1);
end

function TestShowBlackscreen()
    Logic.DEBUG_AddNote("Zeige einen schwarzen Bildschirm.");
    API.ActivateImageScreen(1, "", 0, 0, 0, 255);
    API.DeactivateNormalInterface(1);
end
function TestHideBlackscreen()
    Logic.DEBUG_AddNote("Verstecke schwarzen Bildschirm.");
    API.DeactivateImageScreen(1);
    API.ActivateNormalInterface(1);
end

