function StartScript()
    SetupCattleBreeding();
    SetupSheepBreeding();
    ShowInfoQuest();
end

function ShowInfoQuest()
    API.CreateQuest {
        Name        = "InfoQuest",
        Suggestion  = "Wie es aussieht, kann ich meine Nutztiere vermehren."..
                      " Ich bin sehr gespannt!",
        Description = "Für weitere Details, schaue ins Skript!",

        Goal_NoChange(),
        Trigger_Time(5),
    }
end

-- Es werden keine Kühe benötigt um Kühe zu züchten. Jeder Stall braucht
-- 3 Minuten, bis eine Kuh erscheint. Es geht nicht schneller, egal wie
-- viele Kühe in der Nähe sind.
-- (Es wird weiter Getreide benötigt.)
function SetupCattleBreeding()
    API.ConfigureCattleBreeding{
        RequiredAmount = 0,
        QuantityBoost = 0,
        BreedingTimer = 3*60
    }
end

-- Es werden 5 Schafe benötigt, um neue zu züchten.
-- Die Schafe sind sofort erwachsen.
-- (Es wird weiter Getreide benötigt.)
function SetupSheepBreeding()
    API.ConfigureSheepBreeding{
        RequiredAmount = 5,
        UseCalves = false,
    }
end

