function StartScript()
    API.SetPlayerPortrait(4, "H_NPC_Mercenary_ME");
    API.SetPlayerPortrait(3, "H_NPC_Villager01_ME");
    API.SetPlayerPortrait(5, "H_Knight_Sabatt");

    CreateDemoQuests();
    InitEventListeners();
end

function InitEventListeners()
    -- Wir zeigen eine Nachricht an, wenn Waren gekauft werden
    API.AddScriptEventListener(
        QSB.ScriptEvents.GoodsPurchased,
        function(_OfferID, _Type, _Good, _Amount, _Price, _PlayerID1, _PlayerID2)
            API.Note(string.format(
                "Goods purchased{cr}Player %d Menge: %d Offer: %s Price: %d",
                _PlayerID2,
                _Amount,
                -- Muss zwischen Ware und Entity unterscheiden...
                (_Type == QSB.TraderTypes.GoodTrader and Logic.GetGoodTypeName(_Good))
                or Logic.GetEntityTypeName(_Good),
                _Price
            ));
        end
    );

    -- Wir zeigen zudem eine Nachricht, wenn Waren verkauft werden
    API.AddScriptEventListener(
        QSB.ScriptEvents.GoodsSold,
        function(_Type, _Good, _Amount, _Price, _PlayerID1, _PlayerID2)
            API.Note(string.format(
                "Goods bought{cr}Player %d Menge: %d Offer: %s Price: %d",
                _PlayerID2,
                _Amount,
                -- Sind in diesem Fall sowieso immer Güter
                Logic.GetGoodTypeName(_Good),
                _Price
            ));
        end
    );
end

function CreateDemoQuests()
    API.CreateNestedQuest {
        Name     = "DemoQuestLine",
        Segments = {
            {
                Suggestion  = "Ich schaue mir mal an, was die Händler in der "..
                              "Gegend so zu bieten haben...",
                Description = "Schaue ins Skript, damit du weißt, was hier "..
                              "abgeht.",
                Goal_NoChange(),
            },


            {
                Name        = "DiscoverPlayer3",
                Success     = "Bei uns gibt es Rohstoffe.",
                Sender      = 3,

                Goal_DiscoverPlayer(3),
                Reward_Diplomacy(1, 3, "TradeContact")
            },


            {
                Name        = "DiscoverPlayer4",
                Success     = "Ich handele mit Menschen.",
                Sender      = 4,

                Goal_DiscoverPlayer(4),
                Reward_Diplomacy(1, 4, "TradeContact")
            },


            {
                Name        = "DiscoverPlayer5",
                Success     = "Bei mir gibt es das gute Zeugs!",
                Sender      = 5,

                Goal_DiscoverPlayer(5),
                Reward_Diplomacy(1, 5, "TradeContact")
            },
        },

        Trigger_Time(5)
    }
end

