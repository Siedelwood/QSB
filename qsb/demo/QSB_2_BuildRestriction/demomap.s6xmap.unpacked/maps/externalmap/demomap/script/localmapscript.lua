function StartScript()
    SetupFisherProhibition();
    SetupGrainfarmProtection();
end

-- Hier wird ein benutzerdefinierter Abrissschutz erzeugt. Alle Getreidefarmen
-- auf Territorium dürfen nicht abgerissen werden.
function SetupGrainfarmProtection()
    local ProtectFarmer = function(_PlayerID, _BuildingID, _X, _Y)
        -- Soll eine Getreidefarm abgerissen werden?
        if _PlayerID == 1 and Logic.GetEntityType(_BuildingID) == Entities.B_GrainFarm then
            -- Auf Territorium 3 dürfen stehen alle Getreidefarmen unter
            -- Denkmalschutz und können nicht abgerissen werden.
            local TerritoryID = Logic.GetTerritoryAtPosition(_X, _Y);
            if TerritoryID == 3 then
                return true;
            end
        end
        -- Alle anderen Gebäude werden ignoriert.
        return false;
    end
    GrainfarmProtectionID = API.ProtectBuildingCustomFunction(1, ProtectFarmer);
end

-- Hier wird ein benutzerdefiniertes Bauverbot erzeugt. In Territoriun 4 können
-- keine Fischerhütten gebaut werden.
function SetupFisherProhibition()
    local NoFisher = function(_PlayerID, _Type, _X, _Y)
        -- Soll ein Fischer gebaut werden?
        if _PlayerID == 1 and _Type == Entities.B_FishingHut then
            -- Auf Territorium 4 dürfen keine Fischer gebaut werden, weil es
            -- ein Fischschutzgebiet ist. ;)
            local TerritoryID = Logic.GetTerritoryAtPosition(_X, _Y);
            if TerritoryID == 4 then
                return true;
            end
        end
        -- Alle anderen Gebäude werden ignoriert.
        return false;
    end
    FisherRestrictionID = API.RestrictBuildingCustomFunction(1, NoFisher);
end

