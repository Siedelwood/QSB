function StartScript()
    API.CreateQuest {
        Name        = "DemoQuest",
        Suggestion  = "Die Gebäude scheinen mir heute seltsam zu sein...",
        Description = "Schaue die Gebäudeschalter in Natura an und "..
                      " vergleiche mit dem Skript.",

        Goal_NoChange(),
        Trigger_Time(5),
    }
end


