function StartScript()
    CreateDemoQuests();
end

function CreateDemoQuests()
    API.CreateQuest {
        Name        = "InfoQuest1",
        Suggestion  = "Auf dem Gebiet Territory3 kann ich keine Fischer bauen.",

        Goal_NoChange(),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "InfoQuest2",
        Suggestion  = "Auf dem Gebiet Territory2 kann ich Getreidefarmen "..
                      "nicht mehr abreißen.",

        Goal_NoChange(),
        Trigger_Time(5),
    }
end

