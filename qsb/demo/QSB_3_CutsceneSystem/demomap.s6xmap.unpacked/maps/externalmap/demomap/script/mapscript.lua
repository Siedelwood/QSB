function StartScript()
end

-- DIESE DEMO MAP IST NOCH NICHT FERTIG!!!

-- > CutsceneTest([[Foo]], 1)
function CutsceneTest(_Name, _PlayerID)
    local Cutscene = {};
    local AF = API.AddCutscenePages(Cutscene);

    AF {
        Flight  = "c01",
        Title   = "Flight 1",
        Text    = "What is the first rule of a cutscene?",
        FadeIn  = 3,
    };
    AF {
        Flight  = "c02",
        Title   = "Flight 2",
        Text    = "They are NOT supposed to display huge chuncks of text!",
    };
    AF {
        Flight  = "c03",
        Title   = "Flight 3",
        Text    = "Keep the text small and simple, stupid!",
        FadeOut = 3,
    };

    Cutscene.Finished = function()
    end
    API.StartCutscene(Cutscene, _Name, _PlayerID)
end

