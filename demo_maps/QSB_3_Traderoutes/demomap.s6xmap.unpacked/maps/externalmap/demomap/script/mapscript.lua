function StartScript()
    CreateTestQuests();
end

function CreateTestQuests()
    API.CreateQuest {
        Name        = "DiscoverHarbor",
        Suggestion  = "Hier gibt es einen Hafen. Den sollte ich mir ansehen.",
        Success     = "Ah, da ist er ja.",

        Goal_DiscoverPlayer(2),
        Reward_Diplomacy(1, 2, "TradeContact"),
        Reward_MapScriptFunction("CreateHarbor"),
        Trigger_Time(5),
    }

    API.CreateQuest {
        Name        = "ActivateRoute1",
        Suggestion  = "Wenn Ihr einen höheren Titel erreicht, wird sich eine "..
                      " neue Handelsroute eröffnen.",
        Success     = "Es werden schon bald die ersten Waren ankommen.",
        Sender      = 2,

        Goal_KnightTitle("Mayor"),
        Reward_MapScriptFunction("CreateRoute1"),
        Trigger_OnQuestSuccess("DiscoverHarbor", 10),
    }

    API.CreateQuest {
        Name        = "ActivateRoute2",
        Suggestion  = "Wenn Ihr einen höheren Titel erreicht, wird sich eine "..
                      " neue Handelsroute eröffnen.",
        Success     = "Es werden schon bald die ersten Waren ankommen.",
        Sender      = 2,

        Goal_KnightTitle("Baron"),
        Reward_MapScriptFunction("CreateRoute2"),
        Trigger_OnQuestSuccess("ActivateRoute1", 10),
    }

    API.CreateQuest {
        Name        = "ActivateRoute3",
        Suggestion  = "Wenn Ihr einen höheren Titel erreicht, wird sich eine "..
                      " neue Handelsroute eröffnen.",
        Success     = "Es werden schon bald die ersten Waren ankommen.",
        Sender      = 2,

        Goal_KnightTitle("Earl"),
        Reward_MapScriptFunction("CreateRoute3"),
        Trigger_OnQuestSuccess("ActivateRoute2", 10),
    }
end

function CreateHarbor()
    API.InitHarbor(2);
end

function CreateRoute1()
    API.AddTradeRoute(
        2,
        {Name       = "Route1",
         Path       = {"Route1WP1", "Route1WP2", "Route1WP3", "Route1WP4", "Route1WP5"},
         Interval   = 10*60,
         Duration   = 2*60,
         Amount     = 2,
         Offers     = {
             {"G_Wool", 5},
             {"U_CatapultCart", 1},
             {"G_Beer", 2},
             {"G_Herb", 5},
         }}
    );
end

function CreateRoute2()
    API.AddTradeRoute(
        2,
        {Name       = "Route2",
         Path       = {"Route2WP1", "Route2WP2"},
         Interval   = 12*60,
         Duration   = 3*60,
         Amount     = 3,
         Offers     = {
             {"G_Grain", 5},
             {"G_Bread", 2},
             {"G_Stone", 5},
             {"G_Wood", 5},
             {"U_Entertainer_NA_StiltWalker", 1},
         }}
    );
end

function CreateRoute3()
    API.AddTradeRoute(
        2,
        {Name       = "Route3",
         Path       = {"Route3WP1", "Route3WP2", "Route3WP3"},
         Interval   = 9*60,
         Duration   = 2*60,
         Amount     = 2,
         Offers     = {
             {"U_MilitarySword", 2},
             {"U_MilitaryBow", 2},
             {"U_SiegeTowerCart", 2},
         }}
    );
end

