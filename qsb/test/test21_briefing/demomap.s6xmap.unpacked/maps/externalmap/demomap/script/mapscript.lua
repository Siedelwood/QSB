function StartScript()
end

-- DIESE DEMO MAP IST NOCH NICHT FERTIG!!!

-- -------------------------------------------------------------------------- --
-- Test Stuff
-- This is not part of the example!

-- > BriefingTest([[foo]], 1)
function BriefingTest(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is a briefing. I have to say important things.");
    ASP("SpecialNamedPage2", "Page 2", "WOW! That is very cool.");

    Briefing.PageAnimations = {
        ["SpecialNamedPage1"] = {
            Clear = true,
            {30, "npc1", -60, 2000, 35, "npc1", -30, 2000, 25}
        },
        ["SpecialNamedPage2"] = {
            Clear = true,
            {30, "hero", -45, 6000, 35, "hero", -45, 3000, 35}
        },
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > BriefingTest2([[foo]], 1)
function BriefingTest2(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is a briefing. I have to say important things.");
    ASP("SpecialNamedPage2", "Page 2", "WOW! That is very cool.");

    Briefing.PageAnimations = {
        ["SpecialNamedPage1"] = {
            Clear = true,
            {30, {"Pos1", 1500}, {"npc1", 250}, {"Pos2", 1500}, {"npc1", 0}}
        },
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > BriefingTest3([[foo]], 1)
function BriefingTest3(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is a briefing. I have to say important things.");
    ASP("SpecialNamedPage2", "Page 2", "WOW! That is very cool.");

    Briefing.PageAnimations = {
        ["SpecialNamedPage1"] = {
            Clear = true,
            Repeat = true,
            {30, "hero",   0, 4000, 35, "hero", 180, 4000, 35},
            {30, "hero", 180, 4000, 35, "hero", 360, 4000, 35},
        },
    }

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > BriefingTest4([[foo]], 1)
function BriefingTest4(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("SpecialNamedPage1", "Page 1", "This is a briefing. I have to say important things.", false, "hero");
    ASP("SpecialNamedPage2", "Page 2", "WOW! That is very cool.", false, "hero");

    Briefing.PageParallax = {
        ["SpecialNamedPage1"] = {
            {"C:/IMG/Paralax1.png", 60, 0, 0, 1, 1, 255, 0, 0, 1, 1, 255},
            {"C:/IMG/Paralax2.png", 60, 0, 0, 1, 1, 255, 0, 0, 1, 1, 255},
            {"C:/IMG/Paralax3.png", 60, 0, 0, 1, 1, 255, 0, 0, 1, 1, 255},
            {"C:/IMG/Paralax4.png", 60, 0, 0, 1, 1, 255, 0, 0, 1, 1, 255},
        },
        ["SpecialNamedPage2"] = {
            Clear = true
        },
    };

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

-- > BriefingTest5([[foo]], 1)
function BriefingTest5(_Name, _PlayerID)
    local Briefing = {
        EnableBorderPins = false,
        EnableSky = true,
        EnableFoW = false,
    }
    local AP, ASP = API.AddBriefingPages(Briefing);

    ASP("Page 1", "Gleich kommt der Fader...", false, "hero");

    AP {
        Name = "FadingPage",
        Title = "Page 2",
        Text = "Wussshhh...!",
        Position = "hero",
        DialogCamera = true,
        BarOpacity = 0;
        Duration = 3,
    }
    AP {
        Name = "DarkPage",
        Position = "hero",
        DialogCamera = true,
        Duration = 3,
        FaderAlpha = 1,
    }

    ASP("Page 4", "Das war aber cool...", false, "hero");

    Briefing.PageParallax = {
        ["FadingPage"] = {
            Foreground = true,
            {"C:/IMG/Fader1.png", 3, 0.5, 0, 1, 1, 255, 0, 0, 0.5, 1, 255},
        },
        ["DarkPage"] = {
            Clear = true
        },
    };

    Briefing.Starting = function(_Data)
    end
    Briefing.Finished = function(_Data)
    end
    API.StartBriefing(Briefing, _Name, _PlayerID)
end

