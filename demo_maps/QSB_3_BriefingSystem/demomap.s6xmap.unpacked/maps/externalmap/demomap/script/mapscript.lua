function StartScript()
    Briefing1_Intro("Briefing1", 1);
    Briefing2_FrancisProposes("Briefing2", 1);
    CreateDemoQuests();

    -- Nicht von interesse
    SetDiplomacyState(1, 2, -1);
    DeleteWallConstructionWorkers();
    CreateDecorationalTrees();
end

-- -------------------------------------------------------------------------- --

function CreateDemoQuests()
    API.CreateQuest {
        Name        = "Q01_TakeRequest",
        Suggestion  = "Ha, das wäre doch gelacht! Ihr Vater wird mich "..
                      "niemals davon abbringen, Lis'ar zum Weibe zu nehmen. "..
                      "Wir sind für einander bestimmt! Das spüre ich aus den "..
                      "tiefen meiner H... Seele, Jawohl!",
        Success     = "Comte Ludwig Moreau, ich, Francis Bernard, bin hier, "..
                      "um die Hand Euer Tochter Lis'ar anzuhalten. Ich spüre "..
                      "die Flammen der Liebe in mir lodern, wenn ich in ihre "..
                      "Augen sehe. Sie ist mein und ihr bin ich!",

        Goal_KnightDistance("ludwig", 1000),
        Reward_Victory(),
        Trigger_Briefing("Briefing1", 1, 0)
    }
end

-- -------------------------------------------------------------------------- --

