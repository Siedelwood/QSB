function StartScript()
    gvMission.SermonCount = 0;
    gvMission.GovernMeFester = 0;
    CreateSermonEventListener();
    CreateInfoQuest();
end

-- Wenn eine Predigt gestarted wird, wird der Zähler erhöht.
-- Der Zähler wird in den Aufstiegsbedingungen verwendet.
function CreateSermonEventListener()
    API.AddScriptEventListener(
        QSB.ScriptEvents.SermonStarted,
        function(_PlayerID)
            if _PlayerID == 1 then
                gvMission.SermonCount = gvMission.SermonCount +1;
            end
        end
    );
end

-- Erstellt einen Quest, damit der Spieler weiß, was Sache ist.
function CreateInfoQuest()
    API.CreateQuest {
        Name        = "InfoQuest",
        Suggestion  = "Wenn ich einen höreren Titel erlange, kann ich meinen "..
                      "Regierungsstil festlegen. Das klingt interessant!",

        Goal_KnightTitle("Mayor"),
        Trigger_Time(5),
    }
end

-- Nachdem der Spieler sein Paradigma gewählt hat, werden die Bedingungen
-- für den nächsten Titel angepasst.
function PromotionParadigmaSelectionCallback(_Selected)
    gvMission.GovernMeFester = _Selected;
    if _Selected == 1 then
        Logic.ExecuteInLuaLocalState("SetBaronPromotionParadigmMilitary()");
        SetBaronPromotionParadigmMilitary();
    elseif _Selected == 2 then
        Logic.ExecuteInLuaLocalState("SetBaronPromotionParadigmEconomy()");
        SetBaronPromotionParadigmEconomy();
    elseif _Selected == 3 then
        Logic.ExecuteInLuaLocalState("SetBaronPromotionParadigmFaith()");
        SetBaronPromotionParadigmFaith();
    end
end

