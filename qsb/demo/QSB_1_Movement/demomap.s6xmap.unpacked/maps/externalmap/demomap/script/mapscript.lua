function StartScript()
    CreatePathFoundEventListener();
    CreateStartPathFindingQuest();
    CreateMovingDudesQuest();
end

-- Erzeugt die Quests für die verschiedenen Bewegungsfunktionen.
function CreateMovingDudesQuest()
    API.CreateQuest {
        Name        = "MovingDudeQuest1",
        Suggestion  = "Diesem Typ zuckt schon der Fuß!",
        Success     = "Er bewegt sich ganz normal von A nach B.",

        Goal_KnightDistance("Kerl1", 500),
        Reward_MapScriptFunction(function()
            API.MoveEntity("Kerl1", "Pos1");
        end),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "MovingDudeQuest2",
        Suggestion  = "Diesem Typ zuckt schon der Fuß!",
        Success     = "Er bewegt sich von A nach B und schaut dann jemand an.",

        Goal_KnightDistance("Kerl2", 500),
        Reward_MapScriptFunction(function()
            API.MoveEntityAndLookAt("Kerl2", "Pos2", "Kerl1");
        end),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "MovingDudeQuest3",
        Suggestion  = "Diesem Typ zuckt schon der Fuß!",
        Success     = "Dieser Typ bewegt sich relativ zur Position.",

        Goal_KnightDistance("Kerl3", 500),
        Reward_MapScriptFunction(function()
            API.MoveEntityToPosition("Kerl3", "Pos3", 1000, 45);
        end),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "MovingDudeQuest4",
        Suggestion  = "Diesem Typ zuckt schon der Fuß!",
        Success     = "Der Typ bewegt sich von A nach B und macht dann was.",

        Goal_KnightDistance("Kerl4", 500),
        Reward_MapScriptFunction(function()
            API.MoveEntityAndExecute("Kerl4", "Pos4", function()
                Logic.DEBUG_AddNote("Sometimes it just work's!");
            end);
        end),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "MovingDudeQuest5",
        Suggestion  = "Diesem Typ zuckt schon der Fuß!",
        Success     = "Der Typ bewegt sich offenbar mit Lichtgeschwindigkeit.",

        Goal_KnightDistance("Kerl5", 500),
        Reward_MapScriptFunction(function()
            API.PlaceEntityAndLookAt("Kerl5", "Pos5", "Kerl1");
        end),
        Trigger_Time(5),
    }
end

-- Erzeugt die Quests für die Wegfindung.
function CreateStartPathFindingQuest()
    API.CreateQuest {
        Name        = "PathFindingStart",
        Suggestion  = "Da beginnt ein seltsames Netz aus Wegen. Ich frage "..
                      " micht, was der kürzeste Weg sein mag.",
        Success     = "Jetzt muss ich wohl ein paar Sekunden warten.",
        Description = "Es wird eine Wegsuche gestartet, sobald die Position "..
                      " besucht wird.",

        Goal_KnightDistance("Start", 500),
        Reward_MapScriptFunction("StartPathfinding"),
        Trigger_Time(20),
    }

    API.CreateQuest {
        Name        = "PathFindingFinished",
        Success     = "Ah, das ist also der richtige Weg.",

        Goal_InstantSuccess(),
        Reward_MapScriptFunction(function()
            -- Der Pfad wird als Liste von Entity-IDs geholt.
            WaypointList = API.RetrievePath(RoadPathID);
            -- Bewege den Held über die Wegpunkte.
            API.MoveEntityOnCheckpoints(Logic.GetKnightID(1), WaypointList);
        end),
        Trigger_MapScriptFunction(function()
            -- Wenn der Pfad fertig ist, wird der Quest ausgelöst.
            return API.IsPathExisting(RoadPathID) and not API.IsPathBeingCalculated(RoadPathID);
        end),
    }
end

-- Erzeugt Listener, die auf die Wegsuche horchen.
function CreatePathFoundEventListener()
    -- Wenn der Pfad gefunden wurde, wird er mit Flaggen hervorgehoben.
    API.AddScriptEventListener(
        QSB.ScriptEvents.PathFindingFinished,
        function(_PathID)
            if _PathID == RoadPathID then
                local FoundPath = API.RetrievePath(_PathID);
                for i= 1, #FoundPath do
                    Logic.SetModel(FoundPath[i], Models.Doodads_D_X_Flag);
                    Logic.SetVisible(FoundPath[i], true);
                end
            end
        end
    );

    -- Das sollte eigentlich nicht passieren... ^^
    API.AddScriptEventListener(
        QSB.ScriptEvents.PathFindingFailed,
        function(_PathID)
            Logic.DEBUG_AddNote("Path finding failed: " .._PathID);
        end
    );
end

-- Sucht eine Straßenverbindung zwischen zwei Punkten.
function StartPathfinding()
    RoadPathID = API.StartPathfinding("Start", "Ziel", function(_CurrentNode, _AdjacentNodes)
        -- Die Position darf nicht im Blocking sein.
        if Logic.DEBUG_GetSectorAtPosition(_CurrentNode.X, _CurrentNode.Y) == 0 then
            return false;
        end
        -- Die Position muss über eine Straße mit dem Start verbunden sein.
        local x,y,z = Logic.EntityGetPos(GetID("Start"));
        local e1, l1 = Logic.DoesRoadConnectionExist(_CurrentNode.X, _CurrentNode.Y, x, y, false, 10, nil);
        if not e1 then
            return false;
        end
        -- Position akzeptieren
        return true;
    end);
end

-- Start und Ende werden durch Questmarker hervorgehoben.
function CreatePathEndingMarkers()
    local Position;
    Position = GetPosition("Start");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
    Position = GetPosition("Ziel");
    Logic.CreateEffect(EGL_Effects.E_Questmarker_low, Position.X, Position.Y, 0);
end