function Briefing2_FrancisProposes(_Name, _PlayerID)
    local Briefing = {};
    local AP, ASP = API.AddBriefingPages(Briefing);

    AP {
        Name     = "Page1",
        Title    = "Francis Bernard",
        Text     = "Lis'ar, mein Sonnenschein, heute ist endlich der Tag "..
                   "gekommen. Ich wurde zum Ritter geschlagen und nun muss "..
                   "mich Euer Vater endlich als seinen Schwiegersohn "..
                   "akzeptieren!",
    }
    AP {
        Title    = "Lisar",
        Text     = "Das wäre nur zu schön, liebster Francis. Doch mein "..
                   "Vater ist nichtgrundlos verschrien als 'Ludwig, der "..
                   "Freierschreck'. Er hat bisher jeden jungen Mann "..
                   "vertrieben, der ihm nicht zusagte."..
                   "{cr}{cr}Mein Vater wird Euch gewiss auf die Probe "..
                   "stellen. Doch erwartet keine sinnvolle Aufgabe!",
    }
    AP {
        Title    = "Francis Bernard",
        Text     = "Wird er Schindluder mit mir treiben und Stuss von mir "..
                   "verlangen, um mich in die Flucht zu schlagen? Das wird "..
                   "nicht funktionieren! Ich habe Euch versprochen, Euch"..
                   " zur Frau zu nehmen und ich bin ein Mann, der seine "..
                   "Versprechen einlöst.",
    }
    AP {
        Title    = "Lisar",
        Text     = "Dann geht und sprecht mit ihm, mein Liebster! Stellt "..
                   "Euch seiner Prüfung und überzeugt ihn, dass Ihr meiner "..
                   "Hand würdig seid. {cr}{cr}Ich bin zuversichtlich, dass "..
                   "es ihm nicht gelingen kann, Euch zuentmutigen!",
    }

    Briefing.PageAnimations = {
        ["Page1"] = {
            {1, "q01_meetingpoint", -90, 2400, 30},
        },
    };

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
        Logic.ExecuteInLuaLocalState("ResetNormalCamera()");
    end
    API.StartBriefing(Briefing, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --

function Briefing1_Intro(_Name, _PlayerID)
    local Briefing = {};
    local AP, ASP = API.AddBriefingPages(Briefing);

    AP {
        Name     = "Page1",
        Title    = "",
        Text     = "Der Wind trug das Donnern der Hufe, als ein junger "..
                   "Ritter eilig entlang ritt. Sehnsucht war es, die ihn "..
                   "voran trieb....",
        BigBars  = false,
        Duration = 14,
        FadeIn   = 3,
        Action   = function()
            local pos = GetPosition("c01_francisPos1")
            local ID = Logic.CreateEntity(Entities.U_KnightChivalry, pos.X, pos.Y, 90, 8);
            Logic.SetEntityName(ID, "fakeFrancis1");
            API.MoveEntity("fakeFrancis1", "c01_francisPos2");

            API.SoundSetVolume(100);
            API.SoundSetUIVolume(0);
            API.SoundSetMusicVolume(75);
            API.SoundSetAtmoVolume(0);
            API.SoundSetVoiceVolume(0);
            API.StartEventPlaylist(gvMission.PlaylistRootPath.. "demomapplaylistrain.xml", 1);
        end,
    }

    AP {
        Name     = "Page2",
        Title    = "",
        Text     = "Die Menschen dieses Landes waren bekannt für die Kunst, "..
                   "die schönsten Pflanzen der Welt zu kultivieren. Die "..
                   "Floristen hüteten sie wie ihre Augäpfel. Wundervolle, "..
                   "anmutige Blumen, die ihres Gleichen suchten...",
        BigBars  = false,
        Duration = 16,
    }

    AP {
        Name     = "Page3",
        Title    = "",
        Text     = "",
        BigBars  = false,
        Duration = 10,
        Action   = function()
            API.MoveEntity("fakeFrancis2", "c01_francisPos4")
        end,
    }

    AP {
        Name     = "Page4",
        Title    = "",
        Text     = "La Mans, die geschäftigste Stadt des Landes. Zentrum des "..
                   "Handels und Herz des pulsierenden Lebens. Als Residenz "..
                   "des Comte Ludwig Moreau Ziel für jene, die diplomatische "..
                   "oder geschäftliche Anliegen hatten....",
        BigBars  = false,
        Duration = 16,
        FadeOut  = 1,
    }

    AP {
        Name     = "Page5",
        Title    = "",
        Text     = "Dies ist die Geschichte Francis' Bernards Kampf um die "..
                   "Liebe.",
        BigBars  = false,
        Duration = 8,
        FadeIn   = 1,
        FadeOut  = 3,
    }

    Briefing.PageAnimations = {
        ["Page1"] = {
            {15, "c01_pos1",  2, 4500, 28,
                 "c01_pos1", -2, 4500, 27},
        },
        ["Page2"] = {
            Clear = true,
            {40, "q01_flowerPos3", -125, 2500, 10,
                 "q01_flowerPos3",   30, 2500, 10},
        },
        ["Page3"] = {
            Clear = true,
            {13, {"c01_francisPos3", 3500}, {"fakeFrancis2", 0},
                 {"c01_francisPos3", 3500}, {"c01_francisPos4", 750},}
        },
        ["Page4"] = {
            Clear = true,
            {20, {"c02_rightGuardPos1", 200}, {"storehouse2", 75},
                 {"c02_rightGuardPos1", 200}, {"storehouse2", 875}},
        },
        ["Page5"] = {
            Clear = true,
            {8, "q01_meetingpoint", -90, 1550, 20,
                 "q01_meetingpoint", -90, 2000, 25},
        },
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
        API.StopEventPlaylist(gvMission.PlaylistRootPath.. "demomapplaylistrain.xml", 1);
        API.SoundRestore();
    end
    API.StartBriefing(Briefing, _Name, _PlayerID);
end

-- -------------------------------------------------------------------------- --

function DeleteWallConstructionWorkers()
    API.AddScriptEventListener(
        QSB.ScriptEvents.LoadscreenClosed,
        function()
            for k, v in pairs(GetPlayerEntities(2, Entities.U_WallConstructionWorker)) do
                DestroyEntity(v);
            end
        end
    );
end

function CreateDecorationalTrees()
    local TreeTypes = {
        Entities.R_ME_Tree_Birch01,
        Entities.R_ME_Tree_Birch02,
        Entities.R_ME_Tree_Birch03,
        Entities.R_ME_Tree_Birch04,
        Entities.R_ME_Tree_Birch05
    }
    for k, v in pairs(API.SearchEntitiesByScriptname("^decoTree")) do
        local RandomType = math.random(1, #TreeTypes)
        ReplaceEntity(v, TreeTypes[RandomType], 0)
    end
end

